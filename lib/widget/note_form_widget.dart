import 'package:flutter/material.dart';

class NoteFormWidget extends StatelessWidget {
  final String? domain;
  final int? priority;
  final String? title;
  final String? description;
  final ValueChanged<int> onChangedNumber;
  final ValueChanged<String> onChangedTitle;
  final ValueChanged<String> onChangedDescription;

  const NoteFormWidget({
    Key? key,
    this.domain = '',
    this.priority = 0,
    this.title = '',
    this.description = '',
    required this.onChangedNumber,
    required this.onChangedTitle,
    required this.onChangedDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    "Priority",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: (priority ?? 0).toDouble(),
                      min: 0,
                      max: 3,
                      divisions: 3,
                      onChanged: (number) => onChangedNumber(number.toInt()),
                      activeColor: Colors.lightGreen, // Change the active color
                      inactiveColor: Colors.grey, // Change the inactive color
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              buildTitle(),
              SizedBox(height: 16),
              buildDescription(),
              SizedBox(height: 16),
            ],
          ),
        ),
      );

  Widget buildTitle() => TextFormField(
        maxLines: 1,
        initialValue: title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(), // Add a border to the input field
          labelText: 'Title', // Replace hintText with labelText
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.lightGreen, // Change the label color
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.lightGreen, // Change the focused border color
              width: 2, // Adjust the focused border width
            ),
          ),
        ),
        validator: (title) =>
            title != null && title.isEmpty ? 'The title cannot be empty' : null,
        onChanged: onChangedTitle,
      );

  Widget buildDescription() => TextFormField(
        maxLines: 5,
        initialValue: description,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          border: OutlineInputBorder(), // Add a border to the input field
          labelText: 'Description', // Replace hintText with labelText
          labelStyle: TextStyle(
            fontSize: 16,
            color: Colors.lightGreen, // Change the label color
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.lightGreen, // Change the focused border color
              width: 2, // Adjust the focused border width
            ),
          ),
        ),
        validator: (description) => description != null && description.isEmpty
            ? 'The description cannot be empty'
            : null,
        onChanged: onChangedDescription,
      );
}
