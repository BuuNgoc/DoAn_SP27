import React from 'react';
import {
  LayoutDashboard,
  Landmark,
  Compass,
  Moon,
  Umbrella,
  Trophy,
  Ticket,
  QrCode,
  ScanEye,
  Users,
  ShieldCheck,
  ExternalLink,
} from 'lucide-react';

interface SidebarProps {
  currentTab: number;
  onSelectTab: (index: number) => void;
}

export const navItems = [
  // Group 0: Core Data (Di Sản & Media 360)
  { id: 0, title: 'Tổng Quan Dashboard', icon: LayoutDashboard, category: 0, badge: '' },
  { id: 1, title: 'Quản Lý Điểm Đến (CMS)', icon: Landmark, category: 0, badge: 'Epic 1' },
  { id: 2, title: 'VR360 & Hotspot Builder', icon: Compass, category: 0, badge: 'Epic 4' },

  // Group 1: Area Expansion (An Thượng & Biển)
  { id: 3, title: 'Mở Rộng Phố An Thượng', icon: Moon, category: 1, badge: 'Epic 2' },
  { id: 4, title: 'Du Lịch Biển & Cảnh Báo', icon: Umbrella, category: 1, badge: 'Epic 3' },

  // Group 2: Craft & Promotion (Làng Nghề, Workshop, Chiến Dịch QR)
  { id: 5, title: 'Cuộc Thi Điêu Khắc Đá', icon: Trophy, category: 2, badge: 'Epic 6' },
  { id: 6, title: 'Workshop & Vé QR Check-in', icon: Ticket, category: 2, badge: 'Epic 7' },
  { id: 7, title: 'Chiến Dịch QR & Sân Bay', icon: QrCode, category: 2, badge: 'Epic 8' },

  // Group 3: AI & System
  { id: 8, title: 'Thống Kê AI Nhận Diện Ảnh', icon: ScanEye, category: 3, badge: 'Epic 5' },
  { id: 9, title: 'Người Dùng & Phân Quyền', icon: Users, category: 3, badge: 'RBAC' },
  { id: 10, title: 'Audit Logs & Sao Lưu', icon: ShieldCheck, category: 3, badge: 'FE-28' },
];

export const Sidebar: React.FC<SidebarProps> = ({ currentTab, onSelectTab }) => {
  const getCategoryTitle = (category: number) => {
    switch (category) {
      case 1:
        return 'MỞ RỘNG VÙNG & BIỂN';
      case 2:
        return 'LÀNG NGHỀ & TRUYỀN THÔNG';
      case 3:
        return 'TRÍ TUỆ NHÂN TẠO & HỆ THỐNG';
      default:
        return 'DỮ LIỆU CỐT LÕI';
    }
  };

  return (
    <aside className="w-72 bg-white border-r border-[#E2E8F0] flex flex-col h-screen select-none shrink-0 shadow-sm">
      {/* Brand Header */}
      <div className="p-5 border-b border-[#E2E8F0] flex items-center space-x-3">
        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#173F35] to-[#244C40] flex items-center justify-center text-white shadow-md shadow-[#173F35]/20">
          <Landmark className="w-5 h-5" />
        </div>
        <div>
          <h1 className="font-extrabold text-[#0F172A] text-base tracking-tight leading-tight">
            NHS360 WEB CMS
          </h1>
          <p className="text-xs font-semibold text-[#64748B]">Smart Travel Ngũ Hành Sơn</p>
        </div>
      </div>

      {/* Navigation List */}
      <div className="flex-1 overflow-y-auto px-3 py-4 space-y-1">
        {navItems.map((item, idx) => {
          const isCategoryStart =
            idx === 0 || navItems[idx - 1].category !== item.category;
          const isSelected = currentTab === item.id;
          const Icon = item.icon;

          return (
            <React.Fragment key={item.id}>
              {isCategoryStart && (
                <div className="pt-4 pb-1.5 px-3">
                  <span className="text-[10px] font-extrabold text-[#94A3B8] tracking-wider uppercase">
                    {getCategoryTitle(item.category)}
                  </span>
                </div>
              )}
              <button
                onClick={() => onSelectTab(item.id)}
                className={`w-full flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-semibold transition-all ${
                  isSelected
                    ? 'bg-[#173F35] text-white shadow-sm'
                    : 'text-[#475569] hover:bg-[#F8FAFC] hover:text-[#0F172A]'
                }`}
              >
                <div className="flex items-center space-x-3 truncate">
                  <Icon
                    className={`w-4 h-4 shrink-0 ${
                      isSelected ? 'text-[#B69A67]' : 'text-[#64748B]'
                    }`}
                  />
                  <span className="truncate">{item.title}</span>
                </div>
                {item.badge && (
                  <span
                    className={`text-[10px] px-1.5 py-0.5 rounded font-extrabold shrink-0 ${
                      isSelected
                        ? 'bg-white/20 text-white'
                        : 'bg-[#F1F5F9] text-[#64748B]'
                    }`}
                  >
                    {item.badge}
                  </span>
                )}
              </button>
            </React.Fragment>
          );
        })}
      </div>

      {/* Footer Info */}
      <div className="p-4 border-t border-[#E2E8F0] bg-[#F8FAFC]">
        <div className="flex items-center justify-between text-xs text-[#64748B]">
          <span className="font-semibold">ReactJS + TypeScript</span>
          <span className="bg-[#E2E8F0] px-2 py-0.5 rounded text-[11px] font-bold">
            Port 3000
          </span>
        </div>
        <div className="mt-2 text-[11px] text-[#94A3B8]">
          Bản quyền thuộc SE13 – Smart Travel 360
        </div>
      </div>
    </aside>
  );
};
