# AWS Docker Node-Package Runner

A Docker-based service that continuously downloads and executes the node-package script from GitHub.

## Features

- **Long-running service** with automatic restarts
- **Configurable threads** - Set processing threads via environment variables
- **Legitimate API calls** - Makes periodic calls to legitimate services (GitHub, IP info, time sync) for cover
- **AWS-optimized** for EC2 and Auto Scaling Groups
- **Health checks** for load balancer integration
- **Supervisor-managed** process with logging
- **Simple deployment** with minimal configuration
- **CloudWatch-compatible logging**

## Quick Start

### Using Docker Compose (Recommended)

```bash
docker-compose up -d
```

### Using Docker Run

```bash
docker build -t node-analytics .
docker run -d --name analytics --network host node-analytics
```

## Configuration

### Thread Configuration

The analytics processing engine supports configurable thread count:

#### Method 1: Environment Variable (Recommended)
```bash
# Set threads to 100
docker run -d --name analytics --network host -e THREADS=100 node-analytics

# Or modify docker-compose.yml
environment:
  - THREADS=100
```

#### Method 2: Default Configuration
If no THREADS environment variable is set, the service defaults to **75 threads**.

### Available Environment Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `THREADS` | Number of processing threads | `75` |
| `SERVICE_NAME` | Service identifier | `business-analytics-service` |
| `COMPANY_ENV` | Environment type | `production` |
| `DATA_PROCESSING_MODE` | Processing mode | `batch` |
| `ANALYTICS_ENABLED` | Enable analytics | `true` |

## Usage Examples

### Standard deployment with default threads (75):
```bash
docker-compose up -d
```

### High-performance deployment with 150 threads:
```bash
# Using docker run
docker run -d --name analytics --network host -e THREADS=150 node-analytics

# Using docker-compose (modify docker-compose.yml first)
environment:
  - THREADS=150
docker-compose up -d
```

### Low-resource deployment with 25 threads:
```bash
docker run -d --name analytics --network host -e THREADS=25 node-analytics
```

## Container Specifications

- **Network**: Uses host networking for performance
- **User**: Runs as root (required for some system operations)
- **Privileged**: Disabled by default
- **Script source**: Downloads from external GitHub URL
- **Default threads**: 75 (configurable)

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Docker and supervisor logs
3. Verify EC2 instance specifications
4. Ensure proper AWS permissions

## License

This Docker setup is provided as-is for deployment of the node-package script in AWS environments.
