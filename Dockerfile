FROM langflowai/langflow:1.11.6

EXPOSE 7860

ENV LANGFLOW_MAX_CACHE_SIZE=10
ENV LANGFLOW_WORKERS=1
ENV LANGFLOW_AUTO_LOGIN=false

CMD ["langflow", "run", "--host", "0.0.0.0", "--port", "7860"]
