import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:Dialer/model/note.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath!, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    String query1 = '''
                  CREATE TABLE $tableNotes ( 
                  ${NoteFields.id} $idType, 
                  ${NoteFields.priority} $integerType,
                  ${NoteFields.domain}  $textType,
                  ${NoteFields.phone} $integerType,
                  ${NoteFields.title} $textType,
                  ${NoteFields.description} $textType,
                  ${NoteFields.agent} $textType,
                  ${NoteFields.call_type} $textType,
                  ${NoteFields.caller} $textType,
                  ${NoteFields.recording} $textType,
                  ${NoteFields.trkn} $textType,
                  ${NoteFields.time} $textType
                  )''';
    // print(query1);

    await db.execute(query1);
  }

  // Future<Note> create(Note note) async {
  //   final db = await instance.database;
  //   final id = await db.insert(tableNotes, note.toJson());
  //   return note.copy(id: id);
  // }

  Future<Note> create(Note note) async {
    final db = await instance.database;

    // Check if a record with the same ID already exists
    final existingNote = await getNoteById(note.id ?? -1);
    if (existingNote != null) {
      // Record with the same ID already exists
      // You can choose to handle this case based on your requirements
      // For example, throw an exception, return null, or update the existing record
      await update(note);
      return note.copy(id: note.id);
    } else {
      final id = await db.insert(tableNotes, note.toJson());
      return note.copy(id: id);
    }
  }

  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    final maps = await db.query(tableNotes,
        columns: null,
        where: '${NoteFields.id} = ?',
        whereArgs: [id],
        limit: 1);
    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<Note> readNote(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    // final orderBy = '${NoteFields.time} ASC';
    final result = await db.rawQuery('SELECT * FROM $tableNotes ORDER BY time');

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;
    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> clearData() async {
    final db = await instance.database;
    final result = await db.rawDelete('DELETE FROM $tableNotes');
  }

  Future<void> printTableSchema() async {
    final db = await instance.database;
    final schemaQuery = "PRAGMA table_info($tableNotes)";
    final result = await db.rawQuery(schemaQuery);

    print("Table Schema:");
    result.forEach((row) {
      final cid = row['cid'];
      final name = row['name'];
      final type = row['type'];
      final notNull = row['notnull'] == 1;
      final defaultValue = row['dflt_value'];

      print("Column $cid: $name ($type)");
      print("Not Null: $notNull");
      if (defaultValue != null) {
        print("Default Value: $defaultValue");
      }
      print("---");
    });
  }
}
