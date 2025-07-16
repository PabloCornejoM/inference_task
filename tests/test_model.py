import torch

def test_model_output():
    model = torch.jit.load("doubleit_model.pt")
    input_tensor = torch.tensor([1, 2, 3])
    output = model(input_tensor)
    expected_output = torch.tensor([2, 4, 6])
    
    assert torch.equal(output, expected_output), "Model output is incorrect"
