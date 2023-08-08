import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Dialer/model/note.dart';

class NoteCardWidget extends StatelessWidget {
  NoteCardWidget({
    Key? key,
    required this.note,
    required this.index,
  }) : super(key: key);

  final Note note;
  final int index;

  List<Icon> priorityIcons = [
    const Icon(
      Icons.check_circle_outline,
      color: Colors.grey,
      size: 24,
    ),
    const Icon(
      Icons.low_priority,
      color: Colors.lightGreen,
      size: 24,
    ),
    const Icon(
      Icons.flag,
      color: Colors.orange,
      size: 24,
    ),
    const Icon(
      Icons.crisis_alert,
      color: Colors.red,
      size: 24,
    ),
  ];

  Map<String, Icon> call_types = {
    "Missed": const Icon(
      Icons.call_missed_outgoing,
      color: Colors.red,
      size: 20,
    ),
    "Outgoing": const Icon(
      Icons.call_made,
      color: Colors.green,
      size: 20,
    ),
    "Incoming": const Icon(
      Icons.call_received,
      size: 20,
      color: Colors.blue,
    )
  };

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index

    // final time = DateFormat.yMMMd().format(note.createdTime);
    // print(note.createdTime);
    final time = DateFormat.yMMMd().add_jm().format(note.createdTime);
    return Card(
      color: Colors.lightGreen[100],
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 70),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade800),
                ),
                const SizedBox(height: 4),
                Text(
                  note.title,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      note.call_type == "Outgoing"
                          ? note.phone.toString()
                          : note.caller.toString(),
                      style:
                          TextStyle(color: Colors.grey.shade800, fontSize: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: call_types[note.call_type] ?? Icon(Icons.abc),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(top: 8, right: 8, child: priorityIcons[note.priority]),
        ],
      ),
    );
  }
}
