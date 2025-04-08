import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final bool isDarkMode;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
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
                ? [Colors.grey.shade900, Colors.grey.shade900]
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
              _buildSubjectName(),
              const SizedBox(height: 12),
              _buildSubjectCode(),
              const SizedBox(height: 12),
              _buildGroupTypes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectName() {
    return Row(
      children: [
        Icon(
          Icons.book,
          size: 24,
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            subject['name'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCode() {
    return Row(
      children: [
        Icon(
          Icons.code,
          size: 20,
          color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '${subject['code']}',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTypes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tus grupos:',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (subject['types'] as List).map<Widget>((type) => 
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade700 : Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group,
                    color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }
}

class BuildEmptyCard extends StatelessWidget {
  const BuildEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  Icon(Icons.arrow_right_rounded, size: 64, color: Theme.of(context).disabledColor),
                  Icon(
                    Icons.edit_note_rounded,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Selecciona asignaturas en perfil',
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
}