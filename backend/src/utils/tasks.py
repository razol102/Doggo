import time
from datetime import timedelta, datetime
from threading import Thread
import psycopg2

from src.utils.config import load_database_config
from src.utils.constants import *
from src.utils.logger import logger

TIME_THRESHOLD = timedelta(hours=5)


def run_tasks_thread():
    activities_check_thread = Thread(target=check_and_end_activities)
    activities_check_thread.start()


# Target for activities_check_thread
def check_and_end_activities():
    db = load_database_config()
    get_active_activities_query = f"""SELECT {ACTIVITY_ID_COLUMN}, start_time
                          FROM {ACTIVITIES_TABLE} WHERE end_time IS NULL;"""

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                while True:
                    cursor.execute(get_active_activities_query)
                    active_activities = cursor.fetchall()
                    end_activities_by_time_threshold(cursor, active_activities)
                    connection.commit()
                    time.sleep(10)
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        logger.error(f"Error in check_and_end_activities method: {error}")


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
        if elapsed_time >= TIME_THRESHOLD:
            end_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
            duration = format_timedelta(elapsed_time)
            cursor.execute(end_activity_query, (end_time, duration, activity_id))


def format_timedelta(delta):
    total_seconds = int(delta.total_seconds())
    hours, remainder = divmod(total_seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    # Return as formatted string
    return f"{hours:02}:{minutes:02}:{seconds:02}"
