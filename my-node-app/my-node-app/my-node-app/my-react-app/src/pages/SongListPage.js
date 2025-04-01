// import React, { useEffect, useState } from "react";
// import { fetchSongs } from "E:/my-node-app/my-node-app/my-react-app/src/api/song";

// import { FaPlay, FaPause, FaStepBackward, FaStepForward } from "react-icons/fa";
// import ReactPlayer from "react-player"; // Import ReactPlayer for better media control
// import "E:/my-node-app/my-node-app/my-react-app/src/css/SongListPage.css";


// function SongListPage() {
//   const [songs, setSongs] = useState([]);
//   const [currentSong, setCurrentSong] = useState(null);
//   const [currentThumbnail, setCurrentThumbnail] = useState(null);
//   const [currentSongName, setCurrentSongName] = useState(null);
//   const [isPlaying, setIsPlaying] = useState(false);
//   const [duration, setDuration] = useState(0);
//   const [currentTime, setCurrentTime] = useState(0);
//   const [loading, setLoading] = useState(false);

//   useEffect(() => {
//     const loadSongs = async () => {
//       try {
//         const data = await fetchSongs();
//         setSongs(data);
//         console.log("Songs loaded successfully:", data);
//       } catch (error) {
//         console.error("Error fetching songs:", error);
//       }
//     };

//     loadSongs();
//   }, []);

//   const handlePlaySong = async (thumbnailUrl, songName) => {
//     setLoading(true);
//     try {
//       const songUrl = await sendThumbnailUrlToApi(thumbnailUrl);
//       setCurrentSong(songUrl);
//       setCurrentThumbnail(thumbnailUrl);
//       setCurrentSongName(songName);
//       setDuration(0);
//       setCurrentTime(0);
//       setIsPlaying(true);
//       setLoading(false);
//     } catch (error) {
//       console.error("Error playing song:", error);
//       alert("Failed to play the song.");
//       setLoading(false);
//     }
//   };

//   const handlePlayPause = () => {
//     setIsPlaying(!isPlaying);
//   };

//   const handleNextSong = async () => {
//     try {
//       const nextSongUrl = await getNextSongUrl(currentSong); // Lấy URL bài tiếp theo từ API
//       setCurrentSong(nextSongUrl); // Cập nhật bài hát hiện tại là bài tiếp theo
//       setCurrentTime(0); // Đặt lại thời gian
//       setIsPlaying(true); // Bắt đầu phát bài tiếp theo
//     } catch (error) {
//       console.error("Error fetching next song:", error);
//     }
//   };
//   const handleBeforeSong = async () => {
//     try {
//       const nextSongUrl = await getBeforeSongUrl(currentSong); // Lấy URL bài tiếp theo từ API
//       setCurrentSong(nextSongUrl); // Cập nhật bài hát hiện tại là bài tiếp theo
//       setCurrentTime(0); // Đặt lại thời gian
//       setIsPlaying(true); // Bắt đầu phát bài tiếp theo
//     } catch (error) {
//       console.error("Error fetching next song:", error);
//     }
//   };

//   const sendThumbnailUrlToApi = async (thumbnailUrl) => {
//     try {
//       const response = await fetch(`http://127.0.0.1:8000/song/playwed`, { // Đổi tên API thành playnextwed
//         method: "POST",
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: JSON.stringify({ thumbnail_url: thumbnailUrl }),
//       });

//       if (response.ok) {
//         const data = await response.json();
//         return data.song_url;
//       } else {
//         throw new Error("Failed to fetch song URL from API.");
//       }
//     } catch (error) {
//       console.error("Error sending thumbnail URL to API:", error);
//       throw error;
//     }
//   };

//   const getBeforeSongUrl = async (currentSongUrl) => {
//     try {
//       const response = await fetch(`http://127.0.0.1:8000/song/playnextwed`, {
//         method: "POST",
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: JSON.stringify({ thumbnail_url: currentSongUrl }), // Truyền song_url hiện tại
//       });
  
//       if (response.ok) {
//         const data = await response.json();
//         console.log("API Success: Next song URL fetched", data.song_url); // Thông báo thành công và in URL bài tiếp theo
//         return data.song_url; // Trả về URL của bài tiếp theo
//       } else {
//         console.error("API Error: Failed to fetch next song URL.");
//         alert("Failed to fetch the next song. Please try again."); // Hiển thị thông báo lỗi nếu API thất bại
//         throw new Error("Failed to fetch next song URL.");
//       }
//     } catch (error) {
//       console.error("Error fetching next song:", error);
//       alert("An error occurred while fetching the next song. Please try again."); // Hiển thị thông báo lỗi
//       throw error;
//     }
//   };
  

//   const getNextSongUrl = async (currentSongUrl) => {
//     try {
//       const response = await fetch(`http://127.0.0.1:8000/song/playnextwed`, {
//         method: "POST",
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: JSON.stringify({ thumbnail_url: currentSongUrl }), // Truyền song_url hiện tại
//       });
  
//       if (response.ok) {
//         const data = await response.json();
//         console.log("API Success: Next song URL fetched", data.song_url); // Thông báo thành công và in URL bài tiếp theo
//         return data.song_url; // Trả về URL của bài tiếp theo
//       } else {
//         console.error("API Error: Failed to fetch next song URL.");
//         alert("Failed to fetch the next song. Please try again."); // Hiển thị thông báo lỗi nếu API thất bại
//         throw new Error("Failed to fetch next song URL.");
//       }
//     } catch (error) {
//       console.error("Error fetching next song:", error);
//       alert("An error occurred while fetching the next song. Please try again."); // Hiển thị thông báo lỗi
//       throw error;
//     }
//   };
  

//   const handleProgress = (state) => {
//     setCurrentTime(state.playedSeconds);
//   };

//   const handleSeek = (e) => {
//     const newTime = e.target.value;
//     setCurrentTime(newTime);
//   };

//   return (
//     <div className="song-list-container">
//       <h1>Song List</h1>
//       {loading && <p>Loading...</p>}
//       {songs.length === 0 ? (
//         <p>No songs available</p>
//       ) : (
//         <div className="song-grid">
//           {songs.map((song, index) => (
//             <div
//               className="song-card"
//               key={index}
//               onClick={() => handlePlaySong(song.thumbnail, song.song_name)}
//             >
//               <h3>{song.song_name}</h3>
//               <img
//                 src={song.thumbnail}
//                 alt={song.song_name}
//                 className="song-thumbnail"
//               />
//               <p>
//                 Artist:{" "}
//                 {song.artist_names.length
//                   ? song.artist_names.join(", ")
//                   : "Unknown"}
//               </p>
//               <p>
//                 Genres:{" "}
//                 {song.genre_ids.length ? song.genre_ids.join(", ") : "Unknown"}
//               </p>
//             </div>
//           ))}
//         </div>
//       )}

//       {/* Thanh phát nhạc */}
//       {currentSong && currentThumbnail && (
//         <div className="player-bar">
//           <img
//             src={currentThumbnail}
//             alt="Current Song Thumbnail"
//             className="player-thumbnail"
//           />
//           <div className="player-info">
//             <h4>{currentSongName}</h4>
//           </div>



//           <button onClick={handleBeforeSong} className="player-button">
//             <FaStepBackward size={24} /> {/* Biểu tượng phát bài tiếp theo */}
//           </button>
//           <button onClick={handlePlayPause} className="player-button">
//             {isPlaying ? <FaPause size={24} /> : <FaPlay size={24} />}
//           </button>
//           <button onClick={handleNextSong} className="player-button">
//             <FaStepForward size={24} /> {/* Biểu tượng phát bài tiếp theo */}
//           </button>


    
//           <ReactPlayer
//             url={currentSong}
//             playing={isPlaying}
//             onProgress={handleProgress}
//             onDuration={setDuration}
//             onSeek={(seconds) => setCurrentTime(seconds)}
//             width="0"
//             height="0"
//           />

//           {/* Thanh trượt thời gian */}
//           <div className="progress-container">
//             <span className="start-time">{formatTime(currentTime)}</span>
//             <input
//               type="range"
//               min="0"
//               max={duration}
//               value={currentTime}
//               onChange={handleSeek}
//               className="progress-bar"
//             />
//             <span className="end-time">{formatTime(duration)}</span>
//           </div>
//         </div>
//       )}
//     </div>
//   );
// }

// const formatTime = (seconds) => {
//   const minutes = Math.floor(seconds / 60);
//   const secondsRemaining = Math.floor(seconds % 60);
//   return `${minutes}:${secondsRemaining < 10 ? "0" : ""}${secondsRemaining}`;
// };

// export default SongListPage;













import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom"; 
import { fetchSongs } from "E:/my-node-app/my-node-app/my-react-app/src/api/song";
import { FaPlay, FaPause, FaStepBackward, FaStepForward } from "react-icons/fa";
import ReactPlayer from "react-player";
import "E:/my-node-app/my-node-app/my-react-app/src/css/SongListPage.css";

function SongListPage() {
  const navigate = useNavigate(); // useNavigate hook
  const [songs, setSongs] = useState([]);
  const [currentSong, setCurrentSong] = useState(null);
  const [currentThumbnail, setCurrentThumbnail] = useState(null);
  const [currentSongName, setCurrentSongName] = useState(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [duration, setDuration] = useState(0);
  const [currentTime, setCurrentTime] = useState(0);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const loadSongs = async () => {
      try {
        const data = await fetchSongs();
        setSongs(data);
        console.log("Songs loaded successfully:", data);
      } catch (error) {
        console.error("Error fetching songs:", error);
      }
    };

    loadSongs();
  }, []);

  const handlePlaySong = async (thumbnailUrl, songName) => {
    setLoading(true);
    try {
      const songUrl = await sendThumbnailUrlToApi(thumbnailUrl);
      setCurrentSong(songUrl);
      setCurrentThumbnail(thumbnailUrl);
      setCurrentSongName(songName);
      setDuration(0);
      setCurrentTime(0);
      setIsPlaying(true);
      setLoading(false);
    } catch (error) {
      console.error("Error playing song:", error);
      alert("Failed to play the song.");
      setLoading(false);
    }
  };

  const handlePlayPause = () => {
    setIsPlaying(!isPlaying);
  };

  const handleNextSong = async () => {
    try {
      const nextSongUrl = await getNextSongUrl(currentSong); 
      setCurrentSong(nextSongUrl);
      setCurrentTime(0);
      setIsPlaying(true);
    } catch (error) {
      console.error("Error fetching next song:", error);
    }
  };

  const handleBeforeSong = async () => {
    try {
      const prevSongUrl = await getBeforeSongUrl(currentSong); 
      setCurrentSong(prevSongUrl);
      setCurrentTime(0);
      setIsPlaying(true);
    } catch (error) {
      console.error("Error fetching previous song:", error);
    }
  };

  const sendThumbnailUrlToApi = async (thumbnailUrl) => {
    try {
      const response = await fetch(`http://127.0.0.1:8000/song/playwed`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ thumbnail_url: thumbnailUrl }),
      });

      if (response.ok) {
        const data = await response.json();
        return data.song_url;
      } else {
        throw new Error("Failed to fetch song URL from API.");
      }
    } catch (error) {
      console.error("Error sending thumbnail URL to API:", error);
      throw error;
    }
  };

  const getBeforeSongUrl = async (currentSongUrl) => {
    try {
      const response = await fetch(`http://127.0.0.1:8000/song/playnextwed`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ thumbnail_url: currentSongUrl }),
      });

      if (response.ok) {
        const data = await response.json();
        return data.song_url;
      } else {
        console.error("Failed to fetch previous song URL.");
        throw new Error("Failed to fetch previous song URL.");
      }
    } catch (error) {
      console.error("Error fetching previous song:", error);
      throw error;
    }
  };

  const getNextSongUrl = async (currentSongUrl) => {
    try {
      const response = await fetch(`http://127.0.0.1:8000/song/playnextwed`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ thumbnail_url: currentSongUrl }),
      });

      if (response.ok) {
        const data = await response.json();
        return data.song_url;
      } else {
        console.error("Failed to fetch next song URL.");
        throw new Error("Failed to fetch next song URL.");
      }
    } catch (error) {
      console.error("Error fetching next song:", error);
      throw error;
    }
  };

  const handleProgress = (state) => {
    setCurrentTime(state.playedSeconds);
  };

  const handleSeek = (e) => {
    const newTime = e.target.value;
    setCurrentTime(newTime);
  };

  // Handle click on player bar to navigate to SongPage
  const handlePlayerBarClick = () => {
    navigate("/song", {
      state: {
        thumbnailUrl: currentThumbnail,
        songUrl: currentSong,
        songName: currentSongName,
      },
    });
  };

  return (
    <div className="song-list-container">
      <h1>Song List</h1>
      {loading && <p>Loading...</p>}
      {songs.length === 0 ? (
        <p>No songs available</p>
      ) : (
        <div className="song-grid">
          {songs.map((song, index) => (
            <div
              className="song-card"
              key={index}
              onClick={() => handlePlaySong(song.thumbnail, song.song_name)}
            >
              <h3>{song.song_name}</h3>
              <img
                src={song.thumbnail}
                alt={song.song_name}
                className="song-thumbnail"
              />
              <p>
                Artist:{" "}
                {song.artist_names.length
                  ? song.artist_names.join(", ")
                  : "Unknown"}
              </p>
              <p>
                Genres:{" "}
                {song.genre_ids.length ? song.genre_ids.join(", ") : "Unknown"}
              </p>
            </div>
          ))}
        </div>
      )}

      {currentSong && currentThumbnail && (
        <div className="player-bar" onClick={handlePlayerBarClick}>
          <img
            src={currentThumbnail}
            alt="Current Song Thumbnail"
            className="player-thumbnail"
          />
          <div className="player-info">
            <h4>{currentSongName}</h4>
          </div>

          <button onClick={handleBeforeSong} className="player-button">
            <FaStepBackward size={24} />
          </button>
          <button onClick={handlePlayPause} className="player-button">
            {isPlaying ? <FaPause size={24} /> : <FaPlay size={24} />}
          </button>
          <button onClick={handleNextSong} className="player-button">
            <FaStepForward size={24} />
          </button>

          <ReactPlayer
            url={currentSong}
            playing={isPlaying}
            onProgress={handleProgress}
            onDuration={setDuration}
            onSeek={(seconds) => setCurrentTime(seconds)}
            width="0"
            height="0"
          />

          <div className="progress-container">
            <span className="start-time">{formatTime(currentTime)}</span>
            <input
              type="range"
              min="0"
              max={duration}
              value={currentTime}
              onChange={handleSeek}
              className="progress-bar"
            />
            <span className="end-time">{formatTime(duration)}</span>
          </div>
        </div>
      )}
    </div>
  );
}

const formatTime = (seconds) => {
  const minutes = Math.floor(seconds / 60);
  const secondsRemaining = Math.floor(seconds % 60);
  return `${minutes}:${secondsRemaining < 10 ? "0" : ""}${secondsRemaining}`;
};

export default SongListPage;
