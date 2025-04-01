import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";

function LoginPage() {
  const [name, setName] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setSuccess("");

    try {
      const response = await fetch("http://127.0.0.1:8000/artist/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email: name, password }),
      });

      if (response.ok) {
        const data = await response.json();
        console.log("Login response:", data);

        setSuccess("Đăng nhập thành công!");
        localStorage.setItem("token", data.token);
        localStorage.setItem("artist_id", data.user.id);

        // Chuyển hướng sau khi đăng nhập thành công
        navigate("/trangart");
      } else {
        throw new Error("Sai tên hoặc mật khẩu!");
      }
    } catch (error) {
      setError(error.message || "Đã xảy ra lỗi khi đăng nhập.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      className="container d-flex justify-content-center align-items-center"
      style={{ minHeight: "100vh", backgroundColor: "#fff" }}
    >
      <div
        className="card shadow-lg p-4"
        style={{
          width: "30%",
          maxWidth: "500px",
          borderRadius: "12px",
          border: "2px solid #000",
          backgroundColor: "#fff",
        }}
      >
        {/* Tiêu đề */}
        <h2
          className="text-center mb-4"
          style={{ color: "#000", fontFamily: "Segoe UI Black" }}
        >
          Đăng Nhập 
        </h2>

        {/* Form đăng nhập */}
        <form onSubmit={handleLogin}>
          {/* Tên */}
          <div className="mb-3">
            <label
              htmlFor="name"
              className="form-label fw-bold"
              style={{ color: "#000" }}
            >
              Tên:
            </label>
            <input
              type="text"
              className="form-control"
              id="name"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Nhập tên"
              required
              style={{ backgroundColor: "#fff", color: "#000", borderColor: "#000" }}
            />
          </div>

          {/* Mật khẩu */}
          <div className="mb-3">
            <label
              htmlFor="password"
              className="form-label fw-bold"
              style={{ color: "#000" }}
            >
              Mật khẩu:
            </label>
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

          {/* Nút đăng nhập */}
          <button
            type="submit"
            className="btn w-100"
            disabled={loading}
            style={{
              backgroundColor: "#000",
              color: "#fff",
              fontWeight: "bold",
              border: "2px solid #000",
            }}
          >
            {loading ? "Đang xử lý..." : "Đăng Nhập"}
          </button>
        </form>

        {/* Thông báo lỗi */}
        {error && <p className="text-danger mt-3 text-center">{error}</p>}
        {/* Thông báo thành công */}
        {success && (
          <p className="text-success mt-3 text-center">{success}</p>
        )}

        {/* Điều hướng */}
        <div className="text-center mt-4">
          <p style={{ color: "#000", fontWeight: "bold" }}>
            Bạn là nghệ sĩ chưa có tài khoản?{" "}
            <a
              href="/dangkyart"
              style={{
                color: "#000",
                textDecoration: "underline",
              }}
            >
              Đăng ký 
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}

export default LoginPage;
