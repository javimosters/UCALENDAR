import 'package:flutter/material.dart';
import 'main_scaffold.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ══════════════════════════════════════════════════════════════
//  AjustesPage — Configuración de la app (local)
// ══════════════════════════════════════════════════════════════

class AjustesPage extends StatefulWidget {
  const AjustesPage({super.key});
  @override
  State<AjustesPage> createState() => _AjustesPageState();
}

class _AjustesPageState extends State<AjustesPage> {
  // Preferencias locales
  bool _notificaciones = true;
  bool _recordatorios = true;
  bool _notifExamenes = true;
  bool _notifTareas = true;
  int _anticipacion = 1; // días antes de notificar
  String _idioma = 'Español';
  String _tema = 'Sistema';

  final List<String> _idiomas = ['Español', 'English'];
  final List<String> _temas = ['Sistema', 'Claro', 'Oscuro'];
  final List<int> _anticipaciones = [1, 2, 3, 5, 7];

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── HEADER ──
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // ── NOTIFICACIONES ──
                  _Seccion(titulo: 'Notificaciones'),
                  const SizedBox(height: 10),
                  _SwitchTile(
                    icono: Icons.notifications_rounded,
                    titulo: 'Notificaciones',
                    subtitulo: 'Activar todas las notificaciones',
                    color: const Color(0xFF4A00E0),
                    valor: _notificaciones,
                    onChanged: (v) => setState(() => _notificaciones = v),
                  ),
                  _SwitchTile(
                    icono: Icons.alarm_rounded,
                    titulo: 'Recordatorios',
                    subtitulo: 'Recordar tareas próximas a vencer',
                    color: Colors.orange,
                    valor: _recordatorios && _notificaciones,
                    onChanged: _notificaciones
                        ? (v) => setState(() => _recordatorios = v)
                        : null,
                  ),
                  _SwitchTile(
                    icono: Icons.quiz_rounded,
                    titulo: 'Avisos de exámenes',
                    subtitulo: 'Notificar antes de cada examen',
                    color: Colors.redAccent,
                    valor: _notifExamenes && _notificaciones,
                    onChanged: _notificaciones
                        ? (v) => setState(() => _notifExamenes = v)
                        : null,
                  ),
                  _SwitchTile(
                    icono: Icons.assignment_rounded,
                    titulo: 'Avisos de tareas',
                    subtitulo: 'Notificar antes de cada entrega',
                    color: Colors.teal,
                    valor: _notifTareas && _notificaciones,
                    onChanged: _notificaciones
                        ? (v) => setState(() => _notifTareas = v)
                        : null,
                  ),

                  const SizedBox(height: 8),

                  // Anticipación
                  _SelectTile(
                    icono: Icons.timelapse_rounded,
                    titulo: 'Anticipación de avisos',
                    subtitulo: 'Notificar $_anticipacion día${_anticipacion > 1 ? 's' : ''} antes',
                    color: Colors.blue,
                    opciones: _anticipaciones.map((d) => '$d día${d > 1 ? 's' : ''}').toList(),
                    valorActual: '$_anticipacion día${_anticipacion > 1 ? 's' : ''}',
                    onSeleccion: (i) => setState(() => _anticipacion = _anticipaciones[i]),
                  ),

                  const SizedBox(height: 24),

                  // ── APARIENCIA ──
                  _Seccion(titulo: 'Apariencia'),
                  const SizedBox(height: 10),
                  _SelectTile(
                    icono: Icons.dark_mode_rounded,
                    titulo: 'Tema',
                    subtitulo: _tema,
                    color: Colors.indigo,
                    opciones: _temas,
                    valorActual: _tema,
                    onSeleccion: (i) => setState(() => _tema = _temas[i]),
                  ),
                  _SelectTile(
                    icono: Icons.language_rounded,
                    titulo: 'Idioma',
                    subtitulo: _idioma,
                    color: Colors.green,
                    opciones: _idiomas,
                    valorActual: _idioma,
                    onSeleccion: (i) => setState(() => _idioma = _idiomas[i]),
                  ),

                  const SizedBox(height: 24),

                  // ── CUENTA ──
                  _Seccion(titulo: 'Cuenta'),
                  const SizedBox(height: 10),
                  _InfoTile(
                    icono: Icons.info_outline_rounded,
                    titulo: 'Versión de la app',
                    subtitulo: '1.0.0',
                    color: Colors.grey,
                  ),
                  _InfoTile(
                    icono: Icons.privacy_tip_outlined,
                    titulo: 'Política de privacidad',
                    subtitulo: 'Ver términos y condiciones',
                    color: Colors.blueGrey,
                    onTap: () => _mostrarInfo(
                      context,
                      'Política de privacidad',
                      'UniCalendar no comparte tus datos con terceros. Tu información académica es privada y solo tú puedes acceder a ella.',
                    ),
                  ),
                  _InfoTile(
                    icono: Icons.help_outline_rounded,
                    titulo: 'Ayuda y soporte',
                    subtitulo: 'Preguntas frecuentes',
                    color: Colors.orange,
                    onTap: () => _mostrarInfo(
                      context,
                      'Ayuda',
                      '¿Tienes problemas?\nEscríbenos a soporte@unicalendar.app y te ayudaremos en menos de 24 horas.',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón cerrar sesión
                  _BotonCerrarSesion(
                    onTap: () => _cerrarSesion(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A00E0), Color(0xFF007AFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A00E0).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ajustes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('Personaliza tu experiencia',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.settings_rounded,
                  color: Colors.white, size: 30),
            ),
          ],
        ),
      );

  void _mostrarInfo(BuildContext ctx, String titulo, String texto) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(texto,
            style: TextStyle(color: Colors.grey[600], height: 1.5)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A00E0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Entendido',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _cerrarSesion(BuildContext ctx) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a iniciar sesión.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
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
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }
}

// ─────────────── SUBWIDGETS ───────────────

class _Seccion extends StatelessWidget {
  final String titulo;
  const _Seccion({required this.titulo});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(titulo,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87)),
      );
}

class _SwitchTile extends StatelessWidget {
  final IconData icono;
  final String titulo, subtitulo;
  final Color color;
  final bool valor;
  final void Function(bool)? onChanged;

  const _SwitchTile({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.valor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(onChanged != null ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono,
                color: onChanged != null ? color : Colors.grey,
                size: 20),
          ),
          title: Text(titulo,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: onChanged != null
                      ? Colors.black87
                      : Colors.grey)),
          subtitle: Text(subtitulo,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          trailing: Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: color,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      );
}

class _SelectTile extends StatelessWidget {
  final IconData icono;
  final String titulo, subtitulo, valorActual;
  final Color color;
  final List<String> opciones;
  final void Function(int) onSeleccion;

  const _SelectTile({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.opciones,
    required this.valorActual,
    required this.onSeleccion,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          title: Text(titulo,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(subtitulo,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(valorActual,
                  style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey[350], size: 20),
            ],
          ),
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (_) => Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  Text(titulo,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...opciones.asMap().entries.map((e) {
                    final activo = opciones[e.key] == valorActual;
                    return ListTile(
                      onTap: () {
                        onSeleccion(e.key);
                        Navigator.pop(context);
                      },
                      title: Text(e.value,
                          style: TextStyle(
                              fontWeight: activo
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: activo ? color : Colors.black87)),
                      trailing: activo
                          ? Icon(Icons.check_rounded, color: color)
                          : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    );
                  }),
                ],
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icono;
  final String titulo, subtitulo;
  final Color color;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 20),
          ),
          title: Text(titulo,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(subtitulo,
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          trailing: onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: Colors.grey[350], size: 20)
              : null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      );
}

class _BotonCerrarSesion extends StatelessWidget {
  final VoidCallback onTap;
  const _BotonCerrarSesion({required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cerrar sesión',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.redAccent)),
                      Text('Salir de tu cuenta',
                          style: TextStyle(
                              fontSize: 12, color: Colors.redAccent)),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      color: Colors.redAccent.withOpacity(0.5), size: 20),
                ],
              ),
            ),
          ),
        ),
      );
}