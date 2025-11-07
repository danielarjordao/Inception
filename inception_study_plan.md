
# Inception – Plano de Estudos e Construção (42 Porto)

Este roteiro foi desenhado para estudar e construir o projeto **Inception** da 42 de forma prática e intensiva, com 8h de estudo e prática por dia.  
A metodologia combina teoria + prática incremental: entender um conceito, testá-lo e aplicar diretamente no projeto real.

---

## 🎯 Objetivo Geral

- Compreender e aplicar os principais conceitos de conteinerização (Docker, Docker Compose, redes, volumes, variáveis de ambiente).
- Construir a infraestrutura exigida pelo projeto Inception: **NGINX + TLS**, **WordPress + PHP-FPM**, **MariaDB**, **Volumes**, e **Rede Docker**.
- Automatizar com Makefile e seguir as boas práticas de segurança e estrutura.
- Implementar scripts automáticos de inicialização e serviços adicionais opcionais (Adminer).

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

### **Dia 3 – MariaDB + WordPress + Rede Interna + Automação**
**Meta:** conectar WordPress ao banco de dados via Compose e automatizar a inicialização com scripts.  

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

---

### ⚙️ Automação com Scripts de Inicialização

Para evitar passos manuais e tornar o ambiente totalmente automatizado, cria scripts de configuração que rodem na primeira execução de cada container:

#### 📜 `mariadb/tools/mdb_exec.sh`
Roda no *entrypoint* do container MariaDB.  
Cria banco, usuários e aplica permissões automaticamente:

```bash
#!/bin/bash
service mariadb start
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
mysql -e "FLUSH PRIVILEGES;"
mysqladmin shutdown
exec mysqld_safe
```

#### 📜 `wordpress/tools/wp_exec.sh`
Executa o download e configuração do WordPress usando o CLI oficial (`wp-cli`).  
Configura automaticamente o admin e o user definidos no `.env`:

```bash
#!/bin/bash
cd /var/www/html
wp core download --allow-root
wp config create --allow-root     --dbname=$DB_NAME     --dbuser=$DB_USER     --dbpass=$DB_PASS     --dbhost=$DB_HOST
wp core install --allow-root     --url=$WP_URL     --title="$WP_SITE_TITLE"     --admin_user=$WP_ADMIN_NAME     --admin_password=$(cat /run/secrets/wp_admin_pass)     --admin_email=$WP_ADMIN_EMAIL
wp user create --allow-root     $WP_USER_NAME $WP_USER_EMAIL     --user_pass=$(cat /run/secrets/wp_user_pass)     --role=$WP_USER_ROLE
exec php-fpm7.4 -F
```

**Boas práticas:**
- Scripts devem ter `chmod +x` e serem chamados pelo `ENTRYPOINT` do Dockerfile.
- Evite `sleep`, `tail -f` ou loops infinitos.
- Use apenas comandos legítimos que mantêm o serviço ativo (`exec mysqld_safe`, `exec php-fpm -F`).

---

### **Dia 4 – Automação + Refinamento Final + Adminer**
**Meta:** consolidar, automatizar e garantir estabilidade.

#### Manhã (4h)
- Adiciona `restart: always` no Compose.
- Verifica persistência dos volumes (reinicia containers).
- Revisa conexões de rede e logs.

#### Tarde (4h)
- Organiza `.env` e `secrets/`.
- Finaliza Makefile (`build`, `clean`, `fclean`, `re`).
- Escreve README com instruções e estrutura de pastas.

---

### 🌐 Bônus (opcional): Adminer

Configurar um container **Adminer** para visualização e administração do banco de dados.

#### Estrutura:
```
srcs/requirements/adminer/
├── Dockerfile
└── tools/
    └── adminer.php
```

#### Exemplo de Dockerfile:
```dockerfile
FROM alpine:3.19
RUN apk add --no-cache php php-session php-mysqli
COPY ./tools/adminer.php /var/www/html/index.php
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
```

Adicionar ao `docker-compose.yml` e testar acesso via `https://login.42.fr/adminer`.

**Resultado:** ambiente completo, automatizado e pronto para defesa.

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
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_pass.txt
│   └── wp_user_pass.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        │       └── mdb_exec.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        │       └── wp_exec.sh
        └── adminer/   # bônus opcional
            ├── Dockerfile
            └── tools/
                └── adminer.php
```

---

## ✅ Resultado Final Esperado
Ao final do plano, você terá:
- 3 containers funcionais: **NGINX (HTTPS)**, **WordPress (PHP-FPM)** e **MariaDB**.
- Scripts de inicialização automáticos configurando o ambiente completo.
- Volumes persistentes configurados.
- Rede Docker funcional e segura.
- Makefile automatizado.
- Projeto pronto para defesa com estrutura limpa e documentada.
