def mapping_schema(mapping) -> dict:
    return {
        "name": mapping["code"],
        "last_update": mapping["last_update"],
        "mapping": map_schema(mapping.get("mapping", [])),  # Aplica el esquema de clases
    }

def mappings_schema(mapping) -> list:
    return [mapping_schema(mapping) for mapping in mapping]



def map_schema(map_) -> dict:
    return {
        "code": map_["code"],
        "code_ics": map_["code_ics"],
    }

def maps_schema(maps_) -> list:
    return [map_schema(map_) for map_ in maps_]

