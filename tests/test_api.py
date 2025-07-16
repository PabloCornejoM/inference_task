"""
Tests for the FastAPI inference endpoint.

Basic functionality tests to ensure the API works correctly.
"""

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_predict_endpoint():
    """Test that the predict endpoint returns correct doubled values."""
    response = client.post("/predict", json={"values": [5, 10]})
    assert response.status_code == 200
    assert response.json() == {"result": [10, 20]}
