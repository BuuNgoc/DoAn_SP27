# DoAn_SP27: SmartTravel – Smart Tourism Platform for Ngu Hanh Son (SE13)

> **AI Agent / Claude Code Instructions**: You are working inside the `DoAn_SP27/` monorepo.
> - All **Flutter Frontend** code resides in `DoAn_SP27/Frontend/`.
> - All **Firebase Backend** (Cloud Functions, Firestore Rules, Storage Rules, Indexes) resides in `DoAn_SP27/Backend/`.
> Read this document carefully before generating or modifying any files.

---

## 1. Project Overview
- **Workspace Root**: `DoAn_SP27/`
- **Project Name**: SmartTravel – Smart Tourism Platform for Ngu Hanh Son
- **Project Code**: `SmartTravel` | **Group**: `SE13` (FPT University Da Nang)
- **Mentor**: Lê Thiện Nhật Quang
- **Team Members**: Nguyễn Ngọc Bữu (Leader), Văn Đức Tài, Vương Mai Ngân, Nguyễn Thị An Thuyên, Trương Đình Nhật
- **Tech Stack**:
  - **Frontend (`DoAn_SP27/Frontend/`)**: Flutter (Dart 3.x), Material 3, Clean Architecture (Feature-First), `flutter_bloc`, `go_router`, `get_it`.
  - **Backend (`DoAn_SP27/Backend/`)**: Firebase Serverless BaaS (Firebase Auth, Cloud Firestore, Cloud Functions in TypeScript, Firebase Storage, FCM, Gemini AI / Vertex AI + Firestore Vector Search for RAG).

---

## 2. System Actors & Role-Based Access Control (RBAC)
1. **`TOURIST` (Mobile App User)**:
   - Uses features `FE-01` to `FE-16`: Authentication, Destination Discovery, VR360 & Audio Guide, Interactive Map, AI Photo Recognition, RAG Itinerary Assistant, Event/Workshop Booking, Stone Carving Contest Voting, QR Check-in, Loyalty Rewards, Reviews, and Social Sharing.
2. **`TOURISM_MANAGER` (Tourism Management Staff)**:
   - Uses features `FE-17` to `FE-25`: Manages Destinations, VR360/Audio Media, Events/Workshops, Check-in QR & Loyalty Rules, Artisans, Stone Carving Contests, An Thượng & Beach Zones, Promotions, and Tourism Analytics.
3. **`ADMIN` (System Administrator)**:
   - Uses features `FE-26` to `FE-28` (plus all Manager permissions): User Account Management, Role & Permission Management (RBAC), System Configuration, Audit Logs, and Data Backups.

---

## 3. Monorepo Directory Structure (`DoAn_SP27/`)

~~~text
DoAn_SP27/
├── CLAUDE.md                                   # AI Context & Architecture Guide (This file)
├── README.md                                   # Project Documentation
├── .gitignore
│
├── Frontend/                                   # FLUTTER APPLICATION (smart_travel_app)
│   ├── pubspec.yaml
│   ├── assets/
│   │   ├── images/
│   │   ├── icons/
│   │   ├── animations/
│   │   └── translations/                       # vi.json, en.json, ko.json, zh.json
│   └── lib/
│       ├── main.dart                           # App entry point, Firebase & GetIt DI initialization
│       ├── app.dart                            # MaterialApp.router, Theme, Localization
│       ├── firebase_options.dart
│       │
│       ├── core/                               # Shared core utilities & services
│       │   ├── constants/                      # app_colors.dart, app_dimensions.dart, firestore_collections.dart
│       │   ├── di/                             # injection_container.dart
│       │   ├── errors/                         # exceptions.dart, failures.dart
│       │   ├── network/                        # network_info.dart
│       │   ├── router/                         # app_router.dart, route_names.dart
│       │   ├── services/                       # firebase_auth, firestore, cloud_functions, storage, fcm, location
│       │   ├── theme/                          # app_theme.dart
│       │   └── utils/                          # date_formatter.dart, distance_calculator.dart, validators.dart
│       │
│       ├── shared/                             # Reusable widgets & common models
│       │   ├── models/                         # geo_location_model.dart, media_item_model.dart
│       │   └── widgets/                        # custom_app_bar.dart, custom_button.dart, cached_image_widget.dart
│       │
│       └── features/                           # FEATURE MODULES (FE-01 -> FE-28)
│           ├── auth/                           # [FE-01] Register, Login, Reset/Change Password, Profile
│           ├── destination_discovery/          # [FE-02] List, Search, Filter, Details, Cultural Info, Favorites
│           ├── vr360_audio_guide/              # [FE-03] 360° Panorama Viewer, Multi-language Audio Player
│           ├── interactive_map/                # [FE-04] Google Maps, POI Markers, Category Filters, Directions
│           ├── ai_travel_assistant/            # [FE-05 & RAG] AI Photo Recognition, RAG Itinerary Planner & Chat
│           ├── events_workshops_craft/         # [FE-06, FE-15, FE-16] Events, Non Nuoc Workshops, Artisans, Stone Contest
│           ├── booking_management/             # [FE-07] Create/Confirm/Cancel Booking, Booking History
│           ├── qr_checkin_loyalty/             # [FE-08, FE-09] QR Scanner, Check-in History, Loyalty Points, Redeem Rewards
│           ├── reviews_social_sharing/         # [FE-10, FE-11] Ratings, Reviews with Photos, Report, Social Share
│           ├── specialized_zones/              # [FE-12, FE-13, FE-14] An Thuong Hub, Beach Tourism & Safety, Airport Promo
│           └── admin_portal/                   # [FE-17 -> FE-28] Content, VR/Audio, Event, Loyalty, Analytics, RBAC, Audit
│
└── Backend/                                    # FIREBASE SERVERLESS BACKEND
    ├── .firebaserc
    ├── firebase.json
    ├── firestore.rules                         # RBAC Security Rules (TOURIST, TOURISM_MANAGER, ADMIN)
    ├── firestore.indexes.json                  # Composite & Vector Indexes
    ├── storage.rules                           # Media Upload/Read Security Rules
    └── functions/                              # Cloud Functions (TypeScript)
        ├── package.json
        ├── tsconfig.json
        └── src/
            ├── index.ts                        # Exports all Callable Functions & Firestore Triggers
            ├── config/                         # firebase.config.ts, gemini_ai.config.ts
            ├── common/                         # role_guard.ts, audit_logger.ts, qr_crypto.ts
            └── modules/
                ├── auth_and_users/             # [FE-01, FE-26, FE-27] User init trigger, Custom Claims role assignment
                ├── ai_and_rag/                 # [FE-05 & RAG] Vector embedding sync, Landmark Vision AI, RAG Itinerary
                ├── booking_and_events/         # [FE-06, FE-07, FE-15, FE-16] Transactional booking, Contest voting
                ├── checkin_and_loyalty/        # [FE-08, FE-09, FE-20] QR signature verification, Point calc, Reward redeem
                ├── reviews_and_moderation/     # [FE-10] Auto rating recalculation trigger, Review reporting
                └── analytics_and_system/       # [FE-25, FE-28] Scheduled stats aggregation, Report export, Backup
~~~

---

## 4. Architectural & Coding Rules for Claude Code
1. **3-Layer Clean Architecture inside `Frontend/lib/features/<feature_name>/`**:
   - `data/`: `models/` (with `fromFirestore` & `toFirestore`), `datasources/`, `repositories/`.
   - `domain/`: `entities/`, `repositories/` (abstract interfaces), `usecases/`.
   - `presentation/`: `bloc/` (or `cubit/`), `screens/`, `widgets/`.
2. **Client-Server Security Boundary**:
   - Flutter client in `Frontend/` MUST NOT directly mutate `loyaltyPoints`, `role`, `checkin_records`, `reward_redemptions`, `bookings` capacity, or contest `voteCount`.
   - Always invoke TypeScript Cloud Functions located in `Backend/functions/src/modules/`.
3. **Offline Mode (`LI-05`)**:
   - Keep Firestore Offline Persistence enabled and use `CachedNetworkImage` for all remote media.
4. **Multi-language Support (`FE-03`, `FE-17`, `FE-18`)**:
   - Store translatable text fields in Firestore as localized maps: `{"vi": "...", "en": "...", "ko": "...", "zh": "..."}`.

---

## 5. Cloud Firestore Collections Reference
- `users/{uid}`: User profile, `role`, `loyaltyPoints`, `favoriteDestinationIds[]`, `isActive`.
- `destinations/{destinationId}`: Multi-language `name`, `category`, `zone`, `overview`, `culturalHistoricalInfo`, `beachSafetyInfo`, `location` (`geopoint`, `geohash`, `address`), `images[]`, `hasVr360`, `hasAudioGuide`, `ratingAvg`, `isPublished`, `embedding` (Vector).
  - Sub-collections: `vr360_contents/{vrId}`, `audio_guides/{audioId}`, `reviews/{reviewId}`.
- `artisans/{artisanId}`: Non Nuoc stone carving artisan profiles and media.
- `events_workshops/{eventWorkshopId}`: Events & craft workshops, schedule, `maxCapacity`, `currentParticipants`.
- `bookings/{bookingId}`: Tourist event/workshop bookings and status.
- `checkin_points/{pointId}` & `checkin_records/{recordId}`: QR check-in locations, secret hashes, cooldown rules, and scan logs.
- `rewards/{rewardId}` & `reward_redemptions/{redemptionId}`: Loyalty rewards catalog and tourist voucher redemptions.
- `stone_carving_contests/{contestId}` (with sub-collections `entries/{entryId}` and `votes/{voteId}`).
- `promotion_campaigns/{campaignId}`: Airport arrival QR promotions and featured content.
- `ai_itineraries_and_logs/{logId}`: AI photo recognition logs and generated RAG itineraries.
- `system_administration/*`: `configs`, `analytics_daily/{date}`, and `audit_logs/{logId}`.

---

## 6. Common Commands from `DoAn_SP27/` Root

### Run Flutter Frontend (`DoAn_SP27/Frontend`)
~~~bash
# Cách 1: Chạy trực tiếp qua file script (mặc định luôn chạy cổng 8000):
./run_web.bat     # Trên Windows (hoặc nhấp đúp file run_web.bat)
./run_web.sh      # Trên macOS / Linux

# Cách 2: Chạy qua VS Code / IDE:
# Nhấn F5 (đã cấu hình sẵn profile "SmartTravel Web (Port 8000)" trong .vscode/launch.json)

# Cách 3: Chạy thủ công qua lệnh terminal:
cd Frontend
flutter pub get
flutter run -d chrome --web-port 8000
~~~

### Run / Deploy Firebase Backend (`DoAn_SP27/Backend`)
~~~bash
cd Backend/functions
npm install
npm run build
cd ..
firebase emulators:start
# Deploy to production:
firebase deploy --only firestore:rules,storage:rules,functions
~~~