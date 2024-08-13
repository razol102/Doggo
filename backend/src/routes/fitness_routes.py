from datetime import datetime

from flask import request, Blueprint
from src.utils.helpers import *
from src.utils.logger import logger

fitness_routes = Blueprint('fitness_routes', __name__)


@fitness_routes.route('/api/dog/fitness/steps', methods=['PUT'])
def update_dog_steps():
    dog_id = request.args.get('dog_id')
    new_dog_steps = request.args.get('steps')
    json_error_res = update_dog_fitness(dog_id, STEPS_COLUMN, new_dog_steps)

    if json_error_res is not None:
        return json_error_res
    else:
        return jsonify({"message": str("Dog's steps were updated successfully!")}), HTTP_200_OK


@fitness_routes.route('/api/dog/fitness/distance_calories', methods=['PUT'])
def update_dog_distance_calories():
    dog_id = request.args.get('dog_id')
    new_dog_distance = request.args.get('distance')

    try:
        if new_dog_distance is None or not new_dog_distance:
            raise MissingFieldsError({"distance"})
    except MissingFieldsError as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    # need to check if it's float
    distance_in_meters = float(new_dog_distance)
    new_dog_distance = meters_to_kilometers(distance_in_meters)
    json_error_res = update_dog_fitness(dog_id, DISTANCE_COLUMN, new_dog_distance)

    if json_error_res is not None:
        return json_error_res
    else:
        return jsonify({"message": str("Dog's distance and calories were updated successfully!")}), HTTP_200_OK


# Endpoint from collar
@fitness_routes.route('/api/dog/collar_data', methods=['PUT'])
def update_data_from_collar():
    data = request.form.to_dict()
    required_data = {"collarID", "battery", "steps", "distance"}

    today_date = date.today()
    collar_id = data['collarID']
    battery_level = data['battery']
    new_dog_steps = data['steps']
    distance = data['distance']

    # need to check if it's float
    distance_in_meters = float(distance)
    new_dog_distance = meters_to_kilometers(distance_in_meters)

    logger.debug("Values from collar: {0}".format(data))

    add_fitness_query = """ INSERT INTO {0} (dog_id, fitness_date, {1}, {2}, {3})
                            VALUES (%s, %s, %s, %s, %s); """.format(FITNESS_TABLE,
                                                                    DISTANCE_COLUMN, STEPS_COLUMN, CALORIES_COLUMN)

    update_fitness_query = """
    UPDATE {0}
    SET {1} = %s, {2} = %s, {3} = %s
    WHERE dog_id = %s AND fitness_date = %s;
    """.format(FITNESS_TABLE, DISTANCE_COLUMN, STEPS_COLUMN, CALORIES_COLUMN)

    try:
        if not required_data.issubset(data.keys()):
            missing_fields = required_data - data.keys()
            raise MissingFieldsError(missing_fields)
        db = load_database_config()
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, COLLARS_TABLE, COLLAR_ID_COLUMN, collar_id)
                dog_id = get_dog_id_by_collar_id(cursor, collar_id)
                update_collar_connection(cursor, collar_id, not CONNECTED_TO_MOBILE)
                update_battery_level(cursor, collar_id, battery_level)
                calories = calculate_calories(cursor, dog_id, new_dog_distance)

                if does_exist_by_date(cursor, FITNESS_TABLE, DOG_ID_COLUMN, dog_id, FITNESS_DATE_COLUMN, today_date):
                    cursor.execute(update_fitness_query, (new_dog_distance, new_dog_steps, calories, dog_id, today_date))
                else:
                    cursor.execute(add_fitness_query, (dog_id, today_date, new_dog_distance, new_dog_steps, calories))

                connection.commit()

    except(Exception, psycopg2.DatabaseError, MissingFieldsError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify({"message": "Data was updated"}), HTTP_200_OK


@fitness_routes.route('/api/dog/fitness', methods=['GET'])
def get_dog_fitness():
    dog_id = request.args.get('dog_id')
    fitness_date = request.args.get('date')
    db = load_database_config()
    get_fitness_query = """
                        SELECT distance, steps, calories_burned 
                        FROM {0} 
                        WHERE dog_id = %s AND fitness_date = %s;
                        """.format(FITNESS_TABLE)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                date_obj = datetime.strptime(fitness_date, '%Y-%m-%d').date()
                cursor.execute(get_fitness_query, (dog_id, date_obj))
                fitness_details = cursor.fetchone()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    response = {
        "distance": 0,
        "steps": 0,
        "calories_burned": 0
    } if not fitness_details else {
        "distance": fitness_details[0],
        "steps": fitness_details[1],
        "calories_burned": fitness_details[2]
    }

    return jsonify(response), HTTP_200_OK


