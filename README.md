# 📱 TaskFlow — Flutter Todo App with BLoC

A beautiful, modern Flutter Todo App that uses BLoC state management.
---

## ✨ Features

| Feature | Details |
|---|---|
| 🔐 Authentication | Sign Up & Sign In with local storage |
| 🌙 Dark Mode | Toggle light/dark theme |
| 🎨 Beautiful UI | Modern design with smooth animations |
| 💾 Local Storage | Use SharedPreferences for data persist |
| 🏷️ Priority | Low / Medium / High priority |
| 📂 Categories | Personal, Work, Shopping, Health, Other |
| 📅 Due Date | Date picker For deadline set |
| 🔍 Filter | All / Active / Completed filter |
| 🗑️ Swipe to Delete | Swipe To task delete |
| ✏️ Edit Task | Tap For task edit |



## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
│
├── models/
│   ├── todo_model.dart          # Todo data model
│   └── user_model.dart          # User data model
│
├── repositories/
│   ├── auth_repository.dart     # Authentication logic
│   └── todo_repository.dart     # Todo CRUD operations
│
├── blocs/
│   ├── auth/
│   │   ├── auth_bloc.dart       # Auth BLoC
│   │   ├── auth_event.dart      # Auth Events
│   │   └── auth_state.dart      # Auth States
│   ├── todo/
│   │   ├── todo_bloc.dart       # Todo BLoC
│   │   ├── todo_event.dart      # Todo Events
│   │   └── todo_state.dart      # Todo States
│   └── theme/
│       └── theme_cubit.dart     # Theme Cubit
│
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart   # Splash Screen
│   ├── auth/
│   │   ├── login_screen.dart    # Login Screen
│   │   └── signup_screen.dart   # Signup Screen
│   └── home/
│       └── home_screen.dart     # Main Home Screen
│
├── widgets/
│   ├── todo_card.dart           # Todo Card Widget
│   └── add_todo_sheet.dart      # Add/Edit Bottom Sheet
│
└── utils/
    └── app_theme.dart           # App Theme (Light & Dark)


---

## 📦 Uses Dependencies

```yaml:
# State Management
flutter_bloc: ^8.1.3
bloc: ^8.1.2

# Local Storage
shared_preferences: ^2.2.2

# UI & Animations
google_fonts: ^6.1.0
flutter_animate: ^4.3.0
iconsax: ^0.0.8
gap: ^3.0.1

# Utilities
uuid: ^4.3.3
equatable: ^2.0.5
intl: ^0.19.0


---

## 🎨 BLoC Architecture


UI (Screens/Widgets)
       │
       ▼ Events
   [BLoC/Cubit]
       │
       ▼ 
  [Repository]
       │
       ▼
  [Data Layer]
  (SharedPreferences)
       │
       ▼ States
   [BLoC/Cubit]
       │
       ▼
UI (Rebuilds with new state)


### Auth BLoC Flow:

AuthCheckRequested ──► Check SharedPreferences ──► AuthAuthenticated / AuthUnauthenticated
AuthSignInRequested ──► Validate credentials ──► AuthAuthenticated / AuthError
AuthSignUpRequested ──► Create account ──► AuthAuthenticated / AuthError
AuthSignOutRequested ──► Clear session ──► AuthUnauthenticated


### Todo BLoC Flow:

TodosLoaded ──► Fetch from storage ──► TodoLoaded
TodoAdded ──► Add to list ──► TodoLoaded (updated)
TodoToggled ──► Toggle complete ──► TodoLoaded (updated)
TodoDeleted ──► Remove from list ──► TodoLoaded (updated)
TodoFilterChanged ──► Filter list ──► TodoLoaded (filtered)


---

## 📸 Screens

1. **Splash Screen** — Logo animation + auth check
2. **Login Screen** — Email/Password login
3. **Signup Screen** — Account creation
4. **Home Screen** — Todo list with stats, filter tabs, FAB
5. **Add/Edit Sheet** — Bottom sheet for create/edit todo

---

## 💡 Spectial Features

- **English UI** — Full English interface
- **Greeting** — Greeting based on time (Good morning/afternoon/evening/night)
- **Overdue Detection** — Red color if the due date has passed.
- **Swipe to Delete** — Confirmation dialog
- **Per-user data** — Separate todo list for each user.

---

Made with ❤️ Md. Sakender Saikot using Flutter & BLoC 
