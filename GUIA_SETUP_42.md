# 🚀 GUIA - Setup Final na Máquina Virtual da 42

## ✅ Pré-requisitos
- VM já está pronta e rodando
- Docker e Docker Compose instalados
- Git configurado

---

## 📋 PASSO A PASSO

### 1️⃣ Clonar o Repositório

```bash
# Entrar na VM
cd ~

# Clonar repositório
git clone <url-do-seu-repositorio>
cd Inception
```

### 2️⃣ Mover Estrutura para Raiz

```bash
# Mover arquivos principais
mv shared/inception/Makefile .
mv shared/inception/secrets .
mv shared/inception/srcs .
mv shared/inception/.gitignore .

# Mover documentação
mv shared/inception/README.md .
mv shared/inception/USER_DOC.md .
mv shared/inception/DEV_DOC.md .

# Verificar estrutura
ls -la
# Deve mostrar: Makefile, secrets/, srcs/, README.md, USER_DOC.md, DEV_DOC.md
```

### 3️⃣ Verificar Configuração

**Domain Name já deve estar configurado no /etc/hosts:**
```bash
cat /etc/hosts | grep dramos-j
# Deve mostrar: 127.0.0.1 dramos-j.42.fr
```

**Makefile já usa paths corretos:**
- `/home/dramos-j/data/wordpress`
- `/home/dramos-j/data/mariadb`

### 4️⃣ Verificar Environment Variables

```bash
cat srcs/.env | grep -E "DOMAIN_NAME|MYSQL_USER|WP_ADMIN_NAME"
```

**Deve mostrar:**
```bash
DOMAIN_NAME=dramos-j.42.fr
MYSQL_USER=dramos-j
WP_ADMIN_NAME=dramos-j-manager
WP_USER_NAME=dramos-j
```

Tudo já está configurado corretamente. ✅

### 5️⃣ Criar/Verificar Secrets

```bash
# Verificar se secrets existem
ls -la secrets/

# Se NÃO existirem, criar:
openssl rand -base64 32 > secrets/pass_mariadb.txt
openssl rand -base64 32 > secrets/admin_pass_wp.txt
openssl rand -base64 32 > secrets/user_pass_wp.txt

# Proteger secrets
chmod 600 secrets/*.txt

# Verificar conteúdo (para anotar senhas)
cat secrets/admin_pass_wp.txt
cat secrets/user_pass_wp.txt
cat secrets/pass_mariadb.txt
```

**⚠️ ANOTAR SENHAS EM ALGUM LUGAR SEGURO!**

### 6️⃣ Verificar GitIgnore

```bash
cat .gitignore
```

Deve conter:
```
.env
srcs/.env
secrets/*.txt
secrets/
data/
```

### 7️⃣ Build e Start

```bash
# Build imagens (primeira vez ou após mudanças)
make build

# Verificar se buildou corretamente
docker images | grep -E "nginx|wordpress|mariadb"
```

Deve mostrar 3 imagens sem tag `latest`.

```bash
# Iniciar containers
make up

# Acompanhar logs
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb
```

### 8️⃣ Verificar Funcionamento

**Verificar containers rodando:**
```bash
docker ps
```

Deve mostrar 3 containers: nginx, wordpress, mariadb (todos `Up`)

**Verificar network:**
```bash
docker network inspect inception
```

**Verificar volumes:**
```bash
ls -lh /home/dramos-j/data/wordpress/
ls -lh /home/dramos-j/data/mariadb/
```

Ambos devem ter arquivos.

**Testar conectividade:**
```bash
# Da VM, testar NGINX
curl -k https://dramos-j.42.fr

# Deve retornar HTML do WordPress
```

**Testar no navegador (se tiver GUI na VM):**
- Abrir: `https://dramos-j.42.fr`
- Aceitar certificado auto-assinado
- Deve mostrar site WordPress

### 9️⃣ Login WordPress Admin

```bash
# Lembrar credenciais
echo "Admin: dramos-j-manager"
cat secrets/admin_pass_wp.txt
```

Acessar:
- URL: `https://dramos-j.42.fr/wp-admin`
- User: `dramos-j-manager`
- Password: (conteúdo de admin_pass_wp.txt)

---

## ✅ Checklist de Verificação

Antes de considerar finalizado:

- [ ] `docker ps` mostra 3 containers rodando
- [ ] `docker images` não mostra tag `latest`
- [ ] Site acessível em `https://dramos-j.42.fr`
- [ ] WordPress admin acessível em `/wp-admin`
- [ ] Login com admin funciona
- [ ] Dados em `/home/login/data/`
- [ ] `.gitignore` protegendo secrets
- [ ] `git status` NÃO mostra secrets
- [ ] Documentação (README, USER_DOC, DEV_DOC) na raiz

---

## 🧪 Testes Importantes

### Teste 1: Restart de Containers

```bash
# Parar tudo
make down

# Iniciar novamente
make up

# Verificar que site ainda funciona
curl -k https://dramos-j.42.fr
```

Dados devem persistir (não perder posts, usuários, etc.)

### Teste 2: Restart Individual

```bash
docker restart nginx
docker restart wordpress
docker restart mariadb
```

Todos devem reiniciar sem erro.

### Teste 3: Logs sem Erros

```bash
docker logs nginx 2>&1 | grep -i error
docker logs wordpress 2>&1 | grep -i error
docker logs mariadb 2>&1 | grep -i error
```

Não deve mostrar erros críticos.

### Teste 4: Database

```bash
docker exec mariadb mysql -u dramos-j -p$(cat secrets/pass_mariadb.txt) -e "SHOW DATABASES;"
```

Deve listar database `inception`.

### Teste 5: Conectividade Entre Containers

```bash
docker exec wordpress ping -c 3 mariadb
docker exec nginx ping -c 3 wordpress
```

Ambos devem pingar com sucesso.

### Teste 6: Verificar Não Há Tag Latest

```bash
docker images | grep -E "nginx|wordpress|mariadb"
```

Nenhuma imagem deve ter tag `:latest`.

### Teste 7: Verificar Secrets NÃO Estão no Git

```bash
git status
```

**NÃO deve aparecer:**
- `secrets/*.txt`
- `srcs/.env`
- Arquivos em `data/`

Se aparecer, verificar `.gitignore`.

### Teste 8: Verificar Imagens Foram Buildadas (Não Pulled)

```bash
docker images | grep -E "nginx|wordpress|mariadb"
```

Deve mostrar apenas imagens sem registry remoto (só nome local).

### Teste 9: Verificar TLS

```bash
curl -vk https://dramos-j.42.fr 2>&1 | grep -E "TLS|SSL"
```

Deve mostrar TLSv1.2 sendo usado.

### Teste 10: Verificar Usuários WordPress

Acessar `/wp-admin` → Users:
- Deve ter 2 usuários
- Admin: `dramos-j-manager` (sem "admin" no nome) ✅
- Author: `dramos-j`

### Teste 11: Verificar Restart Policy

```bash
docker inspect nginx | grep -A 5 RestartPolicy
docker inspect wordpress | grep -A 5 RestartPolicy
docker inspect mariadb | grep -A 5 RestartPolicy
```

Todos devem mostrar `"Name": "on-failure"`.

### Teste 12: Verificar Network (NÃO Host)

```bash
docker inspect nginx | grep -A 10 Networks
```

Deve mostrar network `inception`, NÃO `host`.

### Teste 13: Verificar Apenas Porta 443 Exposta

```bash
docker ps
```

Apenas NGINX deve ter `0.0.0.0:443->443/tcp`.
WordPress e MariaDB NÃO devem ter portas mapeadas para host.

### Teste 14: Verificar PID 1 nos Containers

```bash
docker exec nginx ps aux
docker exec wordpress ps aux
docker exec mariadb ps aux
```

PID 1 deve ser:
- nginx: `/usr/sbin/nginx`
- wordpress: `php-fpm8.2`
- mariadb: `mysqld`

NÃO deve ser bash, sh, ou scripts.

### Teste 15: Crash e Restart Automático

```bash
# Forçar crash do nginx
docker exec nginx pkill -9 nginx

# Esperar alguns segundos
sleep 5

# Verificar se reiniciou
docker ps | grep nginx
```

Container deve estar `Up` novamente (menos tempo que os outros).

---

## ✅ CHECKLIST FINAL ANTES DE ENTREGAR

### Requisitos Obrigatórios do Subject

- [ ] **Virtual Machine**: Rodando em VM ✓
- [ ] **Estrutura**: Makefile, secrets/, srcs/ na raiz ✓
- [ ] **Docker Compose**: Usado para orquestração ✓
- [ ] **3 Containers**: nginx, wordpress, mariadb ✓
- [ ] **Base Images**: debian:bookworm-slim (não latest) ✓
- [ ] **Dockerfiles Próprios**: Um por serviço ✓
- [ ] **Build Próprio**: Não pull de images prontas ✓
- [ ] **NGINX TLS**: TLSv1.2 apenas, porta 443 ✓
- [ ] **WordPress**: PHP-FPM sem nginx ✓
- [ ] **MariaDB**: Sem nginx ✓
- [ ] **2 Volumes**: wordpress files + database ✓
- [ ] **Volumes Path**: /home/dramos-j/data/ ✓
- [ ] **Docker Network**: bridge network inception ✓
- [ ] **Restart Policy**: on-failure ✓
- [ ] **No Infinite Loops**: Sem tail -f, sleep infinity ✓
- [ ] **PID 1 Correto**: Daemons como PID 1 ✓
- [ ] **2 Users WordPress**: Admin + regular ✓
- [ ] **Admin Name**: dramos-j-manager (sem "admin") ✓
- [ ] **Domain**: dramos-j.42.fr ✓
- [ ] **No Passwords em Dockerfiles**: Secrets usados ✓
- [ ] **.env File**: Presente e configurado ✓
- [ ] **Docker Secrets**: Configurados e funcionando ✓
- [ ] **Secrets no Git**: NÃO (ignorados) ✓
- [ ] **NGINX Único Entry Point**: Só porta 443 exposta ✓
- [ ] **No network: host**: Usando bridge ✓
- [ ] **No --link**: Não usado ✓

### Documentação

- [ ] **README.md na raiz**: ✓
- [ ] **Primeira linha italizada**: Com login ✓
- [ ] **Seção Description**: ✓
- [ ] **Seção Instructions**: ✓
- [ ] **Seção Resources**: ✓
- [ ] **AI Usage descrito**: ✓
- [ ] **Comparações**: VMs vs Docker, etc. ✓
- [ ] **USER_DOC.md na raiz**: ✓
- [ ] **DEV_DOC.md na raiz**: ✓

### Funcionamento

- [ ] **Site acessível**: https://dramos-j.42.fr ✓
- [ ] **Admin acessível**: /wp-admin ✓
- [ ] **Login funciona**: Com credenciais corretas ✓
- [ ] **Dados persistem**: Após restart ✓
- [ ] **Containers reiniciam**: Após crash ✓
- [ ] **Logs sem erros críticos**: ✓
- [ ] **3 containers rodando**: docker ps ✓

---

## 🎯 VALIDAÇÃO FINAL (CRÍTICA!)

Execute estes comandos e confirme TUDO está OK:

```bash
# 1. Containers rodando
docker ps | wc -l
# Deve retornar 4 (header + 3 containers)

# 2. Nenhum latest
docker images | grep latest | wc -l
# Deve retornar 0

# 3. Site funciona
curl -k https://dramos-j.42.fr | grep -i wordpress
# Deve retornar algo com "wordpress"

# 4. Secrets protegidos
git status | grep secrets
# NÃO deve retornar nada

# 5. Apenas porta 443
docker ps | grep -E "wordpress|mariadb" | grep -E "0.0.0.0|:::"
# NÃO deve retornar nada (só nginx tem porta exposta)

# 6. Network correto
docker network ls | grep inception
# Deve mostrar network inception

# 7. Volumes corretos
ls /home/dramos-j/data/ | grep -E "wordpress|mariadb" | wc -l
# Deve retornar 2
```

**Se TODOS os comandos acima passarem: PROJETO PRONTO! ✅**

---

## 🧪 Testes Importantes

### Problema: "Can't access website"

```bash
# Verificar /etc/hosts
cat /etc/hosts | grep dramos-j

# Verificar nginx
docker logs nginx

# Verificar porta
sudo netstat -tulpn | grep 443
```

### Problema: "Database connection error"

```bash
# Verificar mariadb
docker logs mariadb

# Verificar se está pronto
docker exec mariadb mysqladmin ping -u dramos-j -p$(cat secrets/pass_mariadb.txt)

# Esperar 30s e tentar novamente
sleep 30
docker restart wordpress
```

### Problema: Container não inicia

```bash
# Ver logs
docker logs <container_name>

# Rebuild
make down
docker system prune -f
make build
make up
```

---

## 🎯 Comandos Úteis Durante Desenvolvimento

```bash
# Ver todos containers (incluindo parados)
docker ps -a

# Ver logs de todos serviços
docker compose -f srcs/docker-compose.yml logs

# Entrar em container
docker exec -it nginx /bin/bash
docker exec -it wordpress /bin/bash
docker exec -it mariadb /bin/bash

# Ver uso de recursos
docker stats

# Limpar tudo e recomeçar
make fclean
make
```

---

## 📦 Antes de Commitar (se fizer mudanças)

```bash
# Verificar status
git status

# NÃO deve aparecer:
# - secrets/*.txt
# - srcs/.env
# - data/

# Se aparecer, adicionar ao .gitignore

# Adicionar mudanças
git add Makefile srcs/ README.md USER_DOC.md DEV_DOC.md

# Commit
git commit -m "Move project to root structure"

# Push
git push
```

---

## ✅ Projeto Pronto para Avaliação

Quando tudo acima funcionar:

1. ✅ Site acessível
2. ✅ Admin funciona
3. ✅ Containers reiniciam sem problemas
4. ✅ Dados persistem
5. ✅ Logs sem erros
6. ✅ Documentação completa
7. ✅ Secrets não no git

**🎉 PROJETO PRONTO!**

---

## 📝 Notas Finais

- **Tempo estimado**: 15-30 minutos
- **Internet necessária**: Sim (para pull de imagens base Debian)
- **Espaço em disco**: ~2-3GB
- **Fazer backup dos secrets**: Anotar senhas antes de sair

**Boa sorte! 🚀**
