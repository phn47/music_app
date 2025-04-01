import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
import 'bootstrap/dist/css/bootstrap.min.css';

const defaultImage = "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

function DaBiAnNhanVien() {
  const [songDetails, setSongDetails] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [unhideMessage, setUnhideMessage] = useState("");
  const location = useLocation();
  const queryParams = new URLSearchParams(location.search);
  const songId = queryParams.get("id");

  useEffect(() => {
    const fetchSongDetails = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

        const response = await fetch(`http://127.0.0.1:8000/auth/songnone3/${songId}`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": token,
          },
        });

        if (!response.ok) {
          throw new Error("Không thể tải dữ liệu  nhân viên.");
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

      const response = await fetch(`http://127.0.0.1:8000/auth/song/songtrue3/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) {
        throw new Error("Không thể gỡ ẩn  nhân viên.");
      }

      const data = await response.json();
      setUnhideMessage(" nhân viên đã được gỡ ẩn thành công!");
    } catch (error) {
      setError(error.message);
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
          ) : songDetails ? (
            <div className="card shadow-lg border-0 overflow-hidden fade-in-up">
              <div className="card-header text-white text-center py-4 gradient-animation">
                <div className="position-relative">
                  <img
                    src={songDetails.thumbnail_url || defaultImage}
                    className="rounded-circle border-4 border-white shadow-lg zoom-in"
                    alt={songDetails.song_name}
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
                  <h3 className="fw-bold mb-2">{songDetails.song_name}</h3>
                  <p className="text-muted mb-3">
                    <i className="fas fa-music me-2 bounce"></i>
                    nhân viên đã bị ẩn
                  </p>
                </div>

                <div className="row mb-4 slide-in-left">
                  <div className="col-md-12">
                    <div className="bg-light p-3 rounded hover-effect">
                      <p><strong>Tên Nhân Viên:</strong> {songDetails.status}</p>
                      <p><strong>Ngày tạo:</strong> {new Date(songDetails.created_at).toLocaleDateString()}</p>
                    </div>
                  </div>
                </div>

                <div className="row justify-content-center slide-in-left">
                  <div className="col-md-8">
                    <audio controls className="w-100 mb-4">
                      <source src={songDetails.song_url} type="audio/mpeg" />
                      Trình duyệt của bạn không hỗ trợ phát nhạc.
                    </audio>

                    <div className="d-grid gap-2">
                      <button
                        onClick={unhideSong}
                        className="btn btn-success btn-lg pulse-effect"
                      >
                        <i className="fas fa-eye me-2"></i>
                        Gỡ ẩn  nhân viên
                      </button>
                    </div>
                  </div>
                </div>

                {unhideMessage && (
                  <div className="alert alert-success text-center mx-auto mt-4 fade-in">
                    <i className="fas fa-check-circle me-2 swing"></i>
                    {unhideMessage}
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
          background: linear-gradient(45deg,rgb(46, 122, 204), #27ae60, #2ecc71);
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

        .btn-success {
          background-color:rgb(46, 64, 204);
          border-color:rgb(46, 72, 204);
        }

        .btn-success:hover {
          background-color:rgb(39, 88, 174);
          border-color:rgb(39, 39, 174);
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(46, 80, 204, 0.3);
        }
      `}</style>
    </div>
  );
}

export default DaBiAnNhanVien;
