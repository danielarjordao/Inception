# Inception Study Plan – 4 Days

## Day 1 — Fundamentals + Complete Environment Preparation

**Goal:** Prepare the environment, understand essential concepts, and set up the base project structure.

### Completed

- Installation of Debian 12.12 VM in VirtualBox (manual installation done correctly).
- Sudo user configured.
- Docker + Docker Compose installed and validated.
- Guest Additions installed correctly via Debian repository.
- Shared folder configured with read/write permissions.
- Snapshot created.
- Base project structure created:

```console
inception/
 ├── Makefile
 ├── secrets/
 └── srcs/
      ├── .env
      ├── docker-compose.yml
      └── requirements/
            ├── nginx/
            ├── mariadb/
            └── wordpress/
```

- Functional Makefile (`up`, `down`, `re`).
- Minimal `docker-compose.yml` working (expected error: empty Dockerfile).

## Day 2 — MariaDB (Database + Persistence)

**Goal:** Have the database functional, initializing automatically with users and database.

**Morning:**

**Study:**

- How MariaDB/MySQL works in containers.
- What an entrypoint is.
- What environment variables are in Compose.
- Data persistence via volumes.

**Practice:**

- Create `requirements/mariadb/Dockerfile`.
- Create basic `conf/my.cnf`.
- Create script `tools/mdb_init.sh` to:
  - create database
  - set root password
  - create regular user
  - apply permissions

**Afternoon:**

- Add MariaDB to `docker-compose.yml` with `env_file`.
- Create variables in `.env`:
  - DB_HOST
  - DB_NAME
  - DB_USER
  - DB_PASSWORD
  - DB_ROOT_PASSWORD
- Test the database:

```bash
docker exec -it mariadb mysql -u <user> -p
```

- Confirm persistence after `make re`.

## Day 3 — WordPress (PHP-FPM + WP-CLI + Automatic Configuration)

**Goal:** WordPress functional without a web server, ready to be served by NGINX.

**Morning:**

**Study:**

- How PHP-FPM works.
- What a PHP socket is.
- What WP-CLI is and how to use it.

**Practice:**

- Create `requirements/wordpress/Dockerfile`.
- Install:
  - PHP-FPM
  - required extensions
  - WP-CLI
- Create `tools/wp_setup.sh` to:
  - download WordPress
  - generate wp-config.php
  - create admin
  - create secondary user
  - set URL and title

**Afternoon:**

- Connect WordPress to MariaDB via `.env`.
- Test PHP-FPM:

```bash
docker exec -it wordpress wp --info
```

- Check:
  - `/var/www/html` with WP files.
  - that the entrypoint configures everything automatically.

## Day 4 — NGINX + TLS (HTTPS)

**Goal:** Serve WordPress over HTTPS on port 443 (only entry point).

**Morning:**

**Study:**

- Reverse proxy
- Port 443
- TLS certificates (self-signed)

**Practice:**

- Create certificates:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx.key -out nginx.crt
```

- Create `requirements/nginx/Dockerfile`.
- Create `conf/server.conf` with:
  - SSL
  - proxy to PHP-FPM
  - root pointing to `/var/www/html`

**Afternoon:**

- Insert domain in `/etc/hosts`:

```bash
127.0.0.1 login.42.fr
```

- Adjust shared volumes.
- Test in browser:
  - <https://login.42.fr>
