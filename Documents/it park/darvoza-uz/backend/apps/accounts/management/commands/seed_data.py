from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.marketplace.models import Category, GateType, Seller, Product, Banner

User = get_user_model()

class Command(BaseCommand):
    help = 'Maʼlumotlar bazasini boshlangʻich maʼlumotlar bilan toʻldirish'

    def handle(self, *args, **options):
        self._create_users()
        self._create_categories()
        self._create_gate_types()
        self._create_sellers()
        self._create_products()
        self._create_banners()
        self.stdout.write(self.style.SUCCESS('Barcha maʼlumotlar muvaffaqiyatli yuklandi!'))

    def _create_users(self):
        if User.objects.exists():
            self.stdout.write('Foydalanuvchilar allaqachon mavjud, oʻtkazib yuborilmoqda')
            return
        User.objects.create_superuser(phone='998901234567', password='admin123', role='admin', first_name='Admin')
        User.objects.create_user(phone='998901234568', password='buyer123', role='buyer', first_name='Ali')
        User.objects.create_user(phone='998901234569', password='seller123', role='seller', first_name='Bobur')
        User.objects.create_user(phone='998901234570', password='master123', role='master', first_name='Dilmurod')
        self.stdout.write('Foydalanuvchilar yaratildi')

    def _create_categories(self):
        if Category.objects.exists():
            return
        parent = Category.objects.create(name='Temir darvozalar', slug='temir-darvozalar', order=1)
        Category.objects.create(name='Panel eshiklar', slug='panel-eshiklar', parent=parent, order=2)
        Category.objects.create(name='Panjaralar', slug='panjaralar', order=3)
        Category.objects.create(name='Avtomatik eshiklar', slug='avtomatik-eshiklar', order=4)
        Category.objects.create(name='Kotta darvozalar', slug='kotta-darvozalar', order=5)
        Category.objects.create(name='Devor bloklari', slug='devor-bloklari', order=6)
        self.stdout.write('Kategoriyalar yaratildi')

    def _create_gate_types(self):
        if GateType.objects.exists():
            return
        types = [
            ('Ochiladigan', 'ochiladigan'),
            ('Suriladigan', 'suriladigan'),
            ('Bukiladigan', 'bukiladigan'),
            ('Avtomatik', 'avtomatik'),
            ('Garaj', 'garaj'),
        ]
        for name, slug in types:
            GateType.objects.create(name=name, slug=slug)
        self.stdout.write('Darvoza turlari yaratildi')

    def _create_sellers(self):
        if Seller.objects.exists():
            return
        users = list(User.objects.filter(role='seller'))
        sellers_data = [
            {'company_name': 'Temur Darvozalar', 'owner_name': 'Temur', 'phone': '998901234571', 'city': 'Toshkent', 'latitude': 41.3111, 'longitude': 69.2797, 'rating': 4.8},
            {'company_name': 'Botir Eshiklar', 'owner_name': 'Botir', 'phone': '998901234572', 'city': 'Toshkent', 'latitude': 41.3275, 'longitude': 69.2640, 'rating': 4.5},
            {'company_name': 'Jasur Panjaralar', 'owner_name': 'Jasur', 'phone': '998901234573', 'city': 'Toshkent', 'latitude': 41.2950, 'longitude': 69.3010, 'rating': 4.2},
        ]
        for i, data in enumerate(sellers_data):
            if not data.get('latitude'):
                data['latitude'] = 41.3
            if not data.get('longitude'):
                data['longitude'] = 69.3
            user = users[i] if i < len(users) else None
            Seller.objects.create(user=user, **data)
        self.stdout.write('Sotuvchilar yaratildi')

    def _create_products(self):
        if Product.objects.exists():
            return
        seller = Seller.objects.first()
        category = Category.objects.first()
        gate_type = GateType.objects.first()
        if not all([seller, category, gate_type]):
            self.stdout.write(self.style.WARNING('Sotuvchi, kategoriya yoki tur topilmadi'))
            return
        products = [
            {'title': 'Temir darvoza klassik', 'price': 5000000, 'discount_price': 4500000, 'has_delivery': True, 'has_installation': True, 'material': 'Metall', 'color': 'Qora', 'width': '300', 'height': '250', 'images': [{'id': 1, 'image': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop', 'is_primary': True}]},
            {'title': 'Panel eshik zamonaviy', 'price': 3500000, 'has_delivery': True, 'material': 'Metall', 'color': 'Oq', 'width': '200', 'height': '80', 'images': [{'id': 2, 'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&h=400&fit=crop', 'is_primary': True}]},
            {'title': 'Avtomatik suriladigan darvoza', 'price': 12000000, 'discount_price': 11000000, 'is_promoted': True, 'has_installation': True, 'material': 'Metall', 'color': 'Kumush', 'width': '400', 'height': '200', 'images': [{'id': 3, 'image': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&h=400&fit=crop', 'is_primary': True}]},
            {'title': 'Garaj eshigi izolyatsiyali', 'price': 7000000, 'has_delivery': True, 'has_installation': True, 'material': 'Metall', 'color': 'Jigarrang', 'width': '250', 'height': '220', 'images': [{'id': 4, 'image': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=600&h=400&fit=crop', 'is_primary': True}]},
            {'title': 'Dekorativ panjara', 'price': 2000000, 'material': 'Metall', 'color': 'Oq', 'width': '150', 'height': '150', 'images': [{'id': 5, 'image': 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=600&h=400&fit=crop', 'is_primary': True}]},
        ]
        for data in products:
            Product.objects.create(
                seller=seller, category=category, gate_type=gate_type,
                **data
            )
        self.stdout.write('Mahsulotlar yaratildi')

    def _create_banners(self):
        if Banner.objects.exists():
            return
        Banner.objects.create(title='Sifatli darvozalar', subtitle="10% gacha chegirma", image='https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=1200&h=500&fit=crop', link='/marketplace', order=1)
        Banner.objects.create(title="O'rnatish xizmati bilan", subtitle='Bepul o\'rnatish', image='https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1200&h=500&fit=crop', link='/marketplace', order=2)
        Banner.objects.create(title='Eng yaxshi narxlar', subtitle='Narxlarni solishtiring', image='https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=1200&h=500&fit=crop', link='/marketplace', order=3)
        self.stdout.write('Bannerlar yaratildi')
