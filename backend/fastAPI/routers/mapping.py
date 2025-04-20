## API PARA GESTIONAR LAS ASIGNATURAS ##
from fastapi import APIRouter, HTTPException, status
from db.models.mapping import Mapping
from db.schemas.mapping import mappings_schema
from db.client import db_client

# Definimos el router
router = APIRouter(prefix="/mappings",
                    tags=["mappings"],
                    responses={status.HTTP_404_NOT_FOUND: {"message": "Not found"}})


# Obtener todas los mapeos de asignaturas
@router.get("/", response_model=list[Mapping])
async def get_Mapping():
    try:
        mappings_list = list(db_client.mapping.find())  # Convierte el cursor en una lista
        return mappings_schema(mappings_list)  # Aplica el schema a la lista
    except Exception as e:
        raise HTTPException(status_code=500, detail="Internal Server Error")