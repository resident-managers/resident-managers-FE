# CHANGELOG

Tất cả thay đổi đáng chú ý của project sẽ được ghi lại tại đây.

Format: `[version] - YYYY-MM-DD`
Loại thay đổi: `Added` · `Changed` · `Fixed` · `Removed`

---

## [Unreleased]

---

## [1.0.0] - 2026-03-17

### Added
- Màn hình chi tiết cư dân với đầy đủ CRUD (thêm/sửa/xóa)
- Màn hình dashboard thống kê tổng quan dân cư
- Quản lý bảo hiểm y tế và bảo hiểm xã hội theo từng cư dân
- Quản lý tạm trú và tạm vắng
- Cập nhật app icon mới (adaptive icon Android, nền teal `#3AB9C8`)

---

## [0.3.0] - 2026-03-16

### Added
- Tích hợp đầy đủ CRUD cư dân và hộ khẩu qua GraphQL mutations
- Màn hình danh sách hộ khẩu và chi tiết hộ khẩu
- Chức năng đăng xuất, xóa token và tái tạo GraphQL client

### Changed
- Cải tiến logic xử lý ngôn ngữ và hiển thị thông tin hộ khẩu

---

## [0.2.0] - 2026-03-03

### Added
- Tìm kiếm, lọc theo giới tính và sắp xếp trong danh sách cư dân
- Màn hình tạo và chỉnh sửa hộ khẩu (`SetupHouseholdScreen`)

### Changed
- Hoàn thiện luồng đăng xuất
- Cải thiện hiển thị chi tiết hộ khẩu và danh sách thành viên

---

## [0.1.0] - 2026-02-25

### Added
- Khởi tạo project Flutter
- Cấu hình GitHub Actions CI (build APK, tạo tag tự động)
- Kết nối GraphQL backend với xác thực JWT (AuthLink + SecureStorage)
- Routing với GoRouter (10 routes)
- State management với Riverpod
- Màn hình đăng nhập
- Danh sách cư dân cơ bản
