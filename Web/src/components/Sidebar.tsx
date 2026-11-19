import React from 'react';
import {
  LayoutDashboard,
  BarChart3,
  Landmark,
  Compass,
  Moon,
  Ticket,
  Hammer,
  Trophy,
  QrCode,
  Plane,
  Users,
  ShieldCheck,
  ChevronRight,
  LogOut,
  ExternalLink,
  ChevronLeft,
} from 'lucide-react';
import { AdminUserProfile } from '../services/firebase';

export interface NavItem {
  id: string;
  title: string;
  icon: React.ElementType;
  group: number;
  badge?: string;
  badgeColor?: string;
  adminOnly?: boolean;
}

export const navGroups = [
  { id: 0, title: 'TỔNG QUAN HỆ THỐNG' },
  { id: 1, title: 'NỘI DUNG DU LỊCH' },
  { id: 2, title: 'SỰ KIỆN & LÀNG NGHỀ' },
  { id: 3, title: 'CHECK-IN & QUẢNG BÁ' },
  { id: 4, title: 'QUẢN TRỊ HỆ THỐNG' },
];

export const navItems: NavItem[] = [
  // Nhóm 0: Tổng quan
  { id: 'dashboard', title: 'Dashboard Vận Hành', icon: LayoutDashboard, group: 0 },
  { id: 'analytics', title: 'Thống Kê & Báo Cáo', icon: BarChart3, group: 0, badge: 'FE-25' },

  // Nhóm 1: Nội dung Du lịch
  { id: 'destinations', title: 'Điểm Đến & Danh Mục', icon: Landmark, group: 1, badge: 'FE-17' },
  { id: 'specialized-zones', title: 'An Thượng & Bãi Biển', icon: Moon, group: 1, badge: 'FE-23' },
  { id: 'multimedia', title: 'VR360 & Audio Guide', icon: Compass, group: 1, badge: 'FE-18' },

  // Nhóm 2: Sự kiện & Làng nghề
  { id: 'events', title: 'Sự Kiện & Workshop', icon: Ticket, group: 2, badge: 'FE-19' },
  { id: 'artisans', title: 'Nghệ Nhân Làng Đá', icon: Hammer, group: 2, badge: 'FE-21' },
  { id: 'contests', title: 'Cuộc Thi Điêu Khắc Đá', icon: Trophy, group: 2, badge: 'FE-22' },

  // Nhóm 3: Check-in, Quà tặng & Quảng bá
  { id: 'loyalty', title: 'Trạm QR & Đổi Quà', icon: QrCode, group: 3, badge: 'FE-20' },
  { id: 'campaigns', title: 'Chiến Dịch Sân Bay', icon: Plane, group: 3, badge: 'FE-24' },

  // Nhóm 4: Quản trị Hệ thống
  { id: 'users', title: 'Người Dùng & RBAC', icon: Users, group: 4, badge: 'FE-26/27', adminOnly: true },
  { id: 'system', title: 'Hệ Thống & Audit Logs', icon: ShieldCheck, group: 4, badge: 'FE-28', adminOnly: true },
];

interface SidebarProps {
  currentTab: string;
  onSelectTab: (tabId: string) => void;
  currentUser: AdminUserProfile | null;
  onLogout: () => void;
  onNavigateLanding: () => void;
  collapsed: boolean;
  onToggleCollapsed: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  currentTab,
  onSelectTab,
  currentUser,
  onLogout,
  onNavigateLanding,
  collapsed,
  onToggleCollapsed,
}) => {
  const isAdmin = currentUser?.role === 'ADMIN';

  return (
    <aside
      className={`relative flex flex-col bg-[#173F35] text-[#FAF7F2] border-r border-[#244C40] transition-all duration-300 z-30 flex-shrink-0 ${
        collapsed ? 'w-20' : 'w-64'
      }`}
    >
      {/* ── Brand Header ─────────────────────────────────────────────── */}
      <div className="h-16 flex items-center justify-between px-4 border-b border-[#244C40]">
        <div className="flex items-center gap-3 overflow-hidden cursor-pointer" onClick={onNavigateLanding}>
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#1A453A] to-[#0F2B24] flex items-center justify-center text-[#E4B85E] border border-[#B69A67]/40 flex-shrink-0 shadow-sm">
            <Compass className="w-5 h-5 stroke-[1.8]" />
          </div>
          {!collapsed && (
            <div className="leading-tight">
              <span className="font-serif font-bold text-sm tracking-wide text-white block">
                SmartTravel
              </span>
              <span className="text-[10px] text-[#E4B85E] tracking-widest uppercase font-semibold block">
                Ngũ Hành Sơn
              </span>
            </div>
          )}
        </div>

        <button
          onClick={onToggleCollapsed}
          className="w-7 h-7 rounded-lg bg-[#244C40] hover:bg-[#2D5A4C] text-[#E8DFD0] flex items-center justify-center transition-colors"
          title={collapsed ? 'Mở rộng menu' : 'Thu gọn menu'}
        >
          {collapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
        </button>
      </div>

      {/* ── Navigation Items grouped by 5 groups ────────────────────── */}
      <div className="flex-1 overflow-y-auto py-4 px-3 space-y-6 no-scrollbar">
        {navGroups.map((group) => {
          const items = navItems.filter((item) => {
            if (item.group !== group.id) return false;
            if (item.adminOnly && !isAdmin) return false;
            return true;
          });

          if (items.length === 0) return null;

          return (
            <div key={group.id} className="space-y-1">
              {!collapsed && (
                <div className="px-3 pb-1 text-[10px] font-bold text-[#A1A39D] uppercase tracking-wider">
                  {group.title}
                </div>
              )}
              {items.map((item) => {
                const Icon = item.icon;
                const isActive = currentTab === item.id;

                return (
                  <button
                    key={item.id}
                    onClick={() => onSelectTab(item.id)}
                    title={collapsed ? item.title : undefined}
                    className={`w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition-all group ${
                      isActive
                        ? 'bg-[#EBF2EF] text-[#173F35] shadow-sm font-bold'
                        : 'text-[#E8DFD0] hover:bg-[#244C40] hover:text-white'
                    }`}
                  >
                    <Icon
                      className={`w-4 h-4 flex-shrink-0 transition-transform group-hover:scale-110 ${
                        isActive ? 'text-[#173F35]' : 'text-[#B69A67]'
                      }`}
                    />

                    {!collapsed && (
                      <span className="truncate flex-1 text-left">{item.title}</span>
                    )}

                    {!collapsed && item.badge && (
                      <span
                        className={`text-[9px] px-1.5 py-0.5 rounded font-mono font-bold ${
                          isActive
                            ? 'bg-[#173F35] text-[#E4B85E]'
                            : 'bg-[#244C40] text-[#A1A39D]'
                        }`}
                      >
                        {item.badge}
                      </span>
                    )}
                  </button>
                );
              })}
            </div>
          );
        })}
      </div>

      {/* ── User Profile & Logout Bottom Section ─────────────────────── */}
      <div className="p-3 border-t border-[#244C40] bg-[#0F2B24]/60">
        {!collapsed ? (
          <div className="space-y-3">
            <div className="flex items-center gap-3 px-2">
              <div className="w-9 h-9 rounded-full bg-[#B69A67] text-white flex items-center justify-center font-bold text-xs flex-shrink-0 border border-white/20">
                {currentUser?.displayName ? currentUser.displayName.slice(0, 2).toUpperCase() : 'AD'}
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-xs font-bold text-white truncate">
                  {currentUser?.displayName || 'Quản trị viên'}
                </div>
                <div className="text-[10px] text-[#E4B85E] font-medium truncate">
                  {currentUser?.role === 'ADMIN' ? 'Tổng Quản Trị' : 'Cán Bộ Quản Lý'}
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-2 pt-1">
              <button
                onClick={onNavigateLanding}
                className="flex items-center justify-center gap-1.5 px-2 py-1.5 rounded-lg bg-[#244C40] hover:bg-[#2D5A4C] text-[#E8DFD0] text-[11px] font-semibold transition-colors"
                title="Xem Landing Page công cộng"
              >
                <ExternalLink className="w-3.5 h-3.5 text-[#B69A67]" />
                <span>Trang Chủ</span>
              </button>

              <button
                onClick={onLogout}
                className="flex items-center justify-center gap-1.5 px-2 py-1.5 rounded-lg bg-[#B83A2E]/20 hover:bg-[#B83A2E]/30 text-[#FCA5A5] text-[11px] font-semibold transition-colors border border-[#B83A2E]/40"
                title="Đăng xuất khỏi hệ thống"
              >
                <LogOut className="w-3.5 h-3.5" />
                <span>Đăng xuất</span>
              </button>
            </div>
          </div>
        ) : (
          <div className="flex flex-col items-center gap-2">
            <div
              className="w-9 h-9 rounded-full bg-[#B69A67] text-white flex items-center justify-center font-bold text-xs border border-white/20"
              title={currentUser?.displayName || 'Quản trị viên'}
            >
              {currentUser?.displayName ? currentUser.displayName.slice(0, 2).toUpperCase() : 'AD'}
            </div>
            <button
              onClick={onLogout}
              className="w-8 h-8 rounded-lg bg-[#B83A2E]/20 text-[#FCA5A5] flex items-center justify-center hover:bg-[#B83A2E]/30"
              title="Đăng xuất"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        )}
      </div>
    </aside>
  );
};
