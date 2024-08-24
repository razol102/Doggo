from datetime import datetime
import psycopg2
from flask import Blueprint, request, jsonify

from src.utils.config import load_database_config
from src.utils.helpers import *

activities_routes = Blueprint('activities_routes', __name__)


@activities_routes.route("/api/dog/activities/all", methods=['GET'])
def get_dog_activities_list():
    dog_id = request.args.get('dog_id')
    db = load_database_config()
    get_dog_activities_query = f"""SELECT *, 
                                TO_CHAR(duration, 'DD "days" HH24:MI:SS') AS duration,
                                ROUND(distance::numeric, 2) AS distance
                                FROM {ACTIVITIES_TABLE} WHERE {DOG_ID_COLUMN} = %s;"""

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(get_dog_activities_query, (dog_id,))
                response = get_list_of_dicts_for_response(cursor)
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST
    print(response)

    if not response:
        return "", HTTP_204_STATUS_NO_CONTENT

    return response, HTTP_200_OK


@activities_routes.route("/api/dog/activities", methods=['GET'])
def get_dog_activity_log():
    activity_id = request.args.get("activity_id")
    get_dog_activity_query = """
    SELECT start_time, end_time,         
    ROUND(distance::numeric, 2) AS distance, 
    steps, calories_burned,
    TO_CHAR(duration, 'DD "days" HH24:MI:SS') AS duration
    FROM activities
    WHERE activity_id = %s;
    """

    try:
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, ACTIVITIES_TABLE, ACTIVITY_ID_COLUMN, activity_id)
                cursor.execute(get_dog_activity_query, (activity_id,))
                dict_res = get_dict_for_response(cursor)
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    if dict_res['duration'] is None:
        dict_res['duration'] = 0


    return dict_res, HTTP_200_OK


@activities_routes.route("/api/dog/activities/end", methods=['PUT'])
def end_dog_activity():
    activity_id = request.args.get("activity_id")
    current_datetime = datetime.now()

    update_end_time_activity_query = f"""
        UPDATE {ACTIVITIES_TABLE}
        SET end_time = %s
        WHERE {ACTIVITY_ID_COLUMN} = %s
        ;"""

    update_duration_activity_query = f"""
        UPDATE {ACTIVITIES_TABLE}
        SET duration = end_time - start_time
        WHERE {ACTIVITY_ID_COLUMN} = %s
        RETURNING duration
        ;"""

    try:
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, ACTIVITIES_TABLE, ACTIVITY_ID_COLUMN, activity_id)
                cursor.execute(update_end_time_activity_query, (current_datetime, activity_id))
                cursor.execute(update_duration_activity_query, (activity_id,))
                duration = cursor.fetchone()[0]
                connection.commit()
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return str(duration), HTTP_200_OK


@activities_routes.route("/api/dog/activities", methods=['DELETE'])
def delete_dog_activity():
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


