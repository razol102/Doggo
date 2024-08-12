from flask import request, Blueprint
from src.utils.helpers import *

dog_routes = Blueprint('dog_routes', __name__)


@dog_routes.route('/api/dog/add', methods=['POST'])
def add_new_dog():
    data = request.json
    required_data = {"user_id", "name", "date_of_birth", "home_latitude", "home_longitude"}

    try:
        if not required_data.issubset(data.keys()):
            missing_fields = required_data - data.keys()
            raise MissingFieldsError(missing_fields)

        db = load_database_config()
        user_id = data.get("user_id")
        add_new_dog_query = """
                           INSERT INTO {0}
                           (name, breed, gender, date_of_birth, weight, height, home_latitude, home_longitude) 
                           VALUES (%(name)s, %(breed)s, %(gender)s, %(date_of_birth)s, %(weight)s, 
                           %(height)s, %(home_latitude)s, %(home_longitude)s)
                           RETURNING dog_id;
                           """.format(DOGS_TABLE)
        add_user_dog_query = """
                             INSERT INTO {0} (user_id, dog_id) 
                             VALUES (%s, %s)""".format(USERS_DOGS_TABLE)

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, USERS_TABLE, USER_ID_COLUMN, user_id)
                cursor.execute(add_new_dog_query, data)
                dog_id = cursor.fetchone()[0]
                cursor.execute(add_user_dog_query, (user_id, dog_id))
                connection.commit()
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"dog_id": dog_id}), 201


@dog_routes.route('/api/dog/profile', methods=['GET'])
def get_dog_info():
    dog_id = request.args.get('dog_id')
    db = load_database_config()
    get_details_query = "SELECT * FROM {0} WHERE dog_id = %s;".format(DOGS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(get_details_query, (dog_id,))
                dog_details = cursor.fetchone()
                if not dog_details:
                    raise ValueError("Dog does not exist.")
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    dog_data = {
        "name": dog_details[1],
        "breed": dog_details[2],
        "gender": dog_details[3],
        "date_of_birth": dog_details[4],
        "weight": dog_details[5],
        "height": dog_details[6],
        #        "image": dog_details[7],
        "home_latitude": dog_details[8],
        "home_longitude": dog_details[9]
    }

    return jsonify(dog_data), HTTP_200_OK


@dog_routes.route('/api/dog/profile', methods=['PUT'])
def update_dog_info():
    data = request.json
    dog_id = data.get("dog_id")
    db = load_database_config()

    update_details_query = """
                           UPDATE {0}
                           SET name = %(name)s, breed = %(breed)s, date_of_birth = %(date_of_birth)s,
                           weight = %(weight)s, height = %(height)s, image = %(image)s, 
                           home_latitude = %(home_latitude)s, home_longitude = %(home_longitude)s
                           WHERE dog_id = %(dog_id)s;
                           """.format(DOGS_TABLE)
    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(update_details_query, data)
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "Dog's profile is updated!"}), HTTP_200_OK


@dog_routes.route('/api/dog/profile', methods=['DELETE'])
def delete_dog():
    dog_id = request.args.get('dog_id')
    db = load_database_config()
    delete_dog_query = "DELETE FROM {0} WHERE dog_id = %s;".format(DOGS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(delete_dog_query, (dog_id,))
                # check if there was any change in the DB
                if cursor.rowcount == 0:
                    raise ValueError("Dog does not exist.")
                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "Dog '{0}' was successfully deleted".format(dog_id)}), HTTP_200_OK


@dog_routes.route('/api/dog/profile/home', methods=['PUT'])
def update_dog_home_location():
    data = request.json
    dog_id = data.get("dog_id")
    home_latitude = data.get("home_latitude")
    home_longitude = data.get("home_longitude")
    db = load_database_config()
    update_home_loc_query = """
                            UPDATE {0}
                            SET home_latitude = %s, home_longitude = %s
                            WHERE {1} = %s;
                            """.format(DOGS_TABLE, DOG_ID_COLUMN)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(update_home_loc_query, (home_latitude, home_longitude, dog_id))
                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "Home location was updated!"}), HTTP_200_OK
