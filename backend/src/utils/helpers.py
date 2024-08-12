from datetime import date
import psycopg2
from flask import jsonify

from src.utils.constants import *
from src.utils.config import *
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
    cursor.execute("SELECT COUNT(*) FROM {0} WHERE {1} = %s and {2} = %s"
                   .format(table_to_check, column1_to_check, column2_to_check), (data1_to_check, data2_to_check))
    exists = cursor.fetchone()[0]
    return exists


def update_dog_fitness(dog_id, fitness_column, fitness_new_data):
    db = load_database_config()
    today_date = date.today()
    add_fitness_query = """ INSERT INTO {0} (dog_id, fitness_date, {1})
                            VALUES (%s, %s, %s); """.format(FITNESS_TABLE, fitness_column)

    update_steps_query = """ UPDATE {0}
                             SET {1} = %s
                             WHERE dog_id = %s AND fitness_date = %s; """.format(FITNESS_TABLE, fitness_column)

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                check_if_exists(cursor, DOGS_TABLE, DOG_ID_COLUMN, dog_id)

                if does_exist_by_date(cursor, FITNESS_TABLE, DOG_ID_COLUMN, dog_id, FITNESS_DATE_COLUMN, today_date):
                    cursor.execute(update_steps_query, (fitness_new_data, dog_id, today_date))
                else:
                    cursor.execute(add_fitness_query, (dog_id, today_date, fitness_new_data))
                    connection.commit()
    except(Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST


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


def get_dict_for_response(cursor):
    data_from_query = cursor.fetchone()
    columns_names = [desc[0] for desc in cursor.description]
    return dict(zip(columns_names, data_from_query))