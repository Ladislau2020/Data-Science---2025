from flask import Flask, render_template, request
import mysql.connector

app = Flask(__name__)

# Home Page
@app.route('/')
def home():
    return render_template('home.html')


## songs returning Maybe joining with the songs function below

db = mysql.connector.connect(
    host="Ladislau",
    port="3306",
    user="root",
    # password="yourpassword",
    database="capoeira_db"
)

@app.route('/songs')
def songs():
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM songs")
    songs = cursor.fetchall()
    return render_template('songs.html', songs=songs)



# Songs Page
@app.route('/songs')
def songs():
    return render_template('songs.html')

# Rankings Page
@app.route('/rankings')
def rankings():
    return render_template('rankings.html')

# About Page
@app.route('/about')
def about():
    return render_template('about.html')

if __name__ == '__main__':
    app.run(debug=True)
