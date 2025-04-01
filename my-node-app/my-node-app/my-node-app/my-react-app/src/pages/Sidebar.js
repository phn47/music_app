import React from "react";
import { FaPlus, FaUsers, FaMusic, FaAlbum, FaUserCog } from "react-icons/fa"; // Thêm icon từ react-icons

function Sidebar({ 
  handleAddCategory,
  handleManageEmployees,
  handleManageSongs,
  handleManageUsers,
  handleManageAlbums,
}) {
  return (
    <div className="sidebar">
     <button onClick={handleAddCategory} className="sidebar-btn add-category-btn">
        <FaPlus className="sidebar-icon" /> Thêm Thể Loại
      </button>
      <button onClick={handleManageEmployees} className="sidebar-btn manage-employees-btn">
        <FaUserCog className="sidebar-icon" /> Quản Lý Nhân Viên
      </button>
      <button onClick={handleManageSongs} className="sidebar-btn manage-songs-btn">
        <FaMusic className="sidebar-icon" /> Quản Lý Bài Hát
      </button>
      <button onClick={handleManageUsers} className="sidebar-btn manage-users-btn">
        <FaUsers className="sidebar-icon" /> Quản Lý Người Dùng
      </button>
 
      </div>
  );
}
//      <button onClick={handleManageAlbums} className="sidebar-btn manage-albums-btn">
//<FaAlbum className="sidebar-icon" /> Quản Lý Album
//</button>   
export default Sidebar;
