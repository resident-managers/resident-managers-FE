# KẾ HOẠCH FRONTEND FLUTTER (Dựng theo cấu trúc project hiện tại)

> **Backend đã có:** Laravel 11 + Lighthouse GraphQL trong `/public_html`  
> **Mục tiêu:** Dựng app Flutter (Android APK) kết nối GraphQL, phục vụ nhập liệu và tra cứu dân cư/hộ dân.

---

## 1. Tóm tắt bối cảnh dự án

- Project hiện tại là Laravel với GraphQL schema đặt trong thư mục `graphql/`.
- Endpoint dự kiến: `https://<domain>/graphql`.
- Cơ sở dữ liệu: MySQL, quan hệ chặt (dân cư, hộ dân, thành viên hộ).

Flutter sẽ là **app riêng**, tách code khỏi Laravel. Đề xuất đặt trong thư mục:
- `flutter_app/` (mới, ở cùng cấp với `app/`, `routes/`, `graphql/`…)

---

## 2. Phạm vi chức năng Flutter (MVP)

- Đăng nhập bằng token (Sanctum / custom login từ backend).
- Tra cứu danh sách dân cư.
- Tạo/sửa/xóa dân cư.
- Tra cứu danh sách hộ dân.
- Xem chi tiết hộ dân (chủ hộ + thành viên).
- Tạo/sửa hộ dân (chọn chủ hộ, quản lý thành viên).
- Tìm kiếm nhanh theo tên/số điện thoại/CCCD.

---

## 3. Kiến trúc Flutter

### 3.1. Công nghệ

- Flutter 3.x
- `graphql_flutter`
- `flutter_riverpod`
- `go_router`
- `flutter_secure_storage` (lưu token)

### 3.2. Cấu trúc thư mục đề xuất

```
flutter_app/
  lib/
    app/
      app.dart
      router.dart
    core/
      config/
        env.dart
      graphql/
        client.dart
        queries.dart
        mutations.dart
      storage/
        secure_storage.dart
      utils/
        validators.dart
    features/
      auth/
        data/
          auth_repository.dart
        presentation/
          login_screen.dart
        state/
          auth_controller.dart
      residents/
        data/
          residents_repository.dart
        presentation/
          residents_list_screen.dart
          resident_detail_screen.dart
          resident_form_screen.dart
        state/
          residents_controller.dart
      households/
        data/
          households_repository.dart
        presentation/
          households_list_screen.dart
          household_detail_screen.dart
          household_form_screen.dart
        state/
          households_controller.dart
    shared/
      widgets/
        app_scaffold.dart
        empty_state.dart
        loading.dart
        search_bar.dart
  pubspec.yaml
```

---

## 4. Kết nối GraphQL (khớp Laravel)

### 4.1. Cấu hình client

- Base URL: `APP_URL/graphql`
- Authorization: `Bearer <token>`

### 4.2. Mapping schema

- Query/Mutation sẽ bám theo schema trong thư mục `graphql/` của backend.
- Các file `queries.dart` và `mutations.dart` trong Flutter định nghĩa rõ payload.

### 4.3. Cấu trúc API GraphQL (tham chiếu trực tiếp schema hiện tại)

> Tất cả query/mutation dưới đây phản ánh từ `graphql/schema.graphql` và `graphql/models/*.graphql`.

#### Auth

```graphql
mutation Login($email: String!, $password: String!) {
  login(input: { email: $email, password: $password }) {
    access_token
    user { id name email }
  }
}
```

```graphql
query Me {
  me { id name email }
}
```

#### Residents (Dân cư)

```graphql
query Residents($fullName: String, $nationalId: String, $phone: String, $first: Int, $page: Int) {
  residents(full_name: $fullName, national_id: $nationalId, phone: $phone, first: $first, page: $page) {
    paginatorInfo { currentPage lastPage perPage total }
    data {
      id
      fullName
      gender
      dateOfBirth
      phone
      nationalId
      address
      occupation
      ethnicity
      religion
      educationLevel
      note
    }
  }
}
```

```graphql
query ResidentDetail($id: ID!) {
  resident(id: $id) {
    id
    fullName
    gender
    dateOfBirth
    phone
    nationalId
    address
    occupation
    ethnicity
    religion
    educationLevel
    note
    householdAsHead { id code address }
    household { id code address }
  }
}
```

```graphql
mutation ResidentCreate($input: ResidentCreateInput!) {
  residentCreate(input: $input) {
    id
    fullName
  }
}
```

```graphql
mutation ResidentUpdate($id: ID!, $input: ResidentUpdateInput!) {
  residentUpdate(id: $id, input: $input) {
    id
    fullName
  }
}
```

```graphql
mutation ResidentDelete($id: ID!) {
  residentDelete(id: $id) {
    id
  }
}
```

#### Households (Hộ dân)

```graphql
query Households($code: String, $first: Int, $page: Int) {
  houseHolds(code: $code, first: $first, page: $page) {
    paginatorInfo { currentPage lastPage perPage total }
    data {
      id
      code
      address
      head { id fullName phone }
      members { id fullName relationship }
    }
  }
}
```

```graphql
query HouseholdDetail($id: ID!) {
  household(id: $id) {
    id
    code
    address
    head {
      id
      fullName
      gender
      dateOfBirth
      phone
      nationalId
    }
    members {
      id
      fullName
      gender
      dateOfBirth
      phone
      nationalId
      relationship
    }
  }
}
```

```graphql
mutation HouseholdCreate($input: HouseholdCreateInput!) {
  householdCreate(input: $input) {
    id
    code
    address
  }
}
```

```graphql
mutation HouseholdUpdate($input: HouseholdUpdateInput!) {
  householdUpdate(input: $input) {
    id
    code
    address
  }
}
```

```graphql
mutation HouseholdDelete($id: ID!) {
  householdDelete(id: $id) {
    id
  }
}
```

#### Input types (dùng khi tạo/sửa)

```graphql
input ResidentCreateInput {
  fullName: String!
  gender: GenderEnum!
  dateOfBirth: Date
  phone: String
  nationalId: String
  address: String
  occupation: String
  ethnicity: String
  religion: String
  educationLevel: String
  note: String
}
```

```graphql
input ResidentUpdateInput {
  id: ID
  fullName: String!
  gender: GenderEnum!
  dateOfBirth: Date
  phone: String
  nationalId: String
  address: String
  occupation: String
  ethnicity: String
  religion: String
  educationLevel: String
  note: String
}
```

```graphql
input HouseholdCreateInput {
  code: String
  residentId: ID!
  address: String!
  members: [HouseholdResidentInput!]
}
```

```graphql
input HouseholdUpdateInput {
  id: ID!
  code: String
  headId: ID
  address: String
  members: [HouseholdResidentInput!]
}
```

```graphql
input HouseholdResidentInput {
  residentId: ID!
  relationship: HouseholdRelationship!
}
```

#### Enum

```graphql
enum GenderEnum {
  MALE
  FEMALE
}
```

> Lưu ý: `HouseholdRelationship` đang được tham chiếu trong schema nhưng chưa thấy định nghĩa enum. Nếu backend chưa khai báo, cần bổ sung enum hoặc đổi về `String`.

---

## 5. Danh sách màn hình chính

1. `LoginScreen`
2. `ResidentsListScreen`
3. `ResidentDetailScreen`
4. `ResidentFormScreen` (thêm/sửa)
5. `HouseholdsListScreen`
6. `HouseholdDetailScreen`
7. `HouseholdFormScreen`

---

## 6. Luồng dữ liệu (ví dụ)

- User login → nhận token → lưu `flutter_secure_storage`
- Các query/mutation dùng token tự động
- `ResidentsListScreen` gọi `residentsRepository.fetchList()`
- `ResidentFormScreen` gọi mutation tạo/sửa

---

## 7. Kế hoạch triển khai theo giai đoạn

### Giai đoạn 1: Khởi tạo project Flutter
- Tạo thư mục `flutter_app/`
- Khởi tạo Flutter app
- Thêm dependencies
- Tạo cấu trúc thư mục theo kiến trúc đề xuất

### Giai đoạn 2: Auth + GraphQL client
- Viết cấu hình GraphQL client
- Viết Auth flow, lưu token

### Giai đoạn 3: Residents module
- List residents
- Detail residents
- Create/Update/Delete residents

### Giai đoạn 4: Households module
- List households
- Detail households
- Create/Update households
- Manage household members

### Giai đoạn 5: UX và tối ưu
- Search & filter
- Form validation
- Empty state + loading
- Error handling thống nhất

---

## 8. Các yêu cầu kỹ thuật cần xác nhận từ backend

- API login (mutation hoặc REST endpoint)
- Tên cụ thể của queries/mutations trong GraphQL schema
- Field trả về cho danh sách và chi tiết
- Quy tắc ràng buộc (không cho xoá nếu là chủ hộ, v.v.)

---

## 9. Kết quả mong muốn

- Có APK chạy trên Android, kết nối GraphQL Laravel.
- Tương tác CRUD dân cư và hộ dân.
- Giao diện gọn, thao tác nhanh cho cán bộ địa phương.
