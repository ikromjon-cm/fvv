'use client'

import { useState } from 'react'
import { Send, ArrowLeft, Circle } from 'lucide-react'
import { Navbar } from '@/components/navbar'
import { Footer } from '@/components/footer'
import { MobileBottomNav } from '@/components/mobile-bottom-nav'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { cn } from '@/lib/utils'
import { useConversations, useMessages } from '@/lib/api-hooks'
import { useAuth } from '@/lib/auth'
import type { Conversation } from '@/types'

export default function MessagesPage() {
  const { user } = useAuth()
  const { conversations, loading: convLoading } = useConversations()
  const [selectedConvId, setSelectedConvId] = useState<number | null>(null)
  const { messages, loading: msgLoading, sendMessage } = useMessages(selectedConvId)
  const [messageText, setMessageText] = useState('')

  const selectedConv = conversations.find((c) => c.id === selectedConvId)

  const handleSend = async () => {
    if (!messageText.trim() || !selectedConvId) return
    await sendMessage(messageText.trim())
    setMessageText('')
  }

  const formatTime = (dateStr: string) => {
    const d = new Date(dateStr)
    const now = new Date()
    const isToday = d.toDateString() === now.toDateString()
    if (isToday) return d.toLocaleTimeString('uz-UZ', { hour: '2-digit', minute: '2-digit' })
    return d.toLocaleDateString('uz-UZ', { day: 'numeric', month: 'short' })
  }

  const otherParticipant = (conv: Conversation) =>
    conv.participants.find((p) => p.id !== user?.id) || conv.participants[0]

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Navbar />
      <main className="flex-1 pb-20 lg:pb-0">
        <div className="mx-auto max-w-5xl h-[calc(100vh-8rem)]">
          <div className="flex h-full bg-white border border-gray-100 rounded-2xl overflow-hidden shadow-sm">
            {/* Conversation list */}
            <div
              className={cn(
                'w-full lg:w-80 border-r border-gray-100 flex flex-col',
                selectedConvId && 'hidden lg:flex',
              )}
            >
              <div className="p-4 border-b border-gray-100">
                <h2 className="text-lg font-bold text-gray-900">Xabarlar</h2>
              </div>
              <div className="flex-1 overflow-y-auto">
                {convLoading ? (
                  <div className="p-8 text-center text-sm text-gray-400">Yuklanmoqda...</div>
                ) : conversations.length === 0 ? (
                  <div className="p-8 text-center text-sm text-gray-400">Xabarlar mavjud emas</div>
                ) : (
                  conversations.map((conv) => {
                    const other = otherParticipant(conv)
                    return (
                      <button
                        key={conv.id}
                        onClick={() => setSelectedConvId(conv.id)}
                        className={cn(
                          'w-full flex items-center gap-3 p-4 text-left transition-colors hover:bg-gray-50 border-b border-gray-50',
                          selectedConvId === conv.id && 'bg-primary/5',
                        )}
                      >
                        <div className="relative shrink-0">
                          <Avatar>
                            <AvatarImage src={other.avatar} />
                            <AvatarFallback className="bg-primary/10 text-primary">
                              {other.full_name.charAt(0)}
                            </AvatarFallback>
                          </Avatar>
                          {conv.unread_count > 0 && (
                            <span className="absolute -top-0.5 -right-0.5 h-4 w-4 rounded-full bg-primary text-[9px] font-bold text-primary-foreground flex items-center justify-center">
                              {conv.unread_count}
                            </span>
                          )}
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between gap-2">
                            <span className="text-sm font-semibold text-gray-900 truncate">
                              {other.full_name}
                            </span>
                            {conv.last_message && (
                              <span className="shrink-0 text-[11px] text-gray-400">
                                {formatTime(conv.last_message.created_at)}
                              </span>
                            )}
                          </div>
                          <p className="text-xs text-gray-500 truncate mt-0.5">
                            {conv.last_message?.text || 'Xabar yo\'q'}
                          </p>
                        </div>
                      </button>
                    )
                  })
                )}
              </div>
            </div>

            {/* Chat area */}
            <div
              className={cn(
                'flex-1 flex flex-col',
                !selectedConvId && 'hidden lg:flex',
              )}
            >
              {selectedConv ? (
                <>
                  {/* Chat header */}
                  <div className="flex items-center gap-3 p-4 border-b border-gray-100">
                    <button
                      className="lg:hidden p-1 -ml-1 rounded-lg hover:bg-gray-100"
                      onClick={() => setSelectedConvId(null)}
                    >
                      <ArrowLeft className="h-5 w-5 text-gray-600" />
                    </button>
                    <Avatar className="h-8 w-8">
                      <AvatarImage src={otherParticipant(selectedConv).avatar} />
                      <AvatarFallback className="bg-primary/10 text-primary text-xs">
                        {otherParticipant(selectedConv).full_name.charAt(0)}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <p className="text-sm font-semibold text-gray-900">
                        {otherParticipant(selectedConv).full_name}
                      </p>
                      <p className="text-[11px] text-gray-400">
                        {otherParticipant(selectedConv).role === 'seller' ? 'Sotuvchi' : 'Xaridor'}
                      </p>
                    </div>
                  </div>

                  {/* Messages */}
                  <div className="flex-1 overflow-y-auto p-4 space-y-3">
                    {msgLoading ? (
                      <div className="text-center text-sm text-gray-400 py-8">Yuklanmoqda...</div>
                    ) : messages.length === 0 ? (
                      <div className="text-center text-sm text-gray-400 py-8">Xabarlar yo'q</div>
                    ) : (
                      messages.map((msg) => {
                        const isMine = msg.sender.id === user?.id
                        return (
                          <div
                            key={msg.id}
                            className={cn('flex', isMine ? 'justify-end' : 'justify-start')}
                          >
                            <div
                              className={cn(
                                'max-w-[75%] px-4 py-2.5 rounded-2xl text-sm leading-relaxed',
                                isMine
                                  ? 'bg-primary text-primary-foreground rounded-br-md'
                                  : 'bg-gray-100 text-gray-900 rounded-bl-md',
                              )}
                            >
                              <p>{msg.text}</p>
                              <p
                                className={cn(
                                  'text-[10px] mt-1 text-right',
                                  isMine ? 'text-primary-foreground/70' : 'text-gray-400',
                                )}
                              >
                                {formatTime(msg.created_at)}
                              </p>
                            </div>
                          </div>
                        )
                      })
                    )}
                  </div>

                  {/* Input */}
                  <div className="p-4 border-t border-gray-100">
                    <div className="flex gap-2">
                      <Input
                        value={messageText}
                        onChange={(e) => setMessageText(e.target.value)}
                        placeholder="Xabar yozish..."
                        className="flex-1"
                        onKeyDown={(e) => {
                          if (e.key === 'Enter' && !e.shiftKey) {
                            e.preventDefault()
                            handleSend()
                          }
                        }}
                      />
                      <Button size="icon" onClick={handleSend} disabled={!messageText.trim()}>
                        <Send className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                </>
              ) : (
                <div className="flex-1 flex items-center justify-center">
                  <div className="text-center p-8">
                    <div className="h-16 w-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
                      <Send className="h-6 w-6 text-primary" />
                    </div>
                    <h3 className="text-lg font-semibold text-gray-900 mb-1">Xabarlar</h3>
                    <p className="text-sm text-gray-500">Suhbatni boshlash uchun suhbatni tanlang</p>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
      <Footer />
      <MobileBottomNav />
    </div>
  )
}
