from pydantic import BaseModel
from typing import List


# Modelo para el departamento
class Department(BaseModel):
    code: str
    name: str

