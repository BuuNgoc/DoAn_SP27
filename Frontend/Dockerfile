# ==============================================================================
# 1. Builder Stage: Flutter Web Compilation
# Su dung image instrumentisto/flutter cap nhat Dart SDK moi nhat (Dart >= 3.13)
# de tuong thich hoan toan voi panorama_viewer 3.0.0 va cac thu vien Flutter 3.x
# ==============================================================================
FROM instrumentisto/flutter:latest AS build

USER root
WORKDIR /app

# Cho phep git hoat dong an toan trong container
RUN git config --global --add safe.directory '*'

# Sao chép manifest dependencies để tận dụng Docker cache layer
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Sao chép toàn bộ mã nguồn Frontend
COPY . .

# Biên dịch Flutter Web ở chế độ Release
# Thêm --no-tree-shake-icons để tránh lỗi font subsetting icon
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
