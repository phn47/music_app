import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";

function SignUpArtistPage() {
  const [artistName, setArtistName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const navigate = useNavigate();

  const handleSignUp = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setSuccess(false);

    if (password !== confirmPassword) {
      setError("Mật khẩu xác nhận không khớp.");
      setLoading(false);
      return;
    }

    try {
      const response = await fetch("http://127.0.0.1:8000/artist/signup", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email,
          name: artistName,
          password: password,
        }),
      });

      if (response.ok) {
        const data = await response.json();
        console.log("Artist signed up:", data);
        setSuccess(true);
        navigate("/login");
      } else {
        const errorData = await response.json();
        throw new Error(errorData.detail || "Lỗi khi đăng ký.");
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
        className="card p-4 shadow-lg"
        style={{
          width: "100%",
          maxWidth: "400px",
          borderRadius: "10px",
          border: "2px solid #000",
          backgroundColor: "#fff",
        }}
      >
        <h2
          className="text-center mb-4"
          style={{ color: "#000", fontFamily: "Segoe UI Black" }}
        >
          Đăng Ký Nghệ Sĩ
        </h2>
        <form onSubmit={handleSignUp}>
          {/* Email */}
          <div className="mb-3">
            <label
              htmlFor="email"
              className="form-label"
              style={{ color: "#000", fontFamily: "Segoe UI Black" }}
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

          {/* Tên nghệ sĩ */}
          <div className="mb-3">
            <label
              htmlFor="artistName"
              className="form-label"
              style={{ color: "#000", fontFamily: "Segoe UI Black" }}
            >
              Tên Nghệ Sĩ:
            </label>
            <input
              type="text"
              className="form-control"
              id="artistName"
              value={artistName}
              onChange={(e) => setArtistName(e.target.value)}
              placeholder="Nhập tên nghệ sĩ"
              required
              style={{ backgroundColor: "#fff", color: "#000", borderColor: "#000" }}
            />
          </div>

          {/* Mật khẩu */}
          <div className="mb-3">
            <label
              htmlFor="password"
              className="form-label"
              style={{ color: "#000", fontFamily: "Segoe UI Black" }}
            >
              Mật Khẩu:
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
              className="form-label"
              style={{ color: "#000", fontFamily: "Segoe UI Black" }}
            >
              Xác Nhận Mật Khẩu:
            </label>
            <input
              type="password"
              className="form-control"
              id="confirmPassword"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Xác nhận mật khẩu"
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
              fontFamily: "Segoe UI Black",
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
          <p className="text-success mt-3 text-center">Đăng ký thành công!</p>
        )}

        {/* Chuyển hướng đăng nhập */}
        <div className="text-center mt-4">
          <p style={{ color: "#000", fontFamily: "Segoe UI Black" }}>
            Đã có tài khoản nghệ sĩ?{" "}
            <a href="/loginart" style={{ color: "#000", textDecoration: "underline" }}>
              Đăng nhập
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}

export default SignUpArtistPage;
