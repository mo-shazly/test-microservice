from app import create_app

app = create_app()

if __name__ == '__main__':
    print(app.url_map)  # This will print all the routes
    app.run(host='0.0.0.0', port=5000)
