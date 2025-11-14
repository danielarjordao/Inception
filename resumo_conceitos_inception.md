# Resumo Essencial para Inception: Conceitos Fundamentais de Docker

# 1. Docker vs Máquina Virtual (VM)
- VM roda um **sistema completo**, com kernel próprio, pesada.
- Docker usa o **kernel do host**, isola só o necessário, leve e rápido.
- VMs demoram minutos para iniciar; containers iniciam em milissegundos.

# 2. O que é uma Imagem Docker
- Template imutável com tudo que o container precisa.
- Construída via Dockerfile, **não pode ser baixada pronta** no Inception.
- Cada serviço (nginx, wordpress, mariadb) tem a própria imagem.
- **Regras da avaliação:**
  - Um Dockerfile por serviço (não pode estar vazio)
  - Deve começar com `FROM alpine:X.X.X` ou `FROM debian:XXXXX`
  - Nome da imagem deve ser igual ao nome do serviço
  - Proibido usar imagens prontas do DockerHub

# 3. O que é um Container
- Execução de uma imagem.
- Isolado, mas compartilhando kernel do host.
- Não guarda dados, precisa de volumes.

# 4. Dockerfile
- Arquivo que define a construção da imagem.
- Regras da avaliação:
  - Usar Debian/Alpine penúltima versão.
  - Não pode usar `tail -f`, loops infinitos ou processos em background.
  - ENTRYPOINT não pode chamar bash sem necessidade.

# 5. docker-compose
- Orquestra múltiplos containers.
- Cria redes internas, volumes, dependências, build.
- Diferença com `docker run`:
  - `docker run` inicia um container isolado.
  - `docker-compose` inicia **infraestrutura completa**.

# 6. Volumes
- Mantêm dados persistentes.
- Necessários para:
  - MariaDB: `/var/lib/mysql`
  - WordPress: `/var/www/html`
- Subject exige que volumes fiquem em `/home/login/data/`.
- Devem usar **bind mounts** apontando para:
  - `/home/login/data/wordpress`
  - `/home/login/data/mariadb`
- Na avaliação, rodam `docker volume inspect` para verificar o caminho.

# 7. Docker Network
- Containers se comunicam pelo **nome do serviço**, não pelo IP.
  - Ex.: `DB_HOST=mariadb`
- Compose cria rede automaticamente.
- Subject exige:
  - rede presente no YAML
  - cada serviço conectado à rede
  - **PROIBIDO:** `network: host`, `links:` e `--link`
  - avaliação verifica com `docker network ls`
- Você deve explicar o que é docker-network na avaliação.
- - docker network é uma rede virtual criada pelo Docker para permitir a comunicação entre containers. Cada container pode se conectar a essa rede e se comunicar com outros containers usando nomes de serviço, facilitando a configuração e o isolamento dos serviços.

# 8. ENTRYPOINT vs CMD
- ENTRYPOINT = processo principal do container (PID 1).
- Pode ser:
  - Direto: `ENTRYPOINT ["nginx", "-g", "daemon off;"]`
  - Script: `ENTRYPOINT ["sh", "setup.sh"]` que configura e depois executa o processo
- No Inception:
  - Scripts configuram MariaDB e WordPress
  - Depois iniciam o processo correto (mysqld, php-fpm)
  - **NUNCA rodar processos em background no script** (ex: `nginx & bash`)
- Proibido:
  - loops infinitos: `while true; do sleep 1; done`
  - dormir eternamente: `sleep infinity`
  - hacks: `tail -f /dev/null`, `tail -f /dev/random`
  - bash/sh sem propósito: `ENTRYPOINT ["bash"]` sozinho


# 9. Por que `tail -f` é proibido e o Problema do PID 1
- Containers não são VMs - devem rodar **um processo principal**.
- O PID 1 (primeiro processo) deve ser o serviço real (nginx, mysqld, php-fpm).
- `tail -f` mantém o container vivo, mas não faz nada útil - é hack, reprovação.
- Scripts podem configurar, mas devem **terminar executando o processo**:
  ```bash
  # setup.sh
  configuracao_inicial
  exec php-fpm -F  # 'exec' substitui o script pelo processo
  ```
- Se o processo principal morrer, o container deve morrer também (comportamento correto).


# 10. Estrutura Obrigatória do Projeto
```
inception/
 ├── Makefile
 ├── secrets/
 └── srcs/
      ├── .env
      ├── docker-compose.yml
      └── requirements/
            ├── mariadb/
            ├── wordpress/
            └── nginx/
```

# 11. Makefile
Comandos obrigatórios:
- `make` ou `make all` - inicia tudo
- `make down` - para os containers
- `make re` - reconstrói tudo

Regras da avaliação:
- Makefile deve usar **docker compose**, não `docker run`
- Deve criar os diretórios `/home/login/data/` se não existirem
- Na avaliação, rodam isso antes de testar:
  ```
  docker stop $(docker ps -qa); docker rm $(docker ps -qa);
  docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q);
  docker network rm $(docker network ls -q) 2>/dev/null
  ```

# 12. Comandos Docker essenciais
- `docker compose`
  - constrói e gerencia containers
- `docker ps -a`
  - lista containers
- `docker rm -f <id>`
  - remove container
- `docker exec -it <container> bash`
  - acessa container
- `docker logs <container>`
  - vê logs do container
- `docker volume ls`
  - lista volumes
- `docker network ls`
  - lista redes

# 13. Certificados TLS (HTTPS)
- NGINX deve servir **apenas pela porta 443**.
- Certificado pode ser autoassinado (warning de navegador é normal).
- HTTPS deve funcionar; HTTP (porta 80) deve falhar.
- **Obrigatório:** TLS v1.2 ou v1.3
- Certificado deve estar **dentro do container nginx** (copiado no Dockerfile)
- Na avaliação, verificam se você consegue acessar via HTTPS e não via HTTP

# 14. Acesso final do projeto
Fluxo:
```
Nginx → WordPress com PHP-FPM → MariaDB
```
- Site só funciona em `https://login.42.fr` (login = seu username)
- WordPress deve estar **pré-configurado** (sem tela de instalação)
  - Configurado via script no primeiro boot do container
- **Username do admin:** não pode conter `admin` ou `Admin`
  - Proibido: admin, administrator, Admin-login, admin-123
  - Permitido: dramos-j, manager, boss, etc.
- Na avaliação:
  - Testam adicionar comentário com conta comum
  - Testam editar página com conta admin
  - Verificam persistência após reboot da VM

# 15. Teste de Persistência (Crítico na Avaliação)
- Na avaliação, **rebootam a VM** para testar persistência.
- Após reiniciar:
  - `docker compose up` deve funcionar
  - Site deve voltar com todas as alterações feitas anteriormente
  - Banco de dados deve manter todos os dados
- Se os volumes não estiverem em `/home/login/data/` com bind mounts, dados serão perdidos = **reprovação**.

# Resumo
- Docker = kernel compartilhado; VM = kernel próprio.
- Imagem = receita; container = execução.
- Compose = orquestra tudo.
- Services comunicam via nome do serviço.
- Volumes persistem dados em `/home/login/data/` com **bind mounts**.
- ENTRYPOINT não pode ter loops, tail ou processos em background.
- NGINX só porta 443 com TLS v1.2/v1.3.
- WordPress com PHP-FPM (pré-configurado, sem tela de instalação).
- MariaDB + volume + init automático.
- Estrutura e Makefile obrigatórios.
