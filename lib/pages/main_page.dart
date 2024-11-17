import 'package:flutter/material.dart';
import 'story_creator_page.dart';
import 'inspiration_page.dart';
import 'profile_page.dart';
import '../services/storage_service.dart';

class MainPage extends StatefulWidget {
  final StorageService? storageService;

  const MainPage({Key? key, this.storageService}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final StorageService _storageService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initStorageService();
  }

  Future<void> _initStorageService() async {
    _storageService = widget.storageService ?? await StorageService.init();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          StoryCreatorPage(storageService: _storageService),
          const InspirationPage(),
          ProfilePage(storageService: _storageService),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Erstellen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Inspiration',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
