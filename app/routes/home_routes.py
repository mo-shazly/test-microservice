from flask import Blueprint, jsonify

home_blueprint = Blueprint('home_blueprint', __name__)

@home_blueprint.route('/', methods=['GET'])
def home():
    return jsonify({"message": "Welcome to the API!"}), 200
