# USER_DOC.md

## Services Overview

The Inception infrastructure provides three services:

- **NGINX** (port 443): Web server with TLSv1.2, single entry point
- **WordPress 6.7.1**: Content Management System with PHP 8.2-FPM
- **MariaDB**: Database server storing WordPress data

All services run in Docker containers inside a virtual machine.

## Starting and Stopping

### Start the Project

```bash
make
```

Services start in order: MariaDB → WordPress → NGINX. Takes ~30-60 seconds.

### Stop the Project

```bash
make down
```

Data persists in `/home/dramos-j/data/` even after stopping.

### Check Status

```bash
docker ps
```

Should show three running containers: `nginx`, `wordpress`, `mariadb`.

## Accessing the Website

### Main Website

- URL: `https://dramos-j.42.fr`
- Accept the self-signed certificate warning

### WordPress Admin Panel

- URL: `https://dramos-j.42.fr/wp-admin`
- Login: `dramos-j-manager` / password from `secrets/admin_pass_wp.txt`

> Domain must be configured in `/etc/hosts`: `127.0.0.1 dramos-j.42.fr`

## Credentials

### Locations

All passwords are in the `secrets/` directory:

- `admin_pass_wp.txt` - WordPress admin
- `user_pass_wp.txt` - WordPress regular user
- `pass_mariadb.txt` - MariaDB database

### Users

**WordPress Admin:**

- Username: `dramos-j-manager`
- Email: <dramos-j@student.42.fr>
- Role: Administrator

**WordPress Author:**

- Username: `dramos-j`
- Email: <dramos-j@student.42porto.com>
- Role: Author

**MariaDB:**

- Database: `inception`
- User: `dramos-j`
- Port: 3306 (internal only)

### Changing Passwords

To change passwords, you must rebuild:

```bash
make down
echo "new_password" > secrets/admin_pass_wp.txt
make fclean
make
```

`make fclean` deletes all data!

## Checking Services

### Quick Check

```bash
docker ps
```

All three containers should show `Up`.

### View Logs

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb

# Follow in real-time
docker logs -f nginx
```

### Test Containers

**NGINX:**

```bash
curl -k https://dramos-j.42.fr
```

Should return HTML.

**WordPress:**

```bash
docker exec wordpress ps aux | grep php-fpm
```

Should show PHP-FPM running.

**MariaDB:**

```bash
docker exec mariadb mysql -u dramos-j -p$(cat secrets/pass_mariadb.txt) -e "SHOW DATABASES;"
```

Should display `inception` database.

### Data Persistence

Check data directories:

```bash
ls -lh /home/dramos-j/data/wordpress
ls -lh /home/dramos-j/data/mariadb
```

Both should contain files after first run.

## Troubleshooting

**Can't access website:**

- Check `/etc/hosts` has `127.0.0.1 dramos-j.42.fr`
- Verify nginx is running: `docker ps`

**Database connection error:**

- Wait 30s for MariaDB initialization
- Check logs: `docker logs mariadb`

**Changes don't persist:**

- Data is in `/home/dramos-j/data/`
- Only `make fclean` deletes data

**Rebuild everything:**

```bash
make fclean && make
```

For technical details, see [DEV_DOC.md](DEV_DOC.md).
