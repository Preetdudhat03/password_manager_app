# SecurePass - Personal Password Manager

A secure, local-only password manager built with Flutter.

## Setup

1.  **Initialize Platform Files**:
    Since this project was generated manually, you need to generate the platform-specific files (Android, iOS, etc.).
    Run the following command in your terminal:
    ```bash
    flutter create . --org com.example
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```

## Architecture

This project follows Clean Architecture:

-   `lib/core`: Core functionality (encryption, theme, router).
-   `lib/data`: Data layer (models, repositories, data sources).
-   `lib/domain`: Domain layer (entities, use cases).
-   `lib/presentation`: UI layer (screens, widgets, state management).

## Features (Planned)

-   Local-only storage (Hive/Drift).
-   AES-256 Encryption.
-   Biometric Unlock.
-   Material 3 Design.
