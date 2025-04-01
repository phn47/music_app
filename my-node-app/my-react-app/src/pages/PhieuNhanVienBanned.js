import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";

const defaultImage =
  "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

function PhieuNhanVienBanned() {
  const [song, setSong] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [actionMessage, setActionMessage] = useState("");
  const [hiddenReason, setHiddenReason] = useState("");
  const [isEditing, setIsEditing] = useState(false);  // Trạng thái chỉnh sửa
  const [isHiding, setIsHiding] = useState(false);
  const [editedSong, setEditedSong] = useState({});

  const location = useLocation();
  const songId = new URLSearchParams(location.search).get("id");

  useEffect(() => {
    const fetchSong = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

        const response = await fetch(
          `http://127.0.0.1:8000/auth/songtrue2/${songId}`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "x-auth-token": token,
            },
          }
        );

        if (!response.ok) {
          throw new Error("Không thể tải dữ liệu nhân viên.");
        }

        const data = await response.json();
        setSong(data);
        setEditedSong(data);
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    fetchSong();
  }, [songId]);

  const handleHideSong = async () => {
    if (!hiddenReason.trim()) {
      setActionMessage("Vui lòng nhập lý do ẩn nhân viên.");
      return;
    }

    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      const response = await fetch(
        `http://127.0.0.1:8000/auth/song/songnone2/${songId}`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": token,
          },
          body: JSON.stringify({
            hidden_reason: hiddenReason,
          }),
        }
      );

      if (!response.ok) {
        throw new Error("Không thể ẩn nhân viên.");
      }

      setActionMessage("Nhân viên đã được ẩn thành công!");
      setHiddenReason("");
      setIsHiding(false); // Đóng phần nhập lý do sau khi ẩn
    } catch (error) {
      setActionMessage(error.message);
    }
  };

  const handleSaveChanges = async () => {
    if (
      editedSong.name === song.name &&
      editedSong.email === song.email
    ) {
      setActionMessage("Không có thay đổi nào để lưu.");
      return;
    }

    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      const response = await fetch(
        `http://127.0.0.1:8000/auth/update/${songId}`,  // Đường dẫn API
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": token,
          },
          body: JSON.stringify({
            name: editedSong.name,
            email: editedSong.email,
          }),
        }
      );

      if (!response.ok) {
        throw new Error("Không thể lưu thay đổi.");
      }

      const data = await response.json();
      setSong(data);  // Cập nhật lại thông tin bài hát
      setActionMessage("Cập nhật thành công!");
      setIsEditing(false);  // Đóng chế độ chỉnh sửa
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
          ) : song ? (
            <div className="card shadow-lg border-0 overflow-hidden fade-in-up">
              <div className="card-header text-white text-center py-4 gradient-animation">
                <div className="position-relative">
                  <img
                    src={song.thumbnail_url || defaultImage}
                    className="rounded-circle border-4 border-white shadow-lg zoom-in"
                    alt={song.name}
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
                  {isEditing ? (
                    <input
                      type="text"
                      className="form-control form-control-lg mb-3 text-center fw-bold"
                      value={editedSong.name || ""}
                      onChange={(e) => setEditedSong({ ...editedSong, name: e.target.value })}
                      placeholder="Nhập tên nhân viên"
                    />
                  ) : (
                    <h3 className="fw-bold mb-2">{song.name}</h3>
                  )}
                  <p className="text-muted mb-3">
                    <i className="fas fa-user me-2 bounce"></i>
                    Nhân viên
                  </p>
                </div>

                <div className="row justify-content-center slide-in-left">
                  <div className="col-md-10">
                    <div className="bg-light p-4 rounded-3 hover-effect mb-4">
                      {isEditing ? (
                        <div className="form-floating mb-3">
                          <input
                            type="email"
                            className="form-control"
                            value={editedSong.email || ""}
                            onChange={(e) => setEditedSong({ ...editedSong, email: e.target.value })}
                            placeholder="Nhập email"
                          />
                          <label>Email</label>
                        </div>
                      ) : (
                        <p className="mb-0"><strong>Email:</strong> {song.email}</p>
                      )}
                    </div>

                    {isHiding && (
                      <div className="form-floating mb-4 slide-in-up">
                        <textarea
                          className="form-control bg-light hover-effect"
                          value={hiddenReason}
                          onChange={(e) => setHiddenReason(e.target.value)}
                          placeholder="Nhập lý do tại đây..."
                          style={{ height: "120px", resize: "none" }}
                          required
                        ></textarea>
                        <label>Lý do ẩn nhân viên</label>
                      </div>
                    )}

                    <div className="d-grid gap-2">
                      {isEditing ? (
                        <div className="d-flex gap-2">
                          <button onClick={handleSaveChanges} className="btn btn-success btn-lg w-50 pulse-effect">
                            <i className="fas fa-save me-2"></i>
                            Lưu thay đổi
                          </button>
                          <button onClick={() => setIsEditing(false)} className="btn btn-secondary btn-lg w-50">
                            <i className="fas fa-times me-2"></i>
                            Hủy
                          </button>
                        </div>
                      ) : (
                        <button onClick={() => setIsEditing(true)} className="btn btn-primary btn-lg mb-3 pulse-effect">
                          <i className="fas fa-edit me-2"></i>
                          Chỉnh sửa
                        </button>
                      )}

                      {isHiding ? (
                        <div className="d-flex gap-2">
                          <button onClick={handleHideSong} className="btn btn-danger btn-lg w-50 pulse-effect">
                            <i className="fas fa-ban me-2"></i>
                            Xác nhận ẩn
                          </button>
                          <button onClick={() => setIsHiding(false)} className="btn btn-secondary btn-lg w-50">
                            <i className="fas fa-times me-2"></i>
                            Hủy
                          </button>
                        </div>
                      ) : (
                        <button onClick={() => setIsHiding(true)} className="btn btn-dark btn-lg pulse-effect">
                          <i className="fas fa-eye-slash me-2"></i>
                          Ẩn nhân viên
                        </button>
                      )}
                    </div>
                  </div>
                </div>

                {actionMessage && (
                  <div className="alert alert-info text-center mx-auto mt-4 fade-in">
                    <i className="fas fa-info-circle me-2"></i>
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
        }

        .form-control {
          border-radius: 10px;
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

export default PhieuNhanVienBanned;
