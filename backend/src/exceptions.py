class MissingFieldsError(Exception):
    def __init__(self, missing_fields):
        self.missing_fields = {field.replace('_',' ') for field in missing_fields}
        message = f"Missing required fields: {', '.join(self.missing_fields)}"
        super().__init__(message)
