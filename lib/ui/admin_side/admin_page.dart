import 'package:attendance/models/store.dart';
import 'package:attendance/services/authentication.dart';
import 'package:attendance/services/firebase_service.dart';
import 'package:attendance/ui/admin_side/approval_page.dart';
import 'package:attendance/ui/admin_side/employee_form.dart';
import 'package:attendance/ui/admin_side/list_employee_page.dart';
import 'package:attendance/ui/admin_side/store_config_page.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback logoutCallback;

  AdminPage({this.auth, this.logoutCallback});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List appBarText = [
    'Home',
    'Employees',
    'Approvals'
  ]; // Text appearing as the title of pages
  int _currentIndex = 0; // stores the current index of page
  PageController _pageController;

  bool _isStoreComplete = false;

  List<Store> incompleteStores = []; // Store all incomplete Stores
  List<Store> allStores = []; // Store all the stores

  @override
  void initState() {
    _initStores().then((_) {
      print("isStoreComplete STORE FOUND: " + _isStoreComplete.toString());
      print("ALL STORE LENGTH: " + allStores.length.toString());
    });
    super.initState();
    _currentIndex = 0;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Fetch and store [stores] from firebase
  _initStores() async {
    FirebaseService firebaseService = new FirebaseService();
    QuerySnapshot querySnapshot = await firebaseService.getData('stores');
    List<DocumentSnapshot> docSnap = querySnapshot.documents;

    List<Store> tempStore = [];
    List<Store> incompStore = [];
    tempStore = docSnap.map((snapshot) {
      Store store = Store.fromSnapshot(snapshot);
      if (store.location == null ||
          store.radius == null ||
          store.location[0] == "" ||
          store.radius == "") {
        incompStore.add(store);
      }
      return store;
    }).toList();
    setState(() {
      allStores = tempStore;
      incompleteStores = incompStore;
      _isStoreComplete = incompStore.length == 0 ? true : false;
    });
  }

  ///Generate routes depending on the state of the [stores]
  _navigateTo(int index) {
    // 1 -> Employee Form
    // 2 -> Store Configurator
    if (index == 1 && _isStoreComplete) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              EmployeeForm(auth: widget.auth, stores: allStores)));
    } else if (index == 1 && !_isStoreComplete) {
      print("Cannot navigate Store Information not complete");
    } else {
      if (_isStoreComplete) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                StoreConfigPage(stores: allStores, isStoreComplete: _storeInfoComplete)));
      } else {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StoreConfigPage(
                stores: incompleteStores,
                isStoreComplete: _storeInfoComplete)));
      }
    }
  }

  /// Void Callback to check if stores are complete or not (intializes store again)
  _storeInfoComplete() async {
    await _initStores();
    print("EHLLO CLLBAKC");
    print("isStoreComplete: " + _isStoreComplete.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText[_currentIndex]),
        actions: <Widget>[
          IconButton(
            onPressed: widget.logoutCallback,
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.75,
                child: Image.asset('assets/logo.png'),
              ),
              SizedBox(height: 25.0),
              Center(
                child: MaterialButton(
                  textColor: Colors.white,
                  color: Colors.lightBlue,
                  padding: EdgeInsets.all(16.0),
                  onPressed: () => _navigateTo(1),
                  child: Text(
                    "Add Employee",
                    textScaleFactor: 1.3,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: MaterialButton(
                  textColor: Colors.white,
                  color: Colors.lightBlue,
                  padding: EdgeInsets.all(16.0),
                  onPressed: () => _navigateTo(2),
                  child: Text(
                    "Store Config",
                    textScaleFactor: 1.3,
                  ),
                ),
              ),
            ],
          ),
          ListEmployeePage(stores: allStores),
          ApprovalPage(),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          _pageController.jumpToPage(index);
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Colors.red,
            inactiveColor: Colors.black,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.person),
            title: Text("Employees"),
            activeColor: Colors.purpleAccent,
            inactiveColor: Colors.black,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.assignment_late),
            title: Text("Approvals"),
            activeColor: Colors.blue,
            inactiveColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
