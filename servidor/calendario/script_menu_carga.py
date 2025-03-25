#!/usr/bin/env python3
import json
import os
from datetime import datetime
from pymongo.errors import BulkWriteError
from tqdm import tqdm
import sys
from pathlib import Path

# Configuración de paths
servidor_path = Path(__file__).parent.parent  # Sube a /servidor
sys.path.append(str(servidor_path))
from fastAPI.db.client import db_client

# Variable global para almacenar archivos cargados
loaded_files = {
    'subjects': set(),
    'degrees': set()
}

class ConsoleOutput:
    """Clase para manejar la salida a consola"""
    @staticmethod
    def print_header(title):
        print("\n" + "="*60)
        print(title.center(60))
        print("="*60)

    def print_header_processing(title):
        print("\n" + "_"*60)
        print(title.center(60))
        print("_"*60)

    def print_finish(title1, title2):
        print("\n" + "="*60)
        print(title1.center(60))
        print(title2.center(60))
        print("="*60)
    
    @staticmethod
    def print_menu(title, options):
        print("\n" + "-"*60)
        print(title.center(60))
        print("-"*60)
        for key, option in options.items():
            print(f" {key}. {option['label']}")
        print("-"*60)
    
    @staticmethod
    def print_success(message):
        print(f"[EXITO] {message}")
    
    @staticmethod
    def print_warning(message):
        print(f"[!] {message}")
    
    @staticmethod
    def print_info(message):
        print(f"[i] {message}")

def show_menu():
    """Muestra el menú principal y maneja la selección"""
    menu_options = {
        '1': {
            'label': 'Carga completa de todos los archivos (borrar e insertar)',
            'action': full_clean_load
        },
        '2': {
            'label': 'Carga adicional de archivos específicos (sobreescribir)',
            'action': additional_load_menu
        },
        '3': {
            'label': 'Ver estadísticas detalladas',
            'action': show_detailed_stats
        },
        '4': {
            'label': 'Salir',
            'action': exit_program
        }
    }
    
    while True:
        ConsoleOutput.print_menu("GESTOR DE CARGA DE DATOS", menu_options)
        choice = input("Seleccione una opción (1-4): ")
        
        if choice in menu_options:
            menu_options[choice]['action']()
        else:
            ConsoleOutput.print_warning("Opción no válida. Intente nuevamente.")

def full_clean_load():
    """Borra toda la colección y realiza una carga nueva"""
    ConsoleOutput.print_header("REALIZANDO CARGA COMPLETA (BORRAR TODO E INSERTAR)")
    
    FOLDER_CONFIG = {
        'archivos_asignaturas': 'subjects',
        'archivos_grados': 'degrees'
    }
    
    start_time = datetime.now()
    total_docs = 0
    
    # Limpiar registro de archivos cargados
    global loaded_files
    loaded_files = {'subjects': set(), 'degrees': set()}
    
    for folder, collection in FOLDER_CONFIG.items():
        if not os.path.exists(folder):
            ConsoleOutput.print_warning(f"Carpeta no encontrada: {folder}")
            continue

        files = [f for f in os.listdir(folder) if f.endswith('.json')]
        if not files:
            ConsoleOutput.print_warning(f"No hay archivos JSON en {folder}")
            continue

        ConsoleOutput.print_header_processing(f"PROCESANDO: {folder} -> {collection}")

        
        # 1. Borrado completo
        count_before = db_client[collection].estimated_document_count()
        db_client[collection].delete_many({})
        ConsoleOutput.print_success(f"Colección {collection} borrada. Documentos eliminados: {count_before}")
        
        # 2. Carga de archivos
        inserted = 0
        for filename in tqdm(files, desc=f"Cargando {collection}"):
            loaded_files[collection].add(filename)  # Registrar archivo cargado
            filepath = os.path.join(folder, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    
                    if isinstance(data, list):
                        result = db_client[collection].insert_many(data)
                        inserted += len(result.inserted_ids)
                    else:
                        result = db_client[collection].insert_one(data)
                        inserted += 1
            except Exception as e:
                ConsoleOutput.print_warning(f"Error en {filename}: {str(e)}")
                continue
        
        total_docs += inserted
        ConsoleOutput.print_success(f"Documentos insertados en {collection}: {inserted}")
    
    duration = (datetime.now() - start_time).total_seconds()
    ConsoleOutput.print_finish(f"CARGA COMPLETA FINALIZADA en {duration:.2f} segundos", f"Total documentos insertados: {total_docs}")

def additional_load_menu():
    """Menú para carga adicional de archivos específicos"""
    while True:
        # Opciones del submenú
        submenu_options = {
            '1': {
                'label': 'Añadir asignaturas',
                'action': lambda: process_custom_files('archivos_asignaturas', 'subjects')
            },
            '2': {
                'label': 'Añadir grados',
                'action': lambda: process_custom_files('archivos_grados', 'degrees')
            },
            '3': {
                'label': 'Volver al menú principal',
                'action': lambda: None
            }
        }
        
        # Mostrar el submenú con el mismo formato que el menú principal
        ConsoleOutput.print_menu("CARGA ADICIONAL DE ARCHIVOS ESPECIFICOS", submenu_options)
        choice = input("Seleccione una opción (1-3): ")
        
        if choice in submenu_options:
            if choice == '3':
                return  # Salir del submenú
            submenu_options[choice]['action']()
        else:
            ConsoleOutput.print_warning("Opción no válida. Intente nuevamente.")

def process_custom_files(folder_path: str, collection_name: str):
    """Procesa archivos específicos y registra los nombres"""
    try:
        if not os.path.exists(folder_path):
            ConsoleOutput.print_warning(f"Carpeta no encontrada: {folder_path}")
            return

        available_files = [f for f in os.listdir(folder_path) if f.endswith('.json')]
        if not available_files:
            ConsoleOutput.print_warning(f"No hay archivos JSON en {folder_path}")
            return

        ConsoleOutput.print_info("\nArchivos disponibles:")
        for i, filename in enumerate(available_files, 1):
            print(f" {i}. {filename}")
        
        file_input = input("\nIngrese los números o nombres de los archivos a cargar (separados por espacios): ")
        
        selected_files = []
        for item in file_input.split():
            if item.isdigit():
                index = int(item) - 1
                if 0 <= index < len(available_files):
                    selected_files.append(available_files[index])
            else:
                if item in available_files:
                    selected_files.append(item)
        
        if not selected_files:
            ConsoleOutput.print_warning("No se seleccionaron archivos válidos")
            return

        ConsoleOutput.print_header(f"PROCESANDO {len(selected_files)} ARCHIVOS EN {collection_name}")
        
        current_count = db_client[collection_name].estimated_document_count()
        ConsoleOutput.print_info(f"Documentos actuales en {collection_name}: {current_count}")
        
        total_inserted = 0
        duplicates = 0
        
        for filename in selected_files:
            loaded_files[collection_name].add(filename)  # Registrar archivo cargado
            filepath = os.path.join(folder_path, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    
                    if isinstance(data, list):
                        for doc in data:
                            try:
                                result = db_client[collection_name].update_one(
                                    {'_id': doc.get('_id')},
                                    {'$set': doc},
                                    upsert=True
                                )
                                if result.upserted_id:
                                    total_inserted += 1
                                else:
                                    duplicates += 1
                            except Exception as e:
                                ConsoleOutput.print_warning(f"Error en documento: {str(e)}")
                    else:
                        try:
                            result = db_client[collection_name].update_one(
                                {'_id': data.get('_id')},
                                {'$set': data},
                                upsert=True
                            )
                            if result.upserted_id:
                                total_inserted += 1
                            else:
                                duplicates += 1
                        except Exception as e:
                            ConsoleOutput.print_warning(f"Error en documento: {str(e)}")
                            
            except Exception as e:
                ConsoleOutput.print_warning(f"Error procesando {filename}: {str(e)}")
                continue
        
        ConsoleOutput.print_success(f"\nResumen de la carga:")
        ConsoleOutput.print_success(f"- Documentos nuevos insertados: {total_inserted}")
        ConsoleOutput.print_success(f"- Documentos actualizados: {duplicates}")
        
        new_count = db_client[collection_name].estimated_document_count()
        ConsoleOutput.print_success(f"Total documentos en {collection_name}: {new_count}")
        
    except Exception as e:
        ConsoleOutput.print_warning(f"Error: {str(e)}")

def full_overwrite_load():
    """Realiza una carga completa borrando todo lo existente"""
    ConsoleOutput.print_header("CARGA COMPLETA (SOBREESCRIBIR TODO)")
    
    FOLDER_CONFIG = {
        'archivos_asignaturas': 'subjects',
        'archivos_grados': 'degrees'
    }
    
    start_time = datetime.now()
    total_docs = 0
    
    # Limpiar registro de archivos cargados
    global loaded_files
    loaded_files = {'subjects': set(), 'degrees': set()}
    
    for folder, collection in FOLDER_CONFIG.items():
        if not os.path.exists(folder):
            ConsoleOutput.print_warning(f"Carpeta no encontrada: {folder}")
            continue

        files = [f for f in os.listdir(folder) if f.endswith('.json')]
        if not files:
            ConsoleOutput.print_warning(f"No hay archivos JSON en {folder}")
            continue

        ConsoleOutput.print_header(f"SOBREESCRIBIENDO: {folder} -> {collection}")
        
        # 1. Borrado completo
        count_before = db_client[collection].estimated_document_count()
        db_client[collection].delete_many({})
        ConsoleOutput.print_success(f"Colección {collection} borrada. Documentos eliminados: {count_before}")
        
        # 2. Carga de archivos
        inserted = 0
        for filename in files:
            loaded_files[collection].add(filename)  # Registrar archivo cargado
            filepath = os.path.join(folder, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    
                    if isinstance(data, list):
                        result = db_client[collection].insert_many(data)
                        inserted += len(result.inserted_ids)
                    else:
                        result = db_client[collection].insert_one(data)
                        inserted += 1
            except Exception as e:
                ConsoleOutput.print_warning(f"Error en {filename}: {str(e)}")
                continue
        
        total_docs += inserted
        ConsoleOutput.print_success(f"Documentos insertados en {collection}: {inserted}")
    
    duration = (datetime.now() - start_time).total_seconds()
    ConsoleOutput.print_success(f"\nCarga completada en {duration:.2f} segundos")
    ConsoleOutput.print_success(f"Total documentos insertados: {total_docs}")

def show_detailed_stats():
    """Muestra estadísticas detalladas incluyendo archivos cargados"""
    ConsoleOutput.print_header("ESTADÍSTICAS DETALLADAS")
    collections = {
        'subjects': 'Asignaturas',
        'degrees': 'Grados'
    }
    
    print("\nDocumentos en MongoDB:")
    for col, name in collections.items():
        try:
            count = db_client[col].estimated_document_count()
            print(f"  {name+':':<15}{count:>10}")
            
            # Mostrar archivos cargados para esta colección
            if loaded_files[col]:
                print(f"  Archivos cargados ({len(loaded_files[col])}):")
                for i, filename in enumerate(sorted(loaded_files[col]), 1):
                    print(f"    {i}. {filename}")
            else:
                print("  Ningún archivo cargado recientemente")
                
        except Exception as e:
            ConsoleOutput.print_warning(f"No se pudo acceder a la colección {col}: {str(e)}")

def exit_program():
    """Sale del programa"""
    ConsoleOutput.print_header("FIN DEL PROGRAMA")
    sys.exit(0)

if __name__ == "__main__":
    try:
        show_menu()
    except KeyboardInterrupt:
        ConsoleOutput.print_warning("\nOperación cancelada por el usuario")
    except Exception as e:
        ConsoleOutput.print_warning(f"Error inesperado: {str(e)}")
    finally:
        ConsoleOutput.print_header("SESIÓN TERMINADA")