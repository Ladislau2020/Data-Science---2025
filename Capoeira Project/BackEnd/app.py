from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

# Database connection
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="your_password",
    database="capoeira_db"
)

cursor = db.cursor(dictionary=True)

# Get all songs (with votes)
@app.route('/songs', methods=['GET'])
def get_songs():
    cursor.execute("SELECT * FROM songs ORDER BY votes DESC")
    songs = cursor.fetchall()
    return jsonify(songs)

# Submit a vote
@app.route('/vote', methods=['POST'])
def vote_song():
    data = request.json
    song_id = data['song_id']
    name = data['name']
    email = data['email']

    # Record the voter
    cursor.execute("INSERT INTO voters (name, email) VALUES (%s, %s)", (name, email))
    db.commit()

    # Update the song's vote count
    cursor.execute("UPDATE songs SET votes = votes + 1 WHERE id = %s", (song_id,))
    db.commit()

    return jsonify({"message": "Vote submitted successfully"})

# Get song details
@app.route('/song/<int:song_id>', methods=['GET'])
def get_song_details(song_id):
    cursor.execute("SELECT * FROM songs WHERE id = %s", (song_id,))
    song = cursor.fetchone()
    return jsonify(song)

if __name__ == '__main__':
    app.run(debug=True)
