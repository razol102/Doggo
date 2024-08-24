from datetime import date, timedelta

from src.utils.constants import *
from src.utils.conversion_tables import get_fixed_steps_and_distance, get_burned_calories
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


def update_data_from_collar(cursor, dog_id, embedded_steps):
    update_fitness_query = f"""
        UPDATE {FITNESS_TABLE}
        SET {DISTANCE_COLUMN} = %s, {STEPS_COLUMN} = %s, {CALORIES_COLUMN} = %s
        WHERE {DOG_ID_COLUMN} = %s AND {FITNESS_DATE_COLUMN} = %s; """

    get_steps_and_distance_query = f"""
        SELECT {STEPS_COLUMN}, {DISTANCE_COLUMN}
        FROM {FITNESS_TABLE}
        WHERE {DOG_ID_COLUMN} = %s AND {FITNESS_DATE_COLUMN} = %s;
    """

    today_date = date.today()
    dog_weight = get_dog_weight(cursor, dog_id)
    cursor.execute(get_steps_and_distance_query, (dog_id, today_date))
    prev_dog_steps, prev_dog_distance = cursor.fetchone()
    fixed_dog_steps, fixed_dog_distance = get_fixed_steps_and_distance(dog_weight, embedded_steps)

    steps_to_db = prev_dog_steps + fixed_dog_steps
    distance_to_db = prev_dog_distance + fixed_dog_distance
    calories_to_db = get_burned_calories(dog_weight, distance_to_db)

    cursor.execute(update_fitness_query, (distance_to_db, steps_to_db, calories_to_db, dog_id, today_date))
    # fixed steps and fixed distance would be added to activities
    update_dog_activities(cursor, dog_id, fixed_dog_steps, fixed_dog_distance, dog_weight)


def create_data_from_collar(cursor, dog_id, embedded_steps):
    create_fitness_query = f""" INSERT INTO {FITNESS_TABLE} ({DOG_ID_COLUMN}, {FITNESS_DATE_COLUMN}, 
                                {DISTANCE_COLUMN}, {STEPS_COLUMN}, {CALORIES_COLUMN})
                                VALUES (%s, %s, %s, %s, %s); """

    today_date = date.today()
    dog_weight = get_dog_weight(cursor, dog_id)
    steps_to_db, distance_to_db = get_fixed_steps_and_distance(dog_weight, embedded_steps)
    calories_to_db = get_burned_calories(dog_weight, distance_to_db)

    cursor.execute(create_fitness_query, (dog_id, today_date, distance_to_db, steps_to_db, calories_to_db))
    update_dog_activities(cursor, dog_id, steps_to_db, distance_to_db, dog_weight)


def get_fitness_from_yesterday(cursor, dog_id, fitness_column):
    get_yesterday_fitness_query = f"""
                                SELECT {fitness_column}
                                FROM {FITNESS_TABLE} 
                                WHERE {DOG_ID_COLUMN} = %s AND {FITNESS_DATE_COLUMN} = %s;
                                """

    yesterday_date = date.today() - timedelta(days=1)
    cursor.execute(get_yesterday_fitness_query, (dog_id, yesterday_date))
    res_from_cursor = cursor.fetchone()
    if res_from_cursor is None:
        steps_from_yesterday = 0
    else:
        steps_from_yesterday = res_from_cursor[0]
    return steps_from_yesterday


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


def get_collar_id_by_dog_id(cursor, dog_id):
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


def update_dog_activities(cursor, dog_id, steps, distance, dog_weight):
    add_fitness_data_to_active_activities_query = f"""
    UPDATE {ACTIVITIES_TABLE}
    SET {STEPS_COLUMN} = %s,
        {DISTANCE_COLUMN} = %s,
        {CALORIES_COLUMN} = %s
    WHERE duration IS NULL AND {DOG_ID_COLUMN} = %s;
    """

    get_steps_and_distance_query = f"""
        SELECT {STEPS_COLUMN}, {DISTANCE_COLUMN}
        FROM {ACTIVITIES_TABLE}
        WHERE duration IS NULL AND {DOG_ID_COLUMN} = %s;
        """

    cursor.execute(get_steps_and_distance_query, (dog_id,))
    prev_steps, prev_distance = cursor.fetchone()
    steps_to_db = prev_steps + steps
    distance_to_db = prev_distance + distance
    calories_burned_to_db = get_burned_calories(dog_weight, distance_to_db)

    cursor.execute(add_fitness_data_to_active_activities_query,
                   (steps_to_db, distance_to_db, calories_burned_to_db, dog_id))

