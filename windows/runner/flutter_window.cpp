#include "flutter_window.h"

#include <optional>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // Klypt Secure Clipboard Channel
  // Handles writing data while excluding it from Windows Clipboard History
  static const std::string channel_name = "klypt/clipboard";
  clipboard_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), channel_name,
      &flutter::StandardMethodCodec::GetInstance());

  clipboard_channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "writeSecure") {
            const auto* arguments = std::get_if<std::string>(call.arguments());
            if (!arguments) {
                result->Error("INVALID_ARGUMENT", "String expected");
                return;
            }
            std::string text = *arguments;

            if (!OpenClipboard(nullptr)) {
                result->Error("OPEN_FAILED", "Could not open clipboard");
                return;
            }
            
            EmptyClipboard();

            // 1. Write Text
            HGLOBAL hGlob = GlobalAlloc(GMEM_MOVEABLE, text.size() + 1);
            if (hGlob) {
                memcpy(GlobalLock(hGlob), text.c_str(), text.size() + 1);
                GlobalUnlock(hGlob);
                SetClipboardData(CF_TEXT, hGlob);
            }

            // 2. Set 'ExcludeClipboardContentFromMonitorProcessing'
            // This prevents Windows History from picking it up
            UINT format = RegisterClipboardFormat(TEXT("ExcludeClipboardContentFromMonitorProcessing"));
            HGLOBAL hIgnore = GlobalAlloc(GMEM_MOVEABLE, sizeof(DWORD));
            if (hIgnore) {
                DWORD* ptr = (DWORD*)GlobalLock(hIgnore);
                *ptr = 0; // bool (FALSE/0 doesn't matter, just presence)
                GlobalUnlock(hIgnore);
                SetClipboardData(format, hIgnore);
            }

            CloseClipboard();
            result->Success();
        } else {
          result->NotImplemented();
        }
      });


  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
