import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool obscurePassword = true;
  int _selectedIndex = 0;

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String mensaje = "Error al iniciar sesión";

        if (e.code == 'user-not-found') {
          mensaje = "Usuario no encontrado";
        } else if (e.code == 'wrong-password') {
          mensaje = "Contraseña incorrecta";
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
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterScreen()),
      );
    }
    // index 0 = Login actual
    // index 2 = Otras (puedes crear otra pantalla)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth > 600 ? 400 : double.infinity;
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
                      width: constraints.maxWidth * 0.8, // ocupa 80% del ancho
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

                            /// EMAIL
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Ingresa tu correo";
                                }
                                if (!value.contains("@")) {
                                  return "Correo inválido";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email_outlined),
                                labelText: "Correo Electrónico",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// PASSWORD
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Ingresa tu contraseña";
                                }
                                if (value.length < 6) {
                                  return "Mínimo 6 caracteres";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                labelText: "Contraseña",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            /// LOGIN BUTTON moderno
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : login,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ).copyWith(
                                  backgroundColor: MaterialStateProperty.resolveWith(
                                    (states) => null,
                                  ),
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
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Ingresar",
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

                            const SizedBox(height: 15),

                            /// REGISTRO
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "¿No tienes cuenta? Regístrate",
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Registro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Otras',
          ),
        ],
      ),
    );
  }
}
