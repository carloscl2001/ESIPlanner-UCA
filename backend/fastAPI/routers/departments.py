## API PARA GESTIONAR LOS GRADOS##
from fastapi import APIRouter, HTTPException, status, Response
from db.models.department import Department
from db.schemas.department import department_schema, departments_schema
from db.client import db_client
from bson import ObjectId
from typing import List

# Definimos el router
router = APIRouter(prefix="/departments",
                    tags=["departments"],
                    responses={status.HTTP_404_NOT_FOUND: {"message": "Not found"}})



#Obtener todas los grados
@router.get("/", response_model=list[Department])
async def get_degree():
    try:
        departments_list = list(db_client.departments.find())  # Convierte el cursor en una lista
        return departments_schema(departments_list)  # Aplica el schema a la lista
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")
    