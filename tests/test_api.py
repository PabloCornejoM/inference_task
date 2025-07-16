from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_predict_endpoint():
    response = client.post("/predict", json={"values": [5, 10]})
    assert response.status_code == 200
    assert response.json() == {"result": [10, 20]}
