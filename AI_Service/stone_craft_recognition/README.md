# 🪨 NHS360 – Nhận Diện Tác Phẩm Đá Mỹ Nghệ Non Nước

Mô hình học máy phân loại tác phẩm và thể loại điêu khắc đá truyền thống tại Làng đá Non Nước Ngũ Hành Sơn phục vụ tính năng **Nghệ nhân & Cuộc thi Điêu khắc (`FE-15`, `FE-16`)**.

### Danh mục nhận diện:
1. `tuong_phat_da`: Tượng Phật & Bồ Tát bằng đá cẩm thạch.
2. `linh_vat_phong_thuy`: Kỳ lân, Tỳ hưu, Rồng phong thủy.
3. `phu_dieu_hoa_van`: Tranh đá, phù điêu chạm khắc nổi.
4. `do_trang_suc_luu_niem`: Vòng tay đá, đồ lưu niệm thủ công mini.
5. `da_canh_non_bo`: Hòn non bộ & đá cảnh tự nhiên.

### Hướng dẫn sử dụng:
```bash
# 1. Khởi tạo thư mục
python prepare_dataset.py --init

# 2. Sinh ảnh mẫu test thử
python prepare_dataset.py --generate_synthetic

# 3. Huấn luyện và xuất TFLite
python train_stone_classifier.py --epochs 20
```
Mô hình đầu ra: `exported_model/non_nuoc_stone_model.tflite` và `stone_labels.txt`.
