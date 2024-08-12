from flask import request, Blueprint
from src.utils.helpers import *

collar_routes = Blueprint('collar_routes', __name__)


@collar_routes.route("/api/collar/add", methods=['PUT'])
def add_collar():
    data = request.json
    collar_id = data.get("collar_id")
    dog_id = data.get("dog_id")
    attach_dog_collar_query = """ UPDATE {0}
                                  SET dog_id = %s
                                  WHERE collar_id = %s; """.format(COLLARS_TABLE)
    db = load_database_config()

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                check_if_exists(cursor, COLLARS_TABLE, COLLAR_ID_COLUMN, collar_id)
                cursor.execute(attach_dog_collar_query, (dog_id, collar_id))
                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "Collar {0} connected to dog {1}".format(collar_id, dog_id)}), HTTP_200_OK


@collar_routes.route("/api/collar/get", methods=['GET'])
def get_collar_id_by_dog_id():
    dog_id = request.args.get('dog_id')
    db = load_database_config()
    get_collar_id_query = "SELECT collar_id FROM {0} WHERE dog_id = %s;".format(COLLARS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(get_collar_id_query, (dog_id,))
                collar_id = cursor.fetchone()
                if not collar_id:
                    raise ValueError("There is no collar attached to this dog.")
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"collar_id": collar_id[0]}), HTTP_200_OK
