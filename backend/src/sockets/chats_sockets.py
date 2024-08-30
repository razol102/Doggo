# from flask import Flask
# from flask_socketio import SocketIO, join_room, leave_room, send, emit
#
# app = Flask(_name_)
# app.config['SECRET_KEY'] = 'your_secret_key'
# socketio = SocketIO(app)
#
# # In-memory storage for rooms and users (consider using a database for production)
# rooms = {}
# users_in_room = {}
#
#
# def get_previous_messages(room):
#     # This function should retrieve the previous messages from a database
#     # Placeholder: return an empty list or dummy data
#     return []
#
#
# # Endpoint for users to join a chat room
# @socketio.on('join')
# def on_join(data):
#     try:
#         username = data['username']
#         room = data['room']
#         join_room(room)
#
#         # Fetch and send previous messages from the database
#         messages = get_previous_messages(room)
#         for message in messages:
#             send(message, to=request.sid)
#
#         if room not in users_in_room:
#             users_in_room[room] = []
#         users_in_room[room].append(username)
#
#         send(f"{username} has joined the room.", to=room)
#         emit('user_list', users_in_room[room], to=room)
#
#     except KeyError as e:
#         send(f"Error: {str(e)} is missing.", to=request.sid)
#
#
# # Endpoint for users to leave a chat room
# @socketio.on('leave')
# def on_leave(data):
#     username = data['username']
#     room = data['room']
#     leave_room(room)
#
#     users_in_room[room].remove(username)
#     send(f"{username} has left the room.", to=room)
#     emit('user_list', users_in_room[room], to=room)
#
#
# # Handling incoming messages
# @socketio.on('message')
# def handle_message(data):
#     room = data['room']
#     emit('message', {'msg': data['message'], 'user': data['username']}, to=room)
#
#
# # Create a new room
# @socketio.on('create_room')
# def create_room(data):
#     room_name = data['room_name']
#     if room_name not in rooms:
#         rooms[room_name] = []
#         send(f"Room {room_name} created.", to=request.sid)
#     else:
#         send(f"Room {room_name} already exists.", to=request.sid)
#
#
# # Delete a room
# @socketio.on('delete_room')
# def delete_room(data):
#     room_name = data['room_name']
#     if room_name in rooms:
#         del rooms[room_name]
#         send(f"Room {room_name} deleted.", to=request.sid)
#     else:
#         send(f"Room {room_name} does not exist.", to=request.sid)
#
#
# # Typing indicator
# @socketio.on('typing')
# def typing(data):
#     room = data['room']
#     emit('typing', {'username': data['username']}, to=room)
#
#
# if _name_ == '_main_':
#     socketio.run(app, debug=True)