import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show RepoCubit;
import '../widgets/widgets.dart'
    show ActionsDialog, NegativeButton, PositiveButton;
import 'utils.dart'
    show AppThemeExtension, Dimensions, Fields, Strings, ThemeGetter;

abstract class Dialogs {
  static Future<bool?> alertDialogWithActions({
    required BuildContext context,
    required String title,
    required List<Widget> body,
    required List<Widget> actions,
  }) =>
      showDialog<bool?>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _alertDialog(context, title, body, actions);
          });

  static Future<bool?> simpleAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    List<Widget>? actions,
  }) =>
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _alertDialog(
            context,
            title,
            [Text(message)],
            actions ??
                [
                  TextButton(
                    child: Text(S.current.actionCloseCapital),
                    onPressed: () async => await Navigator.of(
                      context,
                      rootNavigator: true,
                    ).maybePop(false),
                  ),
                ],
          );
        },
      );

  static actionDialog(
          BuildContext context, String dialogTitle, Widget? actionBody) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ActionsDialog(
              title: dialogTitle,
              body: actionBody,
            );
          });

  static AlertDialog _alertDialog(BuildContext context, String title,
          List<Widget> body, List<Widget> actions) =>
      AlertDialog(
          title: Flex(direction: Axis.horizontal, children: [
            Fields.constrainedText(title,
                style: context.theme.appTextStyle.titleMedium, maxLines: 2)
          ]),
          content: SingleChildScrollView(child: ListBody(children: body)),
          actions: actions);

  static Future<String?> deleteFileAlertDialog(RepoCubit repo, String path,
      BuildContext context, String fileName, String parent) async {
    final bodyStyle = context.theme.appTextStyle.bodyMedium
        .copyWith(fontWeight: FontWeight.bold);

    return showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ActionsDialog(
            title: S.current.titleDeleteFile,
            body: ListBody(children: <Widget>[
              Text(fileName, style: bodyStyle),
              Row(children: [
                Text(Strings.atSymbol, style: bodyStyle),
                Text(parent, style: bodyStyle)
              ]),
              const SizedBox(height: 20.0),
              Text(S.current.messageConfirmFileDeletion),
              Fields.dialogActions(buttons: [
                NegativeButton(
                    text: S.current.actionCancel,
                    onPressed: () async =>
                        await Navigator.of(context, rootNavigator: true)
                            .maybePop(),
                    buttonsAspectRatio:
                        Dimensions.aspectRatioModalDialogButton),
                PositiveButton(
                    text: S.current.actionDelete,
                    isDangerButton: true,
                    onPressed: () async {
                      await repo.deleteFile(path);
                      await Navigator.of(context).maybePop(fileName);
                    },
                    buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton)
              ])
            ])));
  }

  static Future<bool?> deleteFolderAlertDialog(BuildContext context,
          RepoCubit repo, String path, String validationMessage) async =>
      showDialog<bool?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ActionsDialog(
          title: S.current.titleDeleteFolder,
          body: ListBody(
            children: <Widget>[
              Text(
                path,
                style: context.theme.appTextStyle.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              Text(validationMessage),
              Fields.dialogActions(
                buttons: [
                  NegativeButton(
                    text: S.current.actionCancel,
                    onPressed: () async =>
                        await Navigator.of(context, rootNavigator: true)
                            .maybePop(false),
                    buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
                  ),
                  PositiveButton(
                    text: S.current.actionDelete,
                    isDangerButton: true,
                    onPressed: () async =>
                        await Navigator.of(context, rootNavigator: true)
                            .maybePop(true),
                    buttonsAspectRatio: Dimensions.aspectRatioModalDialogButton,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
