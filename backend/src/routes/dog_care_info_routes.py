from flask import request, Blueprint
from src.utils.helpers import *

dog_care_info_routes = Blueprint('dog_care_info_routes', __name__)


@dog_care_info_routes.route('/api/dog/dog_care_info', methods=['PUT'])
def add_dog_care_info():
    data = request.json
    db = load_database_config()
    dog_id = data.get("dog_id")

    update_dog_care_info_query = """ UPDATE {0}
                               SET vet_name = %(vet_name)s, vet_phone = %(vet_phone)s, vet_latitude = %(vet_latitude)s,
                               vet_longitude = %(vet_longitude)s, pension_name = %(pension_name)s,
                               pension_latitude = %(pension_latitude)s, pension_longitude = %(pension_longitude)s
                               WHERE {1} = %(dog_id)s
                               ; """.format(DOG_CARE_INFO_TABLE, DOG_ID_COLUMN)

    create_dog_care_info_query = """ INSERT INTO {0} (dog_id, vet_name, vet_phone, pension_name)
                                   VALUES (%(dog_id)s, %(vet_name)s, %(vet_phone)s, %(pension_name)s
                                   ); """.format(DOG_CARE_INFO_TABLE)
    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                if does_exist(cursor, DOG_CARE_INFO_TABLE, DOG_ID_COLUMN, dog_id):
                    cursor.execute(update_dog_care_info_query, data)
                    msg = "Dog care info record was updated"
                else:
                    cursor.execute(create_dog_care_info_query, data)
                    msg = "Dog care info record was created"
                connection.commit()
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify({"message": msg}), HTTP_200_OK


@dog_care_info_routes.route('/api/dog/dog_care_info', methods=['GET'])
def get_dog_care_info():
    dog_id = request.args.get('dog_id')
    get_dog_care_info_query = """ SELECT *
                                FROM {0}
                                WHERE {1} = %s; """.format(DOG_CARE_INFO_TABLE, DOG_ID_COLUMN)
    db = load_database_config()

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                check_if_exists(cursor, DOG_CARE_INFO_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(get_dog_care_info_query, (dog_id,))
                res = get_dict_for_response(cursor)
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify(res), HTTP_200_OK

