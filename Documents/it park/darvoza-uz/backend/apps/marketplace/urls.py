from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('categories', views.CategoryViewSet)
router.register('gate-types', views.GateTypeViewSet)
router.register('sellers', views.SellerViewSet)
router.register('products', views.ProductViewSet)
router.register('favorites', views.FavoriteViewSet, basename='favorites')
router.register('banners', views.BannerViewSet)

urlpatterns = router.urls
