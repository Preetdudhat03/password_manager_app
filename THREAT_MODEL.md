# Threat Model: Klypt

## 1. Protected Threats
Klypt is designated to protect against the following vectors:

*   **Lost/Stolen Device**: Data is AES-256 encrypted at rest. Without the Master Password (or Biometric auth), the database file is just random noise. Keys are derived using Argon2id with random salts, making brute-force attacks computationally expensive.
*   **Offline Attacks**: Even if an attacker copies the `.hive` database file, they cannot decrypt it without the Master Key (which is not stored in the file) or the wrapped Key (which requires the Master Password to unwrap).
*   **Shoulder Surfing (Start)**: The app UI is protected by `FLAG_SECURE` (Android), which prevents:
    *   Screenshots
    *   Screen recording (by malware or user)
    *   "Recent Apps" multitasking snapshots (the app appears black or hidden in the switcher)
*   **Malware (Non-Root)**:
    *   The app does not request `INTERNET` permission, so it cannot exfiltrate data remotely even if compromised libraries were injected (assuming OS sandbox holds).
    *   `flutter_secure_storage` uses Android KeyStore, meaning keys never leave the hardware security module (TEE/SE) on supported devices.
*   **Memory Dump (Partial)**:
    *   The app implements "Auto-Lock" on backgrounding. When the app is paused/inactive, the database connection is closed and session keys are cleared from Dart memory logic (AuthNotifier).

## 2. Unprotected Threats (Limitations)
We explicitly do **NOT* protect against:

*   **Rooted/Jailbroken Devices**: On a compromised OS, a malicious root app could hook into memory `ptrace` or replace system framework calls to intercept keystrokes or memory before encryption happens.
*   **Physical Coercion**: We do not implement "Duress Passwords" (yet) that wipe data or show fake vaults. If you are forced to unlock your phone, the data is visible.
*   **Sophisticated Memory Forensics**: While we clear variables where possible, Dart/Flutter is a garbage-collected language. We cannot guarantee exactly *when* a string (like a password field value) is overwritten in RAM by the GC. A forensic analyst with a freeze-spray RAM dump *might* find artifacts of recently viewed passwords.
*   **Supply Chain Attacks**: If the underlying Flutter engine or a used package (like `hive`) is compromised at the source, security is void. We mitigate this by using popular, stable packages and no internet access to download dynamic payloads.

## 3. Assumptions
*   The user's device OS is not compromised (not rooted/malware-infested).
*   The user uses a strong Master Password (the encryption is only as strong as the entropy of the password).
*   The user trusts the Android KeyStore implementation of their specific device manufacturer.
