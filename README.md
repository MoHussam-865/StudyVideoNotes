📺 Video Notes App

A Flutter app that allows users to watch videos, pause at any moment, and add notes linked to the current timestamp.
It also supports YouTube-like chapters (sections), letting you divide the video into labeled parts for quick navigation.


---

✨ Features

▶️ Video Playback – Play, pause, and seek within videos.

📝 Notes with Timestamps – Pause the video and save a note tied to the exact playback time.

📌 Chapters (Sections) – Organize the video into labeled chapters (e.g., Introduction, Part 1, Conclusion).

🔖 Quick Navigation – Tap a note or chapter to jump instantly to that part of the video.

💾 Persistent Storage – Notes and chapters are stored locally in json file that has the same name as the video so the notes are not removed when the video is deleted.

---

🚀 Getting Started

Prerequisites

Flutter SDK installed (version >= 3.x)

Dart >= 2.17

Android Studio / VS Code with Flutter plugin


Installation

# Clone this repository
git clone https://github.com/yourusername/video_notes_app.git

# Navigate into the project folder
cd video_notes_app

# Get dependencies
flutter pub get

# Run the app
flutter run


---

🏗️ Project Structure follows the MVVM pattern and uses dependncy injection to achieve separation of conserns 


---

⚡ Tech Stack

Flutter (cross-platform UI framework)

Provider (state management with MVVM)

video_player (video playback)


flutter_quill
