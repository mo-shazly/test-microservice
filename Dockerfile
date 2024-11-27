FROM python:3.8-slim

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt
RUN apt update && apt install -y curl


EXPOSE 5000

ENV NAME World

CMD ["python", "run.py"]