import 'package:attendance/models/employee.dart';
import 'package:attendance/models/store.dart';
import 'package:attendance/ui/common/attendance_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ListEmployeePage extends StatefulWidget {
  final List<Store> stores;

  ListEmployeePage({@required this.stores});

  @override
  _ListEmployeePageState createState() => _ListEmployeePageState();
}

class _ListEmployeePageState extends State<ListEmployeePage> {
  Store _dropdownValue; // Current dropdown value

  List<DropdownMenuItem<Store>> _items; // Store all the drop down menu items

  Map<String, String> storeNames = {};

  @override
  void initState() {
    _initStoreName().then((_) {
      print("Stores Initialised");
    });
    _items = _buildDropdownMenuItem();
    _dropdownValue = widget.stores[0];
    super.initState();
  }

  /// Map [store.id] to [store.name] and save it
  _initStoreName() async {
    Map<String, String> map = {};
    for (Store store in widget.stores) {
      map[store.id] = store.name;
    }

    setState(() {
      storeNames = map;
    });
  }

  /// Build Drop Down Menu Item
  List<DropdownMenuItem<Store>> _buildDropdownMenuItem() {
    var tempList = [];
    tempList = widget.stores.map((Store store) {
      return DropdownMenuItem<Store>(value: store, child: Text(store.name));
    }).toList();
    tempList.insert(
        0,
        DropdownMenuItem<Store>(
            value: new Store(storeId: null), child: Text("All Employees")));
    return tempList;
  }

  /// Build a list of employees
  List<Widget> _buildList(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    return snapshot.map((data) => _buildListItem(context, data)).toList();
  }

  /// Build list item (employee)
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    Employee emp = Employee.fromSnapshot(data);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AttendanceHistory(
                  userId: emp.id,
                  appBarNeeded: true,
                ))),
        leading: CircleAvatar(
          radius: 25,
          child: ClipOval(
            child: Center(
              child: Image.network(
                emp.image,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes
                        : null,
                  );
                },
              ),
            ),
          ),
        ),
        title: Text(
          "${emp.first} ${emp.last}",
          textScaleFactor: 1.2,
        ),
        subtitle: Text(
          "Store: ${storeNames[emp.storeID]}",
          textScaleFactor: 1.1,
        ),
        trailing: Icon(Icons.chevron_right, size: 40.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _dropdownValue.id == null
            ? Firestore.instance.collection('employees').snapshots()
            : Firestore.instance
                .collection('employees')
                .where('storeId', isEqualTo: _dropdownValue.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Widget> _empList = _buildList(context, snapshot.data.documents);

          return CustomScrollView(
            slivers: <Widget>[
              SliverStickyHeader(
                header: Container(
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
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _empList[index],
                    childCount: _empList.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
