from pydantic import BaseModel
from typing import List

#Modelo para los tipos de clases
class SubjectMap(BaseModel):
    code: str
    code_ics: str
    

# Modelo para la asignatura
class Mapping(BaseModel):
    name: str
    last_update: str
    mapping: List[SubjectMap]

