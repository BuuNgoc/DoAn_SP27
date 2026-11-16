# 🤖 AGENTS.md — Quy Chuẩn & Dây Chuyền Kỹ Năng Tự Động (NHS360)

> **Tài liệu kim chỉ nam cho AI Assistant trong dự án NHS360 – Smart Travel Ngũ Hành Sơn (SE13)**  
> Tệp này được hệ thống Antigravity tự động nạp ở **mọi lượt tương tác**.  
> Mọi hành vi lập trình, sửa lỗi, thiết kế và tối ưu mã nguồn **bắt buộc phải tuân thủ** các quy tắc dưới đây.

---

## 1. Nguồn Chân Lý Bắt Buộc (Single Source of Truth)

Trước khi thực hiện bất kỳ tác vụ nào, AI phải đối chiếu với 3 tài liệu nghiệp vụ cốt lõi:
- **[`CLAUDE.md`](./CLAUDE.md)**: Bản đồ kiến trúc, phân quyền RBAC (`TOURIST`, `TOURISM_MANAGER`, `ADMIN`), 28 chức năng (`FE-01` → `FE-28`) và 11 giới hạn kỹ thuật (`LI-01` → `LI-11`).
- **[`cautruc.md`](./cautruc.md)**: Cấu trúc monorepo, schema bộ sưu tập Firestore, quy tắc bảo mật.
- **[`tailieudacta.md`](./tailieudacta.md)**: Đặc tả chi tiết từng chức năng từ Capstone Report 1.

> [!IMPORTANT]
> **Quy tắc Git bất di bất dịch**: Tuyệt đối **KHÔNG BAO GIỜ** push trực tiếp lên nhánh `main`. Luôn luôn tạo nhánh tính năng mới (`feat/...`, `fix/...`) và tạo Pull Request.

---

## 2. Dây Chuyền Kỹ Năng Tự Động (Automatic Skill Pipeline)

Mỗi khi người dùng đưa ra yêu cầu lập trình (code tính năng mới, sửa lỗi, làm giao diện), AI **tự động kích hoạt tuần tự các bộ kỹ năng** tương ứng theo quy trình chuẩn sau:

```
                  Yêu Cầu Lập Trình Từ Người Dùng
                                │
                                ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ GIAI ĐOẠN 1: LẬP KẾ HOẠCH & KIẾN TRÚC                      │
 │ • superpowers:brainstorming   (Làm rõ yêu cầu & giải pháp)  │
 │ • superpowers:writing-plans   (Lập plan chi tiết từng bước) │
 │ • harness                     (Tổ chức kiến trúc đa agent)  │
 └──────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ GIAI ĐOẠN 2: THIẾT KẾ UI/UX (Nếu có can thiệp giao diện)    │
 │ • ui-ux-pro-max   (Tra cứu du lịch: palette, style, layout) │
 │ • design-system   (Áp dụng design tokens: color, spacing)   │
 │ • ui-styling      (Tái sử dụng component, responsive)       │
 └──────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ GIAI ĐOẠN 3: LẬP TRÌNH & KIỂM THỬ (TDD)                    │
 │ • superpowers:test-driven-development (Viết test trước)    │
 │ • superpowers:executing-plans         (Code theo kế hoạch) │
 │ • superpowers:systematic-debugging    (Khi gặp lỗi/bug)     │
 └──────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
 ┌─────────────────────────────────────────────────────────────┐
 │ GIAI ĐOẠN 4: ĐÁNH GIÁ & HOÀN TẤT                           │
 │ • superpowers:verification-before-completion (Chạy test)    │
 │ • superpowers:requesting-code-review         (Audit code)   │
 │ • evolve                                     (Ghi nhận học) │
 └─────────────────────────────────────────────────────────────┘
```

---

### Chi Tiết Từng Giai Đoạn & Kỹ Năng Bắt Buộc

#### 🎯 Giai Đoạn 1: Lập Kế Hoạch & Kiến Trúc
- **Khi nào áp dụng**: Bắt đầu tính năng mới, tái cấu trúc mã nguồn, hoặc tác vụ nhiều bước.
- **Kỹ năng gọi tự động**:
  1. `superpowers:brainstorming`: Đặt câu hỏi làm rõ các điểm mơ hồ, đưa ra các phương án giải quyết và so sánh ưu/nhược điểm.
  2. `superpowers:writing-plans`: Viết implementation plan chi tiết, chia nhỏ thành các task có thể kiểm chứng độc lập.
  3. `harness`: Khi bài toán đòi hỏi chia nhỏ công việc cho các chuyên gia/agent chuyên biệt (Database Specialist, UI Specialist, Security QA).

#### 🎨 Giai Đoạn 2: Chuẩn Hóa UI/UX & Design System
- **Khi nào áp dụng**: Mọi tác vụ liên quan đến màn hình, widget, component Frontend.
- **Kỹ năng gọi tự động**:
  1. `ui-ux-pro-max`: Tra cứu và áp dụng đúng phong cách du lịch thông minh hiện đại: visual-first, storytelling-driven, card-based, thumb-friendly.
  2. `design-system` & `ui-styling`:
     - **Màu sắc**: Bắt buộc dùng `AppColors` (`core/constants/app_colors.dart`), không hard-code mã màu hex ngẫu nhiên.
     - **Khoảng cách**: Dùng `AppDimensions` (`core/constants/app_dimensions.dart` với hệ spacing 4, 8, 12, 16, 24, 32, 48).
     - **Typography**: Dùng `AppTheme` (`core/theme/app_theme.dart`).
     - **Tái sử dụng**: Dùng các component đã chuẩn hóa trong `Frontend/lib/shared/widgets/` (`TourismCard`, `DestinationCard`, `PrimaryButton`, `CategoryChip`, `TourismSearchBar`, v.v.).

#### 💻 Giai Đoạn 3: Lập Trình & Sửa Lỗi (Implementation & Debugging)
- **Khi nào áp dụng**: Khi bắt tay vào viết code hoặc điều tra lỗi.
- **Kỹ năng gọi tự động**:
  1. `superpowers:test-driven-development`: Viết test cases trước khi viết code logic (Red $\rightarrow$ Green $\rightarrow$ Refactor).
  2. `superpowers:executing-plans`: Thực hiện tuần tự từng task trong plan, không nhảy cóc.
  3. `superpowers:systematic-debugging`: Khi gặp lỗi, **tuyệt đối không đoán mò hay sửa hú họa**. Phải thực hiện đủ 4 pha:
     - *Pha 1*: Thu thập đầy đủ log, stack trace và trạng thái lỗi.
     - *Pha 2*: Tái hiện lỗi ổn định.
     - *Pha 3*: Tìm nguyên nhân gốc rễ (Root Cause Analysis).
     - *Pha 4*: Đưa ra bản vá tối thiểu và kiểm chứng lại.

#### 🛡️ Giai Đoạn 4: Kiểm Định Thực Tế & Code Review
- **Khi nào áp dụng**: Trước khi thông báo cho người dùng là công việc đã xong.
- **Kỹ năng gọi tự động**:
  1. `superpowers:verification-before-completion`: **Evidence before assertions** — Chạy lệnh build/test thực tế (`flutter test`, `npm run build`, `docker-compose config`, v.v.) và xác nhận kết quả exit code 0 trước khi tuyên bố thành công.
  2. `superpowers:requesting-code-review`: Tự rà soát mã nguồn về:
     - Tuân thủ Clean Architecture 3 tầng (`data`, `domain`, `presentation`).
     - Bảo mật client-server (không ghi trực tiếp vào các trường nhạy cảm `role`, `loyaltyPoints`, `voteCount` theo `LI-07`).
     - Tối ưu hiệu năng, memory leak, dispose controller, streams.
  3. `evolve`: Khi có phản hồi từ người dùng hoặc mentor, cập nhật lại quy trình để các phiên sau vận hành tốt hơn.

---

## 3. Quy Ước Ngôn Ngữ & Giao Tiếp

1. **Giao tiếp với Người Dùng**: Luôn trả lời bằng **Tiếng Việt**, rõ ràng, lịch sự, đúng trọng tâm kỹ thuật, giải thích minh bạch các bước đã làm.
2. **Mã Nguồn & Git**:
   - Tên biến, hàm, class: Tiếng Anh chuẩn mực (camelCase, PascalCase).
   - Commit messages: Theo chuẩn Conventional Commits (`feat: ...`, `fix: ...`, `docs: ...`, `refactor: ...`).
   - Đường dẫn liên kết: Luôn tạo markdown link có thể nhấp được (`[tên_file](file:///đường/dẫn)`).
