import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/child_profile.dart';
import '../models/emotion.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../pages/auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  final StorageService storageService;

  const ProfilePage({Key? key, required this.storageService}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<ChildProfile> _children = [];
  bool _isLoading = true;
  late AuthService _authService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _authService = await AuthService.init();
    setState(() => _isInitialized = true);
    if (_authService.isLoggedIn()) {
      _loadChildProfiles();
    }
  }

  Future<void> _loadChildProfiles() async {
    setState(() => _isLoading = true);
    try {
      final profiles = await widget.storageService.getChildProfiles();
      setState(() {
        _children = profiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // TODO: Fehlerbehandlung
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_authService.isLoggedIn()) {
      return LoginPage(
        onLoginSuccess: () {
          setState(() {});
          _loadChildProfiles();
        },
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF4B45FF)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildChildrenSection(),
                            SizedBox(height: 24),
                            _buildStatsSection(),
                            SizedBox(height: 24),
                            _buildSettingsSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddChildDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF6C63FF),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Familienprofil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.transparent, Colors.black.withOpacity(0.2)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kinder',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        if (_children.isEmpty)
          Center(
            child: Text(
              'Noch keine Kinderprofile angelegt',
              style: TextStyle(color: Colors.white70),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _children.length,
            itemBuilder: (context, index) {
              final child = _children[index];
              return _buildChildCard(child);
            },
          ),
      ],
    );
  }

  Widget _buildChildCard(ChildProfile child) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showChildDetails(child),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF6C63FF).withOpacity(0.1),
                child: Text(
                  child.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${child.age} Jahre',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: child.interests
                          .take(3)
                          .map((interest) => Chip(
                                label: Text(
                                  interest,
                                  style: TextStyle(fontSize: 12),
                                ),
                                backgroundColor:
                                    Color(0xFF6C63FF).withOpacity(0.1),
                                labelStyle: TextStyle(color: Color(0xFF6C63FF)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiken',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.auto_stories,
                label: 'Geschichten',
                value: '${_getTotalStories()}',
              ),
              _buildStatItem(
                icon: Icons.calendar_today,
                label: 'Tage aktiv',
                value: '${_getDaysActive()}',
              ),
              _buildStatItem(
                icon: Icons.favorite,
                label: 'Favoriten',
                value: '${_getTotalFavorites()}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF6C63FF), size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C63FF),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Einstellungen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Benachrichtigungen',
            onTap: () {
              // TODO: Implementiere Benachrichtigungseinstellungen
            },
          ),
          _buildSettingsTile(
            icon: Icons.lock,
            title: 'Datenschutz',
            onTap: () {
              // TODO: Implementiere Datenschutzeinstellungen
            },
          ),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Hilfe',
            onTap: () {
              // TODO: Implementiere Hilfeseite
            },
          ),
          Divider(),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Abmelden',
            onTap: () async {
              await _authService.signOut();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF6C63FF)),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAddChildDialog() {
    final _nameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    double _age = 6;
    List<String> _selectedInterests = [];

    final List<String> _availableInterests = [
      'Abenteuer',
      'Tiere',
      'Märchen',
      'Sport',
      'Natur',
      'Musik',
      'Fantasie',
      'Wissenschaft',
      'Freundschaft',
      'Familie',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Neues Kind hinzufügen'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte gib einen Namen ein';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Alter: ${_age.round()} Jahre',
                    style: TextStyle(fontSize: 16),
                  ),
                  Slider(
                    value: _age,
                    min: 2,
                    max: 12,
                    divisions: 10,
                    label: _age.round().toString(),
                    onChanged: (value) {
                      setState(() => _age = value);
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Interessen',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return FilterChip(
                        label: Text(interest),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                        selectedColor: Color(0xFF6C63FF).withOpacity(0.2),
                        checkmarkColor: Color(0xFF6C63FF),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newChild = ChildProfile(
                    id: const Uuid().v4(),
                    name: _nameController.text,
                    age: _age.round(),
                    interests: _selectedInterests,
                    createdAt: DateTime.now(),
                  );

                  try {
                    await widget.storageService.saveChildProfile(newChild);
                    await _loadChildProfiles(); // Liste aktualisieren
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${newChild.name} wurde hinzugefügt'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Fehler beim Speichern: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
              child: Text('Hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChildDetails(ChildProfile child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF6C63FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${child.age} Jahre',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // TODO: Implementiere Bearbeiten-Funktion
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildDetailSection(
                    'Interessen',
                    child.interests
                        .map((interest) => Chip(
                              label: Text(interest),
                              backgroundColor:
                                  Color(0xFF6C63FF).withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 16),
                  _buildDetailSection(
                    'Letzte Geschichten',
                    child.favoriteStories
                        .map((story) => ListTile(
                              title: Text(story.title),
                              subtitle: Text(story.theme),
                              leading: Icon(Icons.auto_stories),
                            ))
                        .toList(),
                  ),
                  // Weitere Sektionen können hier hinzugefügt werden
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }

  int _getTotalStories() {
    return _children.fold(
        0, (sum, child) => sum + (child.favoriteStories?.length ?? 0));
  }

  int _getDaysActive() {
    if (_children.isEmpty) return 0;
    final oldestProfile =
        _children.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
    return DateTime.now().difference(oldestProfile.createdAt).inDays + 1;
  }

  int _getTotalFavorites() {
    return _children.fold(
        0,
        (sum, child) =>
            sum +
            (child.favoriteStories?.where((s) => s.isFavorite).length ?? 0));
  }
}
