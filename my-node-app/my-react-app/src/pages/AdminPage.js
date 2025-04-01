import React, { useState, useEffect } from "react";
import { Link, Outlet, useNavigate } from "react-router-dom";
import "@fortawesome/fontawesome-free/css/all.min.css";

function AdminPage() {
  const navigate = useNavigate();
  const [headerText, setHeaderText] = useState("Chào Mừng Đến Trang Admin");

  useEffect(() => {
    const token = localStorage.getItem("token");
    const role = localStorage.getItem("role");

    // Kiểm tra token và vai trò
    if (!token) {
      navigate("/login");
    }
  }, [navigate]);

  const handleLogout = () => {
    localStorage.clear(); // Xóa toàn bộ dữ liệu trong localStorage
    navigate("/login");
  };

  const handleLinkClick = (text) => {
    setHeaderText(text);
  };

  return (
    <div style={{ minHeight: "100vh", display: "flex", flexDirection: "column" }}>
      {/* Header */}
      <header
        style={{
          backgroundColor: "#000000",
          color: "#ffffff",
          padding: "10px 20px",
          position: "sticky",
          top: 0,
          zIndex: 10,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          boxShadow: "0 2px 4px rgba(0, 0, 0, 0.3)",
        }}
      >
        {/* Text ở giữa Header */}
        <div
          style={{
            position: "absolute",
            left: "58%",
            transform: "translateX(-50%)",
            fontSize: "1.8rem",
            fontWeight: "bold",
          }}
        >
          {headerText}
        </div>


        {/* Phần icon Home và nút Đăng Xuất */}
        <div style={{ display: "flex", alignItems: "center", gap: "15px", marginLeft: "auto" }}>
          {/* Icon Home */}
          <Link to="/admin/thongke" title="Home" style={{ color: "#ffffff" }}>
            <i className="fas fa-home fs-4"></i>
          </Link>
          <Link to="/admin/thongtincanhan" title="Trang cá nhân" style={{ color: "#ffffff" }}>
            <i className="fas fa-user fs-4"></i>
          </Link>
          {/* Nút Đăng Xuất */}
          <button
            className="btn"
            style={{
              backgroundColor: "#ffffff",
              color: "#000000",
              fontWeight: "bold",
              borderRadius: "4px",
              padding: "6px 12px",
              border: "none",
            }}
            onClick={handleLogout}
          >
            Đăng Xuất
          </button>
        </div>
      </header>

      <div style={{ display: "flex", flexGrow: 1 }}>
        {/* Sidebar */}
        <aside
          style={{
            position: "fixed",
            top: 0,
            left: 0,
            bottom: 0,
            width: "240px",
            backgroundColor: "#1c1c1c",
            color: "#ffffff",
            padding: "20px",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
            boxShadow: "2px 0 5px rgba(0, 0, 0, 0.2)",
            zIndex: 10,
          }}
        >
          <div>
            <h4
              className="text-center mb-4"
              style={{ fontWeight: "bold", fontSize: "1.4rem" }}
            >
              Admin Of Music
            </h4>
            <nav>
              <ul className="nav flex-column gap-3">
                <li>
                  <Link
                    to="/admin/addtl"
                    className="nav-link"
                    style={{
                      color: "#ffffff",
                      textDecoration: "none",
                      padding: "8px 0",
                    }}
                    onClick={() => handleLinkClick("Thêm Nhân Viên")}
                  >
                    ➤ Thêm Thể Loại
                  </Link>
                </li>
                <li>
                  <Link
                    to="/admin/thongke"
                    className="nav-link"
                    style={{
                      color: "#ffffff",
                      textDecoration: "none",
                      padding: "8px 0",
                    }}
                    onClick={() => handleLinkClick("Xem Thống Kê")}
                  >
                    ➤ Bảng Thống Kê
                  </Link>
                </li>
                <li>
                  <Link
                    to="/admin/quanlynhanvien"
                    className="nav-link"
                    style={{
                      color: "#ffffff",
                      textDecoration: "none",
                      padding: "8px 0",
                    }}
                    onClick={() => handleLinkClick("Quản Lý Nhân Viên")}
                  >
                    ➤ Quản Lý Nhân Viên
                  </Link>
                </li>
                <li>
                  <Link
                    to="/admin/quanlyuser"
                    className="nav-link"
                    style={{
                      color: "#ffffff",
                      textDecoration: "none",
                      padding: "8px 0",
                    }}
                    onClick={() => handleLinkClick("Quản Lý Người Dùng")}
                  >
                    ➤ Quản Lý Người Dùng
                  </Link>
                </li>
              </ul>
            </nav>
          </div>

        </aside>

        {/* Nội dung chính */}
        <main
          style={{
            marginLeft: "240px",
            flexGrow: 1,
            backgroundColor: "#f9f9f9",
            padding: "20px",
            overflowY: "auto",
          }}
        >
          <Outlet />
        </main>
      </div>
    </div>
  );
}

export default AdminPage;
