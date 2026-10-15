# 💰 Jod Tang (จดตัง)

A clean, 100% offline personal finance and expense tracker built with Flutter and SQLite. Designed for privacy, speed, and simplicity.

---

## ✨ Features

- **🔒 100% Offline & Private:** All data is stored locally in SQLite on your device. No cloud sync, no tracking.
- **💸 Transaction Tracking:** Record Income, Expense, and Transfers with real-time balance validation to prevent overdrafts.
- **🧾 Receipt & Slip Attachment:** Attach receipt photos, compress them locally, and preview in full-screen.
- **💳 Multi-Wallet Management:** Manage Cash, Bank Accounts, and Credit Cards with real-time balance calculations.
- **🔁 Recurring Transactions:** Automate recurring bills and subscriptions with local scheduled notifications.
- **📊 Spending Analytics:** Interactive Donut charts and category breakdown for monthly insights.
- **🔐 PIN Protection:** Secure 4-digit PIN lock backed by hardware-level encryption (SHA-256 + Secure Storage).
- **📦 Backup & Export:**
  - Export transactions to CSV (UTF-8 BOM, compatible with Excel).
  - 1-Click Full Backup & Restore via `.zip` (database + receipt photos).
- **🌗 Dark Mode:** Seamless toggle between Light and Dark themes.

---

## 🛠️ Tech Stack

- **Framework:** [Flutter](https://flutter.dev) (Dart 3)
- **Database:** SQLite (`sqflite`)
- **State & Architecture:** MVVM + Repository Pattern
- **Storage & Security:** `flutter_secure_storage`, `shared_preferences`

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/FoamNR/jodtang-personal-finance.git

# 2. Install dependencies
flutter pub get

# 3. Run tests
flutter test

# 4. Launch the app
flutter run
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
