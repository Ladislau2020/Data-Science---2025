import React, { useState, useEffect } from 'react';
import axios from 'axios';

function Rankings() {
  const [songs, setSongs] = useState([]);

  useEffect(() => {
    axios.get('http://localhost:5000/songs')
      .then(response => setSongs(response.data))
      .catch(error => console.error(error));
  }, []);

  return (
    <div>
      <h1>Song Rankings</h1>
      <ol>
        {songs.map(song => (
          <li key={song.id}>
            {song.title} by {song.singer} - {song.votes} votes
          </li>
        ))}
      </ol>
    </div>
  );
}

export default Rankings;