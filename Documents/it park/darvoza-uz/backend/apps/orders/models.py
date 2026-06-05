from django.db import models
from django.conf import settings

class Order(models.Model):
    class Status(models.TextChoices):
        NEW = 'new', 'Yangi'
        CONTACTED = 'contacted', 'Aloqaga chiqildi'
        MEASURED = 'measured', "O'lchov olindi"
        OFFERED = 'offered', 'Taklif yuborildi'
        AGREED = 'agreed', 'Kelishildi'
        PRODUCING = 'producing', 'Ishlab chiqarishda'
        INSTALLING = 'installing', 'O‘rnatilmoqda'
        COMPLETED = 'completed', 'Yakunlandi'
        CANCELLED = 'cancelled', 'Bekor qilindi'

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='orders')
    seller = models.ForeignKey('marketplace.Seller', on_delete=models.CASCADE, related_name='orders')
    product = models.ForeignKey('marketplace.Product', on_delete=models.SET_NULL, null=True, blank=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.NEW)
    total = models.BigIntegerField(default=0)
    description = models.TextField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Buyurtma'
        verbose_name_plural = 'Buyurtmalar'
        ordering = ['-created_at']

    def __str__(self):
        return f"#{self.id} - {self.user.username}"
