import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'register_logic.dart';
import 'register_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late RegisterLogic logic;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    logic = RegisterLogic(context);
    _loadDegrees();
  }

  Future<void> _loadDegrees() async {
    await logic.loadDegrees();
    if (mounted) setState(() {});
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final success = await logic.register();
      if (!mounted) return;
      
      if (success) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    }
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return ChangeNotifierProvider<RegisterLogic>.value(
      value: logic,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        body: SingleChildScrollView(
          child: Consumer<RegisterLogic>(
            builder: (context, logic, child) {
              return RegisterForm(
                formKey: _formKey,
                logic: logic,
                isDarkMode: isDarkMode,
                onRegisterPressed: _register,
                isLoading: logic.isLoading,
              );
            },
          ),
        ),
      ),
    );
  }
}