import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:komunika/app/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env["SUPABASE_PROJECT_URL"]!,
    anonKey: dotenv.env["SUPABASE_API_KEY"]!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kotaba',
      debugShowCheckedModeBanner: false,
      theme: kotabaTheme,
      home: const MyHomePage(title: 'Kotaba Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SupabaseClient supabase = Supabase.instance.client;

  void _addRestaurants() async {
    await supabase.from('restaurants').insert([
      {
        'name': 'Insittut Teknologi Bandung',
        // 'location': 'POINT(-6.890138014763959 107.61014828217186)',
        'location': 'POINT(107.61014828217186 -6.890138014763959)',
      },
      {
        'name': 'Warunk Upnormal Sumur Bandung',
        // 'location': 'POINT(-6.885419093134816 107.61307820317128)',
        'location': 'POINT(107.61307820317128 -6.885419093134816)',
      },
      {
        'name': 'McDonald\'s Dago',
        // 'location': 'POINT(-6.884932983955189 107.6134826886188)',
        'location': 'POINT(107.6134826886188 -6.884932983955189)',
      },
    ]);
    print("success");
  }

  void _nearbyRestaurants() async {
    Position currPos = await _determinePosition();
    double lat = currPos.latitude;
    double long = currPos.longitude;
    final data = await supabase.rpc(
      'nearby_restaurants',
      // params: {'lat': 40.807313, 'long': -73.946713},
      // params: {'lat': 40.807474, 'long': -73.94581},
      params: {
        // 'lat': -6.893333731202743,
        // 'long': 107.61165728201057,
        "lat": lat,
        "long": long,
      }, //Deket itb ceritanya
    );
    print(data);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Locatoin services are disabled ");
    }
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        "Location permissions are permanently denied, we cannot request permissions.",
      );
    }
    Position currPos = await Geolocator.getCurrentPosition();
    // print(currPos);
    return currPos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Location....",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 15,
        children: [
          FloatingActionButton(
            onPressed: _addRestaurants,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: _nearbyRestaurants,
            child: const Icon(Icons.food_bank),
          ),
          FloatingActionButton(
            onPressed: _determinePosition,
            child: const Icon(Icons.location_searching),
          ),
        ],
      ),
    );
  }
}
