# Prova Prática — Lab Web · Nível MÉDIO (DVWA Medium + Juice Shop)
### Cyber SENAI Porto · WorldSkills Cyber Security

**Aluno(a):** ______________________________  **Data:** ____/____/______

---

## Instruções

- Mesmo laboratório de sempre (os containers Docker no Kali): DVWA `http://localhost:8081`, Juice Shop `http://localhost:3000`.
- Confirme o lab no ar: `docker ps` (5 containers). Se estiver parado: `cd ~/lab && docker compose up -d`.
- No DVWA, mude **DVWA Security = Medium** (menu da esquerda).
- No nível Medium há **filtros e proteções**: os payloads do nível Low **não funcionam mais**. O objetivo desta prova é **contornar os filtros**.
- Ferramenta recomendada: **Burp Suite** (ou as DevTools do Firefox) para interceptar e editar requisições, já que o Medium usa POST / dropdowns.
- **Entrega:** para cada tarefa, **(a)** o comando/payload usado e **(b)** um **print** da evidência.
- **Uso ético:** apenas no laboratório autorizado.

**Pontuação total: 100 pontos.**

---

## Tarefa 1 — Reconhecimento ativo (10 pts)

Faça uma **enumeração de diretórios/arquivos** do alvo `http://localhost:8081` com uma ferramenta de brute-force de caminhos (gobuster, ffuf ou dirb).
- Informe o **comando** usado e pelo menos um caminho interessante encontrado (ex.: `/config`, `/login.php`).

---

## Tarefa 2 — SQL Injection no Medium (25 pts)

No Medium, o campo **User ID** vai por **POST** e a entrada passa por `mysql_real_escape_string()` — ou seja, a **aspa é neutralizada**. Mas o `id` é usado **sem aspas** na query, então dá para injetar **sem usar aspas**.
- **(a)** Intercepte a requisição (Burp) e envie um payload **numérico** que retorne mais de um usuário. **(10 pts)**
- **(b)** Extraia a tabela de usuários e informe o **hash (MD5) da senha do `admin`**. **(15 pts)**

---

## Tarefa 3 — XSS Refletido no Medium (15 pts)

No Medium, o filtro remove a string `<script>` (minúscula e exata).
- Faça o `alert` disparar **contornando** esse filtro (dica: maiúsculas/minúsculas misturadas, ou um vetor que não use a tag `<script>`).
- Entregue o **payload** e o print do alerta.

---

## Tarefa 4 — Command Injection no Medium (20 pts)

No Medium, o filtro remove `;` e `&&`.
- Mesmo assim, **leia o `/etc/passwd`** usando um operador que **não** foi bloqueado.
- Entregue o payload e o print com a linha do `root`.

---

## Tarefa 5 — File Inclusion no Medium (15 pts)

No Medium, o filtro troca `../` e bloqueia `http://`.
- Mesmo assim, **leia o `/etc/passwd`** (dica: o filtro não bloqueia **caminho absoluto**).
- Entregue a URL/parâmetro usado e o print do conteúdo.

---

## Tarefa 6 — Juice Shop: admin (15 pts)

No Juice Shop (`http://localhost:3000`):
- **(a)** Entre **como administrador** por injeção no login (sem saber a senha). **(8 pts)**
- **(b)** Informe o **e-mail do usuário admin** que você passou a controlar. **(7 pts)**

---

## Bônus (+10 pts) — Quebra de senha de outro usuário

Pegue o hash de **outro** usuário do DVWA (ex.: `gordonb`) e **recupere a senha em texto claro** com dicionário.
- Entregue o comando e a senha encontrada.

---

### Entrega por tarefa: COMANDO/PAYLOAD + PRINT da evidência.
### Boa prova! 🛡️
