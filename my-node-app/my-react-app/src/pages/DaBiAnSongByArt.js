import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import 'bootstrap/dist/css/bootstrap.min.css';

function DaBiAnSongByArt() {
  const [songDetails, setSongDetails] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [unhideMessage, setUnhideMessage] = useState("");
  const location = useLocation();
  const navigate = useNavigate();

  const queryParams = new URLSearchParams(location.search);
  const songId = queryParams.get("id");

  useEffect(() => {
    const fetchSongDetails = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

        const response = await fetch(`http://127.0.0.1:8000/songs/songnone/${songId}`, {
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
        setSongDetails(data);
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    if (songId) {
      fetchSongDetails();
    }
  }, [songId]);

  const unhideSong = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      const response = await fetch(`http://127.0.0.1:8000/songs/song/songtrue/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) {
        throw new Error("Không thể gỡ ẩn bài hát.");
      }

      setUnhideMessage("Bài hát đã được gỡ ẩn thành công!");
      setTimeout(() => {
        navigate('/nhanvien/quanlysong');
      }, 2000);
    } catch (error) {
      setError(error.message);
    }
  };

  return (
    <div className="container-fluid py-4">
      <div className="card">
        <div className="card-header p-3">
          <div className="row align-items-center">
            <div className="col">
              <h3 className="mb-0">Chi tiết bài hát bị ẩn</h3>
            </div>
            <div className="col text-end">
              <button
                className="btn btn-secondary me-2"
                onClick={() => navigate('/nhanvien/quanlysong')}
              >
                Quay lại
              </button>
              <button
                className="btn btn-primary"
                onClick={unhideSong}
              >
                Gỡ ẩn bài hát
              </button>
            </div>
          </div>
        </div>

        <div className="card-body">
          {loading ? (
            <div className="text-center py-4">
              <div className="spinner-border text-primary" role="status">
                <span className="visually-hidden">Đang tải...</span>
              </div>
            </div>
          ) : error ? (
            <div className="alert alert-danger" role="alert">
              {error}
            </div>
          ) : songDetails ? (
            <div className="row">
              <div className="col-md-4">
                <div className="position-relative" style={{ paddingBottom: '100%' }}>
                  <img
                    src={songDetails.thumbnail_url}
                    alt={songDetails.song_name}
                    className="position-absolute w-100 h-100"
                    style={{ objectFit: 'cover', top: 0, left: 0 }}
                  />
                </div>
                <div className="mt-3">
                  <audio controls className="w-100">
                    <source src={songDetails.song_url} type="audio/mpeg" />
                    Trình duyệt của bạn không hỗ trợ phát nhạc.
                  </audio>
                </div>
              </div>
              <div className="col-md-8">
                <table className="table">
                  <tbody>
                    <tr>
                      <th style={{ width: '200px' }}>Tên bài hát:</th>
                      <td>{songDetails.song_name}</td>
                    </tr>
                    <tr>
                      <th>Trạng thái:</th>
                      <td>
                        <span className="badge bg-danger">
                          Đã ẩn
                        </span>
                      </td>
                    </tr>
                    <tr>
                      <th>Mã màu:</th>
                      <td>{songDetails.hex_code}</td>
                    </tr>
                    <tr>
                      <th>Ngày tạo:</th>
                      <td>{new Date(songDetails.created_at).toLocaleDateString('vi-VN')}</td>
                    </tr>
                    <tr>
                      <th>Ngày cập nhật:</th>
                      <td>{new Date(songDetails.updated_at).toLocaleDateString('vi-VN')}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          ) : (
            <div className="alert alert-info" role="alert">
              Không tìm thấy thông tin bài hát.
            </div>
          )}

          {unhideMessage && (
            <div className="alert alert-success mt-3" role="alert">
              {unhideMessage}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default DaBiAnSongByArt;
