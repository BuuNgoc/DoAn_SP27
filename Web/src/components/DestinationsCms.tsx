import React, { useState } from 'react';
import {
  Plus,
  ClipboardCheck,
  CheckCircle,
  XCircle,
  Edit2,
  Trash2,
  Info,
  MapPin,
  ExternalLink,
} from 'lucide-react';
import { Destination } from '../types';

interface DestinationsCmsProps {
  destinations: Destination[];
  onUpdateDestinations: (items: Destination[]) => void;
  searchQuery: string;
}

export const DestinationsCms: React.FC<DestinationsCmsProps> = ({
  destinations,
  onUpdateDestinations,
  searchQuery,
}) => {
  const [selectedCategory, setSelectedCategory] = useState<string>('Tất cả');
  const [selectedQuality, setSelectedQuality] = useState<string>('Tất cả trạng thái');
  const [editingItem, setEditingItem] = useState<Destination | null>(null);
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
  const [checklistModalItem, setChecklistModalItem] = useState<Destination | null>(null);

  // Form State
  const [formData, setFormData] = useState<Partial<Destination>>({});

  const filteredDestinations = destinations.filter((d) => {
    const matchesSearch =
      d.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      d.nameEn.toLowerCase().includes(searchQuery.toLowerCase()) ||
      d.category.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesCategory =
      selectedCategory === 'Tất cả' || d.category === selectedCategory;

    let matchesQuality = true;
    if (selectedQuality === 'Đủ 100% dữ liệu') {
      matchesQuality = d.completenessScore >= 95;
    } else if (selectedQuality === 'Thiếu Audio Guide') {
      matchesQuality = !d.audioGuideUrl || d.audioGuideUrl.trim() === '';
    } else if (selectedQuality === 'Thiếu VR360') {
      matchesQuality = !d.vr360Url || d.vr360Url.trim() === '';
    } else if (selectedQuality === 'Thiếu Album ảnh') {
      matchesQuality = !d.galleryUrls || d.galleryUrls.length === 0;
    }

    return matchesSearch && matchesCategory && matchesQuality;
  });

  const handleOpenAddModal = () => {
    setEditingItem(null);
    setFormData({
      name: '',
      nameEn: '',
      category: 'Heritage',
      address: '',
      lat: 16.0048,
      lng: 108.2638,
      shortDescription: '',
      deepDescription: '',
      culturalStory: '',
      coverUrl: 'https://images.unsplash.com/photo-1599707367072-cd6ada2bc375?auto=format&fit=crop&w=800&q=80',
      galleryUrls: [],
      vr360Url: '',
      audioGuideUrl: '',
      videoUrl: '',
      openingHours: '07:00 - 17:30',
      ticketPrice: '40.000 VNĐ',
      targetAudience: 'Du khách tham quan',
      suggestedDuration: 60,
      tourRoute: 'Tuyến Di Sản',
      hashtags: ['#NguHanhSon', '#DaNang'],
      rating: 5.0,
      isPublished: true,
      completenessScore: 70,
    });
    setIsModalOpen(true);
  };

  const handleOpenEditModal = (item: Destination) => {
    setEditingItem(item);
    setFormData({ ...item });
    setIsModalOpen(true);
  };

  const handleSaveDestination = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name) return;

    // Calculate completeness score
    let score = 0;
    if (formData.name) score += 10;
    if (formData.lat && formData.lng) score += 15;
    if (formData.shortDescription && formData.deepDescription) score += 15;
    if (formData.culturalStory) score += 10;
    if (formData.coverUrl) score += 10;
    if (formData.galleryUrls && formData.galleryUrls.length > 0) score += 10;
    if (formData.vr360Url && formData.vr360Url.trim() !== '') score += 15;
    if (formData.audioGuideUrl && formData.audioGuideUrl.trim() !== '') score += 10;
    if (formData.hashtags && formData.hashtags.length > 0) score += 5;

    if (editingItem) {
      const updated = destinations.map((d) =>
        d.id === editingItem.id ? ({ ...d, ...formData, completenessScore: score } as Destination) : d,
      );
      onUpdateDestinations(updated);
    } else {
      const newItem: Destination = {
        ...(formData as Destination),
        id: `dest_${Date.now()}`,
        completenessScore: score,
      };
      onUpdateDestinations([newItem, ...destinations]);
    }
    setIsModalOpen(false);
  };

  const handleDelete = (id: string) => {
    if (window.confirm('Bạn có chắc chắn muốn xóa điểm đến này khỏi cơ sở dữ liệu?')) {
      onUpdateDestinations(destinations.filter((d) => d.id !== id));
    }
  };

  const getCategoryBadgeClass = (category: string) => {
    switch (category) {
      case 'Heritage':
        return 'bg-[#EBF2EF] text-[#173F35] border-[#173F35]/20';
      case 'Beach':
        return 'bg-[#E0F2FE] text-[#0284C7] border-[#0284C7]/20';
      case 'Craft Village':
        return 'bg-[#FEF3C7] text-[#D97706] border-[#D97706]/20';
      case 'Food':
        return 'bg-[#FEE2E2] text-[#DC2626] border-[#DC2626]/20';
      case 'Event':
        return 'bg-[#EDE9FE] text-[#7C3AED] border-[#7C3AED]/20';
      default:
        return 'bg-[#F1F5F9] text-[#475569] border-[#475569]/20';
    }
  };

  const getScoreColor = (score: number) => {
    if (score >= 90) return 'text-[#16A34A] bg-[#DCFCE7]';
    if (score >= 70) return 'text-[#D97706] bg-[#FEF3C7]';
    return 'text-[#DC2626] bg-[#FEE2E2]';
  };

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Cơ Sở Dữ Liệu Điểm Đến Chuẩn Hóa (FE-17, Epic 1)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Quản trị chuẩn hóa: VR360, Audio thuyết minh, Tọa độ GPS, Câu chuyện văn hóa & Bộ đo lường Data Quality
          </p>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={() => setChecklistModalItem(destinations[0])}
            className="px-3.5 py-2 border border-[#173F35] text-[#173F35] hover:bg-[#EBF2EF] rounded-lg text-xs font-bold transition-all flex items-center space-x-1.5"
          >
            <span>Quy Chuẩn Data Quality</span>
          </button>
          <button
            onClick={handleOpenAddModal}
            className="px-4 py-2 bg-[#173F35] hover:bg-[#244C40] text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center space-x-1.5"
          >
            <Plus className="w-4 h-4" />
            <span>Thêm Điểm Đến Mới</span>
          </button>
        </div>
      </div>

      {/* ── Filters ──────────────────────────────────────────────────────── */}
      <div className="flex flex-wrap items-center justify-between gap-4 pt-2 border-t border-[#F1F5F9]">
        <div className="flex items-center space-x-4 text-xs font-semibold">
          <div className="flex items-center space-x-2">
            <span className="text-[#64748B]">Phân loại:</span>
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="bg-[#F8FAFC] border border-[#E2E8F0] px-3 py-1.5 rounded-lg text-xs font-bold text-[#0F172A] focus:outline-none focus:ring-1 focus:ring-[#173F35]"
            >
              {['Tất cả', 'Heritage', 'Beach', 'Craft Village', 'Food', 'Event', 'Workshop', 'Hotel'].map(
                (c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ),
              )}
            </select>
          </div>

          <div className="flex items-center space-x-2">
            <span className="text-[#64748B]">Chất lượng dữ liệu:</span>
            <select
              value={selectedQuality}
              onChange={(e) => setSelectedQuality(e.target.value)}
              className="bg-[#F8FAFC] border border-[#E2E8F0] px-3 py-1.5 rounded-lg text-xs font-bold text-[#0F172A] focus:outline-none focus:ring-1 focus:ring-[#173F35]"
            >
              {[
                'Tất cả trạng thái',
                'Đủ 100% dữ liệu',
                'Thiếu Audio Guide',
                'Thiếu VR360',
                'Thiếu Album ảnh',
              ].map((q) => (
                <option key={q} value={q}>
                  {q}
                </option>
              ))}
            </select>
          </div>
        </div>

        <span className="text-xs text-[#94A3B8]">
          Hiển thị <strong>{filteredDestinations.length}</strong> / {destinations.length} điểm đến
        </span>
      </div>

      {/* ── Table ────────────────────────────────────────────────────────── */}
      <div className="overflow-x-auto border border-[#E2E8F0] rounded-xl">
        <table className="w-full text-left text-sm">
          <thead className="bg-[#F8FAFC] border-b border-[#E2E8F0] text-xs font-extrabold text-[#475569] uppercase tracking-wider">
            <tr>
              <th className="py-3 px-4">Tên Điểm Đến</th>
              <th className="py-3 px-4">Phân Loại</th>
              <th className="py-3 px-4">Tọa Độ GPS</th>
              <th className="py-3 px-4 text-center">VR360</th>
              <th className="py-3 px-4 text-center">Audio</th>
              <th className="py-3 px-4">Độ Đầy Đủ (Quality)</th>
              <th className="py-3 px-4 text-right">Thao Tác</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#E2E8F0]">
            {filteredDestinations.map((d) => (
              <tr key={d.id} className="hover:bg-[#F8FAFC] transition-colors">
                <td className="py-3 px-4">
                  <div className="flex items-center space-x-3">
                    <img
                      src={d.coverUrl}
                      alt={d.name}
                      className="w-11 h-11 rounded-lg object-cover bg-[#E2E8F0] shrink-0 border border-[#E2E8F0]"
                    />
                    <div>
                      <div className="font-extrabold text-[#0F172A] text-sm">{d.name}</div>
                      <div className="text-xs text-[#64748B]">{d.nameEn}</div>
                    </div>
                  </div>
                </td>
                <td className="py-3 px-4">
                  <span
                    className={`inline-block px-2.5 py-0.5 rounded-full text-xs font-extrabold border ${getCategoryBadgeClass(
                      d.category,
                    )}`}
                  >
                    {d.category}
                  </span>
                </td>
                <td className="py-3 px-4 text-xs font-mono text-[#475569]">
                  {d.lat.toFixed(4)}, {d.lng.toFixed(4)}
                </td>
                <td className="py-3 px-4 text-center">
                  {d.vr360Url ? (
                    <CheckCircle className="w-4 h-4 text-[#16A34A] mx-auto" />
                  ) : (
                    <XCircle className="w-4 h-4 text-[#94A3B8] mx-auto" />
                  )}
                </td>
                <td className="py-3 px-4 text-center">
                  {d.audioGuideUrl ? (
                    <CheckCircle className="w-4 h-4 text-[#16A34A] mx-auto" />
                  ) : (
                    <XCircle className="w-4 h-4 text-[#94A3B8] mx-auto" />
                  )}
                </td>
                <td className="py-3 px-4">
                  <div className="w-36">
                    <div className="flex items-center justify-between text-xs mb-1">
                      <span className={`px-1.5 py-0.5 rounded text-[10px] font-extrabold ${getScoreColor(d.completenessScore)}`}>
                        {d.completenessScore}%
                      </span>
                      {d.completenessScore < 100 && (
                        <span className="text-[10px] text-[#D97706] font-semibold">Cần bổ sung</span>
                      )}
                    </div>
                    <div className="w-full bg-[#E2E8F0] rounded-full h-1.5 overflow-hidden">
                      <div
                        className={`h-1.5 rounded-full ${
                          d.completenessScore >= 90
                            ? 'bg-[#16A34A]'
                            : d.completenessScore >= 70
                            ? 'bg-[#D97706]'
                            : 'bg-[#DC2626]'
                        }`}
                        style={{ width: `${d.completenessScore}%` }}
                      ></div>
                    </div>
                  </div>
                </td>
                <td className="py-3 px-4 text-right">
                  <div className="flex items-center justify-end space-x-2">
                    <button
                      onClick={() => handleOpenEditModal(d)}
                      title="Chỉnh sửa chi tiết"
                      className="p-1.5 text-[#173F35] hover:bg-[#EBF2EF] rounded-md transition-colors"
                    >
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => setChecklistModalItem(d)}
                      title="Xem chấm điểm Data Completeness"
                      className="p-1.5 text-[#D97706] hover:bg-[#FEF3C7] rounded-md transition-colors"
                    >
                      <Info className="w-4 h-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(d.id)}
                      title="Xóa điểm đến"
                      className="p-1.5 text-[#DC2626] hover:bg-[#FEE2E2] rounded-md transition-colors"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* ── Modal Add / Edit Destination ─────────────────────────────────── */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-hidden flex flex-col shadow-2xl">
            {/* Modal Header */}
            <div className="p-5 border-b border-[#E2E8F0] flex items-center justify-between">
              <h4 className="font-extrabold text-[#0F172A] text-base">
                {editingItem ? `Chỉnh Sửa Điểm Đến: ${editingItem.name}` : 'Thêm Điểm Đến Chuẩn Hóa Mới (Epic 1)'}
              </h4>
              <button
                onClick={() => setIsModalOpen(false)}
                className="text-[#64748B] hover:text-[#0F172A] font-bold text-sm"
              >
                Đóng
              </button>
            </div>

            {/* Modal Body */}
            <form onSubmit={handleSaveDestination} className="p-6 overflow-y-auto space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">
                    Tên Điểm Đến (Tiếng Việt) *
                  </label>
                  <input
                    type="text"
                    required
                    value={formData.name || ''}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">
                    Tên Tiếng Anh (English Name)
                  </label>
                  <input
                    type="text"
                    value={formData.nameEn || ''}
                    onChange={(e) => setFormData({ ...formData, nameEn: e.target.value })}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">Phân Loại Chuẩn *</label>
                  <select
                    value={formData.category || 'Heritage'}
                    onChange={(e) =>
                      setFormData({ ...formData, category: e.target.value as any })
                    }
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none font-semibold"
                  >
                    {['Heritage', 'Beach', 'Craft Village', 'Food', 'Event', 'Workshop', 'Hotel'].map(
                      (c) => (
                        <option key={c} value={c}>
                          {c}
                        </option>
                      ),
                    )}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">Vĩ Độ (Latitude) *</label>
                  <input
                    type="number"
                    step="0.0001"
                    required
                    value={formData.lat ?? 16.0048}
                    onChange={(e) => setFormData({ ...formData, lat: parseFloat(e.target.value) })}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none font-mono"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">Kinh Độ (Longitude) *</label>
                  <input
                    type="number"
                    step="0.0001"
                    required
                    value={formData.lng ?? 108.2638}
                    onChange={(e) => setFormData({ ...formData, lng: parseFloat(e.target.value) })}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none font-mono"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Địa Chỉ Thực Địa</label>
                <input
                  type="text"
                  value={formData.address || ''}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Mô Tả Ngắn (Card summary) *</label>
                <textarea
                  rows={2}
                  value={formData.shortDescription || ''}
                  onChange={(e) => setFormData({ ...formData, shortDescription: e.target.value })}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Mô Tả Sâu & Kiến Trúc Di Sản</label>
                <textarea
                  rows={2}
                  value={formData.deepDescription || ''}
                  onChange={(e) => setFormData({ ...formData, deepDescription: e.target.value })}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Câu Chuyện Văn Hóa & Lịch Sử</label>
                <textarea
                  rows={2}
                  value={formData.culturalStory || ''}
                  onChange={(e) => setFormData({ ...formData, culturalStory: e.target.value })}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">URL Ảnh Bìa (Cover Image) *</label>
                  <input
                    type="text"
                    value={formData.coverUrl || ''}
                    onChange={(e) => setFormData({ ...formData, coverUrl: e.target.value })}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">URL Ảnh Panorama VR360 (Equirectangular 2:1)</label>
                  <input
                    type="text"
                    value={formData.vr360Url || ''}
                    onChange={(e) => setFormData({ ...formData, vr360Url: e.target.value })}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">URL Audio Guide Thuyết Minh Đa Ngữ</label>
                  <input
                    type="text"
                    value={formData.audioGuideUrl || ''}
                    onChange={(e) => setFormData({ ...formData, audioGuideUrl: e.target.value })}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">Giờ Mở Cửa & Giá Vé</label>
                  <div className="flex space-x-2">
                    <input
                      type="text"
                      placeholder="Giờ mở cửa"
                      value={formData.openingHours || ''}
                      onChange={(e) => setFormData({ ...formData, openingHours: e.target.value })}
                      className="w-1/2 px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                    />
                    <input
                      type="text"
                      placeholder="Giá vé"
                      value={formData.ticketPrice || ''}
                      onChange={(e) => setFormData({ ...formData, ticketPrice: e.target.value })}
                      className="w-1/2 px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm focus:ring-2 focus:ring-[#173F35] outline-none"
                    />
                  </div>
                </div>
              </div>

              {/* Modal Footer */}
              <div className="pt-4 border-t border-[#E2E8F0] flex items-center justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-[#E2E8F0] rounded-lg text-xs font-bold text-[#64748B] hover:bg-[#F8FAFC]"
                >
                  Hủy Bỏ
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 bg-[#173F35] hover:bg-[#244C40] text-white rounded-lg text-xs font-bold shadow-sm"
                >
                  Lưu Dữ Liệu
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ── Modal Checklist Data Quality ──────────────────────────────────── */}
      {checklistModalItem && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg p-6 shadow-2xl">
            <h4 className="font-extrabold text-[#0F172A] text-base mb-1">
              Bảng Đánh Giá Độ Đầy Đủ Dữ Liệu: {checklistModalItem.name}
            </h4>
            <p className="text-xs text-[#64748B] mb-4">
              Điểm số hiện tại:{' '}
              <span className="font-extrabold text-[#173F35]">
                {checklistModalItem.completenessScore}% / 100%
              </span>
            </p>

            <div className="space-y-3">
              {[
                { label: 'Tọa độ GPS', has: checklistModalItem.lat && checklistModalItem.lng, weight: '15%' },
                { label: 'Mô tả ngắn & sâu', has: !!checklistModalItem.shortDescription, weight: '15%' },
                { label: 'Câu chuyện di sản', has: !!checklistModalItem.culturalStory, weight: '10%' },
                { label: 'Ảnh đại diện', has: !!checklistModalItem.coverUrl, weight: '10%' },
                { label: 'Album ảnh trưng bày', has: checklistModalItem.galleryUrls?.length > 0, weight: '10%' },
                { label: 'Ảnh Panorama VR360', has: !!checklistModalItem.vr360Url, weight: '15%' },
                { label: 'Audio Guide Thuyết Minh', has: !!checklistModalItem.audioGuideUrl, weight: '10%' },
              ].map((c, i) => (
                <div key={i} className="flex items-center justify-between p-2.5 rounded-lg bg-[#F8FAFC] border border-[#E2E8F0]">
                  <div className="flex items-center space-x-2.5">
                    {c.has ? (
                      <CheckCircle className="w-4 h-4 text-[#16A34A]" />
                    ) : (
                      <XCircle className="w-4 h-4 text-[#DC2626]" />
                    )}
                    <span className="text-xs font-bold text-[#0F172A]">{c.label}</span>
                  </div>
                  <span className="text-xs font-semibold text-[#64748B]">Trọng số: {c.weight}</span>
                </div>
              ))}
            </div>

            <div className="mt-6 flex justify-end space-x-2">
              <button
                onClick={() => setChecklistModalItem(null)}
                className="px-4 py-2 bg-[#F1F5F9] text-[#475569] font-bold text-xs rounded-lg hover:bg-[#E2E8F0]"
              >
                Đóng
              </button>
              <button
                onClick={() => {
                  const target = checklistModalItem;
                  setChecklistModalItem(null);
                  handleOpenEditModal(target);
                }}
                className="px-4 py-2 bg-[#173F35] text-white font-bold text-xs rounded-lg hover:bg-[#244C40]"
              >
                Bổ Sung Ngay
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
