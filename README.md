
# TrackIn

**TrackIn** is an innovative AI-powered, geo-location-based attendance app built using Flutter. Designed to revolutionize attendance management, TrackIn uses machine learning for photo-based student verification and geo-location tracking.

## Features

- **AI-Powered Attendance**: Automatically detects student presence by comparing group photos with a registered dataset.
- **Geo-Location Verification**: Ensures photos are taken at the correct location to verify attendance.
- **User Roles**:
  - **Organization**: Register, add students, and manage attendance records.
  - **Individual**: View personal attendance status and historical data.
- **Scalable & Efficient**: Handles attendance for both small and large groups seamlessly.

---

## TrackIn API

The backend exposes the following key API routes:

- **POST** `/TrackIn/register`: Register a new organization.
- **POST** `/TrackIn/add-student`: Add a new student to your organization.
- **GET** `/TrackIn/attendance-status`: Retrieve attendance status for an individual student.
- **POST** `/TrackIn/upload-photo`: Upload a group photo for attendance verification.

---

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/yourusername/trackin.git
    cd trackin
    ```

2. Set up Firebase and configure the Flutter app with the necessary credentials.

3. Run the Flutter app:
    ```bash
    flutter run
    ```

---

## License

TrackIn is licensed under the MIT License. See [LICENSE](LICENSE) for more details.

