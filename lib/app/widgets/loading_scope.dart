import 'package:flutter/material.dart';

/// Shows loading indicator when async operations are running.
///
/// ```dart
/// class ExampleApp extends StatelessWidget {
///     @override
///     Widget build(BuildContext context) => LoadingScope(
///         child: ExamplePage()
///     );
/// }
///
/// class ExamplePage extends StatelessWidget {
///     @override
///     Widget build(BuildContext context) => TextButton(
///         child: Text('Load'),
///         onPressed: () {
///             unawaited(LoadingScope.run(load));
///         }
///     );
///
///     Future<void> load() async {
///         await Future.delayed(Duration(seconds: 1));
///     }
/// }
/// ```
///
class LoadingScope extends StatefulWidget {
  const LoadingScope({required this.child, this.loadingWidget, super.key});

  /// The widget bellow this widget in the tree.
  final Widget child;

  /// Custom loading widget (use default if null).
  final Widget? loadingWidget;

  @override
  State<LoadingScope> createState() => _State();

  /// Shows loading indicator while the given future is being executed.
  static Future<T> run<T>(BuildContext context, Future<T> future) async {
    final state = context.findAncestorStateOfType<_State>();

    if (state != null) {
      return await state.run(future);
    } else {
      return await future;
    }
  }
}

class _State extends State<LoadingScope> {
  // Number of currently running async operations. If this is greater than zero, the loading
  // indicator is shown.
  int loadingCount = 0;

  @override
  Widget build(BuildContext context) => loadingCount > 0
      ? Stack(
          children: [
            widget.child,
            widget.loadingWidget ??
                Center(child: const CircularProgressIndicator.adaptive()),
          ],
        )
      : widget.child;

  Future<T> run<T>(Future<T> future) async {
    setState(() {
      ++loadingCount;
    });

    try {
      return await future;
    } finally {
      setState(() {
        --loadingCount;
      });
    }
  }
}
