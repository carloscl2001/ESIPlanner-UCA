import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectSubjectsHomeWidgets {
  static Widget buildDegreeDropdown({
    required BuildContext context,
    required List<String> availableDegrees,
    required Function(String) onDegreeSelected,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Text(
            'Seleccionar Grado',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ), 
          SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {}, // Feedback táctil (opcional)
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                dropdownColor: isDarkMode ? Colors.black : Colors.white,
                icon: Icon(Icons.arrow_drop_down, color: isDarkMode? Colors.yellow.shade700 : Colors.indigo),
                iconSize: 28,
                decoration: InputDecoration(
                  labelText: 'Seleccionar grado',
                  labelStyle: TextStyle(
                    color: isDarkMode ? Colors.yellow.shade700 : Colors.black,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.school_rounded, color: isDarkMode? Colors.yellow.shade700 : Colors.indigo),
                ),
                items: availableDegrees.map((degree) {
                  return DropdownMenuItem(
                    value: degree,
                    child: Text(
                      degree,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (degree) {
                  if (degree != null) {
                    onDegreeSelected(degree);
                    // Feedback de selección (opcional)
                    HapticFeedback.lightImpact();
                  }
                },
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSelectedSubjectCard({
    required BuildContext context,
    required String code,
    required String name,
    required String degree,
    required bool hasGroupsSelected,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // Puedes añadir funcionalidad si es necesario
        child: Padding(
          padding: const EdgeInsets.only(top:10, bottom: 10, left: 14, right: 2),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$code • $degree',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          hasGroupsSelected ? Icons.check_circle : Icons.warning,
                          color: hasGroupsSelected 
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasGroupsSelected 
                              ? 'Grupos asignados' 
                              : 'No hay grupos asignados',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: hasGroupsSelected
                                ? Colors.green
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildEmptySelectionCard(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school_rounded,
                size: 64,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Selecciona asignaturas de algún grado',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildManageGroupsButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required bool hasSelectedSubjects,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: isDarkMode
            ? null // En modo oscuro, sin gradiente (fondo amarillo)
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.shade900,
                    Colors.blue.shade900,
                    Colors.blueAccent.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
        child: ElevatedButton(
          onPressed: hasSelectedSubjects ? onPressed : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: isDarkMode ? Colors.black : Colors.white,
            backgroundColor: isDarkMode ? Colors.yellow.shade700 : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Ajustamos el padding
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el ancho
            children: [
              const Text('Asignar grupos'), // Texto del botón
              const SizedBox(width: 10), // Espacio entre el icono y el texto
              Icon(Icons.group, size: 20), // Icono de grupo
            ],
          ),
        ),
      ),

    );
  }

  static Widget buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

}
