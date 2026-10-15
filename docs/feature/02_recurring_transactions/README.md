# 02. ระบบรายการประจำอัตโนมัติ (Recurring Transactions)

## 📌 ภาพรวมฟีเจอร์
ระบบสำหรับสร้างแม่แบบรายการที่เกิดขึ้นเป็นประจำ (เช่น เงินเดือน, ค่าเช่าหอพัก, ค่าอินเทอร์เน็ต, ค่าสตรีมมิง) เพื่อให้ระบบสร้างรายการธุรกรรมให้อัตโนมัติเมื่อถึงกำหนดเวลา

---

## 🚀 ฟังก์ชันการทำงานหลัก
1. **การสร้างและกำหนดรอบความถี่:**
   - **รายวัน (Daily):** เกิดซ้ำทุกๆ 1 วัน
   - **รายสัปดาห์ (Weekly):** เกิดซ้ำทุกๆ 7 วัน
   - **รายเดือน (Monthly):** เกิดซ้ำทุกๆ 1 เดือนในวันเดียวกัน
   - **รายปี (Yearly):** เกิดซ้ำทุกๆ 1 ปี
   - กำหนดวันเริ่มต้น (`startDate`) และเลือกกำหนดวันสิ้นสุด (`endDate`) ได้ หรือทำซ้ำต่อเนื่องตลอดไป
2. **การทำงานอัตโนมัติ (Auto-Execution on Launch):**
   - ทุกครั้งที่เปิดแอปพลิเคชันขึ้นมา ระบบจะดึงรายการที่ `isActive = 1` และ `next_due_date <= วันที่ปัจจุบัน`
   - ระบบจะสร้าง `TransactionItem` ลงในตาราง `transactions` โดยอัตโนมัติ
   - คำนวณวันกำหนดถัดไป (`next_due_date`) และอัปเดตลงตาราง `recurring_rules`
   - หากเกินกำหนด `endDate` ระบบจะเปลี่ยนสถานะเป็น `isActive = 0` ให้อัตโนมัติ
3. **การแจ้งเตือน (Local Notification):**
   - เมื่อระบบสร้างรายการอัตโนมัติ จะส่งข้อความแจ้งเตือนผ่าน `NotificationService`
   - ผู้ใช้สามารถกดปุ่ม "ซิงค์รายการทันที" เพื่อตรวจสอบและบันทึกรายการที่ครบกำหนดได้โดยไม่ต้องรอเปิดแอปใหม่

---

## 🗄️ โครงสร้างข้อมูลในฐานข้อมูล (SQLite Schema)

```sql
CREATE TABLE recurring_rules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                 -- ชื่อรายการ (เช่น ค่าเน็ตรายเดือน)
  type TEXT NOT NULL,                 -- 'expense' | 'income' | 'transfer'
  amount REAL NOT NULL,               -- จำนวนเงิน
  wallet_id INTEGER NOT NULL,         -- กระเป๋าเงินต้นทาง
  to_wallet_id INTEGER,               -- กระเป๋าเงินปลายทาง
  category_id INTEGER,                -- หมวดหมู่
  frequency TEXT NOT NULL,            -- 'daily' | 'weekly' | 'monthly' | 'yearly'
  start_date TEXT NOT NULL,           -- วันที่เริ่มรอบแรก
  end_date TEXT,                      -- วันสิ้นสุด (ถ้ามี)
  next_due_date TEXT NOT NULL,        -- วันครบกำหนดรอบถัดไป
  is_active INTEGER NOT NULL DEFAULT 1,
  note TEXT,
  FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE,
  FOREIGN KEY (to_wallet_id) REFERENCES wallets (id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
);
```

---

## 📂 ไฟล์โค้ดที่เกี่ยวข้อง
- **Domain Model:** [`RecurringRule`](file:///d:/fluttle-project/jod_tang/lib/domain/models/recurring_rule.dart)
- **Data Repository:** [`RecurringRepository`](file:///d:/fluttle-project/jod_tang/lib/data/repositories/recurring_repository.dart)
- **Notification Service:** [`NotificationService`](file:///d:/fluttle-project/jod_tang/lib/data/services/notification_service.dart)
- **ViewModel:** [`RecurringViewModel`](file:///d:/fluttle-project/jod_tang/lib/ui/features/recurring/view_models/recurring_view_model.dart)
- **UI Views:**
  - [`RecurringListView`](file:///d:/fluttle-project/jod_tang/lib/ui/features/recurring/views/recurring_list_view.dart)
  - [`AddEditRecurringView`](file:///d:/fluttle-project/jod_tang/lib/ui/features/recurring/views/add_edit_recurring_view.dart)
