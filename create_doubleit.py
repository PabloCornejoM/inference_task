"""
Script to create a doubleit PyTorch model

This script creates a simple PyTorch model that doubles input values
and saves it as a TorchScript model, since the model was not provided.
"""

import torch

# simple model that doubles input values
class DoubleIt(torch.nn.Module):
    def __init__(self):
        super(DoubleIt, self).__init__()

    def forward(self, x):
        return x * 2


# create the model
model = DoubleIt()

# save the model and turn to TorchScript
torch.jit.script(model).save("doubleit_model.pt")

print("Model saved as doubleit_model.pt")