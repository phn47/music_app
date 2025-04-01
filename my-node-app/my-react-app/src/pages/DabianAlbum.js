
import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom";
import "C:/Users/phamn/Downloads/my-node-app (1)/my-node-app/my-react-app/src/DabianSongPage.css"; // Đường dẫn CSS

function DabianAlbum() {
  const [songDetails, setSongDetails] = useState(null); // Thông tin chi tiết bài hát
  const [loading, setLoading] = useState(true); // Trạng thái loading
  const [error, setError] = useState(""); // Thông báo lỗi
  const [unhideMessage, setUnhideMessage] = useState(""); // Thông báo gỡ ẩn
  const location = useLocation(); // Lấy thông tin URL hiện tại

  // Lấy songId từ URL
  const queryParams = new URLSearchParams(location.search);
  const songId = queryParams.get("id");

  useEffect(() => {
    const fetchSongDetails = async () => {
      try {
        const token = localStorage.getItem("token");
        if (!token) {
          throw new Error("Bạn chưa đăng nhập.");
        }

        const response = await fetch(`http://127.0.0.1:8000/albums/songnone/${songId}`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-auth-token": token,
          },
        });

        if (!response.ok) {
          throw new Error("Không thể tải dữ liệu Album.");
        }

        const data = await response.json();
        setSongDetails(data);
      } catch (error) {
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    if (songId) {
      fetchSongDetails();
    }
  }, [songId]);

  // Hàm gọi API để gỡ ẩn bài hát
  const unhideSong = async () => {
    try {
      const token = localStorage.getItem("token");
      if (!token) {
        throw new Error("Bạn chưa đăng nhập.");
      }

      const response = await fetch(`http://127.0.0.1:8000/albums/album/unbanned/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) {
        throw new Error("Không thể gỡ ẩn Album.");
      }

      const data = await response.json();
      setUnhideMessage("Album đã được gỡ ẩn thành công!");
      // Cập nhật trạng thái bài hát hoặc thực hiện xử lý khác nếu cần
    } catch (error) {
      setError(error.message);
    }
  };

  return (
    <div className="container mt-5" style={{ fontFamily: "Segoe UI Black" }}>
      {loading ? (
        <p className="text-center text-muted">Đang tải dữ liệu...</p>
      ) : error ? (
        <div className="alert alert-danger text-center" role="alert">
          {error}
        </div>
      ) : songDetails ? (
        <div className="card shadow-sm">
          <div className="card-body">
            <h2 className="card-title text-center">Chi tiết Album bị ẩn</h2>
            <div className="text-center">
              <img
                src={songDetails.thumbnail_url}
                alt={songDetails.song_name}
                className="img-fluid rounded my-3"
                style={{ maxWidth: "300px" }}
              />
            </div>
            <div className="text-center my-3">
              <audio controls className="w-100">
                <source src={songDetails.song_url} type="audio/mpeg" />
                Trình duyệt của bạn không hỗ trợ phát nhạc.
              </audio>
            </div>
            <div className="song-info">
              <p><strong>Tên Album:</strong> {songDetails.name}</p>
              <p><strong>Trạng thái:</strong> {songDetails.status}</p>
              <p><strong>Mô tả:</strong> {songDetails.description}</p>
              <p><strong>Ngày tạo:</strong> {new Date(songDetails.created_at).toLocaleDateString()}</p>
              <p><strong>Ngày cập nhật:</strong> {new Date(songDetails.updated_at).toLocaleDateString()}</p>
            </div>
            <div className="text-center mt-4">
              <button className="btn btn-dark" onClick={unhideSong}>
                Gỡ ẩn Album
              </button>
            </div>
            {unhideMessage && (
              <div className="alert alert-success mt-3 text-center" role="alert">
                {unhideMessage}
              </div>
            )}
          </div>
        </div>
      ) : (
        <p className="text-center text-muted">Không tìm thấy thông tin Album.</p>
      )}
    </div>
  );

}

export default DabianAlbum;
