import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'home_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  int _paso = 0; // 0 = info personal, 1 = cuenta

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _telefono = TextEditingController();
  final _carrera = TextEditingController();
  final _correoInst = TextEditingController();
  final _correoPersonal = TextEditingController();
  final _password = TextEditingController();
  final _confirmPass = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    for (final c in [_nombre, _apellido, _telefono, _carrera, _correoInst, _correoPersonal, _password, _confirmPass]) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextPaso() {
    if (_formKey.currentState!.validate()) {
      _animCtrl.reset();
      setState(() => _paso = 1);
      _animCtrl.forward();
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _correoInst.text.trim(),
        password: _password.text.trim(),
      );
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(cred.user!.uid)
          .set({
        'nombre': _nombre.text.trim(),
        'apellido': _apellido.text.trim(),
        'telefono': _telefono.text.trim(),
        'carrera': _carrera.text.trim(),
        'correo_institucional': _correoInst.text.trim(),
        'correo_personal': _correoPersonal.text.trim(),
        'uid': cred.user!.uid,
        'fecha_registro': Timestamp.now(),
        'fotoUrl': null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Cuenta creada correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al registrar';
      if (e.code == 'email-already-in-use')
        msg = 'Este correo ya está registrado';
      if (e.code == 'weak-password') msg = 'Contraseña muy débil';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: LayoutBuilder(builder: (ctx, constraints) {
        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600
                      ? 440
                      : double.infinity),
              child: Column(
                children: [
                  // Logo
                  Image.asset('assets/logo.png',
                      width: constraints.maxWidth * 0.55,
                      fit: BoxFit.contain),
                  const SizedBox(height: 8),
                  const Text('Crea tu cuenta',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('Completa el formulario para registrarte',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[500])),
                  const SizedBox(height: 24),

                  // Stepper indicator
                  _StepIndicator(pasoActual: _paso),
                  const SizedBox(height: 20),

                  // Card del formulario
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: _paso == 0
                            ? _buildPaso0()
                            : _buildPaso1(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Link a login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿Ya tienes cuenta? ',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        child: const Text('Inicia sesión',
                            style: TextStyle(
                                color: Color(0xFF4A00E0),
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaso0() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información personal',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _Field(c: _nombre, label: 'Nombre', icon: Icons.person_outline_rounded,
              validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
          _Field(c: _apellido, label: 'Apellido', icon: Icons.person_outline_rounded,
              validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
          _Field(c: _telefono, label: 'Teléfono', icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
          _Field(c: _carrera, label: 'Carrera', icon: Icons.school_outlined,
              validator: (v) => v!.isEmpty ? 'Obligatorio' : null),
          _Field(c: _correoPersonal, label: 'Correo personal', icon: Icons.alternate_email_rounded,
              keyboard: TextInputType.emailAddress,
              validator: (v) {
                if (v!.isEmpty) return 'Obligatorio';
                if (!v.contains('@')) return 'Correo inválido';
                return null;
              }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: _GradButton(
              label: 'Siguiente',
              onTap: _nextPaso,
              trailingIcon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      );

  Widget _buildPaso1() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            GestureDetector(
              onTap: () {
                _animCtrl.reset();
                setState(() => _paso = 0);
                _animCtrl.forward();
              },
              child: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF4A00E0)),
            ),
            const SizedBox(width: 10),
            const Text('Datos de acceso',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          _Field(
            c: _correoInst,
            label: 'Correo institucional',
            icon: Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v!.isEmpty) return 'Obligatorio';
              if (!v.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
          _PassField(
            c: _password,
            label: 'Contraseña',
            obscure: _obscure,
            onToggle: () => setState(() => _obscure = !_obscure),
            validator: (v) {
              if (v!.isEmpty) return 'Obligatorio';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          _PassField(
            c: _confirmPass,
            label: 'Confirmar contraseña',
            obscure: _obscureConfirm,
            onToggle: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) {
              if (v != _password.text) return 'Las contraseñas no coinciden';
              return null;
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4A00E0)))
                : _GradButton(
                    label: 'Crear cuenta',
                    onTap: _register,
                    trailingIcon: Icons.check_rounded,
                    colors: [Colors.green, Colors.teal],
                  ),
          ),
        ],
      );
}

// ── SUBWIDGETS ──

class _StepIndicator extends StatelessWidget {
  final int pasoActual;
  const _StepIndicator({required this.pasoActual});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Dot(activo: true, numero: '1', label: 'Personal'),
          _Line(activo: pasoActual >= 1),
          _Dot(activo: pasoActual >= 1, numero: '2', label: 'Cuenta'),
        ],
      );
}

class _Dot extends StatelessWidget {
  final bool activo;
  final String numero, label;
  const _Dot(
      {required this.activo,
      required this.numero,
      required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: activo
                ? const Color(0xFF4A00E0)
                : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(numero,
                style: TextStyle(
                    color: activo ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: activo
                    ? const Color(0xFF4A00E0)
                    : Colors.grey,
                fontWeight: activo ? FontWeight.w600 : FontWeight.normal)),
      ]);
}

class _Line extends StatelessWidget {
  final bool activo;
  const _Line({required this.activo});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 60,
          height: 2,
          color: activo ? const Color(0xFF4A00E0) : Colors.grey.shade200,
        ),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController c;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final String? Function(String?)? validator;

  const _Field({
    required this.c,
    required this.label,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: keyboard,
          validator: validator,
          decoration: _deco(label, icon),
        ),
      );
}

class _PassField extends StatelessWidget {
  final TextEditingController c;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PassField({
    required this.c,
    required this.label,
    required this.obscure,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          obscureText: obscure,
          validator: validator,
          decoration: _deco(label, Icons.lock_outline_rounded).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20),
              onPressed: onToggle,
            ),
          ),
        ),
      );
}

InputDecoration _deco(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF4A00E0), size: 20),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4A00E0), width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    );

class _GradButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? trailingIcon;
  final List<Color> colors;

  const _GradButton({
    required this.label,
    required this.onTap,
    this.trailingIcon,
    this.colors = const [Color(0xFF4A00E0), Color(0xFF007AFF)],
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: Colors.white, size: 18),
              ]
            ],
          ),
        ),
      );
}