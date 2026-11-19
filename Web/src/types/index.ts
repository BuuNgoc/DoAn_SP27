export interface Destination {
  id: string;
  name: string;
  nameEn: string;
  category: 'Heritage' | 'Beach' | 'Craft Village' | 'Food' | 'Event' | 'Workshop' | 'Hotel';
  address: string;
  lat: number;
  lng: number;
  shortDescription: string;
  deepDescription: string;
  culturalStory: string;
  coverUrl: string;
  galleryUrls: string[];
  vr360Url: string;
  audioGuideUrl: string;
  videoUrl: string;
  openingHours: string;
  ticketPrice: string;
  targetAudience: string;
  suggestedDuration: number;
  tourRoute: string;
  hashtags: string[];
  rating: number;
  isPublished: boolean;
  completenessScore: number;
}

export interface VrHotspot {
  id: string;
  title: string;
  yaw: number;
  pitch: number;
  description: string;
  type: 'INFO' | 'AUDIO' | 'VIDEO' | 'SCENE_TRANSITION';
  audioUrl: string;
  videoUrl: string;
  nextSceneTitle: string;
}

export interface VrScene {
  id: string;
  title: string;
  zone: string;
  imageUrl: string;
  resolution: string;
  fileSize: string;
  hotspots: VrHotspot[];
}

export interface VendorSubmission {
  id: string;
  businessName: string;
  ownerName: string;
  category: 'Food' | 'Cafe' | 'Nightlife' | 'Performance';
  street: string;
  openingHours: string;
  phone: string;
  description: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  submittedDate: string;
}

export interface BeachSafety {
  beachId: string;
  beachName: string;
  flagColor: 'GREEN' | 'YELLOW' | 'RED';
  waveHeight: string;
  windSpeed: string;
  lifeguardStatus: string;
  ripCurrentWarning: boolean;
  noticeMessage: string;
  updatedAt: string;
}

export interface ContestEntry {
  id: string;
  title: string;
  artisanName: string;
  workshopName: string;
  stoneType: string;
  carvingTechnique: string;
  photoUrl: string;
  story: string;
  votes: number;
  shares: number;
  status: 'PENDING' | 'APPROVED' | 'AWARDED';
}

export interface WorkshopBooking {
  ticketCode: string;
  touristName: string;
  phone: string;
  workshopTitle: string;
  sessionTime: string;
  participants: number;
  status: 'CONFIRMED' | 'CHECKED_IN';
  certificateCode: string;
}

export interface QrCampaign {
  id: string;
  name: string;
  channelLocation: string;
  targetLanding: string;
  scans: number;
  checkins: number;
  shares: number;
  conversionRate: number;
  status: 'ACTIVE' | 'PAUSED';
}

export interface UserAccount {
  uid: string;
  name: string;
  email: string;
  role: 'ADMIN' | 'TOURISM_MANAGER' | 'TOURIST';
  department: string;
  isActive: boolean;
  lastLogin: string;
}

export interface AuditLog {
  id: string;
  action: string;
  module: string;
  user: string;
  ipAddress: string;
  timestamp: string;
  status: 'SUCCESS' | 'WARNING' | 'FAILED';
}
