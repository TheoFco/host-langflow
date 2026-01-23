FROM langflowai/langflow:1.6.7

USER root

# Install nginx (reverse proxy)
RUN apt-get update \
  && apt-get install -y --no-install-recommends nginx nginx-module-perl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Nginx config + login page
COPY nginx.conf /etc/nginx/nginx.conf
COPY login.html /usr/share/nginx/html/login.html

# Entrypoint starts langflow on 7861 and nginx on 7860
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 7860

ENTRYPOINT ["/app/entrypoint.sh"]
