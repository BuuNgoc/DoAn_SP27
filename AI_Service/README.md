# 🧠 NHS360 – Trung Tâm Huấn Luyện AI (AI Service Hub)

> **Khóa Luận Tốt Nghiệp SE13 – Smart Travel Ngũ Hành Sơn (FPT University Da Nang)**  
> Thư mục trung tâm quản lý toàn bộ các mô hình học máy (Machine Learning / Deep Learning / NLP) được tự huấn luyện (Self-Trained) phục vụ hệ sinh thái du lịch thông minh Ngũ Hành Sơn, hoàn toàn **không phụ thuộc vào Cloud API thương mại trả phí**.

---

## 1. Cấu Trúc Tổng Thể

```
AI_Service/
├── requirements.txt                  # Danh mục thư viện Python dùng chung (TensorFlow, Pillow, Matplotlib, v.v.)
├── .gitignore                        # Loại bỏ dataset thô, file trọng số .tflite, cache
├── README.md                         # Tài liệu hướng dẫn trung tâm
│
├── shared/                           # Module tiện ích dùng chung
│   ├── tflite_utils.py               # Chuyển đổi và tối ưu hóa mô hình TFLite (Float32 & Float16)
│   └── visualization.py              # Xuất biểu đồ Accuracy, Loss, Confusion Matrix
│
├── landmark_recognition/             # [MODEL 1 - FE-05] Nhận diện 10 Địa danh Ngũ Hành Sơn
│   ├── prepare_dataset.py            # Khởi tạo cây thư mục, kiểm tra ảnh, sinh dữ liệu mẫu
│   ├── train_landmark_classifier.py  # Huấn luyện MobileNetV3 Transfer Learning
│   ├── train_on_google_colab.ipynb   # Notebook Google Colab GPU T4 miễn phí 1-click
│   └── README.md                     # Hướng dẫn chi tiết
│
├── stone_craft_recognition/          # [MODEL 2 - FE-15, FE-16] Phân loại Tác phẩm Đá Mỹ nghệ Non Nước
│   ├── prepare_dataset.py            # Quản lý 5 danh mục tác phẩm điêu khắc đá
│   ├── train_stone_classifier.py     # Huấn luyện mô hình nhận diện sản phẩm đá cẩm thạch
│   └── README.md                     # Hướng dẫn chi tiết
│
└── review_sentiment_analysis/        # [MODEL 3 - FE-10] Phân tích Cảm xúc & Kiểm duyệt Đánh giá
    ├── train_sentiment_model.py      # Huấn luyện mô hình NLP phân loại cảm xúc (Tích cực/Tiêu cực/Trung tính)
    └── README.md                     # Hướng dẫn chi tiết
```

---

## 2. Bảng Tóm Tắt 3 Mô Hình AI

| Mô Hình | Thư Mục | Chức Năng Nghiệp Vụ | Kiến Trúc Thuật Toán | Thiết Bị Triển Khai |
|:---|:---|:---|:---|:---|
| **1. Landmark Vision** | `landmark_recognition/` | **`FE-05`**: Nhận diện ảnh chụp 10 địa danh Ngũ Hành Sơn và mở màn hình chi tiết điểm đến. | MobileNetV3-Small (Transfer Learning + Fine-tuning) | On-Device TFLite (Mobile App) |
| **2. Stone Craft Vision** | `stone_craft_recognition/` | **`FE-15, FE-16`**: Nhận diện thể loại tác phẩm điêu khắc đá Non Nước (Tượng Phật, Linh vật, Phù điêu, Quà lưu niệm). | MobileNetV3-Small (CNN) | On-Device TFLite (Mobile App) |
| **3. Review Sentiment** | `review_sentiment_analysis/` | **`FE-10`**: Tự động phân loại cảm xúc đánh giá du khách và cảnh báo phản hồi tiêu cực/khiếu nại. | TextVectorization + GlobalAveragePooling1D | On-Device TFLite / Local Backend Microservice |

---

## 3. Hướng Dẫn Cài Đặt Môi Trường Chung

1. **Tạo môi trường ảo Python (khuyên dùng Python 3.10 - 3.12)**:
   ```bash
   cd AI_Service
   python -m venv venv
   # Kích hoạt trên Windows:
   venv\Scripts\activate
   # Kích hoạt trên macOS/Linux:
   source venv/bin/activate
   ```

2. **Cài đặt thư viện phụ thuộc**:
   ```bash
   pip install -r requirements.txt
   ```

---

## 4. Hướng Dẫn Huấn Luyện Từng Mô Hình

### Mô hình 1: Nhận diện Địa danh (`landmark_recognition/`)
```bash
cd landmark_recognition
# Tạo cây thư mục 10 địa danh
python prepare_dataset.py --init
# (Tùy chọn) Sinh ảnh mẫu kiểm thử ngay
python prepare_dataset.py --generate_synthetic
# Huấn luyện mô hình
python train_landmark_classifier.py --epochs 25
```
*Hoặc mở file `train_on_google_colab.ipynb` trên Google Colab để train miễn phí bằng GPU T4.*

### Mô hình 2: Phân loại Tác phẩm Đá Mỹ nghệ (`stone_craft_recognition/`)
```bash
cd stone_craft_recognition
python prepare_dataset.py --generate_synthetic
python train_stone_classifier.py --epochs 20
```

### Mô hình 3: Phân tích Cảm xúc Review (`review_sentiment_analysis/`)
```bash
cd review_sentiment_analysis
python train_sentiment_model.py --epochs 30
```

---

## 5. Tích Hợp Vào Flutter Mobile (`Mobile/assets/models/`)

Mỗi khi huấn luyện xong một mô hình, các file xuất ra tại thư mục `exported_model/` gồm:
- File mô hình: `*.tflite` (và bản nén `*_quant_f16.tflite`).
- File nhãn: `*_labels.txt`.

Chỉ cần sao chép các file này vào thư mục `Mobile/assets/models/` trong dự án Flutter, ứng dụng sẽ tự động nhận diện và sử dụng ngoại tuyến ngay lập tức.
