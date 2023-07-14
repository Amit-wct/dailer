final String tableNotes = 'notes';

class NoteFields {
  static final List<String> values = [
    /// Add all fields
    id, isImportant, number, phone, title, description, time, agent
  ];

  static final String id = '_id';
  static final String isImportant = 'isImportant';
  static final String number = 'number';
  static final String phone = 'phone';
  static final String title = 'title';
  static final String description = 'description';
  static final String agent = 'agent';
  static final String time = 'time';
}

class Note {
  final int? id;
  final bool isImportant;
  final int number;
  final int phone;
  final String title;
  final String description;
  final String agent;
  final DateTime createdTime;

  const Note({
    this.id,
    required this.isImportant,
    required this.number,
    required this.phone,
    required this.title,
    required this.description,
    required this.agent,
    required this.createdTime,
  });

  Note copy({
    int? id,
    bool? isImportant,
    int? number,
    int? phone,
    String? title,
    String? description,
    String? agent,
    DateTime? createdTime,
  }) =>
      Note(
        id: id ?? this.id,
        isImportant: isImportant ?? this.isImportant,
        number: number ?? this.number,
        phone: phone ?? this.phone,
        title: title ?? this.title,
        description: description ?? this.description,
        agent: agent ?? this.agent,
        createdTime: createdTime ?? this.createdTime,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[NoteFields.id] as int?,
        isImportant: json[NoteFields.isImportant] == 1,
        number: json[NoteFields.number] as int,
        phone: json[NoteFields.phone] as int,
        title: json[NoteFields.title] as String,
        description: json[NoteFields.description] as String,
        agent: json[NoteFields.agent] as String,
        createdTime: DateTime.parse(json[NoteFields.time] as String),
      );

  Map<String, Object?> toJson() => {
        NoteFields.id: id,
        NoteFields.title: title,
        NoteFields.isImportant: isImportant ? 1 : 0,
        NoteFields.number: number,
        NoteFields.phone: phone,
        NoteFields.description: description,
        NoteFields.agent: agent,
        NoteFields.time: createdTime.toIso8601String(),
      };
}
