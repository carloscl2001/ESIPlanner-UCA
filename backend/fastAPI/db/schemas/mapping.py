def mapping_schema(mapping) -> dict:
    return {
        "name": mapping["name"],
        "last_update": mapping["last_update"],
        "mapping": map_schema(mapping.get("mapping", [])),  # Aplica el esquema de clases
    }

def mappings_schema(mappings) -> list:
    return [mapping_schema(mapping) for mapping in mappings]



def map_schema(map_) -> dict:
    return {
        "code": map_["code"],
        "code_ics": map_["code_ics"],
    }
