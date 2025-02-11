final String tableNotes = 'notes';

class NoteFields {
  static final List<String> values = [
    /// Add all fields
    id, priority, domain, phone, title, description, time, agent, call_type,
    trkn, recording, caller
  ];

  static final String id = '_id';
  static final String priority = 'priority';
  static final String domain = 'domain';
  static final String phone = 'phone';
  static final String title = 'title';
  static final String description = 'description';
  static final String agent = 'agent';
  static final String time = 'time';
  static final String call_type = 'call_type';
  static final String caller = 'caller';
  static final String recording = 'recording';
  static final String trkn = 'trkn';
}

class Note {
  final int? id;
  final int priority;
  final String domain;
  final int phone;
  final String title;
  final String description;
  final String agent;
  final String call_type;
  final String caller;
  final String recording;
  final String trkn;

  final DateTime createdTime;

  const Note({
    this.id,
    required this.priority,
    required this.domain,
    required this.phone,
    required this.title,
    required this.description,
    required this.agent,
    required this.createdTime,
    required this.call_type,
    required this.caller,
    required this.recording,
    required this.trkn,
  });

  Note copy({
    int? id,
    int? priority,
    String? domain,
    int? phone,
    String? title,
    String? description,
    String? agent,
    String? call_type,
    String? caller,
    String? recording,
    String? trkn,
    DateTime? createdTime,
  }) =>
      Note(
        id: id ?? this.id,
        priority: priority ?? this.priority,
        domain: domain ?? this.domain,
        phone: phone ?? this.phone,
        title: title ?? this.title,
        description: description ?? this.description,
        agent: agent ?? this.agent,
        call_type: call_type ?? this.call_type,
        caller: caller ?? this.caller,
        recording: recording ?? this.recording,
        trkn: trkn ?? this.trkn,
        createdTime: createdTime ?? this.createdTime,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[NoteFields.id] as int?,
        priority: json[NoteFields.priority] as int,
        domain: json[NoteFields.domain] as String,
        phone: json[NoteFields.phone] as int,
        title: json[NoteFields.title] as String,
        description: json[NoteFields.description] as String,
        agent: json[NoteFields.agent] as String,
        call_type: json[NoteFields.call_type] as String,
        caller: json[NoteFields.caller] as String,
        recording: json[NoteFields.recording] as String,
        trkn: json[NoteFields.trkn] as String,
        createdTime: DateTime.parse(json[NoteFields.time] as String),
      );

  Map<String, Object?> toJson() => {
        NoteFields.id: id,
        NoteFields.title: title,
        NoteFields.priority: priority,
        NoteFields.domain: domain,
        NoteFields.phone: phone,
        NoteFields.description: description,
        NoteFields.agent: agent,
        NoteFields.call_type: call_type,
        NoteFields.caller: caller,
        NoteFields.recording: recording,
        NoteFields.trkn: trkn,
        NoteFields.time: createdTime.toIso8601String(),
      };
}
