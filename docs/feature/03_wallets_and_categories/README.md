# 03. ระบบกระเป๋าเงินและหมวดหมู่ (Wallets & Categories)

## 📌 ภาพรวมฟีเจอร์
ระบบจัดการกระเป๋าเงินหลายบัญชี (Multi-Wallets) พร้อมคำนวณยอดคงเหลือสุทธิ และระบบจัดการหมวดหมู่รายรับ-รายจ่ายที่ยืดหยุ่น

---

## 🚀 ฟังก์ชันการทำงานหลัก

### 1. กระเป๋าเงิน (Wallets)
- **สร้างได้หลายกระเป๋า:** เช่น เงินสด, บัญชีธนาคาร, TrueMoney Wallet, บัตรเครดิต
- **กำหนดยอดตั้งต้น (Initial Balance):** แต่ละกระเป๋าสามารถระบุยอดเงินที่มีอยู่ก่อนเริ่มจดบันทึกได้
- **คำนวณยอดคงเหลือ Real-time:**
  $$\text{Current Balance} = \text{Initial Balance} + \sum \text{Income} - \sum \text{Expense} + \sum \text{Transfer In} - \sum \text{Transfer Out}$$
- **ปรับแต่งสีและไอคอน:** มีชุดสีพาเลตต์และชุดไอคอนให้เลือก เพื่อให้จดจำกระเป๋าเงินได้ง่าย

### 2. หมวดหมู่ (Categories)
- **ข้อมูลเริ่มต้น (Seed Data):** มาพร้อมหมวดหมู่รายจ่าย 8 หมวดหมู่ และรายรับ 5 หมวดหมู่ที่ครอบคลุมชีวิตประจำวัน
- **สร้างและแก้ไขหมวดหมู่เองได้ (Custom Categories):** เพิ่มชื่อ เลือกสี และเลือกไอคอนตามความต้องการของผู้ใช้
- **การป้องกันข้อมูล:** หมวดหมู่เริ่มต้นจะไม่สามารถกดลบได้ เพื่อรักษาความสมบูรณ์ของระบบ แต่สามารถสร้างหมวดหมู่ใหม่เพิ่มได้อย่างอิสระ

---

## 🗄️ โครงสร้างข้อมูลในฐานข้อมูล (SQLite Schema)

```sql
-- 1. ตารางกระเป๋าเงิน
CREATE TABLE wallets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  initial_balance REAL NOT NULL DEFAULT 0.0,
  color_value INTEGER NOT NULL,
  icon_code_point INTEGER NOT NULL,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL
);

-- 2. ตารางหมวดหมู่
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  type TEXT NOT NULL,                -- 'expense' | 'income'
  color_value INTEGER NOT NULL,
  icon_code_point INTEGER NOT NULL,
  is_default INTEGER NOT NULL DEFAULT 0
);
```

---

## 📂 ไฟล์โค้ดที่เกี่ยวข้อง
- **Domain Models:**
  - [`Wallet`](file:///d:/fluttle-project/jod_tang/lib/domain/models/wallet.dart)
  - [`CategoryItem`](file:///d:/fluttle-project/jod_tang/lib/domain/models/category_item.dart)
- **Repositories:**
  - [`WalletRepository`](file:///d:/fluttle-project/jod_tang/lib/data/repositories/wallet_repository.dart)
  - [`CategoryRepository`](file:///d:/fluttle-project/jod_tang/lib/data/repositories/category_repository.dart)
- **ViewModels & Views:**
  - [`WalletViewModel`](file:///d:/fluttle-project/jod_tang/lib/ui/features/wallets/view_models/wallet_view_model.dart)
  - [`WalletListView`](file:///d:/fluttle-project/jod_tang/lib/ui/features/wallets/views/wallet_list_view.dart)
  - [`AddEditWalletDialog`](file:///d:/fluttle-project/jod_tang/lib/ui/features/wallets/views/add_edit_wallet_dialog.dart)
  - [`CategoryViewModel`](file:///d:/fluttle-project/jod_tang/lib/ui/features/categories/view_models/category_view_model.dart)
  - [`CategoryListView`](file:///d:/fluttle-project/jod_tang/lib/ui/features/categories/views/category_list_view.dart)
  - [`AddEditCategoryDialog`](file:///d:/fluttle-project/jod_tang/lib/ui/features/categories/views/add_edit_category_dialog.dart)
