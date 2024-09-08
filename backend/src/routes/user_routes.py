import psycopg2
from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash

from src.utils.config import load_database_config
from src.utils.helpers import *

user_routes = Blueprint('user_routes', __name__)


@user_routes.route('/api/user/register', methods=['POST'])
def register_user():
    data = request.json
    required_data = {"email", "password", "name", "date_of_birth", "phone_number"}

    email_query = "SELECT COUNT(*) FROM users WHERE email = %s"
    phone_number_query = "SELECT COUNT(*) FROM users WHERE phone_number = %s"
    adding_new_user_query = f"""
                                    INSERT INTO {USERS_TABLE} 
                                    (email, password, name, date_of_birth, phone_number) VALUES 
                                    (%(email)s, %(password)s, %(name)s, %(date_of_birth)s, %(phone_number)s)
                                    RETURNING user_id;
                                    """

    try:
        if not required_data.issubset(data.keys()):
            missing_fields = required_data - data.keys()
            raise MissingFieldsError(missing_fields)

        db = load_database_config()

        data['password'] = generate_password_hash(data['password'])

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                if is_in_use(cursor, email_query, data.get('email')):
                    raise Exception("Email is already in use.")
                elif is_in_use(cursor, phone_number_query, data.get('phone_number')):
                    raise Exception("Phone number is already in use.")
                cursor.execute(adding_new_user_query, data)
                user_id = cursor.fetchone()[0]
                connection.commit()
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify({"user_id": user_id}), HTTP_201_CREATED


@user_routes.route('/api/user/login', methods=['PUT'])
def login():
    data = request.json
    email_from_user = data.get('email')
    password_from_user = data.get('password')
    db = load_database_config()
    logging_in_query = """ UPDATE users
                           SET logged_in = TRUE
                           WHERE email = %s; """
    try:
        check_email_and_password_from_user(email_from_user, password_from_user)
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT user_id, password FROM {0} WHERE email = %s".format(USERS_TABLE),
                               (email_from_user,))
                user_data = cursor.fetchone()
                if user_data is None:
                    raise ValueError("User does not exist.")
                elif check_password_hash(user_data[1], password_from_user):
                    raise ValueError("Incorrect password.")
                else:
                    cursor.execute(logging_in_query, (email_from_user,))
                    connection.commit()
                    user_id = user_data[0]
                    cursor.execute("SELECT dog_id FROM {0} WHERE user_id = %s".format(USERS_DOGS_TABLE), (user_id,))
                    dog_id = cursor.fetchone()[0]
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify({"user_id": user_id, "dog_id": dog_id}), HTTP_200_OK


@user_routes.route('/api/user/logout', methods=['PUT'])
def logout():
    user_id = request.args.get('user_id')
    db = load_database_config()
    logging_out_query = """ UPDATE {0}
                        SET last_activity = NOW(), logged_in = FALSE
                        WHERE user_id = %s; """.format(USERS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, USERS_TABLE, USER_ID_COLUMN, user_id)
                cursor.execute(logging_out_query, (user_id,))
                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    print("{0} is logged out!".format(user_id))

    return jsonify({"message": "You're logged out!"}), HTTP_200_OK


@user_routes.route('/api/user/profile', methods=['GET'])
def get_user_info():
    user_id = request.args.get('user_id')
    db = load_database_config()
    get_details_query = "SELECT email, password, name, date_of_birth, phone_number FROM {0} WHERE user_id = %s;".format(
        USERS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(get_details_query, (user_id,))
                user_details = cursor.fetchone()
                if not user_details:
                    raise ValueError("User does not exist.")
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    user_data = {
        "email": user_details[0],
        "password": user_details[1],
        "name": user_details[2],
        "date_of_birth": user_details[3],
        "phone_number": user_details[4]
    }

    return jsonify(user_data), HTTP_200_OK


@user_routes.route('/api/user/profile', methods=['PUT'])
def update_user_info():
    data = request.json
    user_id = data.get("user_id")
    db = load_database_config()

    update_details_query = """
                            UPDATE {0}
                            SET email = %(email)s, password = %(password)s, name = %(name)s,
                            date_of_birth = %(date_of_birth)s, phone_number = %(phone_number)s
                            WHERE user_id = %(user_id)s;
                            """.format(USERS_TABLE)
    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, USERS_TABLE, USER_ID_COLUMN, user_id)
                cursor.execute(update_details_query, data)
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "Profile is updated!"}), HTTP_200_OK


@user_routes.route('/api/user/profile', methods=['DELETE'])
def delete_user():
    user_id = request.args.get('user_id')
    db = load_database_config()
    delete_user_query = "DELETE FROM {0} WHERE user_id = %s;".format(USERS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, USERS_TABLE, USER_ID_COLUMN, user_id)
                delete_user_dogs(cursor, user_id)
                cursor.execute(delete_user_query, (user_id,))
                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "user '{0}' was successfully deleted".format(user_id)}), HTTP_200_OK


@user_routes.route('/api/user/connection', methods=['GET'])
def is_user_connected():
    user_id = request.args.get('user_id')
    db = load_database_config()
    connection_user_query = "SELECT logged_in FROM {0} WHERE {1} = %s;".format(USERS_TABLE, USER_ID_COLUMN)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, USERS_TABLE, USER_ID_COLUMN, user_id)
                cursor.execute(connection_user_query, (user_id,))
                is_connected = cursor.fetchone()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"user_connection": is_connected[0]}), HTTP_200_OK


