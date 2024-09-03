from flask import Blueprint, request
from src.utils.helpers import *

goals_routes = Blueprint('goals_routes', __name__)


@goals_routes.route("/api/dog/goals/all", methods=['GET'])
def get_dog_goals_list():
    dog_id = request.args.get('dog_id')
    limit = request.args.get('limit', type=int)  # Number of activities to retrieve
    offset = request.args.get('offset', type=int)  # Number of activities to skip

    get_dog_goals_query = f"""
                        SELECT 
                        goal_id, start_date, end_date, category, 
                        current_value, target_value, done 
                        FROM {GOALS_TABLE} 
                        WHERE {DOG_ID_COLUMN} = %s
                        ORDER BY start_date DESC
                        LIMIT %s OFFSET %s;
                        """
    try:
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(get_dog_goals_query, (dog_id, limit, offset))
                list_of_goal_dicts = get_list_of_dicts_for_response(cursor)
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    if not list_of_goal_dicts: # List is empty --> no goals
        return "", HTTP_204_STATUS_NO_CONTENT
    else:
        for goal_dict in list_of_goal_dicts:
            set_goals_data_by_category(goal_dict)

    return jsonify(list_of_goal_dicts), HTTP_200_OK


@goals_routes.route("/api/dog/goals", methods=['GET'])
def get_dog_goal_log():
    goal_id = request.args.get("goal_id")
    get_dog_goal_query = f"""
                        SELECT 
                        start_date, end_date,         
                        current_value, target_value,
                        category, done
                        FROM {GOALS_TABLE}
                        WHERE {GOAL_ID_COLUMN} = %s;
                        """
    try:
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, GOALS_TABLE, GOAL_ID_COLUMN, goal_id)
                cursor.execute(get_dog_goal_query, (goal_id,))
                goal_res = get_dict_for_response(cursor)
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    set_goals_data_by_category(goal_res)

    return goal_res, HTTP_200_OK


@goals_routes.route("/api/dog/goals/add", methods=['POST'])
def add_goal_template():
    template_data = request.json

    add_goal_template_query = f"""
        INSERT INTO {GOAL_TEMPLATES_TABLE} (dog_id, target_value, frequency, category)
        VALUES (%(dog_id)s, %(target_value)s, %(frequency)s, %(category)s);
        """

    try:
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, template_data['dog_id'])
                cursor.execute(add_goal_template_query, template_data)
                create_goal(cursor, template_data)
                connection.commit()
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return "Goal template was added successfully.", HTTP_200_OK


@goals_routes.route("/api/dog/goals", methods=['DELETE'])
def delete_goal():
    goal_id = request.args.get("goal_id")
    delete_goal_query = f"DELETE FROM {GOALS_TABLE} WHERE {GOAL_ID_COLUMN} = %s;"

    try:
        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, GOALS_TABLE, GOAL_ID_COLUMN, goal_id)
                cursor.execute(delete_goal_query, (goal_id,))
                connection.commit()
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return "Goal was deleted successfully.", HTTP_200_OK
