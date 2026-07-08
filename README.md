# 🛒 Toko App

A modern **Flutter Point of Sale (POS)** application built for small shops and *warung*. The application allows shop owners to manage inventory, process sales, monitor profits, and track customer debts completely **offline** using SQLite.

> **Built with Flutter + Provider + SQLite**

---

## 📱 Preview

| Cashier | Shopping Cart |
|---------|---------------|
| ![](screenshots/cashier.png) | ![](screenshots/cart.png) |

| Payment Method | QRIS Payment |
|---------------|--------------|
| ![](screenshots/payment-method.png) | ![](screenshots/qris-payment.png) |

| Products | Dashboard |
|----------|-----------|
| ![](screenshots/products.png) | ![](screenshots/dashboard.png) |

---

# ✨ Features

### 🛒 Cashier

- Browse products
- Product search
- Category filtering
- Shopping cart
- Quantity adjustment
- Stock validation
- Cash payment
- QRIS payment

---

### 📦 Inventory Management

- Add new products
- Edit products
- Delete products
- Restock inventory
- Product image support
- QRIS image configuration

---

### 📊 Sales Dashboard

Track business performance with:

- Today's Revenue
- Today's Profit
- Total Transactions
- Low Stock Monitoring

---

### 💳 Debt Management

- Record customer debts
- Mark debts as paid
- Mark debts as unpaid
- Delete debt records

---

# 🏗️ Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform UI |
| Provider | State Management |
| SQLite | Local Database |
| image_picker | Product Images |
| path_provider | Local Storage |

---

# 📂 Project Structure

```text
lib/
│
├── database/
├── models/
├── providers/
├── screens/
├── widgets/
└── main.dart
```

---

# 🧠 Architecture

```
Flutter UI
      │
      ▼
Provider
(Business Logic)
      │
      ▼
SQLite
(Local Storage)
```

---

# 🗄 Database

The application stores data locally using SQLite.

Tables:

- Products
- Transactions
- Transaction Items
- Debts

No internet connection is required.

---

# 🚀 Getting Started

Clone the repository

```bash
git clone https://github.com/yourusername/toko-app.git
```

Install dependencies

```bash
flutter pub get
```

Run the application

```bash
flutter run
```

---

# 📦 Packages

- provider
- sqflite
- image_picker
- path_provider
- path
- cupertino_icons

---

# 🎯 Highlights

- ✅ Offline First
- ✅ SQLite Database
- ✅ Provider State Management
- ✅ QRIS Payment Support
- ✅ Inventory Management
- ✅ Sales Dashboard
- ✅ Profit Calculation
- ✅ Customer Debt Tracking

---

# 🚧 Future Improvements

- Barcode Scanner
- Receipt Printing
- PDF / Excel Export
- Sales History
- Monthly Reports
- Cloud Backup
- Multi-user Authentication

---

# 📄 License

This project was developed as a portfolio and educational project.
