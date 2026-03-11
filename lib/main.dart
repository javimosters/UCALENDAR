import 'package:flutter/material.dart';

void main() {
  runApp(UniPlannerApp());
}

class UniPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniPlanner',
      debugShowCheckedModeBanner: false,
      home: NuevaActividadView(),
    );
  }
}

////////////////////////////////
/// 1 LOGIN
////////////////////////////////

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inicio de sesión")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.school, size: 100),
            TextField(decoration: InputDecoration(labelText: "Correo")),
            TextField(decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Iniciar sesión")),
            TextButton(onPressed: () {}, child: Text("¿No tienes cuenta?"))
          ],
        ),
      ),
    );
  }
}

////////////////////////////////
/// 2 REGISTRO
////////////////////////////////

class RegistroView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(decoration: InputDecoration(labelText: "Nombre")),
            TextField(decoration: InputDecoration(labelText: "Apellido")),
            TextField(decoration: InputDecoration(labelText: "Teléfono")),
            TextField(decoration: InputDecoration(labelText: "Carrera")),
            TextField(decoration: InputDecoration(labelText: "Email institucional")),
            TextField(decoration: InputDecoration(labelText: "Email")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Crear cuenta"))
          ],
        ),
      ),
    );
  }
}

////////////////////////////////
/// 3 MENU PRINCIPAL
////////////////////////////////

class MenuView extends StatelessWidget {
  Widget boton(String texto, IconData icono) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icono, size: 40),
            Text(texto)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("UniPlanner")),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          boton("Evento", Icons.event),
          boton("Perfil", Icons.person),
          boton("Horario", Icons.schedule),
          boton("Calendario", Icons.calendar_month),
          boton("Tareas", Icons.task),
          boton("Entregas", Icons.upload),
        ],
      ),
    );
  }
}

////////////////////////////////
/// 4 NUEVA ACTIVIDAD
////////////////////////////////

class NuevaActividadView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro académico")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            DropdownButtonFormField(
              items: [],
              onChanged: (value) {},
              decoration: InputDecoration(labelText: "Seleccionar materia"),
            ),
            Text("Tipo"),
            Row(
              children: [
                Checkbox(value: false, onChanged: (v) {}),
                Text("Tarea"),
                Checkbox(value: false, onChanged: (v) {}),
                Text("Trabajo"),
                Checkbox(value: false, onChanged: (v) {}),
                Text("Evaluación"),
              ],
            ),
            TextField(decoration: InputDecoration(labelText: "Título")),
            TextField(decoration: InputDecoration(labelText: "Descripción")),
            TextField(decoration: InputDecoration(labelText: "Fecha de entrega")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Guardar"))
          ],
        ),
      ),
    );
  }
}

////////////////////////////////
/// 5 CARGAR TAREA
////////////////////////////////

class CargarTareaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cargar tarea")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 120),
          ElevatedButton(onPressed: () {}, child: Text("Subir")),
          ElevatedButton(onPressed: () {}, child: Text("Actualizar tarea"))
        ],
      ),
    );
  }
}

////////////////////////////////
/// 6 ACTUALIZAR TAREA
////////////////////////////////

class ActualizarTareaView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Actualizar tarea")),
      body: Column(
        children: [
          CheckboxListTile(
            value: false,
            onChanged: (v) {},
            title: Text("Completada"),
          ),
          CheckboxListTile(
            value: false,
            onChanged: (v) {},
            title: Text("Subir de nuevo"),
          )
        ],
      ),
    );
  }
}

////////////////////////////////
/// 7 PERFIL
////////////////////////////////

class PerfilView extends StatelessWidget {
  Widget info(String label) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Perfil de usuario")),
      body: ListView(
        children: [
          info("Nombre"),
          info("Apellido"),
          info("Teléfono"),
          info("Email institucional"),
          info("Email"),
        ],
      ),
    );
  }
}

////////////////////////////////
/// 8 TAREAS POR DIA
////////////////////////////////

class TareasView extends StatelessWidget {
  Widget dia(String nombre) {
    return ExpansionTile(
      title: Text(nombre),
      children: [
        ListTile(title: Text("Tarea ejemplo")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tareas")),
      body: ListView(
        children: [
          dia("Lunes"),
          dia("Martes"),
          dia("Miércoles"),
          dia("Jueves"),
          dia("Viernes"),
          dia("Sábado"),
        ],
      ),
    );
  }
}

////////////////////////////////
/// 9 HORARIO
////////////////////////////////

class HorarioView extends StatelessWidget {
  Widget clase(String hora, String materia) {
    return ListTile(
      leading: Text(hora),
      title: Text(materia),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Horario")),
      body: ListView(
        children: [
          clase("8:30 AM - 9:30 AM", "Cálculo"),
          clase("9:30 AM - 11:30 AM", "Programación"),
          clase("12:30 PM - 1:45 PM", "Inglés"),
        ],
      ),
    );
  }
}

////////////////////////////////
/// 10 CALENDARIO
////////////////////////////////

class CalendarioView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendario")),
      body: GridView.count(
        crossAxisCount: 3,
        children: [
          Card(child: Center(child: Text("Enero"))),
          Card(child: Center(child: Text("Febrero"))),
          Card(child: Center(child: Text("Marzo"))),
          Card(child: Center(child: Text("Abril"))),
          Card(child: Center(child: Text("Mayo"))),
          Card(child: Center(child: Text("Junio"))),
          Card(child: Center(child: Text("Julio"))),
          Card(child: Center(child: Text("Agosto"))),
          Card(child: Center(child: Text("Septiembre"))),
          Card(child: Center(child: Text("Octubre"))),
          Card(child: Center(child: Text("Noviembre"))),
          Card(child: Center(child: Text("Diciembre"))),
        ],
      ),
    );
  }
}

////////////////////////////////
/// 11 EVENTOS
////////////////////////////////

class EventosView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Eventos")),
      body: Card(
        margin: EdgeInsets.all(20),
        child: ListTile(
          title: Text("Programación"),
          subtitle: Text("Mañana 12:00 AM - Evento en curso"),
        ),
      ),
    );
  }
}
