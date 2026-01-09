# DEV_DOC.md

## Environment Setup

### Prerequisites

- **Virtual Machine** (required by subject)
- Debian 12 or compatible Linux
- Docker & Docker Compose
- Make
- sudo access

### Installation

```bash
# Clone repository
git clone <repo-url>
cd Inception

# Configure environment
cp srcs/.env.example srcs/.env
vim srcs/.env  # Edit with your values

# Create secrets
mkdir -p secrets
openssl rand -base64 32 > secrets/pass_mariadb.txt
openssl rand -base64 32 > secrets/admin_pass_wp.txt
openssl rand -base64 32 > secrets/user_pass_wp.txt
chmod 600 secrets/*.txt

# Configure domain
echo "127.0.0.1 dramos-j.42.fr" | sudo tee -a /etc/hosts
```

### Environment Variables

Edit `srcs/.env`:

```bash
DOMAIN_NAME=dramos-j.42.fr
MYSQL_USER=dramos-j
MYSQL_DATABASE=inception
DB_HOST=mariadb
DB_NAME=inception
DB_USER=dramos-j
WP_URL=https://dramos-j.42.fr
WP_ADMIN_NAME=dramos-j-manager
WP_USER_NAME=dramos-j
WP_USER_ROLE=author
```



## Project Architecture

### Directory Structure

```
.
├── Makefile
├── secrets/
│   ├── admin_pass_wp.txt
│   ├── user_pass_wp.txt
│   └── pass_mariadb.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/wp_exec.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            └── tools/mariadb_init.sh
```

### Services

**NGINX:**
- Base: `debian:bookworm-slim`
- TLSv1.2 only, self-signed cert
- Proxy to wordpress:9000 (FastCGI)
- Exposes port 443

**WordPress:**
- Base: `debian:bookworm-slim`
- WordPress 6.7.1 + PHP 8.2-FPM
- WP-CLI for automation
- Uses `rsync` for smart file copy
- Uses `gosu` for privilege management

**MariaDB:**
- Base: `debian:bookworm-slim`
- Conditional initialization
- Temporary server for setup
- Uses `gosu mysql mysqld`

### Key Design Choices

- **Base Image**: `debian:bookworm-slim` (subject allows Alpine or Debian)
- **Restart Policy**: `on-failure` (not `always`)
- **Secrets**: Files in `/run/secrets/` (not env vars)
- **Network**: Custom bridge `inception`
- **Volumes**: Bind mounts to `/home/dramos-j/data/`
- **PID 1**: `exec "$@"` in entrypoint scripts



## Building and Launching

### Using Makefile

```bash
make        # Build and start (default)
make build  # Build images
make up     # Start containers
make down   # Stop containers
make clean  # Stop and prune
make fclean # Remove data too
make re     # Rebuild everything
```

### Using Docker Compose

```bash
cd srcs

# Build
docker compose build
docker compose build --no-cache nginx

# Start
docker compose up -d

# Logs
docker compose logs -f

# Stop
docker compose down
```



## Container Management

### Commands

```bash
# List containers
docker ps

# Exec into container
docker exec -it nginx /bin/bash
docker exec -it wordpress /bin/bash
docker exec -it mariadb /bin/bash

# View logs
docker logs nginx
docker logs -f wordpress --tail 100

# Restart service
docker restart mariadb
docker compose restart wordpress

# Remove containers
docker compose down
docker rm -f nginx
```

### Debugging

```bash
# Check process
docker exec nginx ps aux | grep nginx
docker exec wordpress ps aux | grep php-fpm

# Check ports
docker exec nginx netstat -tlnp

# Check environment
docker exec wordpress env

# Inspect container
docker inspect mariadb
docker inspect wordpress | grep -A 10 Mounts
```



## Volumes and Data Persistence

### Data Locations

| Service | Container Path | Host Path |
|---------|---------------|-----------|
| MariaDB | `/var/lib/mysql` | `/home/dramos-j/data/mariadb` |
| WordPress | `/var/www/html` | `/home/dramos-j/data/wordpress` |

### Managing Data

```bash
# Inspect data
ls -lh /home/dramos-j/data/wordpress/
ls -lh /home/dramos-j/data/mariadb/

# Backup
sudo tar -czf backup-$(date +%Y%m%d).tar.gz /home/dramos-j/data/

# Database dump
docker exec mariadb mysqldump -u dramos-j -p$(cat secrets/pass_mariadb.txt) \
  inception > backup.sql

# Restore
make down
sudo tar -xzf backup-YYYYMMDD.tar.gz -C /
make up
```

### Volume Configuration

In `docker-compose.yml`:

```yaml
volumes:
  wordpress:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/dramos-j/data/wordpress
```

Bind mounts used (not Docker volumes) for:
- Easy access from host
- Standard backup tools
- Explicit data location
- Subject requirement



## Network Configuration

### Network Details

```bash
# Inspect network
docker network inspect inception

# Test connectivity
docker exec wordpress ping mariadb
docker exec nginx ping wordpress

# DNS resolution
docker exec wordpress getent hosts mariadb
```

### Configuration

```yaml
networks:
  inception:
    driver: bridge
```

Containers communicate via service names:
- `nginx` → `wordpress:9000`
- `wordpress` → `mariadb:3306`

Only NGINX port 443 exposed to host.



## Development Workflow

### Making Changes

**1. Modify configuration:**
```bash
vim srcs/requirements/nginx/conf/nginx.conf
```

**2. Rebuild:**
```bash
docker compose build nginx
docker compose up -d nginx
```

**3. Verify:**
```bash
docker logs nginx
```

### Testing

```bash
# Test NGINX config
docker run --rm inception-nginx nginx -t

# Test WordPress
docker exec wordpress wp --info

# Test database
docker exec mariadb mysql -u dramos-j -p$(cat secrets/pass_mariadb.txt) \
  -e "SELECT VERSION();"
```



## Implementation Details

### WordPress Initialization (wp_exec.sh)

1. Read secrets from `/run/secrets/`
2. Check if WordPress files exist (`version.php`)
3. If not: `rsync` from `/usr/src/wordpress/`
4. Wait for MariaDB (`mysqladmin ping`, max 10 attempts)
5. Create `wp-config.php` with WP-CLI
6. Shuffle security salts
7. Install WordPress if needed
8. Create second user
9. `exec php-fpm8.2 -F`

### MariaDB Initialization (mariadb_init.sh)

1. Read secret from `/run/secrets/db_pass`
2. Check if `/var/lib/mysql/mysql` exists
3. If not:
   - Run `mariadb-install-db`
   - Start temporary server
   - Create database and user
   - Grant privileges
   - Shutdown temporary server
4. `exec gosu mysql mysqld`

### NGINX TLS

```bash
# Certificate generated at build
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/nginx-selfsigned.key \
  -out /etc/ssl/nginx-selfsigned.pem \
  -subj "/C=PT/ST=Porto/L=Porto/O=42/CN=dramos-j.42.fr"
```

Config uses `ssl_protocols TLSv1.2;` only.



## Troubleshooting

### Build Issues

```bash
# Clear cache
docker builder prune -a

# Rebuild from scratch
make fclean
docker system prune -a
make
```

### Container Won't Start

```bash
# Check logs
docker logs mariadb

# Check entrypoint
docker inspect mariadb | grep Entrypoint

# Run manually
docker run -it --entrypoint /bin/bash inception-mariadb
```

### Permission Errors

```bash
# Fix WordPress
sudo chown -R www-data:www-data /home/dramos-j/data/wordpress/

# Fix MariaDB
sudo chown -R 999:999 /home/dramos-j/data/mariadb/
```



## Subject Compliance

**Required:**
- ✅ Virtual machine
- ✅ Docker Compose
- ✅ Custom Dockerfiles (one per service)
- ✅ Debian penultimate stable (bookworm-slim)
- ✅ NGINX TLSv1.2 only, port 443
- ✅ WordPress + php-fpm (no nginx)
- ✅ MariaDB (no nginx)
- ✅ Two volumes (WordPress files + database)
- ✅ Docker network
- ✅ Restart on crash (`on-failure`)
- ✅ No infinite loops
- ✅ No `network: host`, `--link`, `links:`
- ✅ No `latest` tags
- ✅ No passwords in Dockerfiles
- ✅ Environment variables + secrets
- ✅ Two WordPress users (admin not named "admin")
- ✅ Volumes in `/home/login/data/`
- ✅ Domain: `login.42.fr`

**Prohibited:**
- ❌ No `tail -f`, `sleep infinity`, `while true`
- ❌ No passwords in Dockerfiles
- ❌ No pulling ready-made images (except base)
- ❌ No `latest` tags



For user instructions, see [USER_DOC.md](USER_DOC.md).
