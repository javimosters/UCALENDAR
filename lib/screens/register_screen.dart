import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;
  int _selectedIndex = 1; // por defecto en Registro

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController carreraController = TextEditingController();
  final TextEditingController correoInstController = TextEditingController();
  final TextEditingController correoPersonalController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: correoInstController.text.trim(),
          password: passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'nombre': nombreController.text.trim(),
          'apellido': apellidoController.text.trim(),
          'telefono': telefonoController.text.trim(),
          'carrera': carreraController.text.trim(),
          'correo_institucional': correoInstController.text.trim(),
          'correo_personal': correoPersonalController.text.trim(),
          'uid': uid,
          'fecha_registro': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cuenta creada correctamente"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        String mensaje = "Error al registrar";

        if (e.code == 'email-already-in-use') {
          mensaje = "El correo ya está registrado";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }

      setState(() => isLoading = false);
    }
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
    // index 1 = Registro actual
    // index 2 = Otras (puedes crear otra pantalla)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 600 ? 450 : double.infinity;
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [

                    /// LOGO grande
                    Image.asset(
                      'assets/logo.png',
                      width: constraints.maxWidth * 0.8,
                    ),

                    const SizedBox(height: 30),

                    /// FORM CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [

                            buildTextField(nombreController, "Nombre", Icons.person),
                            buildTextField(apellidoController, "Apellido", Icons.person_outline),
                            buildTextField(telefonoController, "Teléfono", Icons.phone, keyboard: TextInputType.phone),
                            buildTextField(carreraController, "Carrera", Icons.school),
                            buildTextField(correoInstController, "Correo Institucional", Icons.email, keyboard: TextInputType.emailAddress),
                            buildTextField(correoPersonalController, "Correo Personal", Icons.alternate_email, keyboard: TextInputType.emailAddress),
                            buildTextField(passwordController, "Contraseña", Icons.lock, isPassword: true),
                            buildTextField(confirmPasswordController, "Confirmar contraseña", Icons.lock_outline, isPassword: true),

                            const SizedBox(height: 25),

                            /// BOTÓN moderno
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : register,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ).copyWith(
                                  backgroundColor: MaterialStateProperty.resolveWith((states) => null),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00C853), Color(0xFF64DD17)],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            "Crear Cuenta",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "¿Ya tienes cuenta? Inicia sesión",
                        style: TextStyle(
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      /// 🔷 BottomNavigationBar moderno
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF145DA0),
        unselectedItemColor: Colors.grey,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.app_registration), label: 'Registro'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Otras'),
        ],
      ),
    );
  }

  /// INPUT REUTILIZABLE
  Widget buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscurePassword : false,
        keyboardType: keyboard,
        validator: (value) {
          if (value == null || value.isEmpty) return "Este campo es obligatorio";
          if (label.contains("Correo") && !value.contains("@")) return "Ingresa un correo válido";
          if (label == "Contraseña" && value.length < 6) return "Mínimo 6 caracteres";
          if (label == "Confirmar contraseña" && value != passwordController.text) return "Las contraseñas no coinciden";
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => obscurePassword = !obscurePassword),
                )
              : null,
        ),
      ),
    );
  }
}
