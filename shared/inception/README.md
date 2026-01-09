# Inception

*This project has been created as part of the 42 curriculum by dramos-j.*

## Description

Inception is a system administration project that focuses on containerization using Docker. The goal is to set up a small infrastructure composed of different services following specific rules: each service must run in a dedicated Docker container, built from custom Dockerfiles based on the penultimate stable version of Alpine or Debian.

**This implementation uses Debian Bookworm (Debian 12)** with the following stack:
- **NGINX** with self-signed SSL certificate, TLSv1.2 only, as single entry point on port 443
- **WordPress 6.7.1** with PHP 8.2-FPM and WP-CLI for automated setup
- **MariaDB** from Debian repositories with custom initialization

All services communicate through a docker bridge network and use bind mounts for data persistence. Each container uses `restart: on-failure` policy and proper daemon processes (no infinite loops or hacky patches).

## Instructions

### Prerequisites
- Virtual machine with Debian-based Linux system (Debian 12 Bookworm recommended)
- Docker and Docker Compose installed
- Make utility
- Root/sudo access for creating data directories

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Inception
   ```

2. **Configure environment variables**
   - Copy the `.env.example` to `.env` if needed
   - Edit `srcs/.env` with your specific configuration
   - Update domain name and paths as needed

4. **Set up secrets**
   - Create password files in the `secrets/` directory:
     - `admin_pass_wp.txt` - WordPress admin password
     - `user_pass_wp.txt` - WordPress user password
     - `pass_mariadb.txt` - MariaDB root password

5. **Configure domain name**
   Add the following line to your `/etc/hosts`:
   ```
   127.0.0.1 dramos-j.42.fr
   ```
   (Replace `dramos-j.42.fr` with your own login)

### Running the Project

```bash
# Build and start all services
make

# Or step by step:
make build    # Build Docker images
make up       # Start containers

# Stop the services
make down

# Clean up containers and images
make clean

# Complete cleanup (removes volumes and data)
make fclean

# Rebuild everything
make re
```

### Accessing the Services

- **Website**: https://dramos-j.42.fr
- **WordPress Admin**: https://dramos-j.42.fr/wp-admin

## Resources

### Documentation & Tutorials
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [Debian Documentation](https://www.debian.org/doc/)

### Articles & Guides
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [WordPress with Docker](https://www.docker.com/blog/how-to-use-the-wordpress-docker-official-image/)
- [NGINX TLS Configuration](https://ssl-config.mozilla.org/)

### 42 Peer Projects
Examples of Inception implementations by other 42 students, reviewed for comparison and learning:
- [pin3dev's Inception](https://github.com/pin3dev/42_Inception)
- [AnaVolkmann's Inception](https://github.com/AnaVolkmann/inception)
- [AijaRe's 42Porto Inception](https://github.com/AijaRe/42Porto_Inception)

### AI Usage
During the development of this project, AI was used for:
- **Documentation review**: Verifying best practices and documentation structure
- **Troubleshooting**: Debugging Docker Compose configurations and networking issues
- **Configuration optimization**: Improving Dockerfile efficiency and security
- **Script validation**: Reviewing bash scripts for initialization processes

The core architecture, implementation decisions, and hands-on configuration were done manually to ensure deep understanding of Docker concepts and container orchestration.

## Project Description

### Docker in This Project

This project leverages **Docker** to create an isolated, reproducible infrastructure that can run consistently across different environments. Each service (NGINX, WordPress, MariaDB) runs in its own container, providing:

- **Isolation**: Each service has its own filesystem, processes, and network
- **Portability**: The entire stack can be deployed anywhere Docker runs
- **Reproducibility**: Same environment every time, eliminating "works on my machine" issues
- **Resource efficiency**: Containers share the host OS kernel

### Sources and Structure

The project is organized as follows:

```
.
├── Makefile              # Build automation
├── secrets/              # Password files (not in git)
├── srcs/
│   ├── docker-compose.yml  # Service orchestration
│   ├── .env                # Environment variables
│   └── requirements/
│       ├── mariadb/        # MariaDB Dockerfile and config
│       ├── nginx/          # NGINX Dockerfile and config
│       └── wordpress/      # WordPress Dockerfile and config
```

Each service has:
- **Dockerfile**: Defines the container image
- **conf/**: Configuration files
- **tools/**: Initialization scripts

### Design Choices

#### 1. Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker (Chosen) |
|--------|-----------------|-----------------|
| **Resource Usage** | Heavy - full OS per VM | Lightweight - shares host kernel |
| **Startup Time** | Minutes | Seconds |
| **Isolation** | Complete hardware virtualization | Process-level isolation |
| **Portability** | Limited - large image files | High - small images, runs anywhere |
| **Use Case** | Complete OS isolation needed | Application deployment and microservices |

**Why Docker?**: For this project, Docker provides the right balance of isolation, efficiency, and portability. We don't need full OS virtualization - we need isolated services that can communicate efficiently.

**Base Image Choice**: The subject allows choosing between Alpine or Debian (penultimate stable versions). This implementation uses **debian:bookworm-slim** as base for all services because:
- Native PHP 8.2 packages available (better WordPress compatibility)
- MariaDB server packages well-maintained
- Easier configuration compared to Alpine's busybox
- Smaller slim variant balances size vs functionality
- Better documentation and community support for Debian-based containers

#### 2. Secrets vs Environment Variables

| Aspect | Secrets (Chosen) | Environment Variables |
|--------|------------------|----------------------|
| **Security** | Not logged, encrypted in swarm mode | Visible in process listings |
| **Storage** | Separate files, can be encrypted | Plain text in .env files |
| **Access Control** | Can be restricted per service | Available to entire container |
| **Rotation** | Easier to update without rebuilding | Requires container restart |
| **Best For** | Passwords, keys, certificates | Configuration, non-sensitive data |

**Why Secrets?**: Passwords are stored in separate files in the `secrets/` directory and mounted as Docker secrets. This prevents them from being logged or exposed in the image layers. Environment variables are used for non-sensitive configuration only.

#### 3. Docker Network vs Host Network

| Aspect | Docker Network (Chosen) | Host Network |
|--------|------------------------|--------------|
| **Isolation** | Services isolated from host | Direct access to host network |
| **Port Mapping** | Explicit port mapping | Uses host ports directly |
| **Security** | Better - only exposed ports accessible | Less - all ports exposed |
| **Service Discovery** | Built-in DNS resolution | Manual IP management |
| **Use Case** | Microservices, multi-container apps | Performance-critical, single container |

**Why Docker Network?**: A custom bridge network (`inception`) allows containers to communicate using service names (e.g., `mariadb`, `wordpress`) with automatic DNS resolution. This provides isolation from the host while maintaining efficient inter-container communication.

#### 4. Docker Volumes vs Bind Mounts

| Aspect | Volumes | Bind Mounts (Chosen) |
|--------|---------|---------------------|
| **Management** | Managed by Docker | Manual path management |
| **Portability** | More portable | Tied to host filesystem |
| **Performance** | Optimized by Docker | Direct filesystem access |
| **Backup** | Requires Docker commands | Standard backup tools work |
| **Permissions** | Docker manages | Host filesystem permissions |

**Why Bind Mounts?**: This project uses bind mounts (`/home/dramos-j/data/`) to make data persistence explicit and easily accessible from the host. This is required by the project subject and makes it easy to:
- Backup data using standard tools
- Inspect data directly on the host
- Migrate data between systems
- Meet the requirement of data persisting in specified host directories

The data directories are created automatically by the Makefile before starting containers.

### Implementation Highlights & Design Decisions

This implementation includes several specific technical choices:

**1. TLS Configuration**
- Uses **TLSv1.2 only** (not 1.2/1.3) for stricter security baseline
- Self-signed certificate generated at build time with Portuguese locality info
- ARG variables passed from docker-compose for dynamic certificate generation

**2. WordPress Setup**
- **Version pinned**: WordPress 6.7.1 explicitly specified
- **WP-CLI automation**: Complete WordPress installation without manual intervention
- **Smart file handling**: `rsync` only copies files if volume is empty (preserves existing installations)
- **Two-user setup**: Admin (`dramos-j-manager`) + Author role user (`dramos-j`)
- **Security salts**: Auto-generated using WP-CLI shuffle-salts

**3. MariaDB Configuration**
- **Conditional initialization**: Checks for existing data before running mysql_install_db
- **No root password exposure**: Uses Docker secrets read at runtime
- **Remote access enabled**: User created with `@'%'` for container-to-container access
- **Temporary server pattern**: Starts server to configure, then shuts down cleanly

**4. Container Strategy**
- **`restart: on-failure`**: More precise than `always` - only restarts on actual failures
- **`gosu` over `su`**: Proper signal handling and PID management
- **`expose` not `ports`**: WordPress and MariaDB ports exposed only within Docker network
- **Layered cleanup**: Each Dockerfile includes `apt clean && rm -rf /var/lib/apt/lists/*`

**5. Dependency Management**
- **Explicit `depends_on`**: NGINX → WordPress → MariaDB chain
- **Active health check**: WordPress script pings MariaDB before proceeding (10 attempts max)
- **Graceful startup**: Each service waits for dependencies using application-level checks

### Technical Implementation Highlights

**Security & Protocol:**
- **TLS 1.2 Only**: NGINX explicitly configured with `ssl_protocols TLSv1.2;` (stricter than allowing both 1.2/1.3)
- **Self-Signed Certificate**: Generated with OpenSSL (RSA 2048, 365 days validity)
- **Single Entry Point**: Only NGINX exposes port 443; WordPress (9000) and MariaDB (3306) use `expose` only
- **Docker Secrets**: Passwords read from `/run/secrets/` mounted files (never in env vars or Dockerfiles)

**Container Management:**
- **Restart Policy**: `restart: on-failure` instead of `always` (more controlled recovery)
- **Proper Daemons**: NGINX runs with `daemon off`, PHP-FPM with `-F`, MariaDB via `gosu mysql mysqld`
- **No Root Processes**: MariaDB uses `gosu` to drop privileges; WordPress operations run as `www-data`
- **PID 1 Handling**: Entrypoint scripts use `exec "$@"` to replace shell with actual daemon

**Software Versions:**
- **WordPress**: 6.7.1 (pinned, downloaded during build)
- **PHP**: 8.2-FPM from Debian repos
- **WP-CLI**: Latest from official builds
- **Base Image**: debian:bookworm-slim (no `latest` tags)

**Initialization Strategy:**
- **WordPress**: Uses `rsync` to copy files only if volume is empty, then WP-CLI for database setup
- **MariaDB**: Conditional initialization with `mariadb-install-db`, temporary server for user creation
- **Database Health Check**: `mysqladmin ping` with retry logic before WordPress setup

**Network & Storage:**
- **Bridge Network**: Custom `inception` network with automatic DNS resolution
- **Bind Mounts**: Explicit paths to `/home/dramos-j/data/` (not Docker-managed volumes)
- **Volume Sharing**: WordPress volume mounted read-write in wordpress container, shared with NGINX for static files



For detailed user instructions, see [USER_DOC.md](USER_DOC.md).
For developer documentation, see [DEV_DOC.md](DEV_DOC.md).
