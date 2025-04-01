import React, { useEffect, useState } from 'react';
import { Bar, Line, Pie } from 'react-chartjs-2';
import '@fortawesome/fontawesome-free/css/all.min.css';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    BarElement,
    ArcElement, // Required for Pie Chart
    LineElement,
    PointElement,
    Title,
    Tooltip,
    Legend,
} from 'chart.js';
import 'bootstrap/dist/css/bootstrap.min.css';  // Ensure Bootstrap CSS is included

// Đăng ký các thành phần của ChartJS
ChartJS.register(
    CategoryScale,
    LinearScale,
    BarElement,
    LineElement,
    ArcElement, // Register ArcElement for Pie Chart
    Title,
    PointElement,
    Title,
    Tooltip,
    Legend
);

const defaultImage = "https://inkythuatso.com/uploads/thumbnails/800/2023/03/9-anh-dai-dien-trang-inkythuatso-03-15-27-03.jpg";

const AdminThongKe = () => {
    const [topPlayedSongs, setTopPlayedSongs] = useState([]);
    const [topPlayedSongsWeek, setTopPlayedSongsWeek] = useState([]);
    const [topLikedSongsWeek, setTopLikedSongsWeek] = useState([]);
    const [dailyPlaysData, setDailyPlaysData] = useState([]);
    const [genrePercentage, setGenrePercentage] = useState([]);
    const [userRoleCounts, setUserRoleCounts] = useState({
        user_count: 0,
        moderator_count: 0,
        artist_count: 0,
        total_play_count: 0
    });

    const [selectedDate, setSelectedDate] = useState("");
    const [topFavoriteSongs, setTopFavoriteSongs] = useState([]); // State lưu ngày được chọn

    const [topArtists, setTopArtists] = useState([]);

    const getTodayDate = () => {
        const today = new Date();
        return today.toISOString().split("T")[0]; // Format ngày YYYY-MM-DD
    };
    useEffect(() => {
        setSelectedDate(getTodayDate());
    }, []);

    // Hàm gọi API lấy danh sách lượt nghe tất cả bài hát
    const fetchTopPlayedSongs = async () => {
        try {
            const response = await fetch('http://127.0.0.1:8000/albums/songs/top-plays', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ limit: 10 }),
            });
            const data = await response.json();
            setTopPlayedSongs(data.top_songs || []);
        } catch (error) {
            console.error('Error fetching top played songs:', error);
        }
    };

    const fetchTopFavoriteSongs = async () => {
        try {
            const response = await fetch('http://127.0.0.1:8000/albums/songs/top-favorites', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ limit: 10 }), // Giới hạn lấy 10 bài hát
            });
            const data = await response.json();
            setTopFavoriteSongs(data.top_songs || []);
        } catch (error) {
            console.error('Error fetching top favorite songs:', error);
        }
    };


    // Hàm gọi API lấy danh sách lượt nghe cao nhất tuần
    const fetchTopPlayedSongsWeek = async () => {
        try {
            const response = await fetch('http://127.0.0.1:8000/albums/songs/top-plays-week', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ limit: 10 }),
            });
            const data = await response.json();
            setTopPlayedSongsWeek(data.top_songs || []);
        } catch (error) {
            console.error('Error fetching top played songs this week:', error);
        }
    };

    // Hàm gọi API lấy danh sách lượt thích nhiều nhất tuần
    const fetchTopLikedSongsWeek = async (date) => {
        try {
            const response = await fetch('http://127.0.0.1:8000/albums/songs/top-like-week-detail', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ date: `${date}T00:00:00` }), // Cập nhật ngày cụ thể cho API
            });
            const data = await response.json();
            setTopLikedSongsWeek(data.songs || []);
        } catch (error) {
            console.error('Error fetching top liked songs this week:', error);
        }
    };

    // Hàm gọi API lấy dữ liệu lượt nghe theo từng ngày trong tuần
    const fetchDailyPlaysData = async (date) => {
        try {
            const response = await fetch('http://127.0.0.1:8000/albums/songs/top-plays-week-detail1', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ date: `${date}T00:00:00` }), // Cập nhật ngày cụ thể cho API
            });
            const data = await response.json();
            setDailyPlaysData(data.songs || []); // Thay đổi để phù hợp với cấu trúc dữ liệu trả về
        } catch (error) {
            console.error('Error fetching daily plays data:', error);
        }
    };
    // Hàm gọi API lấy dữ liệu tỷ lệ phần trăm thể loại nhạc
    const fetchGenrePercentage = async () => {
        try {
            const response = await fetch('http://127.0.0.1:8000/albums/genres/percentage');
            const data = await response.json();
            setGenrePercentage(data.data || []);
        } catch (error) {
            console.error('Error fetching genre percentage:', error);
        }
    };

    // Hàm gọi API lấy thông tin vai trò người dùng
    const fetchUserRoleCounts = async () => {
        try {
            const response = await fetch('http://127.0.0.1:8000/albums/user_role_counts');
            const data = await response.json();
            setUserRoleCounts(data);
        } catch (error) {
            console.error('Error fetching user role counts:', error);
        }
    };

    const fetchTopArtists = async () => {
        try {
            const response = await fetch('http://127.0.0.1:8000/song/top-artists');
            const data = await response.json();
            setTopArtists(data);
        } catch (error) {
            console.error('Error fetching top artists:', error);
        }
    };

    // Gọi API khi component được render
    useEffect(() => {
        fetchTopPlayedSongs();
        fetchTopPlayedSongsWeek();
        fetchTopFavoriteSongs();
        fetchTopArtists();
        if (selectedDate) {
            fetchTopLikedSongsWeek(selectedDate);
            fetchDailyPlaysData(selectedDate);
        }
        fetchGenrePercentage(); // Fetch genre percentage data
        fetchUserRoleCounts(); // Fetch user role counts
    }, [selectedDate]);

    const handleDateChange = (event) => {
        setSelectedDate(event.target.value); // Cập nhật ngày được chọn
    };


    // Hàm chuẩn bị dữ liệu cho biểu đồ Bar
    const prepareChartData = (data, labelKey, valueKey) => {
        return {
            labels: data.map(item => item[labelKey]),
            datasets: [
                {
                    label: 'Số lượng',
                    data: data.map(item => item[valueKey]),
                    backgroundColor: 'rgba(75, 192, 192, 0.6)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 1,
                },
            ],
        };
    };

    // Hàm chuẩn bị dữ liệu cho biểu đồ Line với màu sắc khác nhau cho mỗi bài hát
    const prepareLineChartData = (data, labelKey, valueKey) => {
        const colors = [
            'rgba(255, 99, 132, 1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 206, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)',
            'rgba(255, 159, 64, 1)',
            'rgba(255, 99, 132, 1)',
            'rgba(105, 105, 105, 1)',
            'rgba(255, 165, 0, 1)',
            'rgba(0, 255, 255, 1)'
        ];

        return {
            labels: data.map(item => item[labelKey]),
            datasets: data.map((item, index) => ({
                label: item[labelKey],
                data: item[valueKey],
                fill: false,
                borderColor: colors[index % colors.length], // Gán màu sắc cho mỗi bài hát
                backgroundColor: colors[index % colors.length],
                tension: 0.4,
            })),
        };
    };

    // Biểu đồ "Lượt Nghe Theo Ngày Trong Tuần"
    const prepareDailyPlaysChartData = () => {
        const daysOfWeek = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ Nhật"];

        const allData = dailyPlaysData.map(song => ({
            song_name: song.song_name,
            daily_plays: song.daily_plays.map(dayData => ({
                day: dayData.day,
                play_count: dayData.play_count,
            }))
        }));

        const datasets = allData.map((song, index) => ({
            label: song.song_name,
            data: song.daily_plays.map(dayData => dayData.play_count),
            fill: false,
            borderColor: `rgba(${(index * 50) % 255}, ${(index * 100) % 255}, ${(index * 150) % 255}, 1)`, // Sử dụng màu sắc khác nhau cho mỗi bài hát
            backgroundColor: `rgba(${(index * 50) % 255}, ${(index * 100) % 255}, ${(index * 150) % 255}, 0.2)`,
            tension: 0.4,
        }));

        return {
            labels: daysOfWeek, // Sử dụng mảng các ngày trong tuần thay vì số
            datasets: datasets,
        };
    };

    // Biểu đồ "Lượt Thích Theo Ngày Trong Tuần"
    const prepareLikedSongsChartData = () => {
        const daysOfWeek = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ Nhật"];

        const allData = topLikedSongsWeek.map(song => ({
            song_name: song.song_name,
            daily_plays: song.daily_plays.map(dayData => ({
                day: dayData.day,
                play_count: dayData.play_count,
            }))
        }));

        const datasets = allData.map((song, index) => ({
            label: song.song_name,
            data: song.daily_plays.map(dayData => dayData.play_count),
            fill: false,
            borderColor: `rgba(${(index * 50) % 255}, ${(index * 100) % 255}, ${(index * 150) % 255}, 1)`, // Sử dụng màu sắc khác nhau cho mỗi bài hát
            backgroundColor: `rgba(${(index * 50) % 255}, ${(index * 100) % 255}, ${(index * 150) % 255}, 0.2)`,
            tension: 0.4,
        }));

        return {
            labels: daysOfWeek, // Sử dụng mảng các ngày trong tuần thay vì số
            datasets: datasets,
        };
    };

    // Hàm chuẩn bị dữ liệu cho Pie Chart
    const preparePieChartData = () => {
        return {
            labels: genrePercentage.map(item => item.genre_name),
            datasets: [
                {
                    data: genrePercentage.map(item => item.percentage),
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.6)',
                        'rgba(54, 162, 235, 0.6)',
                        'rgba(255, 206, 86, 0.6)',
                        'rgba(75, 192, 192, 0.6)',
                        'rgba(153, 102, 255, 0.6)',
                    ],
                    borderColor: [
                        'rgba(255, 99, 132, 1)',
                        'rgba(54, 162, 235, 1)',
                        'rgba(255, 206, 86, 1)',
                        'rgba(75, 192, 192, 1)',
                        'rgba(153, 102, 255, 1)',
                    ],
                    borderWidth: 1,
                },
            ],
        };
    };


    // Đảm bảo có ít nhất 10 bài hát, nếu không thêm các bài hát trống
    const prepareTopFavoriteSongsData = () => {
        const emptySongs = Array(10 - topFavoriteSongs.length).fill({
            song_name: '',
            album_name: '',
            user_name: '',
            total_favorite_count: '',
        });
        return [...topFavoriteSongs, ...emptySongs];
    };


    // Đảm bảo có ít nhất 10 bài hát, nếu không thêm các bài hát trống
    const prepareTopSongsData = () => {
        const emptySongs = Array(10 - topPlayedSongs.length).fill({
            song_name: '',
            album_name: '',
            play_count: '',
        });
        return [...topPlayedSongs, ...emptySongs];
    };

    // Thêm hàm để chuẩn bị dữ liệu cho biểu đồ
    const prepareTopArtistsChartData = () => {
        return {
            labels: topArtists.map(artist => artist.artist_name),
            datasets: [
                {
                    label: 'Số người theo dõi',
                    data: topArtists.map(artist => artist.follower_count),
                    backgroundColor: [
                        'rgba(78, 115, 223, 0.8)',
                        'rgba(54, 185, 204, 0.8)',
                        'rgba(28, 200, 138, 0.8)'
                    ],
                    borderColor: [
                        'rgb(78, 115, 223)',
                        'rgb(54, 185, 204)',
                        'rgb(28, 200, 138)'
                    ],
                    borderWidth: 1
                }
            ]
        };
    };

    return (
        <div className="container-fluid mt-4 p-0 animate__animated animate__fadeIn">
            {/* Phần chọn ngày và thông số tổng */}
            <div className="card mb-4 p-3 shadow-sm border-0 animate__animated animate__fadeInDown">
                <div className="row align-items-center">
                    {/* Mục chọn ngày */}
                    <div className="col-md-4 mb-3">
                        <label htmlFor="datePicker" className="form-label fw-bold">
                            <i className="fas fa-calendar-alt me-2"></i>Chọn Ngày:
                        </label>
                        <input
                            type="date"
                            id="datePicker"
                            className="form-control form-control-lg"
                            value={selectedDate}
                            onChange={handleDateChange}
                        />
                    </div>

                    {/* Thống kê tổng */}
                    <div className="col-md-8 row text-center">
                        {/* Tổng Người Dùng */}
                        <div className="col-3">
                            <div className="p-3 border rounded bg-light hover-scale animate__animated animate__fadeInRight" style={{ animationDelay: '0.1s' }}>
                                <i className="fas fa-users fs-3 text-primary"></i>
                                <h6 className="fw-bold mt-2">Tổng Người Dùng</h6>
                                <p className="mb-0 fs-4">{userRoleCounts.user_count}</p>
                            </div>
                        </div>

                        {/* Tổng Quản Trị Viên */}
                        <div className="col-3">
                            <div className="p-3 border rounded bg-light hover-scale animate__animated animate__fadeInRight" style={{ animationDelay: '0.2s' }}>
                                <i className="fas fa-user-shield fs-3 text-success"></i>
                                <h6 className="fw-bold mt-2">Tổng Quản Trị Viên</h6>
                                <p className="mb-0 fs-4">{userRoleCounts.moderator_count}</p>
                            </div>
                        </div>

                        {/* Tổng Nghệ Sĩ */}
                        <div className="col-3">
                            <div className="p-3 border rounded bg-light hover-scale animate__animated animate__fadeInRight" style={{ animationDelay: '0.3s' }}>
                                <i className="fas fa-microphone-alt fs-3 text-warning"></i>
                                <h6 className="fw-bold mt-2">Tổng Nghệ Sĩ</h6>
                                <p className="mb-0 fs-4">{userRoleCounts.artist_count}</p>
                            </div>
                        </div>

                        {/* Tổng Lượt Nghe */}
                        <div className="col-3">
                            <div className="p-3 border rounded bg-light hover-scale animate__animated animate__fadeInRight" style={{ animationDelay: '0.4s' }}>
                                <i className="fas fa-headphones fs-3 text-info"></i>
                                <h6 className="fw-bold mt-2">Tổng Lượt Nghe</h6>
                                <p className="mb-0 fs-4">{userRoleCounts.total_play_count}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Bảng thống kê */}
            <div className="d-flex justify-content-between gap-4">
                {/* Top Bài Hát Yêu Thích Nhất */}
                <div className="col-md-6 animate__animated animate__fadeInLeft">
                    <div className="card border-0 shadow-sm mb-3 hover-shadow">
                        <div className="card-header bg-gradient-primary text-white text-center py-3">
                            <h5 className="card-title mb-0">
                                <i className="fas fa-heart me-2"></i>
                                Top Bài Hát Yêu Thích Nhất
                            </h5>
                        </div>
                        <div className="card-body p-0">
                            <table className="table table-bordered table-striped mb-0">
                                <thead className="table-dark text-center">
                                    <tr>
                                        <th>#</th>
                                        <th>Tên Bài Hát</th>
                                        <th>Nghệ sĩ</th>
                                        <th>Lượt Yêu Thích</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {prepareTopFavoriteSongsData().map((song, index) => (
                                        <tr key={index} className="text-center align-middle">
                                            <td>{index + 1}</td>
                                            <td>{song.song_name || '-'}</td>
                                            <td>{song.user_name || '-'}</td>
                                            <td>{song.favorite_count || '-'}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                {/* Top Bài Hát Được Nghe Nhiều Nhất */}
                <div className="col-md-6 animate__animated animate__fadeInRight">
                    <div className="card border-0 shadow-sm mb-3 hover-shadow">
                        <div className="card-header bg-gradient-success text-white text-center py-3">
                            <h5 className="card-title mb-0">
                                <i className="fas fa-music me-2"></i>
                                Top Bài Hát Được Nghe Nhiều Nhất
                            </h5>
                        </div>
                        <div className="card-body p-0">
                            <table className="table table-bordered table-striped mb-0">
                                <thead className="table-dark text-center">
                                    <tr>
                                        <th>#</th>
                                        <th>Tên Bài Hát</th>
                                        <th>Nghệ sĩ</th>
                                        <th>Lượt Nghe</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {prepareTopSongsData().map((song, index) => (
                                        <tr key={song.id || index} className="text-center align-middle">
                                            <td>{index + 1}</td>
                                            <td>{song.song_name || '-'}</td>
                                            <td>{song.user_name || '-'}</td>
                                            <td>{song.play_count || '-'}</td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            {/* Biểu đồ thống kê */}
            <div className="row g-4 mt-2">
                <div className="col-md-6">
                    <div className="card shadow-sm border-0 h-100">
                        <div className="card-body">
                            <h5 className="card-title text-center mb-3">
                                Top Nghệ Sĩ Được Theo Dõi
                            </h5>
                            <Bar
                                data={prepareTopArtistsChartData()}
                                options={{
                                    responsive: true,
                                    plugins: {
                                        legend: { position: 'top' },
                                        title: { display: true, text: 'Top Nghệ Sĩ Được Theo Dõi' }
                                    },
                                    scales: {
                                        y: {
                                            beginAtZero: true,
                                            title: {
                                                display: true,
                                                text: 'Số người theo dõi'
                                            }
                                        },
                                        x: {
                                            title: {
                                                display: true,
                                                text: 'Nghệ sĩ'
                                            }
                                        }
                                    }
                                }}
                            />
                        </div>
                    </div>
                </div>

                {/* Tỷ Lệ Thể Loại Nhạc (Pie Chart - Kích Thước Đồng Nhất) */}
                <div className="col-md-6">
                    <div className="card shadow-sm border-0 h-100">
                        <div className="card-body d-flex flex-column align-items-center">
                            <h5 className="card-title text-center mb-3">Tỷ Lệ Thể Loại Nhạc</h5>
                            <div style={{ width: '100%', height: '70%' }}>
                                <Pie
                                    data={preparePieChartData()}
                                    options={{
                                        responsive: true,
                                        maintainAspectRatio: false, // Đảm bảo pie chart không bị méo
                                        plugins: {
                                            legend: { position: 'top' },
                                            title: { display: true, text: 'Tỷ Lệ Thể Loại Nhạc' },
                                        },
                                    }}
                                />
                            </div>
                        </div>
                    </div>
                </div>

                <div className="col-md-6">
                    <div className="card shadow-sm border-0 h-100">
                        <div className="card-body">
                            <h5 className="card-title text-center mb-3">
                                Bài Hát Được Thích Nhiều Nhất Tuần
                            </h5>
                            <Line
                                data={prepareLikedSongsChartData()}
                                options={{
                                    responsive: true,
                                    plugins: {
                                        legend: { position: 'top' },
                                        title: { display: true, text: 'Bài Hát Được Thích Nhiều Nhất Tuần' },
                                    },
                                }}
                            />
                        </div>
                    </div>
                </div>

                <div className="col-md-6">
                    <div className="card shadow-sm border-0 h-100">
                        <div className="card-body">
                            <h5 className="card-title text-center mb-3">
                                Lượt Nghe Theo Ngày Trong Tuần
                            </h5>
                            <Line
                                data={prepareDailyPlaysChartData()}
                                options={{
                                    responsive: true,
                                    plugins: {
                                        legend: { position: 'top' },
                                        title: { display: true, text: 'Lượt Nghe Theo Ngày Trong Tuần' },
                                    },
                                }}
                            />
                        </div>
                    </div>
                </div>
            </div>

            <div className="row mt-4">
                <div className="col-md-4">
                    <div className="card border-0 shadow-lg hover-shadow animate__animated animate__fadeInUp">
                        <div className="card-header bg-gradient-purple text-white text-center py-4">
                            <h5 className="card-title mb-0">
                                <i className="fas fa-star me-2"></i>
                                Top Nghệ Sĩ Được Theo Dõi
                            </h5>
                        </div>
                        <div className="card-body p-0">
                            {topArtists.map((artist) => (
                                <div
                                    key={artist.artist_id}
                                    className="d-flex align-items-center p-4 border-bottom position-relative overflow-hidden hover-scale"
                                    style={{
                                        background: artist.rank === 1 ? 'linear-gradient(45deg, rgba(255,215,0,0.1), rgba(255,223,0,0.05))' : ''
                                    }}
                                >
                                    {/* Ranking Badge */}
                                    <div className="position-absolute top-0 start-0 p-2">
                                        <span className={`badge ${artist.rank === 1 ? 'bg-warning' :
                                            artist.rank === 2 ? 'bg-secondary' : 'bg-bronze'
                                            } rounded-circle p-2`}>
                                            {artist.rank === 1 ? '🥇' :
                                                artist.rank === 2 ? '🥈' : '🥉'}
                                        </span>
                                    </div>

                                    {/* Artist Image */}
                                    <div className="position-relative me-4">
                                        <img
                                            src={artist.image_url || defaultImage}
                                            alt={artist.artist_name}
                                            className="rounded-circle border-4 border-white shadow-lg"
                                            style={{
                                                width: "80px",
                                                height: "80px",
                                                objectFit: "cover"
                                            }}
                                        />
                                        {artist.rank === 1 && (
                                            <div className="position-absolute top-0 start-100 translate-middle">
                                                <i className="fas fa-crown text-warning fs-4 animate__animated animate__swing animate__infinite"></i>
                                            </div>
                                        )}
                                    </div>

                                    {/* Artist Info */}
                                    <div className="flex-grow-1">
                                        <h5 className="mb-1 fw-bold">{artist.artist_name}</h5>
                                        <div className="d-flex align-items-center">
                                            <span className="badge bg-primary-soft text-primary rounded-pill">
                                                <i className="fas fa-users me-1"></i>
                                                {artist.follower_count.toLocaleString()} người theo dõi
                                            </span>
                                        </div>
                                    </div>

                                    {/* Decoration for top artist */}
                                    {artist.rank === 1 && (
                                        <div className="position-absolute end-0 top-50 translate-middle-y me-3">
                                            <i className="fas fa-certificate text-warning opacity-25 fa-3x"></i>
                                        </div>
                                    )}
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Thêm styles mới */}
                    <style jsx>{`
                        .bg-gradient-purple {
                            background: linear-gradient(45deg, #6f42c1, #8a5cd0);
                        }

                        .bg-bronze {
                            background-color: #cd7f32;
                        }

                        .bg-primary-soft {
                            background-color: rgba(13, 110, 253, 0.1);
                        }

                        .hover-scale {
                            transition: all 0.3s ease;
                        }

                        .hover-scale:hover {
                            transform: translateX(10px);
                            background-color: rgba(0,0,0,0.02);
                        }

                        .border-bottom:last-child {
                            border-bottom: none !important;
                        }

                        @keyframes float {
                            0% { transform: translateY(0px); }
                            50% { transform: translateY(-5px); }
                            100% { transform: translateY(0px); }
                        }

                        .animate__swing {
                            animation: float 2s ease-in-out infinite;
                        }
                    `}</style>
                </div>
            </div>

            {/* Thêm CSS cho animation và hover effects */}
            <style jsx>{`
                .hover-scale {
                    transition: transform 0.2s ease-in-out;
                }
                .hover-scale:hover {
                    transform: scale(1.05);
                }
                .hover-shadow {
                    transition: box-shadow 0.3s ease-in-out;
                }
                .hover-shadow:hover {
                    box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
                }
                .bg-gradient-primary {
                    background: linear-gradient(45deg, #4e73df 0%, #224abe 100%);
                }
                .bg-gradient-success {
                    background: linear-gradient(45deg, #1cc88a 0%, #13855c 100%);
                }
                .card {
                    border-radius: 0.75rem;
                }
                .table th {
                    font-weight: 600;
                }
            `}</style>
        </div>
    );


};

export default AdminThongKe;

