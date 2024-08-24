import psycopg2
from flask import Blueprint, request, jsonify

from src.utils.config import load_database_config
from src.utils.helpers import *

medical_records_routes = Blueprint('medical_records_routes', __name__)


@medical_records_routes.route('/api/dog/medical_records', methods=['GET'])
def get_medical_records():
    dog_id = request.args.get('dog_id')
    db = load_database_config()
    get_dog_medical_records_query = f"""
        SELECT {MEDICAL_RECORD_ID_COLUMN}, vet_name, address, record_datetime, description
        FROM {MEDICAL_RECORDS_TABLE}
        WHERE {DOG_ID_COLUMN} = %s;
    """
    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(get_dog_medical_records_query, (dog_id,))
                dict_response = get_list_of_dicts_for_response(cursor)
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    if not dict_response:
        return "", HTTP_204_STATUS_NO_CONTENT

    return dict_response, HTTP_200_OK


@medical_records_routes.route("/api/dog/medical_records", methods=['POST'])
def add_dog_medical_record():
    data = request.json
    required_data = {"dog_id", "vet_name", "address", "record_datetime", "description"}

    add_medical_record_query = f"""
        INSERT INTO {MEDICAL_RECORDS_TABLE} 
        (dog_id, vet_name, address, record_datetime, description)
        VALUES 
        (%(dog_id)s, %(vet_name)s, %(address)s, %(record_datetime)s, %(description)s)
        RETURNING {MEDICAL_RECORD_ID_COLUMN};
    """

    try:
        if not required_data.issubset(data.keys()):
            missing_fields = required_data - data.keys()
            raise MissingFieldsError(missing_fields)

        dog_id = data.get("dog_id")
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(add_medical_record_query, data)
                new_record_id = cursor.fetchone()[0]
                connection.commit()
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return {"medical_record_id": new_record_id}, HTTP_201_CREATED


@medical_records_routes.route("/api/dog/medical_records", methods=['PUT'])
def update_dog_medical_record():
    data = request.json
    required_data = {"record_id", "vet_name", "address", "record_datetime", "description"}

    update_medical_record_query = f"""
        UPDATE {MEDICAL_RECORDS_TABLE} 
        SET vet_name = %(vet_name)s,
        address = %(address)s,
        record_datetime = %(record_datetime)s,
        description = %(description)s
        WHERE {MEDICAL_RECORD_ID_COLUMN} = %(record_id)s;
    """

    try:
        if not required_data.issubset(data.keys()):
            missing_fields = required_data - data.keys()
            raise MissingFieldsError(missing_fields)

        record_id = data.get("record_id")
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, MEDICAL_RECORDS_TABLE, MEDICAL_RECORD_ID_COLUMN, record_id)
                cursor.execute(update_medical_record_query, data)
                connection.commit()
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return "medical record was updated successfully.", HTTP_200_OK


@medical_records_routes.route("/api/dog/medical_records", methods=['DELETE'])
def delete_dog_medical_record():
    record_id = request.args.get("record_id")

    delete_medical_record_query = f"""
                                DELETE FROM {MEDICAL_RECORDS_TABLE}
                                WHERE {MEDICAL_RECORD_ID_COLUMN} = %s;
                                """
    try:
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, MEDICAL_RECORDS_TABLE, MEDICAL_RECORD_ID_COLUMN, record_id)
                cursor.execute(delete_medical_record_query, (record_id,))
                connection.commit()
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return "medical record was deleted successfully.", HTTP_200_OK
