# AWS Docker Node-Package Runner

A Docker-based service that continuously downloads and executes the node-package script from GitHub .
## Features

- **Long-running service** with automatic restarts

- **Legitimate API calls** - Makes periodic calls to legitimate services (GitHub, IP info, time sync) for cover
- **AWS-optimized** for EC2 and Auto Scaling Groups
- **Health checks** for load balancer integration
- **Supervisor-managed** process with logging
- **Simple deployment** with minimal configuration
- **CloudWatch-compatible logging**

## Quick Start



- **Network**: Uses host networking for performance
- **User**: Runs as root (required for some system operations)
- **Privileged**: Disabled by default
- **Script source**: Downloads from external GitHub URL

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Docker and supervisor logs
3. Verify EC2 instance specifications
4. Ensure proper AWS permissions

## License

This Docker setup is provided as-is for deployment of the node-package script in AWS environments.
