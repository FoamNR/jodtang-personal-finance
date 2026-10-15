# 💰 จดตัง (Jod Tang) - Personal Finance & Expense Tracker

<div align="center">

**แอปพลิเคชันบันทึกรายรับ-รายจ่ายส่วนบุคคล ออฟไลน์ 100% ปลอดภัย ใช้งานง่าย และดีไซน์ระดับพรีเมียม**

[![Flutter](https://img.shields.io/badge/Flutter-3.13+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-Offline_First-003B57?logo=sqlite&logoColor=white)](https://sqlite.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

---

## 📱 จุดเด่นของแอปพลิเคชัน (Key Features)

### 1. 💵 การจัดการธุรกรรมที่แม่นยำ (Transaction Management)
- **บันทึก 3 รูปแบบ:** รายจ่าย (Expense), รายรับ (Income) และโอนย้ายเงิน (Transfer)
- **ระบบตรวจสอบยอดเงินโอน (Transfer Balance Validation):** ตรวจสอบยอดเงินคงเหลือในกระเป๋าต้นทางแบบเรียลไทม์ ป้องกันการโอนเกินยอดที่มี ป้องกันเงินติดลบ และคำนวณยอดเงินอย่างถูกต้องเมื่อแก้ไขรายการเดิม
- **แนบรูปสลิป / ใบเสร็จ:** ถ่ายภาพหรือเลือกรูปจากแกลเลอรี พร้อมระบบบีบอัดรูปภาพและดูรูปเต็มจอ (InteractiveViewer)
- **ค้นหาและกรองข้อมูล:** ค้นหา Note แบบ Real-time กรองตามประเภท กระเป๋าเงิน หมวดหมู่ และช่วงเวลา

### 2. 🔁 รายการประจำอัตโนมัติ (Recurring Transactions)
- ตั้งค่าบิลหรือรายรับที่เกิดขึ้นซ้ำ เช่น เงินเดือน ค่าเช่าห้อง ค่าเน็ต
- รองรับรอบความถี่: รายวัน, รายสัปดาห์, รายเดือน, รายปี
- ระบบประมวลผลอัตโนมัติเมื่อถึงกำหนดพร้อมระบบแจ้งเตือน (Local Notification)

### 3. 💳 จัดการหลายกระเป๋าเงินและหมวดหมู่ (Multi-Wallets & Categories)
- สร้างกระเป๋าแยกประเภทได้ไม่จำกัด (เงินสด, บัญชีธนาคาร, บัตรเครดิต)
- กำหนดยอดเงินตั้งต้น สี และไอคอนประจำกระเป๋า
- หมวดหมู่พร้อมใช้และเพิ่มหมวดหมู่ของตนเองได้

### 4. 📊 แดชบอร์ดและรายงานสรุปผล (Analytics & Reports)
- สรุปยอดเงินรวม รายรับ รายจ่าย ประจำเดือนแบบ Real-time
- กราฟวงแหวน (Donut Chart) เปรียบเทียบสัดส่วนค่าใช้จ่ายแยกตามหมวดหมู่

### 5. 🔒 ระบบความปลอดภัย (Security & PIN Lock)
- ล็อกแอปด้วยรหัส PIN 4 หลัก เข้ารหัสแฮชแบบ SHA-256 จัดเก็บใน Hardware-backed Keystore (`flutter_secure_storage`)
- แป้นพิมพ์ตัวเลขสัมผัสไว (`_KeypadCell`) ตอบสนองทันที
- ล็อกอัตโนมัติเมื่อพับจอหรือสลับแอป (Lifecycle Auto-Lock)

### 6. 💾 สำรองข้อมูลและส่งออก (Backup, Restore & Export)
- ส่งออกประวัติเป็นไฟล์ CSV รองรับภาษาไทย (UTF-8 BOM) เปิดบน Excel / Sheets ได้ทันที
- สำรองข้อมูลเต็มรูปแบบเป็นไฟล์ `.zip` ก้อนเดียว (รวมฐานข้อมูล `.db` + รูปสลิปทั้งหมด) ย้ายเครื่องได้รูปไม่หาย
- กู้คืนข้อมูล (Restore) และล้างข้อมูล (Reset) ในคลิกเดียว

### 7. 🎨 ปรับแต่งธีมและประสิทธิภาพ (Theme & Performance)
- รองรับโหมดสว่าง (Light Mode) และโหมดมืด (Dark Mode)
- ออกแบบตามหลัก Modern Clean UI ลื่นไหล 60 FPS ปิดการประมวลผล Blur ซ้อนทับ ลดการใช้พลังงาน

---

## 🏗️ สถาปัตยกรรมระบบ (Architecture)

โปรเจกต์พัฒนาด้วยโครงสร้าง **Layered Architecture (MVVM + Repository Pattern)** เพื่อความสะอาด ดูแลรักษาง่าย และแยกความรับผิดชอบอย่างชัดเจน:

```text
lib/
├── data/
│   ├── models/                # ตารางและ Schema ของ SQLite
│   ├── repositories/          # Wallet, Category, Transaction, Recurring Repository
│   └── services/              # Database, Receipt, Security, Backup, Notification Service
├── domain/
│   └── models/                # Domain Entities (Immutable Models)
└── ui/
    ├── core/                  # Theme, Colors, Formatters, Reusable Components
    └── features/              # Feature Modules (Dashboard, Transactions, Wallets, etc.)
```

---

## 🚀 เริ่มต้นใช้งาน (Getting Started)

### ความต้องการของระบบ (Prerequisites)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.13.0 ขึ้นไป
- Dart SDK 3.0.0 ขึ้นไป

### ขั้นตอนการรันโปรเจกต์
```bash
# 1. Clone repository
git clone https://github.com/FoamNR/jodtang-personal-finance.git

# 2. เข้าสู่โฟลเดอร์โปรเจกต์
cd jodtang-personal-finance

# 3. ติดตั้ง Dependencies
flutter pub get

# 4. ทดสอบความถูกต้อง (Run Tests)
flutter test

# 5. รันแอปพลิเคชัน
flutter run
```

---

## 📚 เอกสารประกอบ (Documentation)
ดูรายละเอียดเอกสารแต่ละฟีเจอร์เพิ่มเติมได้ที่โฟลเดอร์ [`docs/`](docs/):
- [สารบัญขอบเขตฟีเจอร์](docs/feature/README.md)
- [ระบบบันทึกธุรกรรม](docs/feature/01_transaction_management/README.md)
- [ระบบความปลอดภัยและรหัส PIN](docs/feature/05_security_and_app_lock/README.md)
