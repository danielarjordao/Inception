# Plano de Estudos Inception – 4 Dias (Atualizado)


# **Dia 1 — Fundamentos + Preparação Completa do Ambiente**
**Meta:** preparar o ambiente, entender conceitos essenciais e montar a estrutura base do projeto.

### Concluído:
- Instalação da VM Debian 12.12 no VirtualBox (instalação manual correta).
- Configuração de usuário sudo.
- Instalação e validação do Docker + Docker Compose.
- Instalação correta do Guest Additions via repositório Debian.
- Pasta compartilhada configurada com permissões de leitura/escrita.
- Snapshot criado.
- Estrutura base do projeto criada:
```
inception/
 ├── Makefile
 ├── secrets/
 └── srcs/
      ├── .env
      ├── docker-compose.yml
      └── requirements/
            ├── nginx/
            ├── mariadb/
            └── wordpress/
```

- Makefile funcional (`up`, `down`, `re`).
- `docker-compose.yml` mínimo funcionando (erro esperado: Dockerfile vazio).

# **Dia 2 — MariaDB (Banco + Persistência)**
**Meta:** ter o banco de dados funcional, inicializando automaticamente com usuários e database.

### Manhã
**Estudo:**
- Como funciona o MariaDB/MySQL em containers.
- O que é um entrypoint.
- O que são variáveis de ambiente no Compose.
- Persistência de dados via volumes.

**Prática:**
- Criar `requirements/mariadb/Dockerfile`.
- Criar `conf/my.cnf` básico.
- Criar script `tools/mdb_init.sh` para:
  - criar database
  - criar root password
  - criar user normal
  - aplicar permissões

### Tarde
- Adicionar MariaDB ao `docker-compose.yml` com `env_file`.
- Criar variáveis no `.env`:
  - DB_HOST
  - DB_NAME
  - DB_USER
  - DB_PASSWORD
  - DB_ROOT_PASSWORD
- Testar o banco:
```
docker exec -it mariadb mysql -u <user> -p
```
- Confirmar persistência após `make re`.

# **Dia 3 — WordPress (PHP-FPM + WP-CLI + Configuração Automática)**
**Meta:** WordPress funcional sem servidor web, pronto para receber o NGINX.

### Manhã
**Estudo:**
- Como funciona PHP-FPM.
- O que é um socket PHP.
- O que é e como usar WP-CLI.

**Prática:**
- Criar `requirements/wordpress/Dockerfile`.
- Instalar:
  - PHP-FPM
  - extensões necessárias
  - WP-CLI
- Criar `tools/wp_setup.sh` para:
  - baixar WordPress
  - gerar wp-config.php
  - criar admin
  - criar user secundário
  - definir URL e título

### Tarde
- Conectar WordPress ao MariaDB via `.env`.
- Testar PHP-FPM:
```
docker exec -it wordpress wp --info
```
- Verificar:
  - `/var/www/html` com arquivos do WP.
  - que o entrypoint configura tudo automaticamente.

# 🟥 **Dia 4 — NGINX + TLS (HTTPS)**
**Meta:** entregar o WordPress em HTTPS pela porta 443 (único ponto de entrada).

### Manhã
**Estudo:**
- Reverse proxy
- Porta 443
- Certificados TLS (self-signed)

**Prática:**
- Criar certificados:
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx.key -out nginx.crt
```
- Criar `requirements/nginx/Dockerfile`.
- Criar `conf/server.conf` com:
  - SSL
  - proxy para PHP-FPM
  - root apontando para `/var/www/html`

### Tarde
- Inserir domínio no `/etc/hosts`:
```
127.0.0.1 login.42.fr
```
- Ajustar volumes compartilhados.
- Testar no navegador:
  - https://login.42.fr
