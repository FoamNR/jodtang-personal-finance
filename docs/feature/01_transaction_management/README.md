# 01. ระบบการจดบันทึกธุรกรรม (Transaction Management)

## 📌 ภาพรวมฟีเจอร์
ระบบจัดการรายการธุรกรรมรายรับ รายจ่าย และการโอนเงินระหว่างกระเป๋า พร้อมรองรับการแนบภาพสลิป/ใบเสร็จ การค้นหา และการกรองข้อมูลแบบละเอียด

---

## 🚀 ฟังก์ชันการทำงานหลัก
1. **บันทึกรายการ 3 รูปแบบ:**
   - **รายจ่าย (Expense):** หักลดยอดเงินในกระเป๋าที่เลือก นำไปคำนวณในรายงานรายจ่าย
   - **รายรับ (Income):** เพิ่มยอดเงินในกระเป๋าที่เลือก นำไปคำนวณในรายงานรายรับ
   - **โอนเงิน (Transfer):** ย้ายเงินจากกระเป๋าต้นทางไปยังกระเป๋าปลายทาง โดย**ไม่ถูกนับรวม**เป็นรายรับหรือรายจ่ายของเดือน พร้อมระบบตรวจสอบความถูกต้อง:
     - **การตรวจสอบยอดเงินคงเหลือ (Transfer Balance Validation):** บัญชีต้นทางต้องมียอดเงินเพียงพอ ไม่สามารถโอนเงินเกินยอดคงเหลือได้ เพื่อป้องกันบัญชีติดลบและรักษาความสอดคล้องของข้อมูลการเงิน
     - **การแสดงผลและแจ้งเตือน Real-time:** แสดงข้อความ `โอนได้สูงสุด ฿xx.xx` บนหัวช่องกรอก และแจ้งเตือนข้อความสีแดง `ยอดเงินไม่เพียงพอ (คงเหลือ ฿xx.xx)` ทันทีที่ผู้ใช้พิมพ์จำนวนเงินเกิน (`AutovalidateMode.onUserInteraction`)
     - **รองรับการแก้ไขรายการเดิมอย่างแม่นยำ (`_getAvailableBalance`):** กรณีเปิดแก้ไขรายการโอนเดิม ระบบจะคืนยอดเงินเดิมกลับเข้ากระเป๋าต้นทางก่อนคำนวณ ทำให้ปรับเปลี่ยนจำนวนเงินได้อย่างถูกต้อง ไม่ถูกบล็อกผิดพลาด
     - **ป้องกันการเลือกกระเป๋าซ้ำ:** กระเป๋าต้นทางจะถูกปิดการเลือกใน Dropdown ปลายทาง (`disabled`) พร้อมข้อความระบุชัดเจน และหากผู้ใช้เลือกกระเป๋าซ้ำระบบจะสลับให้อัตโนมัติ
     - **Responsive Dropdown:** กำหนด `isExpanded: true` และ `TextOverflow.ellipsis` ป้องกันปัญหาข้อความชื่อกระเป๋าและยอดคงเหลือล้นจอ (Right overflow)
2. **การแนบรูปสลิป/ใบเสร็จ (Image Attachment):**
   - ถ่ายภาพจากกล้องหรือเลือกภาพจากแกลเลอรี
   - บีบอัดและคัดลอกไฟล์รูปภาพไปเก็บไว้ใน App Documents Directory โฟลเดอร์ `slips/`
   - ในตารางฐานข้อมูล SQLite จะบันทึกเฉพาะ **Relative Path** (`slips/slip_xxxxxxxx.jpg`) เพื่อป้องกันฐานข้อมูล SQLite บวม
   - รองรับการกดดูภาพแบบเต็มหน้าจอ (Full-screen Preview) พร้อมการซูมด้วย `InteractiveViewer`
   - สามารถลบหรือเปลี่ยนภาพสลิปได้ตลอดเวลา
3. **การค้นหาและกรองข้อมูล (Filter & Search):**
   - ค้นหาแบบ Real-time จากข้อความในบันทึกช่วยจำ (Note)
   - กรองตามประเภทธุรกรรม (ทั้งหมด, รายจ่าย, รายรับ, โอนเงิน)
   - กรองตามกระเป๋าเงิน และหมวดหมู่
   - กรองตามช่วงวันที่ (Date Range Picker)
4. **การจัดกลุ่มและการลบรายการ:**
   - แสดงรายการแบบจัดกลุ่มตามวัน (เช่น วันนี้, เมื่อวาน, หรือวันที่ตามปี พ.ศ.)
   - เว้นระยะห่างการ์ดแต่ละรายการอย่างเหมาะสม (10px) ดูสบายตา
   - สรุปยอดรวมรายรับและรายจ่ายประจำวันบนหัวกลุ่ม
   - รองรับการปัดขวา-ซ้ายเพื่อลบรายการ (Swipe-to-delete) พร้อมหน้าต่างยืนยันความปลอดภัย

---

## 🗄️ โครงสร้างข้อมูลในฐานข้อมูล (SQLite Schema)

```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,                -- 'expense' | 'income' | 'transfer'
  amount REAL NOT NULL,              -- จำนวนเงิน (บาท)
  date TEXT NOT NULL,                -- วันที่และเวลา ISO-8601
  wallet_id INTEGER NOT NULL,        -- รหัสกระเป๋าเงิน (ต้นทาง)
  to_wallet_id INTEGER,              -- รหัสกระเป๋าเงิน (ปลายทาง เฉพาะโอนเงิน)
  category_id INTEGER,               -- รหัสหมวดหมู่
  note TEXT,                         -- บันทึกช่วยจำ
  receipt_image_path TEXT,           -- Relative Path ของรูปสลิป
  created_at TEXT NOT NULL,
  FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE,
  FOREIGN KEY (to_wallet_id) REFERENCES wallets (id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
);
```

---

## 📂 ไฟล์โค้ดที่เกี่ยวข้อง
- **Domain Model:** [`TransactionItem`](file:///d:/fluttle-project/jod_tang/lib/domain/models/transaction_item.dart)
- **Data Repository:** [`TransactionRepository`](file:///d:/fluttle-project/jod_tang/lib/data/repositories/transaction_repository.dart)
- **File Service:** [`ReceiptStorageService`](file:///d:/fluttle-project/jod_tang/lib/data/services/receipt_storage_service.dart)
- **ViewModel:** [`TransactionViewModel`](file:///d:/fluttle-project/jod_tang/lib/ui/features/transactions/view_models/transaction_view_model.dart)
- **UI Views:**
  - [`TransactionListView`](file:///d:/fluttle-project/jod_tang/lib/ui/features/transactions/views/transaction_list_view.dart)
  - [`AddEditTransactionView`](file:///d:/fluttle-project/jod_tang/lib/ui/features/transactions/views/add_edit_transaction_view.dart)
  - [`ReceiptViewerDialog`](file:///d:/fluttle-project/jod_tang/lib/ui/features/transactions/views/receipt_viewer_dialog.dart)
- **Unit Tests:**
  - [`transfer_validation_test.dart`](file:///d:/fluttle-project/jod_tang/test/transfer_validation_test.dart) (ทดสอบตรรกะการตรวจสอบยอดเงินโอนและการคำนวณยอดเงินขณะแก้ไขรายการ)
