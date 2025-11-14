import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class TeacherLoginProvider extends ChangeNotifier {
  Map<String, dynamic>? _teacherData;

  Map<String, dynamic>? get teacherData => _teacherData;

  Future<Map<String, dynamic>?> teacherLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase
          .from('teachers')
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Store teacher data
      _teacherData = response;
      notifyListeners();

      return response;
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  void logout() {
    _teacherData = null;
    notifyListeners();
  }

  bool get isLoggedIn => _teacherData != null;
}
