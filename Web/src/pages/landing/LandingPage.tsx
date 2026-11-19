import React from 'react';
import {
  Compass,
  MapPin,
  Sparkles,
  QrCode,
  ShieldCheck,
  Smartphone,
  ChevronRight,
  ExternalLink,
  Layers,
  Headphones,
  Award,
  ArrowRight,
  CheckCircle2,
} from 'lucide-react';

interface LandingPageProps {
  onNavigateToLogin: () => void;
  onNavigateToAdmin: () => void;
  isLoggedIn: boolean;
}

export const LandingPage: React.FC<LandingPageProps> = ({
  onNavigateToLogin,
  onNavigateToAdmin,
  isLoggedIn,
}) => {
  return (
    <div className="min-h-screen bg-[#FAF7F2] text-[#242824] selection:bg-[#B69A67] selection:text-white">
      {/* ── TOP LUXURY NAVIGATION BAR ────────────────────────────────────── */}
      <header className="sticky top-0 z-50 bg-[#FAF7F2]/90 backdrop-blur-md border-b border-[#E8DFD0]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
          {/* Brand Identity */}
          <div className="flex items-center gap-3">
            <div className="w-11 h-11 rounded-xl bg-gradient-to-br from-[#173F35] to-[#0F2B24] flex items-center justify-center text-[#E4B85E] shadow-sm">
              <Compass className="w-6 h-6 stroke-[1.8]" />
            </div>
            <div>
              <span className="font-serif text-xl font-bold tracking-wide text-[#173F35] block leading-tight">
                SmartTravel
              </span>
              <span className="text-[10px] uppercase tracking-widest text-[#B69A67] font-semibold block">
                Ngũ Hành Sơn • Đà Nẵng
              </span>
            </div>
          </div>

          {/* Nav Links */}
          <nav className="hidden md:flex items-center gap-8 text-sm font-medium text-[#777A73]">
            <a href="#about" className="hover:text-[#173F35] transition-colors">Về Dự Án</a>
            <a href="#clusters" className="hover:text-[#173F35] transition-colors">4 Cụm Danh Thắng</a>
            <a href="#technology" className="hover:text-[#173F35] transition-colors">Trải Nghiệm Số</a>
            <a href="#download" className="hover:text-[#173F35] transition-colors">Tải Ứng Dụng</a>
          </nav>

          {/* CTA Button */}
          <div className="flex items-center gap-3">
            {isLoggedIn ? (
              <button
                onClick={onNavigateToAdmin}
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg bg-[#173F35] text-white hover:bg-[#0F2B24] transition-all text-sm font-semibold shadow-sm hover:shadow"
              >
                <ShieldCheck className="w-4 h-4 text-[#E4B85E]" />
                Vào Cổng Quản Trị
              </button>
            ) : (
              <button
                onClick={onNavigateToLogin}
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg bg-[#173F35] text-white hover:bg-[#0F2B24] transition-all text-sm font-semibold shadow-sm hover:shadow"
              >
                <span>Đăng Nhập Quản Trị</span>
                <ChevronRight className="w-4 h-4 text-[#B69A67]" />
              </button>
            )}
          </div>
        </div>
      </header>

      {/* ── HERO SECTION ─────────────────────────────────────────────────── */}
      <section className="relative overflow-hidden pt-12 pb-20 lg:pt-20 lg:pb-28">
        {/* Subtle Decorative Background Lines */}
        <div className="absolute inset-0 pointer-events-none opacity-40">
          <svg className="w-full h-full" viewBox="0 0 1440 600" fill="none">
            <path d="M0 100 Q 360 250 720 120 T 1440 180" stroke="#E8DFD0" strokeWidth="1.5" />
            <path d="M0 240 Q 400 380 800 200 T 1440 320" stroke="#E8DFD0" strokeWidth="1" />
          </svg>
        </div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
            {/* Left Content */}
            <div className="lg:col-span-7 space-y-6 text-center lg:text-left">
              <div className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-[#EBF2EF] border border-[#C7DCD4] text-[#173F35] text-xs font-semibold uppercase tracking-wider">
                <Sparkles className="w-3.5 h-3.5 text-[#B69A67]" />
                Nền tảng Du lịch Thông minh Thế hệ Mới
              </div>

              <h1 className="font-serif text-4xl sm:text-5xl lg:text-6xl font-bold text-[#173F35] leading-tight tracking-tight">
                Chạm Di Sản <br className="hidden sm:inline" />
                <span className="text-[#B69A67] italic font-normal">Bằng Công Nghệ Số</span>
              </h1>

              <p className="text-base sm:text-lg text-[#777A73] max-w-2xl leading-relaxed">
                Khám phá quần thể danh thắng Ngũ Hành Sơn với trải nghiệm số hóa toàn diện: Bản đồ tương tác GIS, thuyết minh tự động Audio Guide, thực tế ảo VR360°, trợ lý thông minh AI và trạm check-in QR tích điểm đổi quà.
              </p>

              <div className="flex flex-col sm:flex-row items-center gap-4 pt-2 justify-center lg:justify-start">
                <a
                  href="#download"
                  className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-7 py-3.5 rounded-xl bg-[#173F35] text-white font-semibold text-sm hover:bg-[#0F2B24] transition-all shadow-md hover:shadow-lg"
                >
                  <Smartphone className="w-4 h-4 text-[#E4B85E]" />
                  Tải Ứng Dụng Mobile
                </a>
                <a
                  href="#technology"
                  className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-7 py-3.5 rounded-xl bg-white border border-[#E8DFD0] text-[#173F35] font-semibold text-sm hover:border-[#B69A67] hover:bg-[#F8F6F0] transition-all shadow-sm"
                >
                  Khám Phá Công Nghệ
                  <ArrowRight className="w-4 h-4 text-[#B69A67]" />
                </a>
              </div>

              {/* Quick Metrics Bar */}
              <div className="pt-8 border-t border-[#E8DFD0] grid grid-cols-3 gap-6 text-center lg:text-left">
                <div>
                  <div className="font-serif text-2xl font-bold text-[#173F35]">05 Ngọn</div>
                  <div className="text-xs text-[#777A73]">Kim • Mộc • Thủy • Hỏa • Thổ</div>
                </div>
                <div>
                  <div className="font-serif text-2xl font-bold text-[#173F35]">360° VR</div>
                  <div className="text-xs text-[#777A73]">Góc nhìn toàn cảnh panorama</div>
                </div>
                <div>
                  <div className="font-serif text-2xl font-bold text-[#173F35]">04 Ngôn ngữ</div>
                  <div className="text-xs text-[#777A73]">Việt • Anh • Hàn • Trung</div>
                </div>
              </div>
            </div>

            {/* Right Visual: Mobile Mockup Preview */}
            <div className="lg:col-span-5 flex justify-center">
              <div className="relative w-72 sm:w-80 rounded-[40px] bg-[#173F35] p-3 shadow-2xl border-4 border-[#DDD2C0]">
                {/* Speaker Notch */}
                <div className="w-32 h-4 bg-[#0F2B24] mx-auto rounded-full mb-2"></div>
                {/* Screen Content */}
                <div className="rounded-[32px] overflow-hidden bg-[#FAF7F2] border border-[#E8DFD0] shadow-inner space-y-3 p-4">
                  {/* Mock Mobile Header */}
                  <div className="flex items-center justify-between pb-2 border-b border-[#E8DFD0]">
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-full bg-[#173F35] flex items-center justify-center text-[#E4B85E] text-xs font-bold">
                        ✦
                      </div>
                      <span className="font-serif text-xs font-bold text-[#173F35]">SmartTravel NHS</span>
                    </div>
                    <span className="text-[10px] px-2 py-0.5 rounded-full bg-[#EBF2EF] text-[#173F35] font-semibold">
                      Đà Nẵng
                    </span>
                  </div>

                  {/* Mock Hero Card */}
                  <div className="relative h-44 rounded-2xl overflow-hidden shadow-sm group">
                    <img
                      src="https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=600&q=80"
                      alt="Động Huyền Không"
                      className="w-full h-full object-cover"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-[#0F2B24]/90 via-[#0F2B24]/40 to-transparent flex flex-col justify-end p-3 text-white">
                      <span className="text-[10px] uppercase tracking-wider text-[#E4B85E] font-semibold">
                        Di tích Quốc gia đặc biệt
                      </span>
                      <h4 className="font-serif text-sm font-bold">Động Huyền Không</h4>
                      <p className="text-[10px] text-white/80 line-clamp-1">Tia sáng mặt trời rọi thẳng từ vòm đá</p>
                    </div>
                  </div>

                  {/* Mock Category Chips */}
                  <div className="flex gap-1.5 overflow-x-auto text-[10px] no-scrollbar py-1">
                    <span className="px-2.5 py-1 rounded-full bg-[#173F35] text-white font-semibold whitespace-nowrap">
                      Thủy Sơn
                    </span>
                    <span className="px-2.5 py-1 rounded-full bg-white border border-[#E8DFD0] text-[#777A73] whitespace-nowrap">
                      Non Nước
                    </span>
                    <span className="px-2.5 py-1 rounded-full bg-white border border-[#E8DFD0] text-[#777A73] whitespace-nowrap">
                      Sơn Thủy
                    </span>
                    <span className="px-2.5 py-1 rounded-full bg-white border border-[#E8DFD0] text-[#777A73] whitespace-nowrap">
                      An Thượng
                    </span>
                  </div>

                  {/* Mock Feature Action */}
                  <div className="p-2.5 rounded-xl bg-white border border-[#E8DFD0] flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 rounded-lg bg-[#F8F6F0] flex items-center justify-center text-[#B69A67]">
                        <QrCode className="w-4 h-4" />
                      </div>
                      <div>
                        <div className="text-[11px] font-bold text-[#173F35]">Trạm Check-in QR</div>
                        <div className="text-[9px] text-[#777A73]">+50 điểm thưởng du lịch</div>
                      </div>
                    </div>
                    <span className="text-[10px] font-bold text-[#B69A67] bg-[#FAF7F2] px-2 py-1 rounded-md">
                      Quét ngay
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── 4 CLUSTERS HIGHLIGHT SECTION ─────────────────────────────────── */}
      <section id="clusters" className="py-20 bg-white border-y border-[#E8DFD0]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16 space-y-3">
            <span className="text-xs uppercase tracking-widest text-[#B69A67] font-bold">
              Địa Bàn Trọng Điểm
            </span>
            <h2 className="font-serif text-3xl sm:text-4xl font-bold text-[#173F35]">
              4 Cụm Không Gian Du Lịch Đặc Sắc
            </h2>
            <p className="text-sm sm:text-base text-[#777A73]">
              Số hóa và kết nối liền mạch các di tích lịch sử, làng nghề truyền thống và dịch vụ du lịch hiện đại tại Ngũ Hành Sơn.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Cluster 1: Thủy Sơn */}
            <div className="group rounded-2xl bg-[#FAF7F2] border border-[#E8DFD0] overflow-hidden hover:shadow-lg transition-all flex flex-col">
              <div className="h-48 overflow-hidden relative">
                <img
                  src="https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=600&q=80"
                  alt="Thủy Sơn"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <span className="absolute top-3 left-3 px-2.5 py-1 rounded-md bg-[#173F35]/90 text-white text-xs font-semibold backdrop-blur-sm">
                  Di Tích Lịch Sử
                </span>
              </div>
              <div className="p-5 flex-1 flex flex-col justify-between">
                <div>
                  <h3 className="font-serif text-lg font-bold text-[#173F35] mb-2">Thủy Sơn Huyền Bí</h3>
                  <p className="text-xs text-[#777A73] leading-relaxed">
                    Ngọn núi lớn và đẹp nhất, lưu giữ Chùa Tam Thai, Chùa Linh Ứng, Động Huyền Không và Động Hoa Nghiêm với niên đại hàng trăm năm.
                  </p>
                </div>
                <div className="pt-4 mt-4 border-t border-[#E8DFD0] text-xs font-semibold text-[#B69A67] flex items-center justify-between">
                  <span>VR360° & Audio Guide</span>
                  <ChevronRight className="w-4 h-4" />
                </div>
              </div>
            </div>

            {/* Cluster 2: Non Nước */}
            <div className="group rounded-2xl bg-[#FAF7F2] border border-[#E8DFD0] overflow-hidden hover:shadow-lg transition-all flex flex-col">
              <div className="h-48 overflow-hidden relative">
                <img
                  src="https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80"
                  alt="Làng đá Non Nước"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <span className="absolute top-3 left-3 px-2.5 py-1 rounded-md bg-[#173F35]/90 text-white text-xs font-semibold backdrop-blur-sm">
                  Làng Nghề Truyền Thống
                </span>
              </div>
              <div className="p-5 flex-1 flex flex-col justify-between">
                <div>
                  <h3 className="font-serif text-lg font-bold text-[#173F35] mb-2">Làng Đá Non Nước</h3>
                  <p className="text-xs text-[#777A73] leading-relaxed">
                    Di sản văn hóa phi vật thể quốc gia với hơn 400 năm tuổi. Nơi du khách trực tiếp tham gia workshop điêu khắc đá cùng nghệ nhân.
                  </p>
                </div>
                <div className="pt-4 mt-4 border-t border-[#E8DFD0] text-xs font-semibold text-[#B69A67] flex items-center justify-between">
                  <span>Workshop & Đặt vé</span>
                  <ChevronRight className="w-4 h-4" />
                </div>
              </div>
            </div>

            {/* Cluster 3: Sơn Thủy Beach */}
            <div className="group rounded-2xl bg-[#FAF7F2] border border-[#E8DFD0] overflow-hidden hover:shadow-lg transition-all flex flex-col">
              <div className="h-48 overflow-hidden relative">
                <img
                  src="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80"
                  alt="Bãi biển Sơn Thủy"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <span className="absolute top-3 left-3 px-2.5 py-1 rounded-md bg-[#173F35]/90 text-white text-xs font-semibold backdrop-blur-sm">
                  Du Lịch Bờ Biển
                </span>
              </div>
              <div className="p-5 flex-1 flex flex-col justify-between">
                <div>
                  <h3 className="font-serif text-lg font-bold text-[#173F35] mb-2">Bãi Tắm Sơn Thủy</h3>
                  <p className="text-xs text-[#777A73] leading-relaxed">
                    Bãi cát trắng mịn trải dài từ Non Nước đến Tân Trà, tích hợp bản đồ thời tiết thời gian thực và cắm cờ báo hiệu an toàn cứu hộ bờ biển.
                  </p>
                </div>
                <div className="pt-4 mt-4 border-t border-[#E8DFD0] text-xs font-semibold text-[#B69A67] flex items-center justify-between">
                  <span>Cảnh báo thời tiết & SOS</span>
                  <ChevronRight className="w-4 h-4" />
                </div>
              </div>
            </div>

            {/* Cluster 4: An Thượng Tourist Hub */}
            <div className="group rounded-2xl bg-[#FAF7F2] border border-[#E8DFD0] overflow-hidden hover:shadow-lg transition-all flex flex-col">
              <div className="h-48 overflow-hidden relative">
                <img
                  src="https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=600&q=80"
                  alt="Phố du lịch An Thượng"
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <span className="absolute top-3 left-3 px-2.5 py-1 rounded-md bg-[#173F35]/90 text-white text-xs font-semibold backdrop-blur-sm">
                  Kinh Tế Ban Đêm
                </span>
              </div>
              <div className="p-5 flex-1 flex flex-col justify-between">
                <div>
                  <h3 className="font-serif text-lg font-bold text-[#173F35] mb-2">Phố Đi Bộ An Thượng</h3>
                  <p className="text-xs text-[#777A73] leading-relaxed">
                    Khu phố du lịch quốc tế sôi động với chuỗi ẩm thực đa quốc gia, cà phê phong cách, quán bar và các sự kiện âm nhạc đường phố cuối tuần.
                  </p>
                </div>
                <div className="pt-4 mt-4 border-t border-[#E8DFD0] text-xs font-semibold text-[#B69A67] flex items-center justify-between">
                  <span>Bản đồ ẩm thực & Ưu đãi</span>
                  <ChevronRight className="w-4 h-4" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── TECHNOLOGY SHOWCASE SECTION ─────────────────────────────────── */}
      <section id="technology" className="py-20 bg-[#FAF7F2]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-3xl mx-auto mb-16 space-y-3">
            <span className="text-xs uppercase tracking-widest text-[#B69A67] font-bold">
              Công Nghệ Đột Phá
            </span>
            <h2 className="font-serif text-3xl sm:text-4xl font-bold text-[#173F35]">
              Nền Tảng Trải Nghiệm Số Toàn Diện
            </h2>
            <p className="text-sm sm:text-base text-[#777A73]">
              Tích hợp các giải pháp công nghệ tiên tiến nhất nhằm nâng tầm hành trình trải nghiệm của du khách trong và ngoài nước.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            {/* Tech 1 */}
            <div className="p-6 rounded-2xl bg-white border border-[#E8DFD0] shadow-sm hover:border-[#B69A67] transition-all">
              <div className="w-12 h-12 rounded-xl bg-[#EBF2EF] text-[#173F35] flex items-center justify-center mb-5">
                <Layers className="w-6 h-6 stroke-[1.8]" />
              </div>
              <h3 className="font-serif text-lg font-bold text-[#173F35] mb-2">Bản Đồ GIS Tương Tác</h3>
              <p className="text-xs text-[#777A73] leading-relaxed">
                Định vị không gian với hệ tọa độ Geohash chuẩn xác. Bộ lọc đa tầng danh lam, bãi tắm an toàn, trạm hỗ trợ y tế và điểm check-in.
              </p>
            </div>

            {/* Tech 2 */}
            <div className="p-6 rounded-2xl bg-white border border-[#E8DFD0] shadow-sm hover:border-[#B69A67] transition-all">
              <div className="w-12 h-12 rounded-xl bg-[#FBF8F2] text-[#B69A67] flex items-center justify-center mb-5">
                <Headphones className="w-6 h-6 stroke-[1.8]" />
              </div>
              <h3 className="font-serif text-lg font-bold text-[#173F35] mb-2">VR360° & Audio Guide</h3>
              <p className="text-xs text-[#777A73] leading-relaxed">
                Thuyết minh giọng đọc bản ngữ 4 thứ tiếng (Việt, Anh, Hàn, Trung). Tương tác xoay 360 độ ngắm toàn cảnh di sản từ trên cao.
              </p>
            </div>

            {/* Tech 3 */}
            <div className="p-6 rounded-2xl bg-white border border-[#E8DFD0] shadow-sm hover:border-[#B69A67] transition-all">
              <div className="w-12 h-12 rounded-xl bg-[#EDE9FE] text-[#7C3AED] flex items-center justify-center mb-5">
                <Sparkles className="w-6 h-6 stroke-[1.8]" />
              </div>
              <h3 className="font-serif text-lg font-bold text-[#173F35] mb-2">Trợ Lý Du Lịch AI / RAG</h3>
              <p className="text-xs text-[#777A73] leading-relaxed">
                Nhận diện danh thắng qua ảnh chụp tức thì, gợi ý lịch trình thông minh cá nhân hóa dựa trên thời gian và sở thích của du khách.
              </p>
            </div>

            {/* Tech 4 */}
            <div className="p-6 rounded-2xl bg-white border border-[#E8DFD0] shadow-sm hover:border-[#B69A67] transition-all">
              <div className="w-12 h-12 rounded-xl bg-[#FEF3C7] text-[#D97706] flex items-center justify-center mb-5">
                <Award className="w-6 h-6 stroke-[1.8]" />
              </div>
              <h3 className="font-serif text-lg font-bold text-[#173F35] mb-2">QR Loyalty & Quà Tặng</h3>
              <p className="text-xs text-[#777A73] leading-relaxed">
                Quét mã QR tại các trạm check-in vật lý có kiểm tra vị trí Geofence chống gian lận. Tích điểm đổi quà lưu niệm đặc sắc làng đá.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* ── APP DOWNLOAD SECTION ─────────────────────────────────────────── */}
      <section id="download" className="py-20 bg-[#173F35] text-white relative overflow-hidden">
        {/* Glow Effects */}
        <div className="absolute top-0 right-0 w-96 h-96 bg-[#B69A67]/20 rounded-full blur-3xl pointer-events-none"></div>

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="rounded-3xl bg-gradient-to-br from-[#1A453A] to-[#0F2B24] border border-[#244C40] p-8 sm:p-12 lg:p-16 flex flex-col lg:flex-row items-center justify-between gap-12">
            <div className="max-w-2xl space-y-5 text-center lg:text-left">
              <span className="text-xs uppercase tracking-widest text-[#E4B85E] font-bold">
                Trải Nghiệm Mượt Mà Trên Di Động
              </span>
              <h2 className="font-serif text-3xl sm:text-4xl font-bold leading-tight">
                Tải Ứng Dụng SmartTravel <br /> Ngũ Hành Sơn Ngay Hôm Nay
              </h2>
              <p className="text-sm sm:text-base text-[#FAF7F2]/80 leading-relaxed">
                Tương thích hoàn hảo trên thiết bị iOS và Android. Cung cấp chế độ ngoại tuyến (Offline Mode), lưu bản đồ đệm và thông báo an toàn cứu hộ bãi biển.
              </p>

              <div className="flex flex-wrap items-center justify-center lg:justify-start gap-4 pt-4">
                <div className="flex items-center gap-3 px-5 py-3 rounded-xl bg-white/10 hover:bg-white/15 border border-white/20 transition-all cursor-pointer">
                  <Smartphone className="w-6 h-6 text-[#E4B85E]" />
                  <div className="text-left">
                    <div className="text-[10px] text-white/70 uppercase">Tải miễn phí trên</div>
                    <div className="text-sm font-bold">Google Play Store</div>
                  </div>
                </div>

                <div className="flex items-center gap-3 px-5 py-3 rounded-xl bg-white/10 hover:bg-white/15 border border-white/20 transition-all cursor-pointer">
                  <Smartphone className="w-6 h-6 text-[#E4B85E]" />
                  <div className="text-left">
                    <div className="text-[10px] text-white/70 uppercase">Download on the</div>
                    <div className="text-sm font-bold">Apple App Store</div>
                  </div>
                </div>
              </div>
            </div>

            {/* QR Download Box */}
            <div className="bg-white text-[#242824] p-6 rounded-2xl shadow-xl border border-[#E8DFD0] text-center w-64 flex-shrink-0">
              <div className="w-48 h-48 mx-auto bg-[#F8F6F0] rounded-xl p-3 border border-[#E8DFD0] flex flex-col items-center justify-center relative">
                {/* SVG Simulated Clean QR Code */}
                <svg viewBox="0 0 100 100" className="w-full h-full text-[#173F35]">
                  <rect x="0" y="0" width="30" height="30" fill="currentColor" rx="4" />
                  <rect x="5" y="5" width="20" height="20" fill="white" rx="2" />
                  <rect x="10" y="10" width="10" height="10" fill="currentColor" rx="1" />

                  <rect x="70" y="0" width="30" height="30" fill="currentColor" rx="4" />
                  <rect x="75" y="5" width="20" height="20" fill="white" rx="2" />
                  <rect x="80" y="10" width="10" height="10" fill="currentColor" rx="1" />

                  <rect x="0" y="70" width="30" height="30" fill="currentColor" rx="4" />
                  <rect x="5" y="75" width="20" height="20" fill="white" rx="2" />
                  <rect x="10" y="80" width="10" height="10" fill="currentColor" rx="1" />

                  <rect x="40" y="10" width="15" height="10" fill="#B69A67" rx="1" />
                  <rect x="40" y="30" width="20" height="15" fill="currentColor" rx="1" />
                  <rect x="10" y="40" width="20" height="15" fill="currentColor" rx="1" />
                  <rect x="65" y="45" width="25" height="20" fill="#B69A67" rx="1" />
                  <rect x="35" y="65" width="25" height="15" fill="currentColor" rx="1" />
                  <rect x="45" y="45" width="10" height="10" fill="#173F35" rx="1" />
                </svg>
              </div>
              <div className="mt-4">
                <span className="text-xs font-bold text-[#173F35] block">Quét Mã QR Để Tải App</span>
                <span className="text-[11px] text-[#777A73]">Hỗ trợ Android & iOS</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── FOOTER ──────────────────────────────────────────────────────── */}
      <footer className="bg-[#FAF7F2] border-t border-[#E8DFD0] py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-10">
            <div className="md:col-span-2 space-y-3">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-[#173F35] flex items-center justify-center text-[#E4B85E]">
                  <Compass className="w-5 h-5" />
                </div>
                <span className="font-serif text-lg font-bold text-[#173F35]">
                  SmartTravel Ngũ Hành Sơn
                </span>
              </div>
              <p className="text-xs text-[#777A73] leading-relaxed max-w-md">
                Đồ án Nền tảng Du lịch Thông minh Ngũ Hành Sơn (NHS360). Ứng dụng giải pháp chuyển đổi số kết hợp bảo tồn và phát huy giá trị di sản văn hóa, danh thắng và làng nghề đá Non Nước.
              </p>
              <div className="text-xs text-[#777A73]">
                <strong>Địa bàn:</strong> Quận Ngũ Hành Sơn, Thành phố Đà Nẵng, Việt Nam.
              </div>
            </div>

            <div>
              <h4 className="font-serif text-sm font-bold text-[#173F35] mb-3">Phân Hệ Chức Năng</h4>
              <ul className="space-y-2 text-xs text-[#777A73]">
                <li><a href="#clusters" className="hover:text-[#173F35]">Thủy Sơn & Động Huyền Không</a></li>
                <li><a href="#clusters" className="hover:text-[#173F35]">Làng đá mỹ nghệ Non Nước</a></li>
                <li><a href="#clusters" className="hover:text-[#173F35]">Khu phố du lịch An Thượng</a></li>
                <li><a href="#clusters" className="hover:text-[#173F35]">Bãi tắm Sơn Thủy & Tân Trà</a></li>
              </ul>
            </div>

            <div>
              <h4 className="font-serif text-sm font-bold text-[#173F35] mb-3">Cổng Quản Trị</h4>
              <ul className="space-y-2 text-xs text-[#777A73]">
                <li>
                  <button onClick={onNavigateToLogin} className="hover:text-[#173F35] font-semibold text-[#B69A67] flex items-center gap-1">
                    <span>Đăng nhập Quản trị viên</span>
                    <ExternalLink className="w-3 h-3" />
                  </button>
                </li>
                <li><span>Ban Quản lý Di tích & Danh thắng</span></li>
                <li><span>UBND Quận Ngũ Hành Sơn</span></li>
                <li><span>Tiêu chuẩn bảo mật RBAC (FE-26/27)</span></li>
              </ul>
            </div>
          </div>

          <div className="pt-8 border-t border-[#E8DFD0] flex flex-col sm:flex-row items-center justify-between text-xs text-[#777A73]">
            <p>© 2026 SmartTravel – Nền tảng Du lịch Thông minh Ngũ Hành Sơn. Bảo lưu mọi quyền.</p>
            <p className="mt-2 sm:mt-0 font-medium text-[#173F35]">Hệ sinh thái Du lịch Số Đà Nẵng</p>
          </div>
        </div>
      </footer>
    </div>
  );
};
