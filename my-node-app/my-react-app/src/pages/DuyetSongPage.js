import React, { useEffect, useState } from "react";
import { useLocation } from "react-router-dom"; // Dùng để lấy tham số trong URL
import 'bootstrap/dist/css/bootstrap.min.css';

function DuyetSongPage() {
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
        const response = await fetch(`http://127.0.0.1:8000/songs/song/${songId}`, {
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

      const response = await fetch(`http://127.0.0.1:8000/songs/song/duyetsong/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) {
        throw new Error("Không thể duyệt Album.");
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

      const response = await fetch(`http://127.0.0.1:8000/songs/song/duyetsong2/${songId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
      });

      if (!response.ok) {
        throw new Error("Không thể từ chối duyệt Album.");
      }

      const data = await response.json();
      setMessage(data.message); // Hiển thị thông báo thành công
    } catch (error) {
      setError(error.message);
    }
  };

  return (
    <div className="container" style={{ fontFamily: 'Segoe UI Black', backgroundColor: 'white', color: 'black' }}>
      {loading ? (
        <p className="text-center mt-5">Đang tải dữ liệu...</p>
      ) : error ? (
        <p className="text-danger text-center mt-5">{error}</p>
      ) : song ? (
        <div className="row justify-content-center mt-5">
          <div className="col-12 col-md-8">
            <div className="card shadow-lg">
              <div className="card-body">
                <h2 className="text-center mb-4">{song.song_name}</h2>
                <img src={song.thumbnail_url} alt={song.song_name} className="img-fluid rounded mb-4" />
                <audio controls className="w-100 mb-4">
                  <source src={song.song_url} type="audio/mpeg" />
                  Trình duyệt của bạn không hỗ trợ phát nhạc.
                </audio>
                <p><strong>Tên:</strong> {song.name}</p>
                <p><strong>Mô tả:</strong> {song.description}</p>
                <p><strong>Ngày tạo:</strong> {new Date(song.created_at).toLocaleDateString()}</p>
                <p><strong>Ngày cập nhật:</strong> {new Date(song.updated_at).toLocaleDateString()}</p>

                <div className="text-center">
                  <button
                    onClick={handleApprove}
                    className="btn btn-dark px-4 py-2 mr-3"
                  >
                    Duyệt Album
                  </button>
                  <button
                    onClick={handleReject}
                    className="btn btn-dark px-4 py-2"
                  >
                    Từ chối duyệt
                  </button>
                </div>
                {message && <p className="text-success text-center mt-3">{message}</p>}
              </div>
            </div>
          </div>
        </div>
      ) : (
        <p className="text-center mt-5">Không tìm thấy Album.</p>
      )}
    </div>
  );
}

export default DuyetSongPage;
