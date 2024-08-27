import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LoadingIndicator extends StatelessWidget {
  Color? color;
  LoadingIndicator({Key? key, this.color = Colors.black}) : super(key: key);

  /// Returns the appropriate "loading indicator" icon for the given `platform`.
  Widget _getIndicatorWidget(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoActivityIndicator(
          color: color,
        );
      case TargetPlatform.android:
      // return CircularProgressIndicator(
      //   color: color,
      // );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      default:
        return CupertinoActivityIndicator(
          color: color,
        );
    }
  }

  @override
  Widget build(BuildContext context) =>
      _getIndicatorWidget(Theme.of(context).platform);
}
