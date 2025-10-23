from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    return "Flask backend is running."


@app.route("/submit-form", methods=["POST"])
def submit_form():
    data = request.form.to_dict() or request.get_json(silent=True) or {}
    name = data.get("name", "")
    email = data.get("email", "")
    message = data.get("message", "")

    if not name or not email:
        return jsonify({"success": False, "error": "name and email are required"}), 400

    # return success
    return jsonify({
        "success": True,
        "message": "Form received",
        "data": {"name": name, "email": email, "message": message}
    })

if __name__ == "__main__":
    # listen on 0.0.0.0 to be reachable from other containers
    app.run(host="0.0.0.0", port=5000, debug=True)
