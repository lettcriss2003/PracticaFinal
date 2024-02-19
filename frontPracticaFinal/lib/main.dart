import 'package:flutter/material.dart';
import 'package:noticias/views/admin_view.dart';
import 'package:noticias/views/comentariosListarView.dart';
import 'package:noticias/views/editAdmin.dart';
import 'package:noticias/views/editUser.dart';
import 'package:noticias/views/mapView.dart';
import 'package:noticias/views/mapViewInd.dart';
import 'package:noticias/views/sessionview.dart';
import 'package:noticias/views/comentarioView.dart';
import 'package:noticias/views/registerView.dart';
import 'package:noticias/views/exception/Page404.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SessionView(),
      initialRoute: "/",
      routes: {
        "/home": (context) => const SessionView(),
        "/registrarse": (context) => const RegisterView(),
        "/comments": (context) => const ComentarioView(),
        "/principal": (context) => NoticiasView(),
        "/editarPerfil": (context) => EditarPerfilScreen(),
        "/editarAdmin": (context) => EditarAdminScreen(),
        "/mapa": (context) => MapaComentariosView(),
        "/mapaInd": (context) => MapViewInd(),
        "/adminView": (context) => AdminView(),
      },
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Page404(),
      ),
    );
  }
}
