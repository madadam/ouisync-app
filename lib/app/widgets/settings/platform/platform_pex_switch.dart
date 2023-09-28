import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/cubits.dart';
import '../../../utils/platform/platform.dart';

class PlatformPexSwitch extends StatelessWidget {
  const PlatformPexSwitch(
      {required this.repository,
      required this.title,
      required this.icon,
      required this.onToggle});

  final RepoCubit repository;
  final Widget title;
  final IconData icon;

  final dynamic Function(bool)? onToggle;

  @override
  Widget build(BuildContext context) {
    if (PlatformValues.isMobileDevice) {
      return buildMobileWidget(context);
    }
    return buildDesktopWidget(context);
  }

  Widget buildDesktopWidget(BuildContext context) =>
      BlocSelector<RepoCubit, RepoState, bool>(
          bloc: repository,
          selector: (state) => state.isPexEnabled,
          builder: (context, value) => SwitchListTile.adaptive(
              value: value,
              title: title,
              secondary: Icon(icon),
              onChanged: (value) => onToggle?.call(value)));

  AbstractSettingsTile buildMobileWidget(BuildContext context) =>
      SettingsTile.switchTile(
          initialValue: repository.state.isPexEnabled,
          title: title,
          leading: Icon(icon),
          onToggle: (value) => onToggle?.call(value));
}
