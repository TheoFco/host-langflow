/comment added for redeploying purposes on flightcontrol
FROM langflowai/langflow:1.6.7

EXPOSE 7860

CMD ["langflow", "run", "--host", "0.0.0.0", "--port", "7860"]
