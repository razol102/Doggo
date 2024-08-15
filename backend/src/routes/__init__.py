from src.routes.dog_care_info_routes import dog_care_info_routes
from src.routes.fitness_routes import fitness_routes
from src.routes.other_routes import other_routes
from src.routes.user_routes import user_routes
from src.routes.dog_routes import dog_routes
from src.routes.collar_routes import collar_routes
from src.routes.faq_routes import faq_routes
from src.routes.nutrition_routes import nutrition_routes


def init_routes(app):
    app.register_blueprint(user_routes)
    app.register_blueprint(dog_routes)
    app.register_blueprint(collar_routes)
    app.register_blueprint(other_routes)
    app.register_blueprint(fitness_routes)
    app.register_blueprint(dog_care_info_routes)
    app.register_blueprint(faq_routes)
    app.register_blueprint(nutrition_routes)
