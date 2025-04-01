import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";

function AnAlbumByArt() {
  const [artist, setArtist] = useState(null); // Thông tin nghệ sĩ
  const [loading, setLoading] = useState(true); // Trạng thái loading
  const [error, setError] = useState(""); // Thông báo lỗi
  const [actionMessage, setActionMessage] = useState(""); // Thông báo khi thực hiện ẩn bài hát
  const [hiddenReason, setHiddenReason] = useState(""); // Lý do ẩn bài hát

  const location = useLocation(); // Hook để lấy thông tin URL
  const songId = new URLSearchParams(location.search).get("id"); // Lấy ID bài hát từ URL

  useEffect(() => {
    const fetchArtist = async () => {
      try {
        const token = localStorage.getItem("token"); // Lấy token từ localStorage
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

        // Gọi API để lấy thông tin chi tiết bài hát đã duyệt
        const response = await fetch(`http://127.0.0.1:8000/albums/song/songtrue/${songId}`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": token,
          },
        });

        if (!response.ok) {
          throw new Error("Không thể tải dữ liệu Albums.");
        }

        const data = await response.json();
        setArtist(data.artist); // Lưu thông tin nghệ sĩ vào state
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    fetchArtist();
  }, [songId]);

  const handleHideSong = async () => {
    if (!hiddenReason.trim()) {
      setActionMessage("Vui lòng nhập lý do ẩn Albums.");
      return;
    }

    try {
      const token = localStorage.getItem("token"); // Lấy token từ localStorage
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      // Gọi API để ẩn bài hát
      const response = await fetch(`http://127.0.0.1:8000/albums/album/bannedbyart/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
        body: JSON.stringify({
          hidden_reason: hiddenReason, // Truyền lý do ẩn bài hát
        }),
      });

      if (!response.ok) {
        throw new Error("Không thể ẩn Albums.");
      }

      setActionMessage("Albums đã được ẩn thành công!");
      setHiddenReason(""); // Reset trường lý do
    } catch (error) {
      setActionMessage(error.message);
    }
  };

  return (
    <div className="container mt-5" style={{ fontFamily: "Segoe UI Black" }}>
      {loading ? (
        <p className="text-center text-muted">Đang tải dữ liệu...</p>
      ) : error ? (
        <div className="alert alert-danger text-center" role="alert">
          {error}
        </div>
      ) : artist ? (
        <div className="card shadow-sm">
          <div className="card-body">
            <h2 className="card-title text-center">{artist.name}</h2>
            <div className="text-center">
              <img
                src={artist.thumbnail_url}
                alt={artist.name}
                className="img-fluid rounded my-3"
                style={{ maxWidth: "200px" }}
              />
            </div>
            <p className="card-text"><strong>Tên:</strong> {artist.name}</p>
            <p className="card-text"><strong>Mô tả:</strong> {artist.description}</p>
            <p className="card-text"><strong>Created At:</strong> {new Date(artist.created_at).toLocaleDateString()}</p>
            <p className="card-text"><strong>Updated At:</strong> {new Date(artist.updated_at).toLocaleDateString()}</p>
  
            {/* Form nhập lý do */}
            <div className="mb-3">
              <label htmlFor="hidden-reason" className="form-label">
                Lý do ẩn Albums:
              </label>
              <textarea
                id="hidden-reason"
                className="form-control"
                value={hiddenReason}
                onChange={(e) => setHiddenReason(e.target.value)}
                placeholder="Nhập lý do tại đây..."
                required
              ></textarea>
            </div>
  
            {/* Nút hành động */}
            <div className="text-center">
              <button onClick={handleHideSong} className="btn btn-dark me-2">
                Ẩn Album
              </button>
              {/* <button onClick={handleHideSong} className="btn btn-dark">
                Phê duyệt bài hát
              </button> */}
            </div>
  
            {/* Thông báo sau khi thực hiện */}
            {actionMessage && (
              <div className="alert alert-success mt-3 text-center" role="alert">
                {actionMessage}
              </div>
            )}
          </div>
        </div>
      ) : (
        <p className="text-center text-muted">Không tìm thấy Albums.</p>
      )}
    </div>
  );
  
}

export default AnAlbumByArt;
// setHiddenReason
// handleHideSong