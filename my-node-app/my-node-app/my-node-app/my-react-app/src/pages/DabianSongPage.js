import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import 'bootstrap/dist/css/bootstrap.min.css';

function DabianSongPage() {
  const [songDetails, setSongDetails] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [unhideMessage, setUnhideMessage] = useState("");
  const location = useLocation();
  const navigate = useNavigate();

  const songId = new URLSearchParams(location.search).get("id");

  useEffect(() => {
    fetchSongDetails();
  }, [songId]);

  const fetchSongDetails = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Bạn chưa đăng nhập.");

      const response = await fetch(`http://127.0.0.1:8000/songs/songnone/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) throw new Error("Không thể tải dữ liệu bài hát.");
      const data = await response.json();
      setSongDetails(data);
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const unhideSong = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Bạn chưa đăng nhập.");

      const response = await fetch(`http://127.0.0.1:8000/songs/song/songtrue/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) throw new Error("Không thể gỡ ẩn bài hát.");

      setUnhideMessage("Bài hát đã được gỡ ẩn thành công!");
      navigate("/nhanvien/quanlysong");
      setTimeout(() => navigate('/nhanvien/quanlysong'), 2000);
    } catch (error) {
      setError(error.message);
    }
  };

  return (
    <div className="container py-5">
      <div className="row justify-content-center">
        <div className="col-md-10">
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
          ) : songDetails ? (
            <div className="card shadow">
              <div className="card-header bg-primary text-white p-4">
                <div className="d-flex justify-content-between align-items-center">
                  <h4 className="mb-0">
                    <i className="fas fa-music me-2"></i>
                    Chi tiết bài hát bị ẩn
                  </h4>
                  <div>
                    <button
                      className="btn btn-light me-2"
                      onClick={() => navigate('/nhanvien/quanlysong')}
                    >
                      <i className="fas fa-arrow-left me-2"></i>
                      Quay lại
                    </button>

                  </div>
                </div>
              </div>

              <div className="card-body p-4">
                <div className="text-center mb-4">
                  <img
                    src={songDetails.thumbnail_url}
                    alt={songDetails.song_name}
                    className="img-fluid rounded shadow-sm"
                    style={{ maxWidth: "300px", height: "300px", objectFit: "cover" }}
                  />
                  <h3 className="mt-3">{songDetails.song_name}</h3>
                </div>

                <div className="row justify-content-center mb-4">
                  <div className="col-md-8">
                    <div className="audio-player text-center">
                      <audio controls className="w-100">
                        <source src={songDetails.song_url} type="audio/mpeg" />
                        Trình duyệt của bạn không hỗ trợ phát nhạc.
                      </audio>
                    </div>
                  </div>
                </div>

                <div className="row justify-content-center">
                  <div className="col-md-8">
                    <table className="table table-hover">
                      <tbody>
                        <tr>
                          <th style={{ width: "200px" }}>
                            <i className="fas fa-hashtag me-2"></i>
                            Mã màu:
                          </th>
                          <td>
                            <span className="badge" style={{ backgroundColor: songDetails.hex_code }}>
                              {songDetails.hex_code}
                            </span>
                          </td>
                        </tr>
                        <tr>
                          <th>
                            <i className="fas fa-calendar-alt me-2"></i>
                            Ngày tạo:
                          </th>
                          <td>{new Date(songDetails.created_at).toLocaleDateString('vi-VN')}</td>
                        </tr>
                        <tr>
                          <th>
                            <i className="fas fa-clock me-2"></i>
                            Cập nhật:
                          </th>
                          <td>{new Date(songDetails.updated_at).toLocaleDateString('vi-VN')}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
                <div className="d-flex justify-content-center mt-4">
                  <button
                    className="btn btn-success btn-lg"
                    onClick={unhideSong}
                  >
                    <i className="fas fa-eye me-2"></i>
                    Gỡ ẩn bài hát
                  </button>
                </div>
                {unhideMessage && (
                  <div className="alert alert-success text-center mt-4" role="alert">
                    <i className="fas fa-check-circle me-2"></i>
                    {unhideMessage}
                  </div>
                )}
              </div>
            </div>
          ) : (
            <div className="alert alert-info text-center" role="alert">
              <i className="fas fa-info-circle me-2"></i>
              Không tìm thấy thông tin bài hát.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default DabianSongPage;
