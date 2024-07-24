import 'package:camion/Localization/app_localizations.dart';
import 'package:flutter/material.dart';

class ErrorIndicator extends StatelessWidget {
  final VoidCallback onRetry;

  const ErrorIndicator({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onRetry,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('loading_error'),
              style: const TextStyle(color: Colors.red),
            ),
            const Icon(Icons.refresh, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
