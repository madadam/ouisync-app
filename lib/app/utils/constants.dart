import 'package:flutter/material.dart';

enum AuthMode {
  manual,
  version1,
  version2,
  noLocalPassword,
}

String authModeToString(AuthMode authMode) {
  switch (authMode) {
    case AuthMode.manual:
      {
        return "manual";
      }
    case AuthMode.version1:
      {
        return "version1";
      }
    case AuthMode.version2:
      {
        return "version2";
      }
    case AuthMode.noLocalPassword:
      {
        return "noLocalPassword";
      }
  }
}

AuthMode? authModeFromString(String authMode) {
  switch (authMode) {
    case "manual":
      {
        return AuthMode.manual;
      }
    case "version1":
      {
        return AuthMode.version1;
      }
    case "version2":
      {
        return AuthMode.version2;
      }
    case "noLocalPassword":
      {
        return AuthMode.noLocalPassword;
      }
  }
  return null;
}

enum PasswordAction { add, change, remove, biometrics }

class Constants {
  Constants._();

  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color dangerColor = Colors.red;

  static const String folderRepositoriesName = 'repositories';
  static const String configDirName = 'configs';
  static const String logFileName = 'ouisync.log';

  static const int bufferSize = 64000;

  static const int maxCharacterRepoTokenForDisplay = 8;
  static const String ouisyncUrl = 'https://ouisync.net';
  static const String issueTrackerUrl =
      'https://github.com/equalitie/ouisync-app/issues';
  static const String supportEmail = 'support@ouisync.net';
  static const String faqUrl =
      'https://github.com/equalitie/ouisync-app/wiki/Frequently-Asked-Questions';
  static const eqValuesUrl = 'https://equalit.ie/values/';

  static Color primaryColor(context) => Theme.of(context).primaryColorDark;

  static const double repositoryBarHeight = 58.0;

  static const int modalTransitionDurationMs = 800;
  static const int notAvailableActionMessageDuration = 4;

  static const double statePlaceholderImageHeightFactor = 0.15;

  /// In-line text style names

  static const String inlineTextBold = 'bold';
  static const String inlineTextSize = 'size';
  static const String inlineTextColor = 'color';
  static const String inlineTextIcon = 'icon';

  /// Hero tags

  static const String heroTagMainPageActions = 'MAIN_PAGE_ACTIONS';
  static const String heroTagRepoListActions = 'REPO_LIST_ACTIONS';

  /// Authentication modes

  //static const String authModeManual = 'manual';
  //static const String authModeVersion1 =
  //    'version1'; // Using built in biometric validation in biometrics_storage
  //static const String authModeVersion2 =
  //    'version2'; // Using local_auth for biometric validation
  //static const String authModeNoLocalPassword = 'no_local_password';

  static const String repoListEntryName = 'repo_list';

  static const IconData iconVisibilityOn = Icons.visibility;
  static const IconData iconVisibilityOff = Icons.visibility_off;

  static const Color progressBarBackgroundColor =
      Color.fromRGBO(238, 238, 238, 1);
  static const Color modalBottomSheetBackgroundColor = Color(0xFFEAEEFF);
  static const Color folderIconColor = Color.fromARGB(255, 86, 86, 86);
  static const Color inputBackgroundColor = Color.fromARGB(255, 224, 224, 224);
  static const Color inputLabelForeColor = Color.fromARGB(255, 117, 117, 117);

  static const String eQLogo = 'assets/eq_logo.png';

  static const String onboardingShareImage =
      '01_onboarding_send_receive_files.png';
  static const String onboardingPermissionsImage =
      '02_onboarding_permissions_collaborate.png';
  static const String onboardingAccessImage =
      '03_onboarding_access_multiple_devices.png';

  static const String appIcon = './assets/favicon.png';
  static const String windowsAppIcon = './assets/favicon.ico';

  static const String eventLeftMouseUp = 'leftMouseUp';
  static const String eventRightMouseUp = 'rightMouseUp';

  static const String assetPathNothingHereYet = 'assets/nothing_here_yet.png';
  static const String assetPathAddWithQR = 'assets/add_with_qr.png';
  static const String assetLockedRepository = 'assets/locked_repo.png';
  static const String assetEmptyFolder = 'assets/empty_folder.png';

  // List of available storage servers.
  static const List<String> storageServers = ["storage.ouisync.net"];
}
