import os
import json
import pypdf
import re
from datetime import datetime
from icalendar import Calendar, vDatetime
import pandas as pd
from tqdm import tqdm  # Para la barra de progreso

# ================================
# Funciones para procesar PDFs
# ================================

def get_attachments(reader):
    """
    Extrae los archivos adjuntos del PDF.
    
    Args:
        reader: Objeto PdfReader del que extraer los adjuntos
        
    Returns:
        dict: Diccionario con nombres de archivo como clave y contenido como valor
    """
    attachments = {}
    catalog = reader.trailer["/Root"]
    
    # Buscar adjuntos en el catálogo de nombres
    if "/Names" in catalog and "/EmbeddedFiles" in catalog["/Names"]:
        fileNames = catalog['/Names']['/EmbeddedFiles']['/Names']
        for i in range(0, len(fileNames), 2):
            name = fileNames[i].replace("/", "_")
            fDict = fileNames[i + 1].get_object()
            fData = fDict['/EF']['/F'].get_data()
            attachments[name] = fData
    
    # Buscar adjuntos en anotaciones de páginas
    for page_object in reader.pages:
        if "/Annots" in page_object:
            for annot in page_object['/Annots']:
                annotobj = annot.get_object()
                if annotobj['/Subtype'] == '/FileAttachment':
                    fileobj = annotobj["/FS"]
                    sanitized_name = fileobj["/F"].replace("/", "_")
                    attachments[sanitized_name] = fileobj["/EF"]["/F"].get_data()
    return attachments


def extract_degree_name_from_pdf(pdf_reader):
    """
    Extrae el nombre del grado de la primera página del PDF.
    
    Args:
        pdf_reader: Objeto PdfReader del que extraer el nombre
        
    Returns:
        str: Nombre del grado o "Desconocido" si no se encuentra
    """
    first_page = pdf_reader.pages[0]
    text = first_page.extract_text()
    
    if text:
        match = re.search(r'Grado en ([^\n]+)', text)
        if match:
            return match.group(1).strip()
    
    return "Desconocido"


def extract_subject_codes_from_pdf(pdf_reader):
    """
    Extrae códigos de asignaturas de todas las páginas del PDF.
    
    Args:
        pdf_reader: Objeto PdfReader del que extraer los códigos
        
    Returns:
        list: Lista de códigos de asignatura únicos (sin duplicados)
    """
    subject_codes = set()
    pattern = re.compile(r'\s-\s(\d{8})')  # Patrón para códigos de 8 dígitos

    for page in pdf_reader.pages:
        text = page.extract_text()
        if text:
            matches = pattern.findall(text)
            subject_codes.update(matches)

    return list(subject_codes)


def load_mapping_file():
    """
    Carga el archivo de mapeo de códigos desde un TSV.
    
    Returns:
        dict: Diccionario con mapeo {código_asignatura: código_ics}
    """
    mapping_path = os.path.join("archivo_mapeo", "asignaturasInfo.tsv")
    if not os.path.exists(mapping_path):
        print(f"Advertencia: No se encontró el archivo de mapeo en {mapping_path}")
        return {}
    
    # Leer y procesar el archivo TSV
    df = pd.read_csv(mapping_path, sep="\t")
    df = df[['id', 'horarioID']].dropna()
    df['id'] = df['id'].astype(str)
    df['horarioID'] = df['horarioID'].astype(float).astype(int)  # Convertir a entero
    
    return dict(zip(df['id'], df['horarioID']))


def process_pdf(pdf_path, mapping_dict):
    """
    Procesa un archivo PDF y extrae información de grados y asignaturas.
    
    Args:
        pdf_path: Ruta al archivo PDF a procesar
        mapping_dict: Diccionario de mapeo de códigos
        
    Returns:
        dict: Datos estructurados del grado con sus asignaturas
    """
    degree_code = os.path.splitext(os.path.basename(pdf_path))[0]
    
    with open(pdf_path, 'rb') as handler:
        reader = pypdf.PdfReader(handler)
        degree_name = extract_degree_name_from_pdf(reader)
        subject_codes = extract_subject_codes_from_pdf(reader)
        attachments = get_attachments(reader)
        
        save_attachments(attachments)
        
    # Crear lista de asignaturas con mapeo de códigos ICS
    subjects_list = []
    for code in sorted(subject_codes):
        subject_data = {"code": code}
        if code in mapping_dict:
            subject_data["code_ics"] = int(mapping_dict[code])  # Asegurar que es entero
        subjects_list.append(subject_data)
    
    return {
        "code": degree_code,
        "name": degree_name,
        "subjects": subjects_list
    }


def save_attachments(attachments):
    """
    Guarda archivos adjuntos en el directorio 'archivos_adjuntos'.
    
    Args:
        attachments: Diccionario de archivos adjuntos {nombre: contenido}
    """
    os.makedirs("archivos_adjuntos", exist_ok=True)
    
    for fName, fData in attachments.items():
        sanitized_name = fName.replace("/", "_")
        save_path = os.path.join("archivos_adjuntos", sanitized_name)
        with open(save_path, 'wb') as outfile:
            outfile.write(fData)


def extract_data_from_pdfs(mapping_dict):
    """
    Procesa todos los PDFs en 'archivos_pdf' y genera archivos JSON.
    
    Args:
        mapping_dict: Diccionario de mapeo de códigos
        
    Returns:
        list: Lista con datos de todos los grados procesados
    """
    pdf_dir = "archivos_pdf"
    if not os.path.exists(pdf_dir):
        print(f"Error: No se encontró la carpeta '{pdf_dir}'.")
        return []
    
    pdf_files = [f for f in os.listdir(pdf_dir) if f.lower().endswith('.pdf')]
    all_degree_data = []
    os.makedirs("archivos_grados", exist_ok=True)
    
    # Barra de progreso para procesamiento de PDFs
    with tqdm(pdf_files, desc="Procesando PDFs", unit="archivo") as pbar:
        for pdf_file in pbar:
            pdf_path = os.path.join(pdf_dir, pdf_file)
            degree_data = process_pdf(pdf_path, mapping_dict)
            all_degree_data.append(degree_data)
            
            # Actualizar descripción de la barra de progreso
            pbar.set_postfix(grado=degree_data['code'])
            
            # Guardar JSON individual para cada grado
            json_filename = os.path.join("archivos_grados", f"{degree_data['code']}.json")
            with open(json_filename, "w", encoding="utf-8") as json_file:
                json.dump(degree_data, json_file, indent=4, ensure_ascii=False)
    
    return all_degree_data


# ================================
# Funciones para procesar archivos ICS
# ================================

def parse_ics_to_json(ics_content):
    """
    Convierte contenido ICS a estructura JSON.
    
    Args:
        ics_content: Cadena con contenido del archivo ICS
        
    Returns:
        dict: Datos de cursos estructurados
    """
    cal = Calendar.from_ical(ics_content)
    courses = {}

    def format_datetime(dt):
        """Formatea datetime a 'YYYY-MM-DD'."""
        if isinstance(dt, (datetime, vDatetime)):
            if hasattr(dt, 'tzinfo') and dt.tzinfo is not None:
                dt = dt.astimezone(dt.tzinfo).replace(tzinfo=None)
            return dt.strftime('%Y-%m-%d')
        return str(dt)
    
    def format_time(dt):
        """Formatea datetime a 'HH:MM'."""
        if isinstance(dt, (datetime, vDatetime)):
            if hasattr(dt, 'tzinfo') and dt.tzinfo is not None:
                dt = dt.astimezone(dt.tzinfo).replace(tzinfo=None)
            return dt.strftime('%H:%M')
        return str(dt)
    
    def create_event(date, start_time, end_time, location):
        """Crea estructura de evento."""
        return {
            "date": date,
            "start_hour": start_time,
            "end_hour": end_time,
            "location": location.strip()
        }

    # Procesar cada evento en el calendario
    for component in cal.walk():
        if component.name == "VEVENT":
            location = component.get('location', 'No Location')
            uid = component.get('uid', 'No UID')
            dtstart = component.get('dtstart').dt
            dtend = component.get('dtend').dt
            
            full_summary = component.get('summary', 'Sin Título')
            summary = full_summary.split('-')[0].strip()

            uid_parts = uid.split('.')
            codigo = uid_parts[0].strip() if len(uid_parts) > 0 else 'Unknown'
            tipo_clase = uid_parts[1].strip() if len(uid_parts) > 1 else 'Unknown'
            
            # Inicializar estructura del curso si no existe
            if codigo not in courses:
                courses[codigo] = {
                    "code": codigo,
                    "name": summary,
                    "classes": []
                }
            
            # Buscar o crear entrada para este tipo de clase
            class_entry = next((c for c in courses[codigo]["classes"] if c["type"] == tipo_clase), None)
            if class_entry is None:
                class_entry = {"type": tipo_clase, "events": []}
                courses[codigo]["classes"].append(class_entry)
            
            # Añadir evento inicial
            initial_event = create_event(
                format_datetime(dtstart),
                format_time(dtstart),
                format_time(dtend),
                location
            )
            
            if initial_event not in class_entry["events"]:
                class_entry["events"].append(initial_event)
            
            # Procesar eventos recurrentes
            rdates = component.get('rdate', [])
            if not isinstance(rdates, list):
                rdates = [rdates]
            
            for rdate in rdates:
                if hasattr(rdate, 'dts'):
                    for date in rdate.dts:
                        recurrent_event = create_event(
                            format_datetime(date.dt),
                            format_time(dtstart),
                            format_time(dtend),
                            location
                        )
                        if recurrent_event not in class_entry["events"]:
                            class_entry["events"].append(recurrent_event)
                elif hasattr(rdate, 'dt'):
                    recurrent_event = create_event(
                        format_datetime(rdate.dt),
                        format_time(dtstart),
                        format_time(dtend),
                        location
                    )
                    if recurrent_event not in class_entry["events"]:
                        class_entry["events"].append(recurrent_event)
    
    return courses


def combine_ics_files(directory):
    """
    Combina múltiples archivos ICS en una única estructura.
    
    Args:
        directory: Directorio que contiene archivos ICS
        
    Returns:
        dict: Todos los cursos combinados de todos los archivos
    """
    all_courses = {}
    ics_files = [f for f in os.listdir(directory) if f.endswith('.ics')]
    
    # Barra de progreso para procesamiento de ICS
    with tqdm(ics_files, desc="Procesando ICS", unit="archivo") as pbar:
        for file_name in pbar:
            file_path = os.path.join(directory, file_name)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    ics_content = f.read()
                courses = parse_ics_to_json(ics_content)
                
                # Combinar cursos
                for code, details in courses.items():
                    if code not in all_courses:
                        all_courses[code] = details
                    else:
                        # Combinar clases duplicadas
                        for class_entry in details["classes"]:
                            existing_class = next(
                                (c for c in all_courses[code]["classes"] 
                                 if c["type"] == class_entry["type"]), 
                                None
                            )
                            if existing_class:
                                # Añadir eventos nuevos
                                for event in class_entry["events"]:
                                    if event not in existing_class["events"]:
                                        existing_class["events"].append(event)
                            else:
                                all_courses[code]["classes"].append(class_entry)
                
                pbar.set_postfix(archivo=file_name)
            
            except Exception as e:
                print(f"\nError al procesar {file_name}: {e}")
    
    return all_courses


def save_json_for_each_subject(courses):
    """
    Guarda un JSON por cada asignatura en 'archivos_asignaturas'.
    
    Args:
        courses: Diccionario con todos los cursos procesados
    """
    os.makedirs('archivos_asignaturas', exist_ok=True)
    
    # Barra de progreso para guardado de JSONs
    with tqdm(courses.items(), desc="Guardando asignaturas", unit="asignatura") as pbar:
        for code, details in pbar:
            output_file = os.path.join('archivos_asignaturas', f'{code}.json')
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(details, f, indent=4, ensure_ascii=False)
            pbar.set_postfix(codigo=code)


# ================================
# Función principal
# ================================

def main():
    print("=== INICIO DEL PROCESO ===")
    
    # 1. Cargar mapeo de códigos
    print("\nCargando mapeo de códigos...")
    mapping_dict = load_mapping_file()
    
    # 2. Procesar PDFs
    print("\nProcesando archivos PDF...")
    extract_data_from_pdfs(mapping_dict)
    
    # 3. Procesar archivos ICS adjuntos
    print("\nProcesando archivos ICS...")
    directory = './archivos_adjuntos'
    if os.path.exists(directory):
        combined_courses = combine_ics_files(directory)
        save_json_for_each_subject(combined_courses)
    else:
        print(f"Directorio {directory} no encontrado. Omitiendo procesamiento ICS.")
    
    print("\n=== PROCESO COMPLETADO ===")


if __name__ == "__main__":
    main()