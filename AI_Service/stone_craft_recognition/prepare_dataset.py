#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
NHS360 – Smart Travel Ngũ Hành Sơn
Dataset Preparation for Non Nuoc Stone Craft & Sculpture Classification
================================================================================
Mô hình nhận diện tác phẩm & thể loại đá mỹ nghệ Non Nước (FE-15, FE-16)
"""

import os
import sys
import struct
import argparse
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8')

# Danh mục phân loại đá mỹ nghệ Non Nước
STONE_CRAFT_CLASSES = [
    {
        "id": "tuong_phat_da",
        "name": "Tượng Phật & Bồ Tát bằng đá",
        "description": "Tượng Phật Thích Ca, Quan Âm, Di Lặc điêu khắc từ đá cẩm thạch nguyên khối",
    },
    {
        "id": "linh_vat_phong_thuy",
        "name": "Linh vật phong thủy (Kỳ lân, Tỳ hưu, Rồng)",
        "description": "Linh vật trấn trạch, chiêu tài bằng đá cẩm thạch tự nhiên Non Nước",
    },
    {
        "id": "phu_dieu_hoa_van",
        "name": "Phù điêu & Tranh đá nghệ thuật",
        "description": "Tranh chạm nổi hoa sen, tùng cúc trúc mai, rồng phượng trên phiến đá",
    },
    {
        "id": "do_trang_suc_luu_niem",
        "name": "Đồ trang sức & Quà lưu niệm mini",
        "description": "Vòng tay đá, mặt dây chuyền, móc khóa chạm khắc thủ công của nghệ nhân",
    },
    {
        "id": "da_canh_non_bo",
        "name": "Đá cảnh nghệ thuật & Hòn non bộ",
        "description": "Tác phẩm non bộ phong cảnh thu nhỏ từ đá tự nhiên Ngũ Hành Sơn",
    },
]

def init_folders(base_dir: str):
    base = Path(base_dir)
    base.mkdir(parents=True, exist_ok=True)
    print(f"[*] Khởi tạo cấu trúc thư mục Đá mỹ nghệ tại: {base.resolve()}")
    for item in STONE_CRAFT_CLASSES:
        folder = base / item["id"]
        folder.mkdir(exist_ok=True)
        info_file = folder / "README_INFO.txt"
        if not info_file.exists():
            with open(info_file, "w", encoding="utf-8") as f:
                f.write(f"Thể loại: {item['name']}\n")
                f.write(f"Mã: {item['id']}\n")
                f.write(f"Mô tả: {item['description']}\n")
    print(f"[+] Đã tạo sẵn {len(STONE_CRAFT_CLASSES)} thư mục tương ứng các thể loại tác phẩm đá mỹ nghệ.")

def generate_synthetic(base_dir: str, num_per_class: int = 10):
    base = Path(base_dir)
    init_folders(base_dir)
    print(f"[*] Sinh {num_per_class} ảnh mẫu mỗi thể loại đá mỹ nghệ...")
    colors = [(230, 230, 235), (200, 180, 160), (160, 170, 180), (140, 120, 100), (90, 95, 100)]
    for idx, item in enumerate(STONE_CRAFT_CLASSES):
        folder = base / item["id"]
        c = colors[idx % len(colors)]
        for i in range(num_per_class):
            img_path = folder / f"sample_{item['id']}_{i+1:03d}.bmp"
            if img_path.exists():
                continue
            # Pure python BMP generator
            row_size = (224 * 3 + 3) & ~3
            image_size = row_size * 224
            file_size = 54 + image_size
            header = struct.pack('<2sIHHI', b'BM', file_size, 0, 0, 54)
            info = struct.pack('<IIIHHIIIIII', 40, 224, 224, 1, 24, 0, image_size, 2835, 2835, 0, 0)
            row = bytes([c[2], c[1], c[0]]) * 224 + b'\x00' * (row_size - 224 * 3)
            with open(img_path, 'wb') as f:
                f.write(header)
                f.write(info)
                for _ in range(224):
                    f.write(row)
    print(f"[+] Hoàn tất! Đã sinh {num_per_class * len(STONE_CRAFT_CLASSES)} ảnh mẫu.")

def main():
    parser = argparse.ArgumentParser(description="Chuẩn bị dataset Đá mỹ nghệ Non Nước")
    parser.add_argument("--dir", type=str, default="dataset", help="Thư mục dataset")
    parser.add_argument("--init", action="store_true", help="Tạo thư mục")
    parser.add_argument("--generate_synthetic", action="store_true", help="Sinh ảnh mẫu")
    args = parser.parse_args()
    if args.generate_synthetic:
        generate_synthetic(args.dir)
    else:
        init_folders(args.dir)

if __name__ == "__main__":
    main()
