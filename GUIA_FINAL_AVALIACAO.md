# 🎯 GUIA FINAL - INCEPTION - AVALIAÇÃO

## ✅ STATUS DO PROJETO: 100% COMPLETO E FUNCIONAL



## 📊 CONFORMIDADE COM O SUBJECT:

✅ **Virtual Machine** - Debian 12 (Bookworm)
✅ **Docker Compose** - Orquestra todos os serviços
✅ **Dockerfiles próprios** - Um por serviço (Nginx, WordPress, MariaDB)
✅ **Imagens base** - Debian Bookworm (penúltima versão estável)
✅ **Makefile** - Na raiz, chama docker-compose.yml
✅ **Estrutura de diretórios** - Conforme especificado no subject
✅ **Pasta srcs/** - Contém docker-compose.yml, .env e requirements/
✅ **Pasta secrets/** - Contém senhas (ignoradas pelo git)

### **Serviços (containers dedicados):**
✅ **NGINX** - TLSv1.2/1.3 only, porta 443, único ponto de entrada
✅ **WordPress** - PHP-FPM (sem nginx)
✅ **MariaDB** - Banco de dados (sem nginx)

### **Volumes persistentes:**
✅ **mariadb** → `/home/dramos-j/data/mariadb`
✅ **wordpress** → `/home/dramos-j/data/wordpress`

### **Rede:**
✅ **docker-network** - Bridge network conectando os containers
✅ **Não usa** `network: host`, `--link`, ou `links:`

### **Domain Name:**
✅ **dramos-j.42.fr** - Configurado no Nginx
✅ **Aponta para localhost** (127.0.0.1 no /etc/hosts da VM)

### **Usuários WordPress:**
✅ **Admin** - Username: `dramos-j` (não contém 'admin')
✅ **Usuário comum** - Username: `common_user`

### **Segurança:**
✅ **Senhas** - Não estão nos Dockerfiles, usam Docker secrets
✅ **Environment variables** - Arquivo .env para configurações
✅ **Secrets ignorados** - Não estão no git

### **Containers:**
✅ **Restart automático** - restart: always
✅ **Sem infinite loops** - Não usa tail -f, sleep infinity, etc
✅ **PID 1 correto** - Processos daemon adequados
✅ **Sem tag latest** - Versões específicas



## 🌐 COMO ACESSAR O WORDPRESS:

### **DENTRO DA VM (para desenvolvimento):**

```bash
# Instalar navegador (se necessário)
sudo apt install -y firefox-esr

# Acessar
firefox https://dramos-j.42.fr &
```

### **DE FORA DA VM (para avaliação):**

**No computador do avaliador:**

#### Linux/Mac:
```bash
echo "10.12.248.36  dramos-j.42.fr" | sudo tee -a /etc/hosts
```

#### Windows (como Administrador):
```cmd
echo 10.12.248.36  dramos-j.42.fr >> C:\Windows\System32\drivers\etc\hosts
```

**Depois acesse:**
```
https://dramos-j.42.fr
```

### **Via SSH com X11 Forwarding:**
```bash
# Do computador do avaliador
ssh -X dramos-j@10.12.248.36

# Dentro da VM
firefox https://dramos-j.42.fr &
```



## 🔐 AVISO DE CERTIFICADO SSL

Ao acessar, você verá um aviso de segurança. Isso é **NORMAL** porque o certificado é auto-assinado.

**Como proceder:**
1. Clique em **"Avançado"**
2. Clique em **"Continuar para dramos-j.42.fr (não seguro)"** ou **"Aceitar o risco"**



## 📋 CHECKLIST PARA AVALIAÇÃO:

### **1. Estrutura de Diretórios:**

```bash
cd /home/dramos-j/Documents/Inception/shared/inception
ls -la
# Deve ter: Makefile, secrets/, srcs/
```

### **2. Verificar Makefile:**

```bash
cat Makefile
# Deve ter targets: all, build, up, down, clean, fclean, re
```

### **3. Verificar docker-compose.yml:**

```bash
cat srcs/docker-compose.yml
# Deve ter: version, services (nginx, wordpress, mariadb), volumes, networks
```

### **4. Verificar que não usa imagens prontas:**

```bash
# Verificar Dockerfiles
grep -i "FROM" srcs/requirements/*/Dockerfile
# Deve mostrar apenas: debian:bookworm ou alpine

# Verificar que não usa imagens prontas
grep -i "image:" srcs/docker-compose.yml
# Não deve ter wordpress:, nginx:, mariadb:
```

### **5. Verificar volumes persistentes:**

```bash
ls -la /home/dramos-j/data/
# Deve ter: mariadb/ e wordpress/
```

### **6. Verificar containers rodando:**

```bash
cd srcs
docker compose ps
```

**Deve mostrar:**
- ✅ nginx - Up - 0.0.0.0:443->443/tcp
- ✅ wordpress - Up - 9000/tcp
- ✅ mariadb - Up - 3306/tcp

### **7. Verificar que não usa network: host:**

```bash
grep -i "network_mode.*host" srcs/docker-compose.yml
# Não deve retornar nada
```

### **8. Verificar que não usa infinite loops:**

```bash
grep -E "tail -f|sleep infinity|while true" srcs/requirements/*/Dockerfile
grep -E "tail -f|sleep infinity|while true" srcs/requirements/*/tools/*
# Não deve retornar nada
```

### **9. Verificar senhas não estão nos Dockerfiles:**

```bash
grep -i "password" srcs/requirements/*/Dockerfile
# Não deve mostrar senhas em texto claro
```

### **10. Verificar usuário admin:**

```bash
docker exec wordpress wp user list --allow-root
# Admin não deve conter: admin, Admin, administrator, Administrator
```

### **11. Testar acesso:**

```bash
# Adicionar no /etc/hosts do avaliador:
# 10.12.248.36  dramos-j.42.fr

# Acessar no navegador:
https://dramos-j.42.fr

# Ou testar com curl:
curl -k https://dramos-j.42.fr
```

### **12. Testar persistência:**

```bash
cd srcs
docker compose down
docker compose up -d
# Esperar ~30 segundos
# Acessar novamente - dados devem estar preservados
```

### **13. Verificar restart automático:**

```bash
# Forçar crash do nginx
docker exec nginx pkill nginx

# Esperar alguns segundos
docker compose ps
# Nginx deve estar UP novamente
```



## 🎓 CREDENCIAIS DO WORDPRESS:

**Admin:**
- URL: `https://dramos-j.42.fr/wp-admin`
- Usuário: `dramos-j`
- Senha: (executar `cat secrets/admin_pass_wp.txt`)

**Usuário Comum:**
- Usuário: `common_user`
- Senha: (executar `cat secrets/user_pass_wp.txt`)



## 🚨 COMANDOS ÚTEIS:

**Iniciar projeto:**
```bash
make
# ou
cd srcs && docker compose up -d --build
```

**Ver logs:**
```bash
docker compose logs -f mariadb
docker compose logs -f wordpress
docker compose logs -f nginx
```

**Parar containers:**
```bash
make down
# ou
docker compose down
```

**Limpar tudo:**
```bash
make fclean
# Remove containers, volumes, imagens
```

**Rebuild completo:**
```bash
make re
# Down + clean + build + up
```



## 📂 ESTRUTURA DE DIRETÓRIOS ESPERADA:

```
.
├── Makefile
├── secrets/
│   ├── pass_mariadb.txt
│   ├── admin_pass_wp.txt
│   └── user_pass_wp.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── mariadb.cnf
        │   └── tools/
        │       └── mariadb_init.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   ├── nginx.conf
        │   │   └── dramos-j.42.fr.conf
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            │   └── www.conf
            └── tools/
                └── wp_exec.sh
```



## 🏆 PONTOS IMPORTANTES PARA AVALIAÇÃO:

### **O que VAI SER VERIFICADO:**

1. ✅ Makefile funciona (`make`, `make down`, `make clean`, etc)
2. ✅ Dockerfiles personalizados (não imagens prontas)
3. ✅ docker-compose.yml correto (services, volumes, networks)
4. ✅ NGINX único ponto de entrada (porta 443)
5. ✅ TLSv1.2 ou TLSv1.3 configurado
6. ✅ Volumes persistentes em `/home/dramos-j/data/`
7. ✅ Domain name `dramos-j.42.fr` funciona
8. ✅ WordPress com 2 usuários (admin sem 'admin' no nome)
9. ✅ Senhas não estão nos Dockerfiles
10. ✅ Containers reiniciam automaticamente
11. ✅ Sem infinite loops (tail -f, sleep infinity, etc)
12. ✅ Secrets não estão no git

### **O que NÃO PODE TER:**

❌ Imagens prontas do DockerHub (wordpress:, nginx:, mariadb:)
❌ `network: host` ou `--link`
❌ Tag `latest`
❌ Senhas em texto claro nos Dockerfiles
❌ Infinite loops (tail -f, bash, sleep infinity, while true)
❌ Admin com nome contendo 'admin', 'Admin', 'administrator'
❌ Secrets commitados no git



## 📞 DURANTE A AVALIAÇÃO:

### **Se o avaliador disser "não consigo acessar":**

1. Verificar se ele adicionou no `/etc/hosts` dele:
   ```
   10.12.248.36  dramos-j.42.fr
   ```

2. Verificar se os containers estão UP:
   ```bash
   docker compose ps
   ```

3. Mostrar que funciona via curl:
   ```bash
   curl -k https://dramos-j.42.fr
   ```

4. Oferecer SSH com X11:
   ```bash
   ssh -X dramos-j@10.12.248.36
   firefox https://dramos-j.42.fr &
   ```

### **Se o avaliador pedir para rebuild:**

```bash
make fclean
make
# Aguardar ~30 segundos
# Testar acesso
```

### **Se o avaliador pedir logs:**

```bash
docker compose logs mariadb
docker compose logs wordpress
docker compose logs nginx
```



## ✅ RESULTADO FINAL:

**SEU PROJETO ESTÁ 100% CONFORME O SUBJECT!**



## 🔄 COMO ALTERAR A PORTA PARA A AVALIAÇÃO

Caso o avaliador solicite que o WordPress/Nginx rode em uma porta diferente da 443, siga o passo a passo abaixo:

> **Atenção:** Quando usar uma porta diferente da 443, **sempre inclua a porta na URL** ao acessar pelo navegador, curl ou qualquer outro método. Exemplo: `https://dramos-j.42.fr:8443`

### 1. Escolha a nova porta
Exemplo: `8443`

### 2. Edite o arquivo `docker-compose.yml`
No arquivo `srcs/docker-compose.yml`, localize o serviço `nginx` e altere o mapeamento de portas:

```
services:
   nginx:
      # ...
      ports:
         - "8443:443"  # Altere aqui: <porta_nova>:443
```

### 3. (Opcional) Edite configurações do Nginx
Se o Nginx estiver configurado para escutar apenas na porta 443, edite o arquivo `srcs/requirements/nginx/conf/nginx.conf` ou `dramos-j.42.fr.conf` para garantir que a diretiva `listen` inclua a porta 443 (não precisa mudar para 8443, pois o mapeamento já faz a tradução). Normalmente **NÃO é necessário alterar nada aqui**.

### 4. Reinicie os containers
Execute:
```bash
cd srcs
docker compose down
docker compose up -d --build
```

### 5. Acesse pelo navegador

No navegador, acesse (incluindo a porta):
```
https://dramos-j.42.fr:8443
```
**Não esqueça de informar a porta na URL!**
Se for solicitado, aceite o aviso de certificado SSL.

### 6. (Opcional) Teste com curl

```bash
curl -k https://dramos-j.42.fr:8443
```
**Sempre inclua a porta no comando acima!**



Todos os requisitos obrigatórios foram implementados:
- ✅ Virtual Machine com Docker
- ✅ Docker Compose orquestrando serviços
- ✅ 3 containers (NGINX, WordPress, MariaDB)
- ✅ Dockerfiles personalizados
- ✅ Volumes persistentes
- ✅ Rede Docker
- ✅ Domain name configurado
- ✅ HTTPS com TLS
- ✅ Senhas protegidas
- ✅ Estrutura de diretórios correta



**BOA SORTE NA AVALIAÇÃO! 🚀**
