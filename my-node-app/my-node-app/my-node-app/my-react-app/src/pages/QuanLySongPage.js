import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";
import "animate.css";

function QuanLySongPage() {
  const [songs, setSongs] = useState({ pending: [], approved: [], hidden: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [searchTerm, setSearchTerm] = useState("");
  const [filter, setFilter] = useState("all");
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 8;
  const navigate = useNavigate();

  useEffect(() => {
    fetchSongs();
  }, [searchTerm]);

  const fetchSongs = async () => {
    setLoading(true);
    setError("");
    try {
      const token = localStorage.getItem("token");
      if (!token) throw new Error("Bạn chưa đăng nhập.");

      const endpoints = {
        pending: "http://127.0.0.1:8000/song/listwed2",
        approved: "http://127.0.0.1:8000/song/listwed3",
        hidden: "http://127.0.0.1:8000/song/listwed4",
      };

      const [pendingData, approvedData, hiddenData] = await Promise.all([
        fetchData(endpoints.pending, token),
        fetchData(endpoints.approved, token),
        fetchData(endpoints.hidden, token),
      ]);

      setSongs({
        pending: pendingData,
        approved: approvedData,
        hidden: hiddenData,
      });
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const fetchData = async (url, token) => {
    const response = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-auth-token": token,
      },
      body: JSON.stringify({ search: searchTerm }),
    });

    if (!response.ok) throw new Error("Lỗi khi tải dữ liệu");
    return response.json();
  };

  const getFilteredSongs = () => {
    let filteredSongs = [];
    if (filter === "all") {
      filteredSongs = [
        ...songs.pending.map((song) => ({ ...song, status: "pending" })),
        ...songs.approved.map((song) => ({ ...song, status: "approved" })),
        ...songs.hidden.map((song) => ({ ...song, status: "hidden" })),
      ];
    } else {
      filteredSongs = songs[filter].map((song) => ({ ...song, status: filter }));
    }

    return filteredSongs.filter((song) =>
      song.song_name.toLowerCase().includes(searchTerm.toLowerCase())
    );
  };

  const getNavigateUrl = (type) => {
    const urls = {
      pending: "duyetsong",
      approved: "ansong",
      hidden: "dabiansong",
    };
    return urls[type];
  };

  return (
    <div className="container-fluid py-4 animate__animated animate__fadeIn">
      <div className="card shadow-lg border-0">
        <div className="card-header bg-gradient-primary py-4">
          <div className="row align-items-center">
            <div className="col">
              <h3 className="mb-0 text-white">
                <i className="fas fa-music me-2"></i>
                Quản Lý Bài Hát
              </h3>
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
                    placeholder="Tìm kiếm bài hát..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                  />
                </div>
              </div>
            </div>
            <div className="col-md-3">
              <select
                className="form-select form-select-lg"
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
              >
                <option value="all">Tất cả trạng thái</option>
                {/* <option value="pending">Chờ duyệt</option> */}
                <option value="approved">Hoạt động</option>
                <option value="hidden">Đã ẩn</option>
              </select>
            </div>
            <div className="col text-end">
              <span className="text-muted">
                Tổng số: {getFilteredSongs().length} bài hát
              </span>
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
                      <th className="text-center" style={{ width: "15%" }}>Ảnh</th>
                      <th style={{ width: "25%" }}>Tên bài hát</th>
                      <th style={{ width: "20%" }}>Nghệ sĩ</th>
                      <th style={{ width: "15%" }}>Ngày tạo</th>
                      <th className="text-center" style={{ width: "10%" }}>Trạng thái</th>
                      <th className="text-center" style={{ width: "10%" }}>Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    {getFilteredSongs()
                      .slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage)
                      .map((song, index) => (
                        <tr key={song.id} className="animate__animated animate__fadeIn">
                          <td className="text-center">{(currentPage - 1) * itemsPerPage + index + 1}</td>
                          <td className="text-center">
                            <div className="avatar-wrapper">
                              <img
                                src={song.thumbnail_url || "https://via.placeholder.com/50"}
                                alt={song.song_name}
                                className="avatar-img"
                              />
                            </div>
                          </td>
                          <td>
                            <h6 className="mb-0">{song.song_name}</h6>
                          </td>
                          <td>{song.artist_names?.join(", ") || "N/A"}</td>
                          <td>{new Date(song.created_at).toLocaleDateString("vi-VN")}</td>
                          <td className="text-center">
                            {song.status === "approved" ? (
                              <span className="badge bg-soft-success text-success rounded-pill">
                                <i className="fas fa-check-circle me-1"></i>
                                Hoạt động
                              </span>
                            ) : song.status === "pending" ? (
                              <span className="badge bg-soft-warning text-warning rounded-pill">
                                <i className="fas fa-clock me-1"></i>
                                Chờ duyệt
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
                              onClick={() => navigate(`/nhanvien/${getNavigateUrl(song.status)}?id=${song.id}`)}
                            >
                              <i className="fas fa-info-circle me-1"></i>
                              Chi tiết
                            </button>
                          </td>
                        </tr>
                      ))}
                  </tbody>
                </table>
              </div>

              <div className="d-flex justify-content-between align-items-center mt-4">
                <div className="text-muted small">
                  Trang {currentPage} / {Math.ceil(getFilteredSongs().length / itemsPerPage)}
                </div>
                <nav>
                  <ul className="pagination pagination-sm mb-0 gap-2">
                    <li className={`page-item ${currentPage === 1 ? 'disabled' : ''}`}>
                      <button
                        className="page-link rounded"
                        onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                      >
                        <i className="fas fa-chevron-left"></i>
                      </button>
                    </li>
                    {Array.from({ length: Math.ceil(getFilteredSongs().length / itemsPerPage) }, (_, i) => (
                      <li key={i + 1} className={`page-item ${currentPage === i + 1 ? 'active' : ''}`}>
                        <button
                          className="page-link rounded"
                          onClick={() => setCurrentPage(i + 1)}
                        >
                          {i + 1}
                        </button>
                      </li>
                    ))}
                    <li className={`page-item ${currentPage === Math.ceil(getFilteredSongs().length / itemsPerPage) ? 'disabled' : ''}`}>
                      <button
                        className="page-link rounded"
                        onClick={() => setCurrentPage(prev => Math.min(prev + 1, Math.ceil(getFilteredSongs().length / itemsPerPage)))}
                      >
                        <i className="fas fa-chevron-right"></i>
                      </button>
                    </li>
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

        .search-box .form-control:focus {
          box-shadow: none;
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

        .table-hover tbody tr:hover {
          background-color: rgba(78,115,223,.05);
        }

        .badge {
          font-weight: 500;
          padding: 0.5em 1em;
        }

        .bg-soft-success {
          background-color: rgba(25,135,84,.1);
        }

        .bg-soft-warning {
          background-color: rgba(255,193,7,.1);
        }

        .bg-soft-danger {
          background-color: rgba(220,53,69,.1);
        }

        .page-link {
          border: none;
          padding: 0.5rem 0.75rem;
          color: #4e73df;
        }

        .page-item.active .page-link {
          background-color: #4e73df;
          color: white;
        }

        .card {
          border-radius: 12px;
        }
      `}</style>
    </div>
  );
}

export default QuanLySongPage;
