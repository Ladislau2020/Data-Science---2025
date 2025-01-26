import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import Vote from './pages/Vote';
import Rankings from './pages/Rankings';
import SongDetails from './pages/SongDetails';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/vote" element={<Vote />} />
        <Route path="/rankings" element={<Rankings />} />
        <Route path="/song/:id" element={<SongDetails />} />
      </Routes>
    </Router>
  );
}

export default App;