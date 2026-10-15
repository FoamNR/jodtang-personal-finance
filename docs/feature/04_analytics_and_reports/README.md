# 04. แดชบอร์ดและรายงานสรุปผล (Analytics & Reports)

## 📌 ภาพรวมฟีเจอร์
ระบบประมวลผลทางสถิติและแดชบอร์ดสรุปภาพรวมทางการเงิน ช่วยให้ผู้ใช้เข้าใจพฤติกรรมการใช้จ่ายและวิเคราะห์สัดส่วนเงินออมในแต่ละเดือน

---

## 🚀 ฟังก์ชันการทำงานหลัก
1. **การ์ดสรุปภาพรวม (Overview Cards):**
   - **ยอดเงินคงเหลือรวมทั้งหมด (Total Net Wealth):** คำนวณจากยอดตั้งต้นของทุกกระเป๋า รวมกับรายรับสุทธิตั้งแต่เริ่มใช้งาน
   - **รายรับและรายจ่ายประจำเดือน:** แสดงผลเปรียบเทียบในเดือนที่เลือก พร้อมปุ่มเลื่อนเดือนไปข้างหน้า-ถอยหลัง
   - **เงินออมสุทธิ (Net Savings):** คำนวณจาก `รายรับรวม - รายจ่ายรวม` พร้อมป้ายสถานะ (คงเหลือบวก หรือ ใช้เกินงบ)
2. **กราฟสัดส่วนค่าใช้จ่าย (Donut / Pie Chart):**
   - วาดกราฟ Donut Chart ผ่านแพ็กเกจ `fl_chart`
   - แบ่งสัดส่วนตามหมวดหมู่ค่าใช้จ่าย พร้อมระบุเปอร์เซ็นต์กำกับบนชิ้นกราฟ
   - โค้ดสีประจำหมวดหมู่ตรงกับสีที่ผู้ใช้เลือกในระบบหมวดหมู่
3. **ตารางรายละเอียดค่าใช้จ่าย (Category Breakdown):**
   - เรียงลำดับหมวดหมู่ที่มียอดจ่ายสูงสุดลงมาหาต่ำสุด
   - แสดงหลอดความก้าวหน้า (Linear Progress Bar) และเปอร์เซ็นต์สัดส่วน
   - แสดงยอดเงินรวมในแต่ละหมวดหมู่แบบชัดเจน

---

## 📂 ไฟล์โค้ดที่เกี่ยวข้อง
- **Domain Model:** [`DashboardSummary`](file:///d:/fluttle-project/jod_tang/lib/domain/models/dashboard_summary.dart)
- **ViewModel:**
  - [`DashboardViewModel`](file:///d:/fluttle-project/jod_tang/lib/ui/features/dashboard/view_models/dashboard_view_model.dart)
  - [`AnalyticsViewModel`](file:///d:/fluttle-project/jod_tang/lib/ui/features/analytics/view_models/analytics_view_model.dart)
- **UI Views:**
  - [`DashboardView`](file:///d:/fluttle-project/jod_tang/lib/ui/features/dashboard/views/dashboard_view.dart)
  - [`AnalyticsView`](file:///d:/fluttle-project/jod_tang/lib/ui/features/analytics/views/analytics_view.dart)
