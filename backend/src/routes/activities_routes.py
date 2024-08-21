from flask import Blueprint, request
from src.utils.helpers import *

activities_routes = Blueprint('activities_routes', __name__)


@activities_routes.route("/api/dog/activities", methods=['GET'])
def get_dog_activities_list():
    dog_id = request.args.get('dog_id')
    db = load_database_config()
    get_dog_activities_query = f"""
    SELECT * FROM {ACTIVITIES_TABLE} WHERE {DOG_ID_COLUMN} = %s;
"""

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(get_dog_activities_query, (dog_id,))
                response = get_list_of_dicts_for_response(cursor)
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    if not response:
        return "", HTTP_204_STATUS_NO_CONTENT

    return response, HTTP_200_OK


@activities_routes.route("/api/dog/activities", methods=['DELETE'])
def delete_dog_activities():
    activity_id = request.args.get("activity_id")
    delete_activities_query = f"DELETE FROM {ACTIVITIES_TABLE} WHERE {ACTIVITY_ID_COLUMN} = %s;"

    try:
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, ACTIVITIES_TABLE, ACTIVITY_ID_COLUMN, activity_id)
                cursor.execute(delete_activities_query, (activity_id,))
                connection.commit()
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return "Activity was deleted successfully.", HTTP_200_OK


