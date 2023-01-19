# Dockerfile for athlete-server

FROM python:3.9-alpine3.17  
COPY . /app
WORKDIR app
EXPOSE 8000
CMD python3 test.py
CMD [ "python3", "server.py"]