# 07. แอนิเมชันเปิดแอปและระบบธีม (Animated Splash & Theme System)

## 📌 ภาพรวมฟีเจอร์
ระบบแอนิเมชันเปิดแอปแบบ Liquid Glass Splash Screen และระบบการจัดการธีม (Light / Dark Mode) ที่ผ่านการปรับแต่งคอนทราสต์ของสีตัวอักษรและพื้นหลังให้อ่านง่าย สบายตา คมชัดทุกหน้าจอ

---

## 🚀 ฟังก์ชันการทำงานหลัก

### 1. แอนิเมชันเปิดแอป (Liquid Glass Animated Splash Screen)
- **Staggered Elastic Entrance:**
  - โลโก้ Liquid Glass เด้งขึ้นมาอย่างนุ่มนวลด้วย Elastic Curve (`Curves.easeOutBack`)
  - โลโก้มีแสงเงาและประกายทองประกายดาว (`auto_awesome_rounded`)
  - ตัวอักษรชื่อแอป **"จดตัง"** และ **"J O D  T A N G"** เลื่อนขึ้นมาพร้อมแอนิเมชันเฟดเข้า
- **Concentric Fluid Ripples & Glow:**
  - คลื่นวงแหวนโปร่งแสงขยายตัวแผ่ออกจากโลโก้เป็นจังหวะหายใจ (Breathing Aura) ตลอดช่วงโหลดข้อมูล
- **Shimmering Liquid Progress Bar:**
  - แถบแคปซูลแสดงเปอร์เซ็นต์โหลด (0% – 100%) พร้อมแสงประกาย Shimmer พาดผ่านแถบ
  - ข้อความสถานะภาษาไทยเปลี่ยนตามขั้นตอนการโหลด:
    - `กำลังเริ่มต้นระบบ...` (0% - 28%)
    - `กำลังเตรียมข้อมูลกระเป๋าเงิน...` (28% - 65%)
    - `ตรวจสอบความปลอดภัย...` (65% - 92%)
    - `พร้อมใช้งานแล้ว!` (92% - 100%)
- **Smooth Outro & Haptic Feedback:**
  - มีการสั่นเตือนเบา ๆ (`HapticFeedback.lightImpact()`) เมื่อโหลดเสร็จ 100%
  - Transition สลับหน้าจออย่างนุ่มนวลผ่าน `AnimatedSwitcher` ส่งต่อไปยังหน้า **PIN Screen** (กรณีเปิดล็อกแอป) หรือหน้า **Dashboard**
- **Cold Start Only:**
  - เล่นแอนิเมชันเฉพาะตอนเปิดแอปครั้งแรกเท่านั้น ไม่เล่นซ้ำเมื่อสลับแอปไปมา (App Switcher / Backgrounding)

### 2. ระบบธีมและการปรับแต่งคอนทราสต์โหมดมืด (Dark Mode Contrast Optimization)
- **Global Themes:**
  - กำหนดค่า `chipTheme` และ `dialogTheme` ระดับแอปใน `AppTheme.lightTheme` และ `AppTheme.darkTheme`
- **การแก้ปัญหาตัวหนังสือกลืนกับพื้นหลัง:**
  - **ChoiceChips:** ปรับชิปหมวดหมู่ที่ยังไม่ได้เลือกให้มีตัวอักษรสีสว่าง (`textPrimaryDark` / `#F8FAFC`) และพื้นหลังกระจกโปร่งแสง ไม่จมหายไปกับพื้นหลังสีเข้ม
  - **ประเภทธุรกรรม (Transaction Type Tabs):** แท็บที่ยังไม่เลือกปรับสีตัวอักษรให้สว่างคมชัดใน Dark Mode
  - **รายการกระเป๋าเงิน (Wallet List):** ยอดเงินคงเหลือที่เป็นบวกแสดงสีสว่างชัดเจน ไม่กลืนเป็นสีดำ
  - **Dialogs:** ขอบวงกลมสีที่เลือกเปลี่ยนเป็นสีขาวใน Dark Mode และไอคอนในตารางปรับความสว่างให้อ่านง่าย
  - **Section Headers & Subtitles:** หัวข้อหมวดหมู่ในหน้าตั้งค่า, สัดส่วนเปอร์เซ็นต์ในหน้ารายงาน, วันที่ และ Note ในรายการธุรกรรม ปรับใช้ `textSecondaryDark` (`#94A3B8`) เพื่อการมองเห็นที่ชัดเจน

---

## 📂 ไฟล์โค้ดที่เกี่ยวข้อง
- **Splash Screen:** `lib/ui/features/splash/views/splash_screen.dart`
- **Theme Definitions:** `lib/ui/core/app_theme.dart`
- **Theme Controller:** `lib/ui/core/theme_controller.dart`
- **Color Palette:** `lib/ui/core/app_colors.dart`
- **Unit Tests:** `test/splash_screen_test.dart`
