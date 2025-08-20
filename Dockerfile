# Enterprise Data Processing Service Container
# Ubuntu-based container for business analytics and reporting services
FROM ubuntu:22.04

# Set environment variables for business application
ENV DEBIAN_FRONTEND=noninteractive
ENV SERVICE_NAME=business-analytics-service
ENV COMPANY_ENV=production
ENV DATA_PROCESSING_MODE=batch

# Install required business application dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    supervisor \
    procps \
    htop \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create business application directories
RUN mkdir -p /app /var/log/supervisor /opt/business-data /opt/reports

# Copy business service configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start-service.sh /app/analytics-engine.sh

# Set appropriate permissions for business services
RUN chmod +x /app/analytics-engine.sh

# Create business service health monitoring script
RUN echo '#!/bin/bash\nif pgrep -f "analytics-engine.sh" > /dev/null; then\n  echo "Business Analytics Service is operational"\n  exit 0\nfi\necho "Business Analytics Service is offline"\nexit 1' > /app/health-check.sh && \
    chmod +x /app/health-check.sh

# Configure business environment variables
ENV ANALYTICS_ENABLED=true
ENV REPORTING_INTERVAL=300
ENV DATA_RETENTION_DAYS=30

# Container resource configuration - full host CPU access
# No CPU limits set, allowing access to all host CPU cores for analytics processing

# Expose standard business application port
EXPOSE 8080

# Add health monitoring for business continuity
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /app/health-check.sh

# Set business application working directory
WORKDIR /app

# Start enterprise business analytics service
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
