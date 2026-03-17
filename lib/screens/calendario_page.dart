import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Ejemplo de tareas por fecha
  final Map<DateTime, List<String>> tareasPorFecha = {
    DateTime.utc(2026, 3, 20): ["Proyecto de Matemáticas"],
    DateTime.utc(2026, 3, 22): ["Ensayo de Historia", "Lectura Filosofía"],
  };

  List<String> _getTareasDelDia(DateTime day) {
    return tareasPorFecha[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final tareasDelDia = _getTareasDelDia(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendario Académico"),
        backgroundColor: const Color(0xFF145DA0),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2027, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: tareasDelDia.isEmpty
                ? const Center(child: Text("No hay tareas para este día"))
                : ListView.builder(
                    itemCount: tareasDelDia.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.assignment),
                          title: Text(tareasDelDia[index]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
