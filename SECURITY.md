# Security Model

**Simple. Transparent. Local.**

## The Core Philosophy

Klypt is built on a simple premise: **If we don't have your data, we can't lose it, sell it, or give it away.**

Unlike cloud-based password managers that store your vault on central servers, Klypt keeps everything on your device. We are a zero-knowledge application, meaning the developer has absolutely no way to access your passwords, keys, or personal information.

---

## How We Encrypt Your Data

### Authenticated Encryption
We use **AES-256 GCM** (Galois/Counter Mode).

This effectively puts your data in a digital safe. '256-bit' refers to the strength of the key, and 'GCM' ensures that not only is your data hidden, but it also hasn't been tampered with. If anyone tries to modify your encrypted file, it will fail to decrypt.

### Key Derivation
We use **Argon2id**.

Your Master Password isn't just a key; it's the *source* of the key. We use Argon2id to transform your password into a cryptographic key. This process is deliberately slow and memory-hard, making it computationally expensive for attackers to guess your password using brute-force attacks.

---

## Biometric Security

When you enable fingerprint or face unlock, we do not store your biometrics. Instead, we use the secure hardware on your device (Secure Enclave on iOS, Trusted Execution Environment on Android) to store a unique key that unlocks your vault.

This cryptographic key is only released when the operating system confirms your identity. Klypt never sees or processes your actual fingerprint data.

---

## Realistic Threat Model

Security is about trade-offs. We want you to understand exactly what Klypt protects you from, and what it cannot protect you from.

### ✅ What Klypt Protects Against
*   **Server Breaches:** Since we have no servers, a hack on "Klypt HQ" would yield zero user data.
*   **Remote Mass Surveillance:** Your data exists only on your device, decoupled from any central identity.
*   **Offline Attacks:** If someone steals your encrypted backup, they would still need your Master Password (protected by Argon2id) to read it.

### ❌ What YOU Must Protect Against
*   **Device Malware:** If your phone is infected with malware that records your screen or keystrokes, your Master Password could be compromised.
*   **Physical Coercion:** Encryption cannot solve real-world threats where you are forced to unlock your device.
*   **Forgetting Your Password:** We are a zero-knowledge system. If you forget your Master Password and lose your recovery phrase, **we cannot recover your data**.

---

## Don't Trust Us. Trust the Code.

Security through obscurity is not security. Klypt is an open-source project. This means security researchers and developers can audit our code to verify that we are doing exactly what we say we are.

[View Source Code on GitHub](https://github.com/Preetdudhat03/password_manager_app)
