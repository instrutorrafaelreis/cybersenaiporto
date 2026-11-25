# Prova Prática — Lab Web (DVWA + Juice Shop)
### Cyber SENAI Porto · WorldSkills Cyber Security

**Aluno(a):** ______________________________  **Data:** ____/____/______

---

## Instruções

- Ambiente: laboratório **local** no Kali (DVWA em `http://localhost:8081`, Juice Shop em `http://localhost:3000`).
- Antes de começar, confirme o lab no ar: `docker ps` (5 containers).
- No DVWA, deixe **DVWA Security = Low** (salvo quando a tarefa pedir outro nível).
- **Duração sugerida:** 2 horas.
- **Entrega:** para cada tarefa, envie **(a)** o(s) comando(s) ou payload(s) usados e **(b)** um **print** que comprove o resultado.
- **Uso ético:** estas técnicas só podem ser usadas em sistemas autorizados. Fora do lab, é crime.

**Pontuação total: 100 pontos.**

---

## Tarefa 1 — Reconhecimento (10 pts)

Identifique a **tecnologia** que roda no alvo `http://localhost:8081`.
- Informe o **servidor web**, a **linguagem** e qualquer **versão** que encontrar.
- Entregue o comando usado e o print da saída.

---

## Tarefa 2 — SQL Injection (25 pts)

Na página **SQL Injection** do DVWA:
- **(a)** Comprove a injeção manualmente (mostre um payload que retorne mais de um usuário). **(10 pts)**
- **(b)** Extraia a tabela de usuários do banco `dvwa` e informe o **hash da senha do usuário `admin`**. **(15 pts)**

Entregue os comandos/payloads e os prints.

---

## Tarefa 3 — Cross-Site Scripting (XSS) (15 pts)

Na página **XSS (Reflected)** do DVWA:
- Faça o navegador **executar um alerta** (`alert`) a partir da sua entrada.
- Entregue o **payload** usado e o print com a caixa de alerta aberta.

---

## Tarefa 4 — Command Injection (20 pts)

Na página **Command Injection** do DVWA:
- Além do ping normal, **leia o arquivo `/etc/passwd`** do servidor.
- Entregue o payload usado e o print mostrando o conteúdo (a linha do `root` deve aparecer).

---

## Tarefa 5 — File Inclusion / LFI (15 pts)

Na página **File Inclusion** do DVWA:
- **Leia um arquivo do sistema** (ex.: `/etc/passwd`) explorando o parâmetro `page`.
- Entregue a URL usada e o print do conteúdo exibido.

---

## Tarefa 6 — Juice Shop: burlar o login (15 pts)

No Juice Shop (`http://localhost:3000`):
- Entre **como administrador sem saber a senha**, usando injeção no formulário de login.
- Entregue o payload usado e o print já **logado** (o e-mail do admin deve aparecer no topo).

---

## Bônus (+10 pts) — Quebra de senha

Pegue o **hash do admin** da Tarefa 2 e **recupere a senha em texto claro** (dicionário).
- Entregue o comando e o print mostrando a senha encontrada.

---

### Para cada tarefa, lembre-se de entregar: COMANDO/PAYLOAD + PRINT da evidência.
### Boa prova! 🛡️
