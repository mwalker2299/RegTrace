from fastapi.testclient import TestClient


def test_readyz_ok(client: TestClient):
    resp = client.get("/readyz")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ready"}
