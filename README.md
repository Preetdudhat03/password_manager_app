# Klypt — Offline Password Manager

Klypt is an offline-first, local-only password manager built with Flutter. It allows users to securely store credentials on their device without relying on third-party cloud servers. This project was developed as a "Micro Application" to explore advanced mobile security concepts, clean architecture, and zero-knowledge encryption principles.

## Motivation

In a digital landscape dominated by cloud-based services, data breaches are increasingly common. While centralized password managers offer convenience, they also present a centralized target for attackers.

Klypt was built to explore the opposite extreme: **Maximum Sovereignty**. By keeping all data strictly on the user's device and removing the network layer entirely, the attack surface is reduced to the physical possession of the device itself. This project serves as a practical exploration of cryptography, secure mobile storage, and privacy-by-design user experience.

## Key Features

*   **Offline-First**: No internet permission required. Data never leaves the device.
*   **Zero-Knowledge Encryption**: The master password is never stored or transmitted.
*   **Encrypted Local Vault**: All credentials are encrypted using AES-256-GCM.
*   **Secure Backup**: Users can export their vault to an encrypted file for safekeeping.
*   **Biometric Unlock**: Supports Fingerprint/FaceID for convenient access.
*   **Auto-Lock**: Automatically secures the vault when the app is backgrounded.
*   **No Analytics**: Zero tracking, zero ads, zero data collection.

## Security Model

Klypt operates on a **Zero-Knowledge** architecture. 

1.  **Client-Side Only**: All encryption and decryption happen locally on the device.
2.  **Volatile Master Key**: The key used to encrypt your data is derived from your Master Password using **Argon2id**. This key exists in RAM only while the app is open. It is never written to disk.
3.  **No Backdoor**: Because the developer (me) does not run a server, I cannot reset your password, view your data, or help you recover access if you lose your credentials.
4.  **User Responsibility**: You are the sole custodian of your keys and your data.

## Backup & Recovery Philosophy

Because there is no cloud synchronization, losing your phone would normally mean losing your data. To mitigate this without compromising security, Klypt implements a **Manual Encrypted Backup** system.

*   You can export your vault to a `.klypt` (Klypt Backup) file.
*   This file is encrypted with AES-256.
*   It is safe to store this file on Google Drive, email it to yourself, or keep it on a USB drive.
*   To restore, you simply load the file and enter the Master Password used to create it.

**Warning**: If you lose your phone AND you have not created a backup file, your data is effectively gone forever. This is a deliberate security trade-off.

## Tech Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | Flutter (Dart) |
| **State Management** | Riverpod |
| **Local Database** | Hive (AES-256 Encrypted Box) |
| **Cryptography** | AES-GCM, Argon2id (via `cryptography` package) |
| **Secure Storage** | Android Keystore / iOS Keychain (via `flutter_secure_storage`) |
| **Navigation** | GoRouter |
| **Architecture** | Clean Architecture (Domain/Data/Presentation) |

## Project Structure

The codebase follows strict separation of concerns:

```
lib/
 ├── core/              # Shared utilities (Crypto, Router, Theme)
 ├── data/              # Repositories & Data Sources (Hive, SecureStorage)
 ├── domain/            # Business Logic (Entities & Repo Interfaces)
 └── presentation/      # UI Layer (Screens, Widgets, Notifiers)
     ├── screens/
     ├── state/
     └── widgets/
```

## Getting Started

### Prerequisites
*   Flutter SDK (3.x or higher)
*   Android Studio / VS Code
*   An Android device or emulator

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Start-Up-Republic-Ind/SecureVault.git
    cd klypt
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    Connect your Android device (ensure USB Debugging is ON).
    ```bash
    flutter run
    ```

## Limitations & Disclaimer

*   **Micro Project**: This app is built for educational and portfolio purposes. It has not undergone a third-party security audit.
*   **No Cross-Device Sync**: The app is designed for a single device. Syncing between a phone and laptop is currently not supported (except via manual backup/restore).
*   **Use at Your Own Risk**: While standard industry algorithms are used, the author accepts no liability for data loss.

## Future Improvements

*   **Steganography Support**: Hiding backup files inside images.
*   **Hardware Token Support**: Unlocking via YubiKey (NFC).
*   **Desktop Support**: Windows/Linux/MacOS versions.
*   **Multi-Vault**: Separation of Work and Personal vaults.

## License

This project is open-source and available under the **MIT License**.

## Author

