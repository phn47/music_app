import React, { useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";

const defaultImage = "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

function PhieuArtBanned() {
  const location = useLocation();
  const navigate = useNavigate();
  const artist = location.state?.artist;
  const [alert, setAlert] = useState({ show: false, message: '', type: '' });

  if (!artist) {
    return (
      <div className="container py-5">
        <div className="alert alert-info text-center" role="alert">
          <i className="fas fa-info-circle me-2"></i>
          Không có thông tin nghệ sĩ để hiển thị.
        </div>
      </div>
    );
  }

  const handleRestore = async () => {
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

      if (!response.ok) throw new Error("Không thể khôi phục nghệ sĩ.");

      setAlert({
        show: true,
        message: 'Nghệ sĩ đã được khôi phục thành công!',
        type: 'success'
      });

      setTimeout(() => {
        navigate("/nhanvien/quanlyartist");
      }, 1500);
    } catch (error) {
      setAlert({
        show: true,
        message: error.message,
        type: 'danger'
      });
    }
  };

  return (
    <div className="container py-5">
      <div className="row justify-content-center">
        <div className="col-lg-8">
          {!artist ? (
            <div className="alert alert-danger text-center shadow-sm slide-in-down">
              <i className="fas fa-exclamation-circle me-2"></i>
              Không có thông tin nghệ sĩ để hiển thị.
            </div>
          ) : (
            <div className="card shadow-lg border-0 overflow-hidden fade-in-up">
              {alert.show && (
                <div className={`alert alert-${alert.type} alert-dismissible fade show text-center m-3 slide-in-down`} role="alert">
                  <i className={`fas fa-${alert.type === 'success' ? 'check' : 'exclamation'}-circle me-2`}></i>
                  {alert.message}
                  <button type="button" className="btn-close" onClick={() => setAlert({ ...alert, show: false })}></button>
                </div>
              )}
              <div className="card-header text-white text-center py-4 gradient-animation">
                <button
                  className="btn-close btn-close-white shadow-none position-absolute top-0 end-0 m-3"
                  onClick={() => navigate("/nhanvien/quanlyartist")}
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
                  <span className="position-absolute badge bg-danger rounded-pill bounce"
                    style={{
                      zIndex: 10,
                      padding: "8px 15px",
                      fontSize: "0.9rem",
                      right: "-10px",
                      bottom: "-5px"
                    }}>
                    <i className="fas fa-eye-slash me-1"></i>
                    Bị ẩn
                  </span>
                </div>
              </div>

              <div className="card-body p-4">
                <div className="text-center mb-4 slide-in-right">
                  <h3 className="fw-bold mb-2">{artist.normalized_name}</h3>
                  <p className="text-muted mb-3">
                    <i className="fas fa-user-slash me-2 bounce"></i>
                    Nghệ sĩ bị ẩn
                  </p>
                </div>

                <div className="bg-light p-4 rounded-3 hover-effect mb-4 slide-in-left">
                  <div className="row mb-3">
                    <div className="col-md-4">
                      <p className="fw-bold mb-0">
                        <i className="fas fa-id-card me-2 text-primary"></i>
                        ID:
                      </p>
                    </div>
                    <div className="col-md-8">
                      <p className="mb-0">{artist.id}</p>
                    </div>
                  </div>

                  <div className="row mb-3">
                    <div className="col-md-4">
                      <p className="fw-bold mb-0">
                        <i className="fas fa-info-circle me-2 text-primary"></i>
                        Tiểu sử:
                      </p>
                    </div>
                    <div className="col-md-8">
                      <p className="mb-0">{artist.bio || "Không có thông tin."}</p>
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

                <div className="d-grid gap-2 slide-in-up">
                  <button
                    onClick={handleRestore}
                    className="btn btn-success btn-lg pulse-effect"
                  >
                    <i className="fas fa-user-check me-2"></i>
                    Khôi Phục Nghệ Sĩ
                  </button>
                </div>
              </div>
            </div>
          )}
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
          background: linear-gradient(45deg, #dc3545, #b02a37, #dc3545);
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

export default PhieuArtBanned;
