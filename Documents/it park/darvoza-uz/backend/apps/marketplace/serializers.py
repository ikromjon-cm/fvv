from rest_framework import serializers
from .models import Category, GateType, Seller, Product, Review, Favorite, Banner
from apps.accounts.serializers import UserSerializer

class CategorySerializer(serializers.ModelSerializer):
    icon = serializers.SerializerMethodField()
    children = serializers.SerializerMethodField()

    class Meta:
        model = Category
        fields = ('id', 'name', 'slug', 'icon', 'image', 'parent', 'children', 'order')

    def get_icon(self, obj):
        return None

    def get_children(self, obj):
        children = obj.children.all()
        if children:
            return CategorySerializer(children, many=True).data
        return []

class GateTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = GateType
        fields = '__all__'

class ReviewSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = Review
        fields = ('id', 'user', 'product', 'seller', 'name', 'text', 'rating', 'created_at')
        read_only_fields = ('id', 'created_at')

class SellerListSerializer(serializers.ModelSerializer):
    gate_types = GateTypeSerializer(many=True, read_only=True)
    distance = serializers.FloatField(read_only=True, required=False)
    review_count = serializers.SerializerMethodField()
    is_official = serializers.BooleanField(source='is_verified', read_only=True)
    lat = serializers.FloatField(source='latitude', read_only=True)
    lng = serializers.FloatField(source='longitude', read_only=True)
    logo = serializers.SerializerMethodField()
    cover = serializers.SerializerMethodField()
    description = serializers.CharField(source='address', read_only=True, default='')
    working_hours = serializers.SerializerMethodField()
    user_obj = serializers.SerializerMethodField(source='user')

    class Meta:
        model = Seller
        fields = ('id', 'user_obj', 'company_name', 'description', 'logo', 'cover', 'rating', 'review_count', 'is_official', 'lat', 'lng', 'address', 'working_hours', 'phone', 'created_at', 'distance', 'user', 'gate_types')

    def get_review_count(self, obj):
        return obj.reviews.count()

    def get_logo(self, obj):
        if obj.user and obj.user.avatar:
            try:
                return obj.user.avatar.url
            except:
                return None
        return None

    def get_cover(self, obj):
        return None

    def get_working_hours(self, obj):
        return None

    def get_user_obj(self, obj):
        if not obj.user:
            return None
        return UserSerializer(obj.user).data

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['user'] = data.pop('user_obj', None)
        data.pop('user_obj', None)
        return data

class SellerDetailSerializer(SellerListSerializer):
    reviews = ReviewSerializer(many=True, read_only=True)
    product_count = serializers.SerializerMethodField()

    class Meta(SellerListSerializer.Meta):
        fields = SellerListSerializer.Meta.fields + ('reviews', 'product_count', 'owner_name', 'telegram', 'district', 'neighborhood', 'badge')

    def get_product_count(self, obj):
        return obj.products.count()

class ProductSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    gate_type = GateTypeSerializer(read_only=True)
    seller = SellerListSerializer(read_only=True)
    slug = serializers.SerializerMethodField()
    discount_percent = serializers.SerializerMethodField()
    final_price = serializers.SerializerMethodField()
    currency = serializers.SerializerMethodField()
    in_stock = serializers.BooleanField(source='is_active', read_only=True)
    view_count = serializers.SerializerMethodField()
    average_rating = serializers.FloatField(source='rating', read_only=True)
    review_count = serializers.SerializerMethodField()
    is_favorited = serializers.SerializerMethodField()
    panorama = serializers.URLField(source='view_360', read_only=True, default='')

    class Meta:
        model = Product
        fields = ('id', 'category', 'gate_type', 'seller', 'title', 'slug', 'description', 'price', 'discount_percent', 'final_price', 'currency', 'images', 'video', 'panorama', 'width', 'height', 'material', 'color', 'is_promoted', 'in_stock', 'view_count', 'average_rating', 'review_count', 'is_favorited', 'has_delivery', 'has_installation', 'warranty', 'created_at')
        read_only_fields = ('id', 'created_at', 'rating')

    def get_slug(self, obj):
        from django.utils.text import slugify
        return slugify(obj.title) or f'product-{obj.id}'

    def get_discount_percent(self, obj):
        if obj.discount_price and obj.price > 0:
            return int((1 - obj.discount_price / obj.price) * 100)
        return 0

    def get_final_price(self, obj):
        return obj.discount_price or obj.price

    def get_currency(self, obj):
        return 'UZS'

    def get_view_count(self, obj):
        return getattr(obj, 'view_count', 0)

    def get_review_count(self, obj):
        return obj.reviews.count()

    def get_is_favorited(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return Favorite.objects.filter(user=request.user, product=obj).exists()
        return False

class FavoriteSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)

    class Meta:
        model = Favorite
        fields = '__all__'
        read_only_fields = ('id', 'created_at', 'user')

class BannerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Banner
        fields = ('id', 'title', 'subtitle', 'image', 'link', 'is_active', 'order')
