import React, { useState } from 'react';
import {
  ShieldCheck,
  Download,
  Database,
  Clock,
  CheckCircle2,
  AlertCircle,
} from 'lucide-react';
import { AuditLog } from '../types';

interface AuditSystemViewProps {
  logs: AuditLog[];
}

export const AuditSystemView: React.FC<AuditSystemViewProps> = ({ logs }) => {
  const [backupSuccess, setBackupSuccess] = useState(false);
  const [exportSuccess, setExportSuccess] = useState(false);

  const handleBackupNow = () => {
    setBackupSuccess(true);
    setTimeout(() => setBackupSuccess(false), 3000);
  };

  const handleExportCsv = () => {
    setExportSuccess(true);
    setTimeout(() => setExportSuccess(false), 3000);
  };

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Nhật Ký Kiểm Toán & Sao Lưu Hệ Thống (FE-28, LI-07)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Ghi nhận toàn bộ thao tác thêm, sửa, xóa dữ liệu CMS; quản lý bản sao lưu Firestore an toàn
          </p>
        </div>
        <div className="flex items-center space-x-2.5">
          <button
            onClick={handleBackupNow}
            className="px-4 py-2 bg-[#173F35] hover:bg-[#244C40] text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center space-x-1.5"
          >
            <Database className="w-4 h-4" />
            <span>Sao Lưu Dữ Liệu Ngay</span>
          </button>
          <button
            onClick={handleExportCsv}
            className="px-3.5 py-2 border border-[#E2E8F0] hover:bg-[#F8FAFC] text-[#475569] rounded-lg text-xs font-bold transition-all flex items-center space-x-1.5"
          >
            <Download className="w-4 h-4" />
            <span>Xuất CSV / JSON</span>
          </button>
        </div>
      </div>

      {backupSuccess && (
        <div className="p-3 bg-[#DCFCE7] border border-[#86EFAC] text-[#15803D] text-xs font-bold rounded-lg flex items-center space-x-2">
          <CheckCircle2 className="w-4 h-4 shrink-0" />
          <span>Sao lưu toàn bộ Cloud Firestore thành công (Snapshot: backup_firestore_2026_11_19.tar.gz)!</span>
        </div>
      )}

      {exportSuccess && (
        <div className="p-3 bg-[#EFF6FF] border border-[#BFDBFE] text-[#1E40AF] text-xs font-bold rounded-lg flex items-center space-x-2">
          <CheckCircle2 className="w-4 h-4 shrink-0" />
          <span>Đã tạo file báo cáo audit_logs_export.csv thành công!</span>
        </div>
      )}

      {/* ── Logs Table ────────────────────────────────────────────────────── */}
      <div className="overflow-x-auto border border-[#E2E8F0] rounded-xl">
        <table className="w-full text-left text-sm">
          <thead className="bg-[#F8FAFC] border-b border-[#E2E8F0] text-xs font-extrabold text-[#475569] uppercase">
            <tr>
              <th className="py-3 px-4">Thời Gian</th>
              <th className="py-3 px-4">Hành Động Tác Vụ</th>
              <th className="py-3 px-4">Phân Hệ</th>
              <th className="py-3 px-4">Tài Khoản Thực Hiện</th>
              <th className="py-3 px-4">Địa Chỉ IP</th>
              <th className="py-3 px-4 text-right">Kết Quả</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#E2E8F0]">
            {logs.map((l) => (
              <tr key={l.id} className="hover:bg-[#F8FAFC]">
                <td className="py-3 px-4 text-xs font-mono text-[#64748B]">{l.timestamp}</td>
                <td className="py-3 px-4 font-bold text-xs text-[#0F172A]">{l.action}</td>
                <td className="py-3 px-4 text-xs font-extrabold text-[#173F35]">{l.module}</td>
                <td className="py-3 px-4 text-xs text-[#475569]">{l.user}</td>
                <td className="py-3 px-4 text-xs font-mono text-[#94A3B8]">{l.ipAddress}</td>
                <td className="py-3 px-4 text-right">
                  <span className="inline-block px-2 py-0.5 bg-[#DCFCE7] text-[#15803D] rounded text-[11px] font-extrabold">
                    {l.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
