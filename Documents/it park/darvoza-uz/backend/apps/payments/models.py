from django.db import models
from django.conf import settings

class Payment(models.Model):
    class Method(models.TextChoices):
        CLICK = 'click', 'Click'
        PAYME = 'payme', 'Payme'
        UZUM_BANK = 'uzum_bank', 'Uzum Bank'
        UZCARD = 'uzcard', 'Uzcard'
        HUMO = 'humo', 'Humo'
        CASH = 'cash', 'Naqd'

    class Status(models.TextChoices):
        PENDING = 'pending', 'Kutilmoqda'
        SUCCESS = 'success', "To'landi"
        FAILED = 'failed', 'Xatolik'
        CANCELLED = 'cancelled', 'Bekor qilindi'

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='payments')
    order = models.ForeignKey('orders.Order', on_delete=models.SET_NULL, null=True, blank=True, related_name='payments')
    amount = models.BigIntegerField()
    method = models.CharField(max_length=20, choices=Method.choices)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    transaction_id = models.CharField(max_length=200, blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "To'lov"
        verbose_name_plural = "To'lovlar"
        ordering = ['-created_at']

    def __str__(self):
        return f"#{self.id} - {self.amount} so'm"
