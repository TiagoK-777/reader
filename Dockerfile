# Use Node.js 18 slim image (Debian-based)
FROM ghcr.io/home-assistant/amd64-base-debian:bookworm

# Instala ferramentas e adiciona repositórios
RUN apt-get update && \
    apt-get install -y \
      curl \
      gnupg \
      chromium \
      libmagic-dev \
      build-essential \
      python3 \
      wget && \
    # Node.js 18 via NodeSource
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    # Chrome do Google
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub \
      | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
      > /etc/apt/sources.list.d/google.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Variáveis de ambiente para o Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

# Define o diretório de trabalho
WORKDIR /app

# Copia package.json e package-lock.json e instala dependências
COPY backend/functions/package*.json ./
RUN npm ci

# Copia o restante do código e faz build
COPY backend/functions ./
RUN npm run build

# Copia o entrypoint para criar o link e a pasta no startup
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expõe a porta que a aplicação usa
EXPOSE 3000

# Usa o script como entrypoint
ENTRYPOINT ["/entrypoint.sh"]
