FROM node:22-slim

WORKDIR /app
RUN apt-get update && apt-get install -y \
    libc6 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*
   ENV CI=true
# Install wrangler globally to run the cloudflare worker locally
RUN npm install -g wrangler
# Copy the global package files first
COPY package*.json ./
RUN npm install

# Copy the cf-worker directory code
COPY cf-worker/ ./cf-worker/

EXPOSE 8787

# Run wrangler locally in dev/local mode targeting your worker folder
CMD ["npx", "wrangler", "dev", "./cf-worker/src/index.ts", "--ip", "0.0.0.0", "--port", "8787", "--local", "--show-interactive-dev-session=false"]
