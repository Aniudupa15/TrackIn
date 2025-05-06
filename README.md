# 📍 TrackIn - Smart AI & Geo-Location Attendance System

![Flutter](https://img.shields.io/badge/Built%20with-Flutter-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Backend-Firebase-orange?logo=firebase)
![MIT License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)

TrackIn is an innovative attendance automation app that leverages **AI-based facial recognition** and **geo-location verification** to record student presence from a group photo. Designed for institutions and organizations, it reduces manual effort, enhances accuracy, and prevents fraudulent check-ins.

---

## 📚 Table of Contents

- [🚀 Features](#-features)
- [🛠️ Tech Stack](#️-tech-stack)
- [📦 Project Structure](#-project-structure)
- [⚙️ Setup Instructions](#️-setup-instructions)
- [📸 How It Works](#-how-it-works)
- [🧠 Future Enhancements](#-future-enhancements)
- [📄 License](#-license)
- [👨‍💻 Developer](#-developer)
- [🤝 Contributing](#-contributing)
- [📬 Contact](#-contact)

---

## 🚀 Features

- 📸 **Group Photo Detection** – AI identifies students in a single group image.
- 🌐 **Geo-location Validation** – Ensures photos are taken within the campus boundaries.
- 🧠 **Face Matching AI** – Matches faces with pre-trained student image dataset.
- 👥 **Role Management** – Organization and Individual modes with different access levels.
- 📊 **Attendance Dashboard** – View and download attendance reports in real-time.
- ☁️ **Cloud-based Infrastructure** – Secure data handling using Firebase.
- 🔐 **Authentication** – Email/password login using Firebase Auth.
- 🗃️ **Student Dataset Storage** – Image-based identity management.
- 📲 **Cross-platform** – Android, iOS, and Web support.

---

## 🛠️ Tech Stack

| Layer         | Tools/Technologies                          |
|---------------|---------------------------------------------|
| **Frontend**  | Flutter                                     |
| **Backend**   | Firebase Functions or FastAPI               |
| **ML Model**  | Python, face_recognition, OpenCV            |
| **Database**  | Firebase Firestore / Realtime Database      |
| **Storage**   | Firebase Storage                            |
| **Auth**      | Firebase Authentication                     |
| **Maps/GPS**  | Google Maps API, Geolocator Plugin          |

---

## 📦 Project Structure

```
trackin/
├── frontend/           # Flutter mobile/web app
│   ├── lib/
│   └── pubspec.yaml
├── backend/            # AI/ML APIs and Python scripts
│   ├── models/
│   └── main.py
├── dataset/            # Training images of students
├── docs/               # Wireframes, flow diagrams
├── LICENSE
└── README.md
```

---

## ⚙️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/trackin.git
cd trackin
```

### 2. Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

> Ensure Flutter is installed and configured. Follow [Flutter Install Guide](https://docs.flutter.dev/get-started/install).

### 3. Firebase Integration

* Create a Firebase Project.
* Enable Authentication, Firestore, and Storage.
* Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in appropriate directories.

### 4. Python Backend Setup (for local testing)

```bash
cd backend
pip install -r requirements.txt
python main.py
```

> Note: In production, use Firebase Functions or deploy via a scalable FastAPI backend.

---

## 📸 How It Works

1. **Organization** registers and uploads student images.
2. **Individual** captures and uploads a group photo.
3. The system:
   * Validates geo-location.
   * Processes the image.
   * Matches faces using the AI engine.
   * Marks attendance automatically.
4. Attendance records are saved to the database and visible via dashboards.

---

## 🧠 Future Enhancements

* 🧾 Auto-generated monthly reports
* 🧭 Offline check-in + sync on network restore
* 📆 Calendar view for attendance history
* 🏫 Multi-institution management panel
* 📊 Admin analytics dashboard
* 📲 Push notifications for irregular attendance

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Developer

**Anirudha Udupa**  
📍 Computer Science & Business Systems  
🎓 Canara Engineering College  
🔗 [LinkedIn](https://www.linkedin.com/in/anirudha-udupa-815b0b258/)  
🌐 [Portfolio](https://aniudupa.vercel.app/)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!  
Fork the repo, create a branch, commit your code, and open a pull request.

---

## 📬 Contact

For questions, collaboration, or support:  
📧 [aniudupa15@gmail.com](mailto:aniudupa15@gmail.com)  
📱 +91-9972102246

---

> Made with 💡 and 🔍 to simplify attendance, the smart way.
