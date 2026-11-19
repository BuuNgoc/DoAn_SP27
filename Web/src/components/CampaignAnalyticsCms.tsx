import React from 'react';
import {
  QrCode,
  Plane,
  Share2,
  TrendingUp,
  MapPin,
  ExternalLink,
  Plus,
} from 'lucide-react';
import { QrCampaign } from '../types';

interface CampaignAnalyticsCmsProps {
  campaigns: QrCampaign[];
  onUpdateCampaigns: (campaigns: QrCampaign[]) => void;
}

export const CampaignAnalyticsCms: React.FC<CampaignAnalyticsCmsProps> = ({
  campaigns,
}) => {
  const totalScans = campaigns.reduce((acc, cur) => acc + cur.scans, 0);
  const totalCheckins = campaigns.reduce((acc, cur) => acc + cur.checkins, 0);
  const totalShares = campaigns.reduce((acc, cur) => acc + cur.shares, 0);

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Chiến Dịch QR Sân Bay & Phân Tích Lan Tỏa Truyền Thông (FE-24, Epic 8)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Quản trị mã QR tại Sân bay Đà Nẵng T1/T2, nhà ga; cấu hình Landing Page và theo dõi tỷ lệ chuyển đổi
          </p>
        </div>
        <button className="px-4 py-2 bg-[#173F35] hover:bg-[#244C40] text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center space-x-1.5 self-start md:self-auto">
          <Plus className="w-4 h-4" />
          <span>Tạo Chiến Dịch QR Mới</span>
        </button>
      </div>

      {/* ── Stat Badges ───────────────────────────────────────────────────── */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="p-4 rounded-xl bg-[#F8FAFC] border border-[#E2E8F0]">
          <span className="text-xs font-bold text-[#64748B]">Tổng Lượt Quét QR</span>
          <div className="text-xl font-black text-[#173F35] mt-1">{totalScans.toLocaleString()} lượt</div>
        </div>
        <div className="p-4 rounded-xl bg-[#DCFCE7] border border-[#86EFAC]">
          <span className="text-xs font-bold text-[#15803D]">Check-in Thực Địa</span>
          <div className="text-xl font-black text-[#16A34A] mt-1">{totalCheckins.toLocaleString()} lượt</div>
        </div>
        <div className="p-4 rounded-xl bg-[#EFF6FF] border border-[#BFDBFE]">
          <span className="text-xs font-bold text-[#1E40AF]">Chia Sẻ Mạng Xã Hội</span>
          <div className="text-xl font-black text-[#2563EB] mt-1">{totalShares.toLocaleString()} shares</div>
        </div>
        <div className="p-4 rounded-xl bg-[#FEF3C7] border border-[#FDE68A]">
          <span className="text-xs font-bold text-[#92400E]">Tỷ Lệ Chuyển Đổi TB</span>
          <div className="text-xl font-black text-[#D97706] mt-1">43.2%</div>
        </div>
      </div>

      {/* ── Airport Landing Page Preview Card ─────────────────────────────── */}
      <div className="p-5 rounded-xl bg-[#EFF6FF] border border-[#BFDBFE] flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="flex items-start space-x-3.5">
          <div className="p-2.5 rounded-xl bg-[#2563EB] text-white shrink-0">
            <Plane className="w-6 h-6" />
          </div>
          <div>
            <h4 className="font-extrabold text-[#1E40AF] text-sm">
              Landing Page Đón Khách Sân Bay Đà Nẵng (Airport Arrival Hub)
            </h4>
            <p className="text-xs text-[#3B82F6] mt-1 leading-relaxed">
              Thông điệp: "Chào mừng bạn đến Đà Nẵng! Khám phá Di sản Ngũ Hành Sơn nhanh trong 4 giờ" • Hỗ trợ đa ngữ: VI, EN, KO, ZH.
            </p>
          </div>
        </div>
        <button className="px-4 py-2 border border-[#2563EB] text-[#2563EB] hover:bg-[#DBEAFE] rounded-lg text-xs font-bold transition-all shrink-0 self-start md:self-auto">
          Cấu Hình Landing Page
        </button>
      </div>

      {/* ── Campaigns Table ───────────────────────────────────────────────── */}
      <div className="space-y-3">
        <h4 className="text-xs font-extrabold text-[#94A3B8] uppercase tracking-wider">
          Danh Sách Chiến Dịch QR & Điểm Chạm Du Khách
        </h4>

        <div className="overflow-x-auto border border-[#E2E8F0] rounded-xl">
          <table className="w-full text-left text-sm">
            <thead className="bg-[#F8FAFC] border-b border-[#E2E8F0] text-xs font-extrabold text-[#475569] uppercase">
              <tr>
                <th className="py-3 px-4">Chiến Dịch & Vị Trí Đặt QR</th>
                <th className="py-3 px-4">Đường Dẫn Landing Page</th>
                <th className="py-3 px-4">Lượt Quét</th>
                <th className="py-3 px-4">Check-in</th>
                <th className="py-3 px-4">Lượt Share</th>
                <th className="py-3 px-4 text-right">Chuyển Đổi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E2E8F0]">
              {campaigns.map((c) => (
                <tr key={c.id} className="hover:bg-[#F8FAFC]">
                  <td className="py-3 px-4">
                    <div className="font-extrabold text-[#0F172A]">{c.name}</div>
                    <div className="text-xs text-[#64748B]">{c.channelLocation}</div>
                  </td>
                  <td className="py-3 px-4 text-xs font-mono text-[#173F35]">
                    {c.targetLanding}
                  </td>
                  <td className="py-3 px-4 font-bold text-xs text-[#0F172A]">
                    {c.scans.toLocaleString()}
                  </td>
                  <td className="py-3 px-4 font-bold text-xs text-[#16A34A]">
                    {c.checkins.toLocaleString()}
                  </td>
                  <td className="py-3 px-4 font-bold text-xs text-[#2563EB]">
                    {c.shares.toLocaleString()}
                  </td>
                  <td className="py-3 px-4 text-right">
                    <span className="inline-block px-2 py-0.5 bg-[#DCFCE7] text-[#15803D] rounded text-xs font-extrabold">
                      {c.conversionRate}%
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
