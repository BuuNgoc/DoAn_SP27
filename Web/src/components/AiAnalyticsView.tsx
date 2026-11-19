import React from 'react';
import {
  ScanEye,
  CheckCircle2,
  Sparkles,
  RefreshCw,
  Zap,
  Activity,
  Layers,
} from 'lucide-react';

export const AiAnalyticsView: React.FC = () => {
  const topSpots = [
    {
      rank: '#1',
      name: 'Động Huyền Không (Vòm Trời)',
      scans: '4,620 lượt',
      acc: '98.5%',
      checkin: '4,150 (89.8%)',
      ws: 'Tour Tâm Linh & Ma Nhai',
    },
    {
      rank: '#2',
      name: 'Chùa Linh Ứng Non Nước',
      scans: '3,840 lượt',
      acc: '97.2%',
      checkin: '3,380 (88.0%)',
      ws: 'Vòng Tay Cẩm Thạch',
    },
    {
      rank: '#3',
      name: 'Cổng Làng Đá Mỹ Nghệ Non Nước',
      scans: '2,950 lượt',
      acc: '96.1%',
      checkin: '2,710 (91.8%)',
      ws: 'Workshop Đục Đẽo Đá Chibi',
    },
    {
      rank: '#4',
      name: 'Vọng Hải Đài (Đỉnh Thủy Sơn)',
      scans: '2,140 lượt',
      acc: '95.4%',
      checkin: '1,890 (88.3%)',
      ws: 'Tuyến Di Sản Thủy Sơn',
    },
    {
      rank: '#5',
      name: 'Động Âm Phủ & Cầu Âm Dương',
      scans: '1,340 lượt',
      acc: '94.8%',
      checkin: '1,120 (83.5%)',
      ws: 'Khám Phá Hang Động 360',
    },
  ];

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Thống Kê Mô Hình AI Nhận Diện Địa Danh (FE-05, Epic 5)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Báo cáo các điểm đến được nhận diện nhiều nhất, độ chính xác phân loại & tỷ lệ kích hoạt gợi ý Check-in / Workshop
          </p>
        </div>
        <div className="flex items-center space-x-1.5 px-3 py-1 bg-[#DCFCE7] text-[#15803D] rounded-full text-xs font-bold">
          <Activity className="w-3.5 h-3.5" />
          <span>Model Status: ONLINE (SE13-ResNet50-V2)</span>
        </div>
      </div>

      {/* ── Performance Metrics ───────────────────────────────────────────── */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="p-4 rounded-xl bg-[#EDE9FE] border border-[#DDD6FE]">
          <span className="text-xs font-bold text-[#6D28D9]">Độ Chính Xác (Accuracy)</span>
          <div className="text-xl font-black text-[#7C3AED] mt-1">96.8%</div>
        </div>
        <div className="p-4 rounded-xl bg-[#CCFBF1] border border-[#99F6E4]">
          <span className="text-xs font-bold text-[#0F766E]">Thời Gian Xử Lý (Latency)</span>
          <div className="text-xl font-black text-[#0D9488] mt-1">285 ms</div>
        </div>
        <div className="p-4 rounded-xl bg-[#DBEAFE] border border-[#BFDBFE]">
          <span className="text-xs font-bold text-[#1E40AF]">Tổng Ảnh Đã Quét</span>
          <div className="text-xl font-black text-[#2563EB] mt-1">14,890</div>
        </div>
        <div className="p-4 rounded-xl bg-[#DCFCE7] border border-[#86EFAC]">
          <span className="text-xs font-bold text-[#15803D]">Gợi Ý Check-in Tự Động</span>
          <div className="text-xl font-black text-[#16A34A] mt-1">89.4%</div>
        </div>
      </div>

      {/* ── Rankings Table ────────────────────────────────────────────────── */}
      <div className="space-y-3">
        <h4 className="text-xs font-extrabold text-[#94A3B8] uppercase tracking-wider">
          Top Địa Danh Được Du Khách Chụp Ảnh & Nhận Diện Nhiều Nhất (Epic 5)
        </h4>

        <div className="overflow-x-auto border border-[#E2E8F0] rounded-xl">
          <table className="w-full text-left text-sm">
            <thead className="bg-[#F8FAFC] border-b border-[#E2E8F0] text-xs font-extrabold text-[#475569] uppercase">
              <tr>
                <th className="py-3 px-4">Hạng</th>
                <th className="py-3 px-4">Tên Danh Thắng / Di Tích</th>
                <th className="py-3 px-4">Lượt Nhận Diện</th>
                <th className="py-3 px-4">Độ Chính Xác</th>
                <th className="py-3 px-4">Gợi Ý Check-in</th>
                <th className="py-3 px-4">Workshop Gợi Ý</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E2E8F0]">
              {topSpots.map((s) => (
                <tr key={s.rank} className="hover:bg-[#F8FAFC]">
                  <td className="py-3 px-4 font-black text-xs text-[#D97706]">{s.rank}</td>
                  <td className="py-3 px-4 font-bold text-sm text-[#0F172A]">{s.name}</td>
                  <td className="py-3 px-4 text-xs font-semibold text-[#475569]">{s.scans}</td>
                  <td className="py-3 px-4 text-xs font-bold text-[#16A34A]">{s.acc}</td>
                  <td className="py-3 px-4 text-xs text-[#64748B]">{s.checkin}</td>
                  <td className="py-3 px-4 text-xs font-bold text-[#173F35]">{s.ws}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* ── Dataset Sync ──────────────────────────────────────────────────── */}
      <div className="p-4 rounded-xl bg-[#F8FAFC] border border-[#E2E8F0] flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <Layers className="w-6 h-6 text-[#173F35]" />
          <div>
            <div className="font-bold text-sm text-[#0F172A]">
              Quản Lý Nhãn Huấn Luyện Dataset (18 Lớp Đối Tượng Ngũ Hành Sơn)
            </div>
            <div className="text-xs text-[#64748B]">
              Liên kết trực tiếp AI_Service/train_model.py • Bộ ảnh huấn luyện thực địa
            </div>
          </div>
        </div>
        <button className="px-4 py-2 bg-[#173F35] hover:bg-[#244C40] text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center space-x-1.5">
          <RefreshCw className="w-3.5 h-3.5" />
          <span>Đồng Bộ Dataset Mới</span>
        </button>
      </div>
    </div>
  );
};
