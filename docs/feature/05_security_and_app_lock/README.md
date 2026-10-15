# 05. ระบบความปลอดภัยและล็อกแอป (Security & App Lock)

## 📌 ภาพรวมฟีเจอร์
ระบบรักษาความปลอดภัยและการยืนยันตัวตนด้วยรหัส PIN 4 หลัก เพื่อป้องกันไม่ให้ผู้อื่นเข้าถึงข้อมูลบัญชีส่วนตัวเมื่อเปิดแอปหรือสลับแอป

---

## 🚀 ฟังก์ชันการทำงานหลัก
1. **การตั้งและยืนยันรหัส PIN 4 หลัก:**
   - ผู้ใช้สามารถเปิดใช้งานระบบล็อกด้วย PIN 4 หลักได้จากหน้าการตั้งค่า
   - มีหน้าจอยืนยันรหัส PIN 2 รอบเมื่อตั้งค่าครั้งแรก
   - รหัส PIN จะถูกนำไปเข้ารหัสแฮชด้วยอัลกอริทึม **SHA-256** ก่อนบันทึกจัดเก็บใน `flutter_secure_storage` (Hardware-backed Keystore/Keyring) ปลอดภัย 100% โดยไม่มีการเก็บรหัสตัวจริงแบบ Plaintext
   - รองรับการเปลี่ยนรหัส PIN โดยต้องยืนยันรหัสเดิมก่อนเสมอ
   - **แป้นพิมพ์ตัวเลข (Keypad Responsiveness):** ออกแบบปุ่มตัวเลขด้วยคอมโพเนนต์ `_KeypadCell` ที่ใช้ `Material` + `InkResponse` แยกเฉพาะแต่ละปุ่ม ตอบสนองการสัมผัสได้รวดเร็ว แม่นยำ ทันทีทุกครั้งที่กด
2. **ระบบล็อกด้วยรหัส PIN เป็นหลัก (PIN-Focused Security):**
   - ถอดระบบสแกนลายนิ้วมือ/ใบหน้า (Biometrics) ออก เพื่อความเรียบง่าย เสถียร และป้องกันปัญหาข้อผิดพลาดจากการสแกนนิ้วมือไม่ติดในบางอุปกรณ์
3. **การล็อกอัตโนมัติเมื่อพับจอ/สลับแอป (App Lifecycle Auto-Lock):**
   - ตรวจจับสถานะของแอปผ่าน `WidgetsBindingObserver`
   - เมื่อสถานะของแอปเปลี่ยนเป็น `AppLifecycleState.paused` ระบบจะทำการล็อกหน้าจอทันที เพื่อให้เมื่อผู้ใช้สลับกลับมาใช้งาน ต้องใส่รหัส PIN 4 หลักเพื่อปลดล็อกเข้าสู่แอป

---

## 📂 ไฟล์โค้ดที่เกี่ยวข้อง
- **Security Service:** [`SecurityService`](file:///d:/fluttle-project/jod_tang/lib/data/services/security_service.dart)
- **UI Screen:** [`PinScreen`](file:///d:/fluttle-project/jod_tang/lib/ui/features/security/views/pin_screen.dart)
- **App Lifecycle Integration:** [`main.dart`](file:///d:/fluttle-project/jod_tang/lib/main.dart)
