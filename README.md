# Soju IRC Bouncer - Docker Setup

A Docker setup for running [soju](https://soju.im/), a user-friendly IRC bouncer.

## What is soju?

Soju is an IRC bouncer that allows you to stay connected to IRC networks even when your client disconnects. It provides features like message history, multiple client connections, and network persistence.

## Prerequisites

- Docker
- Docker Compose
- TLS certificate and key (for secure connections)

## Quick Start

1. Clone this repository

2. Create the required directories:
   ```bash
   mkdir -p data/soju data/etc
   ```

3. Set up TLS certificates in `./data/etc/`:
   ```bash
   # Generate a self-signed certificate (for testing)
   openssl req -x509 -newkey rsa:4096 -keyout data/etc/key.pem -out data/etc/cert.key -days 365 -nodes
   ```

   For production, use certificates from a trusted CA like Let's Encrypt.

4. Copy the default configuration:
   ```bash
   cp config ./data/etc/config
   ```

   The default config includes:
   - SQLite database storage
   - Filesystem-based message history
   - TLS-enabled IRC listener on port 6697
   - Unix socket for admin commands

5. Start the service:
   ```bash
   docker compose up -d
   ```

Soju will be available on port `6697` with TLS enabled.

## Configuration

### Config File

The included `config` file contains sensible defaults:

```
db sqlite3 /var/lib/soju/main.db
message-store fs /var/lib/soju/logs/
listen ircs://
listen unix+admin://
tls /etc/soju/cert.key /etc/soju/key.pem
```

After copying to `./data/etc/config`, you can customize it as needed. See the [soju documentation](https://soju.im/) for all available options.

### Soju Version

This setup builds soju `v0.10.1` by default. To use a different version, modify the `SOJU_VERSION` arg in `compose.yml` or override it at build time:

```bash
docker compose build --build-arg SOJU_VERSION=v0.11.0
```

### Data Persistence

Two volumes are mounted for persistent data:

- `./data/soju` - Database (`main.db`) and message logs
- `./data/etc` - Configuration file and TLS certificates

## Setting Up Users and Networks

After starting soju, you need to create a user and configure IRC networks:

1. Create an admin user:
   ```bash
   docker exec -it soju sojuctl -config /etc/soju/config create-user <username> -admin
   ```

2. Connect your IRC client to `localhost:6697` using the username you created

3. Use soju's built-in commands to add networks. In your IRC client, send:
   ```
   /msg BouncerServ network create -addr irc.libera.chat:6697 -name libera
   ```

For more details, see the [soju documentation](https://soju.im/).

## Connecting to Soju

Connect your IRC client to:
- **Host:** `localhost` (or your server's address)
- **Port:** `6697`
- **TLS:** Enabled
- **Username:** Your soju username
- **Password:** Your soju password (if set)

## Management

View logs:
```bash
docker compose logs -f
```

Restart the service:
```bash
docker compose restart
```

Stop the service:
```bash
docker compose down
```

Access admin console:
```bash
docker exec -it soju sojuctl -config /etc/soju/config <command>
```

## Repository Structure

```
.
├── compose.yml          # Docker Compose configuration
├── Dockerfile           # Multi-stage build for soju
├── config              # Default soju configuration
└── data/               # Created on first run
    ├── etc/            # Runtime config and TLS certs
    └── soju/           # Database and logs
```

## Ports

- `6697` - IRC over TLS (ircs://)

## License

This Docker setup is provided as-is. Soju itself is licensed under the AGPLv3. See the [soju repository](https://codeberg.org/emersion/soju) for more information.
