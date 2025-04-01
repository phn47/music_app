import React, { useEffect, useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";

const defaultImage = "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

function AnAlbum() {
  const [artist, setArtist] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const [actionMessage, setActionMessage] = useState("");
  const [hiddenReason, setHiddenReason] = useState("");

  const location = useLocation();
  const songId = new URLSearchParams(location.search).get("id");
  const navigate = useNavigate();

  useEffect(() => {
    const fetchArtist = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

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
        setArtist(data.artist);
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
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      const response = await fetch(`http://127.0.0.1:8000/albums/album/banned/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
        body: JSON.stringify({
          hidden_reason: hiddenReason,
        }),
      });

      if (!response.ok) {
        throw new Error("Không thể ẩn Albums.");
      }

      setActionMessage("Albums đã được ẩn thành công!");
      navigate("/nhanvien/quanlysong");

      setHiddenReason("");
    } catch (error) {
      setActionMessage(error.message);
    }
  };

  return (
    <div className="container py-5">
      <div className="row justify-content-center">
        <div className="col-lg-8">
          {loading ? (
            <div className="text-center py-5 fade-in">
              <div className="spinner-grow text-primary" role="status">
                <span className="visually-hidden">Đang tải...</span>
              </div>
            </div>
          ) : error ? (
            <div className="alert alert-danger text-center shadow-sm slide-in-down">
              <i className="fas fa-exclamation-circle me-2"></i>{error}
            </div>
          ) : artist ? (
            <div className="card shadow-lg border-0 overflow-hidden fade-in-up">
              <div className="card-header text-white text-center py-4 gradient-animation">
                <div className="position-relative">
                  <img
                    src={artist.thumbnail_url || defaultImage}
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
                  <h3 className="fw-bold mb-2">{artist.name}</h3>
                  <p className="text-muted mb-3">
                    <i className="fas fa-music me-2 bounce"></i>
                    Album
                  </p>
                </div>

                <div className="row justify-content-center slide-in-left">
                  <div className="col-md-8">
                    <div className="form-floating mb-4">
                      <textarea
                        className="form-control bg-light hover-effect"
                        value={hiddenReason}
                        onChange={(e) => setHiddenReason(e.target.value)}
                        placeholder="Nhập lý do tại đây..."
                        style={{ height: "120px", resize: "none" }}
                        required
                      ></textarea>
                      <label>Lý do ẩn Album</label>
                    </div>

                    <div className="d-grid gap-2">
                      <button
                        onClick={handleHideSong}
                        className="btn btn-danger btn-lg pulse-effect"
                      >
                        <i className="fas fa-ban me-2"></i>
                        Ẩn Album
                      </button>
                    </div>
                  </div>
                </div>

                {actionMessage && (
                  <div className="alert alert-info text-center mx-auto mt-4 fade-in">
                    <i className="fas fa-info-circle me-2 swing"></i>
                    {actionMessage}
                  </div>
                )}
              </div>
            </div>
          ) : null}
        </div>
      </div>

      <style jsx>{`
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }

        @keyframes slideInDown {
          from {
            transform: translateY(-30px);
            opacity: 0;
          }
          to {
            transform: translateY(0);
            opacity: 1;
          }
        }

        @keyframes slideInUp {
          from {
            transform: translateY(30px);
            opacity: 0;
          }
          to {
            transform: translateY(0);
            opacity: 1;
          }
        }

        @keyframes slideInRight {
          from {
            transform: translateX(30px);
            opacity: 0;
          }
          to {
            transform: translateX(0);
            opacity: 1;
          }
        }

        @keyframes slideInLeft {
          from {
            transform: translateX(-30px);
            opacity: 0;
          }
          to {
            transform: translateX(0);
            opacity: 1;
          }
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

        @keyframes swing {
          20% { transform: rotate(15deg); }
          40% { transform: rotate(-10deg); }
          60% { transform: rotate(5deg); }
          80% { transform: rotate(-5deg); }
          100% { transform: rotate(0deg); }
        }

        @keyframes gradient {
          0% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }

        .fade-in {
          animation: fadeIn 0.5s ease-in-out;
        }

        .fade-in-up {
          animation: slideInUp 0.5s ease-out;
        }

        .slide-in-down {
          animation: slideInDown 0.5s ease-out;
        }

        .slide-in-right {
          animation: slideInRight 0.5s ease-out;
        }

        .slide-in-left {
          animation: slideInLeft 0.5s ease-out;
        }

        .zoom-in {
          animation: zoomIn 0.5s ease-out;
        }

        .bounce {
          animation: swing 1s ease infinite;
        }

        .pulse-effect:hover {
          animation: pulse 1s infinite;
        }

        .gradient-animation {
          background: linear-gradient(45deg, #4e73df, #224abe, #4e73df);
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
          transition: all 0.3s ease;
        }

        .btn-danger {
          transition: all 0.3s ease;
        }

        .btn-danger:hover {
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(220,53,69,0.3);
        }
      `}</style>
    </div>
  );
}

export default AnAlbum;