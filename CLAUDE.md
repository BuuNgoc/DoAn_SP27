# CLAUDE.md - SmartTravel Project Architectural Guidelines & AI Context

> **Dự án**: Build SmartTravel – Smart Tourism Platform for Ngu Hanh Son
> **Mã dự án**: `SmartTravel` | **Nhóm**: `SE13` (FPT University Da Nang)
> **Mentor**: Lê Thiện Nhật Quang (`quangltn3@fe.edu.vn` | `0868917786`)
> **Thành viên**:
> - Nguyễn Ngọc Bữu – Leader (`buunnde180722@fpt.edu.vn` | `0822835695`)
> - Văn Đức Tài – Member (`taivdde180369@fpt.edu.vn` | `0329683755`)
> - Vương Mai Ngân – Member (`nganvmde180218@fpt.edu.vn` | `0388490965`)
> - Nguyễn Thị An Thuyên – Member (`thuyenntade180415@fpt.edu.vn` | `0905744213`)
> - Trương Đình Nhật – Member (`nhattdde180221@fpt.edu.vn` | `0388503677`)

---

## 1. Bản đồ Tài liệu Tham chiếu (Single Source of Truth)
- [cautruc.md](file:///c:/SU26/DoAn_SP27/cautruc.md): Kiến trúc monorepo, sơ đồ bộ sưu tập Firestore, hướng dẫn lệnh build và quy tắc bảo mật.
- [tailieudacta.md](file:///c:/SU26/DoAn_SP27/tailieudacta.md): Đặc tả nghiệp vụ chuẩn trích xuất từ Capstone Report 1, chi tiết 28 chức năng (`FE-01` -> `FE-28`) và 11 giới hạn kỹ thuật (`LI-01` -> `LI-11`).

---

## 2. Phân Quyền Người Dùng (RBAC)
1. **`TOURIST`** (Du khách): Sử dụng ứng dụng di động (`FE-01` đến `FE-16`).
2. **`TOURISM_MANAGER`** (Cán bộ / Quản lý Du lịch): Quản lý nội dung, sự kiện, nghệ nhân, QR, quà tặng, báo cáo thống kê trên Admin Web (`FE-17` đến `FE-25`).
3. **`ADMIN`** (Quản trị viên Hệ thống): Quản lý người dùng, phân quyền RBAC (`FE-26`, `FE-27`), cấu hình hệ thống, audit logs, backup dữ liệu (`FE-28`) và kế thừa toàn bộ quyền của Manager.

---

## 3. Bảng Ánh Xạ 28 Chức Năng (FE-01 -> FE-28)

| Mã FE | Tên Chức Năng | Thư Mục Frontend | Module Backend |
|---|---|---|---|
| **FE-01** | Authentication & Profile | `features/auth/` | `modules/auth_and_users/` |
| **FE-02** | Destination Discovery | `features/destination_discovery/` | Firestore `destinations` |
| **FE-03** | VR360 & Audio Guide | `features/vr360_audio_guide/` | Firestore sub-collections |
| **FE-04** | Interactive Tourism Map | `features/interactive_map/` | Firestore geohash / GeoPoints |
| **FE-05** | AI Photo Recognition & RAG Itinerary | `features/ai_travel_assistant/` | `modules/ai_and_rag/` |
| **FE-06** | Events & Workshops Discovery | `features/events_workshops_craft/` | Firestore `events_workshops` |
| **FE-07** | Booking Management | `features/booking_management/` | `modules/booking_and_events/` |
| **FE-08** | QR Check-in System | `features/qr_checkin_loyalty/` | `modules/checkin_and_loyalty/` |
| **FE-09** | Loyalty Points & Rewards | `features/qr_checkin_loyalty/` | `modules/checkin_and_loyalty/` |
| **FE-10** | Reviews & Ratings | `features/reviews_social_sharing/` | `modules/reviews_and_moderation/` |
| **FE-11** | Social Sharing | `features/reviews_social_sharing/` | Native Share Plus |
| **FE-12** | An Thuong Tourist Hub | `features/specialized_zones/` | Firestore `destinations` (zone: An Thuong) |
| **FE-13** | Beach Tourism & Safety | `features/specialized_zones/` | Firestore `destinations` (zone: Beach) |
| **FE-14** | Airport Arrival Promotions | `features/specialized_zones/` | Firestore `promotion_campaigns` |
| **FE-15** | Non Nuoc Stone Village Artisans | `features/events_workshops_craft/` | Firestore `artisans` |
| **FE-16** | Stone Carving Contest Voting | `features/events_workshops_craft/` | `modules/booking_and_events/` |
| **FE-17** | Destination CMS Management | `features/admin_portal/` | Admin Firestore Write |
| **FE-18** | VR360 & Audio Media CMS | `features/admin_portal/` | Admin Storage & Sub-collection CMS |
| **FE-19** | Events & Workshop Management | `features/admin_portal/` | Admin Event CMS |
| **FE-20** | QR Check-in & Loyalty Rules Management | `features/admin_portal/` | `modules/checkin_and_loyalty/` |
| **FE-21** | Artisans & Craft Village Management | `features/admin_portal/` | Admin Artisan CMS |
| **FE-22** | Stone Carving Contest Management | `features/admin_portal/` | Admin Contest CMS |
| **FE-23** | An Thuong & Beach Zones Management | `features/admin_portal/` | Admin Zone CMS |
| **FE-24** | Promotion Campaign Management | `features/admin_portal/` | Admin Campaign CMS |
| **FE-25** | Tourism Analytics & Reporting | `features/admin_portal/` | `modules/analytics_and_system/` |
| **FE-26** | User Account Management | `features/admin_portal/` | `modules/auth_and_users/` |
| **FE-27** | Role-Based Access Control (RBAC) | `features/admin_portal/` | `modules/auth_and_users/` |
| **FE-28** | System Config, Audit Logs & Backup | `features/admin_portal/` | `modules/analytics_and_system/` |

---

## 4. 11 Giới Hạn Hệ Thống (LI-01 -> LI-11)
- **LI-01 (Địa lý)**: Giới hạn trọng tâm địa bàn quận Ngũ Hành Sơn (danh thắng Ngũ Hành Sơn, Non Nước, Sơn Thủy, Tân Trà, An Thượng).
- **LI-02 (RBAC)**: Chỉ hỗ trợ đúng 3 role: `TOURIST`, `TOURISM_MANAGER`, `ADMIN`.
- **LI-03 (Nền tảng)**: Ứng dụng di động Flutter trên iOS và Android; Web Admin & Promo.
- **LI-04 (Hạ tầng)**: Nền tảng Firebase Serverless (Auth, Firestore, Cloud Functions TypeScript, Storage, FCM).
- **LI-05 (Offline)**: Hỗ trợ lưu đệm ngoại tuyến với Firestore Persistence và `CachedNetworkImage`.
- **LI-06 (Đa ngôn ngữ)**: Hỗ trợ 4 ngôn ngữ chuẩn: Tiếng Việt (`vi`), Tiếng Anh (`en`), Tiếng Hàn (`ko`), Tiếng Trung (`zh`). Dữ liệu văn bản lưu dạng Map đa ngữ.
- **LI-07 (Bảo mật Client-Server)**: Client Flutter **tuyệt đối không** tự ý ghi trực tiếp vào các trường nhạy cảm (`loyaltyPoints`, `role`, `checkin_records`, `reward_redemptions`, `currentParticipants`, `voteCount`). Tất cả phải qua Cloud Functions.
- **LI-08 (Chống gian lận QR Check-in)**: Check-in bằng chữ ký HMAC/Crypto, kiểm tra khoảng cách GPS geofence và thời gian giãn cách (cooldown).
- **LI-09 (AI/RAG)**: Sử dụng Gemini Vision nhận diện địa danh và Gemini + Firestore Vector Embeddings tạo lịch trình cá nhân hóa. Giới hạn tần suất gọi API (rate limiting).
- **LI-10 (Đa phương tiện)**: VR360 ảnh panorama độ phân giải cao và audio thuyết minh nén tối ưu băng thông.
- **LI-11 (Phạm vi nghiệp vụ)**: **Không** xây dựng các chức năng ngoài phạm vi: không đặt vé máy bay, không PMS quản trị phòng khách sạn toàn diện, không sàn thương mại điện tử mua bán hàng hóa nói chung. Chỉ quản lý trải nghiệm du lịch, sự kiện, workshop và quà lưu niệm/voucher.

---

## 5. Quy Tắc Phát Triển Cho Các Phiên Làm Việc Tiếp Theo
1. **Frontend**:
   - Tuân thủ nghiêm ngặt 3 tầng Clean Architecture tại từng feature (`data/`, `domain/`, `presentation/`).
   - Mọi state management dùng `flutter_bloc`, điều hướng dùng `go_router`, dependency injection dùng `get_it`.
   - Tất cả text hiển thị trên UI phải dùng localization (`vi`, `en`, `ko`, `zh`).
2. **Backend**:
   - Viết Cloud Functions bằng TypeScript, kiểm tra quyền hạn bằng `role_guard.ts`.
   - Ghi nhật ký các tác vụ quản trị vào `audit_logger.ts`.
   - Kiểm tra chặt chẽ `firestore.rules` và `storage.rules` trước khi triển khai.

---

## 6. UI/UX Pro Max Design Intelligence Skill
- **Đường dẫn**: `.agents/skills/ui-ux-pro-max/` (đồng bộ tại `.agent/skills/ui-ux-pro-max/`)
- **Bộ skills thiết kế tích hợp**:
  - `ui-ux-pro-max`: Design intelligence cho web/mobile/desktop, 80 UI styles, 192 palettes, 74 font pairings, 120 UX rules, hỗ trợ Flutter stack.
  - `design`: Quy chuẩn thiết kế logo, visual identity, landing pages.
  - `design-system`: Thiết lập và quản lý Design Tokens, Component System.
  - `ui-styling`: Hướng dẫn style, animation, spacing.
  - `brand`: Nhận diện thương hiệu & định vị sản phẩm du lịch.
  - `banner-design`: Thiết kế ấn phẩm truyền thông, banner sự kiện/workshop.
  - `slides`: Hướng dẫn thiết kế slide báo cáo dự án.
- **Lệnh tra cứu thiết kế nhanh**:
  ```bash
  python .agents/skills/ui-ux-pro-max/scripts/search.py "<query>" --design-system
  python .agents/skills/ui-ux-pro-max/scripts/search.py "<query>" --domain <domain> --stack flutter
  ```
