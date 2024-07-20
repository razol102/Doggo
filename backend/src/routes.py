from app import app
from flask import request, jsonify
import psycopg2
from config import *

dog_steps = {}  # Dummy data to store steps for each dog
dog_distances = {}  # Dummy data to store distance for each dog
BLE_DOG_STEPS_LIMIT = 65535


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


@app.route('/api/register', methods=['POST'])
def register_user():
    data = request.json

    # maybe to check this in frontend ?.......... probably in here.. everyone can use this api
    # if not data.get('username') or not data.get('password'):
    #     return jsonify({"error": "Username and password are required"}), 400

    db = load_database_config()
    username_query = "SELECT COUNT(*) FROM users WHERE username = %s"
    email_query = "SELECT COUNT(*) FROM users WHERE email = %s"
    phone_number_query = "SELECT COUNT(*) FROM users WHERE phone_number = %s"
    adding_new_user_query = """
                            INSERT INTO users 
                            (username, password, email, first_name, last_name, date_of_birth, phone_number) 
                            VALUES 
                            (%(username)s, %(password)s, %(email)s, %(first_name)s, %(last_name)s, %(date_of_birth)s
                            , %(phone_number)s)
                            """
    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                if is_in_use(cursor, username_query, data.get('username')):
                    raise Exception("Username is already in use.")
                elif is_in_use(cursor, email_query, data.get('email')):
                    raise Exception("Email is already in use.")
                elif is_in_use(cursor, phone_number_query, data.get('phone_number')):
                    raise Exception("Phone number is already in use.")
                # also need to insert logging...
                cursor.execute(adding_new_user_query, data)
                connection.commit()

    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "User registered successfully"}), 201


def is_in_use(cursor, query, data_to_check):
    cursor.execute(query, (data_to_check,))
    return cursor.fetchone()[0] > 0


@app.route('/api/auth/login', methods=['POST'])  # need to add something to user.. logged (boolean) ?
def login():
    data = request.json
    username_from_user = data.get('username')
    password_from_user = data.get('password')

    if not username_from_user or not password_from_user:
        return jsonify({"error": "Username and password are required"}), 400

    db = load_database_config()

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT password FROM users WHERE username = %s", (username_from_user,))
                stored_password = cursor.fetchone()
                # also need to insert logging...
                if stored_password is None:
                    raise ValueError("Username '{0}' doesn't exist".format(username_from_user))
                elif stored_password[0] != password_from_user:
                    raise ValueError("Incorrect password.")
                else:
                    print("{0} is logged in!".format(username_from_user))
    except ValueError as error:
        return jsonify({"error": str(error)}), 400
    except(Exception, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "{0} logged in!".format(username_from_user)}), 201


@app.route("/", methods=['GET'])
def health_check():
    db = load_database_config()
    print(db)
    return "Hello, World!"
