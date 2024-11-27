#! /bin/bash
sudo apt install -y python3 python3-pip python3-venv
mkdir my_flask_project
cd my_flask_project
python3 -m venv flask_env
source flask_env/bin/activate
pip install flask==2.2.2