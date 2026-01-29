# FINAL GUIDE - INCEPTION - EVALUATION

## SUBJECT COMPLIANCE

**Virtual Machine** - Debian 12 (Bookworm)
**Docker Compose** - Orchestrates all services
**Custom Dockerfiles** - One per service (Nginx, WordPress, MariaDB)
**Base images** - Debian Bookworm (second latest stable)
**Makefile** - At root, calls docker-compose.yml
**Directory structure** - As specified in the subject
**srcs/** folder - Contains docker-compose.yml, .env, and requirements/
**secrets/** folder - Contains passwords (git-ignored)

### **Services (dedicated containers):**

**NGINX** - TLSv1.2/1.3 only, port 443, single entry point
**WordPress** - PHP-FPM (no nginx)
**MariaDB** - Database (no nginx)

### **Persistent volumes:**

**mariadb** → `/home/dramos-j/data/mariadb`
**wordpress** → `/home/dramos-j/data/wordpress`

### **Network:**

**docker-network** - Bridge network connecting the containers
**Does not use** `network: host`, `--link`, or `links:`

### **Domain Name:**

**dramos-j.42.fr** - Configured in Nginx
**Points to localhost** (127.0.0.1 in the VM's /etc/hosts)

### **WordPress Users:**

**Admin** - Username: `dramos-j` (does not contain 'admin')
**Regular user** - Username: `common_user`

### **Security:**

**Passwords** - Not in Dockerfiles, use Docker secrets
**Environment variables** - .env file for configuration
**Secrets ignored** - Not in git

### **Containers:**

**Automatic restart** - restart: always
**No infinite loops** - Does not use tail -f, sleep infinity, etc
**Correct PID 1** - Proper daemon processes
**No latest tag** - Specific versions only

## HOW TO ACCESS WORDPRESS

### **INSIDE THE VM (for development):**

```bash
# Install Firefox if not present
sudo apt install -y firefox-esr

# Access the site
firefox https://dramos-j.42.fr &
```

### **OUTSIDE THE VM (for evaluation):**

**On the evaluator's computer:**

#### Linux/Mac

```bash
echo "10.12.248.36  dramos-j.42.fr" | sudo tee -a /etc/hosts
```

#### Windows (as Administrator)

```cmd
echo 10.12.248.36  dramos-j.42.fr >> C:\Windows\System32\drivers\etc\hosts
```

**Then access:**

```console
https://dramos-j.42.fr
```

### **Via SSH with X11 Forwarding:**

```bash
# On the evaluator's computer
ssh -X dramos-j@10.12.248.36

# Inside the VM
firefox https://dramos-j.42.fr &
```

When accessing, you will see a security warning. This is **NORMAL** because the certificate is self-signed.

**How to proceed:**

1. Click **"Advanced"**
2. Click **"Continue to dramos-j.42.fr (unsafe)"** or **"Accept the risk"**

## EVALUATION CHECKLIST

### **1. Directory Structure:**

```bash
cd /home/dramos-j/Documents/Inception/shared/inception
ls -la
# Should have: Makefile, secrets/, srcs/
```

### **2. Check Makefile:**

```bash
cat Makefile
# Should have targets: all, build, up, down, clean, fclean, re
```

### **3. Check docker-compose.yml:**

```bash
cat srcs/docker-compose.yml
# Should have: version, services (nginx, wordpress, mariadb), volumes, networks
```

### **4. Check that no prebuilt images are used:**

```bash
# Check Dockerfiles
grep -i "FROM" srcs/requirements/*/Dockerfile
# Should show only: debian:bookworm or alpine

# Check that no prebuilt images are used
grep -i "image:" srcs/docker-compose.yml
# Should not have wordpress:, nginx:, mariadb:
```

### **5. Check persistent volumes:**

```bash
ls -la /home/dramos-j/data/
# Should have: mariadb/ and wordpress/
```

### **6. Check running containers:**

```bash
cd srcs
docker compose ps
```

#### Should show

- nginx - Up - 0.0.0.0:443->443/tcp
- wordpress - Up - 9000/tcp
- mariadb - Up - 3306/tcp

### **7. Check that network: host is not used:**

```bash
grep -i "network_mode.*host" srcs/docker-compose.yml
# Should return nothing
```

### **8. Check that no infinite loops are used:**

```bash
grep -E "tail -f|sleep infinity|while true" srcs/requirements/*/Dockerfile
grep -E "tail -f|sleep infinity|while true" srcs/requirements/*/tools/*
# Should return nothing
```

### **9. Check that passwords are not in Dockerfiles:**

```bash
grep -i "password" srcs/requirements/*/Dockerfile
# Should not show plain text passwords
```

### **10. Check admin user:**

```bash
docker exec wordpress wp user list --allow-root
# Admin should not contain: admin, Admin, administrator, Administrator
```

### **11. Test access:**

```bash
# Add to evaluator's /etc/hosts:
# 10.12.248.36  dramos-j.42.fr

# Access in the browser:
https://dramos-j.42.fr

# Or test with curl:
curl -k https://dramos-j.42.fr
```

### **12. Test persistence:**

```bash
cd srcs
docker compose down
docker compose up -d
# Wait ~30 seconds
# Access again - data should be preserved
```

### **13. Check automatic restart:**

```bash
# Force crash of nginx
docker exec nginx pkill nginx

# Wait a few seconds
docker compose ps
# Nginx should be UP again
```

## WORDPRESS CREDENTIALS

**Admin:**

- URL: `https://dramos-j.42.fr/wp-admin`
- Username: `dramos-j`
- Password: (run `cat secrets/admin_pass_wp.txt`)

**Regular User:**

- Username: `common_user`
- Password: (run `cat secrets/user_pass_wp.txt`)

## USEFUL COMMANDS

**Start project:**

```bash
make
# or
cd srcs && docker compose up -d --build
```

**View logs:**

```bash
docker compose logs -f mariadb
docker compose logs -f wordpress
docker compose logs -f nginx
```

**Stop containers:**

```bash
make down
# or
docker compose down
```

**Clean everything:**

```bash
make fclean
# Removes containers, volumes, images
```

**Complete rebuild:**

```bash
make re
# Down + clean + build + up
```

## EXPECTED DIRECTORY STRUCTURE

```console
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

## IMPORTANT POINTS FOR EVALUATION

### **What WILL BE CHECKED:**

1. Makefile works (`make`, `make down`, `make clean`, etc)
2. Custom Dockerfiles (no prebuilt images)
3. Correct docker-compose.yml (services, volumes, networks)
4. NGINX as the single entry point (port 443)
5. TLSv1.2 or TLSv1.3 configured
6. Persistent volumes in `/home/dramos-j/data/`
7. Domain name `dramos-j.42.fr` works
8. WordPress with 2 users (admin without 'admin' in the name)
9. Passwords not in Dockerfiles
10. Containers restart automatically
11. No infinite loops (tail -f, sleep infinity, etc)
12. Secrets not in git

### **What MUST NOT BE PRESENT:**

- Prebuilt DockerHub images (wordpress:, nginx:, mariadb:)
- `network: host` or `--link`
- `latest` tag
- Plain text passwords in Dockerfiles
- Infinite loops (tail -f, bash, sleep infinity, while true)
- Admin with a name containing 'admin', 'Admin', 'administrator'
- Secrets committed to git

## DURING THE EVALUATION

### If the evaluator says "I can't access"

1. Check if they have added to their `/etc/hosts` file:

   ```bash
   10.12.248.36  dramos-j.42.fr
   ```

2. Check if the containers are UP:

   ```bash
   docker compose ps
   ```

3. Show that it works via curl:

   ```bash
   curl -k https://dramos-j.42.fr
   ```

4. Offer SSH with X11 forwarding:

   ```bash
   ssh -X dramos-j@10.12.248.36
   firefox https://dramos-j.42.fr &
   ```

### If the evaluator asks to rebuild

```bash
make fclean
make
# Wait ~30 seconds
# Test access
```

### If the evaluator asks for logs

```bash
docker compose logs mariadb
docker compose logs wordpress
docker compose logs nginx
```

## HOW TO CHANGE THE PORT FOR EVALUATION

If the evaluator requests that WordPress/Nginx run on a port other than 443, follow the steps below:

> **Attention:** When using a port different from 443, always include the port in the URL when accessing via browser, curl, or any other method. Example: `https://dramos-j.42.fr:8443`

### 1. Choose the new port

Example: `8443`

### 2. Edit the `docker-compose.yml` file

In the `srcs/docker-compose.yml` file, locate the `nginx` service and change the port mapping:

```console
services:
   nginx:
      # ...
      ports:
         - "8443:443"  # Change here: <new_port>:443
```

### 3. (Optional) Edit Nginx configuration

If Nginx is configured to listen only on port 443, edit the file `srcs/requirements/nginx/conf/nginx.conf` or `dramos-j.42.fr.conf` to ensure the `listen` directive includes port 443 (you do not need to change to 8443, as the mapping already does the translation). Normally, no changes are needed here.

### 4. Restart the containers

Run:

```bash
cd srcs
docker compose down
docker compose up -d --build
```

### 5. Access via browser

In your browser, access (including the port):

```console
https://dramos-j.42.fr:8443
```

Do not forget to include the port in the URL!
If prompted, accept the SSL certificate warning.

### 6. (Optional) Test with curl

```bash
curl -k https://dramos-j.42.fr:8443
```

- Always include the port in the command above!

All mandatory requirements have been implemented:

- Virtual Machine with Docker
- Docker Compose orchestrating services
- 3 containers (NGINX, WordPress, MariaDB)
- Custom Dockerfiles
- Persistent volumes
- Docker network
- Configured domain name
- HTTPS with TLS
- Passwords protected
- Correct directory structure
