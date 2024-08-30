# from socket import SocketIO
#
# from flask import Flask, jsonify
# import psycopg2
# import time
#
# from src.utils.config import load_database_config
#
# app = Flask(_name_)
# socketio = SocketIO(app)
#
#
# def notify_user(user_id, notification):
#     socketio.emit('new_notification', {'user_id': user_id, 'notification': notification}, room=user_id)
#
#
# def check_for_new_notifications():
#     last_check = time.time()
#     notifications_query = """
#         SELECT user_id, message
#         FROM notifications
#         WHERE timestamp > %s AND is_read = FALSE
#         ;"""
#
#     while True:
#         try:
#             db = load_database_config()
#
#             with psycopg2.connect(**db) as connection:
#                 with connection.cursor() as cursor:
#                     cursor.execute(notifications_query, time.strftime('%Y-%m-%d %H:%M:%S', time.gmtime(last_check)))
#                     new_notifications = cursor.fetchall()
#                     for notif in new_notifications:
#                         user_id, message = notif
#                         notify_user(user_id, message)
#         except(Exception, psycopg2.DatabaseError) as error:
#             return jsonify({"error": str(error)}), 400
#
#         last_check = time.time()
#         time.sleep(10)  # Check every 10 seconds
#
#
# @socketio.on('connect')
# def handle_connect():
#     print('Client connected')
#
#
# @socketio.on('disconnect')
# def handle_disconnect():
#     print('Client disconnected')
#
#
# # if _name_ == '_main_':
# #     socketio.run(app, debug=True)