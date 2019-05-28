import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=e7a63369";

void main() async {
  runApp(MaterialApp(
    home: ConversorMoeda(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getDataApi() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class ConversorMoeda extends StatefulWidget {
  @override
  _ConversorMoedaState createState() => _ConversorMoedaState();
}

class _ConversorMoedaState extends State<ConversorMoeda> {
  TextEditingController _realController = TextEditingController();
  TextEditingController _dolarController = TextEditingController();
  TextEditingController _euroController = TextEditingController();

  double dolar;
  double euro;

  bool clearAll(String valor){
      if(valor.isEmpty){
        _realController.text = "";
        _dolarController.text = "";
        _euroController.text = "";

        return true;
      }

      return false;
  }

  void _realConverter(String valor) {
    clearAll(valor);
    double real = double.parse(valor);
    _dolarController.text = (real / this.dolar).toStringAsFixed(2);
    _euroController.text = (real / this.euro).toStringAsFixed(2);
  }

  void _dolarConverter(String valor) {
    clearAll(valor);
    double dolar = double.parse(valor);
    _realController.text = (dolar * this.dolar).toStringAsFixed(2);
    _euroController.text =
        ((dolar * this.dolar) / this.euro).toStringAsFixed(2);
  }

  void _euroConverter(String valor) {
    clearAll(valor);
    double euro = double.parse(valor);
    _realController.text = (euro * this.euro).toStringAsFixed(2);
    _dolarController.text =
        ((euro * this.euro) / this.dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getDataApi(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando dados...",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "HG Finance não está disponível :)",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        buildTextFeld(
                            "Reais", "R\$", _realController, _realConverter),
                        Divider(),
                        buildTextFeld("Dolares", "US\$", _dolarController,
                            _dolarConverter),
                        Divider(),
                        buildTextFeld(
                            "Euros", "€", _euroController, _euroConverter)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextFeld(String label, String prefix,
    TextEditingController moedaController, Function moedaConverter) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    controller: moedaController,
    onChanged: moedaConverter,
    keyboardType: TextInputType.number,
  );
}
