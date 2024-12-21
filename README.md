# Nami Service

Nami is a proxy service built with Nginx, designed to handle multiple subdomains and configurations. This project uses Docker and Docker Compose to streamline deployment and management.

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Makefile Commands](#makefile-commands)
- [Configuration](#configuration)
- [License](#license)

---

## Features
- Proxy for multiple subdomains.
- SSL support using Let's Encrypt.
- Customizable Nginx configurations.
- Easily reload configurations or reset containers.

---

## Requirements
- Docker (>= 20.10.0)
- Docker Compose (>= 1.29.0)
- Access to the domain DNS to configure subdomains.

---

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-repo/nami-service.git
    cd nami-service
    ```

2. Ensure the required directories and files exist:
    - `nginx.conf`: The main Nginx configuration file.
    - `certbot/www/`: Directory for Let's Encrypt challenge files.
    - `certbot/conf/`: Directory for Let's Encrypt certificates.

3. Adjust the configurations as needed:
    - Update `nginx.conf` with your domains and proxy settings.

---

## Usage

### Start the Service
To start the service without rebuilding the Docker images:
```bash
make start
```

### Build and Start the Service
To rebuild Docker images and start the service:
```bash
make startall
```

### Reload Nami
If you make changes to `nginx.conf` or certificates, reload the `nami` container:
```bash
make reload-nami
```

### Stop the Service
To stop the `nami` and `certbot` containers:
```bash
make down
```

### Reset Containers
To remove all containers, volumes, and restart with a clean slate:
```bash
make reset
```

---

## Makefile Commands

| Command        | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `make start`   | Start the project without rebuilding images.                                |
| `make startall`| Rebuild and start the project.                                              |
| `make reload-nami` | Restart the `nami` container to apply configuration changes.            |
| `make down`    | Stop the `nami` and `certbot` containers.                                   |
| `make reset`   | Reset containers, volumes, and networks for a clean slate.                 |
| `make help`    | Display the available `Makefile` commands.                                  |

---

## Configuration

### `nginx.conf`
The `nginx.conf` file contains the Nginx server configuration. Example:
```nginx
server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    location / {
        proxy_pass http://backend-service:8080;
    }
}
```

### Certificates
- Certificates are managed using Let's Encrypt via the `certbot` container.
- The `certbot/www/` directory is used for the ACME challenge.
- Certificates are stored in `certbot/conf/`.

---

## License
This project is licensed under the [MIT License](LICENSE).

---

## Contributions
Feel free to submit issues or pull requests for improvements and bug fixes!

---

## Notes
- Ensure DNS records for your domains are properly configured.
- Use `make reload-nami` whenever you modify `nginx.conf` or update certificates.