# AgenticSeek Runbook

Local, open-source autonomous AI agent system running in Docker inside WSL (Ubuntu), configured to route all LLM completions requests to your local LiteLLM Proxy.

## 1. System Topology & Architecture

* **WSL Location:** `/home/tpcoleary/agenticSeek`
* **Windows File Path:** `\\wsl.localhost\Ubuntu\home\tpcoleary\agenticSeek`
* **Docker Network:** `agenticseek_agentic-seek-net` (Bridge)

### Container Ports & Mappings
| Service | Internal Port | Host Port | Purpose | Status |
| :--- | :--- | :--- | :--- | :--- |
| **frontend** | `3000` | `3010` | Web UI Dashboard | Exited |
| **backend** | `7777` | `7777` | Python FastAPI Agent Engine | Exited |
| **searxng** | `8080` | `8085` | Local Private Search Engine | Exited |
| **redis** | `6379` | *internal* | Valkey key-value cache / memory | Exited |

> [!NOTE]
> - **Port 3010 Mapping:** The frontend host port was changed from `3000` to `3010` to avoid conflicts with your running `mem0-dashboard`.
> - **Port 8085 Mapping:** The SearXNG host port was changed from `8080` to `8085` to avoid conflicts with your running `openclaw-server`.

---

## 2. LLM Integration Configuration

AgenticSeek connects to your **LiteLLM Proxy** on the Windows guest host using the `openai` local-compatible provider setup.

* **Model Name:** `nemotron3super_autogen`
* **API Base Endpoint:** `http://host.docker.internal:4000/v1`
* **API Key:** `sk-any-key-value` (defined in `.env` as `OPENAI_API_KEY`)
* **Stealth Mode:** Set to `False` in `config.ini` to avoid `undetected_chromedriver` trying to execute auto-update DNS queries at startup.

---

## 3. Operational Playbooks

### Start Services
Run this command from your host machine or directly inside WSL to start the entire stack in the background:
```bash
# In WSL:
cd ~/agenticSeek
docker compose --profile full up -d
```

### Stop Services
To stop all containers and release ports:
```bash
# In WSL:
cd ~/agenticSeek
docker compose --profile full down
```

### Recreate Containers (Force Rebuild)
If configurations are updated or dependencies change:
```bash
# In WSL:
cd ~/agenticSeek
docker compose --profile full up -d --force-recreate
```

---

## 4. Diagnostics & Troubleshooting

### Check Service Logs
If the Web UI is inaccessible or commands hang, inspect container logs:
```bash
docker logs -f backend
docker logs -f frontend
docker logs -f searxng
```

### DNS / Name Resolution Issues
If containers throw a `Temporary failure in name resolution` error (which commonly occurs in nested WSL configurations), the custom DNS configuration in `docker-compose.yml` forces the containers to use public DNS servers (`8.8.8.8` and `1.1.1.1`), bypassing the Docker Desktop DNS proxy.

Ensure the following configuration block exists in your `docker-compose.yml` services:
```yaml
    dns:
      - 8.8.8.8
      - 1.1.1.1
```


## 🧹 Docker Resource Maintenance
To prevent high disk space consumption and maintain optimal performance (common issues with Docker Desktop on Windows):
* **Check Disk Usage**: `docker system df`
* **Clean Exited Containers & Dangling Images**: `docker system prune`
* **Complete System Cleanup**: `docker system prune -a --volumes` *(Warning: This removes all stopped containers, unused networks, and dangling volumes/images)*
* **Prune Builder Cache**: `docker builder prune -a`
