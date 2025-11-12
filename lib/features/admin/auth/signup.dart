import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/main.dart';
import 'package:studify/provider/admin/profile.dart';

class AdminSignUp extends StatelessWidget {
  const AdminSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController namecontroller = TextEditingController();
    TextEditingController academycontroller = TextEditingController();
    TextEditingController emailcontroller = TextEditingController();
    TextEditingController mobilecontroller = TextEditingController();
    TextEditingController addresscontroller = TextEditingController();

    final _formKey = GlobalKey<FormState>();
    Future<void> signUp() async {
      if (!_formKey.currentState!.validate()) return;

      try {
        final response = await supabase
            .from('admin')
            .insert({
              'name': namecontroller.text.trim(),
              'email': emailcontroller.text.trim(),
              'academy_name': academycontroller.text.trim(),
              'mobile': mobilecontroller.text.trim(),
              'address': addresscontroller.text.trim(),
            })
            .select('id')
            .single();

        final adminId = response['id'];

        // 🔥 IMPORTANT: Update admin provider with new data
        final adminProvider = Provider.of<AdminProfileProvider>(
          context,
          listen: false,
        );
        await adminProvider.Fatchdata(); // Refresh admin data

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admindashboard',
          (route) => false,
          arguments: {
            'academy_name': academycontroller.text.trim(),
            'email': emailcontroller.text.trim(),
            'id': adminId,
          },
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    }

    final user = supabase.auth.currentUser;
    emailcontroller.text = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.white,
        title: const Text(
          'Sign Up',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Add sign out when going back
            supabase.auth.signOut();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Form(
              key: _formKey, // Add form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ReuseTextfield(
                    controller: namecontroller,
                    text: 'Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  ReuseTextfield(
                    controller: emailcontroller,
                    readonly: true,
                    text: 'Email',
                  ),
                  ReuseTextfield(
                    controller: academycontroller,
                    text: 'Academy Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter academy name';
                      }
                      return null;
                    },
                  ),
                  ReuseTextfield(
                    controller: mobilecontroller,
                    text: 'Mobile Number',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      if (value.length < 10) {
                        return 'Please enter valid mobile number';
                      }
                      return null;
                    },
                  ),
                  ReuseTextfield(
                    controller: addresscontroller,
                    text: 'Address',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(150, 50),
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Sign out and go back to login
                          supabase.auth.signOut();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(150, 50),
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget ReuseTextfield({
  TextEditingController? controller,
  required String text,
  bool readonly = false,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      controller: controller,
      readOnly: readonly,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        label: Text(text),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
  );
}
