# 🌟 NHS360 – Smart Travel Ngũ Hành Sơn

> **Nền tảng Du lịch Thông minh & Khám phá Di sản Ngũ Hành Sơn**  
> Dự án Đồ án Tốt nghiệp – Nhóm **SE13** | **Đại học FPT Đà Nẵng**

---

## 📌 Mục lục
1. [Tổng quan dự án](#-tổng-quan-dự-án)
2. [Yêu cầu môi trường (Prerequisites)](#-yêu-cầu-môi-trường-prerequisites)
3. [Cách 1: Khởi chạy bằng Docker (Khuyến nghị)](#-cách-1-khởi-chạy-bằng-docker-khuyến-nghị)
4. [Cách 2: Khởi chạy ứng dụng Di động (Mobile App trên Giả lập Android)](#-cách-2-khởi-chạy-ứng-dụng-di-động-mobile-app)
5. [Cách 3: Khởi chạy Frontend Web bằng VS Code (Hỗ trợ Hot-Reload)](#-cách-3-khởi-chạy-frontend-web-bằng-vs-code)
6. [Cách 4: Khởi chạy Backend thủ công (Firebase Emulators)](#-cách-4-khởi-chạy-backend-thủ-công-firebase-emulators)
7. [Bảng ánh xạ cổng dịch vụ (Port Mapping)](#-bảng-ánh-xạ-cổng-dịch-vụ)
8. [Cấu hình biến môi trường (.env)](#-cấu-hình-biến-môi-trường)
9. [Quy tắc Git & Đóng góp](#-quy-tắc-git--đóng-góp)

---

## 📖 Tổng quan dự án

Dự án được tổ chức theo mô hình **Monorepo**:
```text
NHS360/
├── Mobile/             # Ứng dụng du lịch đa nền tảng Flutter (Mobile & Web)
├── Backend/            # Cloud Functions (TypeScript) & Cấu hình Firestore / Storage
├── AI_Service/         # Trung tâm huấn luyện AI tự quản (Landmark, Stone Craft, Sentiment)
├── docker-compose.yml  # Điều phối môi trường Container hóa toàn bộ hệ thống
├── run_docker.bat      # Script 1-click chạy Docker trên Windows
├── run_docker.sh       # Script chạy Docker trên Linux/macOS
├── run_mobile.bat      # Script chạy nhanh ứng dụng di động trên máy ảo Android
└── .env.example        # Mẫu khai báo biến môi trường
```

---

## 🛠 Yêu cầu môi trường (Prerequisites)

Tùy theo nhu cầu chạy dự án, bạn cần cài đặt các công cụ tương ứng:

| Mục đích | Công cụ cần thiết |
| :--- | :--- |
| **Chạy toàn bộ dự án qua Docker** | [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Docker Compose v2.0+) |
| **Phát triển Frontend (Flutter)** | [Flutter SDK](https://docs.flutter.dev/) (v3.24+ / 3.29+), [VS Code](https://code.visualstudio.com/) hoặc Android Studio |
| **Chạy Giả lập Android** | Android Studio, Android SDK (Platform-tools, Emulator: khuyến nghị `Pixel_7a` hoặc `Pixel_8`) |
| **Phát triển Backend** | [Node.js](https://nodejs.org/) (v20 LTS), [Java OpenJDK 17+](https://adoptium.net/) (bắt buộc cho Firestore Emulator) |

---

## 🚀 Cách 1: Khởi chạy bằng Docker (Khuyến nghị)

Phương pháp này giúp chạy **đồng thời cả Frontend Web, Backend Cloud Functions và Cơ sở dữ liệu Firestore** chỉ với một lệnh duy nhất mà không cần cài đặt Flutter hay Node.js trên máy tính.

### Bước 1: Khởi động hệ thống
- **Trên Windows**: Nhấp đúp chuột vào file:
  ```text
  run_docker.bat
  ```
- **Hoặc chạy bằng dòng lệnh Terminal / PowerShell**:
  ```bash
  docker-compose up -d --build
  ```

### Bước 2: Truy cập các dịch vụ
Sau khi container khởi động hoàn tất:
- **Ứng dụng Web NHS360**: Truy cập [http://localhost:8000](http://localhost:8000)
- **Bảng điều khiển Database (Firebase Emulator UI)**: Truy cập [http://localhost:4000](http://localhost:4000)

### Bước 3: Xem log và quản lý container
```bash
# Xem log toàn hệ thống theo thời gian thực
docker-compose logs -f

# Xem log riêng Backend/Cloud Functions
docker-compose logs -f backend

# Xem log riêng Frontend Nginx
docker-compose logs -f frontend

# Dừng hệ thống (Dữ liệu Firestore vẫn được bảo lưu qua Volume)
docker-compose down
```

---

## 📱 Cách 2: Khởi chạy ứng dụng Di động (Mobile App)

Ứng dụng du lịch tối ưu trên thiết bị di động (hỗ trợ Camera AI nhận diện địa danh, VR360, Quét QR check-in, Bản đồ tương tác).

> **Lưu ý đặc biệt trên Windows:**  
> Nếu thư mục dự án có chứa dấu tiếng Việt (ví dụ: `D:\FPT\Đồ Án`), công cụ Android NDK / CMake của một số thư viện có thể bị lỗi ký tự. Script đã tự động ánh xạ ổ ảo `X:` để khắc phục triệt để.

### Cách 2.1: Chạy bằng file tiện ích 1-click
Nhấp đúp vào file:
```text
run_mobile.bat
```
*(Script sẽ tự kiểm tra máy ảo Android, nếu chưa mở sẽ tự bật giả lập `Pixel_7a` và chạy ứng dụng)*.

---

### Cách 2.2: Chạy thủ công bằng Terminal (PowerShell)

1. **Bật máy ảo Android** (nếu chưa bật):
   ```powershell
   & "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Pixel_7a
   ```
   *(Chờ 10-15 giây để màn hình chính của điện thoại xuất hiện)*

2. **Chạy ứng dụng Flutter**:
   ```powershell
   if (-not (Test-Path "X:\")) { subst X: "$PSScriptRoot" }; cd X:\Mobile; flutter run
   ```

---

## 💻 Cách 3: Khởi chạy Frontend Web bằng VS Code

Dành cho lập trình viên muốn sửa code giao diện với tính năng **Hot Reload (nhấn `r` để cập nhật tức thì)**:

1. Mở thư mục dự án `D:\FPT\Đồ Án` bằng **VS Code**.
2. Nhấn tổ hợp phím **`Ctrl + Shift + D`** (hoặc mở tab *Run and Debug* ở thanh bên trái).
3. Tại thanh chọn cấu hình trên cùng, chọn:
   - **`Frontend (Chrome Web - Port 8000)`**
4. Nhấn phím **`F5`** (hoặc nút Play xanh).
5. Trình duyệt Google Chrome sẽ tự động mở tại `http://localhost:8000/`.

---

## ⚙️ Cách 4: Khởi chạy Backend thủ công (Firebase Emulators)

Nếu không dùng Docker mà muốn chạy backend và database cục bộ bằng Node.js:

1. **Cài đặt Firebase CLI** (nếu chưa có):
   ```bash
   npm install -g firebase-tools
   ```

2. **Cài đặt dependencies và build Cloud Functions**:
   ```bash
   cd Backend/functions
   npm install
   npm run build
   ```

3. **Khởi chạy cụm Emulator (Firestore, Auth, Storage, Functions)**:
   ```bash
   cd ..
   firebase emulators:start --project smarttravel-se13
   ```
4. Mở trình duyệt tại [http://localhost:4000](http://localhost:4000) để xem Database Console.

---

## 🌐 Bảng ánh xạ cổng dịch vụ

| Cổng (Port) | Dịch vụ | Địa chỉ URL | Mô tả |
| :---: | :--- | :--- | :--- |
| **8000** | **Frontend Web** | [http://localhost:8000](http://localhost:8000) | Giao diện Web du lịch NHS360 |
| **4000** | **Firebase Emulator UI** | [http://localhost:4000](http://localhost:4000) | Giao diện quản trị Database, Users, Storage |
| **8080** | **Cloud Firestore** | [http://localhost:8080](http://localhost:8080) | Cổng kết nối cơ sở dữ liệu NoSQL |
| **5001** | **Cloud Functions** | [http://localhost:5001](http://localhost:5001) | Endpoint thực thi logic Backend & AI |
| **9099** | **Firebase Auth** | [http://localhost:9099](http://localhost:9099) | Dịch vụ xác thực tài khoản cục bộ |
| **9199** | **Cloud Storage** | [http://localhost:9199](http://localhost:9199) | Lưu trữ hình ảnh, media VR360 |

---

## 🔑 Cấu hình biến môi trường

1. Tạo file `.env` tại thư mục gốc từ file mẫu [.env.example](file:///.env.example):
   ```bash
   cp .env.example .env
   ```
2. Cập nhật các giá trị cấu hình nếu cần:
   ```env
   # Google Gemini API Key (phục vụ chức năng AI nhận diện hình ảnh & lập lịch trình RAG)
   GEMINI_API_KEY=your_actual_gemini_api_key_here

   GCLOUD_PROJECT=smarttravel-se13
   FRONTEND_PORT=8000
   ```

---

## 🌿 Quy tắc Git & Đóng góp

Để đảm bảo tính ổn định và tính toàn vẹn của mã nguồn:

1. **Quy tắc vàng**: **Tuyệt đối không push trực tiếp lên nhánh `main`**.
2. **Quy trình làm việc chuẩn**:
   ```bash
   # 1. Luôn cập nhật mã nguồn mới nhất từ main
   git checkout main
   git pull origin main

   # 2. Tạo nhánh tính năng mới từ main
   git checkout -b feat/ten-tinh-nang

   # 3. Thực hiện code, kiểm tra và commit
   git add .
   git commit -m "feat: mô tả ngắn gọn công việc đã làm"

   # 4. Push nhánh tính năng lên GitHub
   git push -u origin feat/ten-tinh-nang
   ```
3. **Mở Pull Request (PR)** trên GitHub để nhóm cùng review trước khi merge vào `main`.
