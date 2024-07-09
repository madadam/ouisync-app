import 'package:flutter/material.dart';
import 'package:ouisync_app/app/widgets/holder.dart';
import 'package:ouisync_app/app/widgets/repo_creation.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart';
import '../cubits/repo_creation.dart';

class RepoCreationPage extends StatelessWidget {
  RepoCreationPage({
    super.key,
    required this.reposCubit,
    this.token,
  });

  final ReposCubit reposCubit;
  final ShareToken? token;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(S.current.titleCreateRepository),
          elevation: 0.0,
        ),
        body: BlocHolder(
          create: () =>
              RepoCreationCubit(reposCubit: reposCubit)..setToken(token),
          builder: (context, cubit) => RepoCreation(cubit),
        ),
      );
}
