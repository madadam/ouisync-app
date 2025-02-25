import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../mixins/mixins.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class RepositorySettings extends StatefulWidget {
  const RepositorySettings(
      {required this.context,
      required this.cubit,
      required this.checkForBiometrics,
      required this.getAuthenticationMode,
      required this.renameRepository,
      required this.deleteRepository});

  final BuildContext context;
  final RepoCubit cubit;

  final Future<bool?> Function() checkForBiometrics;
  final AuthMode Function(String repoName) getAuthenticationMode;
  final Future<void> Function(
      String oldName, String newName, Uint8List reopenToken) renameRepository;
  final Future<void> Function(RepoMetaInfo info, AuthMode authMode)
      deleteRepository;

  @override
  State<RepositorySettings> createState() => _RepositorySettingsState();
}

class _RepositorySettingsState extends State<RepositorySettings>
    with AppLogger, RepositoryActionsMixin {
  @override
  Widget build(BuildContext context) => BlocBuilder<RepoCubit, RepoState>(
        bloc: widget.cubit,
        builder: (context, state) => SingleChildScrollView(
            child: Container(
                padding: Dimensions.paddingBottomSheet,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Fields.bottomSheetHandle(context),
                      Fields.bottomSheetTitle(widget.cubit.name),
                      Row(children: [
                        Expanded(
                            child: SwitchListTile.adaptive(
                          title: Text(S.current.labelBitTorrentDHT),
                          secondary: const Icon(
                            Icons.hub,
                            size: Dimensions.sizeIconMicro,
                            color: Colors.black87,
                          ),
                          contentPadding: EdgeInsets.zero,
                          value: state.isDhtEnabled,
                          onChanged: (value) =>
                              widget.cubit.setDhtEnabled(value),
                        )),
                      ]),
                      Row(children: [
                        Expanded(
                            child: SwitchListTile.adaptive(
                          title: Text(S.current.messagePeerExchange),
                          secondary: const Icon(
                            Icons.group_add,
                            size: Dimensions.sizeIconMicro,
                            color: Colors.black87,
                          ),
                          contentPadding: EdgeInsets.zero,
                          value: state.isPexEnabled,
                          onChanged: (value) =>
                              widget.cubit.setPexEnabled(value),
                        ))
                      ]),
                      Row(
                        children: [
                          Expanded(
                              child: Fields.actionListTile(
                                  S.current.actionRename,
                                  textFontSize: Dimensions.fontAverage,
                                  textOverflow: TextOverflow.ellipsis,
                                  textSoftWrap: false,
                                  onTap: () async => await renameRepository(
                                      widget.context,
                                      repository: widget.cubit,
                                      rename: widget.renameRepository,
                                      popDialog: () =>
                                          Navigator.of(context).pop()),
                                  icon: Icons.edit,
                                  iconSize: Dimensions.sizeIconMicro,
                                  iconColor: Colors.black87,
                                  textColor: Colors.black87,
                                  dense: true,
                                  visualDensity: VisualDensity.compact)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: Fields.actionListTile(
                                  S.current.actionShare,
                                  textFontSize: Dimensions.fontAverage,
                                  textOverflow: TextOverflow.ellipsis,
                                  textSoftWrap: false, onTap: () async {
                            Navigator.of(context).pop();
                            await shareRepository(context,
                                repository: widget.cubit);
                          },
                                  icon: Icons.share,
                                  iconSize: Dimensions.sizeIconMicro,
                                  iconColor: Colors.black87,
                                  textColor: Colors.black87,
                                  dense: true,
                                  visualDensity: VisualDensity.compact)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: Fields.actionListTile(
                                  S.current.titleSecurity,
                                  textFontSize: Dimensions.fontAverage,
                                  textOverflow: TextOverflow.ellipsis,
                                  textSoftWrap: false,
                                  onTap: () async =>
                                      await navigateToRepositorySecurity(
                                        context,
                                        repository: widget.cubit,
                                        checkForBiometrics:
                                            widget.checkForBiometrics,
                                        popDialog: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                  icon: Icons.password,
                                  iconSize: Dimensions.sizeIconMicro,
                                  iconColor: Colors.black87,
                                  textColor: Colors.black87,
                                  dense: true,
                                  visualDensity: VisualDensity.compact)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: Fields.actionListTile(
                                  S.current.actionDelete,
                                  textFontSize: Dimensions.fontAverage,
                                  textOverflow: TextOverflow.ellipsis,
                                  textSoftWrap: false,
                                  onTap: () async => await deleteRepository(
                                      context,
                                      repositoryName: widget.cubit.name,
                                      repositoryMetaInfo: widget.cubit.metaInfo,
                                      getAuthenticationMode:
                                          widget.getAuthenticationMode,
                                      delete: widget.deleteRepository,
                                      popDialog: () =>
                                          Navigator.of(context).pop()),
                                  icon: Icons.delete,
                                  iconSize: Dimensions.sizeIconMicro,
                                  iconColor: Constants.dangerColor,
                                  textColor: Constants.dangerColor,
                                  dense: true,
                                  visualDensity: VisualDensity.compact)),
                        ],
                      )
                    ]))),
      );
}
