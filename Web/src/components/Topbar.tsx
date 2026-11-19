import React from 'react';
import {
  Search,
  Bell,
  RefreshCw,
  ExternalLink,
  ShieldCheck,
  UserCheck,
} from 'lucide-react';
import { AdminUserProfile } from '../services/firebase';
import { navItems } from './Sidebar';

interface TopbarProps {
  currentTab: string;
  currentUser: AdminUserProfile | null;
  onRefreshData?: () => void;
  isRefreshing?: boolean;
  onNavigateLanding: () => void;
}

export const Topbar: React.FC<TopbarProps> = ({
  currentTab,
  currentUser,
  onRefreshData,
  isRefreshing,
  onNavigateLanding,
}) => {
  const currentItem = navItems.find((i) => i.id === currentTab) || navItems[0];
  const isAdmin = currentUser?.role === 'ADMIN';

  return (
    <header className="h-16 bg-white border-b border-[#E8DFD0] px-6 flex items-center justify-between z-20 shadow-sm">
      {/* ── Left: Breadcrumb & Title ─────────────────────────────────── */}
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2 text-xs text-[#777A73]">
          <span className="font-semibold text-[#173F35]">Quản Trị</span>
          <span>/</span>
          <span className="text-[#242824] font-bold">{currentItem.title}</span>
        </div>
      </div>

      {/* ── Right: Quick Actions & Profile ────────────────────────────── */}
      <div className="flex items-center gap-4">
        {/* Refresh Data Button */}
        {onRefreshData && (
          <button
            onClick={onRefreshData}
            disabled={isRefreshing}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-[#E8DFD0] bg-[#FAF7F2] hover:bg-[#F2ECE1] text-[#173F35] text-xs font-semibold transition-all disabled:opacity-50"
            title="Đồng bộ lại dữ liệu từ Cloud Firestore"
          >
            <RefreshCw className={`w-3.5 h-3.5 text-[#B69A67] ${isRefreshing ? 'animate-spin' : ''}`} />
            <span className="hidden sm:inline">Làm Mới</span>
          </button>
        )}

        {/* View Public Landing Page */}
        <button
          onClick={onNavigateLanding}
          className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-lg border border-[#E8DFD0] text-[#777A73] hover:text-[#173F35] hover:border-[#B69A67] text-xs font-medium transition-all"
        >
          <ExternalLink className="w-3.5 h-3.5 text-[#B69A67]" />
          <span>Xem Trang Chủ</span>
        </button>

        {/* Notifications */}
        <div className="relative">
          <button
            className="w-9 h-9 rounded-lg bg-[#FAF7F2] border border-[#E8DFD0] flex items-center justify-center text-[#777A73] hover:text-[#173F35] transition-colors relative"
            title="Thông báo hệ thống"
          >
            <Bell className="w-4 h-4" />
            <span className="absolute 1 top-1.5 right-1.5 w-2 h-2 rounded-full bg-[#B83A2E]"></span>
          </button>
        </div>

        {/* User Role Badge & Chip */}
        <div className="flex items-center gap-2.5 pl-2 border-l border-[#E8DFD0]">
          <div className="text-right hidden sm:block">
            <div className="text-xs font-bold text-[#173F35] leading-tight">
              {currentUser?.displayName || 'Quản trị viên'}
            </div>
            <div className="flex items-center justify-end gap-1 mt-0.5">
              <span
                className={`text-[9px] font-bold px-1.5 py-0.2 rounded uppercase ${
                  isAdmin
                    ? 'bg-[#173F35] text-[#E4B85E]'
                    : 'bg-[#B69A67] text-white'
                }`}
              >
                {isAdmin ? 'ADMIN' : 'MANAGER'}
              </span>
            </div>
          </div>

          <div
            className={`w-9 h-9 rounded-xl flex items-center justify-center font-bold text-xs shadow-sm border ${
              isAdmin
                ? 'bg-[#173F35] text-[#E4B85E] border-[#B69A67]'
                : 'bg-[#EBF2EF] text-[#173F35] border-[#C7DCD4]'
            }`}
          >
            {isAdmin ? <ShieldCheck className="w-4 h-4" /> : <UserCheck className="w-4 h-4" />}
          </div>
        </div>
      </div>
    </header>
  );
};
