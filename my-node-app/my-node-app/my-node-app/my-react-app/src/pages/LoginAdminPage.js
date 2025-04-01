import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
// import "E:/my-node-app/my-node-app/my-react-app/src/css/LoginAdminPage.css";

const LoginAdminPage = () => {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [rememberMe, setRememberMe] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch("http://127.0.0.1:8000/auth/loginadmin", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email,
          password: password,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        setError(errorData.detail || "Login failed!");
        return;
      }

      const data = await response.json();
      localStorage.setItem("token", data.token);
      localStorage.setItem("role", data.user.role);

      if (data.user.role === "admin") {
        navigate("/admin");
      } else {
        setError("This account does not have admin privileges.");
      }
    } catch (err) {
      console.error("Login error:", err);
      setError("Something went wrong. Please try again later.");
    }
  };

  return (
    <div className="admin-login-container">
      <nav className="top-nav">
        {/* <div className="nav-brand">Material Dashboard 2</div>
        <div className="nav-links">
          <a href="/dashboard">Dashboard</a>
          <a href="/profile">Profile</a>
          <a href="/signup">Sign Up</a>
          <a href="/signin">Sign In</a>
          <button className="download-btn">FREE DOWNLOAD</button>
        </div> */}
      </nav>

      <div className="login-card">
        <h2>Đăng nhập</h2>

        <div className="social-login">
          <button className="social-btn facebook">
            <i className="fab fa-facebook-f"></i>
          </button>
          <button className="social-btn github">
            <i className="fab fa-github"></i>
          </button>
          <button className="social-btn google">
            <i className="fab fa-google"></i>
          </button>
        </div>

        <form onSubmit={handleLogin}>
          <div className="form-group">
            <input
              type="email"
              placeholder="Email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          <div className="remember-me">
            <label>
              <input
                type="checkbox"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
              />
              <span>Ghi nhớ tôi</span>
            </label>
          </div>

          {error && <div className="error-message">{error}</div>}

          <button type="submit" className="sign-in-btn">
            Đăng nhập
          </button>

          <div className="signup-link">
            Bạn chưa có tài khoản? <a href="/signup">Đăng ký</a>
          </div>
        </form>
      </div>


      <footer className="footer">
        {/* <div className="footer-left">
          © 2024, made with ♥ by Creative Tim for a better web.
        </div>
        <div className="footer-right">
          <a href="/creative-tim">Creative Tim</a>
          <a href="/about-us">About Us</a>
          <a href="/blog">Blog</a>
          <a href="/license">License</a>
        </div> */}
      </footer>
    </div>
  );
};

export default LoginAdminPage;