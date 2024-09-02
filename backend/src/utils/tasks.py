import time
from datetime import timedelta, datetime
from threading import Thread
import psycopg2

from src.utils.config import load_database_config
from src.utils.constants import *
from src.utils.logger import logger

ACTIVITY_TIME_THRESHOLD = timedelta(hours=5)
COLLAR_LAST_UPDATE_TIME_THRESHOLD = timedelta(hours=5)


def run_tasks_thread():
    activities_check_thread = Thread(target=start_tasks)
    activities_check_thread.start()


def start_tasks():
    while True:
        try:
            db = load_database_config()
            with psycopg2.connect(**db) as connection:
                with connection.cursor() as cursor:
                    while True:
                        check_collars_connection(cursor)
                        check_and_end_activities(cursor)
                        connection.commit()
                        time.sleep(10)
        except (Exception, ValueError, psycopg2.DatabaseError) as error:
            logger.error(f"Error with tasks thread: {error}")
            time.sleep(10)  # Wait before retrying the entire process


def check_and_end_activities(cursor):
    get_active_activities_query = f"""SELECT {ACTIVITY_ID_COLUMN}, start_time
                          FROM {ACTIVITIES_TABLE} WHERE end_time IS NULL;"""
    cursor.execute(get_active_activities_query)
    active_activities = cursor.fetchall()
    end_activities_by_time_threshold(cursor, active_activities)


def end_activities_by_time_threshold(cursor, active_activities):
    current_time = datetime.now()

    end_activity_query = f"""
                        UPDATE {ACTIVITIES_TABLE}
                        SET end_time = %s, duration = %s
                        WHERE {ACTIVITY_ID_COLUMN} = %s
                        """

    for activity in active_activities:
        activity_id, start_time = activity
        elapsed_time = current_time - start_time
        if elapsed_time >= ACTIVITY_TIME_THRESHOLD:
            end_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
            duration = format_timedelta(elapsed_time)
            cursor.execute(end_activity_query, (end_time, duration, activity_id))


def format_timedelta(delta):
    total_seconds = int(delta.total_seconds())
    hours, remainder = divmod(total_seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    # Return as formatted string
    return f"{hours:02}:{minutes:02}:{seconds:02}"


def check_collars_connection(cursor):
    delta_query = f""" SELECT NOW() - last_update AS time_delta
                      FROM {COLLARS_TABLE}
                      WHERE collar_id = %s; """

    collar_ids = get_all_collar_ids(cursor)

    for collar_id in collar_ids:
        cursor.execute(delta_query, ("1211",))
        result = cursor.fetchone()

        # If result is None --> the server never received steps from the current collar
        if result is None or result[0] >= COLLAR_LAST_UPDATE_TIME_THRESHOLD:
            disconnect_collar(cursor, collar_id)


def get_all_collar_ids(cursor):
    get_collar_ids_query = f"""SELECT {COLLAR_ID_COLUMN}
                            FROM {COLLARS_TABLE};"""
    cursor.execute(get_collar_ids_query)
    collar_ids = cursor.fetchone()

    return collar_ids


def disconnect_collar(cursor, collar_id):
    disconnect_collar_query = f""" UPDATE {COLLARS_TABLE}
                              SET wifi_connected = FALSE, ble_connected = FALSE
                              WHERE {COLLAR_ID_COLUMN} = %s; """
    cursor.execute(disconnect_collar_query, (collar_id, ))


# def check_and_end_activities(cursor):

