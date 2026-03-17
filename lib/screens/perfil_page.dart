import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

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

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: const Color(0xFF145DA0),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      userData!['nombre'][0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Nombre completo
                  Text(
                    "${userData!['nombre']} ${userData!['apellido']}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// Carrera
                  Text(
                    "Carrera: ${userData!['carrera']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  /// Teléfono
                  Text(
                    "Teléfono: ${userData!['telefono']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  /// Correos
                  Text(
                    "Correo Institucional: ${userData!['correo_institucional']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Correo Personal: ${userData!['correo_personal']}",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  /// Botón cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: cerrarSesion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cerrar Sesión",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
