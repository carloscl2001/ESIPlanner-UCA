def department_schema(department) -> dict:
    return {
        "code": department["code"],
        "name": department["name"],
    }

def departments_schema(departments) -> list:
    return [department_schema(department) for department in departments]