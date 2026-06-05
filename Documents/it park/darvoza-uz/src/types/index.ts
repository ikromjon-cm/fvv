export type UserRole = 'buyer' | 'seller' | 'master' | 'admin'

export interface User {
  id: number
  phone: string
  full_name: string
  role: UserRole
  avatar?: string
  is_verified: boolean
}

export interface Category {
  id: number
  name: string
  slug: string
  icon?: string
  image?: string
  parent?: number
  children?: Category[]
}

export interface GateType {
  id: number
  name: string
  slug: string
}

export interface Seller {
  id: number
  user: User
  company_name: string
  description: string
  logo?: string
  cover?: string
  rating: number
  review_count: number
  is_official: boolean
  lat?: number
  lng?: number
  address?: string
  working_hours?: string
  phone?: string
  created_at: string
}

export interface ProductImage {
  id: number
  image: string
  is_primary: boolean
}

export interface Product {
  id: number
  category: Category
  gate_type: GateType
  seller: Seller
  title: string
  slug: string
  description: string
  price: number
  discount_percent: number
  final_price: number
  currency: string
  images: ProductImage[]
  video?: string
  panorama?: string
  width: number
  height: number
  material: string
  color: string
  is_promoted: boolean
  in_stock: boolean
  view_count: number
  average_rating: number
  review_count: number
  is_favorited?: boolean
  created_at: string
}

export interface Review {
  id: number
  user: User
  product: number
  rating: number
  comment: string
  created_at: string
}

export type OrderStatus =
  | 'new'
  | 'contacted'
  | 'measured'
  | 'offered'
  | 'agreed'
  | 'producing'
  | 'installing'
  | 'completed'
  | 'cancelled'

export interface Order {
  id: number
  buyer: User
  seller: Seller
  product: Product
  quantity: number
  total_price: number
  status: OrderStatus
  delivery_address: string
  delivery_date?: string
  created_at: string
}

export interface Conversation {
  id: number
  participants: User[]
  last_message?: Message
  unread_count: number
  created_at: string
}

export interface Message {
  id: number
  conversation: number
  sender: User
  text: string
  is_read: boolean
  created_at: string
}

export interface Banner {
  id: number
  title: string
  subtitle?: string
  image: string
  link?: string
  is_active: boolean
  order: number
}

export interface PaginatedResponse<T> {
  count: number
  next: string | null
  previous: string | null
  results: T[]
}

export interface NearbySeller {
  id: number
  company_name: string
  lat: number
  lng: number
  distance_km: number
  rating: number
  product_count: number
}
