import React, { useState } from 'react';
import {
  Compass,
  Lock,
  Mail,
  ShieldCheck,
  AlertCircle,
  ArrowLeft,
  CheckCircle2,
  KeyRound,
  ShieldAlert,
} from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { UserRole } from '../../services/firebase';

interface LoginPageProps {
  onLoginSuccess: () => void;
  onNavigateHome: () => void;
}

export const LoginPage: React.FC<LoginPageProps> = ({
  onLoginSuccess,
  onNavigateHome,
}) => {
  const { login, demoLogin } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setErrorMessage('Vui lòng nhập đầy đủ Email và Mật khẩu.');
      return;
    }

    setLoading(true);
    setErrorMessage(null);

    try {
      await login(email, password);
      onLoginSuccess();
    } catch (err: any) {
      console.error('Login error:', err);
      if (err.message && err.message.includes('TOURIST')) {
        setErrorMessage(err.message);
      } else if (err.code === 'auth/invalid-credential' || err.code === 'auth/wrong-password' || err.code === 'auth/user-not-found') {
        setErrorMessage('Email hoặc mật khẩu không chính xác. Hãy kiểm tra lại hoặc sử dụng Đăng nhập Nhanh bên dưới.');
      } else {
        setErrorMessage(err.message || 'Đã có lỗi xảy ra trong quá trình xác thực.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleQuickLogin = (role: UserRole) => {
    setErrorMessage(null);
    try {
      demoLogin(role);
      onLoginSuccess();
    } catch (err: any) {
      setErrorMessage(err.message || 'Tài khoản không có quyền truy cập.');
    }
  };

  return (
    <div className="min-h-screen bg-[#FAF7F2] flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative selection:bg-[#B69A67] selection:text-white">
      {/* Back to Home Button */}
      <div className="absolute top-6 left-6">
        <button
          onClick={onNavigateHome}
          className="inline-flex items-center gap-2 text-xs font-semibold text-[#777A73] hover:text-[#173F35] bg-white border border-[#E8DFD0] px-3.5 py-2 rounded-lg shadow-sm transition-all"
        >
          <ArrowLeft className="w-4 h-4 text-[#B69A67]" />
          <span>Về Trang Chủ</span>
        </button>
      </div>

      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        {/* Brand Logo & Header */}
        <div className="flex justify-center">
          <div className="w-14 h-14 rounded-2xl bg-[#173F35] flex items-center justify-center text-[#E4B85E] shadow-md border-2 border-[#B69A67]">
            <Compass className="w-8 h-8 stroke-[1.8]" />
          </div>
        </div>

        <h2 className="mt-5 text-center font-serif text-2xl sm:text-3xl font-bold tracking-tight text-[#173F35]">
          Cổng Quản Trị SmartTravel
        </h2>
        <p className="mt-1 text-center text-xs text-[#777A73]">
          Hệ thống Quản lý Du lịch Thông minh Ngũ Hành Sơn (RBAC Portal)
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md px-4 sm:px-0">
        <div className="bg-white py-8 px-6 sm:px-10 shadow-luxury rounded-2xl border border-[#E8DFD0]">
          {/* Security Notice */}
          <div className="mb-6 p-3 rounded-xl bg-[#FAF7F2] border border-[#E8DFD0] flex items-start gap-2.5">
            <ShieldCheck className="w-4 h-4 text-[#173F35] mt-0.5 flex-shrink-0" />
            <p className="text-[11px] text-[#777A73] leading-relaxed">
              Cổng thông tin nội bộ dành riêng cho <strong>Quản trị viên (ADMIN)</strong> và <strong>Cán bộ Du lịch (TOURISM_MANAGER)</strong>. Tài khoản Khách du lịch (TOURIST) sẽ bị từ chối truy cập.
            </p>
          </div>

          {/* Error Alert */}
          {errorMessage && (
            <div className="mb-6 p-3.5 rounded-xl bg-[#FEF2F2] border border-[#FCA5A5] flex items-start gap-2.5 text-[#B83A2E] animate-shake">
              <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
              <div className="text-xs leading-relaxed font-medium">
                {errorMessage}
              </div>
            </div>
          )}

          {/* Form */}
          <form className="space-y-4" onSubmit={handleSubmit}>
            <div>
              <label className="block text-xs font-semibold text-[#242824] mb-1.5">
                Email Quản Trị
              </label>
              <div className="relative rounded-lg shadow-sm">
                <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                  <Mail className="h-4 w-4 text-[#A1A39D]" />
                </div>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin.nhs@danang.gov.vn"
                  className="block w-full rounded-lg border border-[#E8DFD0] bg-[#FAF7F2] py-2.5 pl-9 pr-3 text-xs text-[#242824] placeholder:text-[#A1A39D] focus:border-[#173F35] focus:bg-white focus:outline-none focus:ring-1 focus:ring-[#173F35] transition-all"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#242824] mb-1.5">
                Mật Khẩu
              </label>
              <div className="relative rounded-lg shadow-sm">
                <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                  <Lock className="h-4 w-4 text-[#A1A39D]" />
                </div>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="block w-full rounded-lg border border-[#E8DFD0] bg-[#FAF7F2] py-2.5 pl-9 pr-3 text-xs text-[#242824] placeholder:text-[#A1A39D] focus:border-[#173F35] focus:bg-white focus:outline-none focus:ring-1 focus:ring-[#173F35] transition-all"
                />
              </div>
            </div>

            <div className="pt-2">
              <button
                type="submit"
                disabled={loading}
                className="w-full flex justify-center items-center gap-2 py-2.5 px-4 rounded-lg bg-[#173F35] text-white text-xs font-bold hover:bg-[#0F2B24] transition-all shadow-md hover:shadow disabled:opacity-50"
              >
                {loading ? (
                  <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>
                ) : (
                  <>
                    <KeyRound className="w-4 h-4 text-[#E4B85E]" />
                    <span>Đăng Nhập Quản Trị</span>
                  </>
                )}
              </button>
            </div>
          </form>

          {/* Quick Demo Access Bar */}
          <div className="mt-8 pt-6 border-t border-[#E8DFD0]">
            <span className="block text-[11px] font-bold text-[#777A73] uppercase tracking-wider text-center mb-3">
              Chế Độ Trải Nghiệm Nhanh Phân Quyền RBAC
            </span>

            <div className="space-y-2">
              {/* Button 1: ADMIN */}
              <button
                type="button"
                onClick={() => handleQuickLogin('ADMIN')}
                className="w-full flex items-center justify-between p-2.5 rounded-xl border border-[#C7DCD4] bg-[#EBF2EF] hover:bg-[#D9EAE3] text-[#173F35] transition-all text-left"
              >
                <div className="flex items-center gap-2.5">
                  <div className="w-7 h-7 rounded-lg bg-[#173F35] text-[#E4B85E] flex items-center justify-center font-bold text-xs">
                    AD
                  </div>
                  <div>
                    <div className="text-xs font-bold">1. Tổng Quản Trị (ADMIN)</div>
                    <div className="text-[10px] text-[#777A73]">Toàn quyền FE-17 đến FE-28</div>
                  </div>
                </div>
                <span className="text-[10px] font-bold bg-[#173F35] text-white px-2 py-0.5 rounded">
                  Đăng nhập
                </span>
              </button>

              {/* Button 2: TOURISM_MANAGER */}
              <button
                type="button"
                onClick={() => handleQuickLogin('TOURISM_MANAGER')}
                className="w-full flex items-center justify-between p-2.5 rounded-xl border border-[#E8DFD0] bg-[#FAF7F2] hover:bg-[#F2ECE1] text-[#173F35] transition-all text-left"
              >
                <div className="flex items-center gap-2.5">
                  <div className="w-7 h-7 rounded-lg bg-[#B69A67] text-white flex items-center justify-center font-bold text-xs">
                    QL
                  </div>
                  <div>
                    <div className="text-xs font-bold">2. Cán Bộ Du Lịch (TOURISM_MANAGER)</div>
                    <div className="text-[10px] text-[#777A73]">Quản lý nội dung, sự kiện & báo cáo</div>
                  </div>
                </div>
                <span className="text-[10px] font-bold bg-[#B69A67] text-white px-2 py-0.5 rounded">
                  Đăng nhập
                </span>
              </button>

              {/* Button 3: TOURIST (Demonstrates RBAC blocking) */}
              <button
                type="button"
                onClick={() => handleQuickLogin('TOURIST')}
                className="w-full flex items-center justify-between p-2.5 rounded-xl border border-[#FCA5A5] bg-[#FEF2F2] hover:bg-[#FEE2E2] text-[#B83A2E] transition-all text-left"
              >
                <div className="flex items-center gap-2.5">
                  <div className="w-7 h-7 rounded-lg bg-[#B83A2E] text-white flex items-center justify-center font-bold text-xs">
                    <ShieldAlert className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="text-xs font-bold">3. Khách Du Lịch (TOURIST)</div>
                    <div className="text-[10px] text-[#B83A2E]/80">Thử nghiệm cơ chế Chặn RBAC</div>
                  </div>
                </div>
                <span className="text-[10px] font-bold bg-[#B83A2E] text-white px-2 py-0.5 rounded">
                  Thử Chặn
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
