import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>;
        });
      }
    }
  }

  Future<void> seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      final ref = FirebaseStorage.instance.ref().child('fotos_perfil/${user!.uid}.jpg');
      await ref.putFile(imageFile);

      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).update({
        'fotoUrl': url,
      });

      cargarDatosUsuario();
    }
  }

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void editarPerfil() {
    final nombreController = TextEditingController(text: userData?['nombre']);
    final apellidoController = TextEditingController(text: userData?['apellido']);
    final telefonoController = TextEditingController(text: userData?['telefono']);
    final carreraController = TextEditingController(text: userData?['carrera']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Editar Perfil", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nombreController, decoration: const InputDecoration(labelText: "Nombre")),
                TextField(controller: apellidoController, decoration: const InputDecoration(labelText: "Apellido")),
                TextField(controller: telefonoController, decoration: const InputDecoration(labelText: "Teléfono")),
                TextField(controller: carreraController, decoration: const InputDecoration(labelText: "Carrera")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF145DA0)),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).update({
                  'nombre': nombreController.text,
                  'apellido': apellidoController.text,
                  'telefono': telefonoController.text,
                  'carrera': carreraController.text,
                });
                Navigator.pop(context);
                cargarDatosUsuario();
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// 🔷 AppBar con logo grande centrado
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9FF),
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 90), // logo grande y visible en móvil
        elevation: 0,
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Center( // 🔥 todo centrado
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Avatar con foto y botón cámara
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 75,
                          backgroundColor: Colors.blueAccent,
                          backgroundImage: userData!['fotoUrl'] != null
                              ? NetworkImage(userData!['fotoUrl'])
                              : null,
                          child: (userData!['fotoUrl'] == null)
                              ? Text(
                                  userData!['nombre'][0].toUpperCase(),
                                  style: const TextStyle(fontSize: 40, color: Colors.white),
                                )
                              : null,
                        ),
                        FloatingActionButton(
                          mini: true,
                          backgroundColor: const Color(0xFF00C853),
                          onPressed: seleccionarFoto,
                          child: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    /// Tarjeta con subtítulo y datos
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              "Información Personal",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            ListTile(
                              leading: const Icon(Icons.person, color: Color(0xFF145DA0)),
                              title: Text("Nombre: ${userData!['nombre']} ${userData!['apellido']}"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.school, color: Color(0xFF145DA0)),
                              title: Text("Carrera: ${userData!['carrera']}"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone, color: Color(0xFF145DA0)),
                              title: Text("Teléfono: ${userData!['telefono']}"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.email, color: Color(0xFF145DA0)),
                              title: Text("Institucional: ${userData!['correo_institucional']}"),
                            ),
                            ListTile(
                              leading: const Icon(Icons.alternate_email, color: Color(0xFF145DA0)),
                              title: Text("Personal: ${userData!['correo_personal']}"),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton.icon(
                              onPressed: editarPerfil,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF145DA0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.edit, color: Colors.white),
                              label: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Botón cerrar sesión
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: cerrarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text("Cerrar Sesión", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
