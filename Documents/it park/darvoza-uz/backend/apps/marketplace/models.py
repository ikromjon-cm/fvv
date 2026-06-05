from django.db import models
from django.conf import settings

class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    image = models.ImageField(upload_to='categories/', blank=True, null=True)
    parent = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='children')
    order = models.IntegerField(default=0)

    class Meta:
        verbose_name = 'Kategoriya'
        verbose_name_plural = 'Kategoriyalar'
        ordering = ['order', 'name']

    def __str__(self):
        return self.name

class GateType(models.Model):
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    description = models.TextField(blank=True, default='')

    class Meta:
        verbose_name = 'Darvoza turi'
        verbose_name_plural = 'Darvoza turlari'

    def __str__(self):
        return self.name

class Seller(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, null=True, blank=True, related_name='seller_profile')
    company_name = models.CharField(max_length=200)
    owner_name = models.CharField(max_length=200)
    phone = models.CharField(max_length=20)
    telegram = models.CharField(max_length=100, blank=True, default='')
    city = models.CharField(max_length=100)
    district = models.CharField(max_length=100, blank=True, default='')
    neighborhood = models.CharField(max_length=200, blank=True, default='')
    address = models.TextField(blank=True, default='')
    latitude = models.FloatField()
    longitude = models.FloatField()
    rating = models.FloatField(default=0)
    badge = models.CharField(max_length=100, blank=True, default='')
    gate_types = models.ManyToManyField(GateType, blank=True)
    is_active = models.BooleanField(default=True)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Sotuvchi'
        verbose_name_plural = 'Sotuvchilar'
        ordering = ['-rating']

    def __str__(self):
        return self.company_name

class Product(models.Model):
    seller = models.ForeignKey(Seller, on_delete=models.CASCADE, related_name='products')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, related_name='products')
    gate_type = models.ForeignKey(GateType, on_delete=models.SET_NULL, null=True, blank=True)
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True, default='')
    price = models.BigIntegerField()
    discount_price = models.BigIntegerField(null=True, blank=True)
    material = models.CharField(max_length=100, blank=True, default='')
    color = models.CharField(max_length=50, blank=True, default='')
    width = models.CharField(max_length=50, blank=True, default='')
    height = models.CharField(max_length=50, blank=True, default='')
    has_delivery = models.BooleanField(default=False)
    has_installation = models.BooleanField(default=False)
    warranty = models.CharField(max_length=100, blank=True, default='')
    rating = models.FloatField(default=0)
    is_promoted = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    images = models.JSONField(default=list)
    video = models.URLField(blank=True, default='')
    view_360 = models.URLField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Mahsulot'
        verbose_name_plural = 'Mahsulotlar'
        ordering = ['-created_at']

    def __str__(self):
        return self.title

class Review(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='reviews', null=True, blank=True)
    seller = models.ForeignKey(Seller, on_delete=models.CASCADE, related_name='reviews', null=True, blank=True)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    name = models.CharField(max_length=100)
    text = models.TextField()
    rating = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Sharh'
        verbose_name_plural = 'Sharhlar'

    def __str__(self):
        return f'{self.name} - {self.rating}'

class Favorite(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='favorites')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='favorited_by')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ['user', 'product']
        verbose_name = 'Sevimli'
        verbose_name_plural = 'Sevimlilar'

class Banner(models.Model):
    title = models.CharField(max_length=200)
    subtitle = models.CharField(max_length=500, blank=True, default='')
    image = models.URLField(max_length=500, blank=True, default='')
    link = models.CharField(max_length=500, blank=True, default='')
    is_active = models.BooleanField(default=True)
    order = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Banner'
        verbose_name_plural = 'Bannerlar'
        ordering = ['order']
