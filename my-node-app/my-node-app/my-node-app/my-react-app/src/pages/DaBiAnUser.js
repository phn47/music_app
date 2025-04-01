import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import 'bootstrap/dist/css/bootstrap.min.css';

const defaultImage = "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

function DaBiAnUser() {
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

      const response = await fetch(`http://127.0.0.1:8000/auth/songnone1/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) throw new Error("Không thể tải dữ liệu người dùng.");
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

      const response = await fetch(`http://127.0.0.1:8000/auth/song/songtrue1/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) throw new Error("Không thể gỡ ẩn người dùng.");

      setUnhideMessage("Người dùng đã được gỡ ẩn thành công!");
      if (setUnhideMessage == true) {
        // Quay lại trang trước khi người dùng thực hiện hành động này
        navigate(-1);
      }

      setTimeout(() => navigate("/admin/quanlyuser"), 2000);
    } catch (error) {
      setError(error.message);
    }
  };

  return (
    <div className="container-fluid py-4">
      <div className="card shadow-lg">
        <div className="card-header bg-gradient p-3">
          <div className="row align-items-center">
            <div className="col">

            </div>
            <div className="col text-end">
              <button
                className="btn btn-light"
                onClick={() => navigate("/admin/quanlyuser")}
              >
                <i className="fas fa-arrow-left me-2"></i>
                Quay lại
              </button>
            </div>
          </div>
        </div>

        <div className="card-body">
          {loading ? (
            <div className="text-center py-5">
              <div className="spinner-border text-primary" role="status">
                <span className="visually-hidden">Đang tải...</span>
              </div>
            </div>
          ) : error ? (
            <div className="alert alert-danger" role="alert">
              <i className="fas fa-exclamation-circle me-2"></i>
              {error}
            </div>
          ) : songDetails ? (
            <div className="row">
              <div className="col-md-4 text-center">
                <div className="position-relative mb-4">
                  <img
                    src={songDetails.thumbnail_url || defaultImage}
                    alt={songDetails.name}
                    className="img-fluid rounded-circle shadow"
                    style={{
                      width: "200px",
                      height: "200px",
                      objectFit: "cover"
                    }}
                  />
                  <div className="position-absolute bottom-0 end-0">
                    <span className="badge bg-danger rounded-pill">
                      <i className="fas fa-ban me-1"></i>
                      Đã bị ẩn
                    </span>
                  </div>
                </div>
              </div>

              <div className="col-md-8">
                <div className="card shadow-sm">
                  <div className="card-body">
                    <h5 className="card-title mb-4">
                      <i className="fas fa-info-circle me-2"></i>
                      Thông tin chi tiết
                    </h5>
                    <table className="table table-hover">
                      <tbody>
                        <tr>
                          <th style={{ width: "150px" }}>
                            <i className="fas fa-user me-2"></i>
                            Họ và tên:
                          </th>
                          <td>{songDetails.name}</td>
                        </tr>
                        <tr>
                          <th>
                            <i className="fas fa-envelope me-2"></i>
                            Email:
                          </th>
                          <td>{songDetails.email}</td>
                        </tr>
                        <tr>
                          <th>
                            <i className="fas fa-calendar-plus me-2"></i>
                            Ngày tạo:
                          </th>
                          <td>{new Date(songDetails.created_at).toLocaleDateString('vi-VN')}</td>
                        </tr>
                      </tbody>
                    </table>

                    <div className="text-center mt-4">
                      <button
                        className="btn btn-success"
                        onClick={unhideSong}
                      >
                        <i className="fas fa-user-check me-2"></i>
                        Gỡ ẩn người dùng
                      </button>
                    </div>

                    {unhideMessage && (
                      <div className="alert alert-success mt-3">
                        <i className="fas fa-check-circle me-2"></i>
                        {unhideMessage}
                      </div>
                    )}
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="alert alert-info" role="alert">
              <i className="fas fa-info-circle me-2"></i>
              Không tìm thấy thông tin người dùng.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default DaBiAnUser;
