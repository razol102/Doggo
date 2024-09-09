from dotenv import load_dotenv
from flask import Flask
from src.routes import init_routes
from src.utils.tasks import run_tasks_thread

app = Flask(__name__)

# Load environment variables once at the start of the application
load_dotenv()

# Initialize routes
init_routes(app)

# Start thread of background tasks
run_tasks_thread()


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
