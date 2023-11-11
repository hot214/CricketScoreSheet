import 'package:flutter/material.dart';

Future<void> inputDialog(
    BuildContext context, String title, String hint, String value,
    {onSubmit}) async {
  var controller = TextEditingController(text: value);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          onChanged: (value) {},
          decoration: InputDecoration(hintText: hint),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () {
              Navigator.of(context).pop();
              onSubmit(controller.text);
            },
          ),
        ],
      );
    },
  );
}
