from rest_framework import serializers
from .models import Lead, CallRecord

class LeadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lead
        fields = '__all__'
        read_only_fields = ('id', 'created_at')

class CallRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = CallRecord
        fields = '__all__'
        read_only_fields = ('id', 'created_at')
