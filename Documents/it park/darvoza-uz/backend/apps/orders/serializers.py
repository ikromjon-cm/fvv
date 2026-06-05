from rest_framework import serializers
from .models import Order
from apps.accounts.serializers import UserSerializer
from apps.marketplace.serializers import ProductSerializer, SellerListSerializer


class OrderSerializer(serializers.ModelSerializer):
    buyer = UserSerializer(source='user', read_only=True)
    product = ProductSerializer(read_only=True)
    seller = SellerListSerializer(read_only=True)
    total_price = serializers.IntegerField(source='total', read_only=True)
    quantity = serializers.SerializerMethodField()
    delivery_address = serializers.CharField(source='description', read_only=True)
    delivery_date = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = ('id', 'buyer', 'seller', 'product', 'quantity', 'total_price', 'status', 'delivery_address', 'delivery_date', 'created_at')
        read_only_fields = ('id', 'created_at')

    def get_quantity(self, obj):
        return 1

    def get_delivery_date(self, obj):
        return None
