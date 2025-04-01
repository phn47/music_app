import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom"; // Dùng để lấy tham số trong URL

function DuyetAlbumPage() {
  const [song, setSong] = useState(null); // Thông tin bài hát
  const [loading, setLoading] = useState(true); // Trạng thái loading
  const [error, setError] = useState(""); // Thông báo lỗi
  const [message, setMessage] = useState(""); // Thông báo sau khi duyệt hoặc từ chối

  const location = useLocation(); // Hook để lấy thông tin location
  const songId = new URLSearchParams(location.search).get("id"); // Lấy ID bài hát từ URL

  useEffect(() => {
    const fetchSong = async () => {
      try {
        const token = localStorage.getItem("token"); // Lấy token từ localStorage
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

        // Gọi API để lấy thông tin chi tiết bài hát
        const response = await fetch(`http://127.0.0.1:8000/albums/song/${songId}`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": token,
          },
        });

        if (!response.ok) {
          throw new Error("Không thể tải dữ liệu bài hát.");
        }

        const data = await response.json();
        setSong(data); // Lưu thông tin bài hát vào state
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    fetchSong();
  }, [songId]);

  const handleApprove = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      const response = await fetch(`http://127.0.0.1:8000/albums/song/duyetsong/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) {
        throw new Error("Không thể duyệt bài hát.");
      }

      const data = await response.json();
      setMessage(data.message); // Hiển thị thông báo thành công
    } catch (error) {
      setError(error.message);
    }
  };

  const handleReject = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      const response = await fetch(`http://127.0.0.1:8000/albums/song/duyetsong2/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) {
        throw new Error("Không thể từ chối duyệt bài hát.");
      }

      const data = await response.json();
      setMessage(data.message); // Hiển thị thông báo thành công
    } catch (error) {
      setError(error.message);
    }
  };

  return (
    <div className="container mt-5" style={{ fontFamily: "Segoe UI Black", color: "black" }}>
      {loading ? (
        <p className="text-center text-muted">Đang tải dữ liệu...</p>
      ) : error ? (
        <div className="alert alert-danger text-center" role="alert">
          {error}
        </div>
      ) : song ? (
        <div className="card shadow-sm">
          <div className="card-body">
            <h2 className="card-title text-center mb-4">{song.song_name}</h2>
            <div className="text-center">
              <img
                src={song.thumbnail_url}
                alt={song.song_name}
                className="img-fluid rounded mb-3"
                style={{ maxWidth: "300px" }}
              />
            </div>
            <div className="text-center mb-4">
              <audio controls className="w-100">
                <source src={song.song_url} type="audio/mpeg" />
                Trình duyệt của bạn không hỗ trợ phát nhạc.
              </audio>
            </div>
            <div className="mb-3">
              <p><strong>Tên:</strong> {song.name}</p>
              <p><strong>Mô tả:</strong> {song.description}</p>
              <p><strong>Ngày tạo:</strong> {new Date(song.created_at).toLocaleDateString()}</p>
              {/* <p><strong>Ngày cập nhật:</strong> {new Date(song.updated_at).toLocaleDateString()}</p> */}
            </div>
            <div className="text-center">
              <button
                onClick={handleApprove}
                className="btn btn-dark mx-2"
              >
                Duyệt bài
              </button>
              <button
                onClick={handleReject}
                className="btn btn-dark mx-2"
              >
                Từ chối duyệt
              </button>
            </div>
            {message && (
              <div className="alert alert-success mt-4 text-center" role="alert">
                {message}
              </div>
            )}
          </div>
        </div>
      ) : (
        <p className="text-center text-muted">Không tìm thấy bài hát.</p>
      )}
    </div>
  );
  
}

export default DuyetAlbumPage;
