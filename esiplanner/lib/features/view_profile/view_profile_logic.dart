import 'package:esiplanner/services/profile_service.dart';
import 'package:esiplanner/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewProfileLogic {
  final VoidCallback refreshUI;
  final Function(String) showError;
  final ProfileService profileService = ProfileService();

  Map<String, dynamic> userProfile = {};
  String errorMessage = '';
  bool _isDisposed = false;

  ViewProfileLogic({
    required this.refreshUI,
    required this.showError,
  });

  Future<void> loadUserProfile(BuildContext context) async {
    try {
      // Obtenemos el AuthProvider usando el contexto
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final username = authProvider.username;
      
      if (username == null || username.isEmpty) {
        errorMessage = "El nombre de usuario no está disponible";
        if (!_isDisposed) refreshUI();
        return;
      }

      final profileData = await profileService.getProfileData(username: username);

      if (!_isDisposed) {
        if (profileData.isEmpty) {
          errorMessage = 'No se pudo obtener la información del perfil';
        } else {
          userProfile = profileData;
        }
        refreshUI();
      }
    } catch (e) {
      if (!_isDisposed) {
        errorMessage = 'Error al cargar el perfil: $e';
        refreshUI();
      }
    }
  }

  void dispose() {
    _isDisposed = true;
  }
}