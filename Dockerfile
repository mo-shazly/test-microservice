FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN apt update && apt install -y curl

COPY . .

EXPOSE 5000

CMD ["python", "run.py"]

