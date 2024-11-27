from flask import Flask
from app.routes.user_routes import user_blueprint
from app.routes.product_routes import product_blueprint

def create_app():
   app = Flask(name)
   # Register blueprints with url_prefix
   app.register_blueprint(user_blueprint, url_prefix='/api')
   app.register_blueprint(product_blueprint, url_prefix='/api')
   return app