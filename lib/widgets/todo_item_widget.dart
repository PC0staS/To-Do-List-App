import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoItemWidget extends StatefulWidget {
  final Todo todo;
  final void Function(Todo)? onToggleComplete;
  final void Function(Todo)? onDelete;
  final Color? backgroundColor;
  final bool isNewlyAdded;
  final bool shouldFadeOut;
  final bool shouldFadeIn;

  const TodoItemWidget({
    super.key,
    required this.todo,
    this.onToggleComplete,
    this.onDelete,
    this.backgroundColor,
    this.isNewlyAdded = false,
    this.shouldFadeOut = false,
    this.shouldFadeIn = false,
  });

  @override
  State<TodoItemWidget> createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: widget.isNewlyAdded ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isNewlyAdded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    widget.onToggleComplete?.call(widget.todo);
  }

  void _handleDelete() {
    widget.onDelete?.call(widget.todo);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox personalizado
              GestureDetector(
                onTap: _handleToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.todo.isCompleted
                          ? Colors.green
                          : Colors.grey.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    color: widget.todo.isCompleted
                        ? Colors.green
                        : Colors.transparent,
                  ),
                  child: widget.todo.isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              
              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      widget.todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: widget.todo.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: widget.todo.isCompleted
                            ? Colors.grey.withValues(alpha: 0.6)
                            : Colors.black87,
                      ),
                    ),
                    
                    // Descripción
                    if (widget.todo.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.todo.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.todo.isCompleted
                              ? Colors.grey.withValues(alpha: 0.5)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Botón de eliminar para tareas completadas
              if (widget.todo.isCompleted)
                GestureDetector(
                  onTap: _handleDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}