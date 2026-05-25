import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:registagrodriver/repositories/model/transportType.dart';
import 'package:registagrodriver/repositories/profile.dart';
import 'package:registagrodriver/repositories/transportRequest.dart';
import 'package:registagrodriver/repositories/vehicle.dart';
import 'package:registagrodriver/screens/profile/profile_class.dart';
import 'package:registagrodriver/screens/travels/travels.dart';
import 'package:registagrodriver/screens/vehicle/vehicle_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  bool isloading = true;
  String? errorMessage;
  String? name;
  UserModel? userData;
  List<Transport> requests = [];
  List<Vehicle> vehicles = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
      _loadUserData();
      _loadVehicles();
    });
  }

  List<Widget> get _screens => [
    HomeScreen(
      name: name,
      balance: userData?.balance,
      photo: userData?.profile,
      requests: requests,
    ),
    MyTravels(requests: requests),
    VehiclesAvailable(vehicles: vehicles),
    ProfileScreen(
      name: userData?.name,
      adress: userData?.adress,
      email: userData?.email,
      phone: userData?.phone,
      photo: userData?.profile,
      province: userData?.province,
      balance: userData?.balance,
      totalTrip: requests.where((t) => t.status == "entregue").length.toString(),
    ),
  ];

  Future<void> _loadRequests() async {
    if (!mounted) return;

    setState(() {
      isloading = true;
    });

    try {
      final data = await TransportRequest().getRequests(context);

      if (!mounted) return;
      setState(() {
        requests = data;
        errorMessage = null;
        isloading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isloading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() {
      isloading = true;
    });

    try {
      final data = await Profile().userData(context);

      if (!mounted) return;
      setState(() {
        name = data.name.split(" ")[0];
        userData = data;

        errorMessage = null;
        isloading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isloading = false;
      });
    }
  }

  Future<void> _loadVehicles() async {
    if (!mounted) return;
    setState(() {
      isloading = true;
    });

    try {
      final data = await VehicleRepositorie().getVehicle(context);

      if (!mounted) return;
      setState(() {
        vehicles = data;
        errorMessage = null;
        isloading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            HapticFeedback.lightImpact();
            setState(() => _currentIndex = i);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF1A2B4A),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.route_outlined),
              activeIcon: Icon(Icons.route_rounded),
              label: 'Viagens',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.car_repair),
              activeIcon: Icon(Icons.car_repair),
              label: 'Veículo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
