#!/usr/bin/env bash
# =====================================================================
# Cyber SENAI Porto - Lab Tudo-em-Um (Kali + Docker)
# Instala o Docker + Compose e sobe TODOS os alvos de treino numa unica
# VM Kali. Feito para rodar do zero, mesmo em redes que bloqueiam HTTP.
#
# Uso:
#   1) mkdir -p ~/lab && cd ~/lab
#   2) wget https://raw.githubusercontent.com/instrutorrafaelreis/cybersenaiporto/main/lab/docker-compose.yml \
#           https://raw.githubusercontent.com/instrutorrafaelreis/cybersenaiporto/main/lab/setup-lab.sh
#   3) bash setup-lab.sh
# =====================================================================

echo "[*] Cyber SENAI Porto - preparando o laboratorio tudo-em-um..."

# 0) O docker-compose.yml precisa estar na mesma pasta
if [ ! -f "docker-compose.yml" ]; then
  echo "[!] docker-compose.yml nao encontrado nesta pasta."
  echo "    Baixe os DOIS arquivos (docker-compose.yml e setup-lab.sh) juntos e rode de novo."
  exit 1
fi

# 1) Deixar o apt usar HTTPS.
#    Muitas redes (escola/empresa) bloqueiam HTTP (porta 80). Como o Kali
#    usa HTTP por padrao, o apt trava com "Conexao expirou". HTTPS (443)
#    costuma passar, entao trocamos os mirrors para https.
echo "[*] Ajustando o apt para HTTPS (evita travar em redes que bloqueiam HTTP)..."
for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list; do
  [ -f "$f" ] && sudo sed -i 's|http://http.kali.org|https://http.kali.org|g; s|http://kali.download|https://kali.download|g' "$f" 2>/dev/null || true
done

echo "[*] Atualizando a lista de pacotes (pode pedir a sua senha)..."
sudo apt-get update -y || true

# 2) Docker Engine
if ! command -v docker >/dev/null 2>&1; then
  echo "[*] Instalando o Docker (docker.io)..."
  sudo apt-get install -y docker.io
fi
sudo systemctl enable --now docker 2>/dev/null || true
sudo usermod -aG docker "$USER" 2>/dev/null || true

if ! command -v docker >/dev/null 2>&1; then
  echo "[!] Nao consegui instalar o Docker."
  echo "    Confirme que a VM tem internet (ex.: ping -c3 8.8.8.8) e rode de novo."
  exit 1
fi

# 3) Docker Compose: tenta nesta ordem ate achar um que funcione
#    (a) plugin v2 ja instalado   -> comando:  docker compose
#    (b) docker-compose ja existe -> comando:  docker-compose
#    (c) instalar docker-compose pelo apt (Kali tem este pacote)
#    (d) baixar o binario do Compose v2 direto do GitHub (HTTPS)
if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
elif sudo apt-get install -y docker-compose >/dev/null 2>&1 && command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo "[*] Baixando o Docker Compose v2 do GitHub (HTTPS)..."
  sudo wget -qO /usr/local/bin/docker-compose \
    https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64
  sudo chmod +x /usr/local/bin/docker-compose
  COMPOSE="docker-compose"
fi
echo "[*] Usando o Compose: '$COMPOSE'"

# 4) Sobe os alvos (baixa as imagens do Docker Hub via HTTPS na 1a vez)
echo "[*] Subindo os containers (na primeira vez demora alguns minutos)..."
sudo $COMPOSE up -d

# 5) Mostra os enderecos
echo ""
echo "============================================================"
echo "  Laboratorio pronto! Acesse pelo navegador do Kali:"
echo "    DVWA        ->  http://localhost:8081    (admin / password)"
echo "    Juice Shop  ->  http://localhost:3000"
echo "    WebGoat     ->  http://localhost:8080/WebGoat"
echo "    WordPress   ->  http://localhost:8082"
echo "------------------------------------------------------------"
echo "  Nos tutoriais, troque o IP de exemplo por 'localhost' + a porta."
echo "  Ver status:  sudo docker ps"
echo "  Desligar:    sudo $COMPOSE down"
echo "============================================================"
