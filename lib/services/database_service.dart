import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/todo.dart';

/// Servicio para manejar todas las operaciones de base de datos SQLite
/// para la aplicación de lista de tareas
class DatabaseService {
  // Instancia privada de la base de datos (patrón Singleton)
  static Database? _database;

  /// Getter para obtener la instancia de la base de datos
  /// Si no existe, la inicializa automáticamente
  static Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos SQLite
  /// Crea el archivo de base de datos y define la versión
  static Future<Database> _initDatabase() async {
    // Obtiene la ruta donde se guardará la base de datos
    String path = join(await getDatabasesPath(), 'todo_database.db');

    // Abre (o crea) la base de datos
    return await openDatabase(
      path,
      version: 2, // Versión actualizada para incluir dueDate
      onCreate: _onCreate, // Función que se ejecuta al crear la BD por primera vez
      onUpgrade: _onUpgrade, // Función para actualizar la BD existente
    );
  }

  /// Función que se ejecuta cuando se crea la base de datos por primera vez
  /// Define la estructura de la tabla 'todos'
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID único auto-incrementable
        title TEXT NOT NULL,                   -- Título de la tarea (obligatorio)
        description TEXT NOT NULL,             -- Descripción de la tarea (obligatorio)
        isCompleted INTEGER NOT NULL DEFAULT 0, -- Estado completado (0=false, 1=true)
        createdAt TEXT NOT NULL,               -- Fecha de creación
        dueDate TEXT                           -- Fecha límite (opcional)
      )
    ''');
  }

  /// Función que se ejecuta cuando se actualiza la base de datos
  /// Migra la base de datos existente a la nueva versión
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar el campo dueDate a la tabla existente
      await db.execute('ALTER TABLE todos ADD COLUMN dueDate TEXT');
    }
  }

  /// Inserta una nueva tarea en la base de datos
  /// Parámetro: objeto Todo con los datos de la tarea
  /// Retorna: ID de la tarea insertada
  static Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  /// Obtiene todas las tareas almacenadas en la base de datos
  /// Retorna: Lista de objetos Todo
  static Future<List<Todo>> getAllTodos() async {
    final db = await database;
    // Consulta todos los registros de la tabla 'todos'
    final List<Map<String, dynamic>> maps = await db.query('todos');

    // Convierte cada Map en un objeto Todo usando el factory constructor
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  /// Actualiza una tarea existente en la base de datos
  /// Parámetro: objeto Todo con los datos actualizados
  /// Retorna: número de filas afectadas (debería ser 1 si fue exitoso)
  static Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos', // Tabla a actualizar
      todo.toMap(), // Nuevos datos convertidos a Map
      where: 'id = ?', // Condición WHERE
      whereArgs: [todo.id], // Valor para reemplazar el '?' en WHERE
    );
  }

  /// Elimina una tarea de la base de datos
  /// Parámetro: ID de la tarea a eliminar
  /// Retorna: número de filas afectadas (debería ser 1 si fue exitoso)
  static Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos', // Tabla de la cual eliminar
      where: 'id = ?', // Condición WHERE
      whereArgs: [id], // Valor para reemplazar el '?' en WHERE
    );
  }

  /// Obtiene tareas para una fecha específica
  /// Parámetro: fecha específica (DateTime)
  /// Retorna: Lista de tareas que vencen en esa fecha
  static Future<List<Todo>> getTodosForDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0]; // Solo la fecha, sin hora

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'dueDate LIKE ?',
      whereArgs: ['$dateString%'],
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  /// Obtiene tareas vencidas (anteriores a hoy)
  /// Retorna: Lista de tareas vencidas
  static Future<List<Todo>> getOverdueTodos() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'dueDate < ? AND isCompleted = 0',
      whereArgs: [today],
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  /// Obtiene tareas sin fecha límite
  /// Retorna: Lista de tareas sin fecha límite
  static Future<List<Todo>> getTodosWithoutDueDate() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'dueDate IS NULL',
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  /// Obtiene tareas en un rango de fechas
  /// Parámetros: fecha de inicio y fecha de fin
  /// Retorna: Lista de tareas en el rango especificado
  static Future<List<Todo>> getTodosInDateRange(
      DateTime startDate, DateTime endDate) async {
    final db = await database;
    final startDateString = startDate.toIso8601String().split('T')[0];
    final endDateString = endDate.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'dueDate >= ? AND dueDate <= ?',
      whereArgs: [startDateString, endDateString],
      orderBy: 'dueDate ASC',
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }
}
