# Citadel  Citadel

> An anonymous, offline, peer-to-peer empathy network.

Citadel is a Flutter-based mobile application prototype that allows users to share short, anonymous, and ephemeral voice notes with nearby devices using a BLE (Bluetooth Low Energy) mesh network. It's a fully offline, serverless social experience focused on local, transient communication.

---

## Core Concepts

* **Anonymous:** No user accounts, logins, or persistent identities. Each session is assigned a temporary, random avatar.
* **Offline & Peer-to-Peer:** The app requires no internet connection. It works by forming a decentralized mesh network with other nearby devices running the app.
* **Encrypted:** All voice notes are end-to-end encrypted using AES-GCM before being broadcast. Only other participants in the mesh can decrypt and listen to them.
* **Ephemeral:** Voice pins automatically expire and are deleted from devices after 30 minutes, ensuring conversations are transient and in-the-moment.
* **Empathy-Driven:** By removing visual identity and focusing on the raw, unfiltered human voice, the app encourages a more empathetic form of communication.

## Features

* **BLE Mesh Networking:** Built on top of Nordic Semiconductor's nRF Mesh SDK, allowing for robust, multi-hop data relay between peers.
* **Voice Note Recording:** Simple UI to record 10-15 second voice "pins".
* **End-to-End Encryption:** Audio data is encrypted on the sender's device and only decrypted on the receiver's device.
* **Threaded Replies:** Users can reply to specific voice pins, creating conversational threads.
* **Local Storage:** Uses Hive DB for efficient local caching of voice pins.
* **UI Feed:** A chronological list of all received voice pins.
* **Map View (Optional):** If geo-coordinates are available, pins can be visualized on a map.

## Tech Stack

* **Framework:** Flutter
* **Language:** Dart
* **Mesh Networking:** `nordic_nrf_mesh`
* **BLE Communications:** `flutter_reactive_ble`
* **Audio:** `flutter_sound`
* **Database:** `hive` / `hive_flutter`
* **State Management:** `flutter_riverpod`
* **Encryption:** `encrypt`
* **Permissions:** `permission_handler`

## Getting Started

### Prerequisites

* Flutter SDK installed.
* An IDE like VS Code or Android Studio.
* Two or more physical iOS/Android devices for testing the mesh network (simulators cannot use BLE).

### Setup

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/loveucifer/citadel.git](https://github.com/loveucifer/citadel.git)
    cd citadel
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the build runner:**
    This is required to generate the necessary code for Hive models.
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the app:**
    ```bash
    flutter run
    ```

### Important Platform Configuration

This app requires specific native permissions to be configured. Ensure you have correctly set up:

* **Android:** `android/app/src/main/AndroidManifest.xml` (for Bluetooth and Location permissions).
* **iOS:** `ios/Runner/Info.plist` (for Bluetooth, Location, and Microphone usage descriptions).

---
_This project is a prototype and a proof-of-concept. The encryption keys are hardcoded for demonstration purposes and should be replaced with a secure key exchange mechanism for a production environment._

