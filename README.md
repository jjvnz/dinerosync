# 💸 Dinerosync

**Dinerosync** is a modern and elegant personal finance mobile app built with **Flutter**. It's designed to help users record, visualize, and manage their income and expenses intuitively and enjoyably.

It combines simplicity, a polished design, and a robust architecture to make financial tracking a frictionless experience.

---

## ✨ Key Features

| Category | Description |
| :--- | :--- |
| 💰 **Full Transaction Management** | Create, edit, and delete transactions with an intuitive form, swipe-to-action gestures, and a custom numeric keypad. |
| 📊 **Interactive Visual Analytics** | Explore your finances with dynamic Syncfusion charts, category summaries, and cash flow analysis. |
| 🧠 **Smart Insights** | Receive personalized financial advice based on your spending patterns, month-over-month comparisons, and more. |
| 🎨 **High-Quality UI/UX** | Enjoy a cohesive and beautiful user experience with smooth animations, haptic feedback, and an adaptive design. |
| 💾 **Full Offline Support** | Your data is stored locally and securely with Hive, so the app works perfectly without an internet connection. |
| 🌓 **Adaptive Themes** | Enjoy light and dark modes that automatically adjust to your system for comfort. |
| 🔄 **Real-Time Updates** | State management with Provider ensures the UI updates instantly with every change. |

---

## 🧰 Tech Stack

| Technology | Purpose |
| :--- | :--- |
| 🐦 [**Flutter**](https://flutter.dev/) | Cross-platform UI framework. |
| 📦 [**Hive**](https://github.com/hivedb/hive) | Lightweight and fast NoSQL local database. |
| 🔗 [**Provider**](https://pub.dev/packages/provider) | Reactive and centralized state management. |
| 📈 [**Syncfusion Charts**](https://www.syncfusion.com/flutter-widgets/charts) | Library for interactive charts and data visualization. |
| 🌍 [**intl**](https://pub.dev/packages/intl) | Date and currency formatting. |
| 🎨 [**Local Fonts (Inter)**](https://fonts.google.com/specimen/Inter) | Bundled typography for instant performance and visual consistency. |
| 🧩 [**uuid**](https://pub.dev/packages/uuid) | Unique identifier generation. |

---

## 🏗️ Project Structure

```
dinerosync/
├── lib/
│   ├── models/           # Data models (Transaction, Category, etc.)
│   │   ├── transaction.dart
│   │   └── category.dart
│   ├── providers/        # Business logic and state (FinanceProvider)
│   │   └── finance_provider.dart
│   ├── screens/          # Main application screens
│   │   ├── dashboard_screen.dart
│   │   ├── transactions_screen.dart
│   │   ├── summary_screen.dart
│   │   └── profile_screen.dart
│   ├── widgets/          # Reusable UI components
│   │   ├── transaction_form.dart
│   │   ├── category_selector.dart
│   │   ├── new_transaction_item.dart
│   │   └── custom_date_range_picker.dart
│   ├── utils/            # Utilities (number formatting, etc.)
│   │   └── number_formatter.dart
│   └── main.dart         # App entry point
├── assets/
│   └── fonts/            # Local font files
└── pubspec.yaml
```

---

## 🎨 UI & Architecture Highlights

### 📱 Main Screens

*   **Dashboard:** A dynamic command center with your balance, daily changes, and "Smart Insights."
*   **Transactions:** A complete list grouped by day, with gestures for quick editing or deletion.
*   **Summary:** Visualize your data with pie and line charts, filtered by custom time periods.
*   **Transaction Form:** A redesigned data entry experience with a hero amount display, animated type selector, and integrated keypad.

### ⚙️ Architectural Strengths

*   **Robust Navigation Model:** Uses a `_NavigationItem` model to eliminate indexing errors and make navigation scalable and maintainable.
*   **Centralized State:** The `FinanceProvider` contains all business logic (CRUD, filtering, calculations), keeping the UI clean and reactive.
*   **Reusable Components:** The UI is built on highly reusable widgets like `CategorySelector` and `NewTransactionItem`, promoting consistency and code efficiency.

---

## 🚀 Getting Started

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/jjvnz/dinerosync.git
cd dinerosync
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Run the App

```bash
flutter run
```

> 💡 Make sure you have Flutter installed and set up on your system.
> [Get Flutter](https://flutter.dev/docs/get-started/install)

---

## 📈 Future Enhancements

* 🔐 **Authentication & Cloud Sync:** Allow users to save and sync their data across multiple devices.
* 🌐 **Multi-language Support:** Extend the app to support different languages.
* 💳 **Budgeting & Goal Tracking:** Allow users to set budgets and savings goals.
* ☁️ **Firebase Integration:** For a complete backend-as-a-service solution.

---

## 🧑‍💻 Contributing

Contributions are welcome!

1.  Fork the repository.
2.  Create a feature branch: `git checkout -b feature/your-feature`.
3.  Commit your changes: `git commit -m "Add your feature"`.
4.  Push to the branch: `git push origin feature/your-feature`.
5.  Open a Pull Request 🎉

---

## 📝 License

This project is licensed under the **MIT License**.
See the [LICENSE](LICENSE) file for more details.

---

### ❤️ Built with Flutter by [@jjvnz](https://github.com/jjvnz)