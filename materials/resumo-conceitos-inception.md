# Resumo - Conceitos Fundamentais de Docker

## 1. Docker vs Máquina Virtual (VM)

- **Máquina Virtual (VM):** Roda um sistema operacional completo, com kernel próprio, drivers, interface gráfica, etc. É pesada, consome mais recursos e demora minutos para iniciar.
- **Docker:** Não cria um sistema operacional inteiro, mas sim containers isolados que compartilham o kernel do host. Cada container tem só o necessário para rodar o serviço. É muito mais leve, rápido (inicia em milissegundos) e eficiente.
- **Resumo:** VM = isolamento total, mais pesado. Docker = isolamento de processos, mais leve e rápido.

## 2. O que é uma Imagem Docker

- **Imagem:** É um template imutável, como uma "receita" que define tudo que o container precisa para rodar (sistema base, dependências, arquivos, comandos de inicialização).
- **No Inception:** Você deve construir todas as imagens a partir do zero, usando um Dockerfile para cada serviço (nginx, wordpress, mariadb). Não pode baixar imagens prontas do DockerHub.
- **Regras obrigatórias:**
  - Um Dockerfile por serviço (não pode estar vazio)
  - O Dockerfile deve começar com `FROM alpine:X.X.X` ou `FROM debian:XXXXX` (penúltima versão)
  - O nome da imagem deve ser igual ao nome do serviço
  - Proibido usar imagens prontas do DockerHub

## 3. O que é um Container

- **Container:** É a execução de uma imagem. Ele roda isolado dos outros processos, mas compartilha o kernel do host.
- **Importante:** Containers não guardam dados permanentemente. Se você remover o container, os dados somem. Por isso, usamos volumes para persistência.

## 4. Dockerfile

- **Dockerfile:** É o arquivo de instruções que define como construir a imagem. Nele você especifica o sistema base, instala pacotes, copia arquivos, define variáveis, etc.
- **Regras obrigatórias:**
  - Usar Debian ou Alpine na penúltima versão disponível.
  - Não pode usar comandos como `tail -f`, loops infinitos ou processos em background para manter o container vivo.
  - O ENTRYPOINT não pode chamar bash/sh sem necessidade (evite hacks).

## 5. docker-compose

- **docker-compose:** Ferramenta que orquestra múltiplos containers de uma vez, criando redes, volumes, dependências e builds automaticamente.
- **No Inception:** Você deve usar docker-compose para subir toda a infraestrutura (nginx, wordpress, mariadb) de uma vez só.
- **Diferença:**
  - `docker run` inicia um container isolado.
  - `docker-compose` sobe todos os serviços juntos, já conectados e configurados.

## 6. Volumes

- **Volumes:** São usados para manter dados persistentes mesmo que o container seja removido.
- **No Inception:**
  - MariaDB deve persistir dados em `/var/lib/mysql`
  - WordPress deve persistir dados em `/var/www/html`
- **Regras obrigatórias:**
  - Os volumes devem ser bind mounts, apontando para `/home/login/data/wordpress` e `/home/login/data/mariadb` (substitua "login" pelo seu username).
  - Não pode usar volumes padrão do Docker (tem que ser bind mount).
  - O avaliador vai rodar `docker volume inspect` para conferir o caminho.

## 7. Docker Network

- **Rede Docker:** Permite que containers se comuniquem entre si usando o nome do serviço (ex: `DB_HOST=mariadb`), sem precisar de IP fixo.
- **No Inception:**
  - O docker-compose cria uma rede automaticamente, mas você deve declarar explicitamente a rede no YAML e conectar todos os serviços a ela.
  - **Proibido:** usar `network: host`, `links:` ou `--link`.
  - O avaliador vai rodar `docker network ls` para conferir.
- **Explicação para defesa:** Docker network é uma rede virtual criada pelo Docker para que containers possam se comunicar de forma isolada e segura, usando nomes de serviço.

## 8. ENTRYPOINT vs CMD

- **ENTRYPOINT:** Define o processo principal do container (PID 1). É o que realmente mantém o container "vivo".
- **CMD:** Serve como argumento padrão para o ENTRYPOINT, mas pode ser sobrescrito.
- **No Inception:**
  - O ENTRYPOINT pode ser um comando direto (ex: `ENTRYPOINT ["nginx", "-g", "daemon off;"]`) ou um script (ex: `ENTRYPOINT ["sh", "setup.sh"]`).
  - O script pode fazer configurações iniciais, mas deve terminar executando o processo principal (ex: `exec php-fpm -F`).
  - **Nunca rode processos em background no script** (ex: `nginx & bash`).
- **Proibido:**
  - Loops infinitos: `while true; do sleep 1; done`
  - Dormir eternamente: `sleep infinity`
  - Hacks: `tail -f /dev/null`, `tail -f /dev/random`
  - Bash/sh sem propósito: `ENTRYPOINT ["bash"]` sozinho

## 9. Por que `tail -f` é proibido e o Problema do PID 1

- **Containers não são VMs:** Eles devem rodar apenas um processo principal (PID 1), que é o serviço real (nginx, mysqld, php-fpm, etc).
- **Por que não usar `tail -f`?** Ele só mantém o container "vivo" sem rodar nada útil. Isso é considerado hack e reprova na avaliação.
- **Correto:**
  - O script de setup pode fazer configurações, mas deve terminar com `exec <serviço>` para substituir o script pelo processo real.
  - Exemplo:

    ```bash
    # setup.sh
    configuracao_inicial
    exec php-fpm -F  # 'exec' substitui o script pelo processo
    ```

- **Se o processo principal morrer, o container deve morrer também!**

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

## 10. Estrutura Obrigatória do Projeto

```console
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

## 11. Makefile

- **Comandos obrigatórios:**
  - `make` ou `make all` — Sobe toda a infraestrutura
  - `make down` — Para e remove todos os containers
  - `make re` — Reconstrói tudo do zero
- **Regras da avaliação:**
  - O Makefile deve usar **docker compose** (não pode usar `docker run`)
  - Deve criar os diretórios `/home/login/data/` se não existirem
  - Antes de testar, o avaliador pode rodar:

    ```bash
    docker stop $(docker ps -qa); docker rm $(docker ps -qa);
    docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q);
    docker network rm $(docker network ls -q) 2>/dev/null
    ```

## 12. Comandos Docker Essenciais

- `docker compose` — constrói e gerencia todos os containers do projeto
- `docker ps -a` — lista todos os containers (ativos e parados)
- `docker rm -f <id>` — remove um container
- `docker exec -it <container> bash` — acessa o terminal de um container
- `docker logs <container>` — vê os logs de um container
- `docker volume ls` — lista todos os volumes
- `docker network ls` — lista todas as redes

## 13. Certificados TLS (HTTPS)

- **NGINX deve servir apenas pela porta 443 (HTTPS)**. Não pode responder na porta 80 (HTTP).
- O certificado pode ser autoassinado (o navegador vai mostrar um aviso, isso é esperado).
- **Obrigatório:** TLS v1.2 ou v1.3
- O certificado deve estar **dentro do container nginx** (copiado via Dockerfile).
- O avaliador vai testar se o acesso HTTPS funciona e HTTP não.

## 14. Acesso final do projeto

- **Fluxo de acesso:**

  ```console
  Nginx → WordPress (PHP-FPM) → MariaDB
  ```

- O site só pode funcionar em `https://login.42.fr` (substitua "login" pelo seu username)
- O WordPress deve estar **pré-configurado** (não pode aparecer a tela de instalação na primeira vez)
  - Isso é feito via script no primeiro boot do container
- **Username do admin:** Não pode conter "admin" ou "Admin" (ex: admin, administrator, Admin-login, admin-123 são proibidos; dramos-j, manager, boss, etc. são permitidos)
- **Na avaliação:**
  - Testam adicionar comentário com conta comum
  - Testam editar página com conta admin
  - Verificam persistência dos dados após reboot da VM

## 15. Teste de Persistência (Crítico na Avaliação)

- O avaliador vai **rebootar a VM** para testar se os dados persistem.
- Após reiniciar:
  - `docker compose up` deve funcionar normalmente
  - O site deve voltar com todas as alterações feitas antes do reboot
  - O banco de dados deve manter todos os dados
- **Se os volumes não estiverem em `/home/login/data/` usando bind mounts, os dados serão perdidos e você será reprovado!**

## Resumão Final para Defesa

- Docker = kernel compartilhado; VM = kernel próprio.
- Imagem = receita; container = execução.
- Compose = orquestra tudo.
- Serviços se comunicam via nome do serviço.
- Volumes persistem dados em `/home/login/data/` com **bind mounts**.
- ENTRYPOINT não pode ter loops, tail ou processos em background.
- NGINX só porta 443 com TLS v1.2/v1.3.
- WordPress com PHP-FPM (pré-configurado, sem tela de instalação).
- MariaDB + volume + init automático.
- Estrutura e Makefile obrigatórios.
