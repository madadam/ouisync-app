import 'lib/common.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    final flavors = Flavor.values.map((flavor) => flavor.name).join("|");

    print('Usage: dart util/generate-icons.dart <$flavors>');
    return;
  }

  final flavor = Flavor.fromString(args.first);
  await generateIcons(flavor);
}
