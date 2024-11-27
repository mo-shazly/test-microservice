FROM python:3.8-slim

WORKDIR /app

COPY . /app

COPY . .

# Flask
RUN pip install --no-cache-dir -r requirements.txt 

EXPOSE 3000

ENV NAME World

CMD ["python", "main.py"]