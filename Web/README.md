# 🌐 NHS360 Web Admin & CMS Management Portal

Cổng Quản Trị & Điều Hành Du Lịch Thông Minh Ngũ Hành Sơn (FE-17 → FE-28).

## 🚀 Công Nghệ Sử Dụng (Tech Stack)
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite 6 (Lightning fast HMR & build)
- **Styling**: Tailwind CSS (Thiết kế chuẩn Enterprise & Shangri-La Luxury)
- **Icons**: Lucide React
- **Container**: Docker + Nginx Alpine

## 📁 11 Phân Hệ Quản Trị Tích Hợp (Epics 1 → 8 & Management Layer)
1. **Tổng Quan Dashboard**: KPIs du khách, tỷ lệ chuẩn hóa dữ liệu, biểu đồ tháng, cảnh báo chất lượng dữ liệu.
2. **Quản Lý Điểm Đến (Epic 1)**: Chuẩn hóa 8 nhóm di sản, đo lường Data Completeness Score (0 - 100%), lọc thiếu Audio/VR/Ảnh, modal thêm sửa đầy đủ GPS & câu chuyện văn hóa.
3. **VR360 & Hotspot Builder (Epic 4)**: Kho ảnh Panorama 360°, cấu hình tọa độ Yaw/Pitch, gắn Audio Guide thuyết minh đa ngữ, video & chuyển cảnh tour tuyến.
4. **Mở Rộng Phố An Thượng (Epic 2)**: Duyệt cơ sở kinh doanh do Vendor gửi lên (Ăn uống, Cà phê, Nightlife, Văn nghệ), lịch sự kiện biểu diễn đêm.
5. **Du Lịch Biển Sơn Thủy - Tân Trà (Epic 3)**: Quản lý bãi tắm, lối xuống biển, trạm cứu hộ, hệ thống cập nhật cờ an toàn thời gian thực (Cờ Xanh / Cờ Vàng / Cờ Đỏ), cảnh báo dòng nước rút và phát cảnh báo khẩn.
6. **Cuộc Thi Điêu Khắc Đá (Epic 6)**: Làng nghề Non Nước 400 năm, duyệt tác phẩm nghệ nhân, bảng xếp hạng Leaderboard bình chọn du khách & lượt share.
7. **Workshop Với Nghệ Nhân (Epic 7)**: Quản lý ca trải nghiệm, công cụ quét QR vé tham gia (QR Ticket Validator), tự động cộng +50 Loyalty Points & cấp E-Certificate.
8. **Chiến Dịch QR Sân Bay (Epic 8)**: Quản lý mã QR tại Ga T1/T2 Sân bay Đà Nẵng, cấu hình Airport Landing Page, thống kê tỷ lệ chuyển đổi.
9. **Thống Kê AI Nhận Diện Ảnh (Epic 5)**: Top danh thắng được nhận diện nhiều nhất, độ chính xác mô hình AI (96.8%), công cụ đồng bộ nhãn dataset.
10. **Người Dùng & Phân Quyền RBAC (FE-26, FE-27)**: Quản trị tài khoản ADMIN, TOURISM_MANAGER và TOURIST.
11. **Audit Logs & Sao Lưu Hệ Thống (FE-28)**: Nhật ký kiểm toán thời gian thực, sao lưu Firestore, xuất báo cáo CSV/JSON.

## 🛠️ Hướng Dẫn Khởi Chạy

### Chạy trực tiếp qua Node.js (Port 3000):
```bash
npm install
npm run dev
```
Truy cập: `http://localhost:3000`

### Chạy qua Docker Container:
```bash
docker build -t nhs360-web-admin .
docker run -p 3000:3000 nhs360-web-admin
```
Hoặc dùng `docker-compose up web-admin`.
