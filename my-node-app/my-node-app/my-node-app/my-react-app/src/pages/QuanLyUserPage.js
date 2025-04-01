import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";

const defaultImage = "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

function QuanLyUserPage() {
  const [pendingSongs, setPendingSongs] = useState([]);
  const [approvedSongs, setApprovedSongs] = useState([]);
  const [hiddenSongs, setHiddenSongs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(8);
  const navigate = useNavigate();

  useEffect(() => {
    fetchSongs();
  }, [search]);

  const fetchSongs = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Bạn chưa đăng nhập.");

      const fetchAPI = async (url) => {
        const response = await fetch(url, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": token,
          },
          body: JSON.stringify({ search }),
        });

        if (!response.ok) throw new Error("Không thể tải dữ liệu.");
        return response.json();
      };

      const [pendingData, approvedData, hiddenData] = await Promise.all([
        fetchAPI("http://127.0.0.1:8000/auth/listartfailuser"),
        fetchAPI("http://127.0.0.1:8000/auth/listarttrueuser"),
        fetchAPI("http://127.0.0.1:8000/auth/listartnulluser")
      ]);

      setPendingSongs(pendingData.filter(song => song.is_active));
      setApprovedSongs(approvedData.filter(song => song.is_active));
      setHiddenSongs(hiddenData.filter(song => song.is_active == null));
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const getFilteredUsers = () => {
    const allUsers = [...approvedSongs, ...hiddenSongs];

    if (statusFilter === "all") {
      return allUsers;
    } else if (statusFilter === "true") {
      return allUsers.filter(user => user.is_active === true);
    } else if (statusFilter === "null") {
      return allUsers.filter(user => user.is_active === null);
    }
    return allUsers;
  };

  return (
    <div className="container-fluid py-4 animate__animated animate__fadeIn">
      <div className="card shadow-lg border-0">
        <div className="card-header bg-gradient-primary py-4">
          <div className="row align-items-center">
            <div className="col">
              <h3 className="mb-0 text-white">
                <i className="fas fa-users me-2"></i>
                Quản Lý Người Dùng
              </h3>
              {/* <p className="text-white-50 mb-0">
                 
              </p> */}
            </div>
          </div>
        </div>

        <div className="card-body px-4">
          <div className="row mb-4 align-items-center">
            <div className="col-md-4">
              <div className="search-box">
                <div className="input-group input-group-merge">
                  <span className="input-group-text bg-transparent border-end-0">
                    <i className="fas fa-search text-primary"></i>
                  </span>
                  <input
                    type="text"
                    className="form-control form-control-lg border-start-0 ps-0"
                    placeholder="Tìm kiếm người dùng..."
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                  />
                </div>
              </div>
            </div>
            <div className="col-md-3">
              <select
                className="form-select form-select-lg"
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
              >
                <option value="all">Tất cả trạng thái</option>
                <option value="true">Hoạt động</option>
                <option value="null">Đã ẩn</option>
              </select>
            </div>
          </div>

          {loading ? (
            <div className="text-center py-5">
              <div className="spinner-border text-primary" role="status">
                <span className="visually-hidden">Đang tải...</span>
              </div>
            </div>
          ) : error ? (
            <div className="alert alert-danger" role="alert">
              <i className="fas fa-exclamation-circle me-2"></i>
              {error}
            </div>
          ) : (
            <>
              <div className="table-responsive">
                <table className="table table-hover align-middle table-nowrap">
                  <thead className="table-light">
                    <tr>
                      <th className="text-center" style={{ width: "5%" }}>#</th>
                      <th className="text-center" style={{ width: "15%" }}>Ảnh đại diện</th>
                      <th style={{ width: "30%" }}>Tên người dùng</th>
                      <th style={{ width: "30%" }}>Email</th>
                      <th className="text-center" style={{ width: "10%" }}>Trạng thái</th>
                      <th className="text-center" style={{ width: "10%" }}>Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    {getFilteredUsers()
                      .slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage)
                      .map((user, index) => (
                        <tr key={user.id} className="animate__animated animate__fadeIn">
                          <td className="text-center">{(currentPage - 1) * itemsPerPage + index + 1}</td>
                          <td className="text-center">
                            <div className="avatar-wrapper">
                              <img
                                src={user.thumbnail_url || defaultImage}
                                alt={user.name}
                                className="avatar-img"
                              />
                            </div>
                          </td>
                          <td>
                            <h6 className="mb-0">{user.name}</h6>
                          </td>
                          <td>{user.email}</td>
                          <td className="text-center">
                            {user.is_active ? (
                              <span className="badge bg-soft-success text-success rounded-pill">
                                <i className="fas fa-check-circle me-1"></i>
                                Hoạt động
                              </span>
                            ) : (
                              <span className="badge bg-soft-danger text-danger rounded-pill">
                                <i className="fas fa-ban me-1"></i>
                                Đã ẩn
                              </span>
                            )}
                          </td>
                          <td className="text-center">
                            <button
                              className="btn btn-sm btn-primary"
                              onClick={() => navigate(user.is_active ?
                                `/nhanvien/phieuuserbanned/?id=${user.id}` :
                                `/nhanvien/dabianuser?id=${user.id}`
                              )}
                            >
                              <i className="fas fa-info-circle"></i>
                            </button>
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </table>
              </div>

              <div className="d-flex justify-content-between align-items-center mt-4">
                <div className="text-muted small">
                  Trang {currentPage} / {Math.ceil(getFilteredUsers().length / itemsPerPage)}
                </div>
                <nav>
                  <ul className="pagination pagination-sm mb-0 gap-2">
                    {Array.from({ length: Math.ceil(getFilteredUsers().length / itemsPerPage) }, (_, i) => (
                      <li
                        key={i}
                        className={`page-item ${currentPage === i + 1 ? 'active' : ''}`}
                      >
                        <button
                          className="page-link"
                          onClick={() => setCurrentPage(i + 1)}
                        >
                          {i + 1}
                        </button>
                      </li>
                    ))}
                  </ul>
                </nav>
              </div>
            </>
          )}
        </div>
      </div>

      <style jsx>{`
        .bg-gradient-primary {
          background: linear-gradient(45deg, #4e73df 0%, #224abe 100%);
        }

        .search-box .input-group {
          box-shadow: 0 2px 4px rgba(0,0,0,.05);
          border-radius: 8px;
          overflow: hidden;
        }

        .avatar-wrapper {
          width: 45px;
          height: 45px;
          margin: 0 auto;
          border-radius: 8px;
          overflow: hidden;
          box-shadow: 0 2px 4px rgba(0,0,0,.1);
          transition: transform .2s;
        }

        .avatar-wrapper:hover {
          transform: scale(1.1);
        }

        .avatar-img {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }

        .bg-soft-success {
          background-color: rgba(25,135,84,.1);
        }

        .bg-soft-danger {
          background-color: rgba(220,53,69,.1);
        }

        .card {
          border-radius: 12px;
        }
      `}</style>
    </div>
  );
}

export default QuanLyUserPage;
