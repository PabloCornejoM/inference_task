"""
Script to create a doubleit PyTorch model

This script creates a simple PyTorch model that doubles input values
and saves it as a TorchScript model, since the model was not provided.

"""

import torch

# simple model that doubles input values
class DoubleIt(torch.nn.Module):
    """A simple neural network that doubles input values."""
    
    def __init__(self):
        """Initialize the model."""
        super(DoubleIt, self).__init__()

    def forward(self, x):
        """Forward pass that doubles the input tensor."""
        return x * 2


# create the model
model = DoubleIt()

# save the model and turn to TorchScript
torch.jit.script(model).save("doubleit_model.pt")

print("Model saved as doubleit_model.pt")