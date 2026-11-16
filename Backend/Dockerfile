# ==============================================================================
# Backend & Local Database (Firebase Emulators Suite) Dockerfile
# Group SE13 - SmartTravel Ngu Hanh Son
# ==============================================================================
FROM node:20-alpine

# Cài đặt OpenJDK 17 (bắt buộc cho Firestore & Cloud Storage emulators), curl, bash
RUN apk add --no-cache openjdk17-jre bash curl dos2unix

# Cài đặt Firebase CLI toàn cục
RUN npm install -g firebase-tools@13.31.1

WORKDIR /workspace

# Sao chép các tệp cấu hình Firebase root
COPY firebase.json .firebaserc firestore.rules firestore.indexes.json storage.rules ./

# Sao chép và cài đặt dependencies cho Cloud Functions
COPY functions/package.json functions/package-lock.json ./functions/
RUN npm --prefix functions ci

# Sao chép mã nguồn TypeScript của Functions và biên dịch
COPY functions/ ./functions/
RUN npm --prefix functions run build

# Sao chép entrypoint script
COPY docker-entrypoint.sh ./
RUN dos2unix ./docker-entrypoint.sh && chmod +x ./docker-entrypoint.sh

# Tạo thư mục dữ liệu cục bộ cho Firestore/Auth persistence
RUN mkdir -p /workspace/emulator-data

# Mở các cổng mạng của Firebase Emulators
# 4000: Web Dashboard UI
# 5001: Cloud Functions API
# 8080: Cloud Firestore Database
# 9099: Firebase Authentication
# 9199: Cloud Storage
EXPOSE 4000 5001 8080 9099 9199

# Kiểm tra trạng thái container (Healthcheck kiểm tra Dashboard UI)
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:4000/ || exit 1

ENTRYPOINT ["/workspace/docker-entrypoint.sh"]
