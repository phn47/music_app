import React, { useEffect, useState } from "react";
import { Routes, Route, useNavigate } from "react-router-dom";
import HomePage from "./pages/HomePage";
import RegisterPage from "./pages/RegisterPage";
import SongListPage from "./pages/SongListPage";
import LoginPage from "./pages/LoginPage";
import LogoutButton from "./pages/LogoutButton"; // Import LogoutButton
import SongPage from "./pages/SongPage"; 
import LoginAdminPage from "./pages/LoginAdminPage";
import AdminPage from "./pages/AdminPage";
import AddEmployeePage from "./pages/AddEmployeePage";
import NhanVienPage from "./pages/NhanVienPage";
import AddCategoryPage from "./pages/AddCategoryPage";
import SignUpArtistPage from "./pages/SignUpArtistPage";
import PhieuArtPage from "./pages/PhieuArtPage"; // Import PhieuArtPage
import PhieuArtTruePage from "./pages/PhieuArtTruePage"; // Import PhieuArtPage
import PhieuArtBanned from "./pages/PhieuArtBanned"; // Import PhieuArtPage
import QuanLyArtist from "./pages/QuanLyArtist"; // Import PhieuArtPage
import QuanLySongPage from "./pages/QuanLySongPage"; // Import PhieuArtPage
import DuyetSongPage from "./pages/DuyetSongPage";
import AnSongPage from "./pages/AnSongPage";
import DabianSongPage from "./pages/DabianSongPage";
import LoginArtistPage from "./pages/LoginArtistPage";
import TrangArt from "./pages/TrangArt";
import AnSongByArt from "./pages/AnSongByArt";
import GuiLaiPage from "./pages/GuiLaiPage";
import QuanLyUserPage from "./pages/QuanLyUserPage";
import QuanLyUserPageAdmin from "./pages/QuanLyUserPageAdmin";
import QuanLyNhanVien from "./pages/QuanLyNhanVien";
import QuanLyAlbumsPage from "./pages/QuanLyAlbums";
import DuyetAlbumPage from "./pages/DuyetAlbumPage";
import AnAlbum from "./pages/AnAlbum";
import DabianAlbum from "./pages/DabianAlbum";
import AdminThongKe from "./pages/AdminThongKe";
import AnUser from "./pages/AnUser";
import DaBiAnUser from "./pages/DaBiAnUser";
import PhieuNhanVienBanned from "./pages/PhieuNhanVienBanned";
import DaBiAnNhanVien from "./pages/DaBiAnNhanVien";
import DaBiAnSongByArt from "./pages/DaBiAnSongByArt";
import ThongTinCaNhan from "./pages/ThongTinCaNhan";
import Artist from "./pages/Artist";
import QuanLyAlbumArt from "./pages/QuanLyAlbumArt";

import AnAlbumByArt from "./pages/AnAlbumByArt";
import DabianAlbumByArt from "./pages/DabianAlbumByArt";


function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const navigate = useNavigate();

  // Kiểm tra token khi ứng dụng được tải
  useEffect(() => {
    const token = localStorage.getItem("token");
    if (token) {
      setIsAuthenticated(true); // Nếu có token, người dùng đã đăng nhập
    } else {
      setIsAuthenticated(false); // Nếu không có token, người dùng chưa đăng nhập
    }
  }, []);
// && <LogoutButton />
  return (
    <div className="app-container">
      {isAuthenticated } {/* Hiển thị nút đăng xuất nếu đã đăng nhập */}
      <Routes>
        {/* Trang không yêu cầu đăng nhập */}
        <Route path="/" element={<HomePage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/loginadmin" element={<LoginAdminPage />} />
        <Route path="/dangkyart" element={<SignUpArtistPage />} />
        <Route path="/loginart" element={<LoginArtistPage />} />
        
        
        {/* Các trang yêu cầu đăng nhập */}
        <Route
          path="/song-list"
          element={isAuthenticated ? <SongListPage /> : <LoginPage />}
        />
        <Route path="/song" element={isAuthenticated ? <SongPage /> : <LoginPage />} />
        
        {/* <Route path="/admin" element={ <AdminPage /> } /> */}
        <Route
          path="/admin"
          element={ <AdminPage />}
        >
          <Route path="addtl" element={<AddCategoryPage />} />
          <Route path="/admin/thongke" element={<AdminThongKe />} />
          <Route path="quanlyuser" element={<QuanLyUserPageAdmin />} />
          <Route path="/admin/addnv" element={ <AddEmployeePage /> } />
          <Route path="phieuartbanned" element={<PhieuArtBanned />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="phieuuserbanned" element={<AnUser />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="dabianuser" element={<DaBiAnUser />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="quanlynhanvien" element={<QuanLyNhanVien />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="phieunhanvienbanned" element={<PhieuNhanVienBanned />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="dabiannhanvien" element={<DaBiAnNhanVien />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="thongtincanhan" element={<ThongTinCaNhan />} /> {/* Thêm route cho PhieuArtPage */}
          
        

        </Route>
        ThongTinCaNhan


        <Route
          path="/nhanvien"
          element={isAuthenticated ? <NhanVienPage /> : <LoginPage />}
        >
          <Route path="addtl" element={<AddCategoryPage />} />
          <Route path="quanlyartist" element={<QuanLyArtist />} />
          <Route path="quanlysong" element={<QuanLySongPage />} />
          <Route path="quanlyalbum" element={<QuanLyAlbumsPage />} />
          <Route path="quanlyuser" element={<QuanLyUserPage />} />
          <Route path="ansong" element={<AnSongPage  />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="dabiansong" element={<DabianSongPage />} />
          <Route path="duyetsong" element={<DuyetSongPage  />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="phieuart" element={<PhieuArtPage />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="phieuarttrue" element={<PhieuArtTruePage />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="phieuartbanned" element={<PhieuArtBanned />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="phieuuserbanned" element={<AnUser />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="dabianuser" element={<DaBiAnUser />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="thongtincanhan" element={<ThongTinCaNhan />} /> {/* Thêm route cho PhieuArtPage */}
          <Route path="analbum" element={<AnAlbum />} />
          <Route path="daanalbum" element={<DabianAlbum />} />
          <Route path="duyetalbum" element={<DuyetAlbumPage />} />
          
          
       
        
        </Route>





        <Route
          path="/artist"
          element={isAuthenticated ? <Artist /> : <LoginPage />}
        >
             <Route path="trangart" element={<TrangArt />} />
             <Route path="dabisongbyart" element={<DaBiAnSongByArt />} />
        <Route path="ansongbyart" element={<AnSongByArt />} />
        <Route path="guilai" element={<GuiLaiPage />} />
        <Route path="quanlyablumart" element={<QuanLyAlbumArt />} />  
        <Route path="analbumbyart" element={<AnAlbumByArt />} />  
        <Route path="daanalbumbyart" element={<DabianAlbumByArt />} />  
       
        
        </Route>


        {/* <Route path="/nhanvien" element={isAuthenticated ? <NhanVienPage /> : <LoginPage />} /> */}
   
  
       

        {/* <Route path="/trangart" element={<TrangArt />} />
        <Route path="/dabisongbyart" element={<DaBiAnSongByArt />} />
        <Route path="/ansongbyart" element={<AnSongByArt />} />
        <Route path="/guilai" element={<GuiLaiPage />} /> */}
        
{/*        
        <Route path="/duyetalbum" element={<DuyetAlbumPage />} /> */}
        {/* <Route path="/analbum" element={<AnAlbum />} /> */}
        {/* <Route path="/daanalbum" element={<DabianAlbum />} />
        */}
        
      
      
 
      
      </Routes>
    </div>
  );
}

export default App;
