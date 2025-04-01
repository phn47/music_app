import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.min.css";
import "animate.css";

function AddEmployeePage() {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [searchTerm, setSearchTerm] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [newEmployee, setNewEmployee] = useState({
    name: "",
    email: "",
    password: "",
  });
  const itemsPerPage = 8;
  const navigate = useNavigate();

  useEffect(() => {
    fetchEmployees();
  }, []);

  const fetchEmployees = async () => {
    try {
      const response = await fetch("http://127.0.0.1:8000/auth/list");
      if (!response.ok) {
        throw new Error("Không thể tải danh sách nhân viên");
      }
      const data = await response.json();
      setEmployees(data);
    } catch (error) {
      setError("Lỗi khi tải danh sách nhân viên: " + error.message);
    }
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setNewEmployee((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleAddEmployee = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    setSuccess("");

    try {
      const response = await fetch("http://127.0.0.1:8000/auth/signupnv", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(newEmployee),
      });

      if (response.ok) {
        setNewEmployee({ name: "", email: "", password: "" });
        fetchEmployees();
        setIsModalOpen(false);
      } else {
        const errorData = await response.json();
        throw new Error(errorData.detail || "Lỗi khi thêm nhân viên.");
      }
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const filteredEmployees = employees.filter(employee =>
    employee.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="container-fluid py-4 animate__animated animate__fadeIn">
      <div className="card shadow-lg border-0">
        <div className="card-header bg-gradient-primary py-4">
          <div className="row align-items-center">
            <div className="col">
              <h3 className="mb-0 text-white">
                Quản Lý Nhân Viên
              </h3>
            </div>
            <div className="col text-end">
              <button
                className="btn btn-light shadow-sm animate__animated animate__fadeInRight"
                onClick={() => setIsModalOpen(true)}
              >
                <i className="fas fa-plus-circle me-2"></i>
                Thêm Nhân Viên Mới
              </button>
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
                    placeholder="Tìm kiếm nhân viên..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                  />
                </div>
              </div>
            </div>
            <div className="col text-end">
              <span className="text-muted">
                Tổng số: {filteredEmployees.length} nhân viên
              </span>
            </div>
          </div>

          <div className="table-responsive">
            <table className="table table-hover align-middle table-nowrap">
              <thead className="table-light">
                <tr>
                  <th className="text-center" style={{ width: "5%" }}>STT</th>
                  <th style={{ width: "30%" }}>Tên nhân viên</th>
                  <th style={{ width: "45%" }}>Email</th>
                  <th className="text-center" style={{ width: "20%" }}>Trạng thái</th>
                </tr>
              </thead>
              <tbody>
                {filteredEmployees
                  .slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage)
                  .map((employee, index) => (
                    <tr
                      key={employee.id}
                      className="animate__animated animate__fadeIn"
                      style={{ animationDelay: `${index * 0.1}s` }}
                    >
                      <td className="text-center fw-medium">{(currentPage - 1) * itemsPerPage + index + 1}</td>
                      <td>
                        <h6 className="mb-0">{employee.name}</h6>
                      </td>
                      <td>{employee.email}</td>
                      <td className="text-center">
                        <span className="badge bg-soft-success text-success rounded-pill px-3">
                          <i className="fas fa-check-circle me-1"></i>
                          Hoạt động
                        </span>
                      </td>
                    </tr>
                  ))}
              </tbody>
            </table>
          </div>

          <div className="d-flex justify-content-between align-items-center mt-4">
            <div className="text-muted small">
              Trang {currentPage} / {Math.ceil(filteredEmployees.length / itemsPerPage)}
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
                {Array.from({ length: Math.ceil(filteredEmployees.length / itemsPerPage) }, (_, i) => (
                  <li key={i + 1} className={`page-item ${currentPage === i + 1 ? 'active' : ''}`}>
                    <button
                      className="page-link rounded"
                      onClick={() => setCurrentPage(i + 1)}
                    >
                      {i + 1}
                    </button>
                  </li>
                ))}
                <li className={`page-item ${currentPage === Math.ceil(filteredEmployees.length / itemsPerPage) ? 'disabled' : ''}`}>
                  <button
                    className="page-link rounded"
                    onClick={() => setCurrentPage(prev => Math.min(prev + 1, Math.ceil(filteredEmployees.length / itemsPerPage)))}
                  >
                    <i className="fas fa-chevron-right"></i>
                  </button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>

      {/* Modal Add Employee */}
      {isModalOpen && (
        <div className="modal-backdrop" style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(0, 0, 0, 0.7)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 9999,
        }}>
          <div className="modal-dialog animate__animated animate__fadeIn" style={{
            margin: 0,
            width: '100%',
            maxWidth: '500px',
            position: 'relative',
            zIndex: 10000
          }}>
            <div className="modal-content shadow-lg border-0" style={{
              borderRadius: '15px',
              backgroundColor: '#ffffff',
              boxShadow: '0 5px 15px rgba(0,0,0,0.3)'
            }}>
              <div className="modal-header border-0 bg-primary text-white px-4 py-3" style={{
                borderRadius: '15px 15px 0 0',
                background: 'linear-gradient(135deg, #0d6efd 0%, #0a4cbd 100%)'
              }}>
                <h5 className="modal-title fs-4 fw-bold d-flex align-items-center">
                  <i className="fas fa-plus-circle me-2"></i>
                  Thêm Nhân Viên Mới
                </h5>
                <button
                  type="button"
                  className="btn-close btn-close-white shadow-none"
                  onClick={() => setIsModalOpen(false)}
                  style={{
                    position: 'absolute',
                    top: '10px',
                    right: '10px',
                    fontSize: '20px',
                    transition: 'transform 0.2s',
                  }}
                  onMouseOver={e => e.target.style.transform = 'rotate(90deg)'}
                  onMouseOut={e => e.target.style.transform = 'rotate(0deg)'}
                ></button>
              </div>
              <form onSubmit={handleAddEmployee} className="needs-validation" style={{ margin: 0 }}>
                <div className="modal-body p-4">
                  <div className="mb-4">
                    <label className="form-label fw-bold text-dark d-flex align-items-center">
                      <i className="fas fa-user me-2 text-primary"></i>
                      Tên nhân viên
                    </label>
                    <div className="input-group input-group-lg">
                      <input
                        type="text"
                        name="name"
                        className="form-control border"
                        placeholder="Nhập tên nhân viên"
                        value={newEmployee.name}
                        onChange={handleInputChange}
                        required
                        style={{
                          backgroundColor: '#ffffff',
                          boxShadow: '0 2px 5px rgba(0,0,0,0.1)'
                        }}
                      />
                    </div>
                  </div>
                  <div className="mb-4">
                    <label className="form-label fw-bold text-dark d-flex align-items-center">
                      <i className="fas fa-envelope me-2 text-primary"></i>
                      Email
                    </label>
                    <div className="input-group input-group-lg">
                      <input
                        type="email"
                        name="email"
                        className="form-control border"
                        placeholder="Nhập email"
                        value={newEmployee.email}
                        onChange={handleInputChange}
                        required
                        style={{
                          backgroundColor: '#ffffff',
                          boxShadow: '0 2px 5px rgba(0,0,0,0.1)'
                        }}
                      />
                    </div>
                  </div>
                  <div className="mb-4">
                    <label className="form-label fw-bold text-dark d-flex align-items-center">
                      <i className="fas fa-lock me-2 text-primary"></i>
                      Mật khẩu
                    </label>
                    <div className="input-group input-group-lg">
                      <input
                        type="password"
                        name="password"
                        className="form-control border"
                        placeholder="Nhập mật khẩu"
                        value={newEmployee.password}
                        onChange={handleInputChange}
                        required
                        style={{
                          backgroundColor: '#ffffff',
                          boxShadow: '0 2px 5px rgba(0,0,0,0.1)'
                        }}
                      />
                    </div>
                  </div>
                  {error && (
                    <div className="alert alert-danger mb-4 animate__animated animate__shakeX">
                      <i className="fas fa-exclamation-circle me-2"></i>
                      {error}
                    </div>
                  )}
                  {success && (
                    <div className="alert alert-success mb-4 animate__animated animate__bounceIn">
                      <i className="fas fa-check-circle me-2"></i>
                      {success}
                    </div>
                  )}
                </div>
                <div className="modal-footer border-0 px-4 py-3" style={{
                  borderRadius: '0 0 15px 15px',
                  backgroundColor: '#f8f9fa'
                }}>
                  <button
                    type="button"
                    className="btn btn-light btn-lg px-4"
                    onClick={() => setIsModalOpen(false)}
                    style={{
                      backgroundColor: '#ffffff',
                      border: '1px solid #dee2e6'
                    }}
                  >
                    <i className="fas fa-times me-2"></i>
                    Đóng
                  </button>
                  <button
                    type="submit"
                    className="btn btn-primary btn-lg px-4"
                    disabled={loading}
                    style={{
                      background: 'linear-gradient(135deg, #0d6efd 0%, #0a4cbd 100%)',
                      border: 'none'
                    }}
                  >
                    {loading ? (
                      <>
                        <span className="spinner-border spinner-border-sm me-2"></span>
                        Đang thêm...
                      </>
                    ) : (
                      <>
                        <i className="fas fa-plus-circle me-2"></i>
                        Thêm nhân viên
                      </>
                    )}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

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

        .modal-backdrop {
          backdrop-filter: blur(5px);
        }

        .modal-content {
          box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
        }

        .form-control {
          border: 1px solid #dee2e6;
        }

        .form-control:focus {
          border-color: #0d6efd;
          box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
        }

        .btn-primary:hover {
          background: linear-gradient(135deg, #0a4cbd 0%, #083b9a 100%) !important;
        }

        .btn-light:hover {
          background-color: #f8f9fa !important;
        }
      `}</style>
    </div>
  );
}

export default AddEmployeePage;
