import 'package:flutter/material.dart';

Widget InputFieldMaker(String textLabel, TextEditingController controller_obj,
    TextInputType keyboardType, FocusNode focusNode) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
    child: TextField(
      focusNode: focusNode,
      controller: controller_obj,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: textLabel,
      ),
    ),
  );
}
