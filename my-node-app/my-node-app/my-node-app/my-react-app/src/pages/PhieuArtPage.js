import React, { useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import 'bootstrap/dist/css/bootstrap.min.css';

const defaultImage = "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

function PhieuArtPage() {
  const location = useLocation();
  const navigate = useNavigate();
  const { artist } = location.state || {};
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  if (!artist) {
    return (
      <div className="container py-5">
        <div className="row justify-content-center">
          <div className="col-lg-8">
            <div className="alert alert-danger text-center shadow-sm slide-in-down">
              <i className="fas fa-exclamation-circle me-2"></i>
              Không có dữ liệu nghệ sĩ.
            </div>
          </div>
        </div>
      </div>
    );
  }

  const handleApproveArtist = async () => {
    setLoading(true);
    setError("");
    setSuccess(false);

    try {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Bạn chưa đăng nhập.");

      const response = await fetch(
        `http://127.0.0.1:8000/auth/approve/${artist.id}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": token,
          },
        }
      );

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.detail || "Không thể phê duyệt nghệ sĩ.");
      }

      setSuccess(true);
      setTimeout(() => {
        navigate("/nhanvien/quanlyartist");
      }, 1500);
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container py-5">
      <div className="row justify-content-center">
        <div className="col-lg-8">
          <div className="card shadow-lg border-0 overflow-hidden fade-in-up">
            <div className="card-header text-white text-center py-4 gradient-animation">
              <button
                className="btn-close btn-close-white shadow-none position-absolute top-0 end-0 m-3"
                onClick={() => navigate("//nhanvien/quanlyartist")}
                style={{
                  transition: 'transform 0.2s',
                  zIndex: 10,
                  opacity: 0.8,
                  padding: '12px'
                }}
                onMouseOver={e => e.target.style.transform = 'rotate(90deg)'}
                onMouseOut={e => e.target.style.transform = 'rotate(0deg)'}
              ></button>
              <div className="position-relative">
                <img
                  src={artist.image_url || defaultImage}
                  className="rounded-circle border-4 border-white shadow-lg zoom-in"
                  alt={artist.name}
                  style={{
                    width: "150px",
                    height: "150px",
                    objectFit: "cover",
                    marginTop: "20px"
                  }}
                />

              </div>
            </div>

            <div className="card-body p-4">
              <div className="text-center mb-4 slide-in-right">
                <h3 className="fw-bold mb-2">{artist.nomarlized_name}</h3>
                <p className="text-muted mb-3">
                  <i className="fas fa-user me-2 bounce"></i>
                  Nghệ sĩ mới
                </p>
              </div>

              <div className="bg-light p-4 rounded-3 hover-effect mb-4 slide-in-left">
                <div className="row mb-3">
                  <div className="col-md-4">
                    <p className="fw-bold mb-0">
                      <i className="fas fa-user me-2 text-primary"></i>
                      Tên nghệ sĩ:
                    </p>
                  </div>
                  <div className="col-md-8">
                    <p className="mb-0">{artist.normalized_name}</p>
                  </div>
                </div>

                <div className="row mb-3">
                  <div className="col-md-4">
                    <p className="fw-bold mb-0">
                      <i className="fas fa-book me-2 text-primary"></i>
                      Tiểu sử:
                    </p>
                  </div>
                  <div className="col-md-8">
                    <p className="mb-0">{artist.bio || "Không có thông tin giới thiệu."}</p>
                  </div>
                </div>

                <div className="row mb-3">
                  <div className="col-md-4">
                    <p className="fw-bold mb-0">
                      <i className="fas fa-calendar-alt me-2 text-primary"></i>
                      Ngày tạo:
                    </p>
                  </div>
                  <div className="col-md-8">
                    <p className="mb-0">{new Date(artist.created_at).toLocaleDateString('vi-VN')}</p>
                  </div>
                </div>
              </div>

              {!artist.is_approved && (
                <div className="d-grid gap-2 slide-in-up">
                  <button
                    onClick={handleApproveArtist}
                    disabled={loading}
                    className="btn btn-success btn-lg pulse-effect"
                  >
                    {loading ? (
                      <>
                        <span className="spinner-border spinner-border-sm me-2"></span>
                        Đang xử lý...
                      </>
                    ) : (
                      <>
                        <i className="fas fa-check-circle me-2"></i>
                        Phê Duyệt Nghệ Sĩ
                      </>
                    )}
                  </button>
                </div>
              )}

              {error && (
                <div className="alert alert-danger mt-4 text-center animate__animated animate__shakeX">
                  <i className="fas fa-exclamation-circle me-2"></i>
                  {error}
                </div>
              )}

              {success && (
                <div className="alert alert-success mt-4 text-center animate__animated animate__bounceIn">
                  <i className="fas fa-check-circle me-2"></i>
                  Đã phê duyệt nghệ sĩ thành công!
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      <style jsx>{`
          @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
          }

          @keyframes slideInDown {
            from { transform: translateY(-30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
          }

          @keyframes slideInUp {
            from { transform: translateY(30px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
          }

          @keyframes slideInRight {
            from { transform: translateX(30px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
          }

          @keyframes slideInLeft {
            from { transform: translateX(-30px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
          }

          @keyframes zoomIn {
            from { transform: scale(0.8); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
          }

          @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
          }

          @keyframes gradient {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
          }

          .fade-in { animation: fadeIn 0.5s ease-in-out; }
          .fade-in-up { animation: slideInUp 0.5s ease-out; }
          .slide-in-down { animation: slideInDown 0.5s ease-out; }
          .slide-in-right { animation: slideInRight 0.5s ease-out; }
          .slide-in-left { animation: slideInLeft 0.5s ease-out; }
          .zoom-in { animation: zoomIn 0.5s ease-out; }
          .bounce { animation: pulse 1s ease infinite; }
          .pulse-effect:hover { animation: pulse 1s infinite; }

          .gradient-animation {
            background: linear-gradient(45deg, rgb(188, 204, 46), rgb(160, 174, 39), rgb(193, 204, 46));
            background-size: 200% 200%;
            animation: gradient 5s ease infinite;
          }

          .hover-effect {
            transition: all 0.3s ease;
          }

          .hover-effect:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
          }

          .card {
            border-radius: 20px;
          }

          .btn {
            border-radius: 10px;
            transition: all 0.3s ease;
          }

          .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
          }
        `}</style>
    </div>
  );
}

export default PhieuArtPage;
