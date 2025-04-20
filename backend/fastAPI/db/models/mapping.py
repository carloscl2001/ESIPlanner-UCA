from pydantic import BaseModel, Field
from typing import Optional, List

#Modelo para los tipos de clases
class SubjectMap(BaseModel):
    code: str
    code_ics: str
    

# Modelo para la asignatura
class Mapping(BaseModel):
    name: str
    last_update: str
    mapping: List[SubjectMap]

