# ==============================================================================
# 1. Builder Stage: Flutter Web Compilation
# Cài đặt trực tiếp Flutter SDK Stable mới nhất từ Google (Dart >= 3.13)
# đảm bảo tương thích 100% với camera, panorama_viewer và toàn bộ dependencies
# ==============================================================================
FROM debian:bookworm-slim AS build

# Cài đặt các gói công cụ hệ thống cần thiết cho Flutter
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone Flutter SDK Stable trực tiếp từ repository chính thức của Google
RUN git clone https://github.com/flutter/flutter.git --depth 1 -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Cấu hình git an toàn, tắt gửi analytics và tải trước web engine
RUN git config --global --add safe.directory '*' \
    && flutter config --no-analytics --enable-web \
    && flutter precache --web

WORKDIR /app

# Sao chép manifest dependencies để tận dụng Docker cache layer
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Sao chép toàn bộ mã nguồn Frontend
COPY . .

# Biên dịch Flutter Web ở chế độ Release
# Thêm --no-tree-shake-icons để tránh lỗi subsetting font icon
RUN flutter build web --release --no-tree-shake-icons

# ==============================================================================
# 2. Production Stage: Nginx Web Server
# ==============================================================================
FROM nginx:1.27-alpine AS production

# Xóa cấu hình mặc định của Nginx
RUN rm -rf /etc/nginx/conf.d/*

# Sao chép file cấu hình Nginx tối ưu cho Flutter Web
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Sao chép sản phẩm build từ builder stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Cổng truy cập mặc định cho web (port 8000 theo chuẩn dự án NHS360)
EXPOSE 8000

# Kiểm tra trạng thái container (Healthcheck)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8000/ || exit 1

# Khởi chạy Nginx
CMD ["nginx", "-g", "daemon off;"]
