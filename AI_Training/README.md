# 🤖 NHS360 – Hướng Dẫn Huấn Luyện AI Tự Nhận Diện Địa Danh Ngũ Hành Sơn

> **Dành cho Đội ngũ Phát triển & Ban Đánh giá Khóa luận SE13 (FPT University Da Nang)**  
> Giải pháp nhận diện địa danh du lịch **On-Device (trên thiết bị)** bằng **TensorFlow / Keras & TensorFlow Lite**, hoàn toàn **không phụ thuộc vào Cloud API trả phí bên ngoài** (Gemini Vision, Google Cloud Vision).

---

## 1. Tổng Quan Kiến Trúc

Hệ thống nhận diện địa danh du lịch trong đồ án **NHS360** được thiết kế theo mô hình **On-Device Edge AI**:
- **Trích xuất đặc trưng**: Sử dụng mạng nơ-ron tích chập nhẹ **MobileNetV3-Small** đã được tiền huấn luyện trên ImageNet (1.4 triệu ảnh).
- **Phân loại chuyên biệt**: Transfer Learning với 2 tầng Dense tùy biến (256 và 128 units, Dropout 0.4/0.2, Batch Normalization) học 10 lớp địa danh tại Ngũ Hành Sơn.
- **Tối ưu hóa thiết bị di động**: Chuyển đổi mô hình sang chuẩn **TensorFlow Lite (`.tflite`)** với dung lượng nhỏ (~6-9 MB), thời gian suy luận dưới 80ms trên điện thoại, chạy ngoại tuyến (offline) không tốn chi phí server hay cước API.

---

## 2. Danh Sách 10 Địa Danh Chuẩn Hóa

Mỗi địa danh trong tập huấn luyện được ánh xạ trực tiếp đến một ID trong hệ cơ sở dữ liệu `destinations` của ứng dụng:

| STT | Tên Thư Mục (Class ID) | Tên Địa Danh Tiếng Việt | Destination ID trong App |
|:---:|:---|:---|:---|
| 1 | `dong_huyen_khong` | Động Huyền Không | `dong_huyen_khong` |
| 2 | `chua_tam_thai` | Chùa Tam Thai | `chua_tam_thai` |
| 3 | `chua_linh_ung` | Chùa Linh Ứng Non Nước | `chua_linh_ung_non_nuoc` |
| 4 | `dong_van_thong` | Động Vân Thông | `ngu_hanh_son` |
| 5 | `dong_am_phu` | Động Âm Phủ | `dong_am_phu` |
| 6 | `lang_da_non_nuoc` | Làng đá Mỹ nghệ Non Nước | `lang_da_non_nuoc` |
| 7 | `vong_giang_dai` | Vọng Giang Đài | `ngu_hanh_son` |
| 8 | `dinh_thuong_thai` | Đỉnh Thượng Thai | `ngu_hanh_son` |
| 9 | `chua_quan_the_am` | Chùa Quán Thế Âm | `ngu_hanh_son` |
| 10 | `bai_bien_son_thuy` | Bãi biển Sơn Thủy | `bai_bien_son_thuy` |

---

## 3. Hướng Dẫn Thu Thập & Chuẩn Bị Bộ Ảnh (Dataset)

Để mô hình đạt độ chính xác thực tế cao nhất:
1. **Số lượng khuyến nghị**: Tối thiểu **30 – 50 ảnh/địa danh** (tổng tập ảnh: 300 – 500 ảnh).
2. **Đa dạng góc chụp**:
   - Toàn cảnh (mặt tiền cổng chùa, vòm hang động, bãi cát nhìn từ xa).
   - Trung cảnh (chính điện, bia ký Ma nhai, tượng Phật, cửa động).
   - Cận cảnh các chi tiết hoa văn, biển ngạch chữ Hán - Nôm, bậc thang đá.
3. **Đa dạng ánh sáng**: Chụp buổi sáng sớm (cột nắng động Huyền Không), trưa nắng gắt và chiều muộn.
4. **Định dạng hợp lệ**: `.jpg`, `.jpeg`, `.png`.

---

## 4. Cách Sử Dụng Bộ Công Cụ Python

### Bước 1: Khởi tạo cấu trúc thư mục
Chạy lệnh sau để tự động tạo 10 thư mục địa danh:
```bash
python prepare_dataset.py --init
```

### Bước 2: Kiểm tra dữ liệu (Sanity Check)
Sau khi copy ảnh vào các thư mục tương ứng, chạy lệnh kiểm tra xem có ảnh nào bị lỗi file không:
```bash
python prepare_dataset.py --verify
```

*(Tùy chọn)* Nếu muốn **kiểm thử ngay pipeline mà chưa có ảnh thực tế**, bạn có thể tạo tập ảnh mẫu tự động:
```bash
python prepare_dataset.py --generate_synthetic --samples 25
```

---

## 5. Tiến Hành Huấn Luyện (Training)

### Lựa Chọn A: Huấn Luyện Miễn Phí trên Google Colab (Khuyên Dùng)
1. Truy cập [Google Colab](https://colab.research.google.com/).
2. Chọn **File -> Upload notebook** và tải file `train_on_google_colab.ipynb` lên.
3. Chọn menu **Runtime -> Change runtime type -> T4 GPU**.
4. Chạy tuần tự các ô lệnh từ trên xuống dưới (chỉ mất ~3 - 5 phút).
5. Cuối notebook, Colab sẽ tự động tải 2 file về máy:
   - `ngu_hanh_son_model.tflite`
   - `labels.txt`

### Lựa Chọn B: Huấn Luyện Trực Tiếp Trên Máy Cá Nhân (Local)
Cài đặt thư viện:
```bash
pip install -r requirements.txt
```
Chạy script huấn luyện:
```bash
python train_landmark_classifier.py --dataset_dir dataset --epochs 25 --batch_size 32
```
Kết quả huấn luyện và xuất file sẽ được lưu tại thư mục `exported_model/`:
- `ngu_hanh_son_model.tflite` (Mô hình Float32 chuẩn)
- `ngu_hanh_son_model_quant_f16.tflite` (Mô hình nén FP16 nhẹ gấp đôi)
- `labels.txt` (Danh sách 10 nhãn địa danh)
- `training_metrics.png` (Biểu đồ độ chính xác & tổn thất)
- `model_metadata.json` (Thông số cấu hình mô hình)

---

## 6. Tích Hợp Vào Ứng Dụng Flutter Mobile

Sau khi có file mô hình đã huấn luyện:
1. Copy file `ngu_hanh_son_model.tflite` và `labels.txt` vào thư mục:
   ```
   Mobile/assets/models/
   ```
2. Mở ứng dụng, vào chức năng **AI Photo Recognition**:
   - Chụp ảnh hoặc chọn ảnh từ thư viện.
   - Nhấn **"Nhận diện ngay"**.
   - Ứng dụng sẽ nạp mô hình, phân tích các đặc trưng thị giác và hiển thị tên địa danh, độ tin cậy phần trăm kèm nút bấm dẫn thẳng sang màn hình **Chi tiết điểm đến**!
