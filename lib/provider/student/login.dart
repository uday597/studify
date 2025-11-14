import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class StudentLoginProvider extends ChangeNotifier {
  Map<String, dynamic>? _studentData;

  Map<String, dynamic>? get studentData => _studentData;

  Future<Map<String, dynamic>?> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase
          .from('students')
          .select()
          .eq('email', email)
          .eq('password', password)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      _studentData = response;
      notifyListeners();

      return response;
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  void logout() {
    _studentData = null;
    notifyListeners();
  }

  bool get isLoggedIn => _studentData != null;
}
