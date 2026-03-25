import 'package:flutter/material.dart';

// IMPORTA TUS PANTALLAS
import 'home_page.dart';
import 'calendario_page.dart';
import 'perfil_page.dart';
import 'login_screen.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {

  void _onItemTapped(int index) {
    Widget page;

    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const CalendarioPage();
        break;
      case 2:
        page = const PerfilPage();
        break;
      default:
        page = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

     appBar: PreferredSize(
  preferredSize: const Size.fromHeight(140),
  child: AppBar(
    elevation: 0,
    backgroundColor: const Color(0xFF4A00E0),
    automaticallyImplyLeading: false,
    flexibleSpace: Center(
      child: Image.asset(
        'assets/logo.png',
        height: 120,
        fit: BoxFit.contain,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: _logout,
      ),
    ],
  ),
),




      /// 🔷 CONTENIDO
      body: widget.child,

      /// 🔷 NAVBAR SOLO 3 OPCIONES
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF007AFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: "Inicio",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_rounded),
                  label: "Calendario",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: "Perfil",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
