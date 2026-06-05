from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('leads', views.LeadViewSet, basename='leads')
router.register('calls', views.CallRecordViewSet, basename='calls')

urlpatterns = [
    path('', include(router.urls)),
]
