# Salon Booking App 🧖🏽‍♀️💇🏽‍♂️

A simple Flutter-based mobile application for salon appointment booking, integrated with Firebase Authentication and Firestore. It supports both **Customers** and **Vendors**.

## ✨ Features

- User Registration (Email & Password)
- WhatsApp PIN Verification
- Role-based login (Customer or Vendor)
- Book salon services with date and time
- Vendor approval or rejection of bookings
- View bookings and their statuses
- Logout functionality
- Firebase Firestore integration
- Clean modern UI with Teal accents

## 📱 Screens

1. **AuthEntry** — Welcome screen with navigation to Login or Register
2. **RegisterScreen** — Signup with WhatsApp PIN verification
3. **LoginScreen** — Role-based login
4. **BookingScreen** — Book a service (for Customers), approve/reject (for Vendors)
5. **PinConfirmationScreen** — Verifies 4-digit PIN from WhatsApp (dummy for assessment)
6. **AuthWrapper** — Decides screen based on login state

## 🛠 Tech Stack

- **Flutter**: UI & logic
- **Firebase Auth**: User authentication
- **Cloud Firestore**: Store user info and bookings
- **WhatsApp Web**: Simulated PIN message
- **Dart**: Backend logic
- **Material Design**: Custom UI

---

## 📂 Folder Structure

```bash
/lib
  /screens
    /auth
      auth_entry.dart
      login_screen.dart
      register_screen.dart
      pin_code_screen.dart
    booking_screen.dart
  main.dart


🚀 Getting Started
Prerequisites
Flutter SDK ≥ 3.10

Firebase account

Android Studio / VS Code

Emulator or physical device


git clone https://github.com/yourusername/salon-booking-app.git
cd frulo-booking-app

flutter pub get

flutter run