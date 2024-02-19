import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const SessionView(),
    );
  }
}

class SessionView extends StatefulWidget {
  const SessionView({Key? key}) : super(key: key);

  @override
  _SessionViewState createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final correo = _emailController.text;
    final clave = _passwordController.text;

    if (correo.isEmpty || clave.isEmpty) {
      SnackBar snackBar = SnackBar(
        content: const Text('Por favor, ingrese correo y contraseña'),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // Validar correo y clave aquí
    if (!_isValidEmail(correo)) {
      SnackBar snackBar = SnackBar(
        content: const Text('Por favor, ingrese un correo válido'),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    FacadeService fs = FacadeService();
    Map<String, String> mapa = {
      "correo": correo,
      "clave": clave,
    };
    fs.inicioSesion(mapa).then((value) async {
      if (value.code == 200) {
        Utiles utilidades = Utiles();
        utilidades.saveValue('token', value.datos['token']);
        utilidades.saveValue('external', value.datos['external']);
        utilidades.saveValue('usuario', value.datos['usuario']);
        FacadeService fs = FacadeService();
        var response = await fs.obtenerUsuario(value.datos['external']);
        if (response.datos['rol']['nombre'] != "administrador") {
          SnackBar snackBar = SnackBar(
            content: Text(
                "Inicio de sesión correcto! BIENVENIDO ${value.datos['usuario']}"),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.pushNamed(context, "/principal");
        }else{
          SnackBar snackBar = SnackBar(
            content: Text(
                "Inicio de sesión correcto! BIENVENIDO ADMINISTRADOR ${value.datos['usuario']}"),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.pushNamed(context, "/adminView");
        }
      } else {
        SnackBar snackBar = SnackBar(
          content: Text(value.tag),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'NOTICIAS',
              style: TextStyle(
                color: Color.fromARGB(255, 106, 30, 167),
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Las mejores noticias solo aquí!',
              style: TextStyle(
                color: Color.fromARGB(255, 193, 130, 227),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                suffixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: Icon(Icons.password),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Iniciar Sesión'),
                ),
                const SizedBox(width: 16.0),
                const Text("¿No tienes cuenta? "),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/registrarse");
                  },
                  child: const Text('Registrarse'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
