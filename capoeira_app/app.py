from flask import Flask, render_template

app = Flask(__name__)

# Home Page
@app.route('/')
def home():
    return render_template('home.html')

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
