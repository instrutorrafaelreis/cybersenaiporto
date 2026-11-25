#!/usr/bin/env bash
# Cyber SENAI Porto - Lab Tudo-em-Um (Kali + Docker)
# Instala o Docker (se faltar) e sobe todos os alvos de treino numa unica VM Kali.
# Uso:  chmod +x setup-lab.sh && ./setup-lab.sh
set -e

echo "[*] Cyber SENAI Porto - preparando o laboratorio tudo-em-um..."

# 0) Precisa estar na mesma pasta do docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
  echo "[!] docker-compose.yml nao encontrado nesta pasta."
  echo "    Coloque o setup-lab.sh e o docker-compose.yml juntos e rode de novo."
  exit 1
fi

# 1) Instala o Docker se necessario
if ! command -v docker >/dev/null 2>&1; then
  echo "[*] Docker nao encontrado. Instalando (vai pedir a sua senha)..."
  sudo apt update
  sudo apt install -y docker.io docker-compose-plugin
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER" || true
  echo "[!] Voce foi adicionado ao grupo docker. Se der erro de permissao,"
  echo "    saia e entre na sessao de novo, ou use 'sudo' nos comandos docker."
else
  echo "[*] Docker ja instalado."
fi

# 2) Sobe os alvos (baixa as imagens so na primeira vez)
echo "[*] Subindo os containers (pode demorar alguns minutos na 1a vez)..."
sudo docker compose up -d

# 3) Mostra os enderecos
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
echo "  Desligar:    sudo docker compose down"
echo "============================================================"
