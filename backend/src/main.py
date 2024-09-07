
from flask import Flask
from src.routes import init_routes
from src.utils.tasks import run_tasks_thread

app = Flask(__name__)

# Initialize routes
init_routes(app)

run_tasks_thread()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
