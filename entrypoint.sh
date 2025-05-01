#!/usr/bin/env bash
set -e

# Cria a pasta persistente no /config (montada pelo Home Assistant)
mkdir -p /config/reader-screenshot
chmod 777 /config/reader-screenshot

# (Re)cria o link simbólico para /app/local-storage
# -f remove qualquer link anterior
ln -sf /config/reader-screenshot /app/local-storage

# Por fim, executa o seu servidor
exec node build/server.js
