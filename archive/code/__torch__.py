class Model(Module):
  __parameters__ = []
  __buffers__ = []
  training : bool
  _is_full_backward_hook : Optional[bool]
  def forward(self: __torch__.Model,
    x: Tensor) -> Tensor:
    return torch.mul(x, 2)
