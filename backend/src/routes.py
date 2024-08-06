from app import app
from flask import request, jsonify
import psycopg2
from config import *
from exceptions import *

dog_steps = {}  # Dummy data to store steps for each dog
dog_distances = {}  # Dummy data to store distance for each dog
BLE_DOG_STEPS_LIMIT = 65535
USERS_TABLE = "users"
DOGS_TABLE = "dogs"
COLLARS_TABLE = "collars"


########## Users ##########
@app.route('/api/register', methods=['POST'])
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
                                INSERT INTO users 
                                (email, password, name, date_of_birth, phone_number) VALUES 
                                (%(email)s, %(password)s, %(name)s, %(date_of_birth)s, %(phone_number)s)
                                RETURNING user_id;
                                """

        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                if is_in_use(cursor, email_query, data.get('email')):
                    raise Exception("Email is already in use.")
                elif is_in_use(cursor, phone_number_query, data.get('phone_number')):
                    raise Exception("Phone number is already in use.")
                # also need to insert logging...
                cursor.execute(adding_new_user_query, data)
                user_id = cursor.fetchone()[0]
                connection.commit()
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"user_id": user_id}), 201


def is_in_use(cursor, query, data_to_check):
    cursor.execute(query, (data_to_check,))
    return cursor.fetchone()[0] > 0


@app.route('/api/auth/login', methods=['PUT'])
def login():
    data = request.json
    email_from_user = data.get('email')
    password_from_user = data.get('password')
    db = load_database_config()
    logging_in_query = """
            UPDATE users
            SET logged_in = TRUE
            WHERE email = %s;
            """

    try:
        check_email_and_password_from_user(email_from_user, password_from_user)
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT user_id, password FROM users WHERE email = %s", (email_from_user,))
                user_data = cursor.fetchone()
                # also need to insert logging...
                if user_data is None:
                    raise ValueError("User does not exist.")
                elif user_data[1] != password_from_user:
                    raise ValueError("Incorrect password.")
                else:
                    cursor.execute(logging_in_query, (email_from_user,))
                    connection.commit()
                    user_id = user_data[0]
                    cursor.execute("SELECT dog_id FROM users_dogs WHERE user_id = %s", (user_id,))
                    dog_id = cursor.fetchone()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    print("{0} is logged in!".format(user_id))
    print("Dog id is: {0}".format(dog_id))

    return jsonify({"user_id": user_id, "dog_id": dog_id}), 200


@app.route('/api/auth/logout', methods=['PUT'])
def logout():
    user_id = request.args.get('user_id')
    db = load_database_config()
    logging_out_query = """
                        UPDATE users
                        SET last_activity = NOW(), logged_in = FALSE
                        WHERE user_id = %s;
                        """

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, USERS_TABLE, "user_id", user_id)
                cursor.execute(logging_out_query, (user_id,))
                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    print("{0} is logged out!".format(user_id))

    return jsonify({"message": "You're logged out!"}), 200


@app.route('/api/auth/user/profile', methods=['GET'])
def get_user_info():
    user_id = request.args.get('user_id')
    db = load_database_config()
    get_details_query = "SELECT email, name, date_of_birth, phone_number FROM users WHERE user_id = %s;"

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

    return jsonify(user_data), 200


@app.route('/api/auth/user/profile', methods=['PUT'])
def update_user_info():
    data = request.json
    db = load_database_config()

    update_details_query = """
            UPDATE users
            SET email = %(email)s, password = %(password)s, name = %(name)s,
            date_of_birth = %(date_of_birth)s, phone_number = %(phone_number)s
            WHERE user_id = %(user_id)s;
        """

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, USERS_TABLE, "user_id", data.get("user_id"))
                cursor.execute(update_details_query, data)
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "Profile is updated!"}), 200


@app.route('/api/auth/user/profile', methods=['DELETE'])
def delete_user():
    user_id = request.args.get('user_id')
    db = load_database_config()
    delete_user_query = "DELETE FROM users WHERE user_id = %s;"

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

    return jsonify({"message": "user '{0}' was successfully deleted".format(user_id)}), 200


def check_email_and_password_from_user(email_from_user, password_from_user):
    if not email_from_user:
        raise MissingFieldsError({"email"})
    elif not password_from_user:
        raise MissingFieldsError({"password"})


def check_if_exists(cursor, table_to_check, column_to_check, data_to_check):
    cursor.execute("SELECT COUNT(*) FROM {0} WHERE {1} = %s".format(table_to_check, column_to_check), (data_to_check,))
    does_exist = cursor.fetchone()[0]
    if does_exist == 0:
        raise ValueError("'{0}' was not found in table {1}: [{2}].".format(data_to_check,
                                                                           table_to_check, column_to_check))

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
                               INSERT INTO dogs 
                               (name, breed, date_of_birth, weight, image, home_latitude, home_longitude) VALUES 
                               (%(name)s, %(breed)s, %(date_of_birth)s, %(weight)s, %(image)s, 
                               %(home_latitude)s, %(home_longitude)s)
                               RETURNING dog_id;
                               """

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
    get_details_query = "SELECT * FROM dogs WHERE dog_id = %s;"

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
#        "image": dog_details[5],
        "home_latitude": dog_details[6],
        "home_longitude": dog_details[7]
    }

    return jsonify(dog_data), 200


@app.route('/api/dog/profile', methods=['PUT'])
def update_dog_info():
    data = request.json
    db = load_database_config()

    update_details_query = """
            UPDATE dogs
            SET name = %(name)s, breed = %(breed)s, date_of_birth = %(date_of_birth)s,
            weight = %(weight)s, image = %(image)s, 
            home_latitude = %(home_latitude)s, home_longitude = %(home_longitude)s
            WHERE dog_id = %(dog_id)s;
        """
    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, "dog_id", data.get("dog_id"))
                cursor.execute(update_details_query, data)
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "Dog's profile is updated!"}), 200


@app.route('/api/dog/profile', methods=['DELETE'])
def delete_dog():
    dog_id = request.args.get('dog_id')
    db = load_database_config()
    delete_dog_query = "DELETE FROM dogs WHERE dog_id = %s;"

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

    return jsonify({"message": "Dog '{0}' was successfully deleted".format(dog_id)}), 200

########## Dogs ##########


########## Collars ##########
@app.route("/api/collar/add", methods=['PUT'])
def add_collar():
    data = request.json
    collar_id = data.get("collar_id")
    dog_id = data.get("dog_id")
    attach_dog_collar_query = """
                              UPDATE collars
                              SET dog_id = %s
                              WHERE collar_id = %s;
                              """
    db = load_database_config()

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, "dog_id", dog_id)
                check_if_exists(cursor, COLLARS_TABLE, "collar_id", collar_id)
                cursor.execute(attach_dog_collar_query, (dog_id, collar_id))
                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "Collar {0} connected to dog {1}".format(collar_id, dog_id)}), 200

@app.route("/", methods=['GET'])
def health_check():
    db = load_database_config()
    print(db)
    print("checking....")
    return "Hello, World!"



@app.route('/api/dogs/<int:dog_id>/fitness/steps', methods=['PUT'])
def update_steps(dog_id):
    new_dog_steps = request.json.get('steps')

    # need to check if it's a new day. if it is, then dog_steps[dog_id] = steps (in db there is date)

    current_dog_steps = dog_steps[dog_id]

    # Can happen if the dog stepped more than 65535 steps. The embedded needs to count from 0 again.
    if current_dog_steps >= new_dog_steps:
        new_dog_steps = (BLE_DOG_STEPS_LIMIT - current_dog_steps) + new_dog_steps

    dog_steps[dog_id] = new_dog_steps  # Update dog's steps

    return jsonify({"steps": dog_steps[dog_id]}), 200


@app.route('/api/dogs/<int:dog_id>/fitness/distance', methods=['PUT'])
def update_distance(dog_id):
    new_dog_distance = request.json.get('distance')

    # need to check if it's a new day. if it is, then dog_distance[dog_id] = new_dog_distance (in db there is date)

    current_dog_distance = dog_distances[dog_id]

    # Can happen if the dog stepped more than 65535 steps. The embedded needs to count from 0 again.
    if current_dog_distance >= new_dog_distance:
        new_dog_distance = (BLE_DOG_STEPS_LIMIT - current_dog_distance) + new_dog_distance

    dog_distances[dog_id] = new_dog_distance  # Update dog's steps

    return jsonify({"steps": dog_steps[dog_id]}), 200

