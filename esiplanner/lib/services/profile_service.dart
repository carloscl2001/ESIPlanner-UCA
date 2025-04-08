import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_services.dart'; // Importa ApiServices para usar la URL base

class ProfileService {
  // Obtener datos del perfil
  Future<Map<String, dynamic>> getProfileData({
    required String username,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiServices.baseUrl}/users/$username'),
      );

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        return json.decode(responseBody);
      } else {
        return {
          'success': false,
          'message': 'Error al obtener los datos del perfil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e',
      };
    }
  }

  // Actualizar contraseña
  Future<Map<String, dynamic>> updatePassword({
    required String username,
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      final String? token = Provider.of<AuthProvider>(context, listen: false).token;

      final response = await http.put(
        Uri.parse('${ApiServices.baseUrl}/auth/$username/changePassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'new_password': newPassword}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Contraseña actualizada correctamente',
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'La nueva contraseña tiene que ser distinta a la actual',
        };
      } else {
        return {
          'success': false,
          'message': 'Error al actualizar la contraseña: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e',
      };
    }
  }

  // Obtener asignaturas y grupos del usuario
  Future<Map<String, dynamic>> getUserSubjects({
    required String username,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiServices.baseUrl}/users/$username/subjects'),
      );

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        return {'success': true, 'data': json.decode(responseBody)};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Usuario no encontrado'};
      } else {
        return {
          'success': false,
          'message': 'Error al obtener las asignaturas: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e',
      };
    }
  }

  //Actualizar asignaturas y grupos del usuario
  Future<Map<String, dynamic>> updateSubjects({
    required String username,
    required List<Map<String, dynamic>> subjects,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiServices.baseUrl}/users/$username/subjects'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'subjects': subjects}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error al actualizar las asignaturas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e',
      };
    }
  }
}
