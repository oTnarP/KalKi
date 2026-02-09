# KalKi (কাল-কি?) 🍱🥘

**KalKi** is an AI-inspired, seasonality-aware meal planning and shopping list application tailored for Bangladeshi households. It simplifies the daily question of _"What to cook tomorrow?"_ by providing smart, localized, and context-aware meal suggestions.

## ✨ Key Features

### 📅 Smart Daily Planning

- **Balanced Meals**: Generates a complete daily plan including **Breakfast**, **Lunch**, **Snacks**, and **Dinner**.
- **Cook Once, Eat Twice**: Intelligent optimization for dishes that are typically cooked once and served for both lunch and dinner.
- **Diversity Engine**: Prevents dish fatigue by ensuring breakfast and snacks are unique and not repetitive.

### ❄️ Seasonality-Aware Engine

- **Seasonal Scoring**: Dishes are weighted based on the current month. In winter, you'll see more cauliflower and radish dishes; in summer, more pointed gourd and cooling curries.
- **Dynamic Weights**: Proprietary algorithm prioritizes seasonal ingredients while maintaining variety.

### 🛒 Market Mode (One-Tap Shopping)

- **Instant List**: Automatically generates a shopping list based on your tomorrow's menu.
- **Quantity Scaling**: Specify guest portions to automatically scale ingredient quantities (e.g., 500g -> 1.5kg for 3x portions).
- **Bangla Units**: Full localization of units (গ্রাম, কেজি, টি, পিস) inside the shopping list.
- **Essentials Tracking**: Separate tracking for pantry essentials vs. fresh ingredients.

### 🇧🇩 100% Bangla Localization

- **Native Experience**: Completely localized interface including digits, month names, and unit measurements.
- **Dynamic Branding**: App name dynamically shifts to **কাল-কি?** in Bangla mode.

### 🔔 Smart Reminders & Comfort

- **Water Hydration**: Customizable periodic reminders to stay hydrated.
- **Daily Menu Alert**: Smart notifications at night to check and lock in your menu for the next day.
- **Premium Dark Mode**: A sleek, high-contrast dark theme for easy browsing at night.

## 🚀 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (3.10+)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Notifications**: [Awesome Notifications](https://pub.dev/packages/awesome_notifications)
- **Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Icons**: [FontAwesome](https://pub.dev/packages/font_awesome_flutter)
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts) (Inter & Poppins)

## 📂 Project Structure

- `lib/providers/`: Core business logic and state management (Seasonality & Generation logic).
- `lib/services/`: Data management, persistence, and notification handling.
- `lib/screens/`: UI implementations for Home, Market Mode, and Settings.
- `assets/`: JSON-based databases for dishes, ingredients, and seasonality scores.

## 🤝 Open Source & Licensing

This project is released for public use. It is **permissible and allowed** to use, modify, and distribute this application without any specific license requirements. Feel free to use it to manage your daily meals or as a reference for Flutter development!

---

_Created with ❤️ for the Bangladeshi Kitchen._
