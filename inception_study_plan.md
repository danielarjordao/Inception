
# Inception – Plano de Estudos e Construção (42 Porto)

Este roteiro foi desenhado para estudar e construir o projeto **Inception** da 42 de forma prática e intensiva, com 8h de estudo e prática por dia.  
A metodologia combina teoria + prática incremental: entender um conceito, testá-lo e aplicar diretamente no projeto real.

---

## 🎯 Objetivo Geral

- Compreender e aplicar os principais conceitos de conteinerização (Docker, Docker Compose, redes, volumes, variáveis de ambiente).
- Construir a infraestrutura exigida pelo projeto Inception: **NGINX + TLS**, **WordPress + PHP-FPM**, **MariaDB**, **Volumes**, e **Rede Docker**.
- Automatizar com Makefile e seguir as boas práticas de segurança e estrutura.

---

## 🗓️ Plano de 4 Dias (8h/dia)

### **Dia 1 – Fundamentos + Primeira base**
**Meta:** entender o Docker e montar a base do projeto (estrutura + Makefile + Compose mínimo).

#### Manhã (4h)
**Estudo:**
- Diferença entre máquina virtual e container.
- Conceitos: imagem, container, Dockerfile, Compose, volume, rede.
- Comandos essenciais: `run`, `build`, `exec`, `logs`, `ps`.

**Prática leve:**
```bash
docker run hello-world
docker run -it debian bash
docker ps -a
docker rm -f <id>
```

#### Tarde (4h)
- Cria diretórios base: `srcs/requirements/{nginx,mariadb,wordpress}`.
- Cria `Makefile` com targets `up`, `down`, `re`.
- Escreve `docker-compose.yml` com serviços vazios (apenas `build:` e `container_name:`).
- Testa rede e volumes básicos (`docker network ls`, `docker volume ls`).

**Resultado:** estrutura organizada, Compose e Makefile funcionando.

---

### **Dia 2 – NGINX + HTTPS**
**Meta:** ter o container NGINX servindo uma página segura via TLS.

#### Manhã (4h)
**Estudo:**
- O que é NGINX, servidor reverso e porta 443.
- Conceito de certificado TLS (HTTPS).
- Como gerar certificados autoassinados com `openssl`.

**Mini prática:**
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx.key -out nginx.crt
```

#### Tarde (4h)
- Monta `nginx/Dockerfile` baseado em Debian/Alpine.
- Configura `/etc/nginx/nginx.conf` para HTTPS.
- Adiciona volume para certificados.
- Testa via navegador: `https://login.42.fr` (mapeado em `/etc/hosts`).

**Resultado:** NGINX funcionando com HTTPS na porta 443.

---

### **Dia 3 – MariaDB + WordPress + Rede Interna**
**Meta:** conectar WordPress ao banco de dados via Compose.

#### Manhã (4h)
**Estudo:**
- Estrutura do MariaDB/MySQL.
- Variáveis de ambiente (`MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`).
- Conceito de PHP-FPM e integração com WordPress.

**Mini prática:**
```bash
docker run -e MYSQL_ROOT_PASSWORD=test mariadb
mysql -u root -p
```

#### Tarde (4h)
- Cria `mariadb/Dockerfile` com volume persistente `/var/lib/mysql`.
- Cria `wordpress/Dockerfile` com PHP-FPM e WordPress instalado.
- Define `.env` e secrets (`db_password.txt`, `db_root_password.txt`).
- Testa instalação do WordPress via navegador.

**Resultado:** site WordPress online e conectado ao banco via HTTPS.

---

### **Dia 4 – Automação + Refinamento Final**
**Meta:** consolidar, automatizar e garantir estabilidade.

#### Manhã (4h)
- Adiciona `restart: always` no Compose.
- Verifica persistência dos volumes (reinicia containers).
- Revisa conexões de rede e logs.

#### Tarde (4h)
- Organiza `.env` e `secrets/`.
- Finaliza Makefile (`build`, `clean`, `fclean`, `re`).
- Escreve README com instruções e estrutura de pastas.
- Se houver tempo: implementar um bônus (Redis ou Adminer).

**Resultado:** projeto completo, funcional e pronto para defesa.

---

## 🧭 Dicas de Ritmo
- Use as manhãs para **entender e testar conceitos isolados**.
- Use as tardes para **aplicar no projeto real**.
- Ao fim de cada dia, documente o que aprendeu no README ou em um diário de progresso.
- Mantenha backups do `.env` e `secrets/` fora do Git.

---

## 📦 Estrutura Esperada do Projeto
```
inception/
├── Makefile
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   ├── requirements/
│   │   ├── nginx/
│   │   │   ├── Dockerfile
│   │   │   └── conf/
│   │   ├── mariadb/
│   │   │   ├── Dockerfile
│   │   │   └── conf/
│   │   └── wordpress/
│   │       ├── Dockerfile
│   │       └── conf/
└── secrets/
    ├── db_password.txt
    ├── db_root_password.txt
    └── credentials.txt
```

---

## ✅ Resultado Final Esperado
Ao final do plano, você terá:
- 3 containers funcionais: **NGINX (HTTPS)**, **WordPress (PHP-FPM)** e **MariaDB**.
- Volumes persistentes configurados.
- Rede Docker funcional e segura.
- Makefile automatizado.
- Projeto pronto para defesa com estrutura limpa e documentada.

---

**Autora:** Daniela Ramos Jordão  
**Campus:** 42 Porto  
**Projeto:** Inception  
**Versão:** Novembro 2025
