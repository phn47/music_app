import React from "react";
import { useNavigate } from "react-router-dom";

function LogoutButton() {
  const navigate = useNavigate();

  const handleLogout = () => {
    // Xóa token khỏi localStorage
    localStorage.removeItem("token");
    // Chuyển hướng đến trang đăng nhập
    navigate("/");
  };

  return (
    <button onClick={handleLogout} className="logout-button">
      Đăng xuất
    </button>
  );
}

export default LogoutButton;
