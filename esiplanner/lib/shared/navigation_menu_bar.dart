import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../features/my_week/my_week_screen.dart';
import '../features/timetable/timetable_home/timetable_home_screen.dart';
// import 'screens/agenda_screen.dart';
import '../non_features/profile_menu_screen.dart';
import '../providers/theme_provider.dart'; // Importa el ThemeProvider

class NavigationMenuBar extends StatefulWidget {
  const NavigationMenuBar({super.key});

  @override
  State<NavigationMenuBar> createState() => _NavigationMenuBarState();
}

class _NavigationMenuBarState extends State<NavigationMenuBar> {
  int currentPageIndex = 0;

  // Método para hacer logout
  void logout() {
    context.read<AuthProvider>().logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Método para mostrar el menú de configuración
  void showSettingsMenu(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opción de cambiar modo oscuro
              ListTile(
                leading: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  color: isDarkMode ? Colors.white : Colors.yellow.shade700,
                ),
                title: Text(
                  isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                    Navigator.pop(context); // Cerrar el menú después del cambio
                  },
                  activeColor: Colors.yellow.shade700,
                  inactiveThumbColor: Colors.indigo.shade700,
                ),
              ),

              const Divider(),

              // Opción de cerrar sesión
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  ); // Cerrar el menú antes de cerrar sesión
                  logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).username ?? 'Usuario';
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hola, $username',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 10,
        flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode 
              ? null
              : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.indigo.shade900,
                    Colors.blue.shade900,
                    Colors.blueAccent.shade400,
                  ],
                ),
          color: isDarkMode ? Colors.black : null,
        ),
      ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showSettingsMenu(context), // Abre el menú
            color: isDarkMode ? Colors.yellow.shade700 : Colors.white,
            tooltip: 'Configuración',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Icon(
                Icons.view_week,
                color: isDarkMode ? Colors.black : Colors.blue.shade900,
              ),
              icon: const Icon(Icons.view_week_outlined, color: Colors.grey),
              label: 'Mi semana',
            ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.calendar_month_rounded,
                color: isDarkMode ? Colors.black : Colors.blue.shade900,
              ),
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.grey,
              ),
              label: 'Horario',
            ),
            // NavigationDestination(
            //   selectedIcon: Icon(
            //     Icons.calendar_month_rounded,
            //     color: isDarkMode ? Colors.black : Colors.indigo,
            //   ),
            //   icon: const Icon(
            //     Icons.calendar_month_rounded,
            //     color: Colors.grey,
            //   ),
            //   label: 'Agenda',
            // ),
            NavigationDestination(
              selectedIcon: Icon(
                Icons.person,
                color: isDarkMode ? Colors.black : Colors.blue.shade900,
              ),
              icon: const Icon(Icons.person_outline, color: Colors.grey),
              label: 'Perfil',
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            <Widget>[
              const HomeScreen(),
              const TimetableScreen(),
              //const AgendaScreen(),
              const ProfileMenuScreen(),
            ][currentPageIndex],
      ),
    );
  }
}
