import 'package:flutter/material.dart';
import 'main_scaffold.dart';
import 'tareas_page.dart';
import 'calendario_page.dart';
import 'perfil_page.dart';
import 'avisos_page.dart';
import 'progreso_page.dart';
import 'ajustes_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Datos demo locales
  static const _nombre = 'Javier';
  static const _carrera = 'Ingeniería de Sistemas';

  static final _tareasPendientes = [
    {'titulo': 'Proyecto de Matemáticas', 'materia': 'Matemáticas', 'fecha': '20/03/2026', 'prio': 'Alta'},
    {'titulo': 'Lectura Filosofía cap. 4', 'materia': 'Filosofía', 'fecha': '25/03/2026', 'prio': 'Baja'},
  ];

  static final _materias = [
    {'nombre': 'Matemáticas', 'icono': Icons.calculate_rounded, 'color': 0xFF4A00E0, 'tareas': 3},
    {'nombre': 'Historia', 'icono': Icons.history_edu_rounded, 'color': 0xFFE05000, 'tareas': 1},
    {'nombre': 'Filosofía', 'icono': Icons.menu_book_rounded, 'color': 0xFF007AFF, 'tareas': 2},
    {'nombre': 'Física', 'icono': Icons.science_rounded, 'color': 0xFF00897B, 'tareas': 1},
  ];

  @override
  Widget build(BuildContext context) {
    final hora = DateTime.now().hour;
    final saludo = hora < 12 ? 'Buenos días' : hora < 18 ? 'Buenas tardes' : 'Buenas noches';

    return MainScaffold(
      currentIndex: 0,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── SALUDO + BANNER ──
                _buildBanner(saludo),
                const SizedBox(height: 20),

                // ── STATS RÁPIDAS ──
                _buildStatsRow(context),
                const SizedBox(height: 24),

                // ── ACCESOS RÁPIDOS ──
                _SectionTitle(title: 'Accesos rápidos'),
                const SizedBox(height: 12),
                _buildAccesos(context),
                const SizedBox(height: 24),

                // ── TAREAS PRÓXIMAS ──
                _SectionTitle(
                  title: 'Próximas entregas',
                  actionLabel: 'Ver todo',
                  onAction: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TareasPage()),
                  ),
                ),
                const SizedBox(height: 12),
                ..._tareasPendientes.map((t) => _TareaProxima(tarea: t)),
                const SizedBox(height: 24),

                // ── MATERIAS ──
                _SectionTitle(title: 'Mis materias'),
                const SizedBox(height: 12),
                _buildMaterias(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(String saludo) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF007AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$saludo,',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
                Text(
                  _nombre,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _carrera,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.school_rounded,
                color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Tareas totales',
          value: '7',
          icon: Icons.assignment_rounded,
          color: const Color(0xFF4A00E0),
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TareasPage()),
          ),
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Pendientes',
          value: '2',
          icon: Icons.pending_actions_rounded,
          color: Colors.orange,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TareasPage()),
          ),
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Esta semana',
          value: '3',
          icon: Icons.date_range_rounded,
          color: Colors.teal,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CalendarioPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildAccesos(BuildContext context) {
    final items = [
      _AccesoItem(
        icon: Icons.task_alt_rounded,
        label: 'Tareas',
        color: const Color(0xFF4A00E0),
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TareasPage()),
        ),
      ),
      _AccesoItem(
        icon: Icons.calendar_month_rounded,
        label: 'Calendario',
        color: const Color(0xFF007AFF),
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CalendarioPage()),
        ),
      ),
      _AccesoItem(
        icon: Icons.person_rounded,
        label: 'Perfil',
        color: Colors.teal,
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PerfilPage()),
        ),
      ),
      _AccesoItem(
        icon: Icons.notifications_rounded,
        label: 'Avisos',
        color: Colors.orange,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AvisosPage())),
      ),
      _AccesoItem(
        icon: Icons.bar_chart_rounded,
        label: 'Progreso',
        color: Colors.green,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgresoPage())),
      ),
      _AccesoItem(
        icon: Icons.settings_rounded,
        label: 'Ajustes',
        color: Colors.grey,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AjustesPage())),
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: items
          .map((item) => _AccesoCard(item: item))
          .toList(),
    );
  }

  Widget _buildMaterias() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: _materias.map((m) {
        final color = Color(m['color'] as int);
        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(m['icono'] as IconData, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      m['nombre'] as String,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${m['tareas']} tareas',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────── SUBWIDGETS ───────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionTitle(
      {required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A00E0),
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.18)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 5),
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
}

class _AccesoItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AccesoItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}

class _AccesoCard extends StatelessWidget {
  final _AccesoItem item;
  const _AccesoCard({required this.item});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: item.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(item.label,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ),
      );
}

class _TareaProxima extends StatelessWidget {
  final Map<String, dynamic> tarea;
  const _TareaProxima({required this.tarea});

  @override
  Widget build(BuildContext context) {
    final prio = tarea['prio'] as String;
    final prioColor = prio == 'Alta'
        ? Colors.redAccent
        : prio == 'Media'
            ? Colors.orange
            : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: prioColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tarea['titulo'] as String,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text(tarea['materia'] as String,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: prioColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(prio,
                    style: TextStyle(
                        fontSize: 10,
                        color: prioColor,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 4),
              Text(tarea['fecha'] as String,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }
}