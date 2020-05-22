import 'package:attendance/models/store.dart';
import 'package:attendance/services/firebase_service.dart';
import 'package:attendance/services/validate.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class StoreConfigPage extends StatefulWidget {
  final List<Store> stores;
  final VoidCallback isStoreComplete;

  StoreConfigPage({@required this.stores, this.isStoreComplete});

  @override
  _StoreConfigPageState createState() => _StoreConfigPageState();
}

class _StoreConfigPageState extends State<StoreConfigPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>(); // Form Key
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Scaffold Key

  Store _dropdownValue; // Current dropdown value

  List<DropdownMenuItem<Store>> _items = [];

  bool _isUploading;

  List<String> _location;
  String _radius;

  @override
  void initState() {
    super.initState();
    _items = _buildDropdownMenuItem();
    _dropdownValue = widget.stores[0];
    _isUploading = false;
    _radius = null;
    _location = null;
  }

  /// Build Drop Down Menu Item
  List<DropdownMenuItem<Store>> _buildDropdownMenuItem() {
    return widget.stores.map((Store store) {
      return DropdownMenuItem<Store>(value: store, child: Text(store.name));
    }).toList();
  }

  /// Display message in snack bar
  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get Location
  _getLocation() async {
    Position position = await Geolocator().getCurrentPosition();
    List<String> pos = new List();
    pos.add(position.latitude.toString());
    pos.add(position.longitude.toString());
    setState(() {
      _location = pos;
    });
  }

  /// Upload radius and Location in firebase
  _uploadToFirebase() async {
    FirebaseService firebaseService = new FirebaseService();

    Store store = new Store(
      storeName: _dropdownValue.name,
      storeId: _dropdownValue.id,
      location: _location ?? _dropdownValue.location,
      radius: _radius ?? _dropdownValue.rad,
    );

    Map<String, dynamic> storeMap = store.toMap();

    // Upload to firebase
    await firebaseService.addSpecificData('stores', store.id, storeMap);

    // Set [_isUploading] to false
    setState(() {
      _isUploading = false;
    });
    showInSnackBar("Info Uploaded!");
  }

  /// Submit and upload
  _submitAndUpload() async {
    setState(() {
      _isUploading = true;
    });

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Upload to firebase
      await _uploadToFirebase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Store Configurator"),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, widget.isStoreComplete()),
        ),
      ),
      body: Stack(
        children: <Widget>[
          _showForm(context),
          _showCircularProgress(),
        ],
      ),
    );
  }

  /// Return progress indicator if the form is uploading data
  Widget _showCircularProgress() {
    if (_isUploading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  /// Display form for location and radius
  Widget _showForm(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DropdownButton<dynamic>(
                    value: _dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 26,
                    elevation: 16,
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 23.0,
                    ),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    items: _items,
                    onChanged: (newValue) {
                      setState(() {
                        _dropdownValue = newValue;
                      });
                    }),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text("Location: ", textScaleFactor: 1.1),
                  MaterialButton(
                    padding: EdgeInsets.all(10.0),
                    onPressed: _getLocation,
                    child: Text("Get Location", textScaleFactor: 1.2),
                    textColor: Colors.white,
                    color: Colors.purpleAccent,
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Container(
                height: 100.0,
                width: MediaQuery.of(context).size.width * 0.80,
                child: TextFormField(
                  validator: (String value) {
                    Validate validate = new Validate();
                    return validate.verifyRadius(value);
                  },
                  onSaved: (value) {
                    _radius = value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Radius (in meters)",
                    hintText: "${_dropdownValue.rad}",
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: MaterialButton(
                  padding: EdgeInsets.all(13.0),
                  onPressed: _submitAndUpload,
                  textColor: Colors.white,
                  color: Colors.blue,
                  child: Text(
                    "  SUBMIT  ",
                    textScaleFactor: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
