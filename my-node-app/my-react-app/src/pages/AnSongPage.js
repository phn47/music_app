import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";

function AnSongPage() {
  const [song, setSong] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [actionMessage, setActionMessage] = useState("");
  const [hiddenReason, setHiddenReason] = useState("");

  const location = useLocation();
  const navigate = useNavigate();
  const songId = new URLSearchParams(location.search).get("id");

  useEffect(() => {
    fetchSong();
  }, [songId]);

  const fetchSong = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Bạn chưa đăng nhập.");

      const response = await fetch(`http://127.0.0.1:8000/songs/songtrue/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) throw new Error("Không thể tải dữ liệu bài hát.");
      const data = await response.json();
      setSong(data);
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleHideSong = async () => {
    if (!hiddenReason.trim()) {
      setActionMessage("Vui lòng nhập lý do ẩn bài hát.");
      return;
    }

    try {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Bạn chưa đăng nhập.");

      const response = await fetch(`http://127.0.0.1:8000/songs/song/songnone/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
        body: JSON.stringify({ hidden_reason: hiddenReason }),
      });

      if (!response.ok) throw new Error("Không thể ẩn bài hát.");

      setActionMessage("Bài hát đã được ẩn thành công!");
      setHiddenReason("");
      setTimeout(() => navigate(-1), 1500);
    } catch (error) {
      setActionMessage(error.message);
    }
  };

  return (
    <div className="container py-5">
      <div className="row justify-content-center">
        <div className="col-md-8">
          {loading ? (
            <div className="text-center py-5">
              <div className="spinner-border text-primary" role="status">
                <span className="visually-hidden">Đang tải...</span>
              </div>
            </div>
          ) : error ? (
            <div className="alert alert-danger text-center" role="alert">
              <i className="fas fa-exclamation-circle me-2"></i>
              {error}
            </div>
          ) : song ? (
            <div className="card shadow">

              <div className="card-header bg-primary text-white p-3">
                <div className="d-flex justify-content-between align-items-center">
                  <button
                    className="btn btn-light btn-sm"
                    onClick={() => navigate(-1)}
                  >
                    <i className="fas fa-arrow-left me-2"></i>
                    Quay lại
                  </button>
                  <h4 className="mb-0">
                    <i className="fas fa-music me-2"></i>
                    Chi tiết bài hát
                  </h4>

                </div>
              </div>

              <div className="card-body">
                <div className="text-center mb-4">
                  <img
                    src={song.thumbnail_url || "https://via.placeholder.com/300x300.png?text=No+Image"}
                    alt={song.song_name}
                    className="img-fluid rounded shadow-sm"
                    style={{ maxWidth: "300px" }}
                  />
                  <h5 className="mt-3">{song.song_name}</h5>
                </div>

                <div className="audio-player text-center mb-4">
                  <audio controls className="w-100">
                    <source src={song.song_url} type="audio/mpeg" />
                    Trình duyệt của bạn không hỗ trợ phát nhạc.
                  </audio>
                </div>

                <div className="song-info mb-4">
                  <table className="table table-hover">
                    <tbody>
                      <tr>
                        <th style={{ width: "150px" }}>
                          <i className="fas fa-hashtag me-2"></i>
                          Hex Code:
                        </th>
                        <td>{song.hex_code}</td>
                      </tr>
                      <tr>
                        <th>
                          <i className="fas fa-info-circle me-2"></i>
                          Trạng thái:
                        </th>
                        <td>
                          <span className="badge bg-success">
                            {song.status}
                          </span>
                        </td>
                      </tr>
                      <tr>
                        <th>
                          <i className="fas fa-users me-2"></i>
                          Nghệ sĩ:
                        </th>
                        <td>{song.artist_names?.join(", ") || "Không có"}</td>
                      </tr>
                      <tr>
                        <th>
                          <i className="fas fa-tags me-2"></i>
                          Thể loại:
                        </th>
                        <td>{song.genre_names?.join(", ") || "Không có"}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div className="hidden-form">
                  <div className="form-group mb-3">
                    <label className="form-label">
                      <i className="fas fa-comment-alt me-2"></i>
                      Lý do ẩn bài hát:
                    </label>
                    <textarea
                      className="form-control"
                      value={hiddenReason}
                      onChange={(e) => setHiddenReason(e.target.value)}
                      placeholder="Nhập lý do tại đây..."
                      rows="3"
                      required
                    ></textarea>
                  </div>

                  <div className="text-center">
                    <button
                      onClick={handleHideSong}
                      className="btn btn-danger"
                      disabled={!hiddenReason.trim()}
                    >
                      <i className="fas fa-eye-slash me-2"></i>
                      Ẩn bài hát
                    </button>
                  </div>

                  {actionMessage && (
                    <div className={`alert alert-${actionMessage.includes("thành công") ? "success" : "danger"} mt-3`}>
                      <i className={`fas fa-${actionMessage.includes("thành công") ? "check" : "exclamation"}-circle me-2`}></i>
                      {actionMessage}
                    </div>
                  )}
                </div>
              </div>
            </div>
          ) : (
            <div className="alert alert-info text-center" role="alert">
              <i className="fas fa-info-circle me-2"></i>
              Không tìm thấy bài hát.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default AnSongPage;
