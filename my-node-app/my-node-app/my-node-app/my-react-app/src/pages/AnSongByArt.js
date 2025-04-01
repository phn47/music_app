import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css"; // Đảm bảo đã cài đặt Bootstrap

function AnSongByArt() {
  const [song, setSong] = useState(null); // Thông tin bài hát
  const [loading, setLoading] = useState(true); // Trạng thái loading
  const [error, setError] = useState(""); // Thông báo lỗi
  const [actionMessage, setActionMessage] = useState(""); // Thông báo khi thực hiện ẩn bài hát

  const location = useLocation(); // Hook để lấy thông tin URL
  const songId = new URLSearchParams(location.search).get("id"); // Lấy ID bài hát từ URL

  useEffect(() => {
    const fetchSong = async () => {
      try {
        const token = localStorage.getItem("token"); // Lấy token từ localStorage
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

        // Gọi API để lấy thông tin chi tiết bài hát đã duyệt
        const response = await fetch(`http://127.0.0.1:8000/songs/songtrue/${songId}`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": token,
          },
        });

        if (!response.ok) {
          throw new Error("Không thể tải dữ liệu bài hát.");
        }

        const data = await response.json();
        setSong(data); // Lưu thông tin bài hát vào state
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    fetchSong();
  }, [songId]);

  const handleHideSong = async () => {
    try {
      const token = localStorage.getItem("token"); // Lấy token từ localStorage
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      // Gọi API để ẩn bài hát
      const response = await fetch(`http://127.0.0.1:8000/songs/song/songnone14/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) {
        throw new Error("Không thể ẩn bài hát.");
      }

      const data = await response.json();
      setActionMessage("Bài hát đã được ẩn thành công!");
    } catch (error) {
      setActionMessage(error.message);
    }
  };

  return (
    <div className="container py-5" style={{ backgroundColor: "black", color: "white", fontFamily: "'Segoe UI Black', sans-serif" }}>
      {loading ? (
        <div className="d-flex justify-content-center">
          <div className="spinner-border text-primary" role="status">
            <span className="sr-only">Đang tải...</span>
          </div>
        </div>
      ) : error ? (
        <p className="text-center text-danger">{error}</p>
      ) : song ? (
        <div className="card text-white bg-dark shadow-sm">
          <img
            src={song.thumbnail_url || "https://via.placeholder.com/500x300.png?text=No+Image"}
            alt={song.song_name}
            className="card-img-top"
            style={{ objectFit: "cover", height: "300px" }}
          />
          <div className="card-body">
            <h5 className="card-title">{song.song_name}</h5>
            <audio controls className="w-100 mb-3">
              <source src={song.song_url} type="audio/mpeg" />
              Trình duyệt của bạn không hỗ trợ phát nhạc.
            </audio>
            <p className="card-text">
              <strong>Created At:</strong> {song.created_at}
            </p>
            <p className="card-text">
              <strong>Updated At:</strong> {song.updated_at}
            </p>
            {song.artist_names && (
              <p className="card-text">
                <strong>Artists:</strong> {song.artist_names.join(", ")}
              </p>
            )}
            {song.genre_names && (
              <p className="card-text">
                <strong>Genres:</strong> {song.genre_names.join(", ")}
              </p>
            )}

            {/* Nút Ẩn bài hát */}
            <button onClick={handleHideSong} className="btn btn-dark">
              Ẩn bài hát
            </button>

            {/* Thông báo sau khi thực hiện ẩn bài hát */}
            {actionMessage && <div className="alert alert-info mt-3">{actionMessage}</div>}
          </div>
        </div>
      ) : (
        <p>Không tìm thấy bài hát.</p>
      )}
    </div>
  );
}

export default AnSongByArt;
