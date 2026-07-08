# 🛒 Toko App

A **Flutter-based Point of Sale (POS)** application designed for small shops and *warung*. The app helps store owners manage products, process sales, record customer debts, and monitor daily business performance—all with **offline local storage using SQLite**.

---

## ✨ Features

### 🛍️ Cashier

* Browse available products
* Search products instantly
* Category filtering
* Shopping cart with quantity management
* Cash and QRIS payment support
* Automatic stock validation before checkout

### 📦 Product Management

* Add, edit, and delete products
* Restock inventory
* Product image support
* Configure QRIS payment image
* Category and unit management

### 📊 Sales Summary

* Today's revenue
* Profit calculation
* Transaction count
* Low-stock product monitoring

### 💳 Debt Management

* Record customer debts
* Mark debts as paid or unpaid
* Delete debt records

---

# 📱 Screens

| Feature  | Description                                   |
| -------- | --------------------------------------------- |
| Cashier  | Process sales using a shopping cart interface |
| Products | Manage inventory and product information      |
| Summary  | View daily sales statistics and profits       |
| Debts    | Track customer debts and payment status       |

---

# 🏗️ Tech Stack

* **Flutter**
* **Provider** (State Management)
* **SQLite (sqflite)**
* **Path Provider**
* **Image Picker**

---

# 📂 Project Structure

```text
lib/
│
├── database/
│   └── database_helper.dart
│
├── models/
│   ├── product.dart
│   ├── cart_item.dart
│   └── debt.dart
│
├── providers/
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   └── debt_provider.dart
│
├── screens/
│   ├── cashier/
│   ├── products/
│   ├── summary/
│   └── debts/
│
└── main.dart
```

---

# ⚙️ Architecture

The application follows a simple layered architecture:

```
UI (Screens)
      │
      ▼
Providers (Business Logic)
      │
      ▼
SQLite Database
      │
      ▼
Local Device Storage
```

### State Management

The application uses **Provider** for state management.

| Provider        | Responsibility                               |
| --------------- | -------------------------------------------- |
| ProductProvider | Product CRUD, stock updates, checkout, sales |
| CartProvider    | Shopping cart management                     |
| DebtProvider    | Customer debt management                     |

---

# 🗄️ Database

SQLite is used for persistent local storage.

### Tables

* `products`
* `transactions`
* `transaction_items`
* `debts`

The database stores products, transaction history, and customer debt records even after the application is closed.

---

# 📦 Dependencies

| Package         | Purpose                        |
| --------------- | ------------------------------ |
| provider        | State management               |
| sqflite         | Local SQLite database          |
| path            | File path utilities            |
| path_provider   | Access application directories |
| image_picker    | Select product and QRIS images |
| cupertino_icons | iOS icons                      |

---

# 🚀 Getting Started

## Prerequisites

* Flutter SDK installed
* Android Studio or VS Code
* Android Emulator or physical device

## Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/toko-app.git
```

Navigate to the project:

```bash
cd toko-app
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# 📌 Notes

* Works completely **offline**
* Uses **SQLite** for local data persistence
* Product and QRIS images are stored inside the application's document directory
* Stock is automatically validated before completing a checkout
* Daily sales summaries are generated directly from transaction records

---

# 🚧 Future Improvements

* Receipt printing
* Export sales reports (PDF/Excel)
* Sales history page
* Barcode/QR code scanning
* Multi-user authentication
* Cloud synchronization
* Backup & restore database
* Dark mode

---

# 📄 License

This project is intended for educational and portfolio purposes.
