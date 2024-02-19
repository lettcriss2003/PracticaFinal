import 'package:noticias/controls/servicio_back/RespuestaGenerica.dart';
//import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:noticias/controls/utiles/Utiles.dart';

class Conexion{
  final String URL = "http://10.20.138.220:3000/api/";
  final String URL_MEDIA = "http://10.20.138.220:3000/multimedia/";
// SE PUEDE HACCER COMO STRING
  static bool NO_TOKEN = false;
  // Se creara una respuesta generica, para todo
  Future<RespuestaGenerica> solicitudGet(String recurso, bool token) async{
    // no se va a enviar todavia el token 
    // siempre poner el async 
    // no cuenta con libreria especifica para solicitudes get y post 
    Map<String, String> _header = {'Content-Type':'application/json'};
    if (token) {
      Utiles util = Utiles();
      // ? para retornar un nulo 
      String? tokenA = await util.getValue('token');
      //log(tokenA.toString());
      _header = {'Content-Type':'application/json', 'news-token':tokenA.toString()};
    }
    final String _url = URL+recurso;
    final uri =Uri.parse(_url);
    try {
      final response = await http.get(uri, headers: _header);
      // log para imprimir los datos 
      //log(response.body);
      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          return _response(404, "Recurso no encontrado", []);
        }else{
           Map<dynamic, dynamic> mapa = jsonDecode(response.body); 
         return _response(mapa ['code'], mapa['msg'], mapa ['datos']);
        }
        //log("Page not found");
      }else{
        Map<dynamic, dynamic> mapa = jsonDecode(response.body); 
        return _response(mapa ['code'], mapa['msg'], mapa ['datos']);
        //log(response.body);
      }
      //log(response.statusCode.toString());
      //return RespuestaGenerica();
      
    } catch (e) {
      return _response(500, "Error inesperado", []);
      //return RespuestaGenerica();
    }

  }

Future<RespuestaGenerica> solicitudPost(String recurso, bool token, Map<dynamic, dynamic> mapa ) async{
    // no se va a enviar todavia el token 
    // siempre poner el async 
    // no cuenta con libreria especifica para solicitudes get y post 
    Map<String, String> _header = {'Content-Type':'application/json'};
    if (token) {
      Utiles util = Utiles();
      String? tokenA = await util.getValue('token');
      _header = {'Content-Type':'application/json', 'news-token':tokenA.toString()};
    }
    final String _url = URL+recurso;
    final uri =Uri.parse(_url);
    try {
      final response = await http.post(uri, headers: _header, body: jsonEncode(mapa));
      // log para imprimir los datos 
      //log(response.body);
      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          return _response(404, "Recurso no encontrado", []);
        }else{
           Map<dynamic, dynamic> mapa = jsonDecode(response.body); 
         return _response(mapa ['code'], mapa['msg'], mapa ['datos']);
        }
        //log("Page not found");
      }else{
        Map<dynamic, dynamic> mapa = jsonDecode(response.body); 
        return _response(mapa ['code'], mapa['msg'], mapa ['datos']);
        //log(response.body);
      }
      //log(response.statusCode.toString());
      //return RespuestaGenerica();
      
    } catch (e) {
      return _response(500, "Error inesperado", []);
      //return RespuestaGenerica();
    }

  }
  RespuestaGenerica _response(int code, String msg, dynamic data){
    var respuesta = RespuestaGenerica();
    respuesta.code = code;
    respuesta.datos = data;
    respuesta.msg = msg;
    return respuesta;
  }
}