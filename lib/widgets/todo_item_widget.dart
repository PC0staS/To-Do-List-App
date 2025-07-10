import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoItemWidget extends StatefulWidget {
  final Todo todo;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final bool showDeleteButton;
  final bool shouldFadeOut;
  final bool shouldFadeIn;
  final bool isPinned;

  const TodoItemWidget({
    super.key,
    required this.todo,
    this.onToggle,
    this.onDelete,
    this.onPin,
    this.showDeleteButton = false,
    this.shouldFadeOut = false,
    this.shouldFadeIn = false,
    this.isPinned = false,
  });

  @override
  State<TodoItemWidget> createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Configurar animación basada en el tipo
    if (widget.shouldFadeIn) {
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
      );
      _animationController.forward();
    } else if (widget.shouldFadeOut) {
      _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
      );
      _animationController.forward();
    } else {
      _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_animationController);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    widget.onToggle?.call();
  }

  void _handleDelete() {
    widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox circular
                GestureDetector(
                  onTap: _handleToggle,
                  child: TweenAnimationBuilder<Color?>(
                    duration: const Duration(milliseconds: 200),
                    tween: ColorTween(
                      begin: widget.todo.isCompleted ? Colors.white : Colors.black,
                      end: widget.todo.isCompleted ? Colors.black : Colors.white,
                    ),
                    builder: (context, color, child) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.todo.isCompleted ? Colors.black : Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: widget.todo.isCompleted ? 1.0 : 0.0,
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Texto de la tarea
                Expanded(
                  child: TweenAnimationBuilder<Color?>(
                    duration: const Duration(milliseconds: 200),
                    tween: ColorTween(
                      begin: widget.todo.isCompleted ? Colors.black : Colors.grey,
                      end: widget.todo.isCompleted ? Colors.grey : Colors.black,
                    ),
                    builder: (context, color, child) {
                      return AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 20,
                          color: color ?? Colors.black,
                          fontWeight: FontWeight.w400,
                          decoration: widget.todo.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                        child: Text(widget.todo.title),
                      );
                    },
                  ),
                ),
                
                // Botón de pin (solo se muestra en tareas no completadas)
                if (!widget.todo.isCompleted && widget.onPin != null)
                  IconButton(
                    icon: Icon(
                      widget.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: widget.isPinned ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    onPressed: widget.onPin,
                    visualDensity: VisualDensity.compact,
                  ),
                
                // Botón de eliminar (solo se muestra cuando showDeleteButton es true)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: widget.showDeleteButton ? 48 : 0,
                  child: widget.showDeleteButton
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: _handleDelete,
                          visualDensity: VisualDensity.compact,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}