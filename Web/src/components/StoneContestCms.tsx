import React, { useState } from 'react';
import {
  Trophy,
  CheckCircle2,
  Share2,
  ThumbsUp,
  Plus,
  Sparkles,
} from 'lucide-react';
import { ContestEntry } from '../types';

interface StoneContestCmsProps {
  entries: ContestEntry[];
  onUpdateEntries: (entries: ContestEntry[]) => void;
}

export const StoneContestCms: React.FC<StoneContestCmsProps> = ({
  entries,
  onUpdateEntries,
}) => {
  const [activeTab, setActiveTab] = useState<'LEADERBOARD' | 'APPROVAL'>('LEADERBOARD');
  const [isNewContestOpen, setIsNewContestOpen] = useState(false);

  const pendingList = entries.filter((e) => e.status === 'PENDING');
  const approvedList = entries
    .filter((e) => e.status === 'APPROVED')
    .sort((a, b) => b.votes - a.votes);

  const totalVotes = entries.reduce((acc, cur) => acc + cur.votes, 0);
  const totalShares = entries.reduce((acc, cur) => acc + cur.shares, 0);

  const handleApprove = (id: string) => {
    onUpdateEntries(
      entries.map((e) => (e.id === id ? { ...e, status: 'APPROVED' } : e)),
    );
  };

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Cuộc Thi Điêu Khắc Đá Mỹ Nghệ Non Nước 2026 (FE-16, Epic 6)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Chủ đề: "400 Năm Tinh Hoa Bàn Tay Vàng Làng Đá" • Bảng xếp hạng bình chọn du khách & kiểm duyệt tác phẩm
          </p>
        </div>
        <button
          onClick={() => setIsNewContestOpen(true)}
          className="px-4 py-2 bg-[#173F35] hover:bg-[#244C40] text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center space-x-1.5 self-start md:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Thiết Lập Cuộc Thi Mới</span>
        </button>
      </div>

      {/* ── Metric Badges ─────────────────────────────────────────────────── */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="p-4 rounded-xl bg-[#F8FAFC] border border-[#E2E8F0]">
          <span className="text-xs font-bold text-[#64748B]">Tổng Tác Phẩm Dự Thi</span>
          <div className="text-xl font-black text-[#173F35] mt-1">{entries.length} bài thi</div>
        </div>
        <div className="p-4 rounded-xl bg-[#FEF3C7] border border-[#FDE68A]">
          <span className="text-xs font-bold text-[#92400E]">Tổng Lượt Bình Chọn</span>
          <div className="text-xl font-black text-[#B45309] mt-1">{totalVotes.toLocaleString()} votes</div>
        </div>
        <div className="p-4 rounded-xl bg-[#EFF6FF] border border-[#BFDBFE]">
          <span className="text-xs font-bold text-[#1E40AF]">Lượt Share Mạng Xã Hội</span>
          <div className="text-xl font-black text-[#2563EB] mt-1">{totalShares.toLocaleString()} shares</div>
        </div>
        <div className="p-4 rounded-xl bg-[#FEF2F2] border border-[#FECACA]">
          <span className="text-xs font-bold text-[#991B1B]">Chờ Kiểm Duyệt</span>
          <div className="text-xl font-black text-[#DC2626] mt-1">{pendingList.length} tác phẩm</div>
        </div>
      </div>

      {/* ── Navigation Tabs ───────────────────────────────────────────────── */}
      <div className="flex space-x-2 border-b border-[#E2E8F0] pb-2">
        <button
          onClick={() => setActiveTab('LEADERBOARD')}
          className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
            activeTab === 'LEADERBOARD'
              ? 'bg-[#173F35] text-white shadow-sm'
              : 'text-[#64748B] hover:bg-[#F8FAFC]'
          }`}
        >
          Bảng Xếp Hạng Bình Chọn (Leaderboard)
        </button>
        <button
          onClick={() => setActiveTab('APPROVAL')}
          className={`px-4 py-2 rounded-lg text-xs font-bold transition-all ${
            activeTab === 'APPROVAL'
              ? 'bg-[#173F35] text-white shadow-sm'
              : 'text-[#64748B] hover:bg-[#F8FAFC]'
          }`}
        >
          Duyệt Tác Phẩm Nghệ Nhân ({pendingList.length})
        </button>
      </div>

      {/* ── Tab Content ───────────────────────────────────────────────────── */}
      {activeTab === 'LEADERBOARD' ? (
        <div className="overflow-x-auto border border-[#E2E8F0] rounded-xl">
          <table className="w-full text-left text-sm">
            <thead className="bg-[#F8FAFC] border-b border-[#E2E8F0] text-xs font-extrabold text-[#475569] uppercase">
              <tr>
                <th className="py-3 px-4 text-center">Hạng</th>
                <th className="py-3 px-4">Tác Phẩm & Chất Liệu</th>
                <th className="py-3 px-4">Nghệ Nhân / Xưởng Đá</th>
                <th className="py-3 px-4">Lượt Vote</th>
                <th className="py-3 px-4">Lượt Share</th>
                <th className="py-3 px-4 text-right">Trạng Thái</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E2E8F0]">
              {approvedList.map((item, idx) => (
                <tr key={item.id} className="hover:bg-[#F8FAFC]">
                  <td className="py-3 px-4 text-center">
                    <span
                      className={`inline-flex items-center justify-center w-7 h-7 rounded-full text-xs font-black ${
                        idx === 0
                          ? 'bg-[#F59E0B] text-white shadow'
                          : idx === 1
                          ? 'bg-[#94A3B8] text-white'
                          : idx === 2
                          ? 'bg-[#B45309] text-white'
                          : 'text-[#64748B]'
                      }`}
                    >
                      #{idx + 1}
                    </span>
                  </td>
                  <td className="py-3 px-4">
                    <div className="font-bold text-[#0F172A]">{item.title}</div>
                    <div className="text-xs text-[#64748B]">
                      {item.stoneType} • {item.carvingTechnique}
                    </div>
                  </td>
                  <td className="py-3 px-4">
                    <div className="font-bold text-xs text-[#173F35]">{item.artisanName}</div>
                    <div className="text-xs text-[#94A3B8]">{item.workshopName}</div>
                  </td>
                  <td className="py-3 px-4 text-xs font-black text-[#D97706]">
                    ★ {item.votes.toLocaleString()} votes
                  </td>
                  <td className="py-3 px-4 text-xs font-bold text-[#2563EB]">
                    ↗ {item.shares.toLocaleString()} shares
                  </td>
                  <td className="py-3 px-4 text-right">
                    <span className="text-[11px] font-extrabold px-2.5 py-1 bg-[#DCFCE7] text-[#15803D] rounded-md">
                      Đang bình chọn
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <div className="space-y-3">
          {pendingList.length === 0 ? (
            <div className="p-8 text-center text-[#64748B] bg-[#F8FAFC] rounded-xl border border-dashed border-[#CBD5E1]">
              <CheckCircle2 className="w-10 h-10 text-[#16A34A] mx-auto mb-2" />
              <p className="font-bold text-sm text-[#0F172A]">
                Không có tác phẩm nào đang chờ duyệt!
              </p>
            </div>
          ) : (
            pendingList.map((item) => (
              <div
                key={item.id}
                className="p-4 rounded-xl border border-[#E2E8F0] bg-white flex items-center justify-between hover:shadow-md transition-shadow"
              >
                <div>
                  <h4 className="font-extrabold text-[#0F172A] text-sm">{item.title}</h4>
                  <p className="text-xs text-[#475569] mt-0.5">
                    Nghệ nhân: {item.artisanName} | Xưởng: {item.workshopName} | Chất liệu: {item.stoneType}
                  </p>
                  <p className="text-xs text-[#94A3B8] italic mt-1">"{item.story}"</p>
                </div>
                <button
                  onClick={() => handleApprove(item.id)}
                  className="px-4 py-2 bg-[#16A34A] hover:bg-[#15803D] text-white rounded-lg text-xs font-bold shadow-sm shrink-0"
                >
                  Phê Duyệt Tham Gia
                </button>
              </div>
            ))
          )}
        </div>
      )}

      {/* ── Modal Create Contest ─────────────────────────────────────────── */}
      {isNewContestOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg p-6 shadow-2xl">
            <h4 className="font-extrabold text-[#0F172A] text-base mb-4">
              Thiết Lập Cuộc Thi Điêu Khắc Đá Mới (FE-16)
            </h4>
            <div className="space-y-3">
              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Tên Cuộc Thi *</label>
                <input
                  type="text"
                  defaultValue="Bàn Tay Vàng Làng Đá Non Nước 2026"
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Chủ Đề Điêu Khắc *</label>
                <input
                  type="text"
                  defaultValue="Di sản văn hóa Ngũ Hành Sơn 400 năm"
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Thời Gian Bình Chọn *</label>
                <input
                  type="text"
                  defaultValue="01/12/2026 - 31/12/2026"
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>
            </div>
            <div className="mt-5 flex justify-end space-x-2">
              <button
                onClick={() => setIsNewContestOpen(false)}
                className="px-4 py-2 border border-[#E2E8F0] rounded-lg text-xs font-bold text-[#64748B]"
              >
                Hủy
              </button>
              <button
                onClick={() => setIsNewContestOpen(false)}
                className="px-4 py-2 bg-[#173F35] text-white rounded-lg text-xs font-bold hover:bg-[#244C40]"
              >
                Tạo Cuộc Thi
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
