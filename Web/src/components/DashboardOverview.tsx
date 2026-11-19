import React from 'react';
import {
  Landmark,
  CheckCircle2,
  Compass,
  QrCode,
  Plane,
  Ticket,
  AlertTriangle,
  ArrowRight,
  Calendar,
  Clock,
  ShieldCheck,
} from 'lucide-react';
import { initialAuditLogs } from '../data/mockData';

interface DashboardOverviewProps {
  onNavigateToTab: (index: number) => void;
}

export const DashboardOverview: React.FC<DashboardOverviewProps> = ({
  onNavigateToTab,
}) => {
  const kpis = [
    {
      title: 'Tổng Điểm Đến',
      value: '32',
      delta: '+4 mới',
      subtitle: '5 phân loại chuẩn',
      icon: Landmark,
      color: 'text-[#173F35] bg-[#EBF2EF]',
    },
    {
      title: 'Độ Chuẩn Hóa Data',
      value: '88.5%',
      delta: '+12.4%',
      subtitle: 'Theo chuẩn Epic 1',
      icon: CheckCircle2,
      color: 'text-[#0D9488] bg-[#CCFBF1]',
    },
    {
      title: 'Lượt Xem VR360',
      value: '35,420',
      delta: '+24.1%',
      subtitle: '6 tuyến di sản',
      icon: Compass,
      color: 'text-[#2563EB] bg-[#DBEAFE]',
    },
    {
      title: 'Quét QR Check-in',
      value: '18,650',
      delta: '+18.7%',
      subtitle: 'Geofence HMAC',
      icon: QrCode,
      color: 'text-[#D97706] bg-[#FEF3C7]',
    },
    {
      title: 'QR Sân Bay (Campaign)',
      value: '6,890',
      delta: '+42.5%',
      subtitle: 'T1/T2 Đà Nẵng',
      icon: Plane,
      color: 'text-[#7C3AED] bg-[#EDE9FE]',
    },
    {
      title: 'Vé Workshop Làng Đá',
      value: '1,420',
      delta: '+15.2%',
      subtitle: '24 ca trải nghiệm',
      icon: Ticket,
      color: 'text-[#E11D48] bg-[#FFE4E6]',
    },
  ];

  const monthlyData = [
    { month: 'Thg 1', val: 48, label: '14.2k' },
    { month: 'Thg 2', val: 78, label: '23.4k' },
    { month: 'Thg 3', val: 92, label: '27.6k' },
    { month: 'Thg 4', val: 70, label: '21.0k' },
    { month: 'Thg 5', val: 62, label: '18.6k' },
    { month: 'Thg 6', val: 88, label: '26.4k' },
    { month: 'Thg 7', val: 100, label: '30.0k' },
    { month: 'Thg 8', val: 95, label: '28.5k' },
    { month: 'Thg 9', val: 65, label: '19.5k' },
    { month: 'Thg 10', val: 75, label: '22.5k' },
    { month: 'Thg 11', val: 85, label: '25.5k' },
    { month: 'Thg 12', val: 90, label: '27.0k' },
  ];

  return (
    <div className="space-y-6">
      {/* ── 1. KPI Cards Grid ────────────────────────────────────────────── */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
        {kpis.map((kpi, idx) => {
          const Icon = kpi.icon;
          return (
            <div
              key={idx}
              className="bg-white p-4 rounded-xl border border-[#E2E8F0] shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow"
            >
              <div className="flex items-center justify-between">
                <span className="text-xs font-bold text-[#64748B] truncate">
                  {kpi.title}
                </span>
                <div className={`p-1.5 rounded-lg ${kpi.color}`}>
                  <Icon className="w-4 h-4" />
                </div>
              </div>
              <div className="mt-3">
                <div className="flex items-baseline space-x-2">
                  <span className="text-2xl font-black text-[#0F172A] tracking-tight">
                    {kpi.value}
                  </span>
                  <span className="text-xs font-bold text-[#15803D]">
                    {kpi.delta}
                  </span>
                </div>
                <div className="text-[11px] text-[#94A3B8] mt-0.5">{kpi.subtitle}</div>
              </div>
            </div>
          );
        })}
      </div>

      {/* ── 2. Data Completeness & Quality Alert (Epic 1) ──────────────────── */}
      <div className="bg-[#FFFBEB] border border-[#FDE68A] p-5 rounded-xl shadow-sm">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="flex items-start space-x-3.5">
            <div className="p-2 bg-[#F59E0B] text-white rounded-lg shrink-0 mt-0.5">
              <AlertTriangle className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-extrabold text-[#92400E] text-sm md:text-base">
                Cảnh Báo Độ Đầy Đủ Dữ Liệu Du Lịch (Epic 1 – Data Completeness Quality)
              </h3>
              <p className="text-xs text-[#B45309] mt-1 leading-relaxed">
                Hệ thống phát hiện 3 điểm đến chưa đạt chuẩn 100% dữ liệu (thiếu Audio Guide đa ngữ, thiếu ảnh Panorama VR360 hoặc thiếu tọa độ trạm an toàn biển).
              </p>
            </div>
          </div>
          <button
            onClick={() => onNavigateToTab(1)}
            className="px-4 py-2 bg-[#B45309] hover:bg-[#92400E] text-white rounded-lg text-xs font-bold transition-colors flex items-center space-x-1.5 shrink-0 self-start md:self-auto shadow-sm"
          >
            <span>Bổ Sung Dữ Liệu Ngay</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </button>
        </div>

        {/* Quick Tags for Missing Items */}
        <div className="mt-4 pt-3 border-t border-[#FDE68A] flex flex-wrap gap-2.5">
          <button
            onClick={() => onNavigateToTab(1)}
            className="inline-flex items-center space-x-1.5 px-3 py-1.5 bg-white border border-[#FCD34D] rounded-lg text-xs hover:border-[#F59E0B] transition-colors"
          >
            <span className="font-bold text-[#92400E]">Vọng Hải Đài:</span>
            <span className="text-[#B45309]">Thiếu Audio Guide (KO, ZH)</span>
            <ArrowRight className="w-3 h-3 text-[#D97706]" />
          </button>

          <button
            onClick={() => onNavigateToTab(2)}
            className="inline-flex items-center space-x-1.5 px-3 py-1.5 bg-white border border-[#FCD34D] rounded-lg text-xs hover:border-[#F59E0B] transition-colors"
          >
            <span className="font-bold text-[#92400E]">Làng Đá Non Nước:</span>
            <span className="text-[#B45309]">Thiếu ảnh Panorama VR360</span>
            <ArrowRight className="w-3 h-3 text-[#D97706]" />
          </button>

          <button
            onClick={() => onNavigateToTab(4)}
            className="inline-flex items-center space-x-1.5 px-3 py-1.5 bg-white border border-[#FCD34D] rounded-lg text-xs hover:border-[#F59E0B] transition-colors"
          >
            <span className="font-bold text-[#92400E]">Bãi Tắm Tân Trà:</span>
            <span className="text-[#B45309]">Thiếu tọa độ Trạm Cứu Hộ Biển</span>
            <ArrowRight className="w-3 h-3 text-[#D97706]" />
          </button>
        </div>
      </div>

      {/* ── 3. Monthly Engagement Visualizer ────────────────────────────────── */}
      <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="font-extrabold text-[#0F172A] text-base">
              Lưu Lượng Tham Quan, Quét QR & Tương Tác VR360 (Năm 2026)
            </h3>
            <p className="text-xs text-[#64748B] mt-0.5">
              Dữ liệu tổng hợp từ các điểm di sản, phố đi bộ An Thượng, bãi biển và QR Sân bay
            </p>
          </div>
          <div className="flex items-center space-x-2 px-3 py-1.5 bg-[#F8FAFC] border border-[#E2E8F0] rounded-lg text-xs font-bold text-[#475569]">
            <Calendar className="w-3.5 h-3.5 text-[#64748B]" />
            <span>12 Tháng / 2026 • Quận Ngũ Hành Sơn</span>
          </div>
        </div>

        {/* Bar Visualizer */}
        <div className="h-48 flex items-end justify-between pt-6 px-4">
          {monthlyData.map((m, idx) => (
            <div key={idx} className="flex flex-col items-center flex-1 group">
              <span className="text-[10px] font-bold text-[#94A3B8] mb-1.5 group-hover:text-[#173F35] transition-colors">
                {m.label}
              </span>
              <div className="w-8 bg-[#F1F5F9] rounded-t-md h-36 flex items-end overflow-hidden">
                <div
                  style={{ height: `${m.val}%` }}
                  className="w-full bg-gradient-to-t from-[#0F2B24] to-[#244C40] rounded-t-md group-hover:from-[#173F35] group-hover:to-[#B69A67] transition-all"
                ></div>
              </div>
              <span className="text-xs font-bold text-[#64748B] mt-2 group-hover:text-[#0F172A]">
                {m.month}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* ── 4. Recent Audit Logs Table ─────────────────────────────────────── */}
      <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center space-x-2">
            <ShieldCheck className="w-5 h-5 text-[#173F35]" />
            <h3 className="font-extrabold text-[#0F172A] text-base">
              Nhật Ký Tác Vụ Gần Đây (Audit Logs – FE-28, LI-07)
            </h3>
          </div>
          <button
            onClick={() => onNavigateToTab(10)}
            className="text-xs font-bold text-[#173F35] hover:text-[#244C40] hover:underline flex items-center space-x-1"
          >
            <span>Xem toàn bộ nhật ký kiểm toán</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </button>
        </div>

        <div className="divide-y divide-[#E2E8F0]">
          {initialAuditLogs.map((log) => (
            <div key={log.id} className="py-3 flex items-center justify-between">
              <div className="flex items-center space-x-3">
                <span className="w-2 h-2 rounded-full bg-[#16A34A]"></span>
                <span className="text-sm font-semibold text-[#0F172A]">{log.action}</span>
                <span className="px-2 py-0.5 bg-[#F1F5F9] text-[#475569] text-xs rounded font-medium">
                  {log.module}
                </span>
              </div>
              <div className="flex items-center space-x-4 text-xs text-[#64748B]">
                <span>{log.user}</span>
                <div className="flex items-center space-x-1 text-[#94A3B8]">
                  <Clock className="w-3 h-3" />
                  <span>{log.timestamp}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
