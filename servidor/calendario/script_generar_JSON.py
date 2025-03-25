import os
import json
import pypdf
import re
from datetime import datetime
from icalendar import Calendar, vDatetime


# ================================
# Funciones para procesar PDFs
# ================================

def get_attachments(reader):
    """Extrae los archivos adjuntos del PDF."""
    attachments = {}
    catalog = reader.trailer["/Root"]
    if "/Names" in catalog and "/EmbeddedFiles" in catalog["/Names"]:
        fileNames = catalog['/Names']['/EmbeddedFiles']['/Names']
        for i in range(0, len(fileNames), 2):
            name = fileNames[i].replace("/", "_")
            fDict = fileNames[i + 1].get_object()
            fData = fDict['/EF']['/F'].get_data()
            attachments[name] = fData
    
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
    """Extrae el nombre del grado de la primera página usando pypdf."""
    first_page = pdf_reader.pages[0]
    text = first_page.extract_text()
    
    if text:
        match = re.search(r'Grado en ([^\n]+)', text)
        if match:
            return match.group(1).strip()
    
    return "Desconocido"


def extract_subject_codes_from_pdf(pdf_reader):
    """Extrae los códigos de asignaturas recorriendo todas las páginas sin duplicados."""
    subject_codes = set()  # Usamos un set para evitar duplicados
    pattern = re.compile(r'\s-\s(\d{8})')  # Busca un espacio, guion, espacio seguido de 8 dígitos

    for page in pdf_reader.pages:
        text = page.extract_text()
        if text:
            matches = pattern.findall(text)
            subject_codes.update(matches)  # Añade los códigos al set para evitar duplicados

    return list(subject_codes)  # Convertimos el set a lista antes de devolverlo


def process_pdf(pdf_path):
    """Procesa el archivo PDF y extrae información relevante."""
    degree_code = os.path.splitext(os.path.basename(pdf_path))[0]
    
    with open(pdf_path, 'rb') as handler:
        reader = pypdf.PdfReader(handler)
        degree_name = extract_degree_name_from_pdf(reader)
        subject_codes = extract_subject_codes_from_pdf(reader)
        attachments = get_attachments(reader)
        
        # Guardar archivos adjuntos
        save_attachments(attachments)
        
    degree_data = {
        "code": degree_code,
        "name": degree_name,
        "subjects": [{"code": code} for code in sorted(subject_codes)]
    }
    
    return degree_data


def save_attachments(attachments):
    """Guarda los archivos adjuntos en el directorio correspondiente."""
    for fName, fData in attachments.items():
        sanitized_name = fName.replace("/", "_")
        save_path = os.path.join("archivos_adjuntos", sanitized_name)
        os.makedirs("archivos_adjuntos", exist_ok=True)
        
        with open(save_path, 'wb') as outfile:
            outfile.write(fData)


def extract_data_from_pdfs():
    """Extrae los datos de los PDFs en el directorio 'archivos_pdf' y crea los archivos JSON correspondientes."""
    pdf_dir = "archivos_pdf"
    
    # Verificar si la carpeta existe
    if not os.path.exists(pdf_dir):
        print(f"Error: No se encontró la carpeta '{pdf_dir}'.")
        return []
    
    # Listar archivos PDF en la carpeta especificada
    pdf_files = [f for f in os.listdir(pdf_dir) if f.lower().endswith('.pdf')]
    
    all_degree_data = []
    
    for pdf_file in pdf_files:
        # Construir la ruta completa al archivo PDF
        pdf_path = os.path.join(pdf_dir, pdf_file)
        degree_data = process_pdf(pdf_path)  # Pasar la ruta completa
        
        all_degree_data.append(degree_data)
        
        # Crear carpeta para almacenar los archivos JSON
        os.makedirs("archivos_grados", exist_ok=True)
        
        json_filename = os.path.join("archivos_grados", f"{degree_data['code']}.json")
        with open(json_filename, "w", encoding="utf-8") as json_file:
            json.dump(degree_data, json_file, indent=4, ensure_ascii=False)
    
    return all_degree_data


# ================================
# Funciones para procesar archivos ICS
# ================================

def parse_ics_to_json(ics_content):
    """
    Analiza el contenido del archivo ICS y lo convierte a una estructura JSON.
    """
    cal = Calendar.from_ical(ics_content)
    
    courses = {}

    def format_datetime(dt):
        """Formatea un objeto datetime a una cadena 'YYYY-MM-DD'."""
        if isinstance(dt, (datetime, vDatetime)):
            if hasattr(dt, 'tzinfo') and dt.tzinfo is not None:
                dt = dt.astimezone(dt.tzinfo).replace(tzinfo=None)
            return dt.strftime('%Y-%m-%d')
        return str(dt)
    
    def format_time(dt):
        """Formatea un objeto datetime a una cadena 'HH:MM'."""
        if isinstance(dt, (datetime, vDatetime)):
            if hasattr(dt, 'tzinfo') and dt.tzinfo is not None:
                dt = dt.astimezone(dt.tzinfo).replace(tzinfo=None)
            return dt.strftime('%H:%M')
        return str(dt)
    
    def create_event(date, start_time, end_time, location):
        return {
            "date": date,
            "start_hour": start_time,
            "end_hour": end_time,
            "location": location.strip()
        }

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
            
            # Inicializa la entrada de la asignatura si no existe
            if codigo not in courses:
                courses[codigo] = {
                    "code": codigo,
                    "name": summary,
                    "classes": []
                }
            
            # Buscar si ya existe una entrada para este tipo de clase
            class_entry = next((c for c in courses[codigo]["classes"] if c["type"] == tipo_clase), None)
            if class_entry is None:
                class_entry = {
                    "type": tipo_clase,
                    "events": []
                }
                courses[codigo]["classes"].append(class_entry)
            
            initial_event = create_event(
                format_datetime(dtstart),
                format_time(dtstart),
                format_time(dtend),
                location
            )
            
            # Añadir el evento solo si no existe
            if initial_event not in class_entry["events"]:
                class_entry["events"].append(initial_event)
            
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
    """Combina todos los archivos ICS en una única estructura JSON."""
    all_courses = {}
    
    for file_name in os.listdir(directory):
        if file_name.endswith('.ics'):
            file_path = os.path.join(directory, file_name)
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    ics_content = f.read()
                courses = parse_ics_to_json(ics_content)
                
                for code, details in courses.items():
                    if code not in all_courses:
                        all_courses[code] = details
                    else:
                        # Combinar las clases y eventos si el código ya existe
                        for class_entry in details["classes"]:
                            existing_class = next((c for c in all_courses[code]["classes"] if c["type"] == class_entry["type"]), None)
                            if existing_class:
                                for event in class_entry["events"]:
                                    if event not in existing_class["events"]:
                                        existing_class["events"].append(event)
                            else:
                                all_courses[code]["classes"].append(class_entry)
            
            except FileNotFoundError:
                print(f"Archivo no encontrado: {file_name}")
            except Exception as e:
                print(f"Error al procesar el archivo {file_name}: {e}")
    
    return all_courses


def save_json_for_each_subject(courses):
    """
    Guarda un archivo JSON para cada asignatura en la carpeta 'archivos_asignaturas'.
    """
    # Crear la carpeta 'archivos_asignaturas' si no existe
    os.makedirs('archivos_asignaturas', exist_ok=True)

    subject_codes = []

    for code, details in courses.items():
        # Guardar solo archivos JSON de asignaturas en 'archivos_asignaturas'
        output_file = os.path.join('archivos_asignaturas', f'{code}.json')
        json_output = json.dumps(details, indent=4, ensure_ascii=False)
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(json_output)
        
        subject_codes.append({"code": code})

    # Crear la carpeta 'archivos_grados' si no existe
    os.makedirs('archivos_grados', exist_ok=True)


# ================================
# Función principal
# ================================

def main():
    # Extraer y guardar los datos de los PDFs
    extract_data_from_pdfs()
    print("Se han creado los archivos JSON para los grados")
    
    # Combinar archivos ICS en una estructura JSON
    directory = './archivos_adjuntos'
    combined_courses = combine_ics_files(directory)
    
    # Guardar los JSON de las asignaturas
    save_json_for_each_subject(combined_courses)
    print("Se han creado los archivos JSON para las asignaturas")

    print("\nSCRIPT FINALIZADO")


if __name__ == "__main__":
    main()