# Klypt Brand Usage Guide

This document defines how and where to use Klypt’s two official logos:
1.  **Primary Logo** (Full-color gradient K) - `logo.png`
2.  **Brand Wordmark** (Logo with name) - `logo2.png`
3.  **Monochrome Logo** (Single-color K, flat) - `logo3.png`

This guide must be followed strictly by developers and designers to ensure brand consistency across the Mobile App, Android System UI, Website, and Marketing Assets.

## 🛑 Core Rules
*   **Do not invent new logos.**
*   **Do not alter colors or shapes.**
*   **Follow platform conventions strictly.**

---

## 🟣 1. PRIMARY LOGO (FULL-COLOR)
**Source File:** `logo.png`

### Description
*   Gradient “K” symbol.
*   Represents the core brand identity.
*   Used where visual quality and brand expression matter.

### ✅ Where to use the Primary Logo

#### 📱 App Icon (Launcher)
*   Android home screen, App drawer, App switcher.
*   **Size variants:** 512×512 (Play Store), 192×192, 144×144, 96×96, 48×48.
*   **Note:** Use the icon-only version (no text).

#### 🚀 App Splash Screen
*   Centered primary logo.
*   Dark background.
*   No animations unless detailed/subtle fade-in.
*   **Purpose:** First brand impression, creates trust & polish.

#### 🖥 Website & Landing Pages
*   Hero section, Header logo, Footer branding.
*   **May include:** Icon + “Klypt” wordmark (using `logo2.png`) or large gradient rendering.

#### 📦 Store Listings
*   Google Play feature graphics.
*   App screenshots.
*   Marketing banners.

### ❌ Where NOT to use the Primary Logo
*   Status bar icons.
*   Notifications.
*   System UI elements.
*   Very small sizes (<24px).
*   **Reason:** Gradients lose clarity at small scales.

---

## ⚫ 2. MONOCHROME LOGO (SYSTEM / NOTIFICATION)
**Source File:** `logo3.png`

### Description
*   Single-color (white or black).
*   Flat vector.
*   No gradients, no shadows.
*   Designed for clarity, legibility, and system compliance.

### ✅ Where to use the Monochrome Logo

#### 🔔 Android Notifications (MANDATORY)
*   Notification small icon (`ic_notification`).
*   Foreground service notifications.
*   Background sync alerts.
*   **Rules:**
    *   Must be white on transparent background.
    *   24×24 dp canvas.
    *   Centered with safe padding.

#### 📊 Status Bar
*   Appears alongside battery, Wi-Fi, etc.
*   Must match Android Material guidelines.

#### ⌚ System UI / Quick Panels
*   Background tasks.
*   Vault auto-lock alerts.
*   Backup completed notifications.

#### 🧪 Debug & Developer Mode (Optional)
*   Logs, Debug notifications, Test builds.

### ❌ Where NOT to use the Monochrome Logo
*   App launcher icon.
*   Splash screen.
*   Website hero sections.
*   Marketing materials.
*   **Reason:** Monochrome icon is functional, not expressive.

---

## 🧭 3. Decision Rule (Simple Mental Model)

**Use this rule always:**
> *   If the logo is part of the **operating system** → use **monochrome**.
> *   If the logo represents the **brand** → use **full-color**.

---

## 🧩 4. Implementation Notes (Important)

### Android
*   **Monochrome Icon Location:** `android/app/src/main/res/drawable/ic_notification.xml` (or png assets in mipmap folders if not vector).
*   **Format:** Vector drawable prefers.
*   **Transparency:** No alpha transparency inside the shape itself.

### Flutter
*   **App Icon:** Primary logo (`logo.png`).
*   **Notifications:** Monochrome logo (`logo3.png`).
*   **Splash:** Primary logo (`logo.png`).

### Web
*   **Favicon:**
    *   Colored version for standard tabs.
    *   Monochrome for pinned tabs (optional).

---

## 🚫 Branding Rules (Strict)
1.  **Do not recolor** the logo arbitrarily.
2.  **Do not add strokes**, outlines, or effects.
3.  **Do not place logo** on low-contrast backgrounds.
4.  **Do not stretch or skew**.

---

## 🧠 Final Guidance
*   The **primary logo** builds **trust**.
*   The **monochrome logo** preserves **clarity**.

Using both correctly makes Klypt feel:
*   Polished.
*   Platform-native.
*   Professionally designed.
