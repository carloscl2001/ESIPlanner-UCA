import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final bool isDarkMode;
  final String errorMessage;
  final Map<String, dynamic> userProfile;

  const ProfileCard({
    super.key,
    required this.isDarkMode,
    required this.errorMessage,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final cardWidth = isDesktop ? 600.0 : double.infinity;

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.black, Colors.black]
                    : [Colors.indigo.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 30.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (errorMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha:(0.1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: isDesktop ? 16.0 : 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: isDesktop ? 30.0 : 20.0),
                      ],
                      ProfileField(
                        icon: Icons.person,
                        label: userProfile['username'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                      ProfileField(
                        icon: Icons.email,
                        label: userProfile['email'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                      ProfileField(
                        icon: Icons.badge,
                        label: userProfile['name'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                      ProfileField(
                        icon: Icons.family_restroom,
                        label: userProfile['surname'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                      ProfileField(
                        icon: Icons.school,
                        label: userProfile['degree'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final bool isDesktop;

  const ProfileField({
    super.key,
    required this.icon,
    required this.label,
    required this.isDarkMode,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isDesktop ? 10.0 : 8.0),
      padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: isDesktop ? 28.0 : 24.0,
            color: isDarkMode ? Colors.yellow.shade700 : Colors.blue.shade900,
          ),
          SizedBox(width: isDesktop ? 16.0 : 12.0),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isDesktop ? 17.0 : 16.0,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}