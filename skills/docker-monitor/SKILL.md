---
name: docker-monitor
description: Monitor Docker containers for errors, analyze logs, and help debug issues. Use when user wants to watch container logs, find errors, or debug Docker-based applications.
---

# Docker Container Monitor

Monitor and debug Docker containers during development.

## Container Management

### List running containers

```bash
docker ps
# Or with more detail:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### List all containers (including stopped)

```bash
docker ps -a
```

### Container status

```bash
docker inspect <container_name> --format='{{.State.Status}}'
docker stats --no-stream <container_name>
```

## Log Monitoring

### Stream logs in real-time

```bash
docker logs -f <container_name>
```

### Tail last N lines

```bash
docker logs --tail 100 <container_name>
```

### Show timestamps

```bash
docker logs -t <container_name>
```

### Since timestamp (last hour)

```bash
docker logs --since 1h <container_name>
```

### Follow + tail + timestamps

```bash
docker logs -ft --tail 50 <container_name>
```

## Error Detection

### Find errors in logs

```bash
docker logs <container_name> 2>&1 | grep -i error
docker logs <container_name> 2>&1 | grep -iE "(exception|fatal|failed|panic)"
```

### Show only stderr

```bash
docker logs <container_name> 2>&1 1>/dev/null
```

### Last N errors with context

```bash
docker logs <container_name> 2>&1 | grep -B5 -A5 -i error
```

## Debugging Workflow

### 1. Identify problematic container

```bash
docker ps -a | grep -E "(Exited|Restarting)"
docker stats --no-stream
```

### 2. Check recent logs for errors

```bash
docker logs --tail 200 <container_name> 2>&1 | tail -50
```

### 3. Inspect container

```bash
docker inspect <container_name>
docker inspect <container_name> --format='{{.State}}'
```

### 4. Check resource usage

```bash
docker stats <container_name>
docker system df
```

### 5. Enter container (if running)

```bash
docker exec -it <container_name> sh
# or
docker exec -it <container_name> /bin/bash
```

### 6. Copy logs out

```bash
docker logs <container_name> > local-log-file.log
```

## Common Debug Scenarios

### Container keeps restarting

```bash
# Check restart count
docker inspect <container_name> --format='{{.RestartCount}}'

# Check exit code
docker inspect <container_name> --format='{{.State.ExitCode}}'

# Follow restart logs
docker logs -f <container_name>
```

### Port already in use

```bash
# Find what's using the port
netstat -tlnp | grep <port>
# or
ss -tlnp | grep <port>

# Check container port mapping
docker port <container_name>
```

### Out of memory

```bash
docker stats <container_name>
docker system df
```

### Database connection issues

```bash
# Check if database container is running
docker ps | grep -E "(postgres|mysql|mongo|redis)"

# Test connection from app container
docker exec <app_container> nc -zv <db_host> <port>
```

## Multi-Container Projects

### Docker Compose logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f <service_name>

# Last N lines per service
docker compose logs --tail 100

# Follow specific service
docker compose logs -f <service_name>
```

### Docker Compose debug

```bash
# Show all containers
docker compose ps -a

# Rebuild and start
docker compose up --build

# Start in detached mode
docker compose up -d

# Stop all
docker compose down
```

## Integration with Agent

When user reports an error:

1. **Gather context**: Ask for container name or project directory
2. **Identify containers**: `docker ps -a` to see all containers
3. **Fetch logs**: Get relevant logs with timestamps
4. **Analyze errors**: Search for patterns (error, exception, failed, panic)
5. **Provide insights**: Explain what the error likely means
6. **Suggest fixes**: Based on common patterns

## Common Error Patterns

| Error | Likely Cause | Fix |
|-------|--------------|-----|
| `connection refused` | Service not running or wrong port | Check port mapping, restart service |
| `permission denied` | File/directory permissions | Fix ownership or permissions |
| `no such file or directory` | Missing file or wrong path | Verify volume mounts |
| `out of memory` | Memory limit exceeded | Increase memory in docker-compose |
| `database connection failed` | DB not ready or wrong credentials | Checkdepends_on, credentials |
| `address already in use` | Port conflict | Stop other container or change port |

## Notes

- Use `docker logs` with `-f` to follow in real-time
- Combine `grep` for filtering errors
- Use `--since` and `--tail` to limit log scope
- `docker compose` is preferred for multi-container projects
- Always check container status first: `docker ps -a`