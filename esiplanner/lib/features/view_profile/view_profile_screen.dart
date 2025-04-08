import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'view_profile_logic.dart';
import 'view_profile_widgets.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late ViewProfileLogic logic;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    logic = ViewProfileLogic(
      refreshUI: () {
        if (_isMounted) {
          setState(() {});
        }
      },
      showError: (message) {
        if (_isMounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        logic.loadUserProfile(context);
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: ProfileCard(
              isDarkMode: isDarkMode,
              errorMessage: logic.errorMessage,
              userProfile: logic.userProfile,
            ),
          ),
        ),
      ),
    );
  }
}