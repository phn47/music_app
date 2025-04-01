import React, { useState } from "react";
import { Link, Outlet } from "react-router-dom";
import LogoutButton from "./LogoutButton";
import "@fortawesome/fontawesome-free/css/all.min.css"; // Import Font Awesome

function Artist() {
  const [headerTitle, setHeaderTitle] = useState("Trang Nhân Viên");

  const handleMenuClick = (title) => {
    setHeaderTitle(title);
  };

  return (
    <div className="d-flex flex-column" style={{ minHeight: "100vh" }}>
      {/* Header */}
      <header
  style={{
    backgroundColor: "#000000",
    color: "#ffffff",
    padding: "10px 20px",
    position: "sticky",
    top: 0,
    zIndex: 1000,
    display: "flex",
    justifyContent: "space-between", // Đảm bảo header có không gian đều giữa các phần tử
    alignItems: "center",
    boxShadow: "0 2px 4px rgba(0, 0, 0, 0.3)",
  }}
>
  {/* Title */}
  <div
    style={{
      fontSize: "1.8rem",
      fontWeight: "bold",
      position: "absolute",
      left: "50%",
      transform: "translateX(-50%)", // Center title
    }}
  >
    {headerTitle}
  </div>

  {/* Nút Home, Thanh Cá Nhân và Đăng Xuất */}
  <div className="d-flex align-items-center" style={{ marginLeft: "auto" }}>
    <Link to="/nhanvien" title="Home" style={{ color: "#ffffff", marginRight: "20px" }}>
      <i className="fas fa-home fs-4"></i>
    </Link>

    {/* Nút Thanh Cá Nhân (Icon người dùng) */}
    <Link to="/nhanvien/thongtincanhan" title="Thanh Cá Nhân" style={{ color: "#ffffff", marginRight: "20px" }}>
      <i className="fas fa-user fs-4"></i> {/* Icon người dùng */}
    </Link>

    <LogoutButton />
  </div>
</header>

      {/* Sidebar và Nội dung */}
      <div className="d-flex" style={{ flexGrow: 1 }}>
        {/* Sidebar */}
        <div className="bg-dark text-white p-3" style={{ width: "250px", minHeight: "100vh" }}>
          <h4 className="text-center mb-4">Quản Lý</h4>
          <ul className="nav flex-column gap-2">
         
        
        
            <li>
              <Link
                to="/artist/trangart"
                className="nav-link text-white"
                onClick={() => handleMenuClick("Quản Lý Bài Hát")}
              >
                ➤ Quản Lý Bài Hát
              </Link>
            </li>
            <li>
              <Link
                to="/artist/quanlyablumart"
                className="nav-link text-white"
                onClick={() => handleMenuClick("Quản Lý Albums")}
              >
                ➤ Quản Lý Albums
              </Link>
            </li>
          </ul>
        </div>

        {/* Nội dung động */}
        <div className="p-4 flex-grow-1" style={{ backgroundColor: "#f8f9fa", overflowY: "auto" }}>
          <Outlet />
        </div>
      </div>
    </div>
  );
}

export default Artist;
