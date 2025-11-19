import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/main.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/utils/appbar.dart';

class Adminprofile extends StatefulWidget {
  const Adminprofile({super.key});

  @override
  State<Adminprofile> createState() => _AdminprofileState();
}

class _AdminprofileState extends State<Adminprofile> {
  final image = supabase.auth.currentUser?.userMetadata?['picture'];
  bool isEditing = false;

  final nameController = TextEditingController();
  final academyController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AdminProfileProvider>(context, listen: false).Fatchdata();
    });
  }

  void fillControllers(AdminProfileProvider provider) {
    nameController.text = provider.admin?.name ?? '';
    academyController.text = provider.admin?.academy ?? '';
    mobileController.text = provider.admin?.mobile ?? '';
    addressController.text = provider.admin?.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProfileProvider>(context);
    final size = MediaQuery.of(context).size;

    if (provider.admin != null && nameController.text.isEmpty) {
      fillControllers(provider);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ReuseAppbar(name: 'Admin Profile'),
      body: provider.isloading
          ? const Center(child: CircularProgressIndicator())
          : provider.admin == null
          ? const Center(child: Text('No Data Found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: size.width * 0.15,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: image != null
                                ? NetworkImage(image!)
                                : null,
                            child: image == null
                                ? const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 20),

                          buildTextField(
                            controller: nameController,
                            label: 'Full Name',
                            enabled: isEditing,
                            icon: Icons.person,
                          ),

                          buildTextField(
                            controller: TextEditingController(
                              text: provider.admin!.email,
                            ),
                            label: 'Email Address',
                            enabled: false,
                            icon: Icons.email,
                          ),

                          buildTextField(
                            controller: academyController,
                            label: 'Academy Name',
                            enabled: isEditing,
                            icon: Icons.school,
                          ),

                          buildTextField(
                            controller: mobileController,
                            label: 'Mobile Number',
                            enabled: isEditing,
                            icon: Icons.phone,
                          ),

                          buildTextField(
                            controller: addressController,
                            label: 'Address',
                            enabled: isEditing,
                            icon: Icons.location_on,
                          ),

                          const SizedBox(height: 25),

                          provider.isupdating
                              ? const CircularProgressIndicator()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isEditing
                                            ? Colors.red
                                            : Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isEditing = !isEditing;
                                        });
                                      },
                                      icon: Icon(
                                        isEditing ? Icons.cancel : Icons.edit,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        isEditing ? "Cancel" : "Edit",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isEditing)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          await provider.updatedata(
                                            name: nameController.text,
                                            academy_name:
                                                academyController.text,
                                            mobile: mobileController.text,
                                            address: addressController.text,
                                          );
                                          setState(() {
                                            isEditing = false;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.save,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Save",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}

Widget buildTextField({
  TextEditingController? controller,
  required String label,
  required IconData icon,
  bool enabled = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16, color: Colors.black54),
        filled: true,
        fillColor: enabled ? Colors.blue.shade50 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: enabled ? Colors.blueAccent : Colors.grey.shade400,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    ),
  );
}
