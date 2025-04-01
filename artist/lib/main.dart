import 'package:artist/screens/album_screen.dart';
import 'package:artist/screens/create_album_screen.dart';
import 'package:artist/screens/home_screen.dart';
import 'package:artist/screens/login_screen.dart';
import 'package:artist/screens/manage_songs_screen.dart';
import 'package:artist/screens/profile_screen.dart';
import 'package:artist/screens/register_screen.dart';
import 'package:artist/screens/splash_screen.dart';
import 'package:artist/screens/upload_song_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'services/artist_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthService(prefs: prefs)),
        Provider(create: (_) => ArtistService(prefs: prefs)),
      ],
      child: MyApp(
        authService: AuthService(prefs: prefs),
        artistService: ArtistService(prefs: prefs),
        prefs: prefs,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final ArtistService artistService;
  final SharedPreferences prefs;

  const MyApp({
    Key? key,
    required this.authService,
    required this.artistService,
    required this.prefs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artist App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(prefs: prefs),
        '/register': (context) => RegisterScreen(prefs: prefs),
        '/main': (context) => MainScreen(),
        '/upload-song': (context) => UploadSongScreen(),
        '/manage-songs': (context) => ManageSongsScreen(),
        '/albums': (context) => AlbumScreen(prefs: prefs),
        '/create-album': (context) => CreateAlbumScreen(prefs: prefs),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final SharedPreferences prefs;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    prefs = Provider.of<AuthService>(context, listen: false).prefs;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(),
      ManageSongsScreen(),
      AlbumScreen(prefs: prefs),
      ProfileScreen(),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note),
            label: 'Bài hát',
          ),
          NavigationDestination(
            icon: Icon(Icons.album),
            label: 'Album',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
