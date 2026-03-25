import 'package:flutter/material.dart';
import 'main_scaffold.dart';

// ══════════════════════════════════════════════════════════════
//  ProgresoPage — Progreso académico (local)
//  Muestra estadísticas, progreso por materia y resumen general
// ══════════════════════════════════════════════════════════════

class _Materia {
  final String nombre;
  final Color color;
  final IconData icono;
  final int total;
  final int completadas;

  const _Materia({
    required this.nombre,
    required this.color,
    required this.icono,
    required this.total,
    required this.completadas,
  });

  double get porcentaje => total == 0 ? 0 : completadas / total;
}

class ProgresoPage extends StatefulWidget {
  const ProgresoPage({super.key});
  @override
  State<ProgresoPage> createState() => _ProgresoPageState();
}

class _ProgresoPageState extends State<ProgresoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  final List<_Materia> _materias = const [
    _Materia(nombre: 'Matemáticas', color: Color(0xFF4A00E0), icono: Icons.calculate_rounded, total: 5, completadas: 3),
    _Materia(nombre: 'Historia', color: Color(0xFFE05000), icono: Icons.history_edu_rounded, total: 3, completadas: 3),
    _Materia(nombre: 'Filosofía', color: Color(0xFF007AFF), icono: Icons.menu_book_rounded, total: 4, completadas: 1),
    _Materia(nombre: 'Física', color: Color(0xFF00897B), icono: Icons.science_rounded, total: 3, completadas: 2),
    _Materia(nombre: 'Cálculo', color: Color(0xFFD00060), icono: Icons.functions_rounded, total: 2, completadas: 0),
  ];

  int get _totalTareas => _materias.fold(0, (s, m) => s + m.total);
  int get _completadas => _materias.fold(0, (s, m) => s + m.completadas);
  int get _pendientes => _totalTareas - _completadas;
  double get _progresoGeneral =>
      _totalTareas == 0 ? 0 : _completadas / _totalTareas;

  // Semanas de actividad simuladas (0.0 - 1.0)
  final List<double> _actividad = [
    0.2, 0.5, 0.8, 0.4, 0.9, 0.6, 0.3,
    0.7, 1.0, 0.5, 0.8, 0.4,
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

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
                  const SizedBox(height: 20),

                  // ── STATS ──
                  _buildStats(),
                  const SizedBox(height: 24),

                  // ── PROGRESO GENERAL ──
                  _buildProgresoGeneral(),
                  const SizedBox(height: 24),

                  // ── ACTIVIDAD SEMANAL ──
                  _buildSeccion('Actividad semanal'),
                  const SizedBox(height: 12),
                  _buildGraficoActividad(),
                  const SizedBox(height: 24),

                  // ── POR MATERIA ──
                  _buildSeccion('Progreso por materia'),
                  const SizedBox(height: 12),
                  ..._materias.map((m) => _MateriaCard(materia: m, anim: _anim)),
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
                  Text('Mi Progreso',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text('Seguimiento académico del semestre',
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
              child: const Icon(Icons.bar_chart_rounded,
                  color: Colors.white, size: 30),
            ),
          ],
        ),
      );

  Widget _buildStats() => Row(
        children: [
          _StatBox('Total', '$_totalTareas', Icons.assignment_rounded, const Color(0xFF4A00E0)),
          const SizedBox(width: 10),
          _StatBox('Hechas', '$_completadas', Icons.check_circle_rounded, Colors.green),
          const SizedBox(width: 10),
          _StatBox('Pendientes', '$_pendientes', Icons.pending_actions_rounded, Colors.orange),
        ],
      );

  Widget _buildProgresoGeneral() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progreso general del semestre',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => Text(
                    '${(_progresoGeneral * 100 * _anim.value).toInt()}%',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A00E0)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => LinearProgressIndicator(
                  value: _progresoGeneral * _anim.value,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4A00E0)),
                  minHeight: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _LeyendaDot(Colors.green, '$_completadas completadas'),
                const SizedBox(width: 16),
                _LeyendaDot(Colors.orange, '$_pendientes pendientes'),
              ],
            ),
          ],
        ),
      );

  Widget _buildGraficoActividad() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Últimas ${_actividad.length} semanas',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _actividad.asMap().entries.map((e) {
                  final val = e.value;
                  final color = val > 0.7
                      ? const Color(0xFF4A00E0)
                      : val > 0.4
                          ? const Color(0xFF007AFF)
                          : Colors.grey.shade300;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: AnimatedBuilder(
                        animation: _anim,
                        builder: (_, __) => Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: Duration(
                                  milliseconds: 600 + e.key * 50),
                              curve: Curves.easeOut,
                              height: 70 * val * _anim.value,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );

  Widget _buildSeccion(String titulo) => Text(titulo,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87));
}

// ─────────────── SUBWIDGETS ───────────────

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
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
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ]),
        ),
      );
}

class _LeyendaDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LeyendaDot(this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ]);
}

class _MateriaCard extends StatelessWidget {
  final _Materia materia;
  final Animation<double> anim;
  const _MateriaCard({required this.materia, required this.anim});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: materia.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(materia.icono, color: materia.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(materia.nombre,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87)),
                      AnimatedBuilder(
                        animation: anim,
                        builder: (_, __) => Text(
                          '${(materia.porcentaje * 100 * anim.value).toInt()}%',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: materia.color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedBuilder(
                      animation: anim,
                      builder: (_, __) => LinearProgressIndicator(
                        value: materia.porcentaje * anim.value,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            materia.color),
                        minHeight: 7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${materia.completadas} de ${materia.total} tareas completadas',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}