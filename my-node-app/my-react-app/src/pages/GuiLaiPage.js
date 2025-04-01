import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";

function GuiLaiPage() {
  const [song, setSong] = useState(null); // Thông tin bài hát
  const [loading, setLoading] = useState(true); // Trạng thái loading
  const [error, setError] = useState(""); // Thông báo lỗi
  const [actionMessage, setActionMessage] = useState(""); // Thông báo khi thực hiện ẩn bài hát
//   const [hiddenReason, setHiddenReason] = useState(""); // Lý do ẩn bài hát

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
        const response = await fetch(`http://127.0.0.1:8000/song/songguilai/${songId}`, {
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
      const response = await fetch(`http://127.0.0.1:8000/song/song/duyetsong3/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
        body: JSON.stringify({
        //   "hidden_reason": hiddenReason, // Truyền lý do ẩn bài hát
        }),
      });

      if (!response.ok) {
        throw new Error("Không thể ẩn bài hát.");
      }

      const data = await response.json();
      setActionMessage("Bài hát đã được ẩn thành công!");
    //   setHiddenReason(""); // Reset trường lý do
    } catch (error) {
      setActionMessage(error.message);
    }
  };

  return (
    <div className="ansong-container">
      {loading ? (
        <p>Đang tải dữ liệu...</p>
      ) : error ? (
        <p className="error-message">{error}</p>
      ) : song ? (
        <div className="song-details">
          <h2>{song.song_name}</h2>
          <img src={song.thumbnail_url} alt={song.song_name} />
          <audio controls>
            <source src={song.song_url} type="audio/mpeg" />
            Trình duyệt của bạn không hỗ trợ phát nhạc.
          </audio>
          {/* <p>Hex Code: {song.hex_code}</p>
          <p>Status: {song.status}</p> */}
          <p>Created At: {song.created_at}</p>
          <p>Updated At: {song.updated_at}</p>
          {song.artist_names && <p>Artists: {song.artist_names.join(", ")}</p>}
          {song.genre_names && <p>Genres: {song.genre_names.join(", ")}</p>}

          {/* Form nhập lý do ẩn bài hát */}
          {/* <div className="hide-song-form">
            <label htmlFor="hidden-reason">Lý do ẩn bài hát:</label>
            <textarea
              id="hidden-reason"
              value={hiddenReason}
              onChange={(e) => setHiddenReason(e.target.value)}
              placeholder="Nhập lý do tại đây..."
              required
            ></textarea>
          </div> */}

          {/* Nút Ẩn bài hát */}
          <button onClick={handleHideSong} className="hide-song-button">
            Yêu cầu phê duyệt lại
          </button>

          {/* Thông báo sau khi thực hiện ẩn bài hát */}
          {actionMessage && <p className="action-message">{actionMessage}</p>}
        </div>
      ) : (
        <p>Không tìm thấy bài hát.</p>
      )}
    </div>
  );
}

export default GuiLaiPage;
