import 'dart:math';

import 'package:ouisync_app/app/utils/utils.dart';
import 'package:path/path.dart' as p;

// source: https://gist.github.com/zzpmaster/ec51afdbbfa5b2bf6ced13374ff891d9
dynamic formatSize(int bytes, {int decimals = 2, bool units = false}) {
  if (bytes <= 0) return "0 B";
  if (bytes < 1024) return '$bytes B';

  const suffixes = [
    "B",
    "KiB",
    "MiB",
    "GiB",
    "TiB",
    "PiB",
    "EiB",
    "ZiB",
    "YiB"
  ];
  var i = (log(bytes) / log(1024)).floor();

  final size = double.parse(((bytes / pow(1024, i)).toStringAsFixed(decimals)));

  return units ? '$size ${suffixes[i]}' : size;
}

String buildDestinationPath(String parentPath, String entryPath) {
  /// We want to maintain a POSIX style path inside the library, even when
  /// the app is running on Windows.
  final context = p.Context(style: p.Style.posix);
  return context.join(parentPath, entryPath);
}

String formatShareLinkForDisplay(String shareLink) {
  final shareTokenUri = Uri.parse(shareLink);
  final truncatedToken =
      '${shareTokenUri.fragment.substring(0, Constants.maxCharacterRepoTokenForDisplay)}...';

  final displayToken = shareTokenUri.replace(fragment: truncatedToken);
  return displayToken.toString();
}

String maskPassword(String? password, {bool mask = true}) =>
    (mask ? "●" * (password ?? '').length : password) ?? '';
