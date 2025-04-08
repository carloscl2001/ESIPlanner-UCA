import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'login_logic.dart';
import 'login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginLogic logic;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    logic = LoginLogic(context);
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      await logic.login();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      body: Center(
        child: LoginForm(
          formKey: _formKey,
          logic: logic,
          isDarkMode: isDarkMode,
          onLoginPressed: _login,
        ),
      ),
    );
  }
}