#!/bin/bash
# Script de inicialização do MariaDB para uso em containers Docker.

set -e
# set -e: interrompe o script caso qualquer comando falhe,
# evitando que o container suba com o banco mal configurado.

# Variáveis de Ambiente
# Enviadas automaticamente pelo docker-compose.yml
# São usadas para criar o DB, usuário, senha e senha root.
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASSWORD}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD}"

# Arquivo SQL temporário
# Este arquivo receberá os comandos SQL executados apenas
# na primeira inicialização do MariaDB.
INIT_SQL="/tmp/init.sql"

# Arquivo de flag de inicialização
# Indica se o banco já foi inicializado.
FLAG="/var/lib/mysql/.db_initialized"

# Criar diretórios necessários e ajustar permissões
# /run/mysqld: socket Unix (não persiste, precisa criar toda vez)
# /var/log/mysql: logs do MariaDB
# /var/lib/mysql: dados do banco (já existe pelo volume, mas precisa ajustar owner)
mkdir -p /run/mysqld /var/log/mysql
chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql

# Verificar se o banco já existe
# A pasta /var/lib/mysql/mysql contém as tabelas do sistema do MariaDB.
# Se ela existe, significa que mysql_install_db já foi executado antes.
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First time initialization detected."

    # Inicializar diretório de dados
    # Cria a estrutura inicial do banco (tabelas do sistema: mysql, performance_schema, etc)
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Criar arquivo SQL de inicialização
    # Este SQL será executado automaticamente quando o servidor iniciar pela primeira vez.
    # Contém comandos para criar database, usuário e definir permissões.
    cat << EOF > $INIT_SQL
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    echo "MariaDB initial setup completed."
fi

# Iniciar MariaDB
# O MariaDB deve rodar como PID 1 do container (exec substitui o processo do script).
# Na primeira vez, usa --init-file para executar o SQL de configuração.
# Nas próximas, inicia normalmente sem init-file.
echo "Starting MariaDB server..."
if [ -f "$INIT_SQL" ]; then
    # Primeira inicialização: executa SQL antes de aceitar conexões
    exec mysqld --user=mysql --console --init-file=$INIT_SQL
else
    # Já inicializado: apenas inicia o servidor
    exec mysqld --user=mysql --console
fi
