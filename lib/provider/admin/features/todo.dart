import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class ToDoProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _ToDoList = [];
  List<Map<String, dynamic>> get ToDoList => _ToDoList;
  bool isLoading = false;
  Future<void> fetchTodos(int adminId) async {
    isLoading = true;
    notifyListeners();

    final response = await supabase
        .from('admin_todos')
        .select()
        .eq('admin_id', adminId)
        .order('created_at', ascending: false);

    _ToDoList = List<Map<String, dynamic>>.from(response);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTodo({
    required int adminId,
    required String title,
    String? description,
  }) async {
    await supabase.from('admin_todos').insert({
      'admin_id': adminId,
      'title': title,
      'description': description,
    });

    await fetchTodos(adminId);
  }

  Future<void> updateTodo({
    required String id,
    required String title,
    String? description,
    required int adminId,
  }) async {
    await supabase
        .from('admin_todos')
        .update({
          'title': title,
          'description': description,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);

    await fetchTodos(adminId);
  }

  Future<void> deleteTodo({required String id, required int adminId}) async {
    await supabase.from('admin_todos').delete().eq('id', id);

    await fetchTodos(adminId);
  }
}
