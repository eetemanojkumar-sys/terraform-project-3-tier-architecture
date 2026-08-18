FROM python:3.12-slim

WORKDIR /app

COPY health.py .

EXPOSE 8080

USER nobody

CMD ["python3", "health.py"]
