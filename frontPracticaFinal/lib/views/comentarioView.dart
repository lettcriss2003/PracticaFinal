import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:noticias/controls/Conexion.dart';
import 'package:validators/validators.dart';


class ComentarioView extends StatefulWidget {
  const ComentarioView({Key? key}) : super(key: key);

  @override
  _ComentarioViewState createState() => _ComentarioViewState();
}

class _ComentarioViewState extends State<ComentarioView> {
  @override
  Widget build(BuildContext) {
    final _formkey = GlobalKey<FormState>();
    final TextEditingController textoC = TextEditingController();
    final TextEditingController fechaC = TextEditingController();
    final TextEditingController usuarioC = TextEditingController();
    final TextEditingController latitudC = TextEditingController();
    final TextEditingController longitudC = TextEditingController();

    void _comentar() {
      setState(() {
        //Conexion c = Conexion();
        //c.solicitudGet("autos", false);
        FacadeService servicio = FacadeService();
        Navigator.pushNamed(context, '/noticias');
        if (_formkey.currentState!.validate()) {
          Map<String, String> mapa = {
            "texto": textoC.text,
            "fecha": fechaC.text,
            "usuario": usuarioC.text,
            "latitud": latitudC.text, 
            "longitud": longitudC.text
          };
          //log(mapa.toString());
          servicio.comentario(mapa).then((value) async {
            log(value.toString());
            if (value.code == 200) {
              log("Se comento");
            } else {
              log("No se comento ");
            }
          });
          log('OKKKK');
        } else {
          log('ERRORR');
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
              child: const Text("NUEVAS NOTICIAS",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 30)),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text("Comparte tu opinión ",
                  style: TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.normal,
                      fontSize: 20)),
            ),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: textoC,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Ingresa tu opinión";
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Opinión',
                      suffixIcon: Icon(Icons.account_tree)),
                )),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: fechaC,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Ingresa la fecha";
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Fecha',
                      suffixIcon: Icon(Icons.account_tree)),
                )),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: usuarioC,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Ingresa tu nombre o alias";
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Usuario',
                      suffixIcon: Icon(Icons.alternate_email)),
                )),
            Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: latitudC,
                  obscureText: true,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Ingrese su latitud";
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Latitud',
                      suffixIcon: Icon(Icons.account_tree)),
                )),
                  Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: longitudC,
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      return "Ingresa su longitud";
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Longitud',
                      suffixIcon: Icon(Icons.account_tree)),
                )),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                onPressed: _comentar,
                child: const Text('Comentar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}