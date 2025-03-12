import 'package:http/http.dart' as http;
import 'dart:convert';

class SubjectService {
  //Funcion que hace la solictud HTTP para obtner los datos de una asignatura
  Future<Map<String, dynamic>> getSubjectData({
    required String codeSubject}) async {
      try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/subjects/$codeSubject'),
      );

      if (response.statusCode == 200) {
        // Asegúrate de que el cuerpo de la respuesta se decodifique en UTF-8
        String responseBody = utf8.decode(response.bodyBytes);
        
        // Decodifica el JSON de la respuesta
        return json.decode(responseBody);
      } else {
        return {
          'success': false,
          'message': 'Asignatura no encontrada'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e'
      };
    }
  }

  Future<Map<String, dynamic>> getDegreeData({
    required String degreeName}) async {
      try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/degrees/$degreeName'),
      );

      if (response.statusCode == 200) {
        // Asegúrate de que el cuerpo de la respuesta se decodifique en UTF-8
        String responseBody = utf8.decode(response.bodyBytes);
        
        // Decodifica el JSON de la respuesta
        return json.decode(responseBody);
      } else {
        return {
          'success': false,
          'message': 'Degree no encontrado'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e'
      };
    }
  }

  Future<Map<String, dynamic>> updateSubjects({
    required String username,
    required List<Map<String, dynamic>> subjects
    }) async {
      try {
      final response = await http.patch(
        Uri.parse('http://10.0.2.2:8000/users/$username/subjects'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'subjects': subjects}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error al actualizar las asignaturas'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e'
      };
    }
  }
}