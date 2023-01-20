# Dockerfile for athlete-server

FROM python:3.9-alpine3.17
RUN adduser -D worker
USER worker
WORKDIR /home/worker
COPY --chown=worker:worker . .
EXPOSE 80
CMD python3 test.py
CMD [ "python3", "server.py"]