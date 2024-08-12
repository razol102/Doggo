from flask import request, Blueprint
from src.utils.helpers import *

medical_routes = Blueprint('medical_routes', __name__)


@medical_routes.route('/api/dog/medical_record', methods=['PUT'])
def add_medical_record():
    data = request.json
    db = load_database_config()
    dog_id = data.get("dog_id")

    update_medical_record_query = """ UPDATE {0}
                               SET vet_name = %(vet_name)s, vet_phone = %(vet_phone)s, vet_latitude = %(vet_latitude)s,
                               vet_longitude = %(vet_longitude)s, pension_name = %(pension_name)s,
                               pension_latitude = %(pension_latitude)s, pension_longitude = %(pension_longitude)s
                               WHERE {1} = %(dog_id)s
                               ; """.format(MEDICAL_RECORDS_TABLE, DOG_ID_COLUMN)

    create_medical_record_query = """ INSERT INTO {0} (dog_id, vet_name, vet_phone, pension_name)
                                   VALUES (%(dog_id)s, %(vet_name)s, %(vet_phone)s, %(pension_name)s
                                   ); """.format(MEDICAL_RECORDS_TABLE)
    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                if does_exist(cursor, MEDICAL_RECORDS_TABLE, DOG_ID_COLUMN, dog_id):
                    cursor.execute(update_medical_record_query, data)
                    msg = "Medical record was updated"
                else:
                    cursor.execute(create_medical_record_query, data)
                    msg = "Medical record was created"
                connection.commit()
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify({"message": msg}), HTTP_200_OK


@medical_routes.route('/api/dog/medical_record', methods=['GET'])
def get_medical_record():
    dog_id = request.args.get('dog_id')
    get_medical_query = """ SELECT *
                                FROM {0}
                                WHERE {1} = %s; """.format(MEDICAL_RECORDS_TABLE, DOG_ID_COLUMN)
    db = load_database_config()

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                check_if_exists(cursor, MEDICAL_RECORDS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(get_medical_query, (dog_id,))
                res = get_dict_for_response(cursor)
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify(res), HTTP_200_OK

