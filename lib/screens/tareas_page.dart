import 'package:flutter/material.dart';
import 'main_scaffold.dart';

// ══════════════════════════════════════════════════════════════
//  TareasPage — Funcionalidad completa local (sin base de datos)
//  Incluye: agregar, editar, eliminar, completar, filtrar,
//           prioridad, materia, fecha con date picker
// ══════════════════════════════════════════════════════════════

enum Prioridad { alta, media, baja }

enum FiltroTarea { todas, pendientes, completadas }

class Tarea {
  String id;
  String titulo;
  String materia;
  DateTime fecha;
  Prioridad prioridad;
  bool completada;
  String? descripcion;

  Tarea({
    required this.id,
    required this.titulo,
    required this.materia,
    required this.fecha,
    required this.prioridad,
    this.completada = false,
    this.descripcion,
  });
}

class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage>
    with SingleTickerProviderStateMixin {
  final List<Tarea> _tareas = [
    Tarea(
      id: '1',
      titulo: 'Proyecto de Matemáticas',
      materia: 'Matemáticas',
      fecha: DateTime(2026, 3, 20),
      prioridad: Prioridad.alta,
    ),
    Tarea(
      id: '2',
      titulo: 'Ensayo de Historia',
      materia: 'Historia',
      fecha: DateTime(2026, 3, 22),
      prioridad: Prioridad.media,
      completada: true,
    ),
    Tarea(
      id: '3',
      titulo: 'Lectura Filosofía cap. 4',
      materia: 'Filosofía',
      fecha: DateTime(2026, 3, 25),
      prioridad: Prioridad.baja,
      descripcion: 'Leer y hacer resumen de 1 página',
    ),
  ];

  FiltroTarea _filtro = FiltroTarea.todas;
  late AnimationController _fabCtrl;
  late Animation<double> _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fabAnim =
        CurvedAnimation(parent: _fabCtrl, curve: Curves.easeOut);
    _fabCtrl.forward();
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    super.dispose();
  }

  List<Tarea> get _tareasFiltradas {
    switch (_filtro) {
      case FiltroTarea.pendientes:
        return _tareas.where((t) => !t.completada).toList();
      case FiltroTarea.completadas:
        return _tareas.where((t) => t.completada).toList();
      case FiltroTarea.todas:
        return List.from(_tareas);
    }
  }

  int get _pendientes => _tareas.where((t) => !t.completada).length;
  int get _completadas => _tareas.where((t) => t.completada).length;

  // ─────────────── ACCIONES ───────────────

  void _toggleCompletada(Tarea t) {
    setState(() => t.completada = !t.completada);
  }

  void _eliminar(Tarea t) {
    setState(() => _tareas.removeWhere((x) => x.id == t.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarea "${t.titulo}" eliminada'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: Colors.white,
          onPressed: () => setState(() => _tareas.add(t)),
        ),
      ),
    );
  }

  void _abrirFormulario({Tarea? tarea}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TareaFormSheet(
        tarea: tarea,
        onGuardar: (nueva) {
          setState(() {
            if (tarea != null) {
              final i = _tareas.indexWhere((t) => t.id == tarea.id);
              if (i != -1) _tareas[i] = nueva;
            } else {
              _tareas.insert(0, nueva);
            }
          });
        },
      ),
    );
  }

  // ─────────────── UI ───────────────

  @override
  Widget build(BuildContext context) {
    final lista = _tareasFiltradas;

    return MainScaffold(
      currentIndex: 0,
      child: Column(
        children: [
          // ── HEADER CON STATS ──
          _buildHeader(),

          // ── FILTROS ──
          _buildFiltros(),

          // ── LISTA ──
          Expanded(
            child: lista.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: lista.length,
                    itemBuilder: (_, i) => _TareaCard(
                      tarea: lista[i],
                      onToggle: () => _toggleCompletada(lista[i]),
                      onEditar: () => _abrirFormulario(tarea: lista[i]),
                      onEliminar: () => _eliminar(lista[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final total = _tareas.length;
    final progreso = total == 0 ? 0.0 : _completadas / total;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mis Tareas',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Gestiona tus actividades académicas',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              // FAB inline en header
              GestureDetector(
                onTap: () => _abrirFormulario(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _StatChip('Total', '$total', Colors.white),
              const SizedBox(width: 10),
              _StatChip('Pendientes', '$_pendientes', Colors.orangeAccent),
              const SizedBox(width: 10),
              _StatChip('Completadas', '$_completadas', Colors.greenAccent),
            ],
          ),
          const SizedBox(height: 14),
          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progreso general',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('${(progreso * 100).toInt()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progreso,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: FiltroTarea.values.map((f) {
          final activo = _filtro == f;
          final label = f == FiltroTarea.todas
              ? 'Todas'
              : f == FiltroTarea.pendientes
                  ? 'Pendientes'
                  : 'Completadas';
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filtro = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: activo
                      ? const Color(0xFF4A00E0)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: activo
                        ? const Color(0xFF4A00E0)
                        : Colors.grey.withOpacity(0.2),
                  ),
                  boxShadow: activo
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF4A00E0).withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activo ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _filtro == FiltroTarea.completadas
                ? 'Aún no has completado tareas'
                : 'No hay tareas aquí',
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca + para agregar una nueva',
            style: TextStyle(color: Colors.grey[350], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────── STAT CHIP ───────────────

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        ),
      );
}

// ─────────────── TAREA CARD ───────────────

class _TareaCard extends StatelessWidget {
  final Tarea tarea;
  final VoidCallback onToggle, onEditar, onEliminar;

  const _TareaCard({
    required this.tarea,
    required this.onToggle,
    required this.onEditar,
    required this.onEliminar,
  });

  Color get _prioColor {
    switch (tarea.prioridad) {
      case Prioridad.alta:
        return Colors.redAccent;
      case Prioridad.media:
        return Colors.orange;
      case Prioridad.baja:
        return Colors.green;
    }
  }

  String get _prioLabel {
    switch (tarea.prioridad) {
      case Prioridad.alta:
        return 'Alta';
      case Prioridad.media:
        return 'Media';
      case Prioridad.baja:
        return 'Baja';
    }
  }

  bool get _vencida =>
      !tarea.completada && tarea.fecha.isBefore(DateTime.now());

  String _formatFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (_, val, child) => Opacity(
        opacity: val,
        child: Transform.translate(
            offset: Offset(0, 16 * (1 - val)), child: child),
      ),
      child: Dismissible(
        key: Key(tarea.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_rounded,
              color: Colors.white, size: 26),
        ),
        onDismissed: (_) => onEliminar(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _prioColor.withOpacity(tarea.completada ? 0.05 : 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Barra lateral de prioridad
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    color: tarea.completada
                        ? Colors.grey.shade300
                        : _prioColor,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: onToggle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: tarea.completada
                                ? Colors.green
                                : Colors.transparent,
                            border: Border.all(
                              color: tarea.completada
                                  ? Colors.green
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: tarea.completada
                              ? const Icon(Icons.check_rounded,
                                  size: 16, color: Colors.white)
                              : null,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Contenido
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tarea.titulo,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: tarea.completada
                                    ? Colors.grey
                                    : Colors.black87,
                                decoration: tarea.completada
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (tarea.descripcion != null &&
                                tarea.descripcion!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                tarea.descripcion!,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Materia
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A00E0)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tarea.materia,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF4A00E0),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Prioridad
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _prioColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _prioLabel,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: _prioColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Fecha
                                Icon(
                                  _vencida
                                      ? Icons.warning_rounded
                                      : Icons.calendar_today_rounded,
                                  size: 11,
                                  color: _vencida
                                      ? Colors.redAccent
                                      : Colors.grey[400],
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _formatFecha(tarea.fecha),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _vencida
                                          ? Colors.redAccent
                                          : Colors.grey[400]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Editar
                      IconButton(
                        onPressed: onEditar,
                        icon: Icon(Icons.edit_rounded,
                            size: 18, color: Colors.grey[400]),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────── FORMULARIO BOTTOM SHEET ───────────────

class _TareaFormSheet extends StatefulWidget {
  final Tarea? tarea;
  final void Function(Tarea) onGuardar;

  const _TareaFormSheet({this.tarea, required this.onGuardar});

  @override
  State<_TareaFormSheet> createState() => _TareaFormSheetState();
}

class _TareaFormSheetState extends State<_TareaFormSheet> {
  late TextEditingController _titulo;
  late TextEditingController _materia;
  late TextEditingController _desc;
  late DateTime _fecha;
  late Prioridad _prioridad;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final t = widget.tarea;
    _titulo = TextEditingController(text: t?.titulo ?? '');
    _materia = TextEditingController(text: t?.materia ?? '');
    _desc = TextEditingController(text: t?.descripcion ?? '');
    _fecha = t?.fecha ?? DateTime.now().add(const Duration(days: 3));
    _prioridad = t?.prioridad ?? Prioridad.media;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _materia.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4A00E0),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final nueva = Tarea(
      id: widget.tarea?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: _titulo.text.trim(),
      materia: _materia.text.trim(),
      fecha: _fecha,
      prioridad: _prioridad,
      completada: widget.tarea?.completada ?? false,
      descripcion: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );
    widget.onGuardar(nueva);
    Navigator.pop(context);
  }

  String _formatFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final esEditar = widget.tarea != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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

            Text(
              esEditar ? 'Editar tarea' : 'Nueva tarea',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Título
            _Campo(
              controller: _titulo,
              label: 'Título de la tarea',
              icon: Icons.task_alt_rounded,
              validator: (v) =>
                  v == null || v.isEmpty ? 'El título es obligatorio' : null,
            ),

            // Materia
            _Campo(
              controller: _materia,
              label: 'Materia',
              icon: Icons.school_outlined,
              validator: (v) =>
                  v == null || v.isEmpty ? 'La materia es obligatoria' : null,
            ),

            // Descripción (opcional)
            _Campo(
              controller: _desc,
              label: 'Descripción (opcional)',
              icon: Icons.notes_rounded,
            ),

            // Fecha
            GestureDetector(
              onTap: _pickFecha,
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Color(0xFF4A00E0), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Fecha de entrega: ${_formatFecha(_fecha)}',
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black87),
                    ),
                    const Spacer(),
                    Icon(Icons.edit_calendar_rounded,
                        color: Colors.grey[400], size: 18),
                  ],
                ),
              ),
            ),

            // Prioridad
            const Text('Prioridad',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Row(
              children: Prioridad.values.map((p) {
                final activo = _prioridad == p;
                final color = p == Prioridad.alta
                    ? Colors.redAccent
                    : p == Prioridad.media
                        ? Colors.orange
                        : Colors.green;
                final label = p == Prioridad.alta
                    ? 'Alta'
                    : p == Prioridad.media
                        ? 'Media'
                        : 'Baja';
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _prioridad = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: activo ? color : color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: activo ? color : color.withOpacity(0.3)),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: activo ? Colors.white : color,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A00E0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  esEditar ? 'Guardar cambios' : 'Agregar tarea',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  const _Campo({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon:
                Icon(icon, color: const Color(0xFF4A00E0), size: 20),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF4A00E0), width: 2)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      );
}