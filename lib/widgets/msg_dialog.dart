import 'package:flutter/material.dart';

Future<void> alertDialog(BuildContext context, String title, String alert,
    {onSubmit, cancellable = true}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(alert),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(Duration.zero, onSubmit);
            },
          ),
          cancellable
              ? ElevatedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              : const SizedBox.shrink(),
        ],
      );
    },
  );
}
