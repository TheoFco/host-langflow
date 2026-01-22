FROM langflowai/langflow:1.6.7

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends nginx apache2-utils ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 7860
ENTRYPOINT ["/app/entrypoint.sh"]
