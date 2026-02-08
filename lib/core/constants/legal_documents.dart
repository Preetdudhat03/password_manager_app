class LegalDocuments {
  static const String privacyPolicy = """
# Privacy Policy

**Last Updated:** February 07, 2026

## 1. Introduction
Klypt is an offline, zero-knowledge password manager designed with privacy as its primary goal. Unlike many commercial password managers, Klypt operates entirely on your device. It does not connect to the internet, does not have a central server, and does not require an account.

We believe that your passwords belong only to you.

## 2. Information We Do NOT Collect
We want to be perfectly clear about what we do **not** do:

*   **No Personal Data Collection:** We do not collect your name, email, phone number, or IP address.
*   **No Analytics:** We do not track how you use the app or which buttons you click.
*   **No Tracking:** We do not use cookies, advertising IDs, or tracking pixels.
*   **No Accounts:** You do not create an account with us. There is no login server.
*   **No Server Communication:** The app has no internet permissions (other than what the operating system might require for local network discovery, which we do not use) and sends no data to us or anyone else.

## 3. Information Stored on Your Device
All the data you enter into Klypt (usernames, passwords, notes, categories) is stored locally on your specific device.

*   **Encryption:** Your data is encrypted using industry-standard AES-256 encryption.
*   **Local Only:** This encrypted data remains on your device's internal storage. It never leaves your device unless you explicitly choose to export a backup.

## 4. Backup Files
Klypt allows you to create encrypted backup files to protect against data loss.

*   **User Control:** You choose where to save these files (e.g., your phone's storage, a USB drive, or a cloud storage provider of your choice).
*   **No Access:** We (the developer) have absolutely no access to your backup files. We cannot decrypt them, and we cannot recover them for you.

## 5. Biometric Authentication
Klypt supports unlocking using your device's biometric features (Fingerprint, Face Unlock).

*   **OS Handled:** Biometric authentication is handled entirely by your device's operating system (Android/iOS).
*   **No Access:** Klypt receives only a "Yes/No" confirmation from the system. We never access, store, or transmit your actual biometric data (fingerprint or face map).

## 6. Third-Party Services
Klypt is a standalone application.

*   **No Ads:** The app does not display advertisements.
*   **No Analytics SDKs:** We do not include third-party code (like Google Analytics, Firebase Analytics, or Facebook Pixel) that monitors your behavior.

## 7. Data Loss Disclaimer
Because Klypt is a zero-knowledge, offline system, **we cannot recover your data if you lose access.**

*   **Lost Device:** If you lose your device and do not have a backup, your passwords are lost.
*   **Forgotten Master Password:** If you forget your Master Password, there is no "Forgot Password" link. Your data remains encrypted forever.
*   **Responsibility:** We deliberately chose this design to ensure no one—not even us—can access your data without your permission.

## 8. Children’s Privacy
Klypt is a utility tool not specifically intended for children. However, because we do not collect any personal data whatsoever, the privacy of all users, including minors, is inherently protected.

## 9. Changes to This Policy
We may update this Privacy Policy to reflect changes in the app's functionality or legal requirements. Any changes will be posted clearly in the app's repository or release notes. Since the app is offline, "push" notifications of policy changes are not possible; please check the repository for the latest version.

## 10. Contact
Klypt is developed and maintained by **Preet Dudhat**.

If you have questions about this policy or the app's privacy practices, please reach out via GitHub:
[https://github.com/Preetdudhat03/password_manager_app](https://github.com/Preetdudhat03/password_manager_app)
""";

  static const String termsAndConditions = """
# Terms and Conditions

**Last Updated:** February 07, 2026

## 1. Acceptance of Terms
By downloading, installing, or using the Klypt mobile application ("App"), you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the App.

## 2. Nature of the App
Klypt is a personal, open-source micro project developed for educational and experimental purposes.
*   **Not a Commercial Service:** Klypt is not a commercial Software-as-a-Service (SaaS) product.
*   **As-Is:** It is provided as a standalone utility without dedicated customer support or enterprise-level guarantees.

## 3. No Warranty
**The App is provided "AS IS" and "AS AVAILABLE" without any warranties of any kind, either express or implied.**

To the fullest extent permitted by law, the developer disclaims all warranties, including but not limited to:
*   Fitness for a particular purpose.
*   Absolute security of data.
*   Freedom from bugs or errors.

We do not claim that the App has been audited by a third-party security firm. Use it at your own discretion.

## 4. User Responsibility
Klypt is designed to give you full control over your data. This means you also bear full responsibility for it.

*   **Master Password:** You are solely responsible for remembering your Master Password. **There is no recovery mechanism.** If you forget it, your data is permanently inaccessible.
*   **Backups:** You are solely responsible for creating and maintaining backups of your data. We recommend keeping backups in multiple secure locations.
*   **Device Security:** You are responsible for keeping your device secure and free from malware that could compromise the App.

## 5. Limitation of Liability
In no event shall the developer (Preet Dudhat) be liable for any direct, indirect, incidental, special, or consequential damages arising out of or in any way connected with the use of the App.

This includes, but is not limited to:
*   **Data Loss:** Loss of passwords or data due to forgotten keys, device loss, or app malfunction.
*   **Security Breaches:** Unauthorized access to your data caused by device compromise, malware, or weak Master Passwords.
*   **Misuse:** Any damages resulting from the use of the App for illegal or unauthorized purposes.

## 6. Security Disclaimer
While Klypt uses industry-standard encryption (AES-256) and security best practices, no software is 100% secure.
*   Security depends heavily on your behavior (e.g., choosing a strong Master Password, not rooting/jailbreaking your device).
*   The App reduces risk significantly by working offline, but it cannot eliminate all risks inherent in digital technology.

## 7. Intellectual Property
The code for Klypt is owned by the developer, Preet Dudhat.
If the project is released under an Open Source license (e.g., MIT, Apache 2.0), the terms of that license apply to the use, modification, and distribution of the source code. Please refer to the `LICENSE` file in the repository for specific details.

## 8. Termination
*   **By You:** You may stop using the App at any time by uninstalling it.
*   **By Developer:** The developer reserves the right to discontinue the project or stop providing updates at any time without notice.

## 9. Changes to Terms
We reserve the right to modify these Terms and Conditions at any time. Your continued use of the App following any changes indicates your acceptance of the new Terms.

## 10. Governing Law
These Terms shall be governed by and construed in accordance with the laws of the developer's jurisdiction, without regard to its conflict of law provisions.
""";

  static const String securityOverview = """
# Security Overview

## 🔐 Your Data Is Yours Alone
Klypt is designed to protect your data locally on this device. We do not use cloud servers, we do not track you, and we do not require an account.

## 🧠 How Your Data Is Protected
*   **Local Encryption:** Your passwords are encrypted with AES-256 before they are ever saved.
*   **Master Password:** Your Master Password is the only key. It is never stored or sent anywhere.
*   **Biometrics:** You can optionally use your fingerprint or face unlock for quick access, secured by your device's hardware.

## 👁 What We Cannot See
*   **Zero Knowledge:** As the developers, we have absolutely no access to your vault.
*   **No "Backdoor":** Your data stays on your device. We cannot see it, decrypt it, or recover it for you.

## ⚠️ Your Responsibility
Because we can't see your data, we can't help you retrieve it if you lose the key.
*   **Remember Your Password:** If you forget your Master Password, your data is lost forever.
*   **Create Backups:** Regularly export your vault to a safe location (like a USB drive or cloud storage you trust) to protect against losing your phone.

## 🔗 Learn More
For a detailed explanation of Klypt’s security model, visit:
[klypt.vercel.app/security](https://klypt.vercel.app/security)
""";
}
