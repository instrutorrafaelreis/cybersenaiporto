# Sobre o Desafio — Lab Web (DVWA + Juice Shop)
### Cyber SENAI Porto · WorldSkills Cyber Security (Skill 54)

## O que é este desafio
É uma **prova prática (hands-on)** de exploração web. O aluno ataca aplicações **propositalmente vulneráveis** rodando no próprio laboratório (DVWA em `localhost:8081` e Juice Shop em `localhost:3000`) para **encontrar e explorar** as vulnerabilidades web mais comuns. Não é múltipla escolha: o aluno precisa **explorar de verdade** e entregar **evidência** (comando/payload + print) de cada tarefa.

## Onde se enquadra no WorldSkills Cyber Security
O WorldSkills Cyber Security (Skill 54) é dividido em módulos de **Enterprise Infrastructure Security**, **Incident Response / Forense / Application Security**, **Blue Team** e **Red Team**. Este desafio pertence ao lado **ofensivo (Red Team / Penetration Testing)**, com forte ligação com **Application Security** — é a etapa em que o competidor demonstra que sabe **atacar uma aplicação web** e, na sequência, **explicar como corrigir**. Também exercita a competência de **documentação/relatório**, que é pontuada na competição.

## A qual prova da plataforma ele se liga
- **Prova E — CTF / Pentest (ofensiva):** é a casa natural deste desafio — reconhecimento e *web exploitation* (SQLi, XSS, LFI, etc.).
- **Prova F — Application Security (defensiva):** cada falha explorada aqui tem sua **correção** lá (OWASP Top 10). Atacar e saber corrigir é o que o WorldSkills premia.
- **Aba Ferramentas (Arsenal) + Laboratório (VMs):** fornecem as ferramentas (sqlmap, Burp, hashcat…) e o ambiente (Kali + Docker) usados no desafio.

## Competências avaliadas
- **Reconhecimento** (fingerprint de tecnologia, portas/serviços).
- **Injeção — OWASP A05:** SQL Injection e Command Injection.
- **Cross-Site Scripting (XSS).**
- **File Inclusion / LFI.**
- **Quebra de senha** (hash → texto claro).
- **Documentação:** registrar comando/payload + evidência de cada passo.

## Objetivo pedagógico
Treinar o reflexo do competidor: **reconhecer a falha rápido → explorar com segurança no lab → documentar → saber a correção**. É a ponte entre a teoria (conceitos das provas) e a mão na massa (atacar um alvo real e controlado).

## Nível e duração
**Iniciante → intermediário.** Duração sugerida: **~2 horas.** Pontuação: **100 pontos + bônus.** Para turmas avançadas, repetir no DVWA em nível **Medium/High** (exige bypass de filtros).

## Pré-requisitos
1. **Laboratório montado** (Kali + Docker; DVWA e Juice Shop no ar) — ver *Ferramentas → Laboratório (VMs) → Lab Tudo-em-Um*.
2. Ter estudado o **Tutorial** (mesma área do instrutor).

## Como se conecta ao restante do treinamento
> **Conceitos (Provas A–F) → Arsenal (Ferramentas) → Lab (ambiente) → ESTE DESAFIO (aplicar atacando) → Correção (Prova F).**

Ou seja: o aluno aprende o conceito, conhece a ferramenta, monta o ambiente, **ataca de verdade** aqui, e fecha o ciclo entendendo como **defender**. É exatamente o perfil que a competição exige: dominar os dois lados.

## Ética
Todas as técnicas só podem ser usadas em sistemas **autorizados** (laboratório, ambientes próprios e a competição). Fora disso, é crime. O profissional WorldSkills domina a técnica **e** a responsabilidade.
