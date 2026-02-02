# Docker Moodle

A Docker Compose stack for deploying Moodle with a Traefik proxy.

## Docker Compose breakdown

### Stacks:

- `moodle` - The Moodle PHP-FPM application container
- `moodle-web` - Nginx container exposing Moodle to Traefik
- `db` - MariaDB container for Moodle's database
- `redis` - Redis container for caching and session storage
- `traefik` - Traefik reverse proxy handling routing and HTTPS

### Volumes:

| Volume        | Purpose                                                                                                          |
| ------------- | ---------------------------------------------------------------------------------------------------------------- |
| `moodle_src`  | The Moodle application source code. Mounted inside the Moodle container at `/var/www/html`.                      |
| `moodle_data` | The moodledata (cache, sessions, files, uploaded content). Mounted at `/var/moodledata` in the Moodle container. |
| `db_data`     | The MariaDB database persistence.                                                                                |
| `redis_data`  | Redis data persistence (if configured) for caching and session storage.                                          |

### Moodle sources:

Download and place the Moodle source files in the [moodle/src](moodle/src) folder.

You should have a structure like: `moodle/src/[ Moodle sources files]`.

## Installation

1. Copy the sample file [.env-sample](.env-sample) as `.env` and fill in the missing information.

2. Create the network:

```bash
docker network create web
```

3. Prepare the Docker stack:

- Edit your `.env` file
- Configure the `traefik/acme.json` file with the right permissions:

```bash
chmod 600 traefik/acme.json
chown $USER:$USER traefik/acme.json
```

- Download and prepare Moodle sources:

```bash
wget -P moodle/src https://download.moodle.org/download.php/direct/stable501/moodle-latest-501.tgz

tar -xf moodle/src/moodle-latest-501.tgz -C moodle/src

mv moodle/src/moodle/{*,.*} moodle/src/ 2>/dev/null && \
  rmdir moodle/src/moodle 2>/dev/null && \
  rm moodle/src/moodle-latest-*.tgz
```

4. Build the stack:

```bash
docker compose up --build
```

5. Launch the app:

```bash
docker compose up -d
```

## Traefik

Uncomment the following lines in `docker-compose.yml` to let Traefik display debug logs:

```bash
- "--log.level=DEBUG"
- "--accesslog=true"
- "--accesslog.format=json"
```

## Database

Log into the MariaDB container:

```bash
docker compose exec db mariadb -u moodle -p moodle
```

## Stats

Real time stats:

```bash
docker stats
```

Observe dockerd processes:

```bash
ps aux | grep dockerd | grep -v grep
```

Memory use by dockerd daemon:

```bash
ps aux | grep dockerd | awk '{print $4, $11}' | sort -nr
ps aux --sort=-%mem | head -20
```

App & Traefik logs:

```bash
docker compose logs -f moodle
docker logs traefik
```

## Backups

### Create backups of volumes:

```bash
docker volume ls

docker run --rm -v docker-moodle_db_data:/volume -v /opt/backup:/backup alpine tar czvf /backup/backup_moodle_db_data.tar.gz -C /volume .
```

### Restore volumes:

Remove the containers:

```bash
docker compose down
```

Delete the volumes:

```bash
docker volume rm docker-moodle_db_data
```

Create the volumes:

```bash
docker volume create docker-moodle_db_data
```

Restore the backups:

```bash
docker run --rm -v docker-moodle_db_data:/volume -v /opt/backup:/backup alpine sh -c "tar xzvf /backup/backup_moodle_db_data.tar.gz -C /volume"
```

## Localhost setup

Install `mkcert` and its dependencies:

```bash
brew bundle
```

Install the Docker compose stack:

```bash
docker compose -f docker-compose.local.yml build
```

Generate the certificates for localhost:

```bash
docker compose -f docker-compose.local.yml run --rm mkcert
```

Install the local certificates:

```bash
mkcert -install
```

Run the stack:

```bash
docker compose -f docker-compose.local.yml up -d
```
