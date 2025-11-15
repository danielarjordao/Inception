# Usa Debian 12 (penúltima versão estável exigida pelo projeto)
FROM debian:12

# Atualiza o gerenciador de pacotes
# Instala o servidor MariaDB dentro da imagem
RUN apt update -y && apt install -y mariadb-server

# Adiciona uma configuração personalizada do MariaDB
# (ajustes como bind-address, diretórios e compatibilidade com Docker)
COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copia o script de inicialização personalizado para o funcionamento com o projeto
# O script configura tudo o que o MariaDB precisa (database, usuários, permissões)
# e depois inicia o servidor real como processo principal (PID 1)
# O script de inicialização substitui o uso de hacks como tail -f ou loops infinitos.
COPY ./tools/mariadb_init.sh /usr/local/bin/mariadb_init.sh

# Adiciona permissão de execução ao script
RUN chmod +x /usr/local/bin/mariadb_init.sh

# O MariaDB funciona como um daemon, ou seja, um processo de serviço que roda em
# segundo plano e mantém o banco acessível. Em um container Docker, esse daemon
# deve ser o PID 1. O script abaixo executa a configuração inicial apenas na
# primeira execução e, em seguida, inicia o mysqld como o daemon principal.
ENTRYPOINT ["mariadb_init.sh"]
