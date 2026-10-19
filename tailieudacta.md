# Tài liệu Đặc tả Dự án & Quy tắc Kiến trúc cho Claude Code (SmartTravel - SE13)

> **Chỉ dẫn bắt buộc dành cho Claude Code**:
> Tài liệu này là nguồn tham chiếu chuẩn xác nhất (Single Source of Truth) được trích xuất từ báo cáo Capstone Project Report 1 của dự án **SmartTravel**[cite: 10].
> - Toàn bộ mã nguồn Frontend đặt tại: `DoAn_SP27/Frontend/`[cite: 9].
> - Toàn bộ mã nguồn Backend đặt tại: `DoAn_SP27/Backend/`[cite: 9].
> - Trước khi viết code cho bất kỳ màn hình hay API nào, BẮT BUỘC phải đối chiếu đúng mã chức năng (`FE-01` -> `FE-28`) và tuân thủ nghiêm ngặt các giới hạn kỹ thuật (`LI-01` -> `LI-11`) bên dưới[cite: 10]. Tuyệt đối không tự ý thêm các tính năng nằm ngoài phạm vi dự án (như đặt vé máy bay, vận hành khách sạn hay thương mại điện tử toàn diện theo `LI-11`)[cite: 10].

---

## 1. Thông tin Tổng quan Dự án (Project Overview)
* **Tên dự án**: Build SmartTravel – Smart Tourism Platform for Ngu Hanh Son[cite: 10].
* **Mã dự án**: `SmartTravel`[cite: 10].
* **Tên nhóm**: `SE13` – Trường Đại học FPT Đà Nẵng[cite: 10].
* **Loại phần mềm**: Ứng dụng Web (Web Application) và Ứng dụng Di động (Mobile App)[cite: 10].
* **Giảng viên hướng dẫn (Mentor)**: Lê Thiện Nhật Quang (`quangltn3@fe.edu.vn` | `0868917786`)[cite: 10].
* **Thành viên nhóm**:
  * Nguyễn Ngọc Bữu – Leader (`buunnde180722@fpt.edu.vn` | `0822835695`)[cite: 10].
  * Văn Đức Tài – Member (`taivdde180369@fpt.edu.vn` | `0329683755`)[cite: 10].
  * Vương Mai Ngân – Member (`nganvmde180218@fpt.edu.vn` | `0388490965`)[cite: 10].
  * Nguyễn Thị An Thuyên – Member (`thuyenntade180415@fpt.edu.vn` | `0905744213`)[cite: 10].
  * Trương Đình Nhật – Member (`nhattdde180221@fpt.edu.vn` | `0388503677`)[cite: 10].

---

## 2. Bối cảnh Nghiệp vụ & Tầm nhìn Sản phẩm (Product Vision & Scope)
* **Phạm vi địa lý trọng tâm**: Khu vực quận Ngũ Hành Sơn (Đà Nẵng), bao gồm danh thắng Ngũ Hành Sơn (núi, hang động, chùa chiền), Làng đá mỹ nghệ Non Nước, bãi biển Sơn Thủy – Tân Trà và khu phố du lịch An Thượng (nhà hàng, khách sạn, dịch vụ giải trí về đêm)[cite: 10].
* **Bài toán giải quyết**: Khắc phục tình trạng thông tin du lịch và các cơ sở dịch vụ địa phương bị phân mảnh trên nhiều nền tảng khác nhau, giúp du khách khám phá địa điểm, trải nghiệm văn hóa làng nghề và lên lịch trình trên một nền tảng duy nhất[cite: 10].
* **Ứng dụng AI & RAG**:
  * Gợi ý điểm đến và tạo lịch trình du lịch cá nhân hóa dựa trên thông tin đầu vào của du khách gồm: thời gian rảnh (available time), ngân sách (budget), sở thích (interests), phương tiện di chuyển (transportation method) và hoạt động yêu thích (preferred activities)[cite: 10].
  * Nhận diện địa danh/điểm tham quan qua hình ảnh do du khách chụp hoặc tải lên (`FE-05`)[cite: 10].
* **Ba thành phần cốt lõi của hệ thống**:
  1. **Ứng dụng Di động (`SmartTravel Mobile` / `360Mobile`)**: Xây dựng bằng Flutter dành cho du khách khám phá điểm đến, xem VR360, nghe thuyết minh tự động (Audio Guide), nhận diện ảnh bằng AI, bản đồ tương tác, đặt lịch sự kiện/workshop, quét QR check-in nhận thưởng và đánh giá[cite: 10].
  2. **Hệ thống Quản trị (`SmartTravel Admin Web` / `360 Admin Web`)**: Dành cho Quản trị viên và Quản lý du lịch quản lý người dùng, nội dung điểm đến, tài nguyên VR360/Audio, sự kiện, workshop, mã QR, quà tặng, chiến dịch quảng bá và xem biểu đồ thống kê[cite: 10].
  3. **Trang Quảng bá (`SmartTravel Promotion Web` / `360 Promotion Web`)**: Kênh truyền thông giới thiệu du lịch Ngũ Hành Sơn, di sản văn hóa, sự kiện, workshop và điều hướng du khách tải ứng dụng di động[cite: 10].

---

## 3. Phân quyền Người dùng (System Actors & RBAC)
Hệ thống bao gồm 3 nhóm tác nhân chính (cần kiểm tra chặt chẽ trong cả Router của Frontend lẫn Security Rules/Middlewares của Backend)[cite: 10]:
1. **`ADMIN` (System Administrator)**:
   * Cấu hình và duy trì nền tảng, quản lý tài khoản người dùng (`FE-26`), phân quyền vai trò (`FE-27`), cấu hình hệ thống/thông báo, theo dõi nhật ký hoạt động (Audit Logs), sao lưu dữ liệu (`FE-28`) và toàn quyền quản lý nội dung trên Admin Web[cite: 10].
2. **`TOURISM_MANAGER` (Local Tourism Authority / Management Staff)**:
   * Quản lý hoạt động nghiệp vụ du lịch trên Admin Web gồm: thông tin điểm đến (`FE-17`), nội dung VR360 & Audio Guide (`FE-18`), sự kiện & workshop (`FE-19`), điểm check-in QR & tích điểm thưởng (`FE-20`), nghệ nhân & làng nghề (`FE-21`), cuộc thi điêu khắc đá (`FE-22`), khu vực An Thượng & biển (`FE-23`), chiến dịch quảng bá (`FE-24`) và thống kê báo cáo (`FE-25`)[cite: 10].
3. **`TOURIST` (Tourist / Mobile User)**:
   * Sử dụng ứng dụng di động để thực hiện các chức năng từ `FE-01` đến `FE-16`[cite: 10].

---

## 4. Cấu trúc Thư mục Dự án (`DoAn_SP27/`)
Khi tạo file mới, Claude Code phải đặt đúng vào cấu trúc Monorepo sau[cite: 9]:

~~~text
DoAn_SP27/
├── CLAUDE.md                                   # Tài liệu đặc tả dự án dành cho AI Agent
├── README.md                                   # Tài liệu hướng dẫn cài đặt
├── Frontend/                                   # ỨNG DỤNG FLUTTER (DoAn_SP27/Frontend/)
│   ├── pubspec.yaml
│   ├── assets/                                 # images, icons, animations, translations (vi, en, ko, zh)
│   └── lib/
│       ├── main.dart
│       ├── app.dart
│       ├── firebase_options.dart
│       ├── core/                               # constants, di, errors, network, router, services, theme, utils
│       ├── shared/                             # models & widgets dùng chung
│       └── features/                           # Chia đúng theo các module nghiệp vụ FE-01 -> FE-28
│           ├── auth/                           # [FE-01]
│           ├── destination_discovery/          # [FE-02]
│           ├── vr360_audio_guide/              # [FE-03]
│           ├── interactive_map/                # [FE-04]
│           ├── ai_travel_assistant/            # [FE-05 & RAG Itinerary]
│           ├── events_workshops_craft/         # [FE-06, FE-15, FE-16]
│           ├── booking_management/             # [FE-07]
│           ├── qr_checkin_loyalty/             # [FE-08, FE-09]
│           ├── reviews_social_sharing/         # [FE-10, FE-11]
│           ├── specialized_zones/              # [FE-12, FE-13, FE-14]
│           └── admin_portal/                   # [FE-17 -> FE-28]
│
└── Backend/                                    # HỆ THỐNG BACKEND FIREBASE (DoAn_SP27/Backend/)
    ├── firebase.json
    ├── firestore.rules                         # Phân quyền RBAC cho TOURIST, TOURISM_MANAGER, ADMIN
    ├── firestore.indexes.json                  # Composite Indexes & Vector Indexes cho RAG
    ├── storage.rules                           # Bảo mật lưu trữ ảnh, video, VR360, Audio
    └── functions/                              # Cloud Functions (TypeScript) xử lý nghiệp vụ Backend
        ├── package.json
        ├── tsconfig.json
        └── src/
            ├── index.ts
            ├── config/                         # Cấu hình Firebase Admin & Gemini/RAG AI
            ├── common/                         # Middlewares kiểm tra Role, Audit Logger, QR Crypto
            └── modules/
                ├── auth_and_users/             # [FE-01, FE-26, FE-27]
                ├── ai_and_rag/                 # [FE-05 & RAG/AI]
                ├── booking_and_events/         # [FE-06, FE-07, FE-15, FE-16, FE-19, FE-22]
                ├── checkin_and_loyalty/        # [FE-08, FE-09, FE-20]
                ├── reviews_and_moderation/     # [FE-10]
                └── analytics_and_system/       # [FE-25, FE-28]
~~~

---

## 5. Danh mục Đầy đủ 28 Chức năng Hệ thống (`FE-01` đến `FE-28`)
Claude Code phải đảm bảo triển khai đầy đủ từng chức năng con (sub-features) dưới đây, không bỏ sót bất kỳ luồng nghiệp vụ nào[cite: 10]:

### Nhóm A: Phân hệ dành cho Du khách trên Mobile App (`FE-01` -> `FE-16`)

* **`FE-01`: Authentication (Xác thực & Tài khoản)** (`features/auth/`)[cite: 10]:
  * Register (Đăng ký tài khoản mới)[cite: 10].
  * Login (Đăng nhập)[cite: 10].
  * Reset Password (Khôi phục mật khẩu khi quên)[cite: 10].
  * Change Password (Đổi mật khẩu)[cite: 10].
  * Logout (Đăng xuất)[cite: 10].
  * View Profile (Xem thông tin cá nhân)[cite: 10].
  * Update Profile (Cập nhật hồ sơ cá nhân)[cite: 10].

* **`FE-02`: Destination Discovery (Khám phá Điểm đến)** (`features/destination_discovery/`)[cite: 10]:
  * View Destination List (Xem danh sách điểm đến)[cite: 10].
  * Search Destination (Tìm kiếm điểm đến theo từ khóa)[cite: 10].
  * Filter Destination by Category (Lọc điểm đến theo danh mục)[cite: 10].
  * View Destination Details (Xem chi tiết điểm đến)[cite: 10].
  * View Destination Images and Videos (Xem thư viện hình ảnh và video của điểm đến)[cite: 10].
  * View Destination Information (Xem thông tin mô tả điểm đến)[cite: 10].
  * View Location and Opening Hours (Xem vị trí và giờ mở cửa)[cite: 10].
  * View Cultural and Historical Information (Xem thông tin văn hóa và lịch sử)[cite: 10].
  * Save Favorite Destination (Lưu điểm đến yêu thích)[cite: 10].

* **`FE-03`: VR360 & Audio Guide (Trải nghiệm VR360 & Thuyết minh Tự động)** (`features/vr360_audio_guide/`)[cite: 10]:
  * View VR360 Experience (Xem trải nghiệm VR360)[cite: 10].
  * Explore 360° Destination View (Khám phá góc nhìn 360° tương tác tại điểm đến)[cite: 10].
  * View VR360 Content by Location (Xem nội dung VR360 theo từng khu vực/vị trí)[cite: 10].
  * Play Audio Guide (Phát bản thuyết minh âm thanh)[cite: 10].
  * Pause / Resume Audio Guide (Tạm dừng / Tiếp tục phát thuyết minh)[cite: 10].
  * Select Audio Guide Language (Chọn ngôn ngữ thuyết minh)[cite: 10].
  * View Audio Guide Information (Xem thông tin/nội dung chữ của bài thuyết minh)[cite: 10].
  * Access VR360 and Audio Guide from Destination Details (Truy cập trực tiếp VR360 và Audio Guide từ màn hình chi tiết điểm đến)[cite: 10].

* **`FE-04`: Interactive Tourism Map (Bản đồ Du lịch Tương tác)** (`features/interactive_map/`)[cite: 10]:
  * View Interactive Tourism Map (Xem bản đồ du lịch tương tác)[cite: 10].
  * View Destination Locations (Hiển thị vị trí các điểm tham quan chính)[cite: 10].
  * View Tourism Points of Interest (Hiển thị các điểm quan tâm POI du lịch)[cite: 10].
  * View Restaurants and Local Services (Hiển thị nhà hàng và dịch vụ địa phương)[cite: 10].
  * View Beach Tourism Locations (Hiển thị các địa điểm du lịch biển)[cite: 10].
  * View An Thượng Locations (Hiển thị các địa điểm thuộc khu phố An Thượng)[cite: 10].
  * View Workshop and Event Locations (Hiển thị vị trí tổ chức workshop và sự kiện)[cite: 10].
  * View Check-in Points (Hiển thị các trạm quét mã QR check-in)[cite: 10].
  * View Location Details (Xem thông tin tóm tắt/chi tiết khi chạm vào điểm trên bản đồ)[cite: 10].
  * Get Directions to Selected Location (Chỉ đường đến vị trí đã chọn)[cite: 10].

* **`FE-05`: AI Photo Recognition (Nhận diện Địa danh bằng AI)** (`features/ai_travel_assistant/`)[cite: 10]:
  * Capture or Upload Photo (Chụp ảnh mới từ camera hoặc tải ảnh từ thư viện)[cite: 10].
  * Analyze Tourism Image (Phân tích hình ảnh du lịch bằng AI)[cite: 10].
  * Recognize Destination or Landmark (Nhận diện điểm đến hoặc địa danh tại Ngũ Hành Sơn)[cite: 10].
  * Display Recognition Result (Hiển thị kết quả nhận diện)[cite: 10].
  * Display Destination Information (Hiển thị thông tin về điểm đến vừa nhận diện)[cite: 10].
  * Display Related Tourism Content (Hiển thị các nội dung du lịch liên quan)[cite: 10].
  * Navigate to Destination Details (Điều hướng sang màn hình chi tiết của điểm đến đó)[cite: 10].
  * *(Kết hợp tính năng RAG/AI trong báo cáo)*: Cho phép du khách nhập thời gian, ngân sách, sở thích, phương tiện để nhận gợi ý điểm đến và lịch trình cá nhân hóa[cite: 10].

* **`FE-06`: Event & Workshop (Sự kiện & Workshop)** (`features/events_workshops_craft/`)[cite: 10]:
  * View Event List (Xem danh sách sự kiện)[cite: 10].
  * View Workshop List (Xem danh sách workshop)[cite: 10].
  * Search Event / Workshop (Tìm kiếm sự kiện / workshop)[cite: 10].
  * Filter Event / Workshop (Lọc sự kiện / workshop)[cite: 10].
  * View Event / Workshop Details (Xem chi tiết sự kiện / workshop)[cite: 10].
  * View Event Schedule (Xem lịch trình tổ chức sự kiện)[cite: 10].
  * View Event Location (Xem địa điểm tổ chức)[cite: 10].
  * View Organizer / Artisan Information (Xem thông tin đơn vị tổ chức / nghệ nhân hướng dẫn)[cite: 10].
  * Register for Event / Workshop (Đăng ký tham gia sự kiện / workshop)[cite: 10].
  * Cancel Registration (Hủy đăng ký tham gia)[cite: 10].

* **`FE-07`: Booking Management (Quản lý Đặt chỗ)** (`features/booking_management/`)[cite: 10]:
  * View Available Booking Services (Xem các dịch vụ/trải nghiệm hỗ trợ đặt chỗ)[cite: 10].
  * Select Event / Workshop / Experience (Chọn sự kiện / workshop / trải nghiệm muốn đặt)[cite: 10].
  * Select Date and Time (Chọn ngày và khung giờ)[cite: 10].
  * Select Number of Participants (Chọn số lượng người tham gia)[cite: 10].
  * Create Booking (Tạo yêu cầu đặt chỗ)[cite: 10].
  * View Booking Details (Xem chi tiết đơn đặt chỗ)[cite: 10].
  * Confirm Booking (Xác nhận đặt chỗ)[cite: 10].
  * Cancel Booking (Hủy đặt chỗ)[cite: 10].
  * View Booking History (Xem lịch sử đặt chỗ)[cite: 10].
  * Receive Booking Confirmation (Nhận thông báo xác nhận đặt chỗ)[cite: 10].

* **`FE-08`: QR Check-in (Check-in bằng Mã QR)** (`features/qr_checkin_loyalty/`)[cite: 10]:
  * View Check-in Points (Xem danh sách các điểm hỗ trợ check-in)[cite: 10].
  * Scan QR Code (Quét mã QR tại điểm đến)[cite: 10].
  * Validate Check-in (Xác thực tính hợp lệ của lượt check-in)[cite: 10].
  * Record Check-in History (Lưu nhận lịch sử check-in)[cite: 10].
  * View Check-in Status (Xem trạng thái đã check-in hay chưa)[cite: 10].
  * View Check-in Progress (Xem tiến độ bộ sưu tập check-in tại Ngũ Hành Sơn)[cite: 10].
  * Display Check-in Confirmation (Hiển thị màn hình/hộp thoại xác nhận check-in thành công)[cite: 10].

* **`FE-09`: Loyalty & Reward (Tích điểm & Đổi quà)** (`features/qr_checkin_loyalty/`)[cite: 10]:
  * View Loyalty Points (Xem số điểm tích lũy hiện tại)[cite: 10].
  * Earn Points from Check-in (Nhận điểm thưởng khi quét QR check-in)[cite: 10].
  * Earn Points from Tourism Activities (Nhận điểm từ các hoạt động du lịch hợp lệ)[cite: 10].
  * View Reward List (Xem danh sách quà tặng/ưu đãi có thể đổi)[cite: 10].
  * Redeem Rewards (Thực hiện đổi điểm lấy quà/souvenir)[cite: 10].
  * View Reward Details (Xem chi tiết quà tặng và điều kiện áp dụng)[cite: 10].
  * View Reward Redemption History (Xem lịch sử đã đổi quà)[cite: 10].
  * View Loyalty Progress (Xem tiến trình tích điểm thành viên)[cite: 10].

* **`FE-10`: Review & Rating (Đánh giá & Xếp hạng)** (`features/reviews_social_sharing/`)[cite: 10]:
  * View Destination Reviews (Xem danh sách đánh giá của điểm đến)[cite: 10].
  * Submit Rating (Gửi số sao xếp hạng)[cite: 10].
  * Write Review (Viết nội dung nhận xét)[cite: 10].
  * Upload Review Images (Tải ảnh chụp thực tế kèm đánh giá)[cite: 10].
  * Edit Review (Chỉnh sửa đánh giá của bản thân)[cite: 10].
  * Delete Review (Xóa đánh giá của bản thân)