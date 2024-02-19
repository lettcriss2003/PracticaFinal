import 'package:flutter/material.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/Conexion.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:simple_tiles_map/simple_tiles_map.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapa de Comentarios',
      home: MapViewInd(),
    );
  }
}

class MapViewInd extends StatefulWidget {
  @override
  _MapViewIndState createState() => _MapViewIndState();
}

class _MapViewIndState extends State<MapViewInd> {
  List<dynamic> comentarios = [];
  Map<String, dynamic> lugar_origen = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final externalId = ModalRoute.of(context)?.settings.arguments as String;
    obtenerComentariosConUbicacion(externalId);
  }

  Future<void> obtenerComentariosConUbicacion(String externalId) async {
    FacadeService fs = FacadeService();

    var response = await fs.listarComentarios(externalId);
    if (response.code == 200) {
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

      setState(() {
        lugar_origen = {
          "latitud": latitude,
          "longitud": longitude,
        };
      });

      if (response.code == 200) {
        if (response.datos != "[]") {
          setState(() {
              comentarios = response.datos
                  .where((comentario) =>
                      comentario['latitud'] != 0 && comentario['longitud'] != 0)
                  .toList();
          });
        } else {
          comentarios = [];
        }
      } else {
        print(response.msg);
      }
    } else {
      print(response.msg);
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Mapa de Comentarios'),
    ),
    body: lugar_origen.isNotEmpty
        ? comentarios.isNotEmpty
            ? SimpleTilesMap(
                typeMap: TypeMap.osmHot,
                mapOptions: MapOptions(
                  center: LatLng(
                      lugar_origen['latitud'], lugar_origen['longitud']),
                  zoom: 15.0,
                ),
                otherLayers: [
                  MarkerLayer(
                    markers: comentarios.map((comentario) {
                      return Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(
                          comentario['latitud'],
                          comentario['longitud'],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.comment,
                              color: Colors.blueAccent,
                              size: 30.0,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )
            : Center(
                child: Text("Aun no hay comentarios disponibles para esta noticia"),
              )
        : Center(
            child: CircularProgressIndicator(),
          ),
  );
}
}
