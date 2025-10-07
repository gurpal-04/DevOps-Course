from flask import Flask, render_template, request, redirect, url_for, jsonify
from pymongo import MongoClient
from urllib.parse import quote_plus
import json
import os

MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    raise ValueError("MONGO_URI environment variable not set!")

app = Flask(__name__)

client = MongoClient(MONGO_URI)
db = client["flask_db"]
collection = db["users"]

@app.route("/")
def index():
    return render_template("form.html")

@app.route("/submit", methods=["POST"])
def submit_data():
    try:
        name = request.form.get("name")
        email = request.form.get("email")

        if not name or not email:
            raise ValueError("Name and Email are required!")

        collection.insert_one({"name": name, "email": email})
        return redirect(url_for("success"))
    except Exception as e:
        return render_template("form.html", error=str(e))

@app.route("/success")
def success():
    return render_template("success.html")

@app.route("/api", methods=["GET"])
def get_data():
    try:
        if not os.path.exists("data.json"):
            return jsonify({"error": "data.json file not found"}), 404

        with open("data.json", "r") as file:
            data = json.load(file)

        return jsonify(data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(debug=True)
