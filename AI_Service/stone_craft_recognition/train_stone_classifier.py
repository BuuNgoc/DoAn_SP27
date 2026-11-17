#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
NHS360 – Smart Travel Ngũ Hành Sơn
Non Nuoc Stone Craft Image Classifier (MobileNetV3 -> TFLite)
================================================================================
Huấn luyện mô hình nhận diện sản phẩm điêu khắc đá mỹ nghệ Non Nước (FE-15, FE-16)
"""

import os
import sys
import argparse
from pathlib import Path

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# Import shared utilities
sys.path.append(str(Path(__file__).resolve().parent.parent))
from shared.tflite_utils import export_tflite_models
from shared.visualization import plot_training_history

sys.stdout.reconfigure(encoding='utf-8')
IMG_SIZE = (224, 224)

def parse_args():
    parser = argparse.ArgumentParser(description="Huấn luyện mô hình Đá Mỹ Nghệ Non Nước")
    parser.add_argument("--dataset_dir", type=str, default="dataset", help="Thư mục dataset")
    parser.add_argument("--output_dir", type=str, default="exported_model", help="Thư mục xuất TFLite")
    parser.add_argument("--epochs", type=int, default=20, help="Số epochs")
    parser.add_argument("--batch_size", type=int, default=16, help="Kích thước batch")
    return parser.parse_args()

def build_model(num_classes):
    base_model = tf.keras.applications.MobileNetV3Small(
        input_shape=(*IMG_SIZE, 3),
        include_top=False,
        weights='imagenet',
        pooling='avg'
    )
    base_model.trainable = False

    data_augmentation = keras.Sequential([
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.1),
        layers.RandomZoom(0.1),
    ])

    inputs = keras.Input(shape=(*IMG_SIZE, 3))
    x = data_augmentation(inputs)
    x = tf.keras.applications.mobilenet_v3.preprocess_input(x)
    x = base_model(x, training=False)
    x = layers.Dense(128, activation='relu')(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(num_classes, activation='softmax', name="stone_classes")(x)

    model = keras.Model(inputs, outputs, name="NonNuoc_StoneCraft_Classifier")
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=1e-3),
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    return model

def main():
    args = parse_args()
    data_path = Path(args.dataset_dir)
    if not data_path.exists():
        print(f"[!] Lỗi: Thư mục dataset '{args.dataset_dir}' chưa tồn tại.")
        sys.exit(1)

    train_ds = tf.keras.utils.image_dataset_from_directory(
        args.dataset_dir,
        validation_split=0.2,
        subset="training",
        seed=42,
        image_size=IMG_SIZE,
        batch_size=args.batch_size,
        label_mode='categorical'
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        args.dataset_dir,
        validation_split=0.2,
        subset="validation",
        seed=42,
        image_size=IMG_SIZE,
        batch_size=args.batch_size,
        label_mode='categorical'
    )

    class_names = train_ds.class_names
    print(f"[*] Tìm thấy {len(class_names)} thể loại đá mỹ nghệ: {class_names}")

    model = build_model(len(class_names))
    history = model.fit(train_ds, validation_data=val_ds, epochs=args.epochs)

    # Lưu nhãn
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    with open(out_dir / "stone_labels.txt", "w", encoding="utf-8") as f:
        for c in class_names:
            f.write(f"{c}\n")

    # Xuất mô hình qua shared utility
    export_tflite_models(model, args.output_dir, base_name="non_nuoc_stone_model")
    plot_training_history(history, str(out_dir / "stone_training_metrics.png"), title_prefix="StoneCraft")
    print("[+] Hoàn tất huấn luyện mô hình Đá mỹ nghệ Non Nước!")

if __name__ == "__main__":
    main()
