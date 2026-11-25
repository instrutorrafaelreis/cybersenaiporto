# Tutorial Passo a Passo — Primeiros Ataques no Lab Web
### Cyber SENAI Porto · WorldSkills Cyber Security · DVWA + Juice Shop

> **Para o aluno aprender.** Cada ataque segue a mesma lógica das provas:
> **o que é (conceito) → como fazer → o que observar → como corrigir.**
> Uso **autorizado** apenas: este é um laboratório local, de treino.

---

## Parte 0 — Preparar o ambiente (5 min)

1. Confirme que o lab está no ar (no terminal do Kali):
   ```
   docker ps
   ```
   Devem aparecer: `lab-dvwa`, `lab-juice-shop`, `lab-webgoat`, `lab-wordpress`, `lab-wp-db`.

2. Abra o **Firefox** no Kali e acesse o **DVWA**: `http://localhost:8081`
   - Login: **admin** / **password**
   - Clique em **Create / Reset Database** (botão no fim da página) e logue de novo.
   - Vá em **DVWA Security** (menu esquerdo) e selecione **Low**. (Comece fácil; depois suba.)

3. Abra também o **Juice Shop**: `http://localhost:3000` (vamos usar na Parte 6).

> 💡 Dica: deixe o **Burp Suite** aberto em paralelo (Proxy → Intercept Off, só para ver o histórico das requisições). Opcional, mas ajuda a entender o que acontece.

---

## Parte 1 — Reconhecimento (10 min)

**O que é:** antes de atacar, você mapeia o alvo — portas, serviços e tecnologias. É o primeiro passo de qualquer teste.

### E se você NÃO souber o endereço do alvo?

No nosso lab já sabemos que é `localhost`. Mas num teste real você recebe só uma **faixa de IPs** (um escopo), e precisa **descobrir o alvo** primeiro:

1. Descubra a **sua** rede: `ip a` — veja seu IP e a máscara (ex.: `192.168.56.0/24`).
2. Ache os **hosts vivos** na faixa: `nmap -sn 192.168.56.0/24` ou `netdiscover -r 192.168.56.0/24` (este último usa ARP, acha até quem ignora ping).
3. Identifique **qual** é o alvo pelo serviço: `nmap -p 80,443,3000,8080 --open 192.168.56.0/24` (quem tiver web aberto é candidato).
4. Com o IP em mãos, siga o recon normal: `nmap -sV IP` e `whatweb http://IP`.

Se te deram um **domínio** em vez de IP, resolva antes: `dig alvo.local +short` (ou `nslookup alvo.local`).

> 💡 No lab os alvos sobem em containers no próprio Kali, por isso usamos `localhost`. Se um alvo estiver em **outra VM** (ex.: Metasploitable na rede host-only), é exatamente esse processo (passos 1→4) que você usa para encontrá-lo.

**Como fazer (no nosso lab, com o endereço conhecido):**
```
whatweb http://localhost:8081
```
Veja o servidor (Apache), a linguagem (PHP) e o framework.

```
nmap -sV -p 8081,3000,8080,8082 localhost
```
Confirma os serviços rodando em cada porta.

**O que observar:** anote a tecnologia de cada alvo. Saber que é PHP + MySQL já diz que **SQL Injection** é um caminho provável.

---

## Parte 2 — SQL Injection (SQLi) no DVWA (20 min)

**O que é:** a aplicação monta uma consulta SQL juntando a sua entrada **sem tratar**. Você injeta SQL e muda o sentido da consulta. CWE-89.

### 2.1 Testar manualmente
1. No DVWA, vá em **SQL Injection**.
2. No campo **User ID**, digite `1` e clique em Submit — retorna 1 usuário.
3. Agora digite:
   ```
   1' OR '1'='1
   ```
   e Submit. **O que observar:** retornou **vários** usuários — a condição `'1'='1'` é sempre verdadeira. Isso confirma a injeção.

### 2.2 Automatizar com sqlmap
1. Copie a URL da página (ex.): `http://localhost:8081/vulnerabilities/sqli/?id=1&Submit=Submit`
2. Pegue o **cookie**: no Firefox, F12 → **Storage/Armazenamento → Cookies** → copie `PHPSESSID` e `security`.
3. No terminal:
   ```
   sqlmap -u "http://localhost:8081/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="PHPSESSID=XXXX; security=low" --batch --dbs
   ```
   **O que observar:** o sqlmap confirma a injeção e lista os bancos (ex.: `dvwa`).
4. Extraia os usuários e senhas:
   ```
   sqlmap -u "http://localhost:8081/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="PHPSESSID=XXXX; security=low" --batch -D dvwa -T users --dump
   ```
   **O que observar:** aparece a tabela `users` com `user` e `password` (hash **MD5**). Guarde o hash do **admin**.

### 2.3 Quebrar o hash (bônus)
```
echo 'HASH_DO_ADMIN' > hash.txt
hashcat -m 0 hash.txt /usr/share/wordlists/rockyou.txt
```
(Se o rockyou estiver zipado: `gunzip /usr/share/wordlists/rockyou.txt.gz`.)

### 2.4 Como corrigir 🟢
Use **consultas parametrizadas** (prepared statements) — o dado nunca vira código:
```php
$stmt = $pdo->prepare("SELECT * FROM users WHERE user_id = ?");
$stmt->execute([$id]);
```

---

## Parte 3 — XSS Refletido no DVWA (15 min)

**O que é:** a aplicação devolve a sua entrada na página **sem escapar**, e o navegador executa como HTML/JS. CWE-79.

**Como fazer:**
1. No DVWA, vá em **XSS (Reflected)**.
2. No campo de nome, digite:
   ```
   <script>alert('XSS')</script>
   ```
   e Submit. **O que observar:** aparece a caixinha de alerta — seu script rodou no navegador.
3. Teste uma variação sem `<script>` (para entender filtros):
   ```
   <img src=x onerror=alert('XSS')>
   ```

**Impacto:** com XSS dá para roubar cookies de sessão, redirecionar, etc.

**Como corrigir 🟢:** **escape a saída** por contexto (ex.: `htmlspecialchars()` em PHP) e use `Content-Security-Policy`.

---

## Parte 4 — Command Injection no DVWA (15 min)

**O que é:** a aplicação passa a sua entrada para um **comando do sistema** sem tratar. Você anexa um segundo comando. CWE-78.

**Como fazer:**
1. No DVWA, vá em **Command Injection**.
2. No campo de IP, digite um IP normal: `127.0.0.1` → ele faz um ping.
3. Agora digite:
   ```
   127.0.0.1; cat /etc/passwd
   ```
   **O que observar:** além do ping, aparece o conteúdo do `/etc/passwd` — você executou um comando no servidor.
4. Teste também `127.0.0.1 && whoami`.

**Como corrigir 🟢:** nunca montar comando com entrada do usuário; usar APIs seguras / listas de argumentos e validar a entrada (allowlist).

---

## Parte 5 — File Inclusion / LFI no DVWA (15 min)

**O que é:** a aplicação inclui um arquivo cujo caminho vem da sua entrada, sem validar. Você lê arquivos do servidor. CWE-98.

**Como fazer:**
1. No DVWA, vá em **File Inclusion**.
2. Repare na URL: `...?page=include.php`.
3. Troque o parâmetro por um arquivo do sistema:
   ```
   http://localhost:8081/vulnerabilities/fi/?page=/etc/passwd
   ```
   **O que observar:** o conteúdo do `/etc/passwd` aparece na página.
4. Teste "path traversal": `?page=../../../../etc/passwd`

**Como corrigir 🟢:** nunca incluir caminho vindo do usuário; usar **allowlist** de arquivos permitidos e caminho absoluto fixo.

---

## Parte 6 — Juice Shop: login como admin via SQLi (15 min)

**O que é:** mesmo princípio da Parte 2, agora numa aplicação moderna (SPA).

**Como fazer:**
1. Abra `http://localhost:3000` e vá em **Account → Login**.
2. No campo **Email**, digite:
   ```
   ' OR 1=1--
   ```
   No campo **Password**, digite qualquer coisa. Clique em **Log in**.
   **O que observar:** você entra **como o primeiro usuário (admin)** — a injeção burlou a autenticação.
3. Explore o **placar de desafios**: `http://localhost:3000/#/score-board` (achar o placar já é um desafio!).

**Como corrigir 🟢:** consultas parametrizadas + **nunca** autenticar comparando string montada com a entrada.

---

## Encerramento

- Suba a dificuldade do DVWA (**Medium** → **High**) e veja como os mesmos ataques exigem técnicas melhores (bypass de filtros).
- Fixe a lógica: **toda** injeção nasce de **misturar dado com código** — e a defesa é sempre **separar** (parametrizar / escapar / validar).
- Para a competição, treine **velocidade**: reconhecer a falha e explorar rápido, documentando cada passo (print + comando) para o relatório.

➡️ Quando você dominar isto, parta para o **WebGoat** (`http://localhost:8080/WebGoat`), que traz lições guiadas mais avançadas.
