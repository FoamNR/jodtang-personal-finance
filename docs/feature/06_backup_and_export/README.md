# 06. ระบบส่งออกและสำรองข้อมูล (Backup & Export)

## 📌 ภาพรวมฟีเจอร์
เนื่องจาก "จดตัง" เป็นแอปพลิเคชันแบบ **Offline 100%** ข้อมูลทั้งหมดจึงถูกเก็บไว้ภายในเครื่องของผู้ใช้ ระบบสำรองข้อมูลจึงถูกออกแบบมาให้ปลอดภัย ครบถ้วน และย้ายเครื่องได้ง่ายโดยที่รูปภาพไม่สูญหาย

---

## 🚀 ฟังก์ชันการทำงานหลัก

### 1. ส่งออกเป็นไฟล์ CSV (รองรับ Excel ภาษาไทย 100%)
- ดึงรายการธุรกรรมพร้อมรายละเอียด: วันที่, ประเภท, กระเป๋าเงิน, หมวดหมู่, บันทึกช่วยจำ, สถานะการแนบสลิป
- ใส่ **UTF-8 Byte Order Mark (`\uFEFF`)** ที่หัวไฟล์ ทำให้เมื่อนำไปเปิดใน Microsoft Excel หรือ Numbers บน Windows/Mac ตัวอักษรภาษาไทยจะไม่เป็นภาษาต่างดาว
- แชร์ไฟล์ผ่าน `share_plus` ไปยัง Line, Email, หรือบันทึกลงเครื่อง

### 2. Full Backup เป็นไฟล์ `.zip` (ฐานข้อมูล + รูปสลิป)
- **ปัญหาทางเทคนิคทั่วไป:** หากแบ็กอัปเฉพาะไฟล์ `.db` รูปสลิปที่เก็บแยกในโฟลเดอร์จะไม่ติดไปด้วย และเมื่อย้ายเครื่อง Path รูปจะพัง
- **โซลูชันของแอป จดตัง:**
  - รวบรวมไฟล์ฐานข้อมูล SQLite `jod_tang.db`
  - รวบรวมรูปภาพสลิปทั้งหมดจากโฟลเดอร์ `slips/`
  - บีบอัดเป็นไฟล์ก้อนเดียวในรูปแบบ `.zip` (เช่น `jod_tang_backup_20261014_173000.zip`) ผ่านแพ็กเกจ `archive`
  - แชร์หรืออัปโหลดเก็บไว้บน Google Drive, iCloud, หรือส่งผ่านแอปต่างๆ

### 3. Full Restore จากไฟล์ `.zip`
- เลือกไฟล์ `.zip` สำรองข้อมูลผ่าน `file_picker`
- แตกไฟล์และวางไฟล์ `jod_tang.db` กลับเข้าที่ตำแหน่งฐานข้อมูลหลัก
- แตกไฟล์รูปสลิปทั้งหมดกลับเข้าสู่โฟลเดอร์ `slips/`
- ทำการ Re-open ฐานข้อมูลและรีเฟรชหน้าจอทันที ทำให้ข้อมูลและรูปภาพสลิปทุกใบกลับคืนสู่สภาพเดิมอย่างสมบูรณ์แบบ

### 4. ล้างข้อมูลทั้งหมด (Reset All Data)
- ทำการลบข้อมูลธุรกรรมทั้งหมดใน SQLite และลบไฟล์รูปสลิปทั้งหมดในเครื่อง เพื่อเริ่มต้นใช้งานใหม่เสมือนติดตั้งแอปครั้งแรก
- มี Dialog แจ้งเตือนความปลอดภัยเพื่อป้องกันการกดพลาด

---

## 📂 ไฟล์โค้ดที่เกี่ยวข้อง
- **Service:** [`BackupExportService`](file:///d:/fluttle-project/jod_tang/lib/data/services/backup_export_service.dart)
- **File Storage:** [`ReceiptStorageService`](file:///d:/fluttle-project/jod_tang/lib/data/services/receipt_storage_service.dart)
- **Database:** [`DatabaseService`](file:///d:/fluttle-project/jod_tang/lib/data/services/database_service.dart)
- **ViewModel & View:**
  - [`SettingsViewModel`](file:///d:/fluttle-project/jod_tang/lib/ui/features/settings/view_models/settings_view_model.dart)
  - [`SettingsView`](file:///d:/fluttle-project/jod_tang/lib/ui/features/settings/views/settings_view.dart)
