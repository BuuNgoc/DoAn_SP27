# 💬 NHS360 – Phân Tích Cảm Xúc Đánh Giá & Kiểm Duyệt Nội Dung

Mô hình NLP học máy phân loại cảm xúc đánh giá của du khách phục vụ tính năng **Đánh giá & Xếp hạng (`FE-10`)** và hỗ trợ Ban Quản lý phát hiện kịp thời các phản hồi tiêu cực/khiếu nại.

### Phân loại cảm xúc:
- `0: NEGATIVE` (Tiêu cực / Phàn nàn / Đề xuất cải thiện khẩn cấp)
- `1: NEUTRAL` (Trung tính / Nhận xét thông thường)
- `2: POSITIVE` (Tích cực / Khen ngợi dịch vụ và cảnh quan)

### Hướng dẫn chạy:
```bash
python train_sentiment_model.py --epochs 30
```
Mô hình đầu ra: `exported_model/review_sentiment_model.tflite` và `sentiment_labels.txt`.
