import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
const defaultImage =
  "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

function ThongTinCaNhan() {
  const [song, setSong] = useState(null); // Thông tin bài hát
  const [loading, setLoading] = useState(true); // Trạng thái loading
  const [error, setError] = useState(""); // Thông báo lỗi
  const [actionMessage, setActionMessage] = useState(""); // Thông báo khi thực hiện hành động
  const [name, setName] = useState(""); // Giá trị chỉnh sửa name
  const [email, setEmail] = useState(""); // Giá trị chỉnh sửa email
  const [currentPassword, setCurrentPassword] = useState(""); // Mật khẩu hiện tại
  const [newPassword, setNewPassword] = useState(""); // Mật khẩu mới

  const location = useLocation(); // Hook để lấy thông tin URL
  const songId = new URLSearchParams(location.search).get("id"); // Lấy ID bài hát từ URL

  useEffect(() => {
    const fetchSong = async () => {
      try {
        const token = localStorage.getItem("token"); // Lấy token từ localStorage
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

        // Gọi API để lấy thông tin chi tiết bài hát đã duyệt
        const response = await fetch(`http://127.0.0.1:8000/auth/nhanvien`, {
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
        setSong(data); // Lưu thông tin bài hát vào state
        setName(data.name || "");
        setEmail(data.email || "");
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    fetchSong();
  }, [songId]);

  const handleUpdateSong = async () => {
    try {
      const token = localStorage.getItem("token"); // Lấy token từ localStorage
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      // Gọi API để cập nhật thông tin bài hát
      const response = await fetch(`http://127.0.0.1:8000/auth/update`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
        body: JSON.stringify({
          name,
          email,
        }),
      });

      if (!response.ok) {
        throw new Error("Không thể cập nhật thông tin.");
      }

      setActionMessage("Thông tin đã được cập nhật thành công!");
    } catch (error) {
      setActionMessage(error.message);
    }
  };

  const handleChangePassword = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      // Gọi API đổi mật khẩu
      const response = await fetch(`http://127.0.0.1:8000/auth/change-password2`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
        body: JSON.stringify({
          current_password: currentPassword,
          new_password: newPassword,
        }),
      });

      if (!response.ok) {
        throw new Error("Không thể đổi mật khẩu.");
      }

      setActionMessage("Mật khẩu đã được đổi thành công!");
      setCurrentPassword(""); // Reset input
      setNewPassword("");
    } catch (error) {
      setActionMessage(error.message);
    }
  };
  return (
    <div className="container py-5" style={{ fontFamily: 'Segoe UI', color: 'black', backgroundColor: 'white' }}>
      {loading ? (
        <div className="d-flex justify-content-center">
          <div className="spinner-border text-primary" role="status">
            <span className="sr-only">Đang tải...</span>
          </div>
        </div>
      ) : error ? (
        <p className="text-danger text-center">{error}</p>
      ) : song ? (
        <div className="card shadow-lg border-0">
          <div className="row g-0">
            <div className="col-md-4">
              <img
                src={song.thumbnail_url || defaultImage}
                className="img-fluid rounded-start"
                alt={song.song_name}
                style={{ objectFit: "cover", height: "100%", maxHeight: "450px" }}
              />
            </div>
            <div className="col-md-8">
              <div className="card-body p-4">
                <h3 className="card-title text-dark mb-4">{song.song_name}</h3>
                <hr />
                <div className="mb-4">
                  <label className="form-label fw-bold text-dark">Tên</label>
                  <input
                    type="text"
                    className="form-control rounded-pill"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="Nhập tên bài hát"
                  />
                </div>
  
                <div className="mb-4">
                  <label className="form-label fw-bold text-dark">Email</label>
                  <input
                    type="email"
                    className="form-control rounded-pill"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="Nhập email"
                  />
                </div>
  
                <button className="btn btn-primary rounded-pill px-4" onClick={handleUpdateSong}>
                  Cập nhật thông tin
                </button>
  
                <div className="mt-5">
                  <h5 className="fw-bold">Đổi mật khẩu</h5>
                  <div className="mb-4">
                    <label className="form-label fw-bold text-dark">Mật khẩu hiện tại</label>
                    <input
                      type="password"
                      className="form-control rounded-pill"
                      value={currentPassword}
                      onChange={(e) => setCurrentPassword(e.target.value)}
                      placeholder="Nhập mật khẩu hiện tại"
                    />
                  </div>
  
                  <div className="mb-4">
                    <label className="form-label fw-bold text-dark">Mật khẩu mới</label>
                    <input
                      type="password"
                      className="form-control rounded-pill"
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      placeholder="Nhập mật khẩu mới"
                    />
                  </div>
  
                  <button className="btn btn-warning rounded-pill px-4" onClick={handleChangePassword}>
                    Đổi mật khẩu
                  </button>
                </div>
  
                {actionMessage && <div className="alert alert-info mt-4">{actionMessage}</div>}
              </div>
            </div>
          </div>
        </div>
      ) : (
        <p className="text-center text-muted">Không tìm thấy bài hát.</p>
      )}
    </div>
  );
  
}

export default ThongTinCaNhan;
