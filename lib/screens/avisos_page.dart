import 'package:flutter/material.dart';
import 'main_scaffold.dart';

// ══════════════════════════════════════════════════════════════
//  AvisosPage — Notificaciones y avisos académicos (local)
// ══════════════════════════════════════════════════════════════

enum TipoAviso { tarea, examen, recordatorio, info }

class Aviso {
  final String id;
  final String titulo;
  final String descripcion;
  final TipoAviso tipo;
  final DateTime fecha;
  bool leido;

  Aviso({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.fecha,
    this.leido = false,
  });
}

class AvisosPage extends StatefulWidget {
  const AvisosPage({super.key});
  @override
  State<AvisosPage> createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {
  final List<Aviso> _avisos = [
    Aviso(
      id: '1',
      titulo: 'Entrega próxima: Matemáticas',
      descripcion: 'El proyecto de Matemáticas vence en 2 días. No olvides subirlo.',
      tipo: TipoAviso.tarea,
      fecha: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Aviso(
      id: '2',
      titulo: 'Examen de Cálculo',
      descripcion: 'Tienes un examen programado para el 25 de marzo a las 9:00 AM.',
      tipo: TipoAviso.examen,
      fecha: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Aviso(
      id: '3',
      titulo: 'Recordatorio semanal',
      descripcion: 'Tienes 3 tareas pendientes esta semana. ¡Organiza tu tiempo!',
      tipo: TipoAviso.recordatorio,
      fecha: DateTime.now().subtract(const Duration(hours: 5)),
      leido: true,
    ),
    Aviso(
      id: '4',
      titulo: 'Bienvenido a UniCalendar',
      descripcion: 'Tu app académica está lista. Agrega tus materias y empieza a organizar tu semestre.',
      tipo: TipoAviso.info,
      fecha: DateTime.now().subtract(const Duration(days: 1)),
      leido: true,
    ),
    Aviso(
      id: '5',
      titulo: 'Lectura de Filosofía pendiente',
      descripcion: 'Recuerda completar la lectura del capítulo 4 antes del 25 de marzo.',
      tipo: TipoAviso.tarea,
      fecha: DateTime.now().subtract(const Duration(days: 2)),
      leido: true,
    ),
  ];

  int get _noLeidos => _avisos.where((a) => !a.leido).length;

  void _marcarLeido(Aviso a) {
    setState(() => a.leido = true);
  }

  void _marcarTodosLeidos() {
    setState(() {
      for (final a in _avisos) {
        a.leido = true;
      }
    });
  }

  void _eliminar(Aviso a) {
    setState(() => _avisos.removeWhere((x) => x.id == a.id));
  }

  Color _colorTipo(TipoAviso t) {
    switch (t) {
      case TipoAviso.tarea:
        return const Color(0xFF4A00E0);
      case TipoAviso.examen:
        return Colors.redAccent;
      case TipoAviso.recordatorio:
        return Colors.orange;
      case TipoAviso.info:
        return Colors.teal;
    }
  }

  IconData _iconoTipo(TipoAviso t) {
    switch (t) {
      case TipoAviso.tarea:
        return Icons.assignment_rounded;
      case TipoAviso.examen:
        return Icons.quiz_rounded;
      case TipoAviso.recordatorio:
        return Icons.alarm_rounded;
      case TipoAviso.info:
        return Icons.info_rounded;
    }
  }

  String _labelTipo(TipoAviso t) {
    switch (t) {
      case TipoAviso.tarea:
        return 'Tarea';
      case TipoAviso.examen:
        return 'Examen';
      case TipoAviso.recordatorio:
        return 'Recordatorio';
      case TipoAviso.info:
        return 'Info';
    }
  }

  String _tiempoRelativo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _avisos.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _avisos.length,
                    itemBuilder: (_, i) {
                      final a = _avisos[i];
                      return _AvisoCard(
                        aviso: a,
                        color: _colorTipo(a.tipo),
                        icono: _iconoTipo(a.tipo),
                        label: _labelTipo(a.tipo),
                        tiempo: _tiempoRelativo(a.fecha),
                        onTap: () => _marcarLeido(a),
                        onEliminar: () => _eliminar(a),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF007AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Avisos',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  if (_noLeidos > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$_noLeidos nuevo${_noLeidos > 1 ? 's' : ''}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]
                ],
              ),
              const Text('Notificaciones académicas',
                  style: TextStyle(color: Colors.white60, fontSize: 13)),
            ],
          ),
          const Spacer(),
          if (_noLeidos > 0)
            GestureDetector(
              onTap: _marcarTodosLeidos,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Leer todos',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_rounded,
                size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Sin avisos por ahora',
                style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text('Aquí aparecerán tus notificaciones',
                style: TextStyle(color: Colors.grey[350], fontSize: 13)),
          ],
        ),
      );
}

class _AvisoCard extends StatelessWidget {
  final Aviso aviso;
  final Color color;
  final IconData icono;
  final String label, tiempo;
  final VoidCallback onTap, onEliminar;

  const _AvisoCard({
    required this.aviso,
    required this.color,
    required this.icono,
    required this.label,
    required this.tiempo,
    required this.onTap,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(aviso.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onEliminar(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: aviso.leido ? Colors.white : color.withOpacity(0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: aviso.leido
                  ? Colors.grey.withOpacity(0.12)
                  : color.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icono, color: color, size: 20),
                ),
                const SizedBox(width: 12),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(label,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const Spacer(),
                          Text(tiempo,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(aviso.titulo,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: aviso.leido
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: Colors.black87)),
                      const SizedBox(height: 3),
                      Text(aviso.descripcion,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[500]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),

                // Punto de no leído
                if (!aviso.leido)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}