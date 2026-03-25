import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // base64Encode — sin Storage, funciona en web y móvil

import 'main_scaffold.dart';
import 'login_screen.dart';

// ══════════════════════════════════════════════════════════════
//  🔧 SI LA FOTO AÚN NO SUBE — CHECKLIST RÁPIDO:
//
//  1️⃣  Firebase Console → Storage → Rules → pega esto:
//
//      rules_version = '2';
//      service firebase.storage {
//        match /b/{bucket}/o {
//          match /fotos_perfil/{uid}.jpg {
//            allow read, write: if request.auth != null
//                               && request.auth.uid == uid;
//          }
//        }
//      }
//
//  2️⃣  android/app/src/main/AndroidManifest.xml — agrega:
//      <!-- Android 13+ -->
//      <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
//      <!-- Android < 13 -->
//      <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
//
//  3️⃣  pubspec.yaml — versiones mínimas requeridas:
//      image_picker: ^1.0.0
//
//  El SnackBar de error ahora muestra el código exacto de Firebase
//  para que puedas identificar el problema al instante.
// ══════════════════════════════════════════════════════════════

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  Map<String, dynamic>? userData;
  bool _subiendo = false;
  double _progreso = 0;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    cargarDatosUsuario();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────── DATOS ───────────────────────────

  Future<void> cargarDatosUsuario() async {
    if (user == null) return;
    final snap = await _db.collection('usuarios').doc(user!.uid).get();
    if (snap.exists && mounted) {
      setState(() => userData = snap.data());
      _animCtrl.forward(from: 0);
    }
  }

  // ─────────────────────────── FOTO ────────────────────────────

  Future<void> seleccionarFoto() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,   // ✅ Pequeño para no exceder 1MB de Firestore
      maxHeight: 300,
      imageQuality: 50,
    );
    if (picked == null) return;

    setState(() { _subiendo = true; _progreso = 0; });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Sesión expirada.');

      // Leer bytes y convertir a base64
      setState(() => _progreso = 0.3);
      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) throw Exception('No se pudo leer la imagen.');

      setState(() => _progreso = 0.6);
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Guardar base64 directo en Firestore (sin Storage)
      setState(() => _progreso = 0.9);
      await _db
          .collection('usuarios')
          .doc(currentUser.uid)
          .set({'fotoUrl': base64Str}, SetOptions(merge: true));

      setState(() => _progreso = 1.0);
      await cargarDatosUsuario();
      if (mounted) _snack('✅ Foto actualizada', Colors.green);

    } on FirebaseException catch (e) {
      if (mounted) _snack('❌ Firebase [${e.code}]: ${e.message}', Colors.red, sec: 7);
    } catch (e) {
      if (mounted) _snack('❌ Error: $e', Colors.red, sec: 7);
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  void _snack(String msg, Color color, {int sec = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: Duration(seconds: sec),
    ));
  }

  // ─────────────────────────── SESIÓN ──────────────────────────

  Future<void> cerrarSesion() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a iniciar sesión.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Salir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await _auth.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  // ─────────────────────────── EDITAR ──────────────────────────

  void editarPerfil() {
    final nombre = TextEditingController(text: userData?['nombre'] ?? '');
    final apellido =
        TextEditingController(text: userData?['apellido'] ?? '');
    final telefono =
        TextEditingController(text: userData?['telefono'] ?? '');
    final carrera =
        TextEditingController(text: userData?['carrera'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditarSheet(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        carrera: carrera,
        onGuardar: () async {
          await _db
              .collection('usuarios')
              .doc(user!.uid)
              .update({
            'nombre': nombre.text.trim(),
            'apellido': apellido.text.trim(),
            'telefono': telefono.text.trim(),
            'carrera': carrera.text.trim(),
          });
          if (mounted) Navigator.pop(context);
          cargarDatosUsuario();
        },
      ),
    );
  }

  // ─────────────────────────── UI ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 2,
      child: userData == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
              ),
            )
          : SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── HEADER ──
                          _HeaderCard(
                            userData: userData!,
                            subiendo: _subiendo,
                            progreso: _progreso,
                            onFotoTap: seleccionarFoto,
                          ),
                          const SizedBox(height: 20),

                          // ── STATS ──
                          _StatsRow(userData: userData!),
                          const SizedBox(height: 26),

                          // ── INFO ──
                          const _SectionLabel('Información'),
                          const SizedBox(height: 10),
                          _InfoCard(Icons.school_rounded, 'Carrera',
                              userData!['carrera'] ?? '—'),
                          _InfoCard(Icons.phone_rounded, 'Teléfono',
                              userData!['telefono'] ?? '—'),
                          _InfoCard(Icons.email_rounded, 'Correo Personal',
                              userData!['correo_personal'] ?? '—'),
                          const SizedBox(height: 26),

                          // ── ACCIONES ──
                          const _SectionLabel('Cuenta'),
                          const SizedBox(height: 10),
                          _ActionTile(
                            icon: Icons.edit_rounded,
                            title: 'Editar Perfil',
                            subtitle: 'Actualiza tu información',
                            color: const Color(0xFF4A00E0),
                            onTap: editarPerfil,
                          ),
                          _ActionTile(
                            icon: Icons.logout_rounded,
                            title: 'Cerrar Sesión',
                            subtitle: 'Salir de tu cuenta',
                            color: Colors.redAccent,
                            onTap: cerrarSesion,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SUBWIDGETS
// ═══════════════════════════════════════════════════════════════

class _HeaderCard extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool subiendo;
  final double progreso;
  final VoidCallback onFotoTap;
  const _HeaderCard(
      {required this.userData,
      required this.subiendo,
      required this.progreso,
      required this.onFotoTap});

  @override
  Widget build(BuildContext context) {
    final nombre = userData['nombre'] ?? '';
    final apellido = userData['apellido'] ?? '';
    final correo = userData['correo_institucional'] ?? '';
    final fotoUrl = userData['fotoUrl'] as String?;
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF007AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withOpacity(0.38),
            blurRadius: 24,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xAAFFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white,
                  backgroundImage: fotoUrl != null
                          ? (fotoUrl.startsWith('data:')
                              ? MemoryImage(base64Decode(fotoUrl.split(',').last))
                              : NetworkImage(fotoUrl) as ImageProvider)
                          : null,
                  child: fotoUrl == null
                      ? Text(inicial,
                          style: const TextStyle(
                              fontSize: 38,
                              color: Color(0xFF4A00E0),
                              fontWeight: FontWeight.bold))
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: subiendo ? null : onFotoTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: subiendo
                          ? Colors.grey.shade400
                          : Colors.greenAccent.shade700,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8)
                      ],
                    ),
                    child: subiendo
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              value: progreso > 0 ? progreso : null,
                              strokeWidth: 2,
                              color: Colors.white,
                            ))
                        : const Icon(Icons.camera_alt_rounded,
                            size: 17, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          // Barra de progreso de subida
          if (subiendo && progreso > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progreso,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 3,
              ),
            ),
          ],

          const SizedBox(height: 16),
          Text('$nombre $apellido',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3)),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(correo,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic> userData;
  const _StatsRow({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat('Tareas', '12', Icons.assignment_rounded,
            const Color(0xFF4A00E0)),
        const SizedBox(width: 10),
        _Stat('Pendientes', '3', Icons.pending_actions_rounded,
            Colors.orange),
        const SizedBox(width: 10),
        _Stat('Hechas', '9', Icons.check_circle_rounded, Colors.green),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey[600])),
          ]),
        ),
      );
}

// ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
      );
}

// ─────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoCard(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF4A00E0).withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(icon, color: const Color(0xFF4A00E0), size: 20),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
          ]),
        ]),
      );
}

// ─────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87)),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500])),
                    ]),
                const Spacer(),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey[350], size: 22),
              ]),
            ),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────

class _EditarSheet extends StatelessWidget {
  final TextEditingController nombre, apellido, telefono, carrera;
  final VoidCallback onGuardar;
  const _EditarSheet(
      {required this.nombre,
      required this.apellido,
      required this.telefono,
      required this.carrera,
      required this.onGuardar});

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Editar Perfil',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _Campo(c: nombre, label: 'Nombre', icon: Icons.person_outline_rounded),
            _Campo(c: apellido, label: 'Apellido', icon: Icons.person_outline_rounded),
            _Campo(c: telefono, label: 'Teléfono', icon: Icons.phone_outlined, tipo: TextInputType.phone),
            _Campo(c: carrera, label: 'Carrera', icon: Icons.school_outlined),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onGuardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Guardar cambios',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
}

class _Campo extends StatelessWidget {
  final TextEditingController c;
  final String label;
  final IconData icon;
  final TextInputType tipo;
  const _Campo(
      {required this.c,
      required this.label,
      required this.icon,
      this.tipo = TextInputType.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          keyboardType: tipo,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon:
                Icon(icon, color: const Color(0xFF4A00E0), size: 20),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: Color(0xFF4A00E0), width: 2)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      );
}