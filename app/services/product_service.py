from flask import Blueprint, jsonify

product_blueprint = Blueprint('product_blueprint', __name__)

@product_blueprint.route('/products', methods=['GET'])
def get_products():
    from app.services.product_service import ProductService  # Move the import here
    product_service = ProductService()
    products = product_service.get_products()
    return jsonify(products), 200

@product_blueprint.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    from app.services.product_service import ProductService  # Move the import here
    product_service = ProductService()
    product = product_service.get_product_by_id(product_id)
    if product:
        return jsonify(product), 200
    else:
        return jsonify({"message": "Product not found"}), 404
