#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
NHS360 – Smart Travel Ngũ Hành Sơn (SE13 - FPT University Da Nang)
Dataset Preparation & Verification Tool for Landmark Recognition
================================================================================
Công cụ hỗ trợ:
1. Khởi tạo cấu trúc thư mục cho 10 địa danh Ngũ Hành Sơn (--init).
2. Kiểm tra tính toàn vẹn của tập ảnh (--verify).
3. Tự động sinh dữ liệu ảnh mẫu (--generate_synthetic) chạy độc lập không cần thư viện ngoài.
"""

import os
import sys
import struct
import argparse
from pathlib import Path

# Thiết lập hiển thị UTF-8
sys.stdout.reconfigure(encoding='utf-8')

# Danh sách 10 địa danh Ngũ Hành Sơn chuẩn hóa
LANDMARK_CLASSES = [
    {
        "id": "dong_huyen_khong",
        "name": "Động Huyền Không",
        "destinationId": "dong_huyen_khong",
        "description": "Hang động lớn nhất núi Thủy Sơn với các cột nắng chiếu qua vòm đá",
    },
    {
        "id": "chua_tam_thai",
        "name": "Chùa Tam Thai",
        "destinationId": "chua_tam_thai",
        "description": "Ngôi quốc tự cổ thời nhà Nguyễn trên núi Thủy Sơn",
    },
    {
        "id": "chua_linh_ung",
        "name": "Chùa Linh Ứng Non Nước",
        "destinationId": "chua_linh_ung_non_nuoc",
        "description": "Ngôi chùa cổ hướng nhìn ra biển Non Nước với tượng Phật Thích Ca lớn",
    },
    {
        "id": "dong_van_thong",
        "name": "Động Vân Thông",
        "destinationId": "ngu_hanh_son",
        "description": "Hang động hình ống dẫn lên thẳng đỉnh Thượng Thai",
    },
    {
        "id": "dong_am_phu",
        "name": "Động Âm Phủ",
        "destinationId": "dong_am_phu",
        "description": "Hang động sâu dưới chân núi Thủy Sơn mô phỏng 10 tầng địa ngục",
    },
    {
        "id": "lang_da_non_nuoc",
        "name": "Làng đá Mỹ nghệ Non Nước",
        "destinationId": "lang_da_non_nuoc",
        "description": "Làng nghề truyền thống điêu khắc đá cẩm thạch hơn 400 năm tuổi",
    },
    {
        "id": "vong_giang_dai",
        "name": "Vọng Giang Đài",
        "destinationId": "ngu_hanh_son",
        "description": "Điểm vọng cảnh nhìn ra sông Cổ Cò và sông Cẩm Lệ",
    },
    {
        "id": "dinh_thuong_thai",
        "name": "Đỉnh Thượng Thai",
        "destinationId": "ngu_hanh_son",
        "description": "Đỉnh cao nhất của ngọn Thủy Sơn (106 mét so với mực nước biển)",
    },
    {
        "id": "chua_quan_the_am",
        "name": "Chùa Quán Thế Âm",
        "destinationId": "ngu_hanh_son",
        "description": "Ngôi chùa tọa lạc dưới chân núi Kim Sơn, nơi diễn ra lễ hội Quán Thế Âm",
    },
    {
        "id": "bai_bien_son_thuy",
        "name": "Bãi biển Sơn Thủy",
        "destinationId": "bai_bien_son_thuy",
        "description": "Bãi biển cát trắng mịn, nước trong xanh thuộc quận Ngũ Hành Sơn",
    },
]

def init_folders(base_dir: str):
    """Tạo thư mục cho từng địa danh nếu chưa có"""
    base = Path(base_dir)
    base.mkdir(parents=True, exist_ok=True)
    print(f"[*] Khởi tạo cấu trúc thư mục tại: {base.resolve()}")
    for item in LANDMARK_CLASSES:
        folder = base / item["id"]
        folder.mkdir(exist_ok=True)
        info_file = folder / "README_INFO.txt"
        if not info_file.exists():
            with open(info_file, "w", encoding="utf-8") as f:
                f.write(f"Địa danh: {item['name']}\n")
                f.write(f"Mã định danh: {item['id']}\n")
                f.write(f"Mô tả: {item['description']}\n")
                f.write("Hướng dẫn thu thập ảnh:\n")
                f.write("- Số lượng tối thiểu: 30 - 50 ảnh chụp thực tế.\n")
                f.write("- Chụp đa dạng góc nhìn: toàn cảnh, cận cảnh, góc nghiêng, góc thẳng.\n")
                f.write("- Chụp ở nhiều điều kiện thời tiết: sáng sớm, trưa nắng, chiều muộn.\n")
                f.write("- Định dạng được hỗ trợ: .jpg, .jpeg, .png, .bmp.\n")
    print(f"[+] Đã tạo sẵn {len(LANDMARK_CLASSES)} thư mục tương ứng 10 địa danh Ngũ Hành Sơn.")

def verify_dataset(base_dir: str):
    """Kiểm tra tính toàn vẹn của tập ảnh"""
    base = Path(base_dir)
    if not base.exists():
        print(f"[!] Thư mục {base_dir} chưa tồn tại. Hãy chạy với cờ --init trước.")
        return

    print("=" * 70)
    print("BÁO CÁO KIỂM TRA TẬP DỮ LIỆU ĐỊA DANH NGŨ HÀNH SƠN")
    print("=" * 70)

    total_images = 0
    valid_classes = 0
    corrupt_images = []

    has_pil = False
    try:
        from PIL import Image
        has_pil = True
    except ImportError:
        pass

    supported_exts = [".jpg", ".jpeg", ".png", ".bmp"]

    for item in LANDMARK_CLASSES:
        class_id = item["id"]
        folder = base / class_id
        if not folder.exists():
            print(f"[-] Thiếu thư mục: {class_id}")
            continue

        images = [f for f in folder.iterdir() if f.is_file() and f.suffix.lower() in supported_exts]
        valid_in_class = 0

        for img_path in images:
            if has_pil:
                try:
                    with Image.open(img_path) as img:
                        img.verify()
                    valid_in_class += 1
                except Exception as e:
                    corrupt_images.append((str(img_path), str(e)))
            else:
                # Kiểm tra cơ bản dung lượng file > 100 bytes
                if img_path.stat().st_size > 100:
                    valid_in_class += 1
                else:
                    corrupt_images.append((str(img_path), "File kích thước quá nhỏ/rỗng"))

        status_marker = "[OK]" if valid_in_class >= 20 else ("[WARN]" if valid_in_class > 0 else "[EMPTY]")
        print(f" {status_marker} {item['name']:<28} ({class_id}): {valid_in_class:>4} ảnh hợp lệ")

        if valid_in_class > 0:
            valid_classes += 1
            total_images += valid_in_class

    print("-" * 70)
    print(f"Tổng số ảnh hợp lệ: {total_images} ảnh trên {valid_classes}/{len(LANDMARK_CLASSES)} địa danh.")
    if corrupt_images:
        print(f"[!] Phát hiện {len(corrupt_images)} ảnh bị lỗi/hỏng:")
        for path, err in corrupt_images[:5]:
            print(f"    - {path}: {err}")
    else:
        print("[+] Không phát hiện ảnh hỏng.")

    if total_images < 50:
        print("\n[LƯU Ý] Số lượng ảnh hiện tại còn ít. Bạn có thể chạy:")
        print("    python prepare_dataset.py --generate_synthetic")
        print("để tự động sinh ảnh mẫu kiểm thử toàn bộ luồng huấn luyện & xuất TFLite ngay!")
    print("=" * 70)

def _write_bmp_pure_python(file_path: Path, width: int = 224, height: int = 224, rgb=(46, 134, 193)):
    """Tạo file ảnh BMP chuẩn 24-bit bằng pure Python (không phụ thuộc Pillow)"""
    row_size = (width * 3 + 3) & ~3
    image_size = row_size * height
    file_size = 54 + image_size
    header = struct.pack('<2sIHHI', b'BM', file_size, 0, 0, 54)
    info = struct.pack('<IIIHHIIIIII', 40, width, height, 1, 24, 0, image_size, 2835, 2835, 0, 0)
    b, g, r = rgb[2], rgb[1], rgb[0]
    row = bytes([b, g, r]) * width + b'\x00' * (row_size - width * 3)
    with open(file_path, 'wb') as f:
        f.write(header)
        f.write(info)
        for _ in range(height):
            f.write(row)

def generate_synthetic_samples(base_dir: str, num_per_class: int = 15):
    """Tự động sinh ảnh đồ họa mô phỏng (Synthetic) để kiểm thử pipeline ngay"""
    base = Path(base_dir)
    init_folders(base_dir)

    print(f"[*] Bắt đầu sinh {num_per_class} ảnh mẫu/địa danh để kiểm thử pipeline...")

    colors = [
        (46, 134, 193),   # Xanh dương
        (231, 76, 60),    # Đỏ
        (39, 174, 96),    # Xanh lá
        (243, 156, 18),   # Vàng cam
        (142, 68, 173),   # Tím
        (22, 160, 133),   # Xanh lục bảo
        (211, 84, 0),     # Cam đậm
        (127, 140, 141),  # Xám
        (52, 73, 94),     # Xanh than
        (192, 57, 43),    # Đỏ gạch
    ]

    has_pil = False
    try:
        from PIL import Image, ImageDraw
        has_pil = True
    except ImportError:
        pass

    for idx, item in enumerate(LANDMARK_CLASSES):
        class_id = item["id"]
        folder = base / class_id
        base_color = colors[idx % len(colors)]

        for i in range(num_per_class):
            ext = ".jpg" if has_pil else ".bmp"
            img_path = folder / f"synthetic_{class_id}_{i+1:03d}{ext}"
            if img_path.exists():
                continue

            # Biến tấu màu sắc nhẹ giữa các ảnh
            c_r = (base_color[0] + (i * 7)) % 256
            c_g = (base_color[1] + (i * 11)) % 256
            c_b = (base_color[2] + (i * 13)) % 256
            variant_color = (c_r, c_g, c_b)

            if has_pil:
                img = Image.new("RGB", (224, 224), color=variant_color)
                draw = ImageDraw.Draw(img)
                draw.rectangle([20, 20, 204, 204], outline=(255, 255, 255), width=3)
                draw.ellipse([40 + (i * 2) % 40, 40, 184 - (i * 2) % 40, 184], outline=(240, 240, 240), width=2)
                draw.text((25, 30), item["name"][:16], fill=(255, 255, 255))
                draw.text((25, 60), f"Sample #{i+1}", fill=(240, 240, 240))
                draw.save(img_path, format="JPEG", quality=90)
            else:
                _write_bmp_pure_python(img_path, 224, 224, variant_color)

    print(f"[+] Hoàn tất! Đã sinh {num_per_class * len(LANDMARK_CLASSES)} ảnh mẫu.")
    print("    Bây giờ bạn có thể chạy kiểm tra dataset:")
    print("    python prepare_dataset.py --verify")

def main():
    parser = argparse.ArgumentParser(description="Công cụ chuẩn bị và kiểm tra dataset Ngũ Hành Sơn")
    parser.add_argument("--dir", type=str, default="dataset", help="Thư mục chứa dataset")
    parser.add_argument("--init", action="store_true", help="Tạo cây thư mục cho 10 địa danh")
    parser.add_argument("--verify", action="store_true", help="Kiểm tra ảnh hợp lệ và ảnh lỗi")
    parser.add_argument("--generate_synthetic", action="store_true", help="Tự động sinh ảnh mẫu kiểm thử")
    parser.add_argument("--samples", type=int, default=15, help="Số ảnh mẫu mỗi lớp khi dùng --generate_synthetic")

    args = parser.parse_args()

    if args.init:
        init_folders(args.dir)
    elif args.verify:
        verify_dataset(args.dir)
    elif args.generate_synthetic:
        generate_synthetic_samples(args.dir, args.samples)
    else:
        p = Path(args.dir)
        if not p.exists():
            init_folders(args.dir)
            print("\nChạy lại với --verify để kiểm tra hoặc --generate_synthetic để sinh ảnh mẫu.")
        else:
            verify_dataset(args.dir)

if __name__ == "__main__":
    main()
