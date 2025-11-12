import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/modal/admin/admin.dart';
import 'package:studify/provider/teacher/login.dart';
import 'package:studify/utils/appbar.dart';
import 'package:studify/main.dart';

class TeacherAcademyInfo extends StatefulWidget {
  const TeacherAcademyInfo({super.key});

  @override
  State<TeacherAcademyInfo> createState() => _TeacherAcademyInfoState();
}

class _TeacherAcademyInfoState extends State<TeacherAcademyInfo> {
  bool isLoading = true;
  Admin? adminData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAcademyData();
    });
  }

  Future<void> _loadAcademyData() async {
    final teacherProvider = Provider.of<TeacherLoginProvider>(
      context,
      listen: false,
    );

    try {
      final teacherData = teacherProvider.teacherData;

      if (teacherData != null && teacherData['admin_id'] != null) {
        final adminId = teacherData['admin_id'];

        final adminResponse = await supabase
            .from('admin')
            .select()
            .eq('id', adminId)
            .maybeSingle();

        if (adminResponse != null) {
          final admin = Admin(
            id: adminResponse['id'],
            name: adminResponse['name'] ?? 'Admin',
            email: adminResponse['email'] ?? 'No Email',
            academy: adminResponse['academy_name'] ?? 'Academy',
            mobile: adminResponse['mobile'] ?? 'No Mobile',
            address: adminResponse['address'] ?? 'No Address',
          );

          if (mounted) {
            setState(() {
              adminData = admin;
              isLoading = false;
            });
          }
          return;
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      debugPrint('❌ Error loading academy data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReuseAppbar(name: 'Academy Information'),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminData == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Academy Information Not Available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please contact your admin',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _buildAcademyContent(adminData!),
    );
  }

  Widget _buildAcademyContent(Admin admin) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            color: Colors.blue[50],
            child: Image.asset(
              'assets/images/stulogo.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Academy Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Academy Name', admin.academy),
                    _buildInfoRow('Admin Name', admin.name),
                    _buildInfoRow('Email', admin.email),
                    _buildInfoRow('Mobile', admin.mobile),
                    _buildInfoRow('Address', admin.address),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Contact Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(Icons.phone, 'Call', admin.mobile),
                    _buildContactItem(Icons.email, 'Email', admin.email),
                    _buildContactItem(
                      Icons.location_on,
                      'Address',
                      admin.address,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
