from datetime import date
from flask import request, jsonify
import psycopg2
from app import *
from config import *
from exceptions import *


BLE_DOG_STEPS_LIMIT = 65535
USERS_TABLE = "users"
USER_ID_COLUMN = "user_id"
DOGS_TABLE = "dogs"
DOG_ID_COLUMN = "dog_id"
USERS_DOGS_TABLE = "users_dogs"
COLLARS_TABLE = "collars"
COLLAR_ID_COLUMN = "collar_id"
FITNESS_TABLE = "fitness"
STEPS_COLUMN = "steps"
DISTANCE_COLUMN = "distance"

# http status codes
HTTP_200_OK = 200
HTTP_201_CREATED = 201
HTTP_400_BAD_REQUEST = 400
HTTP_404_NOT_FOUND = 404

EMPTY_STR = ""


########## Users ##########
@app.route('/api/user/register', methods=['POST'])
def register_user():
    data = request.json
    required_data_for_registration = {"email", "password", "name",
                                      "date_of_birth", "phone_number"}
    try:
        if not required_data_for_registration.issubset(data.keys()):
            missing_fields = required_data_for_registration - data.keys()
            raise MissingFieldsError(missing_fields)
        # need to check all data which can't be Null...
        db = load_database_config()
        email_query = "SELECT COUNT(*) FROM users WHERE email = %s"
        phone_number_query = "SELECT COUNT(*) FROM users WHERE phone_number = %s"
        adding_new_user_query = """
                                INSERT INTO {0} 
                                (email, password, name, date_of_birth, phone_number) VALUES 
                                (%(email)s, %(password)s, %(name)s, %(date_of_birth)s, %(phone_number)s)
                                RETURNING user_id;
                                """.format(USERS_TABLE)

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


@app.route('/api/user/login', methods=['PUT'])
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
                elif user_data[1] != password_from_user:
                    raise ValueError("Incorrect password.")
                else:
                    cursor.execute(logging_in_query, (email_from_user,))
                    connection.commit()
                    user_id = user_data[0]
                    cursor.execute("SELECT dog_id FROM {0} WHERE user_id = %s".format(USERS_DOGS_TABLE), (user_id,))
                    dog_id = cursor.fetchone()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    print("{0} is logged in!".format(user_id))
    print("Dog id is: {0}".format(dog_id))

    return jsonify({"user_id": user_id, "dog_id": dog_id}), HTTP_200_OK


@app.route('/api/user/logout', methods=['PUT'])
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


@app.route('/api/user/profile', methods=['GET'])
def get_user_info():
    user_id = request.args.get('user_id')
    db = load_database_config()
    get_details_query = "SELECT email, name, date_of_birth, phone_number FROM {0} WHERE user_id = %s;".format(
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
        "name": user_details[1],
        "date_of_birth": user_details[2],
        "phone_number": user_details[3]
    }

    return jsonify(user_data), HTTP_200_OK


@app.route('/api/user/profile', methods=['PUT'])
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


@app.route('/api/user/profile', methods=['DELETE'])
def delete_user():
    user_id = request.args.get('user_id')
    db = load_database_config()
    delete_user_query = "DELETE FROM {0} WHERE user_id = %s;".format(USERS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(delete_user_query, (user_id,))
                # check if there was any change in the DB
                if cursor.rowcount == 0:
                    raise ValueError("User does not exist.")
                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "user '{0}' was successfully deleted".format(user_id)}), HTTP_200_OK


@app.route('/api/user/connection', methods=['GET'])
def is_user_connected():
    user_id = request.args.get('user_id')
    db = load_database_config()
    connection_user_query = "SELECT logged_in FROM {0} WHERE user_id = %s;".format(USERS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, USERS_TABLE, USER_ID_COLUMN, user_id)
                cursor.execute(connection_user_query, (user_id,))
                is_connected = cursor.fetchone()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"user_connection": {0}.format(is_connected[0])}), HTTP_200_OK


def is_in_use(cursor, query, data_to_check):
    cursor.execute(query, (data_to_check,))
    return cursor.fetchone()[0] > 0


def check_email_and_password_from_user(email_from_user, password_from_user):
    if not email_from_user:
        raise MissingFieldsError({"email"})
    elif not password_from_user:
        raise MissingFieldsError({"password"})


def check_if_exists(cursor, table_to_check, column_to_check, data_to_check):
    if not does_exist(cursor, table_to_check, column_to_check, data_to_check):
        raise DataNotFoundError(table_to_check, column_to_check, data_to_check)


def does_exist(cursor, table_to_check, column_to_check, data_to_check):
    cursor.execute("SELECT COUNT(*) FROM {0} WHERE {1} = %s".format(table_to_check, column_to_check), (data_to_check,))
    exists = cursor.fetchone()[0]
    return exists

########## Users ##########

########## Dogs ##########
@app.route('/api/dog/add', methods=['POST'])
def add_new_dog():
    data = request.json
    required_data_for_new_dog = {"name", "date_of_birth",
                                 "home_latitude", "home_longitude"}
    try:
        if not required_data_for_new_dog.issubset(data.keys()):
            missing_fields = required_data_for_new_dog - data.keys()
            raise MissingFieldsError(missing_fields)

        db = load_database_config()
        adding_new_dog_query = """
                               INSERT INTO {0}
                               (name, breed, date_of_birth, weight, height, image, home_latitude, home_longitude) VALUES 
                               (%(name)s, %(breed)s, %(date_of_birth)s, %(weight)s, %(height), 
                               %(image)s, %(home_latitude)s, %(home_longitude)s)
                               RETURNING dog_id;
                               """.format(DOGS_TABLE)

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(adding_new_dog_query, data)
                dog_id = cursor.fetchone()[0]
                connection.commit()
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"dog_id": dog_id}), 201


@app.route('/api/dog/profile', methods=['GET'])
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
        "date_of_birth": dog_details[3],
        "weight": dog_details[4],
        "height": dog_details[5],
        #        "image": dog_details[6],
        "home_latitude": dog_details[7],
        "home_longitude": dog_details[8]
    }

    return jsonify(dog_data), HTTP_200_OK


@app.route('/api/dog/profile', methods=['PUT'])
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


@app.route('/api/dog/profile', methods=['DELETE'])
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


########## Dogs ##########

########## Collars ##########
@app.route("/api/collar/add", methods=['PUT'])
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


########## Collars ##########
@app.route('/api/dog/fitness/steps', methods=['PUT'])
def update_dog_steps():
    dog_id = request.args.get('dog_id')
    new_dog_steps = request.args.get('steps')
    json_error_res = update_dog_fitness(dog_id, STEPS_COLUMN, new_dog_steps)

    if json_error_res is not None:
        return json_error_res
    else:
        return jsonify({"message": str("Dog's steps were updated successfully!")}), HTTP_200_OK


@app.route('/api/dog/fitness/distance', methods=['PUT'])
def update_dog_distance():
    dog_id = request.args.get('dog_id')
    new_dog_distance = request.args.get('distance')

    try:
        if new_dog_distance is None or new_dog_distance == EMPTY_STR:
            raise MissingFieldsError({"distance"})
    except MissingFieldsError as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    new_dog_distance = float(new_dog_distance)
    json_error_res = update_dog_fitness(dog_id, DISTANCE_COLUMN, new_dog_distance)

    if json_error_res is not None:
        return json_error_res
    else:
        return jsonify({"message": str("Dog's distance were updated successfully!")}), HTTP_200_OK


def update_dog_fitness(dog_id, fitness_column, fitness_new_data):
    db = load_database_config()
    today_date = date.today()

    get_current_fitness_query = """ SELECT {0}
                                     FROM {1}
                                     WHERE dog_id = %s AND fitness_date = %s; 
                                     """.format(fitness_column, FITNESS_TABLE)

    add_fitness_query = """ INSERT INTO {0} (dog_id, fitness_date, {1})
                          VALUES (%s, %s, %s); """.format(FITNESS_TABLE, fitness_column)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(get_current_fitness_query, (dog_id, today_date))
                current_fitness = cursor.fetchone()
                if current_fitness is None:  # new day
                    cursor.execute(add_fitness_query, (dog_id, today_date, fitness_new_data))
                else:
                    update_daily_fitness(cursor, current_fitness[0],
                                         fitness_new_data, dog_id, today_date, fitness_column)
                    connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST


def update_daily_fitness(cursor, current_fitness_data, fitness_new_data, dog_id, today_date, fitness_column):
    update_steps_query = """ UPDATE {0}
                                SET {1} = %s
                                WHERE dog_id = %s AND fitness_date = %s; """.format(FITNESS_TABLE, fitness_column)

    new_dog_fitness = fix_fitness_data(current_fitness_data, fitness_new_data)
    cursor.execute(update_steps_query, (new_dog_fitness, dog_id, today_date))


def fix_fitness_data(current_fitness_data, new_fitness_data):
    # Can happen if the dog stepped more than 65535 steps.
    # The embedded needs to count from 0 again.
    if current_fitness_data is not None and current_fitness_data >= new_fitness_data:
        new_fitness_data = (BLE_DOG_STEPS_LIMIT - current_fitness_data) + new_fitness_data

    return new_fitness_data


########## Fitness ##########


# Endpoint from collar
@app.route('/api/dogs/collar_data', methods=['PUT'])
def update_data_from_collar():
    data = request.form.to_dict()
    required_data_for_registration = {"collarID", "battery", "steps", "distance"}

    collar_id = data['collarID']
    battery_level = data['battery']
    new_dog_steps = data['steps']
    new_dog_distance = data['distance']

    try:
        if not required_data_for_registration.issubset(data.keys()):
            missing_fields = required_data_for_registration - data.keys()
            raise MissingFieldsError(missing_fields)

        db = load_database_config()

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                # update distance
                # update steps
                update_battery_level(cursor, battery_level)
                connection.commit()
    except(Exception, psycopg2.DatabaseError, MissingFieldsError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify({"message": "ALL GOOD!"}), HTTP_200_OK


def update_battery_level(cursor, new_level):
    update_battery_level_query = """
                                 UPDATE {0}
                                 SET battery_level = %s
                                 WHERE {1} = %s;
                                 """.format(COLLARS_TABLE, COLLAR_ID_COLUMN)
    cursor.execute(update_battery_level_query, (new_level, ))


@app.route("/", methods=['GET'])
def health_check():
    db = load_database_config()
    print(db)
    print("checking....")
    return "Hello, World!"
