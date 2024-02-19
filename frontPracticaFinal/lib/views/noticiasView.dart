
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:noticias/controls/utiles/Utiles.dart';

class NoticiasView extends StatefulWidget {
  @override
  _NoticiasViewState createState() => _NoticiasViewState();
}

class _NoticiasViewState extends State<NoticiasView> {
  List<dynamic> noticias = [];

  Future<void> obtenerNoticias() async {
    final response =
        await http.get(Uri.parse("http://10.0.2.15:3000/api/admin/noticias"));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      setState(() {
        noticias = jsonResponse["datos"];
      });
    } else {
      throw Exception('Error al cargar las noticias');
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerNoticias();
  }

  void mostrarNoticiaCompleta(String titulo, String cuerpo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: Text(cuerpo),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Noticias'),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Título')),
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Tipo de noticia')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: noticias
              .asMap()
              .entries
              .where((entry) => entry.value['estado'] == true)
              .map(
                (entry) => DataRow(
                  cells: [
                    DataCell(
                      GestureDetector(
                        onTap: () {
                          mostrarNoticiaCompleta(
                            entry.value['titulo'],
                            entry.value['cuerpo'],
                          );
                        },
                        child: Text(entry.value['titulo']),
                      ),
                    ),
                    DataCell(Text(entry.value['fecha'])),
                    DataCell(Text(entry.value['tipo_noticia'])),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.message),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/comentarios',
                                arguments: entry.value['external_id'],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
