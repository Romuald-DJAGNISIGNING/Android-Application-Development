# --- Stage 1: Build Environment ---
# Use a lightweight, pre-configured Flutter environment
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

WORKDIR /app

# Copy your frontend source code into the container
COPY . .

# Run the Flutter web build optimization
RUN flutter pub get
RUN flutter build web --release

# --- Stage 2: Production Web Server ---
# Use the ultra-lightweight Alpine Nginx image you already have
FROM docker.io/library/nginx:alpine

# Copy the compiled production assets from Stage 1 to Nginx's public folder
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
