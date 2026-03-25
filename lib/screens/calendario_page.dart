import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'main_scaffold.dart';

class _TareaCalendario {
  final String id;
  final String titulo;
  final String materia;
  final Color color;
  final IconData icono;
  _TareaCalendario({required this.id, required this.titulo, required this.materia, required this.color, required this.icono});
}

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});
  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _formato = CalendarFormat.month;
  late AnimationController _listCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  final Map<DateTime, List<_TareaCalendario>> _tareas = {
    DateTime.utc(2026, 3, 20): [_TareaCalendario(id:'1', titulo:'Proyecto de Matemáticas', materia:'Matemáticas', color:Color(0xFF4A00E0), icono:Icons.calculate_rounded)],
    DateTime.utc(2026, 3, 22): [
      _TareaCalendario(id:'2', titulo:'Ensayo de Historia', materia:'Historia', color:Color(0xFFE05000), icono:Icons.history_edu_rounded),
      _TareaCalendario(id:'3', titulo:'Lectura Filosofía', materia:'Filosofía', color:Color(0xFF007AFF), icono:Icons.menu_book_rounded),
    ],
    DateTime.utc(2026, 3, 25): [_TareaCalendario(id:'4', titulo:'Examen de Cálculo', materia:'Matemáticas', color:Color(0xFFD00060), icono:Icons.quiz_rounded)],
  };

  DateTime _toUtc(DateTime d) => DateTime.utc(d.year, d.month, d.day);
  List<_TareaCalendario> _getTareas(DateTime day) => _tareas[_toUtc(day)] ?? [];
  int get _totalTareas => _tareas.values.fold(0, (s, l) => s + l.length);

  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _listCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _listCtrl, curve: Curves.easeOut);
    _listCtrl.forward();
  }

  @override
  void dispose() { _listCtrl.dispose(); super.dispose(); }

  void _onDaySelected(DateTime sel, DateTime focused) {
    setState(() { _selectedDay = sel; _focusedDay = focused; });
    _listCtrl..reset()..forward();
  }

  void _eliminarTarea(DateTime day, String id) {
    final key = _toUtc(day);
    setState(() {
      _tareas[key]?.removeWhere((t) => t.id == id);
      if (_tareas[key]?.isEmpty ?? false) _tareas.remove(key);
    });
  }

  void _agregarTarea(DateTime day) {
    final tituloCtrl = TextEditingController();
    final materiaCtrl = TextEditingController();
    Color colorSel = const Color(0xFF4A00E0);
    final colores = [const Color(0xFF4A00E0), const Color(0xFF007AFF), const Color(0xFFE05000), const Color(0xFFD00060), const Color(0xFF00897B), Colors.orange];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setInner) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const Text('Agregar tarea al día', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildInput(tituloCtrl, 'Título', Icons.task_alt_rounded),
              _buildInput(materiaCtrl, 'Materia', Icons.school_outlined),
              const Text('Color', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(children: colores.map((c) => GestureDetector(
                onTap: () => setInner(() => colorSel = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                    border: Border.all(color: colorSel == c ? Colors.black87 : Colors.transparent, width: 2.5)),
                ),
              )).toList()),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (tituloCtrl.text.trim().isEmpty || materiaCtrl.text.trim().isEmpty) return;
                    final key = _toUtc(day);
                    setState(() {
                      _tareas[key] = [...(_tareas[key] ?? []), _TareaCalendario(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        titulo: tituloCtrl.text.trim(),
                        materia: materiaCtrl.text.trim(),
                        color: colorSel,
                        icono: Icons.assignment_rounded,
                      )];
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A00E0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  child: const Text('Agregar tarea', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String label, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(controller: c, decoration: InputDecoration(
      labelText: label, prefixIcon: Icon(icon, color: const Color(0xFF4A00E0), size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4A00E0), width: 2)),
      filled: true, fillColor: Colors.grey.shade50,
    )),
  );

  @override
  Widget build(BuildContext context) {
    final diaActivo = _selectedDay ?? _focusedDay;
    final tareasHoy = _getTareas(diaActivo);
    return MainScaffold(
      currentIndex: 1,
      child: Column(children: [
        _buildTopHeader(),
        Expanded(child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(children: [
              const SizedBox(height: 16),
              _buildCalendar(),
              const SizedBox(height: 20),
              _buildDayHeader(diaActivo, tareasHoy.length),
              const SizedBox(height: 12),
              _buildLista(tareasHoy, diaActivo),
              const SizedBox(height: 32),
            ]),
          )),
        )),
      ]),
    );
  }

  Widget _buildTopHeader() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF007AFF)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    child: Row(children: [
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Mi Calendario', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Organiza tus entregas', style: TextStyle(color: Colors.white60, fontSize: 13)),
      ]),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          const Icon(Icons.assignment_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text('$_totalTareas tareas', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
    ]),
  );

  Widget _buildCalendar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF007AFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(26),
      boxShadow: [BoxShadow(color: const Color(0xFF4A00E0).withOpacity(0.32), blurRadius: 24, offset: const Offset(0, 10))],
    ),
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          _Toggle(label: 'Semana', activo: _formato == CalendarFormat.week, onTap: () => setState(() => _formato = CalendarFormat.week)),
          const SizedBox(width: 8),
          _Toggle(label: 'Mes', activo: _formato == CalendarFormat.month, onTap: () => setState(() => _formato = CalendarFormat.month)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 10),
        child: TableCalendar<_TareaCalendario>(
          firstDay: DateTime.utc(2025, 1, 1), lastDay: DateTime.utc(2027, 12, 31),
          focusedDay: _focusedDay, calendarFormat: _formato,
          selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
          eventLoader: _getTareas,
          onDaySelected: _onDaySelected,
          onFormatChanged: (f) => setState(() => _formato = f),
          headerStyle: const HeaderStyle(
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            formatButtonVisible: false,
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            headerPadding: EdgeInsets.symmetric(vertical: 10),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            weekendStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: const TextStyle(color: Colors.white),
            weekendTextStyle: const TextStyle(color: Colors.white),
            outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            todayDecoration: BoxDecoration(color: Colors.orange.withOpacity(0.85), shape: BoxShape.circle),
            todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            selectedDecoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            selectedTextStyle: const TextStyle(color: Color(0xFF4A00E0), fontWeight: FontWeight.bold),
            markerDecoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
            markersMaxCount: 3, markerSize: 5.5, markerMargin: const EdgeInsets.symmetric(horizontal: 1),
          ),
        ),
      ),
    ]),
  );

  Widget _buildDayHeader(DateTime day, int count) {
    final esHoy = isSameDay(day, DateTime.now());
    const dias = ['Lun','Mar','Mié','Jue','Vie','Sáb','Dom'];
    const meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(esHoy ? 'Hoy' : dias[day.weekday - 1], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text('${day.day} de ${meses[day.month - 1]}', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ]),
        const Spacer(),
        GestureDetector(
          onTap: () => _agregarTarea(day),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF007AFF)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF4A00E0).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: const Row(children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text('Agregar', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildLista(List<_TareaCalendario> tareas, DateTime day) {
    if (tareas.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.grey.withOpacity(0.14))),
          child: Column(children: [
            Icon(Icons.event_available_rounded, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Sin tareas este día', style: TextStyle(color: Colors.grey[400], fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Toca "Agregar" para añadir una', style: TextStyle(color: Colors.grey[350], fontSize: 13)),
          ]),
        ),
      );
    }
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: tareas.asMap().entries.map((e) {
            final t = e.value;
            return Dismissible(
              key: Key(t.id),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
              ),
              onDismissed: (_) => _eliminarTarea(day, t.id),
              child: _buildTareaCard(t, e.key),
            );
          }).toList()),
        ),
      ),
    );
  }

  Widget _buildTareaCard(_TareaCalendario t, int index) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 280 + index * 90),
    curve: Curves.easeOut,
    builder: (_, val, child) => Opacity(opacity: val, child: Transform.translate(offset: Offset(0, 18*(1-val)), child: child)),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: t.color.withOpacity(0.13), blurRadius: 16, offset: const Offset(0, 5))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(children: [
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: t.color)),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: t.color.withOpacity(0.1), borderRadius: BorderRadius.circular(13)),
                child: Icon(t.icono, color: t.color, size: 20)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 3),
                Text(t.materia, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ])),
              Icon(Icons.swipe_left_rounded, color: Colors.grey[300], size: 18),
            ]),
          ),
        ]),
      ),
    ),
  );
}

class _Toggle extends StatelessWidget {
  final String label; final bool activo; final VoidCallback onTap;
  const _Toggle({required this.label, required this.activo, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: activo ? Colors.white : Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: activo ? const Color(0xFF4A00E0) : Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    ),
  );
}