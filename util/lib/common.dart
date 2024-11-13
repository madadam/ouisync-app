import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum Flavor {
  production(
    requiresSigning: true,
    requiresSentryDSN: true,
    doGitCleanCheck: true,
  ),

  nightly(
    requiresSigning: true,
    requiresSentryDSN: true,
    doGitCleanCheck: false,
  ),

  unofficial(
    requiresSigning: false,
    requiresSentryDSN: false,
    doGitCleanCheck: false,
  );

  const Flavor({
    required this.requiresSigning,
    required this.requiresSentryDSN,
    required this.doGitCleanCheck,
  });

  final bool requiresSigning;
  final bool requiresSentryDSN;
  final bool doGitCleanCheck;

  static Flavor fromString(String name) {
    switch (name) {
      case "":
      case "production":
        return Flavor.production;
      case "nightly":
        return Flavor.nightly;
      case "unofficial":
        return Flavor.unofficial;
      default:
        throw ('Invalid flavor "$name", must be one of {production, nightly, unofficial}');
    }
  }

  @override
  String toString() {
    switch (this) {
      case Flavor.production:
        return "production";
      case Flavor.nightly:
        return "nightly";
      case Flavor.unofficial:
        return "unofficial";
    }
  }

  String get displayString {
    switch (this) {
      case Flavor.production:
        return "";
      case Flavor.nightly:
        return "nightly";
      case Flavor.unofficial:
        return "unofficial";
    }
  }
}

/// Runs external command and waits for it to finish. Forwards stdout/stderr to the calling process.
Future<void> run(
  String command,
  List<String> args, {
  String? workingDirectory,
  Map<String, String>? environment,
}) async {
  final process = await Process.start(
    command,
    args,
    workingDirectory: workingDirectory,
    // This helps on Windows with finding `command` in $PATH environment variable.
    runInShell: true,
    environment: environment,
  );

  unawaited(process.stdout.transform(utf8.decoder).forEach(stdout.write));
  unawaited(process.stderr.transform(utf8.decoder).forEach(stderr.write));

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw 'Command "$command ${args.join(' ')}" failed with exit code $exitCode';
  }
}

/// Runs external command and returns its output. Forwards stderr only on failure.
Future<String> runCapture(
  String command,
  List<String> args, {
  String? workingDirectory,
}) async {
  final result = await Process.run(
    command,
    args,
    workingDirectory: workingDirectory,
  );

  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    throw 'Command $command ${args.join(' ')} failed with exit code $exitCode';
  }

  return result.stdout.trim();
}

class IconBadgeDesc {
  final String fileName;
  final String pointsize;
  final String geometry;

  IconBadgeDesc(this.fileName, this.pointsize, this.geometry);
}

Future<void> generateIcons(Flavor flavor) async {
  await _generateFlavorIcons(flavor);
  await _generatePlatformIcons(flavor);
}

Future<void> _generateFlavorIcons(Flavor flavor) async {
  if (flavor == Flavor.production) {
    return;
  }

  final descriptions = [
    IconBadgeDesc("ic_launcher.png", '30', "+0+16"),
    IconBadgeDesc("ic_launcher_foreground.png", '40', "+0+120"),
    IconBadgeDesc("ic_launcher_round.png", '30', "+0+16"),
    IconBadgeDesc("ouisync_icon.png", '40', "+0+16"),
    IconBadgeDesc("OuisyncFull.png", '40', "+0+16"),
    IconBadgeDesc("Ouisync_v1_1560x1553.png", '200', "+0+124"),
  ];

  String binaryName;

  if (Platform.isWindows) {
    binaryName = "magick";
  } else {
    binaryName = "convert";
  }

  final srcDir = Directory("assets/${Flavor.production.name}");

  final dstDir = Directory("assets/${flavor.name}");
  await dstDir.create(recursive: true);

  for (final desc in descriptions) {
    // Use imagemagick's `convert` because the 'package:image/image.dart' lacks features
    // (and some things like setting a font color doesn't seem to work).
    // TODO: This overwrites the existing png files in git, which is annoying when done not
    // on CI.
    await run(binaryName, [
      "${srcDir.path}/${desc.fileName}",
      '-undercolor', '#FA4032aa',
      '-fill', 'white',
      // Picked randomly by what is on my and the CI machines.
      '-font', 'DejaVu-Sans',
      '-gravity', 'South',
      '-pointsize', desc.pointsize,
      '-annotate', desc.geometry, flavor.name.toUpperCase(),
      "${dstDir.path}/${desc.fileName}",
    ]);
  }
}

Future<void> _generatePlatformIcons(Flavor flavor) async {
  final tempDir = await Directory.systemTemp.createTemp();

  try {
    final srcFile = File('icons_launcher.yaml.template');
    final dstFile = File('${tempDir.path}/icons_launcher.yaml');

    await dstFile.writeAsString(
      (await srcFile.readAsString()).replaceAll('\$flavor', flavor.name),
    );

    await run('dart', ['run', 'icons_launcher:create', '--path', dstFile.path]);
  } finally {
    await tempDir.delete(recursive: true);
  }
}
