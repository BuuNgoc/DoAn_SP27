import React, { useState } from 'react';
import {
  Ticket,
  QrCode,
  CheckCircle2,
  XCircle,
  Award,
  Plus,
} from 'lucide-react';
import { WorkshopBooking } from '../types';

interface WorkshopsCmsProps {
  bookings: WorkshopBooking[];
  onUpdateBookings: (bookings: WorkshopBooking[]) => void;
}

export const WorkshopsCms: React.FC<WorkshopsCmsProps> = ({
  bookings,
  onUpdateBookings,
}) => {
  const [ticketInput, setTicketInput] = useState('');
  const [validationResult, setValidationResult] = useState<{
    success: boolean;
    message: string;
  } | null>(null);

  const handleValidateTicket = (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    const code = ticketInput.trim().toUpperCase();
    if (!code) {
      setValidationResult({
        success: false,
        message: 'Vui lòng nhập hoặc quét mã vé QR!',
      });
      return;
    }

    const match = bookings.find((b) => b.ticketCode.toUpperCase() === code);
    if (!match) {
      setValidationResult({
        success: false,
        message: `Mã vé "${code}" không tồn tại hoặc không hợp lệ!`,
      });
      return;
    }

    if (match.status === 'CHECKED_IN') {
      setValidationResult({
        success: false,
        message: `Vé "${match.ticketCode}" (${match.touristName}) ĐÃ CHECK-IN TRƯỚC ĐÓ với mã chứng nhận: ${match.certificateCode}!`,
      });
      return;
    }

    // Process Check-in
    const certCode = `CERT-NHS-2026-${(1000 + bookings.indexOf(match)).toString()}`;
    onUpdateBookings(
      bookings.map((b) =>
        b.ticketCode === match.ticketCode
          ? { ...b, status: 'CHECKED_IN', certificateCode: certCode }
          : b,
      ),
    );

    setValidationResult({
      success: true,
      message: `Xác thực THÀNH CÔNG! Đã check-in cho "${match.touristName}". Tự động cộng +50 Điểm Loyalty & Cấp E-Certificate: ${certCode}!`,
    });
  };

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Quản Trị Workshop Làng Nghề & Xác Thực Vé QR (FE-19, Epic 7)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Quản lý ca trải nghiệm cùng nghệ nhân, công cụ quét QR xác nhận tham gia, tự động tích điểm Loyalty & cấp E-Certificate
          </p>
        </div>
      </div>

      {/* ── QR Ticket Validator Tool (Staff / Admin Tool) ─────────────────── */}
      <div className="p-5 rounded-xl bg-[#F8FAFC] border border-[#E2E8F0] space-y-3">
        <div className="flex items-center space-x-2 text-[#173F35]">
          <QrCode className="w-5 h-5" />
          <h4 className="font-extrabold text-sm text-[#0F172A]">
            Công Cụ Quét & Kiểm Tra Mã QR Vé Tham Gia (Staff / Admin QR Ticket Validator)
          </h4>
        </div>
        <p className="text-xs text-[#64748B]">
          Nhân viên/Nghệ nhân dùng đầu đọc mã vạch hoặc camera để quét mã QR vé của du khách khi đến xưởng:
        </p>

        <form onSubmit={handleValidateTicket} className="flex flex-wrap items-center gap-3">
          <input
            type="text"
            value={ticketInput}
            onChange={(e) => setTicketInput(e.target.value)}
            placeholder="Nhập hoặc quét mã vé (VD: TK-NHS-WS8821)"
            className="w-80 px-3.5 py-2 bg-white border border-[#CBD5E1] rounded-lg text-sm text-[#0F172A] outline-none font-mono focus:ring-2 focus:ring-[#173F35]"
          />
          <button
            type="submit"
            className="px-4 py-2 bg-[#16A34A] hover:bg-[#15803D] text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center space-x-1.5"
          >
            <CheckCircle2 className="w-4 h-4" />
            <span>Xác Thực Vé & Check-in</span>
          </button>
          <button
            type="button"
            onClick={() => {
              setTicketInput('TK-NHS-WS8821');
              setTimeout(() => handleValidateTicket(), 50);
            }}
            className="px-3.5 py-2 border border-[#CBD5E1] bg-white hover:bg-[#F1F5F9] text-[#475569] rounded-lg text-xs font-bold transition-all"
          >
            Thử Nghiệm Vé Mẫu (TK-NHS-WS8821)
          </button>
        </form>

        {validationResult && (
          <div
            className={`p-3.5 rounded-lg border text-xs font-bold flex items-center space-x-2 mt-2 ${
              validationResult.success
                ? 'bg-[#DCFCE7] border-[#86EFAC] text-[#15803D]'
                : 'bg-[#FEE2E2] border-[#FCA5A5] text-[#DC2626]'
            }`}
          >
            {validationResult.success ? (
              <Award className="w-4 h-4 shrink-0" />
            ) : (
              <XCircle className="w-4 h-4 shrink-0" />
            )}
            <span>{validationResult.message}</span>
          </div>
        )}
      </div>

      {/* ── Bookings Table ────────────────────────────────────────────────── */}
      <div className="space-y-3">
        <h4 className="text-xs font-extrabold text-[#94A3B8] uppercase tracking-wider">
          Danh Sách Du Khách Đăng Ký Tham Gia Workshop
        </h4>

        <div className="overflow-x-auto border border-[#E2E8F0] rounded-xl">
          <table className="w-full text-left text-sm">
            <thead className="bg-[#F8FAFC] border-b border-[#E2E8F0] text-xs font-extrabold text-[#475569] uppercase">
              <tr>
                <th className="py-3 px-4">Mã Vé QR</th>
                <th className="py-3 px-4">Họ Tên Du Khách</th>
                <th className="py-3 px-4">Tên Workshop & Ca Diễn</th>
                <th className="py-3 px-4">Thời Gian</th>
                <th className="py-3 px-4">Trạng Thái</th>
                <th className="py-3 px-4">Chứng Nhận E-Cert</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E2E8F0]">
              {bookings.map((b) => (
                <tr key={b.ticketCode} className="hover:bg-[#F8FAFC]">
                  <td className="py-3 px-4 font-mono font-bold text-xs text-[#173F35]">
                    {b.ticketCode}
                  </td>
                  <td className="py-3 px-4">
                    <div className="font-bold text-[#0F172A]">{b.touristName}</div>
                    <div className="text-xs text-[#64748B]">
                      SĐT: {b.phone} • {b.participants} người
                    </div>
                  </td>
                  <td className="py-3 px-4 text-xs font-semibold text-[#334155]">
                    {b.workshopTitle}
                  </td>
                  <td className="py-3 px-4 text-xs text-[#64748B]">{b.sessionTime}</td>
                  <td className="py-3 px-4">
                    <span
                      className={`inline-block px-2.5 py-0.5 rounded text-[11px] font-extrabold ${
                        b.status === 'CHECKED_IN'
                          ? 'bg-[#DCFCE7] text-[#15803D]'
                          : 'bg-[#FEF3C7] text-[#B45309]'
                      }`}
                    >
                      {b.status === 'CHECKED_IN' ? 'Đã Tham Gia' : 'Chờ Check-in'}
                    </span>
                  </td>
                  <td className="py-3 px-4 text-xs font-mono font-bold text-[#173F35]">
                    {b.certificateCode || '(Chưa cấp)'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
