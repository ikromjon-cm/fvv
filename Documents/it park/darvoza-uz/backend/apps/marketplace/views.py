from django.db.models import F, Value
from django.db.models.functions import ACos, Cos, Radians, Sin
from rest_framework import viewsets, permissions, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Category, GateType, Seller, Product, Review, Favorite, Banner
from .serializers import (
    CategorySerializer, GateTypeSerializer, SellerListSerializer,
    SellerDetailSerializer, ProductSerializer, ReviewSerializer,
    FavoriteSerializer, BannerSerializer
)

class CategoryViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

class GateTypeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = GateType.objects.all()
    serializer_class = GateTypeSerializer

class SellerViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Seller.objects.filter(is_active=True).order_by('-rating')
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['company_name', 'city', 'district']
    ordering_fields = ['rating', 'created_at']
    ordering = ['-rating']

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return SellerDetailSerializer
        return SellerListSerializer

    @action(detail=False, methods=['get'])
    def me(self, request):
        if not request.user.is_authenticated or not hasattr(request.user, 'seller_profile'):
            return Response({'detail': 'Sotuvchi profili topilmadi'}, status=404)
        serializer = SellerDetailSerializer(request.user.seller_profile)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def nearby(self, request):
        lat = request.query_params.get('lat')
        lng = request.query_params.get('lng')
        if not lat or not lng:
            return Response({'error': 'lat and lng required'}, status=400)
        lat, lng = float(lat), float(lng)
        sellers = Seller.objects.filter(is_active=True).annotate(
            distance=ACos(
                Sin(Radians(Value(lat))) * Sin(Radians(F('latitude'))) +
                Cos(Radians(Value(lat))) * Cos(Radians(F('latitude'))) *
                Cos(Radians(F('longitude')) - Radians(Value(lng)))
            ) * Value(6371)
        ).order_by('distance')
        page = self.paginate_queryset(sellers)
        if page:
            serializer = SellerListSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = SellerListSerializer(sellers, many=True)
        return Response(serializer.data)

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.filter(is_active=True)
    serializer_class = ProductSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'gate_type', 'seller', 'material', 'has_delivery', 'has_installation', 'is_promoted']
    search_fields = ['title', 'description', 'material']
    ordering_fields = ['price', 'rating', 'created_at']

    def get_permissions(self):
        if self.action in ('create', 'update', 'partial_update', 'destroy'):
            return [permissions.IsAuthenticated()]
        return [permissions.AllowAny()]

    def perform_create(self, serializer):
        user = self.request.user
        if hasattr(user, 'seller_profile'):
            serializer.save(seller=user.seller_profile)
        else:
            serializer.save()

    @action(detail=False, methods=['get'])
    def promoted(self, request):
        products = self.queryset.filter(is_promoted=True)[:10]
        serializer = self.get_serializer(products, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def reviews(self, request, pk=None):
        product = self.get_object()
        reviews = product.reviews.all()
        serializer = ReviewSerializer(reviews, many=True)
        return Response(serializer.data)

class FavoriteViewSet(viewsets.ModelViewSet):
    serializer_class = FavoriteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Favorite.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=False, methods=['post'])
    def toggle(self, request):
        product_id = request.data.get('product')
        if not product_id:
            return Response({'error': 'product required'}, status=400)
        fav, created = Favorite.objects.get_or_create(
            user=request.user, product_id=product_id
        )
        if not created:
            fav.delete()
            return Response({'status': 'removed'})
        return Response({'status': 'added'})

class BannerViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Banner.objects.filter(is_active=True)
    serializer_class = BannerSerializer
