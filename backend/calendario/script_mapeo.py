import pandas as pd
import json
import os

# Obtener la ruta del archivo actual
current_dir = os.path.dirname(os.path.abspath(__file__))

# Rutas de entrada y salida
tsv_path = os.path.join(current_dir, "asignaturasInfo.tsv")
json_output_path = os.path.join(current_dir, "mapeo.json")

# Leer el archivo TSV
df = pd.read_csv(tsv_path, sep="\t")

# Convertir a enteros (por seguridad eliminamos nulos antes)
df = df[['id', 'horarioID']].dropna()
df['id'] = df['id'].astype(int)
df['horarioID'] = df['horarioID'].astype(int)

# Crear el diccionario de mapeo
mapping = dict(zip(df['id'], df['horarioID']))

# Guardar el diccionario como JSON
with open(json_output_path, 'w') as f:
    json.dump(mapping, f, indent=4)

print(f"Archivo JSON guardado en: {json_output_path}")
