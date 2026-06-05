import { useState, useEffect, useCallback } from 'react'
import { api } from './api'
import type {
  Banner, Category, Product, Seller, Review, User,
  PaginatedResponse, Order, Conversation, Message, NearbySeller
} from '@/types'

function useFetch<T>(url: string | null, params?: Record<string, string | number | boolean | undefined>) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetch = useCallback(async () => {
    if (!url) return
    setLoading(true)
    setError(null)
    try {
      const result = await api.get<T>(url, params)
      setData(result)
    } catch (e: any) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }, [url, JSON.stringify(params)])

  useEffect(() => { fetch() }, [fetch])

  return { data, loading, error, refetch: fetch }
}

export function useBanners() {
  return useFetch<Banner[]>('/banners/')
}

export function useCategories() {
  return useFetch<Category[]>('/categories/')
}

export function useProducts(params?: Record<string, string | number | boolean | undefined>) {
  const [products, setProducts] = useState<Product[]>([])
  const [count, setCount] = useState(0)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetch = useCallback(async (page?: number) => {
    setLoading(true)
    setError(null)
    try {
      const result = await api.get<PaginatedResponse<Product>>('/products/', { ...params, page: page ?? 1 })
      if (page && page > 1) {
        setProducts(prev => [...prev, ...result.results])
      } else {
        setProducts(result.results)
      }
      setCount(result.count)
    } catch (e: any) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }, [JSON.stringify(params)])

  useEffect(() => { fetch(1) }, [fetch])

  return { products, count, loading, error, loadMore: (page: number) => fetch(page), refetch: () => fetch(1) }
}

export function useProduct(id: string) {
  return useFetch<Product>(`/products/${id}/`)
}

export function useProductReviews(id: string) {
  return useFetch<Review[]>(`/products/${id}/reviews/`)
}

export function useSellers(params?: Record<string, string | number | boolean | undefined>) {
  return useFetch<PaginatedResponse<Seller>>('/sellers/', params)
}

export function useNearbySellers(lat: number, lng: number) {
  return useFetch<PaginatedResponse<NearbySeller>>('/sellers/nearby/', { lat, lng })
}

export function useFavorites() {
  const [favorites, setFavorites] = useState<Product[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetch = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const result = await api.get<PaginatedResponse<{ product: Product }>>('/favorites/')
      setFavorites(result.results.map(f => f.product))
    } catch (e: any) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { fetch() }, [fetch])

  return { favorites, loading, error, refetch: fetch }
}

export function useOrders() {
  const [orders, setOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetch = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const result = await api.get<PaginatedResponse<Order>>('/orders/')
      setOrders(result.results)
    } catch (e: any) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { fetch() }, [fetch])

  return { orders, loading, error, refetch: fetch }
}

export function useConversations() {
  const [conversations, setConversations] = useState<Conversation[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetch = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const result = await api.get<PaginatedResponse<Conversation>>('/chat/conversations/')
      setConversations(result.results)
    } catch (e: any) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { fetch() }, [fetch])

  return { conversations, loading, error, refetch: fetch }
}

export function useMessages(conversationId: number | null) {
  const [messages, setMessages] = useState<Message[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetch = useCallback(async () => {
    if (!conversationId) return
    setLoading(true)
    setError(null)
    try {
      const result = await api.get<PaginatedResponse<Message>>(`/chat/conversations/${conversationId}/messages/`)
      setMessages(result.results)
    } catch (e: any) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }, [conversationId])

  useEffect(() => { fetch() }, [fetch])

  const sendMessage = useCallback(async (text: string) => {
    if (!conversationId) return
    const msg = await api.post<Message>(`/chat/conversations/${conversationId}/send/`, { text })
    setMessages(prev => [...prev, msg])
  }, [conversationId])

  return { messages, loading, error, sendMessage, refetch: fetch }
}

export function useToggleFavorite() {
  const [loading, setLoading] = useState(false)
  const toggle = useCallback(async (productId: number) => {
    setLoading(true)
    try {
      const result = await api.post<{ status: string }>('/favorites/toggle/', { product: productId })
      return result.status
    } finally {
      setLoading(false)
    }
  }, [])
  return { toggle, loading }
}

export function useSellerProfile() {
  return useFetch<Seller>('/sellers/me/')
}

export function useSellerProducts(sellerId: number | null) {
  return useFetch<PaginatedResponse<Product>>(sellerId ? `/products/?seller=${sellerId}` : null)
}

export function useUsers() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const fetch = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const result = await api.get<PaginatedResponse<User>>('/auth/users/')
      setUsers(result.results)
    } catch (e: any) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => { fetch() }, [fetch])

  return { users, loading, error, refetch: fetch }
}
