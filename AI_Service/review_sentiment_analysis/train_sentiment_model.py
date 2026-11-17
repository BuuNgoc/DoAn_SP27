#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
NHS360 – Smart Travel Ngũ Hành Sơn
Vietnamese Tourism Review Sentiment & Moderation AI Model (FE-10)
================================================================================
Mô hình phân tích cảm xúc đánh giá (Tích cực / Trung tính / Tiêu cực) và phát hiện
từ khóa vi phạm quy chuẩn kiểm duyệt nội dung du lịch.
"""

import os
import sys
import json
import argparse
from pathlib import Path

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

sys.path.append(str(Path(__file__).resolve().parent.parent))
from shared.tflite_utils import export_tflite_models
from shared.visualization import plot_training_history

sys.stdout.reconfigure(encoding='utf-8')

# Tập dữ liệu mẫu ngữ cảnh du lịch Ngũ Hành Sơn
SAMPLE_TRAINING_DATA = [
    # POSITIVE (2)
    ("Động Huyền Không cột nắng chiếu xuống quá đẹp, cảnh sắc hùng vĩ", 2),
    ("Chùa Linh Ứng rất thanh tịnh, view nhìn ra biển Non Nước tuyệt vời", 2),
    ("Workshop làng đá rất thú vị, nghệ nhân chỉ dẫn cực kỳ tận tình", 2),
    ("Bãi biển Sơn Thủy sạch sẽ, cát trắng, có cứu hộ an tâm tắm", 2),
    ("Mì quảng ở chân núi ngon đậm đà, giá cả rất hợp lý", 2),
    ("Động Âm Phủ không gian mát lạnh, nhũ đá tự nhiên rất ấn tượng", 2),
    ("Trải nghiệm tuyệt vời, đáng để quay lại nhiều lần", 2),
    ("Nhân viên hướng dẫn nhiệt tình, thang máy lên núi rất tiện lợi", 2),

    # NEUTRAL (1)
    ("Núi Thủy Sơn bậc đá hơi dốc, người lớn tuổi nên đi thang máy", 1),
    ("Giá vé 40k tham quan bình thường, không quá đắt", 1),
    ("Quán ăn đông vào buổi trưa, phải chờ khoảng 15 phút", 1),
    ("Thời tiết buổi trưa nắng gắt, nên đi vào sáng sớm", 1),
    ("Bãi gửi xe hơi xa một chút nhưng chấp nhận được", 1),

    # NEGATIVE (0)
    ("Bậc thang trơn trượt nguy hiểm không có biển cảnh báo rõ", 0),
    ("Chèo kéo mua đá lưu niệm ở chân núi quá mức phiền phức", 0),
    ("Giá nước uống chặt chém quá đắt so với quy định", 0),
    ("Vệ sinh ở khu vực chân núi chưa được dọn dẹp sạch", 0),
    ("Thái độ nhân viên bảo vệ không thân thiện, rất thất vọng", 0),
    ("Đông đúc chen lấn xô đẩy nhau, trải nghiệm rất tệ", 0),
]

VOCAB_SIZE = 1000
MAX_LEN = 50
EMBEDDING_DIM = 64

def build_nlp_model():
    text_vectorizer = layers.TextVectorization(
        max_tokens=VOCAB_SIZE,
        output_mode='int',
        output_sequence_length=MAX_LEN
    )
    # Fit vectorizer on sample sentences
    texts = [item[0] for item in SAMPLE_TRAINING_DATA]
    text_vectorizer.adapt(tf.data.Dataset.from_tensor_slices(texts).batch(len(texts)))

    inputs = keras.Input(shape=(1,), dtype=tf.string)
    x = text_vectorizer(inputs)
    x = layers.Embedding(VOCAB_SIZE, EMBEDDING_DIM)(x)
    x = layers.GlobalAveragePooling1D()(x)
    x = layers.Dense(32, activation='relu')(x)
    x = layers.Dropout(0.2)(x)
    outputs = layers.Dense(3, activation='softmax', name="sentiment")(x)

    model = keras.Model(inputs, outputs, name="Tourism_Review_Sentiment_Model")
    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    return model

def main():
    parser = argparse.ArgumentParser(description="Huấn luyện mô hình Phân tích Cảm xúc Review (FE-10)")
    parser.add_argument("--output_dir", type=str, default="exported_model", help="Thư mục xuất TFLite")
    parser.add_argument("--epochs", type=int, default=30, help="Số epochs")
    args = parser.parse_args()

    print("[*] Đang xây dựng mô hình NLP phân tích cảm xúc du lịch...")
    model = build_nlp_model()

    texts = [item[0] for item in SAMPLE_TRAINING_DATA]
    labels = [item[1] for item in SAMPLE_TRAINING_DATA]

    # Nhân bản tập dữ liệu nhỏ để huấn luyện
    texts_expanded = texts * 15
    labels_expanded = labels * 15

    history = model.fit(
        tf.constant(texts_expanded),
        tf.constant(labels_expanded),
        epochs=args.epochs,
        batch_size=16,
        verbose=1
    )

    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Lưu danh mục nhãn
    sentiment_labels = ["NEGATIVE (Tiêu cực)", "NEUTRAL (Trung tính)", "POSITIVE (Tích cực)"]
    with open(out_dir / "sentiment_labels.txt", "w", encoding="utf-8") as f:
        for idx, lbl in enumerate(sentiment_labels):
            f.write(f"{idx}: {lbl}\n")

    # Xuất mô hình TFLite
    export_tflite_models(model, args.output_dir, base_name="review_sentiment_model")
    plot_training_history(history, str(out_dir / "sentiment_training_metrics.png"), title_prefix="ReviewSentiment")

    # Thử nghiệm câu dự đoán nhanh
    test_sentences = [
        "Động Huyền Không đẹp tuyệt vời!",
        "Chèo kéo khách du lịch phiền quá.",
        "Điểm tham quan bình thường, giá vé tạm ổn."
    ]
    preds = model.predict(tf.constant(test_sentences))
    print("\n--- KẾT QUẢ THỬ NGHIỆM DỰ ĐOÁN ---")
    for s, p in zip(test_sentences, preds):
        idx = p.argmax()
        print(f"Câu: \"{s}\" -> Cảm xúc: {sentiment_labels[idx]} (Độ tin cậy: {p[idx]*100:.1f}%)")

if __name__ == "__main__":
    main()
