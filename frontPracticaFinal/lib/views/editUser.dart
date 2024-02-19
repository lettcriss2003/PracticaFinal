import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noticias/controls/servicio_back/FacadeService.dart';
import 'package:noticias/controls/utiles/Utiles.dart';

class EditarPerfilScreen extends StatefulWidget {
  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  TextEditingController _nombresController = TextEditingController();
  TextEditingController _apellidosController = TextEditingController();
  TextEditingController _correoController = TextEditingController();
  TextEditingController _claveController = TextEditingController();
  TextEditingController _celularController = TextEditingController();
  TextEditingController _direccionController = TextEditingController();
  DateTime? _fechaNac;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    Utiles u = Utiles();
    var externalUser = await u.getValue('external') ?? '';
    var response = await FacadeService().obtenerUsuario(externalUser);
    if (response.code == 200) {
      Map<String, dynamic> datosUsuario = response.datos;
      setState(() {
        _nombresController.text = datosUsuario['nombres'] ?? '';
        _apellidosController.text = datosUsuario['apellidos'] ?? '';
        _correoController.text = datosUsuario['cuenta']['correo'] ?? '';
        _claveController.text = datosUsuario['cuenta']['clave'] ?? '';
        _celularController.text =
            datosUsuario['celular'] != "NONE" ? datosUsuario['celular'] : '';
        _direccionController.text = datosUsuario['direccion'] != "NONE"
            ? datosUsuario['direccion']
            : '';
        String fechaNacStr = datosUsuario['fecha_nac'] ?? '';
        if (fechaNacStr.isNotEmpty) {
          _fechaNac = DateFormat("yyyy-MM-dd").parse(fechaNacStr);
        } else {
          _fechaNac = null;
        }
      });
    } else {
      // Handle error
    }
  }

  Future<void> _enviarDatosEditados() async {
    if (_formKey.currentState!.validate()) {
      // Send data to backend
      String nombres = _nombresController.text;
      String apellidos = _apellidosController.text;
      String correo = _correoController.text;
      String clave = _claveController.text;
      String celular = _celularController.text;
      String direccion = _direccionController.text;
      String fechaNac = DateFormat("yyyy-MM-dd").format(_fechaNac!);

      var externalUser = await Utiles().getValue('external') ?? '';
      Map<String, String> datosUsuario = {
        'nombres': nombres,
        'apellidos': apellidos,
        'correo': correo,
        'clave': clave,
        'celular': celular,
        'direccion': direccion,
        'fecha': fechaNac,
      };
      var response =
          await FacadeService().modificarUsuario(datosUsuario, externalUser);
      if (response.code == 200) {
        SnackBar snackBar = SnackBar(
          content: Text('Datos actualizados correctamente'),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushNamed(context, "/principal");
      } else {
        SnackBar snackBar = SnackBar(
          content: Text(response.msg),
          duration: const Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nombresController,
                decoration: InputDecoration(
                  labelText: 'Nombres',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tus nombres';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _apellidosController,
                decoration: InputDecoration(
                  labelText: 'Apellidos',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tus apellidos';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _correoController,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu correo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _claveController,
                decoration: InputDecoration(
                  labelText: 'Clave',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                obscureText: _obscureText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa tu clave';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _celularController,
                decoration: InputDecoration(
                  labelText: 'Celular',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _fechaNac ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _fechaNac = selectedDate;
                    });
                  }
                },
                child: Text(_fechaNac != null
                    ? DateFormat('yyyy-MM-dd').format(_fechaNac!)
                    : 'Seleccionar Fecha de Nacimiento'),
              ),
              ElevatedButton(
                onPressed: _enviarDatosEditados,
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
