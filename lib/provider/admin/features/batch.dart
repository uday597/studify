import 'package:flutter/material.dart';
import 'package:studify/main.dart';

class BatchProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _batches = [];
  List<Map<String, dynamic>> get batches => _batches;
  bool _loading = false;
  bool get loading => _loading;

  Future<void> fetchData({required int adminId}) async {
    try {
      _loading = true;
      notifyListeners();

      final List<dynamic> data = await supabase
          .from('batches')
          .select('*')
          .eq('admin_id', adminId);
      _batches = data.map((e) => e as Map<String, dynamic>).toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Error fetching batches: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addBatch({
    required String name,
    required String location,
    required String incharge,
    required int adminId,
  }) async {
    try {
      await supabase.from('batches').insert({
        'name': name,
        'location': location,
        'incharge': incharge,
        'admin_id': adminId,
      });
      await fetchData(adminId: adminId);
    } catch (e) {
      throw Exception('Error adding batch: $e');
    }
  }

  Future<bool> checkBatchExists(String name, int adminId) async {
    try {
      final List data = await supabase
          .from('batches')
          .select('id')
          .eq('name', name)
          .eq('admin_id', adminId);
      return data.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking existing batch: $e');
    }
  }

  Future<void> removeBatch(String batchid, int adminId) async {
    try {
      await supabase
          .from('batches')
          .delete()
          .eq('id', batchid)
          .eq('admin_id', adminId);
      await fetchData(adminId: adminId);
    } catch (e) {
      throw Exception('Error deleting batch: $e');
    }
  }

  Future<void> updateBatch({
    required String batchid,
    required String name,
    required String location,
    required String incharge,
    required int adminId,
  }) async {
    try {
      await supabase
          .from('batches')
          .update({'name': name, 'location': location, 'incharge': incharge})
          .eq('id', batchid)
          .eq('admin_id', adminId);
      await fetchData(adminId: adminId);
    } catch (e) {
      throw Exception('Error updating batch: $e');
    }
  }
}
