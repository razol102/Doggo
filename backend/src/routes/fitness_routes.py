from datetime import datetime
from flask import request, Blueprint
from src.utils.helpers import *
from src.utils.conversion_tables import *
from src.utils.logger import logger

fitness_routes = Blueprint('fitness_routes', __name__)


# Endpoint from mobile
@fitness_routes.route('/api/dog/fitness', methods=['PUT'])
def add_fitness_from_mobile():
    dog_id = request.args.get('dog_id')
    embedded_steps = int(request.args.get('steps'))
    today_date = date.today()

    try:
        db = load_database_config()
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                collar_id = get_collar_id_by_dog_id(cursor, dog_id)
                update_collar_connection(cursor, collar_id, CONNECTED_TO_MOBILE)

                if does_exist_by_date(cursor, FITNESS_TABLE, DOG_ID_COLUMN, dog_id, FITNESS_DATE_COLUMN, today_date):
                    update_data_from_collar(cursor, dog_id, embedded_steps)
                else:
                    create_data_from_collar(cursor, dog_id, embedded_steps)

                connection.commit()

    except(Exception, psycopg2.DatabaseError, MissingFieldsError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    return jsonify({"message": "Data was updated"}), HTTP_200_OK


# Endpoint from collar
@fitness_routes.route('/api/dog/collar_data', methods=['PUT'])
def add_data_from_collar():
    data = request.form.to_dict()
    required_data = {"collarID", "battery", "steps"}

    today_date = date.today()
    collar_id = data['collarID']
    battery_level = data['battery']
    embedded_steps = int(data['steps'])

    logger.debug("Values from collar: {0}".format(data))

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

                if does_exist_by_date(cursor, FITNESS_TABLE, DOG_ID_COLUMN, dog_id, FITNESS_DATE_COLUMN, today_date):
                    update_data_from_collar(cursor, dog_id, embedded_steps)
                else:
                    create_data_from_collar(cursor, dog_id, embedded_steps)

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
        "distance": 0.0,
        "steps": 0,
        "calories_burned": 0
    } if not fitness_details else {
        "distance": fitness_details[0],
        "steps": fitness_details[1],
        "calories_burned": fitness_details[2]
    }

    return jsonify(response), HTTP_200_OK


@fitness_routes.route('/api/dog/bcs', methods=['GET'])
def get_dog_bcs():
    dog_id = request.args.get('dog_id')
    db = load_database_config()

    get_weight_and_height_query =   f"""
                                    SELECT weight, height 
                                    FROM {DOGS_TABLE} 
                                    WHERE dog_id = %s;
                                    """

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)
                cursor.execute(get_weight_and_height_query, (dog_id,))
                weight, height = cursor.fetchone()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), 400

    bcs = weight * height

    return jsonify(bcs), HTTP_200_OK
