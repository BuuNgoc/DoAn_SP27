import React, { useState } from 'react';
import { Users, Plus, ShieldCheck, UserCheck, ShieldAlert } from 'lucide-react';
import { UserAccount } from '../types';

interface UsersRbacViewProps {
  users: UserAccount[];
  onUpdateUsers: (users: UserAccount[]) => void;
}

export const UsersRbacView: React.FC<UsersRbacViewProps> = ({
  users,
  onUpdateUsers,
}) => {
  const [isAddUserOpen, setIsAddUserOpen] = useState(false);
  const [newName, setNewName] = useState('');
  const [newEmail, setNewEmail] = useState('');
  const [newRole, setNewRole] = useState<UserAccount['role']>('TOURISM_MANAGER');
  const [newDept, setNewDept] = useState('');

  const handleAddUser = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newName || !newEmail) return;

    const newUser: UserAccount = {
      uid: `usr_${Date.now()}`,
      name: newName,
      email: newEmail,
      role: newRole,
      department: newDept || 'Ban Quản Trị Du Lịch',
      isActive: true,
      lastLogin: 'Chưa đăng nhập',
    };

    onUpdateUsers([...users, newUser]);
    setIsAddUserOpen(false);
    setNewName('');
    setNewEmail('');
    setNewDept('');
  };

  const handleChangeRole = (uid: string, role: UserAccount['role']) => {
    onUpdateUsers(
      users.map((u) => (u.uid === uid ? { ...u, role } : u)),
    );
  };

  const getRoleBadge = (role: UserAccount['role']) => {
    switch (role) {
      case 'ADMIN':
        return 'bg-[#FEE2E2] text-[#DC2626] border-[#FCA5A5]';
      case 'TOURISM_MANAGER':
        return 'bg-[#EBF2EF] text-[#173F35] border-[#173F35]/20';
      default:
        return 'bg-[#F1F5F9] text-[#475569] border-[#CBD5E1]';
    }
  };

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Phân Quyền Vai Trò & Quản Trị Tài Khoản RBAC (FE-26, FE-27)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Kiểm soát quyền truy cập phân cấp: ADMIN (Toàn quyền), TOURISM_MANAGER (Nội dung CMS & Vận hành) và TOURIST (Du khách)
          </p>
        </div>
        <button
          onClick={() => setIsAddUserOpen(true)}
          className="px-4 py-2 bg-[#173F35] hover:bg-[#244C40] text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center space-x-1.5 self-start md:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Thêm Tài Khoản Quản Trị</span>
        </button>
      </div>

      {/* ── Users Table ───────────────────────────────────────────────────── */}
      <div className="overflow-x-auto border border-[#E2E8F0] rounded-xl">
        <table className="w-full text-left text-sm">
          <thead className="bg-[#F8FAFC] border-b border-[#E2E8F0] text-xs font-extrabold text-[#475569] uppercase">
            <tr>
              <th className="py-3 px-4">Họ Tên Quản Trị Viên</th>
              <th className="py-3 px-4">Email Đăng Nhập</th>
              <th className="py-3 px-4">Vai Trò (Role)</th>
              <th className="py-3 px-4">Đơn Vị Phụ Trách</th>
              <th className="py-3 px-4">Đăng Nhập Gần Nhất</th>
              <th className="py-3 px-4 text-right">Phân Quyền</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#E2E8F0]">
            {users.map((u) => (
              <tr key={u.uid} className="hover:bg-[#F8FAFC]">
                <td className="py-3 px-4 font-bold text-[#0F172A]">{u.name}</td>
                <td className="py-3 px-4 text-xs font-mono text-[#64748B]">{u.email}</td>
                <td className="py-3 px-4">
                  <span
                    className={`inline-block px-2.5 py-0.5 rounded text-xs font-extrabold border ${getRoleBadge(
                      u.role,
                    )}`}
                  >
                    {u.role}
                  </span>
                </td>
                <td className="py-3 px-4 text-xs text-[#475569]">{u.department}</td>
                <td className="py-3 px-4 text-xs text-[#94A3B8]">{u.lastLogin}</td>
                <td className="py-3 px-4 text-right">
                  <select
                    value={u.role}
                    onChange={(e) => handleChangeRole(u.uid, e.target.value as any)}
                    className="text-xs font-bold border border-[#CBD5E1] rounded px-2 py-1 bg-white outline-none"
                  >
                    <option value="ADMIN">ADMIN</option>
                    <option value="TOURISM_MANAGER">TOURISM_MANAGER</option>
                    <option value="TOURIST">TOURIST</option>
                  </select>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* ── Modal Add User ───────────────────────────────────────────────── */}
      {isAddUserOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md p-6 shadow-2xl">
            <h4 className="font-extrabold text-[#0F172A] text-base mb-4">
              Thêm Tài Khoản Quản Trị Viên (FE-26)
            </h4>

            <form onSubmit={handleAddUser} className="space-y-3.5">
              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Họ và Tên *</label>
                <input
                  type="text"
                  required
                  value={newName}
                  onChange={(e) => setNewName(e.target.value)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Email Đăng Nhập *</label>
                <input
                  type="email"
                  required
                  placeholder="admin@fe.edu.vn"
                  value={newEmail}
                  onChange={(e) => setNewEmail(e.target.value)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Phân Quyền Vai Trò *</label>
                <select
                  value={newRole}
                  onChange={(e) => setNewRole(e.target.value as any)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none font-bold"
                >
                  <option value="ADMIN">ADMIN - Toàn Quyền Hệ Thống & RBAC</option>
                  <option value="TOURISM_MANAGER">TOURISM_MANAGER - Quản Lý CMS & Vận Hành</option>
                  <option value="TOURIST">TOURIST - Du Khách</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Bộ Phận / Phòng Ban</label>
                <input
                  type="text"
                  placeholder="Ban Quản Lý Du Lịch Ngũ Hành Sơn"
                  value={newDept}
                  onChange={(e) => setNewDept(e.target.value)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>

              <div className="pt-3 border-t border-[#E2E8F0] flex justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setIsAddUserOpen(false)}
                  className="px-4 py-2 border border-[#E2E8F0] rounded-lg text-xs font-bold text-[#64748B]"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#173F35] text-white rounded-lg text-xs font-bold hover:bg-[#244C40]"
                >
                  Tạo Tài Khoản
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
