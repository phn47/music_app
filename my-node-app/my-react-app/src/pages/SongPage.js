import React from "react";
import { useLocation } from "react-router-dom";
import "E:/my-node-app/my-node-app/my-react-app/src/css/SongPage.css";

function SongPage() {
  const location = useLocation();
  const { thumbnailUrl, songUrl, songName } = location.state || {};

  if (!thumbnailUrl || !songUrl || !songName) {
    return <p>No song details available.</p>;
  }

  return (
    <div className="song-page">
      <h1>{songName}</h1>
      <img src={thumbnailUrl} alt="Song Thumbnail" className="song-thumbnail" />
      <p className="song-url">Song URL: {songUrl}</p>
      <audio controls>
        <source src={songUrl} type="audio/mp3" />
        Your browser does not support the audio element.
      </audio>
    </div>
  );
}

export default SongPage;
