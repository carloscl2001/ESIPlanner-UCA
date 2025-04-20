def mapping_schema(mapping) -> dict:
    return {
        "name": mapping["name"],
        "last_update": mapping["last_update"],
        "mapping": [map_schema(item) for item in mapping.get("mapping", [])],  # Aplica map_schema a cada elemento
    }

def mappings_schema(mappings) -> list:
    return [mapping_schema(mapping) for mapping in mappings]



def map_schema(map_) -> dict:
    return {
        "code": map_["code"],
        "code_ics": map_["code_ics"],
    }
