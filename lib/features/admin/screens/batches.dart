import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studify/provider/admin/features/batch.dart';
import 'package:studify/provider/admin/profile.dart';
import 'package:studify/features/admin/screens/studentlist.dart';
import 'package:studify/utils/appbar.dart';
import 'package:studify/features/admin/auth/signup.dart';

class Batches extends StatefulWidget {
  const Batches({super.key});

  @override
  State<Batches> createState() => _BatchesState();
}

class _BatchesState extends State<Batches> {
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController inchargeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDataFromProvider();
  }

  void fetchDataFromProvider() async {
    final adminProvider = Provider.of<AdminProfileProvider>(
      context,
      listen: false,
    );
    final batchProvider = Provider.of<BatchProvider>(context, listen: false);

    await adminProvider.ensureAdminLoaded();

    if (adminProvider.adminId != null) {
      await batchProvider.fetchData(adminId: adminProvider.adminId!);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProfileProvider>(context);
    final provider = Provider.of<BatchProvider>(context);

    return Scaffold(
      appBar: ReuseAppbar(name: 'Batches List'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.batches.isEmpty
          ? const Center(child: Text('No batches created yet 😔'))
          : ListView.builder(
              itemCount: provider.batches.length,
              itemBuilder: (context, index) {
                final batch = provider.batches[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentListScreen(
                            batchId: batch['id'],
                            batchName: batch['name'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/studenticon.png',
                            fit: BoxFit.contain,
                            color: Colors.black,
                          ),
                        ),
                        title: Text(
                          batch['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          batch['location'],
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                _showEditDialog(
                                  context,
                                  provider,
                                  batch,
                                  adminProvider,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Confirmation'),
                                    content: const Text(
                                      'Are you sure you want to delete this batch?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await provider.removeBatch(
                                    batch['id'],
                                    adminProvider.adminId!,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Batch deleted 🗑️'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

      // 🟢 Floating Add Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Center(
                child: Text(
                  'New Batch',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReuseTextfield(
                        controller: nameController,
                        text: 'Batch Name',
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter batch name'
                            : null,
                      ),
                      ReuseTextfield(
                        controller: locationController,
                        text: 'Batch Location',
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter location'
                            : null,
                      ),
                      ReuseTextfield(
                        controller: inchargeController,
                        text: 'Incharge Name',
                        validator: (v) => v == null || v.isEmpty
                            ? 'Please enter incharge name'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  // In your Batches screen, update the add batch button:
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // 🔥 GET ADMIN ID SAFELY
                        final adminProvider = Provider.of<AdminProfileProvider>(
                          context,
                          listen: false,
                        );
                        await adminProvider.ensureAdminLoaded();

                        if (adminProvider.adminId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Admin not logged in properly'),
                            ),
                          );
                          return;
                        }

                        bool exists = await provider.checkBatchExists(
                          nameController.text.trim(),
                          adminProvider.adminId!,
                        );

                        if (exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Batch already exists')),
                          );
                          return;
                        }

                        await provider.addBatch(
                          name: nameController.text.trim(),
                          location: locationController.text.trim(),
                          incharge: inchargeController.text.trim(),
                          adminId: adminProvider.adminId!, // ✅ SAFE NOW
                        );

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Batch added successfully')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    BatchProvider provider,
    Map<String, dynamic> batch,
    AdminProfileProvider adminProvider, // Add this parameter
  ) {
    TextEditingController nameCtrl = TextEditingController(text: batch['name']);
    TextEditingController locCtrl = TextEditingController(
      text: batch['location'],
    );
    TextEditingController inchargeCtrl = TextEditingController(
      text: batch['incharge'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Edit Batch')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Batch Name'),
              ),
              TextField(
                controller: locCtrl,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: inchargeCtrl,
                decoration: const InputDecoration(labelText: 'Incharge'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.updateBatch(
                batchid: batch['id'].toString(),
                name: nameCtrl.text.trim(),
                location: locCtrl.text.trim(),
                incharge: inchargeCtrl.text.trim(),
                adminId: adminProvider.adminId!, // Add adminId
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Batch updated successfully ✅')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
