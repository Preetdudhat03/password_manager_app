# SecureVault - Offline Password Manager (Flutter)

A personal-first, privacy-first, zero-knowledge password manager build with Flutter.

## 🔐 Security Model & Architecture

This application is designed with a strictly **Offline-First** and **Zero-Knowledge** philosophy.

### Core Principles
1.  **Offline by Default:** No internet permission, no cloud sync, no API calls.
2.  **Zero Knowledge:** The master password is never stored. It is used to derive the encryption key in memory.
3.  **No Telemetry:** No analytics SDKs, no ad networks.

### Data Protection
-   **Encryption:** The Vault is encrypted using **AES-256-GCM**.
-   **Key Derivation:** The encryption key is derived from the Master Password using **Argon2id** (via `cryptography` package).
-   **Storage:** The encrypted vault chunks are stored using **Hive** (encrypted box) or raw file storage with **Flutter Secure Storage** protecting the encryption key (wrapped).
    -   *Current Implementation uses `flutter_secure_storage` to store the wrapped Key/Salt and `Hive` or Files for the Vault content.*
-   **Biometrics:** Biometric authentication (Fingerprint/Face) is used for convenience but does NOT replace the Master Password for key derivation (unless using hardware-backed keystore wrapping, which is implemented via `flutter_secure_storage`).

### Android Security Features
-   **FLAG_SECURE:** Screenshots and screen recording are disabled in the app.
-   **Biometric Prompt:** Uses generic Android BiometricPrompt via `local_auth`.
-   **Auto-Lock:** App clears sensitive state on background.

## 📱 Features

-   **Unlock:** Master Password & Biometric unlock.
-   **Vault:** View, Add, Edit, Delete passwords.
-   **Generator:** Strong password generator (coming soon).
-   **Theme:** Privacy-focused Dark Mode.

## 🛠 Project Structure

The project follows Clean Architecture:
-   `lib/core`: Core logic, security, encryption, theme.
-   `lib/data`: Data layer, repositories, models, datasources.
-   `lib/domain`: Domain layer, entities, usecases.
-   `lib/presentation`: UI layer, screens, widgets, riverpod providers.

## 🚀 How to Run

### Prerequisites
-   Flutter SDK (Stable)
-   Android SDK & Emulator/Device
-   Java 17 (Required for Gradle)

### Steps
1.  **Clone & Install Dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Run on Android:**
    Connect a device or start an emulator.
    ```bash
    flutter run
    ```

3.  **Build APK:**
    ```bash
    flutter build apk --release
    ```

## ⚠️ Important Notes

-   **Do not lose your Master Password.** There is no recovery mechanism.
-   **Backup:** (Feature In Progress) Export encrypted vault manually.

---
*Built with Flutter & Riverpod. Secure by Design.*
