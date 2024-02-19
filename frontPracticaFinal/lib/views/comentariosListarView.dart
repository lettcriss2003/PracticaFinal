import 'package:flutter/material.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/Conexion.dart';
import 'package:noticias/controls/utiles/Utiles.dart';
import 'package:location/location.dart';

class NoticiasView extends StatefulWidget {
  @override
  _NoticiasViewState createState() => _NoticiasViewState();
}

class _NoticiasViewState extends State<NoticiasView> {
  List<dynamic> noticias = [];
  Conexion c = Conexion();
  TextEditingController _comentarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obtenerNoticias();
  }

  Future<void> obtenerNoticias() async {
    FacadeService fs = FacadeService();
    var response = await fs.listarNoticias();
    if (response.code == 200) {
      setState(() {
        noticias = response.datos;
      });
    } else {
      print(response.msg);
    }
  }

  Future<List<dynamic>> obtenerComentarios(String externalId) async {
    FacadeService fs = FacadeService();
    var response = await fs.listarComentarios(externalId);
    if (response.code == 200) {
      List<dynamic> comentarios = response.datos;
      return comentarios;
    } else {
      print(response.msg);
      return [];
    }
  }

  Future<void> cerrarSesion() async {
    Utiles u = Utiles();
    u.removeAllItem();
    Navigator.pushReplacementNamed(context, '/');
    SnackBar snackBar = SnackBar(
      content: Text('Sesión cerrada correctamente'),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void mostrarVentanaModal(
      String titulo, String cuerpo, String externalId) async {
    List<dynamic> comentarios = await obtenerComentarios(externalId);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(titulo),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cuerpo,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _comentarioController,
                      decoration: InputDecoration(
                        hintText: 'Agregar comentario',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Comentarios:'),
                    SizedBox(height: 8),
                    Column(
                      children: comentarios.map((comentario) {
                        return GestureDetector(
                          onLongPress: () async {
                            Utiles u = Utiles();
                            var usuarioActual =
                                await u.getValue('external') ?? '';
                            // Verificar si el usuario actual es el propietario del comentario
                            if (comentario['user_external'] == usuarioActual) {
                              // Mostrar menú emergente para editar comentario
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Editar comentario"),
                                    content: TextField(
                                      controller: TextEditingController(
                                          text: comentario['texto']),
                                      onChanged: (value) {
                                        // Actualizar el texto del comentario en tiempo real
                                        comentario['texto'] = value;
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancelar"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          // Lógica para guardar el comentario editado
                                          String nuevoComentario =
                                              comentario['texto'];
                                          await editarComentario(
                                              comentario['external_id'],
                                              nuevoComentario,
                                              externalId,
                                              comentario['user_external']);
                                          Navigator.pop(context);
                                          List<dynamic>
                                              comentariosActualizados =
                                              await obtenerComentarios(
                                                  externalId);
                                          setState(() {
                                            comentarios =
                                                comentariosActualizados;
                                          });
                                        },
                                        child: Text("Guardar"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              // Mostrar un mensaje indicando que el usuario no tiene permisos para editar
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Mensaje"),
                                    content: Text(
                                        "No tienes permisos para editar este comentario"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Aceptar"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: ListTile(
                            title: Text(comentario['texto']),
                            subtitle: Text(comentario['usuario']),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cerrar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Implementar la lógica para añadir un comentario
                    String comentario = _comentarioController.text.trim();
                    if (comentario.isNotEmpty) {
                      await agregarComentario(externalId, comentario);
                      _comentarioController.clear();
                      // Actualizar los comentarios después de agregar uno nuevo
                      List<dynamic> comentariosActualizados =
                          await obtenerComentarios(externalId);
                      setState(() {
                        comentarios = comentariosActualizados;
                      });
                    }
                  },
                  child: Text('Añadir comentario'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> agregarComentario(String externalId, String comentario) async {
    FacadeService fs = FacadeService();
    Utiles u = Utiles();

    var externalUser = await u.getValue('external') ?? '';

    Location location = Location();

    bool serviceEnabled;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        SnackBar snackBar = SnackBar(
          content: Text('El servicio de ubicación está desactivado'),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }

    PermissionStatus permission;
    permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        SnackBar snackBar = SnackBar(
          content: Text('Permiso de ubicación denegado'),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }

    LocationData locationData = await location.getLocation();
    double latitude = locationData.latitude!;
    double longitude = locationData.longitude!;

    Map<String, String> mapa = {
      'noticia': externalId,
      'usuario': externalUser,
      'texto': comentario,
      'latitud': latitude.toString(),
      'longitud': longitude.toString(),
      'fecha': DateTime.now().toString().substring(0, 10),
    };
    print(mapa);

    var response = await fs.guardarComentarios(mapa);

    if (response.code == 200) {
      SnackBar snackBar = SnackBar(
        content: Text('Comentario agregado correctamente'),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      SnackBar snackBar = SnackBar(
        content: Text(response.msg),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      if (response.msg == "Ha sido baneado por comentarios inapropiados") {
        cerrarSesion();
      }
    }
  }

  Future<void> editarComentario(String comentarioId, String nuevoComentario,
      String noticia, String usuarioExternalOriginal) async {
    FacadeService fs = FacadeService();
    Utiles u = Utiles();

    var externalUser = await u.getValue('external') ?? '';

    if (externalUser != usuarioExternalOriginal) {
      SnackBar snackBar = SnackBar(
        content: Text('No tienes permisos para editar este comentario'),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } else {
      Location location = Location();

      bool serviceEnabled;
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          SnackBar snackBar = SnackBar(
            content: Text('El servicio de ubicación está desactivado'),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }
      }

      PermissionStatus permission;
      permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) {
          SnackBar snackBar = SnackBar(
            content: Text('Permiso de ubicación denegado'),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }
      }

      LocationData locationData = await location.getLocation();
      double latitude = locationData.latitude!;
      double longitude = locationData.longitude!;

      Map<String, String> mapa = {
        'noticia': noticia,
        'usuario': externalUser,
        'texto': nuevoComentario,
        'latitud': latitude.toString(),
        'longitud': longitude.toString(),
        'fecha': DateTime.now().toString().substring(0, 10),
      };
      print(mapa);

      var response = await fs.modificarComentario(mapa, comentarioId);

      if (response.code == 200) {
        SnackBar snackBar = SnackBar(
          content: Text('Comentario editado correctamente'),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        SnackBar snackBar = SnackBar(
          content: Text(response.msg),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if (response.msg == "Ha sido baneado por comentarios inapropiados") {
          cerrarSesion();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Noticias'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Menú'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Editar perfil'),
              onTap: () {
                Navigator.pushNamed(context, "/editarPerfil");
              },
            ),
            ListTile(
              title: Text('Cerrar sesión'),
              onTap: () {
                cerrarSesion();
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: noticias.length,
        itemBuilder: (context, index) {
          var noticia = noticias[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                mostrarVentanaModal(
                  noticia['titulo'],
                  noticia['cuerpo'],
                  noticia['external_id'],
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 250,
                    decoration: BoxDecoration(
                      image: noticia['archivo'].toString() != "noticia.png"
                          ? DecorationImage(
                              image: NetworkImage(
                                  c.URL_MEDIA + noticia['archivo'].toString()),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            noticia['titulo'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(noticia['fecha']),
                          Text(noticia['tipo_noticia']),
                          Text(noticia['cuerpo']),
                          SizedBox(height: 8),
                          IconButton(
                            icon: Icon(Icons.message),
                            onPressed: () {
                              mostrarVentanaModal(
                                noticia['titulo'],
                                noticia['cuerpo'],
                                noticia['external_id'],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
