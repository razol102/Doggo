FROM python:3.11.5-slim

RUN apt-get update && apt-get install -y gcc libpq-dev

WORKDIR /app
COPY . /app

RUN pip install --no-cache-dir -r ./src/requirements.txt

EXPOSE 5000
ENV FLASK_APP=./src/main.py
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
