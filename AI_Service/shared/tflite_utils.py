#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
NHS360 – Smart Travel Ngũ Hành Sơn
Shared TensorFlow Lite Model Conversion & Optimization Utilities
================================================================================
"""

import os
from pathlib import Path
import tensorflow as tf

def export_tflite_models(keras_model, output_dir: str, base_name: str = "model"):
    """
    Chuyển đổi và xuất Keras model sang 2 định dạng TFLite:
    1. Float32 chuẩn (độ chính xác cao nhất).
    2. Float16 Quantization (nhẹ gấp đôi, tối ưu GPU/NPU trên điện thoại).
    """
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)
    
    results = {}

    # 1. Float32 TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(keras_model)
    tflite_f32 = converter.convert()
    f32_file = out_path / f"{base_name}.tflite"
    with open(f32_file, "wb") as f:
        f.write(tflite_f32)
    f32_size = os.path.getsize(f32_file) / (1024 * 1024)
    results["f32"] = {"path": str(f32_file), "size_mb": f32_size}
    print(f"[+] Xuất TFLite Float32: {f32_file.name} ({f32_size:.2f} MB)")

    # 2. Float16 Quantized TFLite
    converter_f16 = tf.lite.TFLiteConverter.from_keras_model(keras_model)
    converter_f16.optimizations = [tf.lite.Optimize.DEFAULT]
    converter_f16.target_spec.supported_types = [tf.float16]
    tflite_f16 = converter_f16.convert()
    f16_file = out_path / f"{base_name}_quant_f16.tflite"
    with open(f16_file, "wb") as f:
        f.write(tflite_f16)
    f16_size = os.path.getsize(f16_file) / (1024 * 1024)
    results["f16"] = {"path": str(f16_file), "size_mb": f16_size}
    print(f"[+] Xuất TFLite Float16: {f16_file.name} ({f16_size:.2f} MB - Giảm {(1 - f16_size/f32_size)*100:.1f}%)")

    return results
