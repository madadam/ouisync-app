import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../mixins/repo_actions_mixin.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';

class MissingRepositoryState extends StatelessWidget
    with AppLogger, RepositoryActionsMixin {
  const MissingRepositoryState(
      {required this.repositoryName,
      required this.repositoryMetaInfo,
      required this.errorMessage,
      this.errorDescription,
      required this.settings,
      required this.onReloadRepository,
      required this.onDelete,
      Key? key})
      : super(key: key);

  final String repositoryName;
  final RepoMetaInfo repositoryMetaInfo;
  final String errorMessage;
  final String? errorDescription;

  final Settings settings;
  final void Function()? onReloadRepository;
  final Future<void> Function(RepoMetaInfo, AuthMode) onDelete;

  @override
  Widget build(BuildContext context) {
    final emptyFolderImageHeight = MediaQuery.of(context).size.height *
        Constants.statePlaceholderImageHeightFactor;

    return Center(
        child: SingleChildScrollView(
      reverse: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
              alignment: Alignment.center,
              child: Fields.placeholderWidget(
                  assetName: Constants.assetEmptyFolder,
                  assetHeight: emptyFolderImageHeight)),
          Dimensions.spacingVerticalDouble,
          Align(
            alignment: Alignment.center,
            child: Fields.inPageMainMessage(errorMessage,
                style: context.theme.appTextStyle.bodyLarge
                    .copyWith(color: Constants.dangerColor)),
          ),
          if (errorDescription != null) Dimensions.spacingVertical,
          if (errorDescription != null)
            Align(
                alignment: Alignment.center,
                child: Fields.inPageSecondaryMessage(errorDescription!,
                    tags: {Constants.inlineTextBold: InlineTextStyles.bold})),
          Dimensions.spacingVerticalDouble,
          if (onReloadRepository != null)
            Fields.inPageButton(
                onPressed: () => onReloadRepository!(),
                text: S.current.actionReloadRepo,
                size: Dimensions.sizeInPageButtonLong,
                alignment: Alignment.center,
                autofocus: true),
          if (onReloadRepository != null) Dimensions.spacingVertical,
          Fields.inPageButton(
            onPressed: () => deleteRepository(context,
                repositoryName: repositoryName,
                repositoryMetaInfo: repositoryMetaInfo,
                settings: settings,
                delete: onDelete),
            text: S.current.actionRemoveRepo,
            size: Dimensions.sizeInPageButtonLong,
            alignment: Alignment.center,
          ),
        ],
      ),
    ));
  }
}
