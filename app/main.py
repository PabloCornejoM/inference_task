
"""
API for serving PyTorch model inference.

This module provides a API endpoint for model inference using a pre-trained
PyTorch model that doubles input tensor values.
"""


from fastapi import FastAPI
from pydantic import BaseModel
import torch

# Load model
model = torch.jit.load("doubleit_model.pt")

# Create FastAPI instance
app = FastAPI()

# Define input schema
class InputData(BaseModel):
    """Input data structure for the prediction endpoint."""
    values: list[int]

# Inference endpoint
@app.post("/predict")
def predict(data: InputData):
    """Process input values through the model and return doubled results."""
    x = torch.tensor(data.values)
    y = model(x)
    return {"result": y.tolist()}
