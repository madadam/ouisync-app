import 'dart:io';

import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import 'app_version_tile.dart';

class AboutSectionMobile extends AbstractSettingsSection {
  final ReposCubit repos;

  AboutSectionMobile({required this.repos});

  @override
  Widget build(BuildContext context) => SettingsSection(
        title: Text(S.current.titleAbout),
        tiles: [
          CustomSettingsTile(
            child: AppVersionTile(
              session: repos.session,
              leading: Icon(Icons.info_outline),
              title: Text(S.current.labelAppVersion),
            ),
          ),
          SettingsTile(
            title: Text(S.current.messageSettingsRuntimeID),
            leading: Icon(Icons.person),
            value: _getRuntimeIdForOS(),
          ),
        ],
      );

  Widget _getRuntimeIdForOS() => FutureBuilder(
      future: repos.session.thisRuntimeId,
      builder: (context, snapshot) {
        final runtimeId = snapshot.data ?? '';
        final runtimeIdWidget = Text(
          runtimeId,
          overflow: TextOverflow.ellipsis,
        );

        if (Platform.isIOS) {
          return Expanded(
            child: Row(children: [Expanded(child: runtimeIdWidget)]),
          );
        }

        return runtimeIdWidget;
      });
}
