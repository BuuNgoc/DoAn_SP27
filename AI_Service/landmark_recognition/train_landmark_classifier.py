#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
NHS360 – Smart Travel Ngũ Hành Sơn (SE13 - FPT University Da Nang)
Landmark Image Classification Training & TFLite Export Pipeline
================================================================================
Script tự động huấn luyện mô hình nhận diện địa danh Ngũ Hành Sơn bằng Transfer Learning
(MobileNetV3) và xuất mô hình định dạng TensorFlow Lite (.tflite) nhúng vào Flutter Mobile.
"""

import os
import sys
import json
import argparse
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# Thiết lập hiển thị UTF-8 cho console
sys.stdout.reconfigure(encoding='utf-8')

# Kích thước ảnh chuẩn của MobileNetV3
IMG_SIZE = (224, 224)
AUTOTUNE = tf.data.AUTOTUNE

def parse_args():
    parser = argparse.ArgumentParser(description="Huấn luyện mô hình nhận diện địa danh Ngũ Hành Sơn")
    parser.add_argument("--dataset_dir", type=str, default="dataset", help="Đường dẫn thư mục chứa ảnh phân loại theo từng thư mục con")
    parser.add_argument("--output_dir", type=str, default="exported_model", help="Thư mục xuất file .tflite và labels.txt")
    parser.add_argument("--epochs", type=int, default=25, help="Số epochs huấn luyện")
    parser.add_argument("--batch_size", type=int, default=32, help="Kích thước batch")
    parser.add_argument("--learning_rate", type=float, default=1e-3, help="Tốc độ học khởi tạo")
    parser.add_argument("--val_split", type=float, default=0.2, help="Tỉ lệ dữ liệu kiểm thử (Validation)")
    return parser.parse_args()

def check_dataset_structure(dataset_dir):
    """Kiểm tra cấu trúc thư mục dataset trước khi train"""
    p = Path(dataset_dir)
    if not p.exists():
        print(f"[!] LỖI: Thư mục dataset '{dataset_dir}' không tồn tại!")
        print("    Vui lòng tạo thư mục dataset với các thư mục con chứa ảnh địa danh tương ứng:")
        print("    dataset/\n    ├── dong_huyen_khong/\n    ├── chua_tam_thai/\n    ├── chua_linh_ung/\n    └── ...")
        sys.exit(1)
        
    classes = [d.name for d in p.iterdir() if d.is_dir() and not d.name.startswith('.')]
    if len(classes) < 2:
        print(f"[!] CẢNH BÁO: Thư mục dataset chỉ tìm thấy {len(classes)} lớp địa danh. Cần ít nhất 2 lớp để huấn luyện.")
        sys.exit(1)
        
    print(f"[*] Tìm thấy {len(classes)} địa danh trong dataset:")
    for idx, c in enumerate(sorted(classes)):
        num_imgs = len(list((p / c).glob('*.*')))
        print(f"    {idx+1}. {c}: {num_imgs} ảnh")
    return sorted(classes)

def build_data_augmentation():
    """Tăng cường dữ liệu (Data Augmentation) để mô hình học tốt hơn với tập ảnh nhỏ"""
    return keras.Sequential([
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.15),
        layers.RandomZoom(0.15),
        layers.RandomContrast(0.1),
        layers.RandomTranslation(0.1, 0.1),
    ], name="data_augmentation")

def build_model(num_classes, img_size=IMG_SIZE):
    """Xây dựng kiến trúc mô hình Transfer Learning trên nền tảng MobileNetV3-Small"""
    # Base model đã được pretrain trên tập dữ liệu ImageNet (1.4 triệu ảnh)
    base_model = tf.keras.applications.MobileNetV3Small(
        input_shape=(*img_size, 3),
        include_top=False,
        weights='imagenet',
        pooling='avg'
    )
    # Đóng băng các tầng trích xuất đặc trưng cơ bản
    base_model.trainable = False

    data_augmentation = build_data_augmentation()

    inputs = keras.Input(shape=(*img_size, 3))
    x = data_augmentation(inputs)
    # Tiền xử lý chuẩn hóa pixel theo MobileNetV3 [-1, 1]
    x = tf.keras.applications.mobilenet_v3.preprocess_input(x)
    x = base_model(x, training=False)

    # Classification Head cho địa danh Ngũ Hành Sơn
    x = layers.BatchNormalization()(x)
    x = layers.Dense(256, activation='relu', kernel_regularizer=keras.regularizers.l2(1e-4))(x)
    x = layers.Dropout(0.4)(x)
    x = layers.Dense(128, activation='relu')(x)
    x = layers.Dropout(0.2)(x)
    outputs = layers.Dense(num_classes, activation='softmax', name="predictions")(x)

    model = keras.Model(inputs, outputs, name="NguHanhSon_Landmark_Classifier")
    return model, base_model

def export_tflite_models(model, class_names, output_dir):
    """Xuất mô hình ra định dạng TensorFlow Lite (.tflite) tối ưu cho Mobile"""
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)

    # 1. Lưu file nhãn labels.txt
    labels_file = out_path / "labels.txt"
    with open(labels_file, "w", encoding="utf-8") as f:
        for name in class_names:
            f.write(f"{name}\n")
    print(f"\n[+] Đã lưu danh sách nhãn vào: {labels_file}")

    # 2. Xuất mô hình TFLite chuẩn (Float32)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    tflite_path = out_path / "ngu_hanh_son_model.tflite"
    with open(tflite_path, "wb") as f:
        f.write(tflite_model)
    size_mb = len(tflite_model) / (1024 * 1024)
    print(f"[+] Đã xuất mô hình TFLite (Float32): {tflite_path} ({size_mb:.2f} MB)")

    # 3. Xuất mô hình TFLite tối ưu Float16 (giảm 50% kích thước, giữ nguyên độ chính xác)
    converter_fp16 = tf.lite.TFLiteConverter.from_keras_model(model)
    converter_fp16.optimizations = [tf.lite.Optimize.DEFAULT]
    converter_fp16.target_spec.supported_types = [tf.float16]
    tflite_fp16_model = converter_fp16.convert()
    tflite_fp16_path = out_path / "ngu_hanh_son_model_fp16.tflite"
    with open(tflite_fp16_path, "wb") as f:
        f.write(tflite_fp16_model)
    size_fp16_mb = len(tflite_fp16_model) / (1024 * 1024)
    print(f"[+] Đã xuất mô hình TFLite Tối ưu (Float16): {tflite_fp16_path} ({size_fp16_mb:.2f} MB)")

    # 4. Xuất file thông số kỹ thuật model_metadata.json
    metadata = {
        "model_name": "NHS360 Landmark Classifier",
        "architecture": "MobileNetV3-Small",
        "input_shape": [1, 224, 224, 3],
        "input_type": "float32",
        "num_classes": len(class_names),
        "classes": class_names,
        "recommendation": "Copy file ngu_hanh_son_model_fp16.tflite (đổi tên thành ngu_hanh_son_model.tflite) va labels.txt vao Mobile/assets/models/"
    }
    with open(out_path / "model_metadata.json", "w", encoding="utf-8") as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)

def main():
    args = parse_args()
    print("======================================================================")
    print("  NHS360 – TIẾN TRÌNH HUẤN LUYỆN AI NHẬN DIỆN ĐỊA DANH NGŨ HÀNH SƠN")
    print("======================================================================")

    classes = check_dataset_structure(args.dataset_dir)
    num_classes = len(classes)

    print("\n[*] Đang nạp và chia tách tập dữ liệu...")
    train_ds = tf.keras.utils.image_dataset_from_directory(
        args.dataset_dir,
        validation_split=args.val_split,
        subset="training",
        seed=123,
        image_size=IMG_SIZE,
        batch_size=args.batch_size,
        label_mode="categorical"
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        args.dataset_dir,
        validation_split=args.val_split,
        subset="validation",
        seed=123,
        image_size=IMG_SIZE,
        batch_size=args.batch_size,
        label_mode="categorical"
    )

    class_names = train_ds.class_names
    train_ds = train_ds.cache().prefetch(buffer_size=AUTOTUNE)
    val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

    print(f"\n[*] Xây dựng kiến trúc mô hình MobileNetV3 ({num_classes} lớp phân loại)...")
    model, base_model = build_model(num_classes)
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=args.learning_rate),
        loss="categorical_crossentropy",
        metrics=["accuracy", tf.keras.metrics.TopKCategoricalAccuracy(k=2, name="top_2_accuracy")]
    )
    model.summary()

    callbacks = [
        keras.callbacks.EarlyStopping(monitor="val_loss", patience=6, restore_best_weights=True),
        keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=3, min_lr=1e-6),
    ]

    print(f"\n[*] Bắt đầu Phase 1: Huấn luyện Classification Head ({args.epochs} epochs)...")
    history = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs,
        callbacks=callbacks
    )

    # Phase 2: Fine-tuning một số tầng trên cùng của base model để tăng độ chính xác
    print("\n[*] Bắt đầu Phase 2: Fine-tuning chuyên sâu (Mở khóa 20 tầng cuối)...")
    base_model.trainable = True
    for layer in base_model.layers[:-20]:
        layer.trainable = False

    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=1e-4), # Learning rate nhỏ để fine-tune
        loss="categorical_crossentropy",
        metrics=["accuracy", tf.keras.metrics.TopKCategoricalAccuracy(k=2, name="top_2_accuracy")]
    )

    history_fine = model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=args.epochs + 15,
        initial_epoch=history.epoch[-1],
        callbacks=callbacks
    )

    # Đánh giá kết quả trên tập Validation
    print("\n[*] Đánh giá kết quả cuối cùng trên tập Validation:")
    eval_results = model.evaluate(val_ds)
    print(f"    - Validation Loss: {eval_results[0]:.4f}")
    print(f"    - Validation Accuracy: {eval_results[1]*100:.2f}%")
    print(f"    - Top-2 Accuracy: {eval_results[2]*100:.2f}%")

    # Xuất mô hình ra TFLite
    print("\n[*] Đang chuyển đổi và xuất mô hình TFLite cho Flutter Mobile...")
    export_tflite_models(model, class_names, args.output_dir)

    print("\n======================================================================")
    print("  HUẤN LUYỆN VÀ XUẤT MÔ HÌNH HOÀN TẤT THÀNH CÔNG!")
    print(f"  Vui lòng copy file '{args.output_dir}/ngu_hanh_son_model_fp16.tflite'")
    print("  (đổi tên thành 'ngu_hanh_son_model.tflite') và 'labels.txt'")
    print("  vào thư mục 'Mobile/assets/models/' của ứng dụng Flutter.")
    print("======================================================================")

if __name__ == "__main__":
    main()
