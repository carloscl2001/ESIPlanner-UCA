
# Inicia el server: uvicorn main:app --reload
# Detener el server: CTRL+C

# Documentación con Swagger: http://127.0.0.1:8000/docs
# Documentación con Redocly: http://127.0.0.1:8000/redoc

from fastapi import FastAPI
from routers import auth
from routers import users
from routers import degrees
from routers import subjects
from routers import mapping
from routers import departments
from fastapi.middleware.cors import CORSMiddleware

# Instanciamos la aplicación
app = FastAPI()

# Incluimos los routers
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(degrees.router)
app.include_router(subjects.router)
app.include_router(mapping.router)
app.include_router(departments.router)

# Configuramos CORS (Cross-Origin Resource Sharing)
# origins = [
#     "http://localhost",          # Flutter web en desarrollo
#     "http://localhost:8000",    # Backend local
#     "http://10.182.119.113",    # Tu IP local
#     "http://10.182.119.113:8000",
#     "https://tudominio.com",    # Dominio de producción
#     "https://app.tudominio.com"
# ]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En desarrollo permite cualquier origen (en producción usa tu dominio), es decir, usar el vector origins
    allow_methods=["*"],  # Permite todos los métodos (GET, POST, etc.)
    allow_headers=["*"],  # Permite todos los headers
)

# Definimos una peticion básica
@app.get("/")
async def root():
    return "Hola FastAPI!"
