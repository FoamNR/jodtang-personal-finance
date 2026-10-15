# 📱 สารบัญขอบเขตฟีเจอร์: แอปพลิเคชัน จดตัง (Jod Tang)

**แอปพลิเคชันบันทึกบัญชีรายรับ-รายจ่าย Offline 100%**  
พัฒนาด้วย Flutter ตามสถาปัตยกรรม **Layered Architecture (MVVM + Repository Pattern)** พร้อมจัดเก็บข้อมูลภายในเครื่องด้วย SQLite และระบบรักษาความปลอดภัย Secure Storage

---

## 🗂️ โครงสร้างเอกสารแยกตามหัวข้อฟีเจอร์ (Feature Topics)

| ลำดับ | หัวข้อฟีเจอร์ | รายละเอียดสังเขป | ลิงก์เอกสาร |
| :---: | :--- | :--- | :---: |
| **01** | **ระบบบันทึกธุรกรรม**<br>*(Transaction Management)* | บันทึกรายรับ รายจ่าย โอนเงินพร้อมระบบ Balance Validation ป้องกันเงินติดลบ แนบสลิป/ใบเสร็จ ค้นหาและกรอง | [อ่านรายละเอียด ➔](file:///d:/fluttle-project/jod_tang/docs/feature/01_transaction_management/README.md) |
| **02** | **ระบบรายการประจำอัตโนมัติ**<br>*(Recurring Transactions)* | ตั้งบิลรายเดือน/สัปดาห์/ปี ตรวจสอบ `next_due_date` ตอนเปิดแอป บันทึกอัตโนมัติและแจ้งเตือน | [อ่านรายละเอียด ➔](file:///d:/fluttle-project/jod_tang/docs/feature/02_recurring_transactions/README.md) |
| **03** | **ระบบกระเป๋าเงินและหมวดหมู่**<br>*(Wallets & Categories)* | จัดการหลายกระเป๋าเงิน คำนวณยอดเงินคงเหลือ Real-time ปรับแต่งชื่อ สี และไอคอนหมวดหมู่ | [อ่านรายละเอียด ➔](file:///d:/fluttle-project/jod_tang/docs/feature/03_wallets_and_categories/README.md) |
| **04** | **แดชบอร์ดและรายงานสรุปผล**<br>*(Analytics & Reports)* | สรุปยอดรายรับ-รายจ่ายสุทธิ พร้อมโลโก้จดตัง กราฟ Donut Chart เปรียบเทียบสัดส่วนค่าใช้จ่าย | [อ่านรายละเอียด ➔](file:///d:/fluttle-project/jod_tang/docs/feature/04_analytics_and_reports/README.md) |
| **05** | **ระบบความปลอดภัยและล็อกแอป**<br>*(Security & App Lock)* | ล็อกแอปด้วยรหัส PIN 4 หลัก แป้นพิมพ์ตอบสนองไว ปลอดภัยด้วย SHA-256 ล็อกอัตโนมัติเมื่อสลับแอป | [อ่านรายละเอียด ➔](file:///d:/fluttle-project/jod_tang/docs/feature/05_security_and_app_lock/README.md) |
| **06** | **ระบบส่งออกและสำรองข้อมูล**<br>*(Backup & Export)* | ส่งออกไฟล์ CSV รองรับภาษาไทย (UTF-8 BOM) สำรองและกู้คืนไฟล์ .ZIP ก้อนเดียวรวม .db + รูปสลิป | [อ่านรายละเอียด ➔](file:///d:/fluttle-project/jod_tang/docs/feature/06_backup_and_export/README.md) |

---

## 🛠️ โครงสร้างสถาปัตยกรรมระบบที่ใช้งานจริง (Architecture Mapping)

```text
lib/
├── data/
│   ├── models/                # โครงสร้างฐานข้อมูล SQLite
│   ├── repositories/          # WalletRepository, CategoryRepository, TransactionRepository, RecurringRepository
│   └── services/              # DatabaseService, ReceiptStorageService, SecurityService, BackupExportService, NotificationService
├── domain/
│   └── models/                # Domain Entities (TransactionItem, Wallet, CategoryItem, RecurringRule, DashboardSummary)
└── ui/
    ├── core/                  # AppColors, AppTheme, ThemeController (Light/Dark Mode), ThaiFormatters, CustomCard, EmptyState, IconHelper
    └── features/
        ├── dashboard/         # หน้าแรก สรุปยอดเงินพร้อมโลโก้จดตัง และทางลัด
        ├── transactions/      # ประวัติรายการ ค้นหา กรอง และฟอร์มบันทึก/โอนเงินแนบสลิป
        ├── wallets/           # จัดการกระเป๋าเงินและยอดตั้งต้น
        ├── categories/        # จัดการหมวดหมู่รายรับ-รายจ่าย
        ├── recurring/         # รายการประจำอัตโนมัติ
        ├── analytics/         # กราฟ Donut และสัดส่วนค่าใช้จ่าย
        ├── security/          # หน้าใส่และตั้งค่า PIN 4 หลัก
        └── settings/          # สลับ Light/Dark Mode, สำรองข้อมูล, ส่งออก CSV, กู้คืน และรีเซ็ตข้อมูล
```
