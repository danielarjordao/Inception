# INCEPTION - Complete Requirements Checklist

## Chapter III - General Guidelines

### Virtual Machine

- [x] **Project done in VM** - Running in Debian VM

### File Structure

- [ ] **All files in `srcs/` folder** - ATTENTION: Currently in `shared/inception/srcs/`
  - **REQUIRED ACTION**: Move everything from `shared/inception/` to the repository root

### Makefile

- [x] **Makefile at root** - Exists in `shared/inception/Makefile`
  - [ ] **Must be at final root** - When moving structure
- [x] **Build via docker-compose.yml** - Makefile calls docker compose

## Chapter V - Mandatory Part

### Docker Compose

- [x] **Use docker compose** - Present in `srcs/docker-compose.yml`

### Docker Images

- [x] **Image name = service name** - Verified:
  - nginx image: nginx
  - wordpress image: wordpress
  - mariadb image: mariadb

### Dedicated Containers

- [x] **Each service in dedicated container** - 3 separate containers

### Base Images

- [x] **Alpine or Debian penultimate stable version** - Using `debian:bookworm-slim`
- [x] **Do not use latest tag** - Using bookworm-slim (specific)

### Custom Dockerfiles

- [x] **Custom Dockerfile for each service** - Verified:
  - nginx/Dockerfile
  - wordpress/Dockerfile
  - mariadb/Dockerfile
- [x] **Dockerfiles called by docker-compose** - Via build context
- [x] **Own build (no pulling ready images)** - FROM only Debian base

### Required Services

#### NGINX

- [x] **Container with NGINX**
- [x] **TLSv1.2 or TLSv1.3 only** - TLSv1.2 configured
- [x] **Port 443 only** - Port 443 exposed
- [x] **Single entrypoint** - Only NGINX exposes port

#### WordPress

- [x] **Container with WordPress**
- [x] **php-fpm installed and configured** - PHP 8.2-FPM
- [x] **No nginx** - Only PHP-FPM

#### MariaDB

- [x] **Container with MariaDB**
- [x] **No nginx** - Only MariaDB

### Volumes

- [x] **Volume for WordPress database** - mariadb volume
- [x] **Volume for WordPress files** - wordpress volume
- [x] **Volumes in /home/login/data/** - `/home/dramos-j/data/`

### Network

- [x] **Docker network connecting containers** - Network `inception`
- [x] **Network line in docker-compose** - Present
- [x] **DO NOT use network: host** - Using bridge
- [x] **DO NOT use --link or links:** - Not used

### Restart Policy

- [x] **Containers restart on crash** - `restart: on-failure`

### Prohibitions - Infinite Loops

- [x] **DO NOT use tail -f** - Not used
- [x] **DO NOT use bash as command** - Not used
- [x] **DO NOT use sleep infinity** - Not used
- [x] **DO NOT use while true** - Not used
- [x] **Use appropriate daemons** - nginx, php-fpm, mysqld
- [x] **Correct PID 1** - Using exec "$@"

### WordPress Users

- [x] **Two users in WordPress** - dramos-j-manager and dramos-j
- [x] **Admin username WITHOUT admin/Admin/administrator** - dramos-j-manager

### Domain Name

- [x] **Domain = login.42.fr** - dramos-j.42.fr
- [x] **Points to local IP** - 127.0.0.1 in /etc/hosts

### Security - Passwords

- [x] **NO passwords in Dockerfiles** - No hardcoded passwords
- [x] **Use environment variables** - .env file present
- [x] **Use .env file** - `srcs/.env` present
- [x] **Use Docker secrets** - Secrets configured
- [x] **Secrets ignored in git** - .gitignore configured

## Chapter VI - README Requirements

### README.md at Root

- [ ] **README.md at repository root** - Currently in `shared/inception/README.md`
  - **REQUIRED ACTION**: Copy to root when moving structure

### Required Content

#### First Line

- [x] **Italicized** - `*This project has been created...*`
- [x] **Correct text with login** - "by dramos-j"

#### Description Section

- [x] **Presents the project**
- [x] **Clear objective**
- [x] **Brief overview**

#### Instructions Section

- [x] **Build information** - Make commands
- [x] **Installation information** - Setup steps
- [x] **Execution information** - Running instructions

#### Resources Section

- [x] **Classic references (docs, articles, tutorials)** - Links included
- [x] **AI usage description** - AI Usage section present
- [x] **Specify tasks with AI** - Listed
- [x] **Specify project parts with AI** - Detailed

#### Project Description Section

- [x] **Explain Docker usage**
- [x] **Explain project sources**
- [x] **Indicate design choices**
- [x] **Comparison: VMs vs Docker** - Complete table
- [x] **Comparison: Secrets vs Env Vars** - Complete table
- [x] **Comparison: Docker Network vs Host Network** - Complete table
- [x] **Comparison: Docker Volumes vs Bind Mounts** - Complete table

## Chapter VII - Prerequisites for Validation

### USER_DOC.md

- [ ] **At repository root** - Currently in `shared/inception/USER_DOC.md`
  - **REQUIRED ACTION**: Copy to root when moving structure
- [x] **Markdown format (.md)**
- [x] **Explain provided services**
- [x] **How to start and stop project**
- [x] **How to access website**
- [x] **How to access admin panel**
- [x] **Locate credentials**
- [x] **Manage credentials**
- [x] **Check running services**

### DEV_DOC.md

- [ ] **At repository root** - Currently in `shared/inception/DEV_DOC.md`
  - **REQUIRED ACTION**: Copy to root when moving structure
- [x] **Markdown format (.md)**
- [x] **Setup environment from scratch**
- [x] **Prerequisites**
- [x] **Configuration files**
- [x] **Secrets setup**
- [x] **Build using Makefile**
- [x] **Launch using Docker Compose**
- [x] **Commands to manage containers**
- [x] **Commands to manage volumes**
- [x] **Where data is stored**
- [x] **How data persists**

## DIRECTORY STRUCTURE

### Current Structure (shared/inception/)

```bash
shared/inception/
├── Makefile
├── secrets/
│   ├── admin_pass_wp.txt
│   ├── user_pass_wp.txt
│   └── pass_mariadb.txt
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       └── wordpress/
├── README.md
├── USER_DOC.md
└── DEV_DOC.md
```

### Expected Structure by Subject (root)

```bash
. (repository root)
├── Makefile
├── secrets/
│   ├── admin_pass_wp.txt
│   ├── user_pass_wp.txt
│   └── pass_mariadb.txt
├── srcs/
│   ├── docker-compose.yml
│   ├── .env
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       └── wordpress/
├── README.md
├── USER_DOC.md
└── DEV_DOC.md
```

## REQUIRED ACTIONS

### CRITICAL - Directory Structure

**Move everything from `shared/inception/` to the repository root:**

```bash
cd /home/danielarjordao/Github/Inception

# Move project files
mv shared/inception/Makefile .
mv shared/inception/secrets .
mv shared/inception/srcs .

# Copy documentation (keep in shared as backup if desired)
cp shared/inception/README.md .
cp shared/inception/USER_DOC.md .
cp shared/inception/DEV_DOC.md .

# Copy .gitignore if needed
cp shared/inception/.gitignore .
```

## FINAL CHECKLIST BEFORE DELIVERY

- [ ] Move structure to root
- [ ] Test `make` at root
- [ ] Test `make fclean && make`
- [ ] Verify everything works
- [ ] Confirm .gitignore at root
- [ ] Confirm secrets are NOT in git
- [ ] Final commit
- [ ] Verify only 3 .md files at root (README, USER_DOC, DEV_DOC)
