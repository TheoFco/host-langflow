FROM langflowai/langflow:1.5.1

EXPOSE 7860

CMD ["sh", "-c", "langflow run --host 0.0.0.0 --port ${PORT:-7860}"]
