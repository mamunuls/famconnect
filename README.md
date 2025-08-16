# 👨‍👩‍👧‍👦 FamConnect

**FamConnect** is a smart, all-in-one Android app built with **Flutter** to help families stay organized, safe, and connected. From chore tracking and real-time GPS to event reminders and dinner planning — FamConnect makes managing family life seamless.

---

## 🚀 Features

### 🧑‍💼 Family Member Profiles
- Each member can create a personal profile with name, work schedule, and preferences.
- Data is stored and synced in real time using Firebase.

### 📍 Real-Time Location Tracking
- Track each family member's current location.
- Display locations on an interactive Google Map.
- Helps with safety, coordination, and peace of mind.

### ✅ Household Chore Management
- Assign, track, and complete daily chores.
- Checkbox-based UI for simplicity.
- Optional auto-scheduler to distribute chores evenly.

### 🎉 Event & Occasion Reminders
- Get reminders for birthdays, anniversaries, and more.
- Receive local notifications in advance.
- All events stored securely in Firestore.

### 🎁 Gift Suggestion System
- Personalized gift ideas based on interests and occasion types.
- Uses basic logic (tags or randomization) to generate suggestions.

### 🍽 Smart Dinner Planner
- Finds the best possible dinner time by comparing work schedules.
- Family members can confirm or suggest changes collaboratively.

### 🔐 Security & Privacy
- Firebase Authentication (Email/Password or Google Sign-In).
- Firestore encryption and privacy compliance (e.g. GDPR).
- Consent-based data collection.

---

## 🖥 Screens Included

- Home Dashboard
- Profile Page
- GPS Tracker Map
- Chore List & Manager
- Event Calendar
- Dinner Scheduler
- App Settings

---

## 🔧 Tech Stack

| Technology                              | Description                            |
|-----------------------------------------|----------------------------------------|
| **Flutter**                             | Cross-platform mobile framework         |
| **Firebase Firestore**                  | Real-time NoSQL cloud database         |
| **Firebase Auth**                       | Secure sign-in options                  |
| **Geolocator**                          | GPS tracking for real-time location     |
| **Google Maps API**                     | Map UI for displaying locations         |
| **Local Notifications**                 | For event reminders                |
| **Firebase Cloud Messaging** (optional) | Push notifications   |

---

## 📲 Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or VS Code
- Firebase account and project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/PoramaChowdhury/famconnect/
   cd famconnect
