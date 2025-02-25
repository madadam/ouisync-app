import 'dart:io';

import 'platform.dart';

abstract class PlatformWindowManager {
  factory PlatformWindowManager() {
    if (Platform.isAndroid ||
    Platform.isIOS) {
      return PlatformWindowManagerMobile();
    }
    return PlatformWindowManagerDesktop();
  }

  Future<void> setTitle(String title);

  Future<void> initSystemTray();

  Future<bool> get isVisible;

  void dispose() {}

  Future<void> setPreventClose(bool isPreventClose);

  void onWindowClose() {}

  Future<void> close();
}
