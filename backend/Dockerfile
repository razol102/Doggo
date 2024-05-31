FROM python:3.11.5-slim
WORKDIR /app
COPY ../doggo_backend_api /app
RUN pip3 install -r requirements.txt
EXPOSE 5000
ENV FLASK_APP=main.py
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
