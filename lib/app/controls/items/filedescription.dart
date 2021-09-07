import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../models/models.dart';
import '../../utils/utils.dart';

class FileDescription extends StatelessWidget {
  const FileDescription({
    required this.fileData,
  });

  final BaseItem fileData;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  _getUI(),
      ),
    );
  }

  List<Widget> _getUI() {
    return [
      Text(
        this.fileData.name,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
        ),
      ),
      const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
      Text(
        "${formattSize(this.fileData.size.toInt(), units: true)}",
        style: const TextStyle(fontSize: 14.0),
      ),
    ];
  }
}