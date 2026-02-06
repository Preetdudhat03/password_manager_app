# Klypt Clipboard Security

This document explains the security architecture for clipboard operations in Klypt, including platform-specific limitations and the custom native implementation for Windows.

## The Problem: Persistent Clipboard History

Modern operating systems (Windows 10/11) maintain a "Clipboard History" (accessible via `Win+V`) that retains copied items even after the current clipboard is cleared or overwritten. If Klypt simply writes to the clipboard, the password remains in this history, accessible to anyone with physical access.

## The Solution

### 1. Windows Desktop App (Native Protection)
For the Windows Desktop target (`flutter run -d windows`), we have implemented a **native C++ method channel** (`klypt/clipboard`) that uses the Windows API to explicitly exclude sensitive data from the history.

**Mechanism:**
- We write the password to the clipboard using `SetClipboardData`.
- We immediately write a special signal format: `ExcludeClipboardContentFromMonitorProcessing`.
- This tells the OS/Clipboard Manager NOT to record this entry in history or sync it to the cloud.

Implemented in:
- `windows/runner/flutter_window.cpp` (C++ backend)
- `lib/core/security/clipboard_manager.dart` (Dart frontend)

### 2. Web / Chrome (Browser Sandbox Limitation)
When running Klypt in a browser (e.g., `flutter run -d chrome`):
- We **CANNOT** prevent the OS from recording the clipboard history. The browser sandbox isolates the app from low-level OS APIs.
- The "Auto-Clear" timer (10s) works by overwriting the clipboard with empty text. However, browsers require a **user gesture** (like a click) to allow clipboard writing.
  - **Limitation**: The timer callback runs in the background. Modern browsers often block this write attempt unless the user is interacting with the page at that exact moment.
  - **Result**: You may see console errors or failure to clear on Web if the tab is idle.

**Recommendation**:
For maximum security, use the **Windows Desktop App** build rather than the Web version. The native app provides stronger guarantees that the web platform physically cannot support.
