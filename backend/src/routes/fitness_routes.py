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


@fitness_routes.route('/api/dog/fitness/distance', methods=['PUT'])
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


# Endpoint from collar
@fitness_routes.route('/api/dogs/collar_data', methods=['PUT'])
def update_data_from_collar():
    data = request.form.to_dict()
    required_data = {"collarID", "battery", "steps", "distance"}

    collar_id = data['collarID']
    new_dog_steps = data['steps']
    new_dog_distance = data['distance']
    battery_level = data['battery']
    today_date = date.today()

    logger.debug("Values from collar: {0}".format(data))

    add_fitness_query = """ INSERT INTO {0} (dog_id, fitness_date, {1}, {2})
                            VALUES (%s, %s, %s, %s); """.format(FITNESS_TABLE, DISTANCE_COLUMN, STEPS_COLUMN)

    update_fitness_query = """
    UPDATE {0}
    SET {1} = %s, {2} = %s
    WHERE dog_id = %s AND fitness_date = %s;
    """.format(FITNESS_TABLE, DISTANCE_COLUMN, STEPS_COLUMN)

    try:
        if not required_data.issubset(data.keys()):
            missing_fields = required_data - data.keys()
            raise MissingFieldsError(missing_fields)
        db = load_database_config()
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, COLLARS_TABLE, COLLAR_ID_COLUMN, collar_id)
                dog_id = get_dog_id_by_collar_id(cursor, collar_id)
                update_battery_level(cursor, collar_id, battery_level)
                if does_exist_by_date(cursor, FITNESS_TABLE, DOG_ID_COLUMN, dog_id, FITNESS_DATE_COLUMN, today_date):
                    cursor.execute(update_fitness_query, (new_dog_distance, new_dog_steps, dog_id, today_date))
                    msg = "Fitness was updated"
                else:
                    cursor.execute(add_fitness_query, (dog_id, today_date, new_dog_distance, new_dog_steps))
                    msg = "Fitness was added"
                connection.commit()

    except(Exception, psycopg2.DatabaseError, MissingFieldsError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify({"message": msg}), HTTP_200_OK

