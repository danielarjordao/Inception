# FINAL SETUP GUIDE - 42 Virtual Machine

## Prerequisites

- VM is already running
- Docker and Docker Compose installed
- Git configured

## STEP-BY-STEP INSTRUCTIONS

### 1. Clone the Repository

```bash
# Enter the VM
cd ~

# Clone repository
git clone <your-repository-url>
cd Inception
```

### 2. Move Structure to Root

```bash
# Move main files
mv shared/inception/Makefile .
mv shared/inception/secrets .
mv shared/inception/srcs .
mv shared/inception/.gitignore .

# Move documentation
mv shared/inception/README.md .
mv shared/inception/USER_DOC.md .
mv shared/inception/DEV_DOC.md .

# Check structure
ls -la
# Should show: Makefile, secrets/, srcs/, README.md, USER_DOC.md, DEV_DOC.md
```

### 3. Check Configuration

**Domain Name should already be set in /etc/hosts:**

```bash
cat /etc/hosts | grep dramos-j
# Should show: 127.0.0.1 dramos-j.42.fr
```

**Makefile already uses correct paths:**

- `/home/dramos-j/data/wordpress`
- `/home/dramos-j/data/mariadb`

### 4. Check Environment Variables

```bash
cat srcs/.env | grep -E "DOMAIN_NAME|MYSQL_USER|WP_ADMIN_NAME"
```

**Should show:**

```bash
DOMAIN_NAME=dramos-j.42.fr
MYSQL_USER=dramos-j
WP_ADMIN_NAME=dramos-j-manager
WP_USER_NAME=dramos-j
```

Everything should already be correctly configured.

### 5. Create/Check Secrets

```bash
# Check if secrets exist
ls -la secrets/

# If NOT, create them:
openssl rand -base64 32 > secrets/pass_mariadb.txt
openssl rand -base64 32 > secrets/admin_pass_wp.txt
openssl rand -base64 32 > secrets/user_pass_wp.txt

# Protect secrets
chmod 600 secrets/*.txt

# Check contents (to note passwords)
cat secrets/admin_pass_wp.txt
cat secrets/user_pass_wp.txt
cat secrets/pass_mariadb.txt
```

### 6. Check .gitignore

```bash
cat .gitignore
```

Should contain:

```bash
.env
srcs/.env
secrets/*.txt
secrets/
data/
```

### 7. Build and Start

```bash
# Build images (first time or after changes)
make build

# Check if built correctly
docker images | grep -E "nginx|wordpress|mariadb"
```

Should show 3 images without the `latest` tag.

```bash
# Start containers
make up

# Follow logs
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb
```

### 8. Check Operation

**Check running containers:**

```bash
docker ps
```

Should show 3 containers: nginx, wordpress, mariadb (all `Up`)

**Check network:**

```bash
docker network inspect inception
```

**Check volumes:**

```bash
ls -lh /home/dramos-j/data/wordpress/
ls -lh /home/dramos-j/data/mariadb/
```

Both should have files.

**Test connectivity:**

```bash
# From the VM, test NGINX
curl -k https://dramos-j.42.fr

# Should return WordPress HTML
```

**Test in browser (if VM has GUI):**

- Open: `https://dramos-j.42.fr`
- Accept self-signed certificate
- Should show WordPress site

### 9. WordPress Admin Login

```bash
# Remember credentials
echo "Admin: dramos-j-manager"
cat secrets/admin_pass_wp.txt
```

Access:

- URL: `https://dramos-j.42.fr/wp-admin`
- User: `dramos-j-manager`
- Password: (contents of admin_pass_wp.txt)

## Verification Checklist

Before considering it finished:

- [ ] `docker ps` shows 3 running containers
- [ ] `docker images` does not show `latest` tag
- [ ] Site accessible at `https://dramos-j.42.fr`
- [ ] WordPress admin accessible at `/wp-admin`
- [ ] Admin login works
- [ ] Data in `/home/login/data/`
- [ ] `.gitignore` protects secrets
- [ ] `git status` does NOT show secrets
- [ ] Documentation (README, USER_DOC, DEV_DOC) in root

## Important Tests

### Test 1: Restart Containers

```bash
# Stop everything
make down

# Start again
make up

# Check that site still works
curl -k https://dramos-j.42.fr
```

Data should persist (no loss of posts, users, etc.)

### Test 2: Individual Restart

```bash
docker restart nginx
docker restart wordpress
docker restart mariadb
```

All should restart without error.

### Test 3: Logs Without Errors

```bash
docker logs nginx 2>&1 | grep -i error
docker logs wordpress 2>&1 | grep -i error
docker logs mariadb 2>&1 | grep -i error
```

Should not show critical errors.

### Test 4: Database

```bash
docker exec mariadb mysql -u dramos-j -p$(cat secrets/pass_mariadb.txt) -e "SHOW DATABASES;"
```

Should list the `inception` database.

### Test 5: Container Connectivity

```bash
docker exec wordpress ping -c 3 mariadb
docker exec nginx ping -c 3 wordpress
```

Both should ping successfully.

### Test 6: No Latest Tag

```bash
docker images | grep -E "nginx|wordpress|mariadb"
```

No image should have the `:latest` tag.

### Test 7: Secrets NOT in Git

```bash
git status
```

**Should NOT show:**

- `secrets/*.txt`
- `srcs/.env`
- Files in `data/`

If shown, check `.gitignore`.

### Test 8: Images Were Built (Not Pulled)

```bash
docker images | grep -E "nginx|wordpress|mariadb"
```

Should show only images with local names (no remote registry).

### Test 9: TLS Verification

```bash
curl -vk https://dramos-j.42.fr 2>&1 | grep -E "TLS|SSL"
```

Should show TLSv1.2 in use.

### Test 10: WordPress Users

Access `/wp-admin` → Users:

- Should have 2 users
- Admin: `dramos-j-manager` (no "admin" in the name)
- Author: `dramos-j`

### Test 11: Restart Policy

```bash
docker inspect nginx | grep -A 5 RestartPolicy
docker inspect wordpress | grep -A 5 RestartPolicy
docker inspect mariadb | grep -A 5 RestartPolicy
```

All should show `"Name": "on-failure"`.

### Test 12: Network (NOT Host)

```bash
docker inspect nginx | grep -A 10 Networks
```

Should show network `inception`, NOT `host`.

### Test 13: Only Port 443 Exposed

```bash
docker ps
```

Only NGINX should have `0.0.0.0:443->443/tcp`.
WordPress and MariaDB should NOT have ports mapped to host.

### Test 14: PID 1 in Containers

```bash
docker exec nginx ps aux
docker exec wordpress ps aux
docker exec mariadb ps aux
```

PID 1 should be:

- nginx: `/usr/sbin/nginx`
- wordpress: `php-fpm8.2`
- mariadb: `mysqld`

Should NOT be bash, sh, or scripts.

### Test 15: Crash and Automatic Restart

```bash
# Force nginx crash
docker exec nginx pkill -9 nginx

# Wait a few seconds
sleep 5

# Check if restarted
docker ps | grep nginx
```

Container should be `Up` again (less uptime than the others).

## ✅ FINAL CHECKLIST BEFORE DELIVERY

### Mandatory Subject Requirements

- [ ] **Virtual Machine**: Running in VM ✓
- [ ] **Structure**: Makefile, secrets/, srcs/ at root ✓
- [ ] **Docker Compose**: Used for orchestration ✓
- [ ] **3 Containers**: nginx, wordpress, mariadb ✓
- [ ] **Base Images**: debian:bookworm-slim (not latest) ✓
- [ ] **Custom Dockerfiles**: One per service ✓
- [ ] **Own Build**: No pulling ready images ✓
- [ ] **NGINX TLS**: Only TLSv1.2, port 443 ✓
- [ ] **WordPress**: PHP-FPM without nginx ✓
- [ ] **MariaDB**: Without nginx ✓
- [ ] **2 Volumes**: wordpress files + database ✓
- [ ] **Volumes Path**: /home/dramos-j/data/ ✓
- [ ] **Docker Network**: bridge network inception ✓
- [ ] **Restart Policy**: on-failure ✓
- [ ] **No Infinite Loops**: No tail -f, sleep infinity ✓
- [ ] **Correct PID 1**: Daemons as PID 1 ✓
- [ ] **2 WordPress Users**: Admin + regular ✓
- [ ] **Admin Name**: dramos-j-manager (no "admin") ✓
- [ ] **Domain**: dramos-j.42.fr ✓
- [ ] **No Passwords in Dockerfiles**: Use secrets ✓
- [ ] **.env File**: Present and configured ✓
- [ ] **Docker Secrets**: Configured and working ✓
- [ ] **Secrets in Git**: NO (ignored) ✓
- [ ] **NGINX Single Entry Point**: Only port 443 exposed ✓
- [ ] **No network: host**: Using bridge ✓
- [ ] **No --link**: Not used ✓

### Documentation

- [ ] **README.md at root**: ✓
- [ ] **First line italicized**: With login ✓
- [ ] **Description section**: ✓
- [ ] **Instructions section**: ✓
- [ ] **Resources section**: ✓
- [ ] **AI Usage described**: ✓
- [ ] **Comparisons**: VMs vs Docker, etc. ✓
- [ ] **USER_DOC.md at root**: ✓
- [ ] **DEV_DOC.md at root**: ✓

### Functionality

- [ ] **Site accessible**: <https://dramos-j.42.fr> ✓
- [ ] **Admin accessible**: /wp-admin ✓
- [ ] **Login works**: With correct credentials ✓
- [ ] **Data persists**: After restart ✓
- [ ] **Containers restart**: After crash ✓
- [ ] **Logs without critical errors**: ✓
- [ ] **3 containers running**: docker ps ✓

## FINAL VALIDATION

Run these commands and confirm EVERYTHING is OK:

```bash
# 1. Containers running
docker ps | wc -l
# Should return 4 (header + 3 containers)

# 2. No latest
docker images | grep latest | wc -l
# Should return 0

# 3. Site works
curl -k https://dramos-j.42.fr | grep -i wordpress
# Should return something with "wordpress"

# 4. Secrets protected
git status | grep secrets
# Should NOT return anything

# 5. Only port 443
docker ps | grep -E "wordpress|mariadb" | grep -E "0.0.0.0|:::"
# Should NOT return anything (only nginx has exposed port)

# 6. Correct network
docker network ls | grep inception
# Should show network inception

# 7. Correct volumes
ls /home/dramos-j/data/ | grep -E "wordpress|mariadb" | wc -l
# Should return 2
```

### Problem: "Can't access website"

```bash
# Check /etc/hosts
cat /etc/hosts | grep dramos-j

# Check nginx
docker logs nginx

# Check port
sudo netstat -tulpn | grep 443
```

### Problem: "Database connection error"

```bash
# Check mariadb
docker logs mariadb

# Check if ready
docker exec mariadb mysqladmin ping -u dramos-j -p$(cat secrets/pass_mariadb.txt)

# Wait 30s and try again
sleep 30
docker restart wordpress
```

### Problem: Container does not start

```bash
# Check logs
docker logs <container_name>

# Rebuild
make down
docker system prune -f
make build
make up
```

---

## Useful Commands During Development

```bash
# See all containers (including stopped)
docker ps -a

# See logs of all services
docker compose -f srcs/docker-compose.yml logs

# Enter container
docker exec -it nginx /bin/bash
docker exec -it wordpress /bin/bash
docker exec -it mariadb /bin/bash

# Check resource usage
docker stats

# Clean everything and restart
make fclean
make
```

## Before Committing (if making changes)

```bash
# Check status
git status

# Should NOT show:
# - secrets/*.txt
# - srcs/.env
# - data/

# If shown, add to .gitignore

# Add changes
git add Makefile srcs/ README.md USER_DOC.md DEV_DOC.md

# Commit
git commit -m "Move project to root structure"

# Push
git push
```
