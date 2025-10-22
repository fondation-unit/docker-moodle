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

### Environment file:

Copy the sample file [.env-sample](.env-sample) as `.env` and fill in the missing information.

1. Create the network:

```sh
docker network create web
```

2. Prepare the Docker stack:

- Edit your `.env` file
- Configure the `traefik/acme.json` file with the right permissions:

```sh
chmod 600 traefik/acme.json
chown $USER:$USER traefik/acme.json
```

3. Build the stack:

```sh
docker compose up --build
```

4. Launch the app:

```sh
docker compose up -d
```

## Traefik

Uncomment the following lines in `docker-compose.yml` to let Traefik display debug logs:

```sh
- "--log.level=DEBUG"
- "--accesslog=true"
- "--accesslog.format=json"
```

## Base de données

Log into the MariaDB container:

```sh
docker compose exec db mariadb -U moodle -d moodle
```

## Stats

Real time stats:

```sh
docker stats
```

Observe dockerd processes:

```sh
ps aux | grep dockerd | grep -v grep
```

Memory use by dockerd daemon:

```sh
ps aux | grep dockerd | awk '{print $4, $11}' | sort -nr
ps aux --sort=-%mem | head -20
```

Logs de l'application / Traefik :

```sh
docker compose logs -f moodle
docker logs traefik
```
