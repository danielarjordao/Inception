# Define qual shell vai interpretar o script, nesse caso o bash
#!/bin/bash

# set -e faz o script parar se algum comando falhar
# Isso evita o banco iniciar em um estado inconsistente
set -e

# Carrega variáveis de ambiente do arquivo .env para o docker-compose
# E do docker-compose para dentro do container e então para o script
# Estas variáveis definem o nome do banco, usuário e senha
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASSWORD}"
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD}"

# Diretório onde o MariaDB armazena os dados.
MYSQL_DIR="/var/lib/mysql"

# Garante que o diretório de dados existe
mkdir -p $MYSQL_DIR
# Garante que o usuário mysql tem permissão sobre o diretório de dados
chown -R mysql:mysql $MYSQL_DIR

# ls -A lista todos os arquivos, incluindo os ocultos
# -z verifica se a string está vazia, ou seja, se não há arquivos no diretório
# Ou seja, esse if verifica se o diretório está vazio.
# - Se estiver vazio, realiza a primeira inicialização do banco
# - Se já tiver arquivos, então o banco já existe e não deve ser recriado
if [ -z "$(ls -A $MYSQL_DIR)" ]; then
    FIRST_RUN=true
else
    FIRST_RUN=false
fi

if [ "$FIRST_RUN" = true ]; then
    echo "Starting MariaDB initial setup..."

# Inicia o daemon do MariaDB em segundo plano temporariamente
# apenas para executar os comandos de criação do banco e usuário
    mysqld --user=mysql --bootstrap << EOF

CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOF

# Dentro desse daemon temporário, o banco e o usuário são criados
# Garante que todas as permissões sejam aplicadas
# Além disso, define a senha do usuário root do MariaDB
    echo "MariaDB initial setup completed."
fi

# Após a configuração inicial ou de já existir o banco,
# inicia o MariaDB normalmente.
# O exec substitui o processo do script pelo processo do mysqld,
# tornando o mysqld o processo
# principal (PID 1), mantendo o container vivo.
exec mysqld
