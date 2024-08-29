from datetime import date, timedelta, datetime
import time
import psycopg2
from flask import jsonify

from src.utils.config import load_database_config
from src.utils.constants import *
from src.utils.conversion_tables import get_converted_steps_and_distance, get_burned_calories, \
    get_converted_steps, get_converted_distance
from src.utils.exceptions import *


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


def does_exist_by_date(cursor, table_to_check, column1_to_check, data1_to_check, column2_to_check, data2_to_check):
    cursor.execute(f"SELECT COUNT(*) FROM {table_to_check} WHERE {column1_to_check} = %s and {column2_to_check} = %s",
                   (data1_to_check, data2_to_check))
    exists = cursor.fetchone()[0]

    return exists


def update_fitness(cursor, dog_id, embedded_steps):
    update_fitness_query = f"""
        UPDATE {FITNESS_TABLE}
        SET {STEPS_COLUMN} = {STEPS_COLUMN} + %s, 
            {DISTANCE_COLUMN} = {DISTANCE_COLUMN} + %s, 
            {CALORIES_COLUMN} = {CALORIES_COLUMN} + %s
        WHERE {DOG_ID_COLUMN} = %s AND {FITNESS_DATE_COLUMN} = %s;
    """

    today_date = date.today()
    dog_weight = get_dog_weight(cursor, dog_id)

    converted_steps = get_converted_steps(dog_weight, embedded_steps)
    steps_to_db = fix_steps_before_update(cursor, dog_id, converted_steps, dog_weight)

    if steps_to_db != 0:
        distance_to_db = get_converted_distance(dog_weight, steps_to_db)
        calories_to_db = get_burned_calories(dog_weight, distance_to_db)
        cursor.execute(update_fitness_query, (steps_to_db, distance_to_db, calories_to_db, dog_id, today_date))
        update_dog_activity(cursor, dog_id, steps_to_db, distance_to_db, calories_to_db)
        save_last_steps(cursor, dog_id, converted_steps)


def create_fitness(cursor, dog_id, embedded_steps):
    create_fitness_query = f""" INSERT INTO {FITNESS_TABLE} ({DOG_ID_COLUMN}, {FITNESS_DATE_COLUMN}, 
                                {DISTANCE_COLUMN}, {STEPS_COLUMN}, {CALORIES_COLUMN})
                                VALUES (%s, %s, %s, %s, %s); """

    today_date = date.today()
    dog_weight = get_dog_weight(cursor, dog_id)
    converted_steps = get_converted_steps(dog_weight, embedded_steps)
    steps_to_db = fix_steps_before_create(cursor, dog_id, converted_steps)
    distance_to_db = get_converted_distance(dog_weight, steps_to_db)
    calories_to_db = get_burned_calories(dog_weight, distance_to_db)

    save_last_steps(cursor, dog_id, converted_steps)
    cursor.execute(create_fitness_query, (dog_id, today_date, distance_to_db, steps_to_db, calories_to_db))
    update_dog_activity(cursor, dog_id, steps_to_db, distance_to_db, calories_to_db)


def update_battery_level(cursor, collar_id, new_level):
    update_battery_level_query = """
                                 UPDATE {0}
                                 SET battery_level = %s
                                 WHERE {1} = %s;
                                 """.format(COLLARS_TABLE, COLLAR_ID_COLUMN)
    cursor.execute(update_battery_level_query, (int(new_level), collar_id))


def get_dog_id_by_collar_id(cursor, collar_id):
    get_dog_id_query = "SELECT {0} FROM {1} WHERE {2} = %s;".format(DOG_ID_COLUMN, COLLARS_TABLE, COLLAR_ID_COLUMN)
    cursor.execute(get_dog_id_query, (collar_id,))
    dog_id = cursor.fetchone()

    if not dog_id:
        raise ValueError("There is no collar attached to this dog.")
    else:
        return dog_id[0]


def get_collar_from_dog(cursor, dog_id):
    get_collar_id_query = "SELECT {0} FROM {1} WHERE {2} = %s;".format(COLLAR_ID_COLUMN, COLLARS_TABLE, DOG_ID_COLUMN)
    cursor.execute(get_collar_id_query, (dog_id,))
    collar_id = cursor.fetchone()

    if not collar_id:
        raise ValueError("There is no collar attached to this dog.")
    else:
        return collar_id[0]


def get_dict_for_response(cursor):
    data_from_query = cursor.fetchone()
    res = None

    if data_from_query is not None:
        columns_names = [desc[0] for desc in cursor.description]
        res = dict(zip(columns_names, data_from_query))

    return res


def get_list_of_dicts_for_response(cursor):
    rows = cursor.fetchall()
    column_names = [desc[0] for desc in cursor.description]

    list_of_dicts = [
        dict(zip(column_names, row)) for row in rows
    ]

    return list_of_dicts


def calculate_calories(cursor, dog_id, distance):
    get_weight_query = """
                       SELECT weight
                       FROM {0}
                       WHERE {1} = dog_id;    
                       """.format(DOGS_TABLE, DOG_ID_COLUMN)

    cursor.execute(get_weight_query, (dog_id, ))
    weight = cursor.fetchone()[0]
    # burn_rate = get_caloric_burn_rate(velocity)
    burn_rate = 1.0 # Moderate walk (average)
    return weight * distance * burn_rate


def update_collar_connection(cursor, collar_id, is_connected_to_mobile):
    # If connected to mobile --> ble = True
    # else (connected to collar) --> wifi = True

    update_connection_query = """ UPDATE {0}
                                  SET wifi_connected = %s, ble_connected = %s
                                  WHERE collar_id = %s; """.format(COLLARS_TABLE)

    check_if_exists(cursor, COLLARS_TABLE, COLLAR_ID_COLUMN, collar_id)
    cursor.execute(update_connection_query, (not is_connected_to_mobile, is_connected_to_mobile, collar_id))


def check_collar_attachment(cursor, collar_id):
    get_attachment_status_query = f"SELECT {DOG_ID_COLUMN} FROM {COLLARS_TABLE} WHERE {COLLAR_ID_COLUMN} = %s;"
    cursor.execute(get_attachment_status_query, (collar_id,))
    dog_id = cursor.fetchone()[0]
    is_attached = dog_id is not None

    if is_attached:
        raise ValueError("Collar is attached to a dog already.")


def get_dog_weight(cursor, dog_id):
    get_dog_weight_query = f"""
        SELECT {WEIGHT_COLUMN}
        FROM {DOGS_TABLE}
        WHERE {DOG_ID_COLUMN} = %s;
    """

    cursor.execute(get_dog_weight_query, (dog_id, ))

    return cursor.fetchone()[0]


def update_dog_activity(cursor, dog_id, steps_to_db, distance_to_db, calories_to_db):

    add_fitness_data_to_active_activity_query = f"""
    UPDATE {ACTIVITIES_TABLE}
    SET {STEPS_COLUMN} = {STEPS_COLUMN} + %s, 
        {DISTANCE_COLUMN} = {DISTANCE_COLUMN} + %s, 
        {CALORIES_COLUMN} = {CALORIES_COLUMN} + %s
    WHERE duration IS NULL AND {DOG_ID_COLUMN} = %s;
    """

    cursor.execute(add_fitness_data_to_active_activity_query,
                   (steps_to_db, distance_to_db, calories_to_db, dog_id))


def check_for_active_activity(cursor, dog_id):
    get_active_activity =   f"""
                            SELECT COUNT(*) 
                            FROM {ACTIVITIES_TABLE} 
                            WHERE {DOG_ID_COLUMN} = %s AND end_time IS NULL
                            ;"""

    cursor.execute(get_active_activity, (dog_id,))
    activities_count = cursor.fetchone()[0]

    if activities_count != 0:
        raise ActiveActivityExistsError()


def remove_dog_from_data_tables(cursor, dog_id):
    remove_dog_from_activities_table(cursor, dog_id)
    remove_dog_from_care_info_table(cursor, dog_id)
    remove_dog_from_fitness_table(cursor, dog_id)
    remove_dog_from_goals_table(cursor, dog_id)
    remove_dog_from_medical_records_table(cursor, dog_id)
    remove_dog_from_nutrition_table(cursor, dog_id)
    remove_dog_from_vaccinations_table(cursor, dog_id)
    remove_dog_from_users_dogs_table(cursor, dog_id)


def remove_dog_from_activities_table(cursor, dog_id):
    delete_activities_query = f"DELETE FROM {ACTIVITIES_TABLE} WHERE {DOG_ID_COLUMN} = %s"
    cursor.execute(delete_activities_query, (dog_id,))


def remove_dog_from_care_info_table(cursor, dog_id):
    delete_care_info_query = f"DELETE FROM {CARE_INFO_TABLE} WHERE {DOG_ID_COLUMN} = %s"
    cursor.execute(delete_care_info_query, (dog_id,))


def remove_dog_from_fitness_table(cursor, dog_id):
    delete_fitness_query = f"DELETE FROM {FITNESS_TABLE} WHERE {DOG_ID_COLUMN} = %s"
    cursor.execute(delete_fitness_query, (dog_id,))


def remove_dog_from_goals_table(cursor, dog_id):
    delete_goals_query = f"DELETE FROM {GOALS_TABLE} WHERE {DOG_ID_COLUMN} = %s"
    cursor.execute(delete_goals_query, (dog_id,))


def remove_dog_from_medical_records_table(cursor, dog_id):
    delete_medical_records_query = f"DELETE FROM {MEDICAL_RECORDS_TABLE} WHERE {DOG_ID_COLUMN} = %s"
    cursor.execute(delete_medical_records_query, (dog_id,))


def remove_dog_from_nutrition_table(cursor, dog_id):
    delete_nutrition_query = f"DELETE FROM {NUTRITION_TABLE} WHERE {DOG_ID_COLUMN} = %s"
    cursor.execute(delete_nutrition_query, (dog_id,))


def remove_dog_from_vaccinations_table(cursor, dog_id):
    delete_vaccinations_query = f"DELETE FROM {VACCINATIONS_TABLE} WHERE {DOG_ID_COLUMN} = %s"
    cursor.execute(delete_vaccinations_query, (dog_id,))


def remove_dog_from_users_dogs_table(cursor, dog_id):
    delete_users_dogs_query = f"DELETE FROM {USERS_DOGS_TABLE} WHERE {DOG_ID_COLUMN} = %s"
    cursor.execute(delete_users_dogs_query, (dog_id,))


def fix_steps_before_create(cursor, dog_id, new_steps):
    last_steps = load_last_steps(cursor, dog_id)

    if last_steps <= new_steps:
        fixed_fitness_to_db = new_steps - last_steps
    else:   # Can happen because of BLE overflow or embedded was off
        fixed_fitness_to_db = new_steps

    return fixed_fitness_to_db


def fix_steps_before_update(cursor, dog_id, new_steps, dog_weight):
    # Get the battery level
    get_battery_level_query = f"SELECT battery_level FROM {COLLARS_TABLE} WHERE collar_id = %s;"
    collar_id = get_collar_from_dog(cursor, dog_id)
    cursor.execute(get_battery_level_query, (collar_id,))
    battery_level_result = cursor.fetchone()[0]

    last_steps = load_last_steps(cursor, dog_id)
    converted_collar_count_limit = get_converted_steps(dog_weight, COLLAR_FITNESS_COUNT_LIMIT)

    if last_steps > new_steps and battery_level_result < BATTERY_THRESHOLD:  # Battery was off
        fixed_fitness_to_db = new_steps
    elif last_steps > new_steps:      # Overflow because of BLE
        fixed_fitness_to_db = new_steps + converted_collar_count_limit - last_steps
    elif last_steps == new_steps:
        fixed_fitness_to_db = 0
    else:   # last_steps < new_steps
        fixed_fitness_to_db = new_steps - last_steps

    return fixed_fitness_to_db


def save_last_steps(cursor, dog_id, current_steps):
    update_last_steps_query = f"""
    UPDATE {DOGS_TABLE}
    SET last_step = %s
    WHERE {DOG_ID_COLUMN} = %s;
    """

    cursor.execute(update_last_steps_query, (current_steps, dog_id))


def load_last_steps(cursor, dog_id):
    get_last_steps_query = f"""
    SELECT last_step
    FROM {DOGS_TABLE}
    WHERE {DOG_ID_COLUMN} = %s;
    """

    cursor.execute(get_last_steps_query, (dog_id, ))

    return int(cursor.fetchone()[0])
