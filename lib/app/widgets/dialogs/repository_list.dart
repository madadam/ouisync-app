import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../../cubit/cubits.dart';
import '../../pages/pages.dart';
import '../../models/main_state.dart';
import '../../utils/loggers/ouisync_app_logger.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class RepositoryList extends StatelessWidget with OuiSyncAppLogger {
  RepositoryList({
    required this.context,
    required this.cubit,
  });

  final BuildContext context;
  final RepositoriesCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepositoriesCubit, RepositoriesChanged>(
      bloc: cubit,
      builder: (context, changed) {
        final state = cubit.mainState;

        return Container(
          padding: Dimensions.paddingBottomSheet,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Fields.bottomSheetHandle(context),
              Fields.bottomSheetTitle(S.current.titleRepositoriesList),
              _buildRepositoryList(state.repositoryNames().toList(), state.currentRepoName),
              Dimensions.spacingActionsVertical,
              Fields.paddedActionText(
                S.current.iconCreateRepository,
                icon: Icons.add_circle_outline_rounded,
                onTap: () => createRepoDialog(this.cubit),
              ),
              Fields.paddedActionText(
                S.current.iconAddRepositoryWithToken,
                icon: Icons.insert_link_rounded,
                onTap: () => addRepoWithTokenDialog(this.cubit),
              ),
            ]
          ),
        ); 
      }
    );
  }

  Widget _buildRepositoryList(List<String> repositories, String? current) => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: repositories.length,
    itemBuilder: (context, index) {

      final repositoryName = repositories[index];
      return Fields.paddedActionText(
        repositoryName,
        onTap: () {
          this.cubit.setCurrent(repositoryName);
          updateDefaultRepositorySetting(repositoryName);
          Navigator.of(context).pop();
        },
        // TODO: This doesn't actually say whether the repo is locked or not.
        icon: repositoryName == current
          ? Icons.lock_open_rounded
          : Icons.lock,
        textColor: repositoryName == current
          ? Colors.black
          : Colors.black54,
        textFontWeight: repositoryName == current
          ? FontWeight.bold
          : FontWeight.normal,
        iconColor: repositoryName == current
          ? Colors.black
          : Colors.black54);
    }
  );

  Future<void> updateDefaultRepositorySetting(repositoryName) async {
    final result = await Settings.saveSetting(Constants.currentRepositoryKey, repositoryName);
    loggy.app('Current repository updated to $repositoryName: $result');
  }

  void createRepoDialog(RepositoriesCubit cubit) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.titleCreateRepository,
          body: RepositoryCreation(
            context: context,
            cubit: cubit,
            formKey: formKey,
          ),
        );
      }
    ).then((newRepository) async => await updateSettingsAndPop(newRepository));
  }

  void addRepoWithTokenDialog(cubit) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();

        return ActionsDialog(
          title: S.current.titleAddRepository,
          body: AddRepositoryWithToken(
            context: context,
            cubit: cubit,
            formKey: formKey,
          ),
        );
      }
    ).then((addedRepository) async => await updateSettingsAndPop(addedRepository));
  }

  Future<void> updateSettingsAndPop(String repositoryName) async {
    // If a repository is successfuly created/added, the repository name is returned; otherwise, empty string.
    if (repositoryName.isEmpty) {
      return;
    }

    await updateDefaultRepositorySetting(repositoryName);
    Navigator.of(this.context).pop();
  }
}
