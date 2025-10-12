# app/app.py
from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello():
    image_tag = os.environ.get("IMAGE_TAG", "dev")
    return f"Hello, World! (image: {image_tag})\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
