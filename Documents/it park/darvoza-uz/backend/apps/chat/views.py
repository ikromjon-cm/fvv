from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Conversation, Message
from .serializers import ConversationSerializer, MessageSerializer

class ConversationViewSet(viewsets.ModelViewSet):
    serializer_class = ConversationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Conversation.objects.filter(participants=self.request.user)

    def perform_create(self, serializer):
        conv = serializer.save()
        conv.participants.add(self.request.user)
        participant_id = self.request.data.get('participant_id')
        if participant_id:
            from django.contrib.auth import get_user_model
            try:
                other = get_user_model().objects.get(id=participant_id)
                conv.participants.add(other)
            except get_user_model().DoesNotExist:
                pass

    @action(detail=True, methods=['post'])
    def send(self, request, pk=None):
        conv = self.get_object()
        text = request.data.get('text', '')
        if not text:
            return Response({'error': 'text required'}, status=400)
        msg = Message.objects.create(conversation=conv, sender=request.user, text=text)
        serializer = MessageSerializer(msg)
        return Response(serializer.data, status=201)

    @action(detail=True, methods=['get'])
    def messages(self, request, pk=None):
        conv = self.get_object()
        msgs = conv.messages.all()
        page = self.paginate_queryset(msgs)
        if page:
            serializer = MessageSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = MessageSerializer(msgs, many=True)
        return Response(serializer.data)
