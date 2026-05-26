# Docker Cheat Sheet

## Images

```bash
docker images
docker pull <image>:<tag>
docker build -t <image>:<tag> .
docker build -t <image>:<tag> -f <Dockerfile> .
docker tag <image>:<tag> <registry>/<image>:<tag>
docker push <registry>/<image>:<tag>
docker rmi <image>:<tag>
docker image prune -a
docker image inspect <image>:<tag>
```

## Containers

```bash
docker ps
docker ps -a
docker run -d --name <name> <image>:<tag>
docker run -d -p <host-port>:<container-port> <image>:<tag>
docker run -d -e <KEY>=<VALUE> <image>:<tag>
docker run -d -v <host-path>:<container-path> <image>:<tag>
docker run -it --rm <image>:<tag> /bin/sh
docker start <container>
docker stop <container>
docker restart <container>
docker rm <container>
docker rm -f <container>
docker exec -it <container> /bin/sh
docker inspect <container>
```

## Logs

```bash
docker logs <container>
docker logs <container> --tail 100
docker logs <container> -f
docker logs <container> --since 1h
```

## Networking

```bash
docker network ls
docker network create <network>
docker network inspect <network>
docker network connect <network> <container>
docker network disconnect <network> <container>
docker network rm <network>
```

## Volumes

```bash
docker volume ls
docker volume create <volume>
docker volume inspect <volume>
docker volume rm <volume>
docker volume prune
```

## Docker Compose

```bash
docker compose up -d
docker compose down
docker compose ps
docker compose logs
docker compose logs -f <service>
docker compose build
docker compose pull
docker compose restart <service>
docker compose exec <service> /bin/sh
docker compose config
```

## System and Cleanup

```bash
docker system df
docker system prune
docker system prune -a --volumes
docker container prune
docker image prune -a
docker volume prune
docker network prune
```

## Registry

```bash
docker login <registry>
docker logout <registry>
docker search <term>
```

## Useful Flags

| Flag | Description |
|---|---|
| `-d` | Run in detached mode |
| `-it` | Interactive with TTY |
| `--rm` | Remove container after exit |
| `-p` | Port mapping (host:container) |
| `-v` | Volume mount (host:container) |
| `-e` | Set environment variable |
| `--name` | Assign container name |
| `--network` | Connect to network |
| `--restart` | Restart policy (no, always, unless-stopped, on-failure) |