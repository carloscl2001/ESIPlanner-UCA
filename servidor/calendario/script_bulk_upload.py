#!/usr/bin/env python3
import json
import os
from datetime import datetime
from pymongo.errors import BulkWriteError
from tqdm import tqdm
import sys
from pathlib import Path

# Añade el directorio servidor al path
servidor_path = Path(__file__).parent.parent  # Sube a /servidor
sys.path.append(str(servidor_path))

# Ahora importa normalmente
from fastAPI.db.client import db_client


class ConsoleOutput:
    """Maneja la salida a consola con símbolos compatibles"""
    @staticmethod
    def print_header(title):
        print("\n" + "-"*60)
        print(title.center(60))
        print("-"*60)

    @staticmethod
    def print_header_final(title):
        print("\n" + "="*60)
        print(title.center(60))
        print("="*60)
    
    
    @staticmethod
    def print_step(message):
        print(f"\n>> {message}")
    
    @staticmethod
    def print_success(message):
        print(f"[OK] {message}")
    
    @staticmethod
    def print_warning(message):
        print(f"[!] {message}")
    
    @staticmethod
    def print_deletion(message):
        print(f"[DEL] {message}")

def process_folder(folder_path: str, collection_name: str):
    """Procesa una carpeta mostrando claramente cada paso"""
    try:
        if not os.path.exists(folder_path):
            ConsoleOutput.print_warning(f"Carpeta no encontrada: {folder_path}")
            return 0

        files = [f for f in os.listdir(folder_path) if f.endswith('.json')]
        if not files:
            ConsoleOutput.print_warning(f"No hay archivos JSON en {folder_path}")
            return 0

        ConsoleOutput.print_step(f"PROCESANDO: desde {folder_path} -> coleccion {collection_name}")
        
        # 1. Borrado completo con confirmación clara
        count_before = db_client[collection_name].estimated_document_count()
        db_client[collection_name].delete_many({})
        count_after = db_client[collection_name].estimated_document_count()
        
        ConsoleOutput.print_deletion(
            f"COLECCION BORRADA: {collection_name} | " +
            f"Eliminados: {count_before} | " +
            f"Restantes: {count_after}"
        )
        
        total_inserted = 0
        
        # 2. Procesamiento con barra de progreso
        for filename in tqdm(files, desc=f"Loading {collection_name[:12]}".ljust(20),
                           bar_format="{desc}: {percentage:3.0f}%|{bar}| {n_fmt}/{total_fmt} [Elapsed: {elapsed}]",
                           file=sys.stdout):
            filepath = os.path.join(folder_path, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    
                    if isinstance(data, list):
                        result = db_client[collection_name].insert_many(data)
                        total_inserted += len(result.inserted_ids)
                    else:
                        result = db_client[collection_name].insert_one(data)
                        total_inserted += 1
                        
            except Exception as e:
                ConsoleOutput.print_warning(f"Error en {filename}: {str(e)}")
                continue
        
        ConsoleOutput.print_success(
            f"CARGA EXITOSA: {collection_name} | " +
            f"Insertados: {total_inserted}"
        )
        return total_inserted
        
    except Exception as e:
        ConsoleOutput.print_warning(f"ERROR: {str(e)}")
        raise

if __name__ == "__main__":
    try:
        FOLDER_CONFIG = {
            'archivos_asignaturas': 'subjects',
            'archivos_grados': 'degrees'
        }
        
        start_time = datetime.now()
        ConsoleOutput.print_header("INICIO DE CARGA MASIVA")
        
        total_docs = 0
        for folder, collection in FOLDER_CONFIG.items():
            docs = process_folder(folder, collection)
            total_docs += docs if docs else 0
        
        duration = (datetime.now() - start_time).total_seconds()
        ConsoleOutput.print_header("RESUMEN DE CARGA")
        
        print(f"\n{'Tiempo total:':<20}{duration:>10.2f} segundos")
        print(f"{'Total documentos:':<20}{total_docs:>10}")
        
        print("\nDocumentos en MongoDB:")
        for collection in sorted(FOLDER_CONFIG.values()):
            count = db_client[collection].estimated_document_count()
            print(f"  {collection+':':<15}{count:>10}")
            
    except Exception as e:
        ConsoleOutput.print_warning(f"ERROR GRAVE: {str(e)}")
    finally:
        ConsoleOutput.print_header_final("FIN DEL PROCESO")