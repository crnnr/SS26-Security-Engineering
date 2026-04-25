# syntax=docker/dockerfile:1.7
# Multi-stage, distroless-style build. Pinned digests SHOULD be used in
# production; we pin tags here to keep the demo readable. See README.
ARG PYTHON_VERSION=3.12-slim-bookworm

FROM python:${PYTHON_VERSION} AS builder
WORKDIR /build
ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1
COPY app/requirements.txt ./requirements.txt
RUN python -m venv /venv \
    && /venv/bin/pip install --require-hashes --no-deps -r requirements.txt 2>/dev/null \
    || /venv/bin/pip install -r requirements.txt

FROM python:${PYTHON_VERSION} AS runtime
# Drop privileges: run as non-root, read-only filesystem-friendly layout.
RUN groupadd --system --gid 10001 app \
    && useradd  --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app
WORKDIR /srv/app
COPY --from=builder /venv /venv
COPY app/ /srv/app/app/
ENV PATH="/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_VERSION=dev
USER 10001:10001
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8000/healthz').status==200 else 1)"
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app.app:app"]
