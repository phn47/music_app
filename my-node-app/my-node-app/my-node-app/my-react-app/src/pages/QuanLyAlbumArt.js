import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";

const defaultImage = "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

function QuanLyAlbumaArt() {
  const [pendingSongs, setPendingSongs] = useState([]);
  const [approvedSongs, setApprovedSongs] = useState([]);
  const [hiddenSongs, setHiddenSongs] = useState([]);
  const [hiddenSongsByArt, setHiddenSongsByArt] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");

  // Phân trang
  const [pendingPage, setPendingPage] = useState(1);
  const [approvedPage, setApprovedPage] = useState(1);
  const [hiddenPage, setHiddenPage] = useState(1);
  const itemsPerPage = 4;

  const navigate = useNavigate();

  // Phân trang
  const paginate = (data, page) => {
    const startIndex = (page - 1) * itemsPerPage;
    return data.slice(startIndex, startIndex + itemsPerPage);
  };

  // Render phân trang
  const renderPagination = (totalItems, currentPage, setPage) => {
    const totalPages = Math.ceil(totalItems / itemsPerPage);

    return (
      <nav className="d-flex justify-content-center mt-3">
        <ul className="pagination">
          {[...Array(totalPages)].map((_, index) => (
            <li
              key={index}
              className={`page-item ${currentPage === index + 1 ? "active" : ""}`}
              onClick={() => setPage(index + 1)}
              style={{ cursor: "pointer" }}
            >
              <span className="page-link">{index + 1}</span>
            </li>
          ))}
        </ul>
      </nav>
    );
  };

  // Xử lý tìm kiếm
  const handleSearch = (event) => {
    setSearch(event.target.value);
  };

  // Xử lý thay đổi filter
  const handleStatusFilterChange = (event) => {
    setStatusFilter(event.target.value);
  };

  useEffect(() => {
    const fetchSongs = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

        const fetchAPI = async (url) => {
          const response = await fetch(url, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "x-auth-token": token,
            },
            body: JSON.stringify({ search: search }),
          });

          if (!response.ok) {
            throw new Error("Không thể tải dữ liệu từ API.");
          }
          return response.json();
        };

        const pendingData = await fetchAPI("http://127.0.0.1:8000/albums/listdoiduyet");
        const approvedData = await fetchAPI("http://127.0.0.1:8000/albums/listdaduyet");
        const hiddenData = await fetchAPI("http://127.0.0.1:8000/albums/listbian");

        setPendingSongs(pendingData.filter(song => song.status));
        setApprovedSongs(approvedData.filter(song => song.status && song.is_hidden === false));
        setHiddenSongs(hiddenData.filter(song => song.status && song.is_hidden === true && song.hidden_by !== song.user_id));
        setHiddenSongsByArt(hiddenData.filter(song => song.status && song.is_hidden === true && song.hidden_by === song.user_id));
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    fetchSongs();
  }, [search]);

  const renderSongList = (songs, page, setPage, onClickHandler) => {
    const filteredSongs = paginate(songs, page);

    return (
      <div className="song-list-container">
        <div className="row g-4">
          {filteredSongs.map((song, index) => (
            <div
              key={song.id}
              className="col-lg-3 col-md-6 fade-in-up"
              style={{ animationDelay: `${index * 0.1}s` }}
            >
              <div className="card h-100 album-card" onClick={() => onClickHandler && onClickHandler(song.id)}>
                <div className="img-container">
                  <img
                    src={song.thumbnail_url || defaultImage}
                    alt={song.name}
                    className="card-img-top"
                  />
                  <div className="overlay">
                    <button className="btn btn-light rounded-circle">
                      <i className="fas fa-info"></i>
                    </button>
                  </div>
                </div>
                <div className="card-body">
                  <h5 className="card-title text-truncate mb-2">{song.name}</h5>
                  <span className={`status-badge ${song.status ? 'bg-success' : 'bg-warning'
                    }`}>
                    {song.status ? 'Đang hoạt động' : 'Chờ duyệt'}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>
        {renderPagination(songs.length, page, setPage)}
      </div>
    );
  };

  return (
    <div className="album-manager">
      <div className="container py-5">
        <h2 className="text-center mb-5 slide-in-down">
          <i className="fas fa-compact-disc me-2"></i>
          Quản lý Album
        </h2>

        <div className="search-filter-container slide-in-right mb-5">
          <div className="row g-3">
            <div className="col-md-8">
              <div className="search-box">
                <i className="fas fa-search"></i>
                <input
                  type="text"
                  placeholder="Tìm kiếm album..."
                  value={search}
                  onChange={handleSearch}
                  className="form-control"
                />
              </div>
            </div>
            <div className="col-md-4">
              <select
                value={statusFilter}
                onChange={handleStatusFilterChange}
                className="form-select"
              >
                <option value="all">Tất cả Album</option>
                <option value="approved">Đang hoạt động</option>
                <option value="rejected">Chờ duyệt</option>
                <option value="hidden">Đã ẩn</option>
              </select>
            </div>
          </div>
        </div>

        {loading ? (
          <div className="text-center py-5">
            <div className="spinner-grow text-primary">
              <span className="visually-hidden">Loading...</span>
            </div>
          </div>
        ) : error ? (
          <div className="alert alert-danger fade-in" role="alert">
            <i className="fas fa-exclamation-circle me-2"></i>
            {error}
          </div>
        ) : (
          <div className="album-sections">
            {/* ... phần render các section album giữ nguyên */}
          </div>
        )}
      </div>

      <style jsx>{`
                .album-manager {
                    background-color: #f8f9fa;
                    min-height: 100vh;
                }

                .search-box {
                    position: relative;
                }

                .search-box i {
                    position: absolute;
                    left: 15px;
                    top: 50%;
                    transform: translateY(-50%);
                    color: #6c757d;
                }

                .search-box input {
                    padding-left: 45px;
                    height: 50px;
                    border-radius: 25px;
                    border: 2px solid #e9ecef;
                    transition: all 0.3s ease;
                }

                .search-box input:focus {
                    border-color: #4e73df;
                    box-shadow: 0 0 0 0.25rem rgba(78, 115, 223, 0.25);
                }

                .form-select {
                    height: 50px;
                    border-radius: 25px;
                    border: 2px solid #e9ecef;
                }

                .album-card {
                    border: none;
                    border-radius: 15px;
                    transition: all 0.3s ease;
                    cursor: pointer;
                    overflow: hidden;
                }

                .album-card:hover {
                    transform: translateY(-5px);
                    box-shadow: 0 10px 20px rgba(0,0,0,0.1);
                }

                .img-container {
                    position: relative;
                    overflow: hidden;
                    padding-top: 100%;
                }

                .img-container img {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    transition: transform 0.3s ease;
                }

                .album-card:hover img {
                    transform: scale(1.1);
                }

                .overlay {
                    position: absolute;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background: rgba(0,0,0,0.5);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    opacity: 0;
                    transition: opacity 0.3s ease;
                }

                .album-card:hover .overlay {
                    opacity: 1;
                }

                .status-badge {
                    padding: 8px 12px;
                    border-radius: 20px;
                    font-size: 0.875rem;
                    font-weight: 500;
                }

                /* Animations */
                @keyframes fadeInUp {
                    from {
                        opacity: 0;
                        transform: translateY(20px);
                    }
                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }

                @keyframes slideInDown {
                    from {
                        opacity: 0;
                        transform: translateY(-30px);
                    }
                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }

                @keyframes slideInRight {
                    from {
                        opacity: 0;
                        transform: translateX(30px);
                    }
                    to {
                        opacity: 1;
                        transform: translateX(0);
                    }
                }

                .fade-in-up {
                    animation: fadeInUp 0.5s ease-out forwards;
                }

                .slide-in-down {
                    animation: slideInDown 0.5s ease-out;
                }

                .slide-in-right {
                    animation: slideInRight 0.5s ease-out;
                }

                /* Pagination styling */
                .pagination {
                    gap: 5px;
                }

                .page-link {
                    border-radius: 50%;
                    width: 40px;
                    height: 40px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    border: none;
                    background-color: #fff;
                    color: #4e73df;
                    transition: all 0.3s ease;
                }

                .page-item.active .page-link {
                    background-color: #4e73df;
                    color: #fff;
                }

                .page-link:hover {
                    background-color: #e8eaf6;
                    color: #4e73df;
                }

                /* New Animations */
                @keyframes float {
                    0% {
                        transform: translateY(0px);
                    }
                    50% {
                        transform: translateY(-10px);
                    }
                    100% {
                        transform: translateY(0px);
                    }
                }

                @keyframes pulse {
                    0% {
                        transform: scale(1);
                    }
                    50% {
                        transform: scale(1.05);
                    }
                    100% {
                        transform: scale(1);
                    }
                }

                @keyframes rotate {
                    from {
                        transform: rotate(0deg);
                    }
                    to {
                        transform: rotate(360deg);
                    }
                }

                @keyframes shimmer {
                    0% {
                        background-position: -1000px 0;
                    }
                    100% {
                        background-position: 1000px 0;
                    }
                }

                @keyframes bounce {
                    0%, 20%, 50%, 80%, 100% {
                        transform: translateY(0);
                    }
                    40% {
                        transform: translateY(-20px);
                    }
                    60% {
                        transform: translateY(-10px);
                    }
                }

                /* Apply new animations */
                .fas.fa-compact-disc {
                    display: inline-block;
                    animation: rotate 4s linear infinite;
                }

                .search-box input:focus + i {
                    animation: bounce 1s ease infinite;
                }

                .album-card {
                    animation: float 6s ease-in-out infinite;
                }

                .status-badge {
                    animation: pulse 2s infinite;
                }

                .card-img-top {
                    transition: all 0.5s ease;
                }

                .album-card:hover .card-img-top {
                    transform: scale(1.2) rotate(5deg);
                }

                .overlay button {
                    animation: pulse 1.5s infinite;
                }

                /* Hover Effects Enhancement */
                .album-card::before {
                    content: '';
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: linear-gradient(45deg, rgba(78,115,223,0.1), rgba(255,255,255,0.1));
                    opacity: 0;
                    transition: all 0.3s ease;
                    z-index: 1;
                    border-radius: 15px;
                }

                .album-card:hover::before {
                    opacity: 1;
                }

                /* Loading Animation */
                .spinner-grow {
                    animation: pulse 1s ease infinite;
                }

                /* Search Box Enhancement */
                .search-box input {
                    background: linear-gradient(120deg, #fdfbfb 0%, #ebedee 100%);
                }

                .search-box input:focus {
                    background: white;
                    transform: translateY(-2px);
                }

                /* Select Enhancement */
                .form-select {
                    background: linear-gradient(120deg, #fdfbfb 0%, #ebedee 100%);
                    transition: all 0.3s ease;
                }

                .form-select:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 5px 15px rgba(0,0,0,0.1);
                }

                /* Card Body Enhancement */
                .card-body {
                    background: linear-gradient(to right, #fff, #f8f9fa);
                    transition: all 0.3s ease;
                }

                .album-card:hover .card-body {
                    background: linear-gradient(to right, #f8f9fa, #fff);
                }

                /* Title Animation */
                .card-title {
                    position: relative;
                    overflow: hidden;
                }

                .card-title::after {
                    content: '';
                    position: absolute;
                    bottom: 0;
                    left: 0;
                    width: 0;
                    height: 2px;
                    background: #4e73df;
                    transition: width 0.3s ease;
                }

                .album-card:hover .card-title::after {
                    width: 100%;
                }

                /* Status Badge Enhancement */
                .status-badge {
                    position: relative;
                    overflow: hidden;
                }

                .status-badge::before {
                    content: '';
                    position: absolute;
                    top: 0;
                    left: -100%;
                    width: 100%;
                    height: 100%;
                    background: linear-gradient(
                        90deg,
                        transparent,
                        rgba(255, 255, 255, 0.2),
                        transparent
                    );
                    animation: shimmer 2s infinite;
                }

                /* Pagination Enhancement */
                .page-link {
                    transition: all 0.3s ease;
                }

                .page-link:hover {
                    transform: scale(1.1);
                }

                .page-item.active .page-link {
                    animation: pulse 2s infinite;
                }
            `}</style>
    </div>
  );
}

export default QuanLyAlbumaArt; 