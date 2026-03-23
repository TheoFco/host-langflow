FROM langflowai/langflow:1.8.2

EXPOSE 7860

ENV LANGFLOW_MAX_CACHE_SIZE=10
ENV LANGFLOW_WORKERS=1

CMD ["langflow", "run", "--host", "0.0.0.0", "--port", "7860"]
