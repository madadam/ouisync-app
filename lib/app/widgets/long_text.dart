import 'package:flutter/material.dart';

/// Text that shows ellipsis on overflow but that has a tooltip with the full content.
class LongText extends StatelessWidget {
  final String text;

  LongText(this.text);

  @override
  Widget build(BuildContext context) => Tooltip(
        message: text,
        triggerMode: TooltipTriggerMode.tap,
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
        ),
      );
}
