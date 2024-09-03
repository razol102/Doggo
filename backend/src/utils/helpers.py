from calendar import monthrange
from datetime import date, timedelta, datetime
import time
import psycopg2
from flask import jsonify

from src.utils.config import load_database_config
from src.utils.constants import *
from src.utils.conversion_tables import get_burned_calories, \
    get_converted_steps, get_calculated_distance
from src.utils.exceptions import *
from src.utils.logger import logger


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
    dog_weight, dog_height = get_dog_weight_and_height(cursor, dog_id)

    fixed_steps = fix_steps_before_update(cursor, dog_id, embedded_steps)
    save_last_steps(cursor, dog_id, embedded_steps)
    steps_to_db = get_converted_steps(dog_weight, fixed_steps)

    if steps_to_db != 0:
        distance_to_db = get_calculated_distance(dog_weight, dog_height, steps_to_db)
        calories_to_db = get_burned_calories(dog_weight, distance_to_db)
        cursor.execute(update_fitness_query, (steps_to_db, distance_to_db, calories_to_db, dog_id, today_date))
        update_dog_activity(cursor, dog_id, steps_to_db, distance_to_db, calories_to_db)


def create_fitness(cursor, dog_id, embedded_steps):
    create_fitness_query = f""" INSERT INTO {FITNESS_TABLE} ({DOG_ID_COLUMN}, {FITNESS_DATE_COLUMN}, 
                                {DISTANCE_COLUMN}, {STEPS_COLUMN}, {CALORIES_COLUMN})
                                VALUES (%s, %s, %s, %s, %s); """

    today_date = date.today()
    dog_weight, dog_height = get_dog_weight_and_height(cursor, dog_id)

    fixed_steps = fix_steps_before_create(cursor, dog_id, embedded_steps)
    save_last_steps(cursor, dog_id, embedded_steps)

    steps_to_db = get_converted_steps(dog_weight, fixed_steps)
    distance_to_db = get_calculated_distance(dog_weight, dog_height, steps_to_db)
    calories_to_db = get_burned_calories(dog_weight, distance_to_db)

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


def get_dog_weight_and_height(cursor, dog_id):
    get_dog_weight_query = f"""
        SELECT {WEIGHT_COLUMN}, {HEIGHT_COLUMN}
        FROM {DOGS_TABLE}
        WHERE {DOG_ID_COLUMN} = %s;
    """

    cursor.execute(get_dog_weight_query, (dog_id, ))

    return cursor.fetchone()


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
    remove_dog_from_favorites_table(cursor, dog_id)


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


def remove_dog_from_favorites_table(cursor, dog_id):
    delete_favorites_query = f"DELETE FROM {FAVORITE_PLACES_TABLE} WHERE {DOG_ID_COLUMN} = %s"
    cursor.execute(delete_favorites_query, (dog_id,))


def fix_steps_before_create(cursor, dog_id, new_steps):
    last_steps = load_last_steps(cursor, dog_id)

    if last_steps <= new_steps:
        fixed_steps = new_steps - last_steps
    else:   # Can happen because of BLE overflow or embedded was off
        fixed_steps = new_steps

    return fixed_steps


def fix_steps_before_update(cursor, dog_id, new_steps):
    # # Get the battery level
    # get_battery_level_query = f"SELECT battery_level FROM {COLLARS_TABLE} WHERE collar_id = %s;"
    # collar_id = get_collar_from_dog(cursor, dog_id)
    # cursor.execute(get_battery_level_query, (collar_id,))
    # battery_level_result = cursor.fetchone()[0]

    last_steps = load_last_steps(cursor, dog_id)

    logger.debug("Last steps loaded: {0}".format(last_steps))

    # if last_steps > new_steps and battery_level_result < BATTERY_THRESHOLD:  # Battery was off
    if last_steps > new_steps: # Battery was off
        fixed_steps = new_steps
    # elif last_steps > new_steps:      # Overflow because of Arduino
    #     converted_collar_count_limit = get_converted_steps(dog_weight, COLLAR_FITNESS_COUNT_LIMIT)
    #     fixed_fitness_to_db = new_steps + converted_collar_count_limit - last_steps
    #     logger.debug("Fixed after BLE LIMIT: {0}".format(fixed_fitness_to_db))
    elif last_steps == new_steps:
        fixed_steps = 0
    else:   # last_steps < new_steps
        fixed_steps = new_steps - last_steps
        logger.debug("Fixed after 'else': {0}".format(fixed_steps))

    return fixed_steps


def save_last_steps(cursor, dog_id, current_steps):
    update_last_steps_query = f"""
    UPDATE {DOGS_TABLE}
    SET last_steps = %s
    WHERE {DOG_ID_COLUMN} = %s;
    """

    cursor.execute(update_last_steps_query, (current_steps, dog_id))


def load_last_steps(cursor, dog_id):
    get_last_steps_query = f"""
    SELECT last_steps
    FROM {DOGS_TABLE}
    WHERE {DOG_ID_COLUMN} = %s;
    """

    cursor.execute(get_last_steps_query, (dog_id, ))

    return int(cursor.fetchone()[0])


def delete_user_dogs(cursor, user_id):
    get_dogs_query = f"SELECT {DOG_ID_COLUMN} FROM {USERS_DOGS_TABLE} WHERE {USER_ID_COLUMN} = %s;"
    delete_dog_query = f"DELETE FROM {DOGS_TABLE} WHERE {DOG_ID_COLUMN} = %s;"

    cursor.execute(get_dogs_query, (user_id,))
    dogs = cursor.fetchall()

    for dog in dogs:
        dog_id = dog[0]
        remove_dog_from_data_tables(cursor, dog_id)
        cursor.execute(delete_dog_query, (dog_id,))


def set_goals_data_by_category(goal):
    if goal['category'] == "steps" or goal['category'] == "calories_burned":
        goal['current_value'] = int(goal['current_value'])
        goal['target_value'] = int(goal['target_value'])
    else:
        goal['current_value'] = round(goal['current_value'], 2)
        goal['target_value'] = round(goal['target_value'], 2)


def get_day_record_map(cursor, month, year):
    records = cursor.fetchall()
    total_days_in_month = monthrange(int(year), int(month))[1]
    day_record_map = {day: False for day in range(1, total_days_in_month + 1)}

    for record in records:
        day = int(record[0])  # Extract the day number from the result
        day_record_map[day] = True

    return day_record_map


def create_goal(cursor, template_data):
    get_current_fitness_query = f"""
        SELECT {template_data['category']} FROM {FITNESS_TABLE}
        WHERE {DOG_ID_COLUMN} = %s AND {FITNESS_DATE_COLUMN} = CURRENT_DATE
        """
    insert_goal_query = f"""
        INSERT INTO {GOALS_TABLE} (dog_id, end_date, current_value, target_value, category)
        VALUES (%s, %s, %s, %s, %s);
        """

    goal_end_date = get_end_date_by_frequency(template_data['frequency'])
    cursor.execute(get_current_fitness_query, (template_data['dog_id'], ))
    today_fitness = cursor.fetchone()[0]
    cursor.execute(insert_goal_query, (template_data['dog_id'], goal_end_date, today_fitness,
                                       template_data['target_value'], template_data['category']))


def get_end_date_by_frequency(frequency):
    today = datetime.today().date()
    end_date = None

    if frequency == "daily":
        end_date = today + timedelta(days=1)
    elif frequency == "weekly":
        if today.weekday() == 6:  # If today is Sunday (Sunday is day 6)
            end_date = today + timedelta(7)  # Set end_date to next Sunday
        else:
            end_date = today + timedelta(6 - today.weekday())  # Set to the upcoming Sunday
    elif frequency == "monthly":
        if today.month == DECEMBER:
            end_date = today.replace(day=1, month=1, year=today.year + 1)
        else:
            end_date = today.replace(day=1, month=today.month + 1)

    return end_date

