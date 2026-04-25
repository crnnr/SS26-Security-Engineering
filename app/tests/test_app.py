from app.app import app


def test_healthz():
    client = app.test_client()
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.get_json() == {"status": "ok"}


def test_version():
    client = app.test_client()
    r = client.get("/version")
    assert r.status_code == 200
    body = r.get_json()
    assert "version" in body and "commit" in body


def test_echo_roundtrip():
    client = app.test_client()
    r = client.post("/echo", json={"hello": "world"})
    assert r.status_code == 200
    assert r.get_json() == {"received": {"hello": "world"}}


def test_echo_empty_body():
    client = app.test_client()
    r = client.post("/echo")
    assert r.status_code == 200
    assert r.get_json() == {"received": {}}
