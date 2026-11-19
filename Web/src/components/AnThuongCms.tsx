import React, { useState } from 'react';
import {
  Store,
  CheckCircle2,
  XCircle,
  Clock,
  MapPin,
  Sparkles,
  Music,
} from 'lucide-react';
import { VendorSubmission } from '../types';

interface AnThuongCmsProps {
  vendors: VendorSubmission[];
  onUpdateVendors: (vendors: VendorSubmission[]) => void;
}

export const AnThuongCms: React.FC<AnThuongCmsProps> = ({
  vendors,
  onUpdateVendors,
}) => {
  const [activeTab, setActiveTab] = useState<'APPROVAL' | 'DIRECTORY' | 'EVENTS'>('APPROVAL');
  const [categoryFilter, setCategoryFilter] = useState<string>('Tất cả');

  const pendingList = vendors.filter((v) => v.status === 'PENDING');
  const approvedList = vendors.filter(
    (v) =>
      v.status === 'APPROVED' &&
      (categoryFilter === 'Tất cả' || v.category === categoryFilter),
  );

  const handleApprove = (id: string) => {
    onUpdateVendors(
      vendors.map((v) => (v.id === id ? { ...v, status: 'APPROVED' } : v)),
    );
  };

  const handleReject = (id: string) => {
    onUpdateVendors(
      vendors.map((v) => (v.id === id ? { ...v, status: 'REJECTED' } : v)),
    );
  };

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Mở Rộng Phố Đi Bộ An Thượng & Phê Duyệt Vendor (FE-12, Epic 2)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Quản trị 4 nhóm dịch vụ: Ẩm thực (Food), Cà phê (Cafe), Nightlife & Văn nghệ đường phố
          </p>
        </div>
        <div className="flex items-center space-x-2">
          <span className="px-3 py-1 bg-[#FEF2F2] border border-[#FCA5A5] text-[#DC2626] rounded-full text-xs font-bold">
            {pendingList.length} cơ sở chờ duyệt
          </span>
        </div>
      </div>

      {/* ── Navigation Tabs ───────────────────────────────────────────────── */}
      <div className="flex space-x-2 border-b border-[#E2E8F0] pb-2">
        <button
          onClick={() => setActiveTab('APPROVAL')}
          className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
            activeTab === 'APPROVAL'
              ? 'bg-[#173F35] text-white shadow-sm'
              : 'text-[#64748B] hover:bg-[#F8FAFC]'
          }`}
        >
          Duyệt Hồ Sơ Vendor Gửi Lên ({pendingList.length})
        </button>
        <button
          onClick={() => setActiveTab('DIRECTORY')}
          className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
            activeTab === 'DIRECTORY'
              ? 'bg-[#173F35] text-white shadow-sm'
              : 'text-[#64748B] hover:bg-[#F8FAFC]'
          }`}
        >
          Danh Mục Cơ Sở Đã Lên Bản Đồ
        </button>
        <button
          onClick={() => setActiveTab('EVENTS')}
          className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
            activeTab === 'EVENTS'
              ? 'bg-[#173F35] text-white shadow-sm'
              : 'text-[#64748B] hover:bg-[#F8FAFC]'
          }`}
        >
          Lịch Văn Nghệ & Sự Kiện Đêm
        </button>
      </div>

      {/* ── Tab Content ───────────────────────────────────────────────────── */}
      {activeTab === 'APPROVAL' && (
        <div className="space-y-4">
          {pendingList.length === 0 ? (
            <div className="p-8 text-center text-[#64748B] bg-[#F8FAFC] rounded-xl border border-dashed border-[#CBD5E1]">
              <CheckCircle2 className="w-10 h-10 text-[#16A34A] mx-auto mb-2" />
              <p className="font-bold text-sm text-[#0F172A]">
                Tất cả hồ sơ đăng ký từ Vendor An Thượng đã được xử lý hoàn tất!
              </p>
            </div>
          ) : (
            <div className="overflow-x-auto border border-[#E2E8F0] rounded-xl">
              <table className="w-full text-left text-sm">
                <thead className="bg-[#F8FAFC] border-b border-[#E2E8F0] text-xs font-extrabold text-[#475569] uppercase">
                  <tr>
                    <th className="py-3 px-4">Tên Cơ Sở & Chủ Hộ</th>
                    <th className="py-3 px-4">Nhóm Dịch Vụ</th>
                    <th className="py-3 px-4">Tuyến Phố</th>
                    <th className="py-3 px-4">Giờ Đêm</th>
                    <th className="py-3 px-4 text-right">Phê Duyệt</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#E2E8F0]">
                  {pendingList.map((item) => (
                    <tr key={item.id} className="hover:bg-[#F8FAFC]">
                      <td className="py-3 px-4">
                        <div className="font-bold text-[#0F172A]">{item.businessName}</div>
                        <div className="text-xs text-[#64748B]">
                          Chủ hộ: {item.ownerName} • SĐT: {item.phone}
                        </div>
                      </td>
                      <td className="py-3 px-4">
                        <span className="font-extrabold text-xs text-[#173F35]">
                          {item.category}
                        </span>
                      </td>
                      <td className="py-3 px-4 text-xs text-[#475569]">{item.street}</td>
                      <td className="py-3 px-4 text-xs text-[#64748B]">{item.openingHours}</td>
                      <td className="py-3 px-4 text-right">
                        <div className="flex items-center justify-end space-x-2">
                          <button
                            onClick={() => handleApprove(item.id)}
                            className="px-3 py-1.5 bg-[#16A34A] hover:bg-[#15803D] text-white rounded-lg text-xs font-bold shadow-sm"
                          >
                            Duyệt
                          </button>
                          <button
                            onClick={() => handleReject(item.id)}
                            className="px-3 py-1.5 border border-[#DC2626] text-[#DC2626] hover:bg-[#FEE2E2] rounded-lg text-xs font-bold"
                          >
                            Từ Chối
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {activeTab === 'DIRECTORY' && (
        <div className="space-y-4">
          <div className="flex items-center justify-between pb-2">
            <span className="text-xs font-bold text-[#64748B]">Lọc theo phân nhóm:</span>
            <select
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
              className="bg-[#F8FAFC] border border-[#E2E8F0] px-3 py-1.5 rounded-lg text-xs font-bold text-[#0F172A]"
            >
              {['Tất cả', 'Food', 'Cafe', 'Nightlife', 'Performance'].map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {approvedList.map((item) => (
              <div
                key={item.id}
                className="p-4 rounded-xl border border-[#E2E8F0] bg-white shadow-sm flex items-start space-x-3.5 hover:shadow-md transition-shadow"
              >
                <div className="p-2.5 rounded-xl bg-[#EBF2EF] text-[#173F35] shrink-0 mt-0.5">
                  <Store className="w-5 h-5" />
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between">
                    <h4 className="font-extrabold text-[#0F172A] text-sm">{item.businessName}</h4>
                    <span className="text-[10px] font-extrabold px-2 py-0.5 bg-[#DCFCE7] text-[#15803D] rounded">
                      Đang hiển thị
                    </span>
                  </div>
                  <div className="text-xs text-[#64748B] mt-1 leading-relaxed">
                    {item.description}
                  </div>
                  <div className="mt-2.5 flex items-center space-x-4 text-xs text-[#94A3B8]">
                    <span className="font-semibold text-[#173F35]">{item.category}</span>
                    <span>•</span>
                    <span>{item.street}</span>
                    <span>•</span>
                    <span>{item.openingHours}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'EVENTS' && (
        <div className="space-y-3">
          {[
            {
              title: 'Acoustic Sunset & Night Vibes',
              time: 'Mỗi Thứ 6 & Thứ 7 (20:00 - 22:30)',
              venue: 'Ngã tư An Thượng 2 & Hoàng Kế Viêm',
              band: 'Ban nhạc Flamenco Đà Nẵng',
            },
            {
              title: 'Carnival Vũ Điệu Đường Phố & Ẩm Thực Đêm',
              time: 'Chủ Nhật (19:30 - 22:00)',
              venue: 'Tuyến Phố An Thượng 1',
              band: 'Đoàn vũ công Quốc tế',
            },
            {
              title: 'Đêm Thơ Nhạc & Không Gian Trà Đạo',
              time: 'Thứ 4 hằng tuần (20:00 - 21:30)',
              venue: 'Không gian Văn hóa An Thượng 3',
              band: 'CLB Văn Nghệ Dân Gian',
            },
          ].map((ev, i) => (
            <div
              key={i}
              className="p-4 rounded-xl border border-[#E2E8F0] bg-white flex items-center justify-between hover:border-[#173F35] transition-all"
            >
              <div className="flex items-center space-x-3.5">
                <div className="p-2.5 rounded-xl bg-[#EDE9FE] text-[#7C3AED]">
                  <Music className="w-5 h-5" />
                </div>
                <div>
                  <div className="font-extrabold text-[#0F172A] text-sm">{ev.title}</div>
                  <div className="text-xs text-[#64748B] mt-0.5">
                    Thời gian: {ev.time} | Địa điểm: {ev.venue} | Ban nhạc: {ev.band}
                  </div>
                </div>
              </div>
              <span className="text-xs font-bold text-[#16A34A] bg-[#DCFCE7] px-2.5 py-1 rounded-md">
                Đang diễn ra
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
