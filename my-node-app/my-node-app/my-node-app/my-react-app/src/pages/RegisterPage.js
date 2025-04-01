import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";

function RegisterPage() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const navigate = useNavigate();

  const handleRegister = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setSuccess("");

    if (password !== confirmPassword) {
      setError("Mật khẩu không khớp!");
      setLoading(false);
      return;
    }

    try {
      const response = await fetch("http://127.0.0.1:8000/auth/signup", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ name, email, password }),
      });

      if (response.ok) {
        setSuccess("Đăng ký thành công!");
        navigate("/login");
      } else {
        throw new Error("Đăng ký không thành công. Hãy thử lại.");
      }
    } catch (error) {
      setError(error.message || "Đã xảy ra lỗi khi đăng ký.");
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
          width: "100%",
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
          Đăng Ký Tài Khoản
        </h2>

        {/* Form đăng ký */}
        <form onSubmit={handleRegister}>
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
              placeholder="Nhập tên của bạn"
              required
              style={{ backgroundColor: "#fff", color: "#000", borderColor: "#000" }}
            />
          </div>

          {/* Email */}
          <div className="mb-3">
            <label
              htmlFor="email"
              className="form-label fw-bold"
              style={{ color: "#000" }}
            >
              Email:
            </label>
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

          {/* Xác nhận mật khẩu */}
          <div className="mb-3">
            <label
              htmlFor="confirmPassword"
              className="form-label fw-bold"
              style={{ color: "#000" }}
            >
              Xác nhận mật khẩu:
            </label>
            <input
              type="password"
              className="form-control"
              id="confirmPassword"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Nhập lại mật khẩu"
              required
              style={{ backgroundColor: "#fff", color: "#000", borderColor: "#000" }}
            />
          </div>

          {/* Nút đăng ký */}
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
            {loading ? "Đang xử lý..." : "Đăng Ký"}
          </button>
        </form>

        {/* Thông báo lỗi */}
        {error && <p className="text-danger mt-3 text-center">{error}</p>}
        {/* Thông báo thành công */}
        {success && (
          <p className="text-success mt-3 text-center">{success}</p>
        )}

        {/* Điều hướng đến trang đăng nhập */}
        <div className="text-center mt-4">
          <p style={{ color: "#000", fontWeight: "bold" }}>
            Đã có tài khoản?{" "}
            <a
              href="/login"
              style={{
                color: "#000",
                textDecoration: "underline",
              }}
            >
              Đăng nhập ngay
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}

export default RegisterPage;
