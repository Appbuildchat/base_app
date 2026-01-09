# Apply typing fixes at package initialization - must be first!
from .modules import typing_fix

def hello() -> str:
    return "Hello from nano-agent!"
