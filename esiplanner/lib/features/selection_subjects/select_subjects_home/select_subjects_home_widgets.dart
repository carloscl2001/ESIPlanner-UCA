import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectSubjectsHomeWidgets {
  static void showAddSubjectsDialog({
    required BuildContext context,
    required List<String> availableDegrees,
    required Function(String) onDegreeSelected,
    required bool isDarkMode,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar grado'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableDegrees.length,
            itemBuilder: (context, index) {
              final degree = availableDegrees[index];
              return ListTile(
                leading: Icon(Icons.school_rounded,
                    color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo),
                title: Text(degree),
                onTap: () {
                  Navigator.pop(context);
                  onDegreeSelected(degree);
                  HapticFeedback.lightImpact();
                },
              );
            },
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 14, right: 2),
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
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(150),
                      )
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
                'No hay asignaturas seleccionadas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pulsa el botón + para añadir asignaturas',
                style: Theme.of(context).textTheme.bodyMedium,
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: hasSelectedSubjects ? onPressed : null,
          icon: const Icon(Icons.group),
          label: const Text('Asignar grupos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
            foregroundColor: isDarkMode ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}