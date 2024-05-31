from flask import Flask, request, jsonify
import psycopg2

app = Flask(__name__)

users = []  # This will store registered users
dog_steps = {} # Dummy data to store steps for each dog
dog_distances = {} # Dummy data to store distance for each dog
BLE_DOG_STEPS_LIMIT = 65535

@app.route('/api/dogs/<int:dog_id>/fitness/steps', methods=['PUT'])
def update_steps(dog_id):
    new_dog_steps = request.json.get('steps')

    # need to check if it's a new day. if it is, then dog_steps[dog_id] = steps (in db there is date)

    current_dog_steps = dog_steps[dog_id]

    # Can happen if the dog stepped more than 65535 steps. The embedded needs to count from 0 again.
    if current_dog_steps >= new_dog_steps:
        new_dog_steps = (BLE_DOG_STEPS_LIMIT - current_dog_steps) + new_dog_steps

    dog_steps[dog_id] = new_dog_steps       # Update dog's steps

    return jsonify({"steps": dog_steps[dog_id]}), 200


@app.route('/api/dogs/<int:dog_id>/fitness/distance', methods=['PUT'])
def update_distance(dog_id):
    new_dog_distance = request.json.get('distance')

    # need to check if it's a new day. if it is, then dog_distance[dog_id] = new_dog_distance (in db there is date)

    current_dog_distance = dog_distances[dog_id]

    # Can happen if the dog stepped more than 65535 steps. The embedded needs to count from 0 again.
    if current_dog_distance >= new_dog_distance:
        new_dog_distance = (BLE_DOG_STEPS_LIMIT - current_dog_distance) + new_dog_distance

    dog_distances[dog_id] = new_dog_distance       # Update dog's steps

    return jsonify({"steps": dog_steps[dog_id]}), 200


@app.route('/api/register', methods=['POST'])
def register_user():
    data = request.json
    if 'username' not in data or 'password' not in data:
        return jsonify({'error': 'Username and password are required'}), 400

    username = data['username']
    password = data['password']

    # Check if the username is already taken
    if any(user['username'] == username for user in users):
        return jsonify({'error': 'Username is already taken'}), 400

    # Create a new user
    new_user = {'username': username, 'password': password}
    users.append(new_user)

    return jsonify({'message': 'User registered successfully'}), 201

@app.route("/", methods=['GET'])
def hello_world():
    print("Printing hello world")
    return "Hello, World!"



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
