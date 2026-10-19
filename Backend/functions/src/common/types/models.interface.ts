export interface LocalizedMap {
  vi: string;
  en: string;
  ko: string;
  zh: string;
}

export interface UserProfile {
  uid: string;
  email: string;
  fullName: string;
  role: 'TOURIST' | 'TOURISM_MANAGER' | 'ADMIN';
  loyaltyPoints: number;
  favoriteDestinationIds: string[];
  isActive: boolean;
  createdAt: FirebaseFirestore.Timestamp;
}

export interface Destination {
  id: string;
  name: LocalizedMap;
  category: 'mountain' | 'cave' | 'pagoda' | 'craft_village' | 'beach' | 'zone';
  zone?: 'an_thuong' | 'beach' | 'craft_village' | 'mountain';
  overview: LocalizedMap;
  culturalHistoricalInfo: LocalizedMap;
  beachSafetyInfo?: LocalizedMap;
  location: {
    geopoint: FirebaseFirestore.GeoPoint;
    geohash: string;
    address: string;
  };
  images: string[];
  hasVr360: boolean;
  hasAudioGuide: boolean;
  ratingAvg: number;
  reviewCount: number;
  isPublished: boolean;
  embedding?: number[];
}

export interface Booking {
  id: string;
  userId: string;
  serviceId: string;
  serviceType: 'event' | 'workshop' | 'craft_experience';
  eventTitle: string;
  scheduledTime: FirebaseFirestore.Timestamp;
  participantsCount: number;
  status: 'PENDING' | 'CONFIRMED' | 'CANCELLED';
  createdAt: FirebaseFirestore.Timestamp;
}

export interface CheckinRecord {
  id: string;
  userId: string;
  pointId: string;
  pointName: string;
  pointsEarned: number;
  userLocation: FirebaseFirestore.GeoPoint;
  timestamp: FirebaseFirestore.Timestamp;
}

export interface LoyaltyReward {
  id: string;
  title: LocalizedMap;
  description: LocalizedMap;
  pointsRequired: number;
  stockQuantity: number;
  isAvailable: boolean;
}
