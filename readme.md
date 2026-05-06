# [Bài tập tổng hợp] Xây dựng Module "Siêu Công Cụ Soi Đơn" cho Admin

---

## 1. Bản vẽ Logic (Mổ xẻ Bẫy)

### Vấn đề

Điều kiện lọc gồm:

- (1) `total_amount` trong khoảng [2.000.000 → 5.000.000]
- (2) `status != 'CANCELLED'`
- (3) `(note LIKE '%gấp%' OR user_id IS NULL)`

Sai lầm phổ biến:

```sql
WHERE total_amount BETWEEN ...
AND status != 'CANCELLED'
AND note LIKE '%gấp%'
OR user_id IS NULL
```

### Vì sao sai?

Do thứ tự ưu tiên toán tử:

- `AND` được xử lý trước `OR`

Câu trên thực chất bị hiểu thành:

```sql
(
    total_amount BETWEEN ...
    AND status != 'CANCELLED'
    AND note LIKE '%gấp%'
)
OR user_id IS NULL
```

→ Hậu quả:

- Mọi đơn có `user_id IS NULL` đều được lấy
- Kể cả:
  - đơn `CANCELLED`
  - đơn > 5.000.000

---

### Kỹ thuật khóa bẫy

Dùng dấu ngoặc `()` để group logic:

```sql
AND (
    note LIKE '%gấp%'
    OR user_id IS NULL
)
```

→ đảm bảo:

- Điều kiện (3) chỉ áp dụng sau khi (1) và (2) đã đúng

---

## 2. Quy trình chống bẫy đầu vào (Pagination)

### Công thức OFFSET

- Mỗi trang: `limit = 20`
- Trang thứ `page`

```text
OFFSET = (page - 1) * limit
```

Trang 3:

```text
OFFSET = (3 - 1) * 20 = 40
```

---

### Chặn dữ liệu lỗi từ Client

#### Vấn đề

- `page = 0`
- `page = -5`

→ gây sai logic phân trang

---

#### Cách xử lý Backend

```js
let pageNumber = parseInt(page, 10);

if (Number.isNaN(pageNumber) || pageNumber < 1) {
  pageNumber = 1;
}

const limit = 20;
const offset = (pageNumber - 1) * limit;
```

→ đảm bảo:

- Không âm
- Không lệch trang
- Không query sai dữ liệu

---

## 3. Mã nguồn Database: [SQL](query.sql)

---

## 4. Tổng kết

- Bẫy lớn nhất nằm ở `OR` phá vỡ logic filter
- Luôn dùng `()` để group điều kiện phức tạp
- Validate input (page) ở Backend trước khi query
- Kết hợp:
  - `CASE WHEN` → tạo cột ảo
  - `ORDER BY` → ưu tiên dữ liệu quan trọng
  - `LIMIT + OFFSET` → phân trang chuẩn

---
