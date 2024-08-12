from flask import Flask
from src.routes import init_routes

app = Flask(__name__)

# Initialize routes
init_routes(app)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
