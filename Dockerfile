# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files first for better caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build Flutter web with release optimizations
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built web files
COPY --from=build /app/build/web /usr/share/nginx/html

# Cloud Run uses PORT environment variable
ENV PORT=8080
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
