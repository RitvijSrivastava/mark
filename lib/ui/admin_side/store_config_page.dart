import 'package:attendance/models/store.dart';
import 'package:flutter/material.dart';

class StoreConfigPage extends StatefulWidget {
  final List<Store> stores;
  StoreConfigPage({this.stores});

  @override
  _StoreConfigPageState createState() => _StoreConfigPageState();
}

class _StoreConfigPageState extends State<StoreConfigPage> {
  Store _dropdownValue;

  @override
  void initState() {
    super.initState();
    _dropdownValue = widget.stores[0];
  }

  /// Build Drop Down Menu Item
  List<DropdownMenuItem<Store>> _buildDropdownMenuItem() {
    return widget.stores.map((Store store) {
      return DropdownMenuItem<Store>(value: store, child: Text(store.name));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Configurator'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DropdownButton<dynamic>(
                    value: _dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    items: _buildDropdownMenuItem(),
                    onChanged: (newValue) {
                      setState(() {
                        _dropdownValue = newValue;
                      });
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
