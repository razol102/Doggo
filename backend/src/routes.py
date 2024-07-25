from app import app
from flask import request, jsonify
import psycopg2
from config import *
from exceptions import *

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
                                """
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                if is_in_use(cursor, email_query, data.get('email')):
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


@app.route('/api/auth/login', methods=['POST'])
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
                cursor.execute("SELECT password FROM users WHERE email = %s", (email_from_user,))
                stored_password = cursor.fetchone()
                # also need to insert logging...
                if stored_password is None:
                    raise ValueError("User does not exist.")
                elif stored_password[0] != password_from_user:
                    raise ValueError("Incorrect password.")
                else:
                    cursor.execute(logging_in_query, (email_from_user,))
                    connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    print("{0} is logged in!".format(email_from_user))

    return jsonify({"message": "User is logged in!"}), 201


@app.route('/api/auth/logout', methods=['POST'])  # need to add something to user.. logged (boolean) ?
def logout():
    data = request.json
    user_email = data.get('email')

    db = load_database_config()
    logging_out_query = """
            UPDATE users
            SET last_activity = NOW(), logged_in = FALSE
            WHERE email = %s;
        """

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_user_exists(cursor, user_email)
                cursor.execute(logging_out_query, (user_email,))
                connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    print("{0} is logged out!".format(user_email))

    return jsonify({"message": "You're logged out!"}), 201


@app.route('/api/auth/user/profile', methods=['GET'])
def get_user_info():
    data = request.json
    user_email = data.get('email')
    db = load_database_config()

    get_details_query = "SELECT * FROM users WHERE email = %s;"

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(get_details_query, (user_email,))
                user_details = cursor.fetchone()
                if not user_details:
                    raise ValueError("User does not exist.")
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    user_data = {
        "email": user_details[1],
        "name": user_details[3],
        "phone_number": user_details[5]
    }

    return jsonify(user_data), 201



@app.route('/api/auth/user/profile', methods=['PUT'])
def update_user_info():
    data = request.json
    user_email = data.get("email")
    new_email = data.get('new_email')
    new_password = data.get('new_password')
    new_phone_number = data.get('new_phone_number')
    db = load_database_config()

    update_details_query = """
            UPDATE users
            SET email = %s, password = %s, phone_number = %s
            WHERE email = %s;
        """

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_user_exists(cursor, user_email)
                cursor.execute(update_details_query, (new_email, new_password, new_phone_number, user_email))
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    return jsonify({"message": "Profile is updated!"}), 201



def check_email_and_password_from_user(email_from_user, password_from_user):
    if not email_from_user:
        raise MissingFieldsError({"email"})
    elif not password_from_user:
        raise MissingFieldsError({"password"})


def check_if_user_exists(cursor, user_email):
    cursor.execute("SELECT COUNT(*) FROM users WHERE email = %s", (user_email,))
    user_exists = cursor.fetchone()[0]
    if user_exists == 0:
        raise ValueError("User does not exist.")

@app.route("/", methods=['GET'])
def health_check():
#    db = load_database_config()
    print("checking....")
    return "Hello, World!"
