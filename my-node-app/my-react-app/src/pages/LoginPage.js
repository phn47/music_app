import React, { useState } from "react";
import { useNavigate } from "react-router-dom"; // Import useNavigate
import "bootstrap/dist/css/bootstrap.min.css"; // Thêm Bootstrap

function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const navigate = useNavigate(); // Khởi tạo useNavigate để điều hướng

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setSuccess("");

    try {
      const response = await fetch("http://127.0.0.1:8000/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
      });

      if (response.ok) {
        const data = await response.json();
        console.log("Login response:", data); // Kiểm tra dữ liệu trả về

        setSuccess("Đăng nhập thành công!");

        // Lưu token vào localStorage
        localStorage.setItem("token", data.token);
        localStorage.setItem("artist_id", data.user.id);

        // Kiểm tra giá trị role trong đối tượng user
        if (data.user.role && data.user.role.trim() === "moderator") {
          navigate("/nhanvien"); // Chuyển hướng đến trang /nhanvien cho "moderator"
        }

        if (data.user.role && data.user.role.trim() === "admin") {
          navigate("/admin/thongke"); // Chuyển hướng đến trang /nhanvien cho "moderator"
        }
        else if (data.user.role && data.user.role.trim() === "user") {
          navigate("/song-list"); // Chuyển hướng đến trang /song-list cho "user"
        }
        if (data.user.role && data.user.role.trim() === "artist") {
          navigate("/artist/"); // Chuyển hướng đến trang /trangart cho "artist"
        } else {
          setError("Vai trò không hợp lệ.");
        }
      } else {
        throw new Error("Sai email hoặc mật khẩu!");
      }
    } catch (error) {
      setError(error.message || "Đã xảy ra lỗi khi đăng nhập.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container d-flex justify-content-center align-items-center" style={{ minHeight: "100vh", backgroundColor: "#f8f9fa" }}>
      <div className="card shadow-lg p-4" style={{ width: "100%", maxWidth: "400px", borderRadius: "10px", backgroundColor: "#fff", border: "2px solid #000" }}>
        <h2 className="text-center mb-4" style={{ color: "#000", fontFamily: "Segoe UI Black" }}>Đăng Nhập</h2>
        <form onSubmit={handleLogin}>
          <div className="mb-3">
            <label htmlFor="email" className="form-label" style={{ color: "#000", fontFamily: "Segoe UI Black" }}>Email</label>
            <input
              type="email"
              className="form-control"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Nhập email"
              required
              style={{ backgroundColor: "#fff", color: "#000", borderColor: "#000" }}
            />
          </div>
          <div className="mb-3">
            <label htmlFor="password" className="form-label" style={{ color: "#000", fontFamily: "Segoe UI Black" }}>Mật khẩu</label>
            <input
              type="password"
              className="form-control"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Nhập mật khẩu"
              required
              style={{ backgroundColor: "#fff", color: "#000", borderColor: "#000" }}
            />
          </div>
          <button
            type="submit"
            className="btn w-100"
            disabled={loading}
            style={{ backgroundColor: "#000", color: "#fff", fontFamily: "Segoe UI Black", fontWeight: "bold", borderColor: "#000" }}
          >
            {loading ? "Đang xử lý..." : "Đăng Nhập"}
          </button>
        </form>

        {error && <p className="text-danger mt-3">{error}</p>}
        {success && <p className="text-success mt-3">{success}</p>}

        <div className="mt-4 text-center">
          {/* <p style={{ color: "#000", fontFamily: "Segoe UI Black" }}>Bạn chưa có tài khoản? <a href="/register" style={{ color: "#000" }}>Đăng ký</a></p> */}
          <p style={{ color: "#000", fontFamily: "Segoe UI Black" }}>Bạn chưa có tài khoản nghệ sĩ? <a href="/dangkyart" style={{ color: "#000" }}>Đăng ký</a></p>
        </div>
      </div>
    </div>
  );
}

export default LoginPage;
