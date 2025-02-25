import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../utils/utils.dart';
import '../widgets.dart';

class DirectoryActions extends StatelessWidget with AppLogger {
  const DirectoryActions({
    required this.context,
    required this.cubit,
  });

  final BuildContext context;
  final RepoCubit cubit;

  @override
  Widget build(BuildContext context) => Container(
      padding: Dimensions.paddingBottomSheet,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Fields.bottomSheetHandle(context),
            Fields.bottomSheetTitle(S.current.titleFolderActions),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildAction(
                  name: S.current.actionNewFolder,
                  icon: Icons.create_new_folder_outlined,
                  action: () => createFolderDialog(context, cubit)),
              _buildAction(
                  name: S.current.actionNewFile,
                  icon: Icons.upload_file_outlined,
                  action: () async => await addFile(context, cubit))
            ])
          ]));

  Widget _buildAction({name, icon, action}) => Padding(
      padding: Dimensions.paddingBottomSheetActions,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: action,
          child: Column(children: [
            Icon(
              icon,
              size: Dimensions.sizeIconBig,
            ),
            Dimensions.spacingVertical,
            Text(name, style: const TextStyle(fontSize: Dimensions.fontSmall))
          ])));

  void createFolderDialog(context, RepoCubit cubit) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();

          return ActionsDialog(
            title: S.current.titleCreateFolder,
            body: FolderCreation(
              context: context,
              cubit: cubit,
              formKey: formKey,
            ),
          );
        }).then((newFolder) => {
          if (newFolder.isNotEmpty)
            {
              // If a folder is created, the new folder is returned path; otherwise, empty string.
              Navigator.of(this.context).pop()
            }
        });
  }

  Future<void> addFile(context, RepoCubit repo) async {
    final permissionName = S.current.messageStorage;
    final permissionGranted =
        await _checkPermission(Permission.storage, permissionName);

    if (!permissionGranted) return;

    final dstDir = repo.state.currentFolder.path;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withReadStream: true,
      allowMultiple: true,
    );

    if (result != null) {
      Navigator.of(context).pop();

      for (final srcFile in result.files) {
        String fileName = srcFile.name;
        String dstPath = buildDestinationPath(dstDir, fileName);

        if (await repo.exists(dstPath)) {
          final action = await showDialog<FileAction>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: Text(S.current.titleAddFile),
                  content: ReplaceFile(context: context, fileName: fileName)));

          if (action == null) {
            return;
          }

          if (action == FileAction.replace) {
            await repo.replaceFile(
              filePath: dstPath,
              length: srcFile.size,
              fileByteStream: srcFile.readStream!,
            );

            return;
          }

          fileName = await _renameFile(dstPath, 0);
          dstPath = buildDestinationPath(dstDir, fileName);
        }

        await repo.saveFile(
          filePath: dstPath,
          length: srcFile.size,
          fileByteStream: srcFile.readStream!,
        );
      }
    }
  }

  Future<String> _renameFile(String dstPath, int versions) async {
    final name = p.basenameWithoutExtension(dstPath);
    final extension = p.extension(dstPath);

    final newFileName = '$name (${versions += 1})$extension';

    if (await cubit.exists(newFileName)) {
      return await _renameFile(dstPath, versions);
    }

    return newFileName;
  }

  Future<bool> _checkPermission(
      Permission permission, String permissionName) async {
    final result = await Permissions.requestPermission(
        context, permission, permissionName);

    if (result.status != PermissionStatus.granted) {
      loggy.app(result.resultMessage);
      return false;
    }

    return true;
  }
}
