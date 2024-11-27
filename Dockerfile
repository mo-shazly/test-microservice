FROM python:3.8-slim

WORKDIR /app

COPY . /app

COPY . .

# Flask
#RUN pip install --no-cache-dir -r requirements.txt 
RUN pip install Flask==2.2.2

EXPOSE 3000

ENV NAME World

CMD ["python", "run.py"]