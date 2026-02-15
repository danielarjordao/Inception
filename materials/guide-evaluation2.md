# Inception: Guia para Avaliação

## 1. Checklist Inicial

Garantir que seu Makefile está na raiz.

* **Limpar tudo:** `make fclean` (apaga containers, redes, imagens e **volumes**).
* **Subir o projeto:** `make` ou `make up`.
* **Verificar se está "Up":** `docker ps`


## 2. Teoria: O "Activity Overview"


| Pergunta | Resposta Curta |
| --- | --- |
| **Docker vs VM?** | VMs emulam hardware e levam um OS inteiro (pesado). Docker compartilha o **Kernel do Host**, é isolamento de processo (leve e rápido). |
| **Docker Compose?** | É um **orquestrador**. Serve para gerir múltiplos containers, redes e volumes em um único arquivo YAML. |
| **Volumes vs Bind Mounts?** | Volumes são geridos pelo Docker. **Bind Mounts** (o que usamos) mapeiam uma pasta específica da nossa VM (`/home/dramos-j/data`) para dentro do container. |
| **Por que Debian?** | É estável, seguro e permite instalar exatamente o que precisamos (PHP 8.2, MariaDB) sem o bloatware de imagens prontas. |


## 3. Comandos de Inspeção Técnica

### **NGINX & SSL (A prova do TLS 1.2)**

```bash
# Provar o TLS 1.2 e ver o certificado
openssl s_client -connect localhost:443 -tls1_2

```

* **O que apontar:** Procurar a linha `Protocol : TLSv1.2` e `CN = dramos-j.42.fr`.

### **Volumes (A prova da Persistência)**

```bash
# Ver os arquivos na VM (fora do container)
ls -la /home/dramos-j/data/wordpress
ls -la /home/dramos-j/data/mariadb

```

### **MariaDB**

```bash
# Entrar no banco de dados (Com a senha do secrets/pass_mariadb.txt)
docker exec -it mariadb mysql -u root -p

# Comandos lá dentro:
SHOW DATABASES;
USE inception;
SHOW TABLES;

```

## 4. Mudar a Porta do NGINX (Se pedirem para mudar de 443 para 8443)

Se pedir para mudar a porta do Nginx de 443 para 8443:

1. Abra o `srcs/docker-compose.yml`.
2. Mude em `nginx > ports`: de `"443:443"` para `"8443:443"`.
3. Rode: `docker compose up -d --build nginx`.
4. Acesse: `https://dramos-j.42.fr:8443`.

## 5. Dicas

* **Logs:** Se algo não subir, use o comando `docker logs <nome_do_container>`.
* **HTTPS:** O site **só** abre com `https://`. Se digitar `http://`, vai dar erro
* **Hosts:** Se o site não abrir no browser, verifique se o IP está no `/etc/hosts`: `127.0.0.1 dramos-j.42.fr`.
