import 'package:couchbase_lite/couchbase_lite.dart';

late Database db;

Future<void> initDatabase() async {
  db = await Database.initWithName('tasks_db');
}

Future<void> addTask(String title) async {
  final mutableDoc = MutableDocument(
    data: {'title': title, 'done': false},
  );
  await db.saveDocument(mutableDoc);
}

Future<List<Map<String, dynamic>>> getTasks() async {
  final query = QueryBuilder
      .select([
        SelectResult.all(),
        SelectResult.expression(Meta.id).as('id'),
      ])
      .from(db.name);

  final resultSet = await query.execute();

  return resultSet.allResults().map((r) {
    final map = r.toMap();
    final doc = Map<String, dynamic>.from(map[db.name] as Map? ?? {});
    doc['id'] = map['id'];
    return doc;
  }).toList();
}

Future<void> toggleTask(String id) async {
  final doc = await db.document(id);

  if (doc != null) {
    final mutable = doc.toMutable();
    mutable.setBoolean('done', !(doc.getBoolean('done') ?? false));
    await db.saveDocument(mutable);
  }
}

Future<void> deleteTask(String id) async {
  await db.deleteDocument(id);
}
