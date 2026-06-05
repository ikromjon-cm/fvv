from django.db import models
from django.conf import settings

class Lead(models.Model):
    full_name = models.CharField(max_length=200)
    phone = models.CharField(max_length=20)
    source = models.CharField(max_length=100, blank=True, default='')
    notes = models.TextField(blank=True, default='')
    is_converted = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Lead'
        verbose_name_plural = 'Leadlar'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.full_name} - {self.phone}"

class CallRecord(models.Model):
    lead = models.ForeignKey(Lead, on_delete=models.CASCADE, related_name='calls', null=True, blank=True)
    manager = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    duration = models.IntegerField(default=0)
    notes = models.TextField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "Qo'ng'iroq"
        verbose_name_plural = "Qo'ng'iroqlar"
        ordering = ['-created_at']

    def __str__(self):
        return f"Qo'ng'iroq #{self.id}"
