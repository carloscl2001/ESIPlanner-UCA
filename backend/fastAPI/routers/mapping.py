## API PARA GESTIONAR LAS ASIGNATURAS ##
from fastapi import APIRouter, HTTPException, status, Response
from db.models.subject import Mapping
from db.schemas.subject import mapping_schema, mappings_schema
from db.client import db_client
from bson import ObjectId

# Definimos el router
router = APIRouter(prefix="/mapping",
                    tags=["mapping"],
                    responses={status.HTTP_404_NOT_FOUND: {"message": "Not found"}})


#Obtener todas las asignaturas
@router.get("/", response_model=list[Mapping])
async def get_subject():
    try:
        mapping_list = list(db_client.mapping.find())  # Convierte el cursor en una lista
        return mappings_schema(mapping_list)  # Aplica el schema a la lista
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")