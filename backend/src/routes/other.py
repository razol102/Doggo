from flask import Blueprint, request
from src.utils.helpers import *

other_routes = Blueprint('other_routes', __name__)


@other_routes.route("/", methods=['GET'])
def health_check():
    db = load_database_config()
    print(db)
    print("checking....")
    return "Hello, World!"


@other_routes.route("/api/user/all", methods=['GET'])
def get_all_users():
    query = "SELECT * FROM {0};".format(USERS_TABLE)
    try:
        db = load_database_config()
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(query)
                rows = cursor.fetchall()
                columns_names = [desc[0] for desc in cursor.description]
                result = [dict(zip(columns_names, row)) for row in rows]
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify(result), HTTP_200_OK


@other_routes.route("/api/dog/all", methods=['GET'])
def get_all_dogs():
    query = "SELECT * FROM {0};".format(DOGS_TABLE)
    try:
        db = load_database_config()
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(query)
                rows = cursor.fetchall()
                columns_names = [desc[0] for desc in cursor.description]
                result = []
                for row in rows:
                    row_dict = dict(zip(columns_names, row))
                    if 'image' in row_dict:
                        del row_dict['image']  # Remove the 'image' key
                    result.append(row_dict)
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify(result), HTTP_200_OK


@other_routes.route("/api/devices/battery", methods=['GET'])
def get_battery_level():
    collar_id = request.args.get('collar_id')
    db = load_database_config()
    get_battery_level_query = "SELECT battery_level FROM {0} WHERE collar_id = %s;".format(COLLARS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(get_battery_level_query, (collar_id,))
                battery_level = cursor.fetchone()
                if not battery_level:
                    raise ValueError("There is no collar with id '{0}'.".format(collar_id))
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"battery_level": battery_level[0]}), HTTP_200_OK


@other_routes.route("/api/faq/questions", methods=['GET'])
def get_faq_questions():
    db = load_database_config()
    get_questions_query = f"SELECT faq_id, question FROM {FAQ_TABLE};"

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(get_questions_query)
                faq_questions = cursor.fetchall()

                # Convert the list of tuples into a dictionary
                faq_dict = {faq_id: question for faq_id, question in faq_questions}

    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify(faq_dict), HTTP_200_OK


@other_routes.route("/api/faq/answer", methods=['GET'])
def get_faq_answer():
    faq_id = request.args.get('faq_id')
    db = load_database_config()
    get_answer_query = f"SELECT answer FROM {FAQ_TABLE} WHERE faq_id = %s;"

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(get_answer_query, (faq_id,))
                faq_answer = cursor.fetchone()[0]

    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify(faq_answer), HTTP_200_OK
