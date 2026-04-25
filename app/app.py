"""Minimal Flask demo application used as the Subject-Under-Test (SUT)
for the secure CI/CD pipeline. Intentionally simple so the focus stays
on the pipeline, not the application logic."""
from __future__ import annotations

import os
from flask import Flask, jsonify, request

app = Flask(__name__)


@app.get("/healthz")
def healthz():
    return jsonify(status="ok"), 200


@app.get("/version")
def version():
    return jsonify(
        version=os.environ.get("APP_VERSION", "dev"),
        commit=os.environ.get("GIT_COMMIT", "unknown"),
    )


@app.post("/echo")
def echo():
    payload = request.get_json(silent=True) or {}
    # Keep the response shape predictable; never reflect headers/cookies.
    return jsonify(received=payload), 200


if __name__ == "__main__":  # pragma: no cover
    # Bind to localhost by default; container overrides via gunicorn.
    app.run(host="127.0.0.1", port=8000)
