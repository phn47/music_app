import React from 'react';
import { Link } from 'react-router-dom';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap/dist/js/bootstrap.bundle.min.js';

function HomePage() {
  return (
    <div className="home-container" style={{ fontFamily: "'Segoe UI Black', sans-serif", fontWeight: 600 }}>
      {/* Full-width Carousel Section */}
      <section className="home-carousel">
        <div
          id="artistCarousel"
          className="carousel slide"
          data-bs-ride="carousel"
          data-bs-interval="3000"
          style={{
            background: '#000', // Đổi nền carousel thành màu đen
            borderRadius: '10px',
            boxShadow: '0px 5px 15px rgba(0, 0, 0, 0.5)',
            overflow: 'hidden',
          }}
        >
          <div className="carousel-inner">
            <div className="carousel-item active">
              <img
                src="https://img.freepik.com/free-vector/hand-drawn-colorful-music-festival-twitch-banner_23-2149065820.jpg"
                className="d-block w-100"
                alt="Nghệ Sĩ 1"
                style={{
                  objectFit: 'cover',
                  height: '400px',
                  borderRadius: '10px',
                }}
              />
            </div>
            <div className="carousel-item">
              <img
                src="https://static.vecteezy.com/system/resources/thumbnails/011/000/296/small/abstract-music-soundwave-banner-design-free-vector.jpg"
                className="d-block w-100"
                alt="Nghệ Sĩ 2"
                style={{
                  objectFit: 'cover',
                  height: '400px',
                  borderRadius: '10px',
                }}
              />
            </div>
          </div>
          <button
            className="carousel-control-prev"
            type="button"
            data-bs-target="#artistCarousel"
            data-bs-slide="prev"
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.6)',
              borderRadius: '50%',
            }}
          >
            <span className="carousel-control-prev-icon" aria-hidden="true" style={{ filter: 'invert(1)' }}></span>
            <span className="visually-hidden">Previous</span>
          </button>
          <button
            className="carousel-control-next"
            type="button"
            data-bs-target="#artistCarousel"
            data-bs-slide="next"
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.6)',
              borderRadius: '50%',
            }}
          >
            <span className="carousel-control-next-icon" aria-hidden="true" style={{ filter: 'invert(1)' }}></span>
            <span className="visually-hidden">Next</span>
          </button>
        </div>
      </section>

      {/* Nội dung chính */}
      <section className="home-content text-center py-5" style={{ backgroundColor: '#FFF', color: '#000' }}>
        <div className="container">
          <h2 className="display-5 text-dark mb-4" style={{ fontWeight: 700, textShadow: '1px 1px 5px rgba(0, 0, 0, 0.3)' }}>
            Khám Phá Âm Nhạc Của Bạn
          </h2>
          <p className="lead text-muted mb-4">
            Tham gia cộng đồng và thể hiện tài năng âm nhạc của bạn ngay hôm nay!
          </p>
          {/* Bố cục ba cột */}
          <div className="row justify-content-center">
            {/* Cột Đăng Ký */}
            <div className="col-md-4 mb-4">
              <div className="card shadow-sm p-4" style={{ borderRadius: '10px', background: '#f8f8f8', border: '1px solid #ddd' }}>
                <h3 className="mb-3 text-dark" style={{ fontWeight: 700 }}>
                Bạn là nghệ sĩ
                </h3>
                <p className="text-muted mb-4">Đăng nhập và thể hiện tài năng của bạn!</p>
                <Link
                  to="/loginart"
                  className="btn btn-dark btn-lg px-4 py-2"
                  style={{
                    fontWeight: 800,
                    transition: 'all 0.3s ease-in-out',
                    borderRadius: '50px',
                  }}
                >
                  Đăng nhập 
                </Link>
              </div>
            </div>

            {/* Cột Đăng Nhập */}
            <div className="col-md-4 mb-4">
              <div className="card shadow-sm p-4" style={{ borderRadius: '10px', background: '#f8f8f8', border: '1px solid #ddd' }}>
                <h3 className="mb-3 text-dark" style={{ fontWeight: 700 }}>
                  Bạn là nhân viên
                </h3>
                <p className="text-muted mb-4">Đăng nhập và thể hiện tài năng của bạn!</p>
                <Link
                  to="/login"
                  className="btn btn-dark btn-lg px-4 py-2"
                  style={{
                    fontWeight: 800,
                    transition: 'all 0.3s ease-in-out',
                    borderRadius: '50px',
                    color: 'white',
                  }}
                >
                  Đăng Nhập
                </Link>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer
        className="home-footer bg-dark text-white text-center py-4"
        style={{
          boxShadow: '0px -5px 10px rgba(0, 0, 0, 0.2)',
          fontSize: '14px',
        }}
      >
        <p>&copy; 2024 Ứng Dụng Âm Nhạc. Mọi quyền được bảo lưu.</p>
        <p>
          <Link to="/about" className="text-white">
            Giới thiệu
          </Link>{' '}
          |{' '}
          <Link to="/contact" className="text-white">
            Liên hệ
          </Link>
        </p>
      </footer>
    </div>
  );
}

export default HomePage;
