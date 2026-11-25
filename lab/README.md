# Lab Tudo-em-Um (Kali + Docker) — Cyber SENAI Porto

Sobe **todos os alvos de treino** (DVWA, Juice Shop, WebGoat, WordPress) dentro de **uma única VM Kali**, usando Docker. Cobre ~90% dos comandos do treinamento sem precisar de outras máquinas.

## Como montar (do zero, no Kali)

Abra o terminal e digite:

```bash
mkdir -p ~/lab && cd ~/lab

wget https://raw.githubusercontent.com/instrutorrafaelreis/cybersenaiporto/main/lab/docker-compose.yml https://raw.githubusercontent.com/instrutorrafaelreis/cybersenaiporto/main/lab/setup-lab.sh

bash setup-lab.sh
```

O `setup-lab.sh` faz tudo sozinho: ajusta o apt para HTTPS (importante em redes que bloqueiam HTTP), instala o Docker e o Compose, e sobe os alvos. Na primeira vez demora alguns minutos para baixar as imagens.

> **Internet:** necessária apenas durante a montagem (download dos pacotes e imagens). Depois você pode voltar a VM para uma rede isolada (host-only); os alvos continuam em `localhost`.

## Acessar os alvos (navegador do Kali)

| Alvo | Endereço | Login |
|------|----------|-------|
| DVWA | http://localhost:8081 | admin / password (clique em *Create/Reset Database*) |
| Juice Shop | http://localhost:3000 | — |
| WebGoat | http://localhost:8080/WebGoat | crie um usuário |
| WordPress | http://localhost:8082 | — |

Nos tutoriais das ferramentas, troque o IP de exemplo (ex.: `192.168.56.21`) por `localhost` + a porta. Ex.: `sqlmap -u "http://localhost:8081/..."`.

## Comandos úteis

```bash
sudo docker ps            # ver o que está rodando
sudo docker compose down  # desligar tudo  (ou: sudo docker-compose down)
sudo docker compose up -d # subir de novo  (ou: sudo docker-compose up -d)
```

## Módulos que pedem máquina extra

- **Active Directory** (Kerberoasting, BloodHound, DCSync): requer uma VM Windows / Domain Controller (ou o GOAD).
- **Wireless** (Aircrack, Wifite): requer um adaptador Wi-Fi físico em modo monitor.

> Uso **autorizado** apenas — laboratório, ambientes próprios e a competição.
