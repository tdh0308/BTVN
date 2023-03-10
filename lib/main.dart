// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Sinh Vien',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text fields' controllers
  final TextEditingController _IdController = TextEditingController();
  final TextEditingController _MaSVController = TextEditingController();
  final TextEditingController _GioiTinhController = TextEditingController();
  final TextEditingController _QueQuanController = TextEditingController();

  final CollectionReference _SinhVienss =
      FirebaseFirestore.instance.collection('SinhViens');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a SinhVien if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing SinhVien
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _IdController.text = documentSnapshot['Id'];
      _MaSVController.text = documentSnapshot['MaSV'].toString();
      _GioiTinhController.text = documentSnapshot['GioiTinh'];
      _QueQuanController.text = documentSnapshot['QueQuan'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _IdController,
                  decoration: const InputDecoration(labelText: 'Id'),
                ),
                TextField(
                  controller: _MaSVController,
                  decoration: const InputDecoration(
                    labelText: 'MaSV',
                  ),
                ),
                TextField(
                  controller: _MaSVController,
                  decoration: const InputDecoration(
                    labelText: 'GioiTinh',
                  ),
                ),
                TextField(
                  controller: _MaSVController,
                  decoration: const InputDecoration(
                    labelText: 'QueQuan',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? MaSV = _IdController.text;
                    final String? GioiTinh = _IdController.text;
                    final String? QueQuan = _IdController.text;
                    final double? Id = double.tryParse(_MaSVController.text);
                    if (Id != null && MaSV != null) {
                      if (action == 'create') {
                        // Persist a new SinhVien to Firestore
                        await _SinhVienss.add({
                          "Id": Id,
                          "MaSV": MaSV,
                          "GioiTinh": GioiTinh,
                          "QueQuan": QueQuan
                        });
                      }

                      if (action == 'update') {
                        // Update the SinhVien
                        await _SinhVienss.doc(documentSnapshot!.id).update({
                          "Id": Id,
                          "MaSV": MaSV,
                          "GioiTinh": GioiTinh,
                          "QueQuan": QueQuan
                        });
                      }

                      // Clear the text fields
                      _IdController.text = '';
                      _MaSVController.text = '';
                      _GioiTinhController.text = '';
                      _QueQuanController.text = '';

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Deleteing a SinhVien by id
  Future<void> _deleteSinhVien(String SinhVienId) async {
    await _SinhVienss.doc(SinhVienId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a SinhVien')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('crud.com'),
      ),
      // Using StreamBuilder to display all SinhViens from Firestore in real-time
      body: StreamBuilder(
        stream: _SinhVienss.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['Id'].toString()),
                    subtitle: Text(documentSnapshot['MaSV']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single SinhVien
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single SinhVien
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteSinhVien(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new SinhVien
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
