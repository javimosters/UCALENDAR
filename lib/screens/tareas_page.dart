import 'package:flutter/material.dart';

class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final List<Map<String, dynamic>> tareas = [
    {"titulo": "Proyecto de Matemáticas", "fecha": "20/03/2026", "completada": false},
    {"titulo": "Ensayo de Historia", "fecha": "22/03/2026", "completada": true},
  ];

  void agregarTarea(String titulo, String fecha) {
    setState(() {
      tareas.add({"titulo": titulo, "fecha": fecha, "completada": false});
    });
  }

  void marcarCompletada(int index) {
    setState(() {
      tareas[index]["completada"] = !tareas[index]["completada"];
    });
  }

  void eliminarTarea(int index) {
    setState(() {
      tareas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Tareas"),
        backgroundColor: const Color(0xFF145DA0),
      ),
      body: ListView.builder(
        itemCount: tareas.length,
        itemBuilder: (context, index) {
          final tarea = tareas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: ListTile(
              leading: Icon(
                tarea["completada"] ? Icons.check_circle : Icons.circle_outlined,
                color: tarea["completada"] ? Colors.green : Colors.grey,
              ),
              title: Text(
                tarea["titulo"],
                style: TextStyle(
                  decoration: tarea["completada"] ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text("Fecha entrega: ${tarea["fecha"]}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => eliminarTarea(index),
              ),
              onTap: () => marcarCompletada(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00C853),
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final tituloController = TextEditingController();
              final fechaController = TextEditingController();
              return AlertDialog(
                title: const Text("Nueva Tarea"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(labelText: "Título"),
                    ),
                    TextField(
                      controller: fechaController,
                      decoration: const InputDecoration(labelText: "Fecha"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancelar"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    child: const Text("Agregar"),
                    onPressed: () {
                      agregarTarea(tituloController.text, fechaController.text);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
