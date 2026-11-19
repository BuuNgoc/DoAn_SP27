import React, { useState } from 'react';
import {
  Umbrella,
  Flag,
  AlertTriangle,
  Radio,
  Clock,
  Wind,
  Waves,
  ShieldAlert,
  CheckCircle,
} from 'lucide-react';
import { BeachSafety } from '../types';

interface BeachTourismCmsProps {
  beaches: BeachSafety[];
  onUpdateBeaches: (beaches: BeachSafety[]) => void;
}

export const BeachTourismCms: React.FC<BeachTourismCmsProps> = ({
  beaches,
  onUpdateBeaches,
}) => {
  const [selectedBeach, setSelectedBeach] = useState<BeachSafety | null>(null);
  const [isAlertModalOpen, setIsAlertModalOpen] = useState(false);
  const [broadcastMessage, setBroadcastMessage] = useState('');
  const [isBroadcastSent, setIsBroadcastSent] = useState(false);

  // Edit Flag State
  const [editingFlagColor, setEditingFlagColor] = useState<BeachSafety['flagColor']>('GREEN');
  const [editingWave, setEditingWave] = useState('');
  const [editingRip, setEditingRip] = useState(false);
  const [editingNotice, setEditingNotice] = useState('');

  const handleOpenEditFlag = (b: BeachSafety) => {
    setSelectedBeach(b);
    setEditingFlagColor(b.flagColor);
    setEditingWave(b.waveHeight);
    setEditingRip(b.ripCurrentWarning);
    setEditingNotice(b.noticeMessage);
  };

  const handleSaveFlag = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedBeach) return;

    onUpdateBeaches(
      beaches.map((b) =>
        b.beachId === selectedBeach.beachId
          ? {
              ...b,
              flagColor: editingFlagColor,
              waveHeight: editingWave,
              ripCurrentWarning: editingRip,
              noticeMessage: editingNotice,
              updatedAt: 'Vừa cập nhật',
            }
          : b,
      ),
    );
    setSelectedBeach(null);
  };

  const handleSendBroadcast = (e: React.FormEvent) => {
    e.preventDefault();
    setIsBroadcastSent(true);
    setTimeout(() => {
      setIsBroadcastSent(false);
      setIsAlertModalOpen(false);
      setBroadcastMessage('');
    }, 2000);
  };

  const getFlagBadge = (color: BeachSafety['flagColor']) => {
    switch (color) {
      case 'GREEN':
        return {
          bg: 'bg-[#DCFCE7] text-[#15803D] border-[#86EFAC]',
          label: 'CỜ XANH: AN TOÀN TẮM BIỂN',
        };
      case 'YELLOW':
        return {
          bg: 'bg-[#FEF3C7] text-[#B45309] border-[#FCD34D]',
          label: 'CỜ VÀNG: BIỂN ĐỘNG / CHÚ Ý',
        };
      case 'RED':
        return {
          bg: 'bg-[#FEE2E2] text-[#DC2626] border-[#FCA5A5]',
          label: 'CỜ ĐỎ: CẤM TẮM BIỂN!',
        };
    }
  };

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Du Lịch Biển & Hệ Thống Cảnh Báo An Toàn Bờ Biển (FE-13, Epic 3)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Quản lý bãi tắm Sơn Thủy, Tân Trà, lối xuống biển, trạm cứu hộ & cập nhật cờ cảnh báo an toàn thời gian thực
          </p>
        </div>
        <button
          onClick={() => {
            setBroadcastMessage(
              'Khuyến cáo an toàn: Gió giật mạnh và sóng lớn do thời tiết xấu. Đề nghị du khách không tắm biển và tuân thủ hướng dẫn của đội cứu hộ.',
            );
            setIsAlertModalOpen(true);
          }}
          className="px-4 py-2 bg-[#DC2626] hover:bg-[#B91C1C] text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center space-x-1.5 self-start md:self-auto"
        >
          <Radio className="w-4 h-4 animate-pulse" />
          <span>Phát Cảnh Báo Khẩn Cấp (Push Alert)</span>
        </button>
      </div>

      {/* ── Beach Cards Grid ──────────────────────────────────────────────── */}
      <div className="space-y-4">
        <h4 className="text-xs font-extrabold text-[#94A3B8] uppercase tracking-wider">
          Tình Trạng An Toàn & Cờ Hiệu Bờ Biển Thời Gian Thực
        </h4>

        {beaches.map((b) => {
          const badge = getFlagBadge(b.flagColor);
          return (
            <div
              key={b.beachId}
              className="p-5 rounded-xl border border-[#E2E8F0] bg-white shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-4 hover:border-[#CBD5E1] transition-all"
            >
              <div className="space-y-2">
                <div className="flex items-center space-x-3">
                  <span
                    className={`px-3 py-1 rounded-full text-xs font-extrabold border flex items-center space-x-1.5 ${badge.bg}`}
                  >
                    <Flag className="w-3.5 h-3.5" />
                    <span>{badge.label}</span>
                  </span>
                  <h4 className="font-extrabold text-[#0F172A] text-base">{b.beachName}</h4>
                  {b.ripCurrentWarning && (
                    <span className="px-2.5 py-0.5 bg-[#FEF2F2] border border-[#FCA5A5] text-[#DC2626] text-xs font-extrabold rounded-md flex items-center space-x-1">
                      <AlertTriangle className="w-3.5 h-3.5" />
                      <span>Cảnh Báo Dòng Nước Rút (Rip Current)</span>
                    </span>
                  )}
                </div>

                <p className="text-xs text-[#475569] leading-relaxed max-w-3xl">
                  {b.noticeMessage}
                </p>

                <div className="flex flex-wrap items-center gap-4 text-xs text-[#64748B] pt-1">
                  <div className="flex items-center space-x-1 font-medium">
                    <Waves className="w-3.5 h-3.5 text-[#0284C7]" />
                    <span>Sóng biển: {b.waveHeight}</span>
                  </div>
                  <div className="flex items-center space-x-1 font-medium">
                    <Wind className="w-3.5 h-3.5 text-[#64748B]" />
                    <span>Gió: {b.windSpeed}</span>
                  </div>
                  <div className="flex items-center space-x-1 font-bold text-[#15803D]">
                    <ShieldAlert className="w-3.5 h-3.5" />
                    <span>{b.lifeguardStatus}</span>
                  </div>
                  <span className="text-[#94A3B8]">Cập nhật: {b.updatedAt}</span>
                </div>
              </div>

              <button
                onClick={() => handleOpenEditFlag(b)}
                className="px-3.5 py-2 bg-[#173F35] hover:bg-[#244C40] text-white rounded-lg text-xs font-bold transition-all shadow-sm shrink-0 self-start md:self-center"
              >
                Đổi Cờ & Cập Nhật
              </button>
            </div>
          );
        })}
      </div>

      {/* ── Beach Facilities Table ────────────────────────────────────────── */}
      <div className="space-y-3 pt-2">
        <h4 className="text-xs font-extrabold text-[#94A3B8] uppercase tracking-wider">
          Hạ Tầng Tiện Ích Biển & Khách Sạn Gợi Ý (Sheet gid=0)
        </h4>

        <div className="overflow-x-auto border border-[#E2E8F0] rounded-xl">
          <table className="w-full text-left text-sm">
            <thead className="bg-[#F8FAFC] border-b border-[#E2E8F0] text-xs font-extrabold text-[#475569] uppercase">
              <tr>
                <th className="py-3 px-4">Tên Cơ Sở / Tiện Ích</th>
                <th className="py-3 px-4">Phân Loại</th>
                <th className="py-3 px-4">Tọa Độ GPS</th>
                <th className="py-3 px-4">Trạng Thái Vận Hành</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E2E8F0]">
              {[
                {
                  name: 'Lối Xuống Biển Sơn Thủy Số 1 (Lát Gỗ Đạt Chuẩn)',
                  type: 'Lối Xuống Biển Công Cộng',
                  gps: '16.0128, 108.2718',
                  status: 'Hoạt động tốt, có dốc xe lăn',
                },
                {
                  name: 'Bãi Đỗ Xe Công Cộng Sơn Thủy (Sức chứa 200 xe)',
                  type: 'Bãi Đỗ Xe Du Khách',
                  gps: '16.0120, 108.2709',
                  status: 'Miễn phí, có bảo vệ',
                },
                {
                  name: 'Trạm Cứu Hộ Bờ Biển Số 3 (Tân Trà)',
                  type: 'Trạm Cứu Hộ Bờ Biển',
                  gps: '16.0085, 108.2730',
                  status: 'Trực ca 05:00 - 18:30 hằng ngày',
                },
                {
                  name: 'Hyatt Regency Danang Resort & Spa (5 Sao)',
                  type: 'Resort Ven Biển Đối Tác',
                  gps: '16.0180, 108.2690',
                  status: 'Liên kết ưu đãi du khách NHS360',
                },
              ].map((f, i) => (
                <tr key={i} className="hover:bg-[#F8FAFC]">
                  <td className="py-3 px-4 font-bold text-[#0F172A]">{f.name}</td>
                  <td className="py-3 px-4 text-xs font-extrabold text-[#173F35]">{f.type}</td>
                  <td className="py-3 px-4 text-xs font-mono text-[#64748B]">{f.gps}</td>
                  <td className="py-3 px-4 text-xs font-semibold text-[#15803D]">{f.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* ── Modal Edit Flag ──────────────────────────────────────────────── */}
      {selectedBeach && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg p-6 shadow-2xl">
            <h4 className="font-extrabold text-[#0F172A] text-base mb-4">
              Cập Nhật Trạng Thái An Toàn: {selectedBeach.beachName}
            </h4>

            <form onSubmit={handleSaveFlag} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">
                  Mức Cờ An Toàn Bờ Biển *
                </label>
                <select
                  value={editingFlagColor}
                  onChange={(e) => setEditingFlagColor(e.target.value as any)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm font-bold outline-none"
                >
                  <option value="GREEN">🟢 CỜ XANH: An Toàn Tắm Biển</option>
                  <option value="YELLOW">🟡 CỜ VÀNG: Biển Động Nhẹ / Chú Ý</option>
                  <option value="RED">🔴 CỜ ĐỎ: CẤM TẮM BIỂN (Nguy Hiểm)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Độ Cao Sóng (m)</label>
                <input
                  type="text"
                  value={editingWave}
                  onChange={(e) => setEditingWave(e.target.value)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>

              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="ripCurrent"
                  checked={editingRip}
                  onChange={(e) => setEditingRip(e.target.checked)}
                  className="rounded text-[#DC2626] focus:ring-[#DC2626]"
                />
                <label htmlFor="ripCurrent" className="text-xs font-bold text-[#DC2626]">
                  Cảnh báo xuất hiện Dòng Nước Rút (Rip Current) nguy hiểm
                </label>
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">
                  Thông Báo Chi Tiết Gửi Du Khách
                </label>
                <textarea
                  rows={3}
                  value={editingNotice}
                  onChange={(e) => setEditingNotice(e.target.value)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>

              <div className="pt-3 border-t border-[#E2E8F0] flex justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setSelectedBeach(null)}
                  className="px-4 py-2 border border-[#E2E8F0] rounded-lg text-xs font-bold text-[#64748B]"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#173F35] text-white rounded-lg text-xs font-bold hover:bg-[#244C40]"
                >
                  Cập Nhật Ngay
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ── Modal Emergency Broadcast ────────────────────────────────────── */}
      {isAlertModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg p-6 shadow-2xl">
            <div className="flex items-center space-x-2 text-[#DC2626] mb-2">
              <AlertTriangle className="w-5 h-5" />
              <h4 className="font-extrabold text-[#0F172A] text-base">
                Phát Cảnh Báo Khẩn Cấp Toàn Bờ Biển (Push Notification)
              </h4>
            </div>
            <p className="text-xs text-[#64748B] mb-4">
              Hệ thống sẽ gửi thông báo đẩy (FCM) tức thì tới tất cả thiết bị du khách đang có mặt trong bán kính 3km quanh bờ biển Ngũ Hành Sơn.
            </p>

            <form onSubmit={handleSendBroadcast} className="space-y-4">
              <textarea
                rows={4}
                required
                value={broadcastMessage}
                onChange={(e) => setBroadcastMessage(e.target.value)}
                className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
              />

              {isBroadcastSent && (
                <div className="p-3 bg-[#DCFCE7] text-[#15803D] text-xs font-bold rounded-lg flex items-center space-x-2">
                  <CheckCircle className="w-4 h-4" />
                  <span>Đã phát thông báo khẩn cấp tới 4,820 thiết bị thành công!</span>
                </div>
              )}

              <div className="pt-3 border-t border-[#E2E8F0] flex justify-end space-x-2">
                <button
                  type="button"
                  disabled={isBroadcastSent}
                  onClick={() => setIsAlertModalOpen(false)}
                  className="px-4 py-2 border border-[#E2E8F0] rounded-lg text-xs font-bold text-[#64748B]"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  disabled={isBroadcastSent}
                  className="px-4 py-2 bg-[#DC2626] text-white rounded-lg text-xs font-bold hover:bg-[#B91C1C]"
                >
                  Gửi Cảnh Báo Ngay
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
