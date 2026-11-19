import React from 'react';
import { Search, Bell, ShieldCheck, Globe } from 'lucide-react';

interface TopbarProps {
  title: string;
  badge?: string;
  searchQuery: string;
  onSearchChange: (query: string) => void;
}

export const Topbar: React.FC<TopbarProps> = ({
  title,
  badge,
  searchQuery,
  onSearchChange,
}) => {
  return (
    <header className="h-16 bg-white border-b border-[#E2E8F0] px-8 flex items-center justify-between shrink-0 shadow-sm">
      {/* Title & Badge */}
      <div className="flex items-center space-x-3">
        <h2 className="text-lg font-extrabold text-[#0F172A] tracking-tight">{title}</h2>
        {badge && (
          <span className="bg-[#EBF2EF] text-[#173F35] text-xs px-2.5 py-0.5 rounded-full font-extrabold border border-[#173F35]/20">
            {badge}
          </span>
        )}
      </div>

      {/* Actions & Search */}
      <div className="flex items-center space-x-4">
        {/* Search Input */}
        <div className="relative w-72">
          <Search className="w-4 h-4 text-[#94A3B8] absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Tìm kiếm dữ liệu CMS..."
            className="w-full pl-9 pr-3 py-1.5 bg-[#F8FAFC] border border-[#E2E8F0] rounded-lg text-sm text-[#0F172A] focus:outline-none focus:ring-2 focus:ring-[#173F35] focus:bg-white transition-all placeholder:text-[#94A3B8]"
          />
        </div>

        {/* Port Status */}
        <div className="flex items-center space-x-1.5 px-3 py-1 bg-[#F1F5F9] rounded-full border border-[#E2E8F0] text-xs font-bold text-[#2563EB]">
          <Globe className="w-3.5 h-3.5" />
          <span>REACT TS • 3000</span>
        </div>

        {/* Role Badge */}
        <div className="flex items-center space-x-1.5 px-3 py-1 bg-[#DCFCE7] rounded-full text-xs font-extrabold text-[#15803D]">
          <ShieldCheck className="w-3.5 h-3.5" />
          <span>ROLE: ADMIN</span>
        </div>

        {/* Notifications */}
        <button className="p-2 text-[#64748B] hover:text-[#0F172A] hover:bg-[#F8FAFC] rounded-lg relative">
          <Bell className="w-4 h-4" />
          <span className="w-2 h-2 bg-[#DC2626] rounded-full absolute top-1.5 right-1.5"></span>
        </button>

        {/* User Profile */}
        <div className="flex items-center space-x-3 pl-2 border-l border-[#E2E8F0]">
          <div className="w-9 h-9 rounded-full bg-[#173F35] text-white flex items-center justify-center font-bold text-xs shadow-sm">
            AD
          </div>
          <div className="hidden md:block">
            <div className="text-xs font-bold text-[#0F172A]">Nguyễn Ngọc Bữu</div>
            <div className="text-[11px] text-[#64748B]">buunnde180722@fpt.edu.vn</div>
          </div>
        </div>
      </div>
    </header>
  );
};
