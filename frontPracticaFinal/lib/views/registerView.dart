import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:noticias/controls/Conexion.dart';
import 'package:validators/validators.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext) {
    final _formkey = GlobalKey<FormState>();
    final TextEditingController nombresC = TextEditingController();
    final TextEditingController apellidosC = TextEditingController();
    final TextEditingController correoC = TextEditingController();
    final TextEditingController claveC = TextEditingController();

    void _iniciar() {
      setState(() {
        //Conexion c = Conexion();
        //c.solicitudGet("autos", false);
        FacadeService servicio = FacadeService();
        if (_formkey.currentState!.validate()) {
          Map<String, String> mapa = {
            "nombres": nombresC.text,
            "apellidos": apellidosC.text,
            "correo": correoC.text,
            "clave": claveC.text
          };
          //log(mapa.toString());
          servicio.registro(mapa).then((value) async {
            if (value.code == 200) {
              SnackBar snackBar = SnackBar(
                content: const Text('Registro exitoso, Inicie sesion para continuar'),
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.pushNamed(context, '/home');
            } else {
              SnackBar snackBar = SnackBar(
                content: Text(value.msg),
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          });
          log('OKKK');
        } else {
          log('ERROR');
        }
      });
    }

    return Form(
      key: _formkey, //* Asignación del key
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(32),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text("LAS MEJORES NOTICIAS",
                  style: TextStyle(
                      color: Color.fromARGB(255, 140, 54, 226),
                      fontWeight: FontWeight.bold,
                      fontSize: 30)),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text("Registrece",
                  style: TextStyle(
                      color: Color.fromARGB(255, 182, 126, 216),
                      fontWeight: FontWeight.normal,
                      fontSize: 20)),
            ),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: apellidosC,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Debe ingresar sus Apellidos";
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Apellidos',
                      suffixIcon: Icon(Icons.account_tree)),
                )),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: nombresC,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Debe ingresar sus Nombres";
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Nombres',
                      suffixIcon: Icon(Icons.account_tree)),
                )),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: correoC,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Debe ingresar su correo";
                    }
                    if (!isEmail(value.toString())) {
                      return "Debe ser un correo valido";
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Correo',
                      suffixIcon: Icon(Icons.email)),
                )),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: claveC,
                  obscureText: true,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Debe ingresar una clave";
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Clave',
                      suffixIcon: Icon(Icons.account_tree)),
                )),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                onPressed: _iniciar,
                child: const Text('Registrar'),
              ),
            ),
            
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                children: <Widget>[
                  const Text("Ya tienes una cuenta"),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/home');
                    },
                    child: const Text(
                      'Inicio Sesion',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}