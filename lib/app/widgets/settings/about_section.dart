import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/platform/platform.dart';
import '../../utils/utils.dart';
import 'app_version_tile.dart';
import 'settings_section.dart';
import 'settings_tile.dart';

class AboutSection extends SettingsSection with AppLogger {
  AboutSection(this._cubits) : super(title: S.current.titleAbout);

  final Cubits _cubits;

  @override
  List<Widget> buildTiles(BuildContext context) => [
        NavigationTile(
            title: Text(S.current.titleFAQShort),
            leading: Icon(Icons.question_answer_rounded),
            trailing:
                PlatformValues.isDesktopDevice ? _externalNavigationIcon : null,
            value: Text(S.current.messageFAQ),
            onTap: () => unawaited(_openFaq(context))),
        if (PlatformValues.isMobileDevice)
          NavigationTile(
            title: Text(S.current.titleSendFeedback),
            leading: Icon(Icons.comment),
            onTap: () => unawaited(_openFeedback(context)),
          ),
        NavigationTile(
          title: Text(Constants.ouisyncUrl),
          // Icons.language is actually a stylized globe icon which is a good fit here:
          leading: Icon(Icons.language),
          trailing: _externalNavigationIcon,
          onTap: () => unawaited(launchUrl(Uri.parse(Constants.ouisyncUrl))),
        ),
        NavigationTile(
          title: Text(Constants.supportEmail),
          leading: Icon(Icons.mail),
          trailing: _externalNavigationIcon,
          onTap: () => unawaited(
              launchUrl(Uri.parse('mailto:${Constants.supportEmail}'))),
        ),
        NavigationTile(
          title: Text(S.current.titleIssueTracker),
          leading: Icon(Icons.bug_report),
          trailing: _externalNavigationIcon,
          onTap: () =>
              unawaited(launchUrl(Uri.parse(Constants.issueTrackerUrl))),
        ),
        AppVersionTile(
          session: _cubits.repositories.session,
          leading: Icon(Icons.info_outline),
          title: Text(S.current.labelAppVersion),
        ),
        SettingsTile(
          title: Text(S.current.messageSettingsRuntimeID),
          leading: Icon(Icons.person),
          value: _getRuntimeIdForOS(),
        ),
      ];

  @override
  bool containsErrorNotification() {
    return _cubits.upgradeExists.state;
  }

  Future<void> _openFaq(BuildContext context) async {
    final webView = PlatformWebView();

    if (PlatformValues.isMobileDevice) {
      final title = Text(S.current.titleFAQShort);
      final content = await Dialogs.executeFutureWithLoadingDialog(context,
          f: webView.loadUrl(context, Constants.faqUrl));

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  WebViewPage(title: title, content: content)));
    } else {
      await webView.launchUrl(Constants.faqUrl);
    }
  }

  Future<void> _openFeedback(BuildContext context) async {
    final attachments = await showDialog<FeedbackAttachments>(
      context: context,
      builder: (context) => FeedbackDialog(),
    );

    if (attachments == null) {
      return;
    }

    if (attachments.logs) {
      final logs = await Dialogs.executeFutureWithLoadingDialog(
        context,
        f: dumpAll(
          context,
          _cubits.repositories.rootStateMonitor,
          compress: true,
        ),
      );

      try {
        await _sendFeedback(logs);
      } finally {
        await logs.delete();
      }
    } else {
      await _sendFeedback(null);
    }
  }

  Future<void> _sendFeedback(File? logs) async {
    final email = Email(
      recipients: const [Constants.supportEmail],
      attachmentPaths: [if (logs != null) logs.path],
    );

    if (logs != null) {
      final name = basename(logs.path);
      final size = formatSize(await logs.length(), units: true);

      loggy.debug('Sending feedback email with attachment: $name, $size');
    } else {
      loggy.debug('Sending feedback email without attachments');
    }

    await FlutterEmailSender.send(email);
  }

  Widget _getRuntimeIdForOS() => FutureBuilder(
      future: _cubits.repositories.session.thisRuntimeId,
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

const _externalNavigationIcon = Icon(Icons.open_in_browser);

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog();

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  FeedbackAttachments attachments = FeedbackAttachments(logs: true);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Go to the mail app'), // TODO: localize
        content: CheckboxListTile(
          title: Text(S.current.labelAttachLogs),
          value: attachments.logs,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                attachments = FeedbackAttachments(logs: value);
              });
            }
          },
        ),
        actions: [
          TextButton(
            child: Text(S.current.actionOK),
            onPressed: () {
              Navigator.of(context).pop(attachments);
            },
          ),
          TextButton(
            child: Text(S.current.actionCancel),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
        ],
      );
}

class FeedbackAttachments {
  final bool logs;

  const FeedbackAttachments({required this.logs});
}
