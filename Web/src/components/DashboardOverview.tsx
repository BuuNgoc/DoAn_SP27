import React, { useState } from 'react';
import {
  Users,
  QrCode,
  Ticket,
  Landmark,
  TrendingUp,
  ArrowRight,
  Clock,
  CheckCircle2,
  AlertCircle,
  RefreshCw,
  Sparkles,
  MapPin,
  Calendar,
  Eye,
  AlertTriangle,
} from 'lucide-react';

interface DashboardOverviewProps {
  onNavigateToTab: (tabId: string) => void;
  isLoading?: boolean;
  hasError?: boolean;
  onRetry?: () => void;
}

export const DashboardOverview: React.FC<DashboardOverviewProps> = ({
  onNavigateToTab,
  isLoading = false,
  hasError = false,
  onRetry,
}) => {
  const [timeRange, setTimeRange] = useState<'7d' | '30d'>('7d');
  const [hoveredDayIndex, setHoveredDayIndex] = useState<number | null>(null);

  // ── ERROR STATE ────────────────────────────────────────────────────────
  if (hasError) {
    return (
      <div className="bg-white rounded-2xl border border-[#FCA5A5] p-12 text-center max-w-lg mx-auto shadow-sm my-12">
        <div className="w-16 h-16 rounded-full bg-[#FEF2F2] text-[#B83A2E] flex items-center justify-center mx-auto mb-4 border border-[#FCA5A5]">
          <AlertCircle className="w-8 h-8" />
        </div>
        <h3 className="font-serif text-xl font-bold text-[#173F35] mb-2">Đã xảy ra sự cố tải Dashboard</h3>
        <p className="text-xs text-[#777A73] mb-6">
          Không thể kết nối tới Cloud Firestore hoặc phiên kết nối đã hết hạn. Vui lòng thử lại.
        </p>
        <button
          onClick={onRetry}
          className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#173F35] text-white text-xs font-bold hover:bg-[#0F2B24] transition-all shadow-sm"
        >
          <RefreshCw className="w-4 h-4 text-[#E4B85E]" />
          <span>Thử lại ngay</span>
        </button>
      </div>
    );
  }

  // ── LOADING SKELETON ───────────────────────────────────────────────────
  if (isLoading) {
    return (
      <div className="space-y-6 animate-pulse">
        {/* Skeleton KPIs */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {[1, 2, 3, 4].map((i) => (
            <div key={i} className="h-32 bg-white rounded-2xl border border-[#E8DFD0] p-5 space-y-3">
              <div className="flex justify-between items-center">
                <div className="h-4 w-24 bg-[#E8DFD0] rounded"></div>
                <div className="w-9 h-9 rounded-xl bg-[#FAF7F2]"></div>
              </div>
              <div className="h-8 w-28 bg-[#E8DFD0] rounded"></div>
              <div className="h-3 w-36 bg-[#E8DFD0] rounded"></div>
            </div>
          ))}
        </div>

        {/* Skeleton Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          <div className="lg:col-span-8 h-80 bg-white rounded-2xl border border-[#E8DFD0] p-6"></div>
          <div className="lg:col-span-4 h-80 bg-white rounded-2xl border border-[#E8DFD0] p-6"></div>
        </div>

        {/* Skeleton Table */}
        <div className="h-64 bg-white rounded-2xl border border-[#E8DFD0] p-6"></div>
      </div>
    );
  }

  // ── DATA FOR 4 CORE KPIS ───────────────────────────────────────────────
  const kpis = [
    {
      id: 'kpi-users',
      title: 'Tổng Người Dùng',
      value: '12,480',
      delta: '+14.2%',
      trendUp: true,
      period: 'so với tuần trước',
      icon: Users,
      bgColor: 'bg-[#EBF2EF]',
      textColor: 'text-[#173F35]',
      iconColor: 'text-[#173F35]',
    },
    {
      id: 'kpi-qr',
      title: 'Lượt Quét QR Check-in',
      value: '4,320',
      delta: '+22.5%',
      trendUp: true,
      period: 'so với tuần trước',
      icon: QrCode,
      bgColor: 'bg-[#FBF8F2]',
      textColor: 'text-[#173F35]',
      iconColor: 'text-[#B69A67]',
    },
    {
      id: 'kpi-bookings',
      title: 'Đặt Chỗ Workshop & Tour',
      value: '285',
      delta: '+8.1%',
      trendUp: true,
      period: 'so với tuần trước',
      icon: Ticket,
      bgColor: 'bg-[#FEF3C7]',
      textColor: 'text-[#173F35]',
      iconColor: 'text-[#D97706]',
    },
    {
      id: 'kpi-destinations',
      title: 'Điểm Đến Đang Hoạt Động',
      value: '32',
      delta: '100% Online',
      trendUp: true,
      period: '5 cụm danh thắng đã số hóa',
      icon: Landmark,
      bgColor: 'bg-[#CCFBF1]',
      textColor: 'text-[#173F35]',
      iconColor: 'text-[#0D9488]',
    },
  ];

  // ── CHART 1 DATA: 7-DAY TREND (SVG INTERACTIVE AREA CHART) ──────────────
  const chartData7d = [
    { label: 'T2', checkins: 420, interactions: 1850 },
    { label: 'T3', checkins: 510, interactions: 2100 },
    { label: 'T4', checkins: 480, interactions: 2020 },
    { label: 'T5', checkins: 690, interactions: 2750 },
    { label: 'T6', checkins: 850, interactions: 3400 },
    { label: 'T7', checkins: 1120, interactions: 4600 },
    { label: 'CN', checkins: 1250, interactions: 5200 },
  ];

  const maxCheckin = 1400;
  const svgWidth = 600;
  const svgHeight = 200;
  const paddingX = 40;
  const paddingY = 20;

  // Calculate coordinates
  const points = chartData7d.map((d, index) => {
    const x = paddingX + (index * (svgWidth - 2 * paddingX)) / (chartData7d.length - 1);
    const y = svgHeight - paddingY - (d.checkins / maxCheckin) * (svgHeight - 2 * paddingY);
    return { x, y, ...d };
  });

  const pathD = points.reduce((acc, p, i) => {
    if (i === 0) return `M ${p.x} ${p.y}`;
    const prev = points[i - 1];
    const cpX = (prev.x + p.x) / 2;
    return `${acc} C ${cpX} ${prev.y}, ${cpX} ${p.y}, ${p.x} ${p.y}`;
  }, '');

  const areaD = `${pathD} L ${points[points.length - 1].x} ${svgHeight - paddingY} L ${points[0].x} ${svgHeight - paddingY} Z`;

  // ── CHART 2 DATA: 4 CLUSTERS DISTRIBUTION ──────────────────────────────
  const clusterData = [
    { name: 'Thủy Sơn (Di tích & Chùa)', percent: 48, count: '2,074 lượt', color: '#173F35', bgClass: 'bg-[#173F35]' },
    { name: 'Làng Đá Non Nước (Nghề)', percent: 24, count: '1,036 lượt', color: '#B69A67', bgClass: 'bg-[#B69A67]' },
    { name: 'Phố Đi Bộ An Thượng (Đêm)', percent: 18, count: '778 lượt', color: '#7C3AED', bgClass: 'bg-[#7C3AED]' },
    { name: 'Bãi Biển Sơn Thủy & Tân Trà', percent: 10, count: '432 lượt', color: '#0284C7', bgClass: 'bg-[#0284C7]' },
  ];

  // ── TABLE DATA: EXACTLY 5 RECENT ACTIONS NEEDING ATTENTION ──────────────
  const recentActivities = [
    {
      id: 'BK-1082',
      type: 'Workshop',
      title: 'Đặt chỗ Trải nghiệm Điêu khắc Đá Non Nước',
      subject: 'Du khách: David Miller (Anh) • 2 vé',
      status: 'Chờ duyệt',
      statusClass: 'bg-[#FEF3C7] text-[#D97706] border-[#FDE68A]',
      time: '12 phút trước',
      actionTab: 'events',
    },
    {
      id: 'RD-4421',
      type: 'Loyalty',
      title: 'Đổi Quà Lưu Niệm: Quạt Trầm & Tháp Đá',
      subject: 'Du khách: Nguyễn Văn An • -250 điểm',
      status: 'Đã đổi quà',
      statusClass: 'bg-[#EBF2EF] text-[#173F35] border-[#C7DCD4]',
      time: '34 phút trước',
      actionTab: 'loyalty',
    },
    {
      id: 'CK-9912',
      type: 'QR Check-in',
      title: 'Quét QR Check-in Động Huyền Không',
      subject: 'Du khách: Kim Min-soo (Hàn Quốc) • Geofence Valid',
      status: 'Hợp lệ',
      statusClass: 'bg-[#EBF2EF] text-[#173F35] border-[#C7DCD4]',
      time: '48 phút trước',
      actionTab: 'loyalty',
    },
    {
      id: 'ST-004',
      type: 'Cuộc thi',
      title: 'Tác phẩm dự thi Điêu khắc "Bồ Tát Quán Thế Âm"',
      subject: 'Nghệ nhân: Huỳnh Văn Quý • Làng đá Non Nước',
      status: 'Chờ duyệt',
      statusClass: 'bg-[#FEF3C7] text-[#D97706] border-[#FDE68A]',
      time: '1 giờ trước',
      actionTab: 'contests',
    },
    {
      id: 'BEACH-01',
      type: 'Cảnh báo biển',
      title: 'Bãi tắm Sơn Thủy & Non Nước cập nhật an toàn',
      subject: 'Cứu hộ bờ biển • Cắm cờ xanh (Biển êm, an toàn tắm)',
      status: 'Hoạt động',
      statusClass: 'bg-[#ECFDF5] text-[#059669] border-[#A7F3D0]',
      time: '2 giờ trước',
      actionTab: 'specialized-zones',
    },
  ];

  return (
    <div className="space-y-6">
      {/* ── HEADER BANNER: 3-SECOND HEALTH SUMMARY ───────────────────── */}
      <div className="bg-gradient-to-r from-[#173F35] via-[#1A453A] to-[#0F2B24] rounded-2xl p-6 text-white shadow-luxury flex flex-col md:flex-row md:items-center justify-between gap-4 border border-[#244C40]">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <span className="w-2.5 h-2.5 rounded-full bg-[#27AE60] animate-pulse"></span>
            <span className="text-xs font-bold uppercase tracking-wider text-[#E4B85E]">
              Hệ Thống Trực Tuyến 100%
            </span>
          </div>
          <h2 className="font-serif text-2xl font-bold tracking-tight">
            Tổng Quan Vận Hành Thông Minh
          </h2>
          <p className="text-xs text-[#E8DFD0]/80">
            Dữ liệu đồng bộ thời gian thực từ Cloud Firestore & Ban Quản Lý Quận Ngũ Hành Sơn.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={() => onNavigateToTab('analytics')}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/15 text-white text-xs font-semibold backdrop-blur-sm border border-white/20 transition-all"
          >
            <span>Báo Cáo Chi Tiết (FE-25)</span>
            <ArrowRight className="w-3.5 h-3.5 text-[#E4B85E]" />
          </button>
        </div>
      </div>

      {/* ── TẦNG 1: ĐÚNG 4 THẺ KPI CỐT LÕI (MINIMALIST & HIGH IMPACT) ──── */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {kpis.map((kpi) => {
          const Icon = kpi.icon;
          return (
            <div
              key={kpi.id}
              className="bg-white rounded-2xl border border-[#E8DFD0] p-5 shadow-card hover:shadow-luxury hover:border-[#B69A67]/40 transition-all flex flex-col justify-between"
            >
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold text-[#777A73]">
                  {kpi.title}
                </span>
                <div className={`w-9 h-9 rounded-xl ${kpi.bgColor} flex items-center justify-center ${kpi.iconColor}`}>
                  <Icon className="w-5 h-5 stroke-[1.8]" />
                </div>
              </div>

              <div className="my-2">
                <div className="font-serif text-3xl font-bold text-[#173F35] tracking-tight">
                  {kpi.value}
                </div>
              </div>

              <div className="flex items-center gap-2 text-xs pt-1 border-t border-[#F2F0EB]">
                <span className="inline-flex items-center gap-0.5 font-bold text-[#059669] bg-[#ECFDF5] px-1.5 py-0.5 rounded text-[11px]">
                  <TrendingUp className="w-3 h-3" />
                  {kpi.delta}
                </span>
                <span className="text-[#A1A39D] text-[11px] truncate">
                  {kpi.period}
                </span>
              </div>
            </div>
          );
        })}
      </div>

      {/* ── TẦNG 2: TỐI ĐA 2 BIỂU ĐỒ TRỰC QUAN (7/30 DAYS & 4 CLUSTERS) ─ */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Biểu đồ 1: Xu Hướng Quét QR & Tương Tác (8 Cột) */}
        <div className="lg:col-span-8 bg-white rounded-2xl border border-[#E8DFD0] p-6 shadow-card flex flex-col justify-between">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between pb-4 border-b border-[#E8DFD0] gap-3">
            <div>
              <h3 className="font-serif text-base font-bold text-[#173F35]">
                Xu Hướng Lượt Quét QR & Tương Tác
              </h3>
              <p className="text-xs text-[#777A73]">
                Theo dõi lưu lượng du khách đến tham quan thực địa
              </p>
            </div>

            <div className="flex items-center gap-2">
              <div className="inline-flex rounded-lg border border-[#E8DFD0] p-0.5 bg-[#FAF7F2]">
                <button
                  onClick={() => setTimeRange('7d')}
                  className={`px-2.5 py-1 text-xs font-semibold rounded-md transition-all ${
                    timeRange === '7d'
                      ? 'bg-[#173F35] text-white shadow-sm'
                      : 'text-[#777A73] hover:text-[#173F35]'
                  }`}
                >
                  7 Ngày
                </button>
                <button
                  onClick={() => setTimeRange('30d')}
                  className={`px-2.5 py-1 text-xs font-semibold rounded-md transition-all ${
                    timeRange === '30d'
                      ? 'bg-[#173F35] text-white shadow-sm'
                      : 'text-[#777A73] hover:text-[#173F35]'
                  }`}
                >
                  30 Ngày
                </button>
              </div>
            </div>
          </div>

          {/* SVG Interactive Area Chart */}
          <div className="relative pt-6 pb-2">
            <svg
              viewBox={`0 0 ${svgWidth} ${svgHeight}`}
              className="w-full h-48 overflow-visible"
            >
              <defs>
                <linearGradient id="areaGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#173F35" stopOpacity="0.25" />
                  <stop offset="100%" stopColor="#173F35" stopOpacity="0.0" />
                </linearGradient>
              </defs>

              {/* Grid Lines */}
              <line x1={paddingX} y1={paddingY} x2={svgWidth - paddingX} y2={paddingY} stroke="#F2F0EB" strokeDasharray="3 3" />
              <line x1={paddingX} y1={svgHeight / 2} x2={svgWidth - paddingX} y2={svgHeight / 2} stroke="#F2F0EB" strokeDasharray="3 3" />
              <line x1={paddingX} y1={svgHeight - paddingY} x2={svgWidth - paddingX} y2={svgHeight - paddingY} stroke="#E8DFD0" />

              {/* Area & Line */}
              <path d={areaD} fill="url(#areaGradient)" />
              <path d={pathD} fill="none" stroke="#173F35" strokeWidth="3" strokeLinecap="round" />

              {/* Data Points */}
              {points.map((p, idx) => {
                const isHovered = hoveredDayIndex === idx;
                return (
                  <g
                    key={p.label}
                    onMouseEnter={() => setHoveredDayIndex(idx)}
                    onMouseLeave={() => setHoveredDayIndex(null)}
                    className="cursor-pointer"
                  >
                    <circle
                      cx={p.x}
                      cy={p.y}
                      r={isHovered ? 6 : 4}
                      fill={isHovered ? '#E4B85E' : '#173F35'}
                      stroke="white"
                      strokeWidth="2"
                      className="transition-all"
                    />
                    <text
                      x={p.x}
                      y={svgHeight}
                      textAnchor="middle"
                      className="text-[11px] fill-[#777A73] font-semibold"
                    >
                      {p.label}
                    </text>
                  </g>
                );
              })}
            </svg>

            {/* Hover Tooltip */}
            {hoveredDayIndex !== null && (
              <div
                className="absolute top-2 bg-[#173F35] text-white p-2.5 rounded-lg shadow-xl text-xs z-10 pointer-events-none transition-all border border-[#B69A67]"
                style={{
                  left: `${points[hoveredDayIndex].x - 60}px`,
                }}
              >
                <div className="font-bold text-[#E4B85E]">
                  {points[hoveredDayIndex].label} (Ngũ Hành Sơn)
                </div>
                <div className="text-[11px] mt-0.5">
                  Lượt Quét QR: <strong>{points[hoveredDayIndex].checkins.toLocaleString()}</strong>
                </div>
                <div className="text-[10px] text-white/70">
                  Tương tác app: {points[hoveredDayIndex].interactions.toLocaleString()}
                </div>
              </div>
            )}
          </div>

          <div className="flex items-center justify-between pt-3 border-t border-[#F2F0EB] text-[11px] text-[#777A73]">
            <div className="flex items-center gap-4">
              <span className="flex items-center gap-1.5">
                <span className="w-2.5 h-2.5 rounded-full bg-[#173F35]"></span>
                Lượt Check-in QR thực địa
              </span>
              <span className="flex items-center gap-1.5">
                <span className="w-2.5 h-2.5 rounded-full bg-[#B69A67]"></span>
                Đỉnh cao điểm: Thứ Bảy & Chủ Nhật
              </span>
            </div>
            <span className="font-semibold text-[#173F35]">Đạt 118% chỉ tiêu tuần</span>
          </div>
        </div>

        {/* Biểu đồ 2: Tỷ Trọng 4 Cụm Trọng Điểm (4 Cột) */}
        <div className="lg:col-span-4 bg-white rounded-2xl border border-[#E8DFD0] p-6 shadow-card flex flex-col justify-between">
          <div className="pb-4 border-b border-[#E8DFD0]">
            <h3 className="font-serif text-base font-bold text-[#173F35]">
              Phân Bố 4 Cụm Trọng Điểm
            </h3>
            <p className="text-xs text-[#777A73]">
              Tỷ trọng lượng khách tham quan theo khu vực
            </p>
          </div>

          {/* Clean Visual Distribution Bars */}
          <div className="space-y-4 my-auto py-2">
            {clusterData.map((cluster) => (
              <div key={cluster.name} className="space-y-1.5">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-bold text-[#242824] truncate">{cluster.name}</span>
                  <div className="flex items-center gap-2">
                    <span className="text-[11px] text-[#777A73]">{cluster.count}</span>
                    <span className="font-bold text-[#173F35] w-9 text-right">{cluster.percent}%</span>
                  </div>
                </div>
                {/* Horizontal Progress Bar */}
                <div className="w-full h-2.5 rounded-full bg-[#F2F0EB] overflow-hidden">
                  <div
                    className={`h-full rounded-full transition-all duration-700 ${cluster.bgClass}`}
                    style={{ width: `${cluster.percent}%` }}
                  ></div>
                </div>
              </div>
            ))}
          </div>

          <div className="pt-3 border-t border-[#F2F0EB]">
            <button
              onClick={() => onNavigateToTab('destinations')}
              className="w-full flex items-center justify-center gap-1.5 py-2 rounded-xl bg-[#FAF7F2] hover:bg-[#F2ECE1] text-[#173F35] text-xs font-semibold transition-all border border-[#E8DFD0]"
            >
              <span>Quản lý 32 Điểm Đến (FE-17)</span>
              <ArrowRight className="w-3.5 h-3.5 text-[#B69A67]" />
            </button>
          </div>
        </div>
      </div>

      {/* ── TẦNG 3: BẢNG TÓM TẮT ĐÚNG 5 DÒNG (RECENT ACTIONS NEEDING CARE) ─ */}
      <div className="bg-white rounded-2xl border border-[#E8DFD0] shadow-card overflow-hidden">
        <div className="p-5 border-b border-[#E8DFD0] flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-2 h-2 rounded-full bg-[#E4B85E]"></div>
            <div>
              <h3 className="font-serif text-base font-bold text-[#173F35]">
                Hoạt Động Cần Xử Lý Gần Nhất
              </h3>
              <p className="text-xs text-[#777A73]">
                Tóm tắt 5 mục mới phát sinh yêu cầu phê duyệt hoặc xác nhận
              </p>
            </div>
          </div>

          <button
            onClick={() => onNavigateToTab('events')}
            className="inline-flex items-center gap-1.5 text-xs font-bold text-[#B69A67] hover:text-[#173F35] transition-colors"
          >
            <span>Xem Tất Cả</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </button>
        </div>

        {/* 5 Rows Table */}
        <div className="divide-y divide-[#F2F0EB]">
          {recentActivities.map((act) => (
            <div
              key={act.id}
              className="p-4 sm:px-6 flex flex-col sm:flex-row sm:items-center justify-between gap-3 hover:bg-[#FAF7F2] transition-colors group"
            >
              <div className="flex items-center gap-3.5">
                <span className="font-mono text-xs font-bold text-[#777A73] bg-[#FAF7F2] px-2 py-1 rounded border border-[#E8DFD0]">
                  {act.id}
                </span>
                <div>
                  <div className="text-xs font-bold text-[#242824] group-hover:text-[#173F35] transition-colors">
                    {act.title}
                  </div>
                  <div className="text-[11px] text-[#777A73] flex items-center gap-2 mt-0.5">
                    <span>{act.subject}</span>
                    <span>•</span>
                    <span className="flex items-center gap-1 text-[#A1A39D]">
                      <Clock className="w-3 h-3" />
                      {act.time}
                    </span>
                  </div>
                </div>
              </div>

              <div className="flex items-center gap-3 self-end sm:self-center">
                <span
                  className={`text-[10px] font-bold px-2.5 py-1 rounded-full border ${act.statusClass}`}
                >
                  {act.status}
                </span>

                <button
                  onClick={() => onNavigateToTab(act.actionTab)}
                  className="px-3 py-1 text-xs font-semibold text-[#173F35] hover:bg-[#EBF2EF] rounded-lg transition-colors border border-transparent hover:border-[#C7DCD4]"
                >
                  Xử lý
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
