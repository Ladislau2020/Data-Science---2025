import React, { useState, useEffect } from 'react';
import axios from 'axios';

function Vote() {
  const [songs, setSongs] = useState([]);
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  useEffect(() => {
    axios.get('http://localhost:5000/songs')
      .then(response => setSongs(response.data))
      .catch(error => console.error(error));
  }, []);

  const handleVote = (id) => {
    axios.post('http://localhost:5000/vote', { song_id: id, name, email })
      .then(() => alert('Vote submitted successfully!'))
      .catch(error => console.error(error));
  };

  return (
    <div>
      <h1>Vote for Your Favorite Song</h1>
      <input placeholder="Your Name" value={name} onChange={(e) => setName(e.target.value)} />
      <input placeholder="Your Email" value={email} onChange={(e) => setEmail(e.target.value)} />
      <div>
        {songs.map(song => (
          <div key={song.id}>
            <h3>{song.title}</h3>
            <p>Singer: {song.singer}</p>
            <button onClick={() => handleVote(song.id)}>Vote</button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default Vote;
