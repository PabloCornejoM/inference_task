"""
Simple inference script for testing the doubleit model.

Loads the saved model and runs a quick test to verify it works correctly.
"""

import torch

# Load the saved model and run a test
ts = torch.jit.load('./doubleit_model.pt')
sample_tensor = torch.tensor([1, 2, 3, 4])
result = ts(sample_tensor)

print(result)  # Expected output: tensor([2, 4, 6, 8])