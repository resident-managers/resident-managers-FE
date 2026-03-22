# Residential Management System

Ứng dụng quản lý dân cư dành cho cán bộ phường/xã, hỗ trợ tra cứu, cập nhật thông tin cư dân, hộ khẩu, bảo hiểm và tình trạng cư trú.

## Tính năng

- **Quản lý cư dân**: Tìm kiếm, lọc, thêm/sửa/xóa hồ sơ cư dân
- **Quản lý hộ khẩu**: Tạo và cập nhật thông tin hộ khẩu, danh sách thành viên
- **Bảo hiểm**: Theo dõi bảo hiểm y tế và bảo hiểm xã hội của từng cư dân
- **Tình trạng cư trú**: Quản lý tạm trú, tạm vắng, thường trú
- **Thống kê**: Dashboard tổng quan số liệu dân cư

## Tech Stack

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter |
| State Management | Riverpod (flutter_riverpod + riverpod_annotation) |
| Backend | GraphQL API |
| Routing | GoRouter |
| Auth Storage | flutter_secure_storage |
| Image Caching | cached_network_image |

## Kiến trúc

Ứng dụng theo luồng một chiều: **GraphQL → Providers → UI**

```
GraphQL API (GRAPHQL_ENDPOINT)
        │
        ▼
lib/graphql/
  ├── queries.dart      # Tất cả câu truy vấn (getResidents, getHouseholds, ...)
  └── mutations.dart    # Tất cả thao tác ghi (create, update, delete)
        │
        ▼
lib/providers/          # Riverpod FutureProviders — cầu nối giữa API và UI
        │
        ▼
lib/screens/            # ConsumerWidget / ConsumerStatefulWidget
```

**Authentication flow:**
1. Người dùng đăng nhập → `authProvider` gọi `loginMutation`
2. JWT token nhận về được lưu vào `SecureStorage`
3. `GraphQLConfig` tái tạo client với `AuthLink` tự động đính kèm `Bearer <token>` vào mọi request
4. Đăng xuất: xóa token → tái tạo client → điều hướng về `/login`

## Cài đặt

### Yêu cầu

- Flutter SDK
- Dart SDK ^3.10.3

### Chạy ứng dụng

```bash
# Cài dependencies
flutter pub get

# Tạo file cấu hình môi trường
cp .env.example .env
# Chỉnh sửa GRAPHQL_ENDPOINT trong .env

# Sinh code Riverpod (chạy lần đầu hoặc sau khi sửa @riverpod)
dart run build_runner build --delete-conflicting-outputs

# Chạy ứng dụng
flutter run
```

### Build

```bash
flutter build apk           # Android APK
flutter build appbundle     # Android App Bundle
```

## Cấu hình môi trường

Tạo file `.env` tại root project:

```env
GRAPHQL_ENDPOINT=https://your-api.com/graphql
```

## Màn hình chính

| Route | Màn hình | Mô tả |
|---|---|---|
| `/login` | Đăng nhập | Xác thực tài khoản |
| `/dashboard` | Dashboard | Thống kê tổng quan |
| `/directory` | Danh sách cư dân | Tìm kiếm, lọc theo giới tính, sắp xếp |
| `/add-resident` | Thêm cư dân | Form tạo hồ sơ mới |
| `/resident-detail/:id` | Chi tiết cư dân | Thông tin, bảo hiểm, tình trạng cư trú |
| `/resident-detail/:id/edit` | Sửa cư dân | Cập nhật hồ sơ |
| `/households` | Danh sách hộ khẩu | Danh sách các hộ |
| `/household/:id` | Chi tiết hộ khẩu | Thông tin hộ và thành viên |
| `/setup-household` | Tạo hộ khẩu | Form tạo hộ mới |
| `/household/:id/edit` | Sửa hộ khẩu | Cập nhật thông tin hộ |
