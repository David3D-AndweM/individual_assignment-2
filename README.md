# BookSwap - Mobile Book Exchange Platform

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

A comprehensive mobile application for students to exchange textbooks, built with Flutter and Firebase. BookSwap enables users to list books, initiate swap offers, and communicate through an integrated chat system.

## 📱 Features

### Core Functionality
- **User Authentication**: Secure signup/login with email verification
- **Book Management**: Full CRUD operations for book listings
- **Swap System**: Initiate and manage book exchange offers
- **Real-time Chat**: Integrated messaging system for swap coordination
- **Image Upload**: Book cover photo support with compression
- **State Management**: Reactive UI with Provider pattern

### Technical Highlights
- **Clean Architecture**: Separation of domain, data, and presentation layers
- **Real-time Synchronization**: Live updates across all connected devices
- **Performance Optimized**: Image compression and lazy loading
- **Security**: Comprehensive Firestore security rules

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Firebase CLI
- iOS Simulator or Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/davidmwape/bookswap_app.git
   cd bookswap_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   
   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   
   b. Enable Authentication (Email/Password), Cloud Firestore, and Storage
   
   c. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
   
   d. Configure Firebase:
   ```bash
   flutterfire configure
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 📋 Assignment Requirements Checklist

### ✅ Authentication
- [x] Firebase Auth email/password signup/login
- [x] Email verification enforcement
- [x] User profile management

### ✅ Book Listings (CRUD)
- [x] Create: Add books with title, author, condition, image
- [x] Read: Browse all listings in shared feed
- [x] Update: Edit existing book listings
- [x] Delete: Remove book listings

### ✅ Swap Functionality
- [x] Initiate swap offers with "Swap" button
- [x] Move listings to "My Offers" section
- [x] State management (Pending, Accepted, Rejected)
- [x] Real-time sync between users

### ✅ State Management
- [x] Provider pattern implementation
- [x] Reactive UI updates
- [x] Real-time data synchronization

### ✅ Navigation
- [x] BottomNavigationBar with 4 screens
- [x] Browse Listings, My Books, Offers, Settings screens

### ✅ Chat Feature (Bonus)
- [x] Chat creation after swap offers
- [x] Real-time messaging system
- [x] Message persistence in Firestore

## 📚 Documentation

### Project Documentation
- [Reflection Report](docs/reflection_report.md) - Development experience and challenges
- [Design Summary](docs/design_summary.md) - Architecture and design decisions
- [Demo Video Script](docs/demo_video_script.md) - Video demonstration guide

## 👨‍💻 Author

**David Mwape**
- Course: Mobile Application Development
- Assignment: Individual Assignment 2 - BookSwap App
- Date: November 11, 2025

---

**Note**: This project was developed as part of Individual Assignment 2 for Mobile Application Development course. It demonstrates proficiency in Flutter development, Firebase integration, state management, and mobile app architecture.
# individual_assignment-2
