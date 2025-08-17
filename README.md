# 📝 Todo List App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

**Una aplicación de lista de tareas moderna y elegante construida con Flutter**

*Organiza tu vida con estilo y funcionalidad avanzada*

</div>

---

## ✨ Características Principales

### 🎯 **Gestión de Tareas Inteligente**
- ➕ **Agregar tareas** con título, descripción y fecha de vencimiento
- ✅ **Marcar como completadas** con animaciones suaves
- 🗑️ **Eliminar tareas** solo desde la sección "Terminadas"
- 📅 **Organización automática** por día (Hoy, Mañana, Más tarde)

### 📱 **Notificaciones Avanzadas**
- 📌 **Pin de tareas** como notificaciones persistentes en Android
- 🍎 **Live Activities** en iOS (próximamente)
- 🔔 **Notificaciones locales** con canal personalizado
- ⚡ **Gestión inteligente** de notificaciones por tarea

### 🎨 **Interfaz de Usuario Moderna**
- 🌟 **Diseño minimalista** con colores elegantes
- ✨ **Animaciones fluidas** para agregar/eliminar tareas
- 📱 **Responsive design** optimizado para móviles
- 🎭 **Feedback visual** con SnackBars informativos

### 💾 **Persistencia de Datos**
- 🗄️ **Base de datos SQLite** local
- 🔄 **Sincronización automática** de estado
- 💪 **Manejo robusto** de errores
- 🚀 **Rendimiento optimizado**

---

## 🛠️ Tecnologías Utilizadas

| Tecnología | Propósito |
|------------|-----------|
| **Flutter** | Framework de desarrollo multiplataforma |
| **Dart** | Lenguaje de programación |
| **SQLite** | Base de datos local |
| **flutter_local_notifications** | Sistema de notificaciones |
| **sqflite** | Plugin de SQLite para Flutter |
| **path** | Manejo de rutas del sistema |

---

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Android Studio / VS Code
- Emulador Android o dispositivo físico

### 1. **Clonar el repositorio**
```bash
git clone https://github.com/PC0staS/To-Do-List-App.git
cd todo_list
```

### 2. **Instalar dependencias**
```bash
flutter pub get
```

### 3. **Configurar el entorno**
```bash
# Verificar la instalación de Flutter
flutter doctor

# Listar dispositivos disponibles
flutter devices
```

### 4. **Ejecutar la aplicación**
```bash
# Modo debug
flutter run

# Modo release
flutter run --release

# Dispositivo específico
flutter run -d <device_id>
```

---

## 📱 Uso de la Aplicación

### **Pantalla Principal**
- 👀 **Vista general** de todas tus tareas organizadas por fecha
- ➕ **Botón flotante** para agregar nuevas tareas
- 🔔 **Botón de prueba** para probar notificaciones

### **Agregar Nueva Tarea**
1. Presiona el botón **+** en la esquina superior derecha
2. Completa el **título** (obligatorio)
3. Agrega una **descripción** (opcional)
4. Selecciona la **fecha de vencimiento**
5. Presiona **"Agregar Tarea"**

### **Gestionar Tareas**
- **Marcar como completada**: Toca el círculo a la izquierda
- **Fijar notificación**: Presiona el ícono de pin 📌
- **Eliminar**: Solo disponible para tareas completadas

### **Funciones Avanzadas**
- 🧪 **Probar notificaciones**: Botón en la barra superior
- 📌 **Pin/Unpin tareas**: Notificaciones persistentes
- ✨ **Animaciones automáticas**: Al agregar/eliminar tareas

---

## 🏗️ Arquitectura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── models/
│   └── todo.dart               # Modelo de datos Todo
├── screens/
│   ├── main_screen.dart        # Pantalla principal
│   └── add_todo.dart          # Pantalla para agregar tareas
├── services/
│   ├── database_service.dart   # Servicio de base de datos SQLite
│   └── notification_service.dart # Servicio de notificaciones
└── widgets/
    ├── todo_item_widget.dart   # Widget individual de tarea
    ├── todo_list_view.dart     # Vista de lista de tareas
    └── todo_section_header.dart # Encabezados de sección
```

### **Patrones de Diseño Implementados**
- 🏛️ **Arquitectura por capas** (UI → Services → Data)
- 🔄 **Estado centralizado** con StatefulWidget
- 📦 **Inyección de dependencias** para servicios
- 🎯 **Separación de responsabilidades**

---

## 🎨 Paleta de Colores

| Color | Hex | Uso |
|-------|-----|-----|
| **Fondo Principal** | `#FAF9F9` | Background general |
| **Blanco Cards** | `#FFFFFF` | Tarjetas de tareas |
| **Verde Éxito** | `#4CAF50` | Confirmaciones |
| **Naranja Advertencia** | `#FF9800` | Advertencias |
| **Rojo Error** | `#F44336` | Errores |
| **Azul Acción** | `#2196F3` | Botones de acción |

---

## 📊 Funcionalidades Detalladas

### **Sistema de Notificaciones**

#### Android
```dart
// Notificación persistente con canal personalizado
await NotificationService.pinTodoToNotification(todo);
```

#### iOS (Próximamente)
```dart
// Live Activities para tareas importantes
await NotificationService.startLiveActivity(todo);
```

### **Base de Datos SQLite**

#### Esquema de Tabla
```sql
CREATE TABLE todos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  createdAt TEXT NOT NULL,
  dueDate TEXT
);
```

#### Operaciones CRUD
- **Create**: `insertTodo(Todo todo)`
- **Read**: `getAllTodos()`, `getTodoById(int id)`
- **Update**: `updateTodo(Todo todo)`
- **Delete**: `deleteTodo(int id)`

---

## 🚨 Manejo de Errores

La aplicación incluye manejo robusto de errores:

```dart
try {
  await DatabaseService.insertTodo(todo);
  // Operación exitosa
} catch (e) {
  // Mostrar error al usuario
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${e.toString()}')),
  );
}
```

---

## 🧪 Testing y Desarrollo

### **Comandos Útiles**
```bash
# Análisis de código
flutter analyze

# Formatear código
flutter format .

# Limpiar proyecto
flutter clean && flutter pub get

# Generar APK
flutter build apk --release

# Instalar en dispositivo
flutter install
```

### **Debug y Logs**
- 🔍 **Logs detallados** en consola para debugging
- 📱 **Hot reload** para desarrollo rápido
- 🐛 **Error boundaries** para recuperación graceful

---

## 📈 Roadmap Futuro

### **Versión 2.0**
- [ ] 🔐 **Autenticación de usuario**
- [ ] ☁️ **Sincronización en la nube**
- [ ] 🎨 **Temas personalizables**
- [ ] 📊 **Estadísticas de productividad**

### **Versión 2.1**
- [ ] 🏷️ **Etiquetas y categorías**
- [ ] 🔔 **Recordatorios avanzados**
- [ ] 📱 **Widget de pantalla de inicio**
- [ ] 🌐 **Soporte para múltiples idiomas**

---

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! 

### **Cómo contribuir:**
1. **Fork** el proyecto
2. Crea una **rama feature** (`git checkout -b feature/nueva-caracteristica`)
3. **Commit** tus cambios (`git commit -m 'Agregar nueva característica'`)
4. **Push** a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un **Pull Request**

### **Tipos de contribuciones:**
- 🐛 **Bug fixes**
- ✨ **Nuevas características**
- 📚 **Documentación**
- 🎨 **Mejoras de UI/UX**
- ⚡ **Optimizaciones de rendimiento**

---

## 📝 Changelog

### **v1.0.0** (Actual)
- ✅ Funcionalidades básicas de TODO
- ✅ Notificaciones persistentes Android
- ✅ Interfaz de usuario moderna
- ✅ Base de datos SQLite
- ✅ Animaciones fluidas

---

## 📄 Licencia

Este proyecto está licenciado bajo la **MIT License**.

```
Copyright (c) 2025 PC0staS

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software...
```

---

## 📞 Contacto y Soporte

<div align="center">

**¿Encontraste un bug? ¿Tienes una sugerencia?**

[![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-red?style=for-the-badge&logo=github)](https://github.com/PC0staS/To-Do-List-App/issues)
[![GitHub Discussions](https://img.shields.io/badge/GitHub-Discussions-blue?style=for-the-badge&logo=github)](https://github.com/PC0staS/To-Do-List-App/discussions)

</div>

---

<div align="center">

**⭐ Si te gusta este proyecto, ¡dale una estrella! ⭐**

*Hecho con ❤️ y Flutter*

</div>
