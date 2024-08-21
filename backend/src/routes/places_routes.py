from flask import Blueprint, request
from src.utils.helpers import *

places_routes = Blueprint('places_routes', __name__)


@places_routes.route("/api/places/all", methods=['GET'])
def get_all_places():
    all_places_query = "SELECT * FROM {0};".format(PLACES_TABLE)
    try:
        db = load_database_config()
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(all_places_query)
                rows = cursor.fetchall()
                columns_names = [desc[0] for desc in cursor.description]
                result = [dict(zip(columns_names, row)) for row in rows]
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify(result), HTTP_200_OK


@places_routes.route("/api/places/by_type", methods=['GET'])
def get_places_by_type():
    place_type = request.args.get('type')
    get_places_by_type_query = f"SELECT * FROM {PLACES_TABLE} WHERE type = '{place_type}';"

    try:
        db = load_database_config()
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(get_places_by_type_query)
                rows = cursor.fetchall()
                columns_names = [desc[0] for desc in cursor.description]
                result = [dict(zip(columns_names, row)) for row in rows]
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify(result), HTTP_200_OK


@places_routes.route("/api/places/favorite_by_type", methods=['PUT'])
def set_favorite_place_by_type():
    data = request.json
    required_data = {"place_name", "address", "type"}
    reset_favorite_places_query = f"UPDATE {PLACES_TABLE} SET is_favorite = FALSE WHERE type = '{data.get('type')}'"
    set_favorite_place_query = f"""
    UPDATE {PLACES_TABLE}
    SET is_favorite = TRUE
    WHERE place_name = '{data.get('place_name')}' AND address = '{data.get('address')}' AND type = '{data.get('type')}';
    """

    try:
        if not required_data.issubset(data.keys()):
            missing_fields = required_data - data.keys()
            raise MissingFieldsError(missing_fields)

        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(reset_favorite_places_query, (data.get('type')))
                cursor.execute(set_favorite_place_query, data)
                connection.commit()

    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return "", HTTP_200_OK
