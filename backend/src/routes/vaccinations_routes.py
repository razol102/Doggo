from flask import Blueprint, request
from src.utils.helpers import *

vaccinations_routes = Blueprint('vaccinations_routes', __name__)


@vaccinations_routes.route("/api/dog/nutrition", methods=['GET'])
def get_dog_nutrition():
    dog_id = request.args.get('dog_id')
    db = load_database_config()
    get_dog_nutrition_query = f"SELECT * FROM {NUTRITION_TABLE} WHERE dog_id = %s;"

    try:
        with psycopg2.connect(**db) as connection:
            with connection.cursor() as cursor:
                cursor.execute(get_dog_nutrition_query, (dog_id,))
                dict_response = get_dict_for_response(cursor)
    except (Exception, ValueError, psycopg2.DatabaseError) as error:
        return jsonify({"error": str(error)}), HTTP_400_BAD_REQUEST

    if dict_response is None:
        return jsonify("There is no nutrition record for the chosen dog."), HTTP_200_OK

    return jsonify(dict_response), HTTP_200_OK


