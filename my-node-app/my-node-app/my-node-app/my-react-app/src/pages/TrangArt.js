import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import "E:/my-node-app/my-node-app/my-react-app/src/css/TrangArt.css"; // Thêm tệp CSS

function TrangArt() {
  const [visibleSongs, setVisibleSongs] = useState([]);
  const [hiddenSongsByArt, setHiddenSongsByArt] = useState([]);
  const [hiddenSongs, setHiddenSongs] = useState([]);
  const [pendingSongs, setPendingSongs] = useState([]); // Thêm trạng thái cho bài hát chờ duyệt
  const [rejectedSongs, setRejectedSongs] = useState([]);
  const [allSongs, setAllSongs] = useState([]); // Thêm trạng thái cho tất cả bài hát
  const [error, setError] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const fetchSongs = async () => {
      try {
        const token = localStorage.getItem("token");
        const artistId = localStorage.getItem("artist_id");

        if (!token || !artistId) {
          throw new Error("Không tìm thấy thông tin đăng nhập.");
        }

        const songIds = await fetchSongIds(artistId, token);
        if (!songIds || songIds.length === 0) {
          throw new Error("Nghệ sĩ này không có bài hát.");
        }

        const songDetails = await fetchSongDetails(songIds, token);

        setAllSongs(songDetails); // Lưu tất cả bài hát
        const visible = songDetails.filter((song) => song.is_hidden);
        const hidden = songDetails.filter((song) => song.is_hidden === null&&song.hidden_by!==song.user_id);
        const hidenbyart = songDetails.filter((song) => song.is_hidden === null&&song.hidden_by===song.user_id);
        const pending = songDetails.filter((song) => song.is_hidden === false&&song.status==="pending");
        const rejected = songDetails.filter((song) => song.is_hidden === false&&song.status==="rejected");  // Lọc bài hát chờ duyệt

        setVisibleSongs(visible);
        setHiddenSongs(hidden);
        setHiddenSongsByArt(hidenbyart)
        setPendingSongs(pending);
        setRejectedSongs(rejected); // Lưu bài hát chờ duyệt
      } catch (err) {
        setError(err.message);
      }
    };

    fetchSongs();
  }, []);

  const fetchSongIds = async (artistId, token) => {
    const response = await fetch(
      `http://127.0.0.1:8000/artist/songs/user/${artistId}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ artist_id: artistId }),
      }
    );

    if (!response.ok) {
      throw new Error("Không thể lấy danh sách bài hát.");
    }

    const data = await response.json();
    return data.song_ids;
  };

  const fetchSongDetails = async (songIds, token) => {
    const response = await fetch(
      "http://127.0.0.1:8000/artist/songs/details",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ song_ids: songIds }),
      }
    );

    if (!response.ok) {
      throw new Error("Không thể lấy thông tin chi tiết bài hát.");
    }

    const data = await response.json();
    return data.songs;
  };
  const handleSongClick = (songId) => {
    navigate(`/artist/ansongbyart/${songId}`); // Chuyển hướng đến đường dẫn mới với ID bài hát
  };

  return (
    <div className="container mt-5">
      <div className="p-4 rounded shadow" style={{ backgroundColor: "white" }}>
        
        {error && <p className="text-danger">{error}</p>}
  
        {/* Danh sách bài hát chờ duyệt */}
        <div className="mb-5">
          <h3 className="mb-3">Danh sách bài hát chờ duyệt</h3>
          <div className="row">
            {pendingSongs.length > 0 ? (
              pendingSongs.map((song) => (
                <div key={song.id} className="col-md-3 mb-4">
                  <div className="card h-100 shadow-sm">
                    <img src={song.thumbnail_url} alt={song.song_name} className="card-img-top" />
                    <div className="card-body">
                      <h5 className="card-title">{song.song_name}</h5>
                      <p className="card-text">Bài hát đang chờ phê duyệt.</p>
                      <a href={song.song_url} target="_blank" rel="noopener noreferrer" className="btn btn-dark">
                        Nghe bài hát
                      </a>
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <p>Không có bài hát chờ duyệt.</p>
            )}
          </div>
        </div>
  
        {/* Danh sách bài hát từ chối duyệt */}
        <div className="mb-5">
          <h3 className="mb-3">Danh sách bài hát từ chối duyệt</h3>
          <div className="row">
            {rejectedSongs.length > 0 ? (
              rejectedSongs.map((song) => (
                <div
                  key={song.id}
                  className="col-md-3 mb-4"
                  onClick={() => navigate(`/guilai?id=${song.id}`)}
                  style={{ cursor: "pointer" }}
                >
                  <div className="card h-100 shadow-sm">
                    <img src={song.thumbnail_url} alt={song.song_name} className="card-img-top" />
                    <div className="card-body">
                      <h5 className="card-title">{song.song_name}</h5>
                      <p className="card-text">Bài hát đã bị từ chối phê duyệt.</p>
                      <a href={song.song_url} target="_blank" rel="noopener noreferrer" className="btn btn-dark">
                        Nghe bài hát
                      </a>
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <p>Không có bài hát nào bị từ chối duyệt.</p>
            )}
          </div>
        </div>
  
        {/* Danh sách bài hát đã duyệt */}
        <div className="mb-5">
          <h3 className="mb-3">Danh sách bài hát đã duyệt</h3>
          <div className="row">
            {visibleSongs.length > 0 ? (
              visibleSongs.map((song) => (
                <div
                  key={song.id}
                  className="col-md-3 mb-4"
                  onClick={() => navigate(`/artist/ansongbyart?id=${song.id}`)}
                  style={{ cursor: "pointer" }}
                >
                  <div className="card h-100 shadow-sm">
                    <img src={song.thumbnail_url} alt={song.song_name} className="card-img-top" />
                    <div className="card-body">
                      <h5 className="card-title">{song.song_name}</h5>
                      <a href={song.song_url} target="_blank" rel="noopener noreferrer" className="btn btn-dark">
                        Nghe bài hát
                      </a>
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <p>Không có bài hát công khai.</p>
            )}
          </div>
        </div>
  
        {/* Danh sách bài hát bị ẩn bởi artist */}
        <div className="mb-5">
          <h3 className="mb-3">Danh sách bài hát bị ẩn bởi artist</h3>
          <div className="row">
            {hiddenSongsByArt.length > 0 ? (
              hiddenSongsByArt.map((song) => (
                <div
                  key={song.id}
                  className="col-md-3 mb-4"
                  onClick={() => navigate(`/artist/dabisongbyart?id=${song.id}`)}
                  style={{ cursor: "pointer" }}
                >
                  <div className="card h-100 shadow-sm">
                    <img src={song.thumbnail_url} alt={song.song_name} className="card-img-top" />
                    <div className="card-body">
                      <h5 className="card-title">{song.song_name}</h5>
                      <p className="card-text">Bài hát này đã bị ẩn bởi nhân viên của artist</p>
                      <p className="card-text"><strong>Lý do bị ẩn:</strong> {song.hidden_reason}</p>
                      <a href={song.song_url} target="_blank" rel="noopener noreferrer" className="btn btn-dark">
                        Nghe bài hát
                      </a>
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <p>Không có bài hát bị ẩn.</p>
            )}
          </div>
        </div>
  
        {/* Danh sách bài hát bị ẩn bởi hệ thống */}
        <div className="mb-5">
          <h3 className="mb-3">Danh sách bài hát bị ẩn bởi hệ thống</h3>
          <div className="row">
            {hiddenSongs.length > 0 ? (
              hiddenSongs.map((song) => (
                <div key={song.id} className="col-md-3 mb-4">
                  <div className="card h-100 shadow-sm">
                    <img src={song.thumbnail_url} alt={song.song_name} className="card-img-top" />
                    <div className="card-body">
                      <h5 className="card-title">{song.song_name}</h5>
                      <p className="card-text">Bài hát này đã bị ẩn bởi nhân viên của hệ thống.</p>
                      <p className="card-text"><strong>Lý do bị ẩn:</strong> {song.hidden_reason}</p>
                      <a href={song.song_url} target="_blank" rel="noopener noreferrer" className="btn btn-dark">
                        Nghe bài hát
                      </a>
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <p>Không có bài hát bị ẩn.</p>
            )}
          </div>
        </div>
  
      </div>
    </div>
  );
  
  
}

export default TrangArt;
