import 'package:flutter/material.dart';
import 'package:studify/main.dart';
import 'package:studify/modal/admin/admin.dart';

class AdminProfileProvider extends ChangeNotifier {
  Admin? admin;
  bool isloading = false;
  bool isupdating = false;

  int? get adminId => admin?.id;

  Future<void> Fatchdata() async {
    try {
      isloading = true;
      notifyListeners();

      final user = supabase.auth.currentUser;
      if (user == null) {
        print("⚠️ No user is logged in");
        isloading = false;
        notifyListeners();
        return;
      }

      final email = user.email;
      print("🔄 Fetching admin data for email: $email");

      final response = await supabase
          .from('admin')
          .select()
          .eq('email', email!)
          .maybeSingle();

      if (response != null && response.isNotEmpty) {
        admin = Admin(
          id: response['id'],
          name: response['name'],
          email: response['email'],
          academy: response['academy_name'],
          mobile: response['mobile'],
          address: response['address'],
        );
        print("✅ Admin data fetched successfully. Admin ID: ${admin!.id}");
      } else {
        print("❌ No admin record found for email: $email");
        admin = null;
      }
    } catch (e) {
      print('❌ Error fetching admin data: $e');
      admin = null; // 🔥 IMPORTANT: Reset on error
    } finally {
      isloading = false;
      notifyListeners();
    }
  }

  // 🔥 NEW METHOD: Clear admin data on logout
  void clearAdminData() {
    admin = null;
    notifyListeners();
    print("🧹 Admin data cleared");
  }

  Future<void> ensureAdminLoaded() async {
    if (admin == null && !isloading) {
      await Fatchdata();
    }
  }

  Future<void> updatedata({
    required String name,
    required String academy_name,
    required String mobile,
    required String address,
  }) async {
    if (admin == null) {
      print("❌ Cannot update: Admin data not loaded");
      return;
    }
    try {
      isupdating = true;
      notifyListeners();
      await supabase
          .from('admin')
          .update({
            'name': name,
            'mobile': mobile,
            'academy_name': academy_name,
            'address': address,
          })
          .eq('id', admin!.id);
      admin = Admin(
        name: name,
        id: admin!.id,
        academy: academy_name,
        address: address,
        email: admin!.email,
        mobile: mobile,
      );

      print("✅ Profile updated successfully!");
    } catch (e) {
      print("❌ Error updating profile: $e");
    } finally {
      isupdating = false;
      notifyListeners();
    }
  }
}
