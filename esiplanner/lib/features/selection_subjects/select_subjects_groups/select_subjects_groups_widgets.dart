import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'select_subjects_groups_logic.dart';

class SelectGroupsContent extends StatelessWidget {
  final bool isDarkMode;
  final bool requireAllTypes;
  final bool oneGroupPerType;

  const SelectGroupsContent({
    super.key,
    required this.isDarkMode,
    required this.requireAllTypes,
    required this.oneGroupPerType,
  });

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<SelectGroupsLogic>(context, listen: true);

    return Column(
      children: <Widget>[
        if (logic.errorMessage.isNotEmpty) ...[
          Text(
            logic.errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
        if (requireAllTypes && !logic.allSelectionsComplete)
          SelectionWarning(isDarkMode: isDarkMode),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: logic.subjects.length,
            itemBuilder: (context, index) {
              final subject = logic.subjects[index];
               final missingTypes = requireAllTypes 
                  ? logic.getMissingTypesForSubject(subject['code']).cast<String>()
                  : <String>[];
              
              Map<String, List<Map<String, dynamic>>> groupedClasses = {};
    
              for (var group in subject['classes']) {
                final type = group['type'];
                final letter = type[0];
                if (!groupedClasses.containsKey(letter)) {
                  groupedClasses[letter] = [];
                }
                groupedClasses[letter]?.add(group);
              }
    
              return SubjectGroupCard(
                subject: subject,
                groupedClasses: groupedClasses,
                missingTypes: missingTypes,
                isDarkMode: isDarkMode,
                subjectDegrees: logic.subjectDegrees,
                requireAllTypes: requireAllTypes,
                oneGroupPerType: oneGroupPerType,
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsDialog extends StatefulWidget {
  final bool requireAllTypes;
  final bool oneGroupPerType;
  final Function(bool, bool) onSettingsChanged;

  const SettingsDialog({
    super.key,
    required this.requireAllTypes,
    required this.oneGroupPerType,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool tempRequireAll;
  late bool tempOnePerType;

  @override
  void initState() {
    super.initState();
    tempRequireAll = widget.requireAllTypes;
    tempOnePerType = widget.oneGroupPerType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar restricciones'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Seleccionar todos los tipos de grupos'),
            subtitle: const Text('Requiere seleccionar al menos un grupo de cada tipo'),
            value: tempRequireAll,
            onChanged: (value) {
              setState(() {
                tempRequireAll = value;
                if (!value) tempOnePerType = false;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Seleccionar solo un grupo por tipo'),
            subtitle: const Text('Permite solo un grupo seleccionado por cada tipo (A, B, C, etc.)'),
            value: tempOnePerType,
            onChanged: tempRequireAll ? (value) {
              setState(() {
                tempOnePerType = value;
              });
            } : null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            widget.onSettingsChanged(tempRequireAll, tempOnePerType);
            Navigator.pop(context);
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDarkMode;

  const SaveButton({
    super.key,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'GUARDAR SELECCIÓN',
          style: TextStyle(
            color: isDarkMode ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class SelectionWarning extends StatelessWidget {
  final bool isDarkMode;

  const SelectionWarning({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Card(
        color: isDarkMode ? Colors.yellow.shade700.withAlpha(229) : Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning, color: isDarkMode ? Colors.white: Colors.orange[800]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'No has completado todas las selecciones requeridas',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SubjectGroupCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final Map<String, List<Map<String, dynamic>>> groupedClasses;
  final List<String> missingTypes;
  final bool isDarkMode;
  final Map<String, String> subjectDegrees;
  final bool requireAllTypes;
  final bool oneGroupPerType;

  const SubjectGroupCard({
    super.key,
    required this.subject,
    required this.groupedClasses,
    required this.missingTypes,
    required this.isDarkMode,
    required this.subjectDegrees,
    required this.requireAllTypes,
    required this.oneGroupPerType,
  });

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<SelectGroupsLogic>(context, listen: true);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InfoRow(
                icon: Icons.book,
                text: subject['name'] ?? 'No Name',
                isDarkMode: isDarkMode,
                isTitle: true,
              ),
              const SizedBox(height: 4),
              InfoRow(
                icon: Icons.school,
                text: subjectDegrees[subject['code']] ?? 'Grado no disponible',
                isDarkMode: isDarkMode,
                isTitle: false,
              ),
              const SizedBox(height: 4),
              InfoRow(
                icon: Icons.code_rounded,
                text: 'Código: ${subject['code']}',
                isDarkMode: isDarkMode,
                isTitle: false,
              ),
              const SizedBox(height: 4),
              InfoRow(
                icon: Icons.code_rounded,
                text: 'Código ICS: ${subject['code_ics'] ?? 'N/A'}',
                isDarkMode: isDarkMode,
                isTitle: false,
              ),
              const SizedBox(height: 12),
              if (requireAllTypes && missingTypes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Falta por seleccionar: ${missingTypes.join(', ')}',
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ...groupedClasses.keys.map((letter) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${logic.getGroupLabel(letter)}${requireAllTypes ? '' : ' (Opcional)'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: groupedClasses[letter]!.map<Widget>((group) {
                        final groupType = group['type'] as String;
                        final isSelected = logic.isGroupSelected(subject['code'], groupType);
                        
                        return GestureDetector(
                          onTap: () {
                            logic.toggleGroupSelection(
                              subject['code'], 
                              groupType,
                              oneGroupPerType,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, 
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDarkMode 
                                      ? Colors.yellow.shade700 
                                      : Colors.indigo.shade100)
                                  : (isDarkMode 
                                      ? Colors.grey.shade800 
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode 
                                    ? Colors.grey.shade200 
                                    : Colors.indigo.shade300,
                              ),
                            ),
                            child: Text(
                              groupType,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? (isDarkMode 
                                        ? Colors.black 
                                        : Colors.indigo)
                                    : (isDarkMode 
                                        ? Colors.yellow.shade700 
                                        : Colors.indigo),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDarkMode;
  final bool isTitle;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.isDarkMode,
    required this.isTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTitle ? 24 : 20,
          color: isDarkMode 
              ? Colors.yellow.shade700 
              : Colors.indigo.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTitle ? 18 : 14,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}