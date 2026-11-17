#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
================================================================================
NHS360 – Smart Travel Ngũ Hành Sơn
Shared Visualization & Metrics Plotting Utilities
================================================================================
"""

import matplotlib.pyplot as plt
from pathlib import Path

def plot_training_history(history, output_path: str = "training_metrics.png", title_prefix: str = "Model"):
    """Vẽ và lưu đồ thị Accuracy & Loss sau khi huấn luyện"""
    acc = history.history.get('accuracy', [])
    val_acc = history.history.get('val_accuracy', [])
    loss = history.history.get('loss', [])
    val_loss = history.history.get('val_loss', [])

    epochs_range = range(1, len(acc) + 1)

    plt.figure(figsize=(14, 5))

    # Đồ thị Accuracy
    plt.subplot(1, 2, 1)
    plt.plot(epochs_range, acc, 'b-', label='Train Accuracy', linewidth=2)
    plt.plot(epochs_range, val_acc, 'r--', label='Val Accuracy', linewidth=2)
    plt.title(f'{title_prefix} - Training & Validation Accuracy', fontsize=12, fontweight='bold')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy')
    plt.grid(True, linestyle='--', alpha=0.6)
    plt.legend(loc='lower right')

    # Đồ thị Loss
    plt.subplot(1, 2, 2)
    plt.plot(epochs_range, loss, 'b-', label='Train Loss', linewidth=2)
    plt.plot(epochs_range, val_loss, 'r--', label='Val Loss', linewidth=2)
    plt.title(f'{title_prefix} - Training & Validation Loss', fontsize=12, fontweight='bold')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.grid(True, linestyle='--', alpha=0.6)
    plt.legend(loc='upper right')

    plt.tight_layout()
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(output_path, dpi=300)
    plt.close()
    print(f"[+] Đã lưu biểu đồ huấn luyện: {output_path}")
