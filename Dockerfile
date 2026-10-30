# Base image pinned by digest. Refresh deliberately, not on every build.
FROM python:3.13-slim@sha256:2d44738ebf4ce5f63b9d9ea871e9c7cfdc0426f7b0c97cac915fd88ded1d86bb

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin app \
 && mkdir /data && chown 10001:10001 /data

WORKDIR /app
# SQLite creates -wal/-shm files next to disclosed_reports.db, so the directory must be writable.
RUN chown 10001:10001 /app
COPY requirements.txt .
RUN pip install --no-cache-dir --require-hashes -r requirements.txt

COPY --chown=10001:10001 server.py hack_instructions.md disclosed_reports.db ./

USER 10001:10001

# Personal DB goes on the /data volume. The server runs in HTTP mode in the container.
ENV H1_DATA_DIR=/data \
    MCP_TRANSPORT=streamable-http \
    MCP_HOST=0.0.0.0 \
    MCP_PORT=8000
EXPOSE 8000
CMD ["python", "server.py"]
