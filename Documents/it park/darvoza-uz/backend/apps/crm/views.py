from rest_framework import viewsets, permissions
from .models import Lead, CallRecord
from .serializers import LeadSerializer, CallRecordSerializer

class LeadViewSet(viewsets.ModelViewSet):
    queryset = Lead.objects.all()
    serializer_class = LeadSerializer
    permission_classes = [permissions.IsAuthenticated]

class CallRecordViewSet(viewsets.ModelViewSet):
    queryset = CallRecord.objects.all()
    serializer_class = CallRecordSerializer
    permission_classes = [permissions.IsAuthenticated]
