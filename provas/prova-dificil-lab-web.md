# Prova Prática — Lab Web · Nível DIFÍCIL (DVWA High + WordPress + Juice Shop)
### Cyber SENAI Porto · WorldSkills Cyber Security

**Aluno(a):** ______________________________  **Data:** ____/____/______

---

## Instruções

- Mesmo laboratório (containers Docker no Kali): DVWA `http://localhost:8081`, Juice Shop `http://localhost:3000`, WordPress `http://localhost:8082`, WebGoat `http://localhost:8085/WebGoat`.
- Confirme o lab: `docker ps` (5 containers). Parado? `cd ~/lab && docker compose up -d`.
- No DVWA, mude **DVWA Security = High**. Aqui os filtros são **agressivos** — você precisa de técnicas de **bypass** e de ferramentas automatizadas.
- Use **Burp Suite**, **sqlmap** e **wpscan** conforme a tarefa.
- **Entrega:** para cada tarefa, **(a)** o(s) comando(s)/payload(s) e **(b)** o **print** da evidência.
- **Uso ético:** apenas no laboratório autorizado.

**Pontuação total: 100 pontos.**

---

## Tarefa 1 — Enumeração do WordPress (10 pts)

O container WordPress está em `http://localhost:8082`.
- Use o **wpscan** para **enumerar os usuários** do WordPress.
- Entregue o comando usado e a lista de usuários encontrada.

---

## Tarefa 2 — SQL Injection no High (25 pts)

No High, a query usa `LIMIT 1` e a entrada vai por outra janela (sem resposta imediata). O truque é **comentar** o resto da query para anular o `LIMIT`.
- **(a)** Monte um payload com **UNION** e um **comentário** (`#` ou `-- -`) que extraia dados mesmo com o `LIMIT 1`. **(15 pts)**
- **(b)** Extraia e informe o **hash (MD5) da senha do `admin`**. **(10 pts)**

---

## Tarefa 3 — SQL Injection cego / automatizado (20 pts)

Nem toda injeção devolve o dado na tela (injeção **cega**).
- Use o **sqlmap** aumentando a agressividade (ex.: `--level` / `--risk`) para detectar e **extrair** os dados da injeção, mesmo cega.
- Entregue o comando completo e o print do dump.

---

## Tarefa 4 — XSS no High (15 pts)

No High, um filtro por **expressão regular** bloqueia as variações de `<script>`.
- Dispare o `alert` usando um **vetor que não seja a tag `<script>`**.
- Entregue o payload e o print do alerta.

---

## Tarefa 5 — Command Injection no High (15 pts)

No High, a blacklist cobre vários operadores — mas deixa escapar um caso específico de **pipe**.
- **Leia o `/etc/passwd`** contornando a blacklist (dica: atenção ao **espaço** depois do operador).
- Entregue o payload e o print.

---

## Tarefa 6 — File Inclusion no High (15 pts)

No High, a aplicação exige que o nome do arquivo **comece com `file`** (`fnmatch("file*", ...)`).
- **Leia o `/etc/passwd`** respeitando essa regra (dica: o esquema `file://`).
- Entregue a URL/parâmetro usado e o print.

---

## Bônus (+15 pts) — Juice Shop + quebra de hash

- **(a)** No Juice Shop, abra o **painel de desafios** (score board) — informe a **URL** que leva até ele. **(7 pts)**
- **(b)** Quebre o hash de um usuário secundário do DVWA (ex.: `gordonb`) e informe a **senha em texto claro**. **(8 pts)**

---

### Entrega por tarefa: COMANDO/PAYLOAD + PRINT da evidência.
### Boa prova! 🛡️
