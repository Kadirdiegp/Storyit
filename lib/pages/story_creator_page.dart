import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/story_generation_service.dart';
import 'package:uuid/uuid.dart';
import './story_display_page.dart';
import '../services/storage_service.dart';
import '../models/child_profile.dart';

class StoryCreatorPage extends StatefulWidget {
  final StorageService storageService;

  const StoryCreatorPage({
    Key? key,
    required this.storageService,
  }) : super(key: key);

  @override
  _StoryCreatorPageState createState() => _StoryCreatorPageState();
}

class _StoryCreatorPageState extends State<StoryCreatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _storyService = StoryGenerationService();
  String _selectedTheme = '';
  String _customPrompt = '';
  double _age = 6;
  bool _isGenerating = false;
  List<ChildProfile> _children = [];
  ChildProfile? _selectedChild;

  final List<ThemeOption> _themeOptions = [
    ThemeOption(
      title: 'Abenteuer',
      icon: Icons.explore,
      color: Colors.orange,
    ),
    ThemeOption(
      title: 'Fantasie',
      icon: Icons.auto_awesome,
      color: Colors.purple,
    ),
    ThemeOption(
      title: 'Tiere',
      icon: Icons.pets,
      color: Colors.green,
    ),
    ThemeOption(
      title: 'Freundschaft',
      icon: Icons.people,
      color: Colors.blue,
    ),
    ThemeOption(
      title: 'Märchen',
      icon: Icons.castle,
      color: Colors.pink,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadChildProfiles();
  }

  Future<void> _loadChildProfiles() async {
    try {
      final profiles = await widget.storageService.getChildProfiles();
      setState(() {
        _children = profiles;
        // Automatisch das erste Kind auswählen, falls vorhanden
        if (profiles.isNotEmpty) {
          _selectedChild = profiles.first;
          _age = profiles.first.age.toDouble();
        }
      });
    } catch (e) {
      print('Fehler beim Laden der Profile: $e');
    }
  }

  // Neues Widget für die Profilauswahl
  Widget _buildProfileSelector() {
    if (_children.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text('Kein Kinderprofil vorhanden'),
            subtitle: Text('Bitte erstellen Sie zuerst ein Profil'),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                // Navigation zur ProfilePage und Warten auf Rückkehr
                await Navigator.pushNamed(context, '/profile');
                // Nach Rückkehr Profile neu laden
                _loadChildProfiles();
              },
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kinderprofil auswählen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadChildProfiles,
                tooltip: 'Profile neu laden',
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ChildProfile>(
                isExpanded: true,
                value: _selectedChild,
                items: _children.map((child) {
                  return DropdownMenuItem(
                    value: child,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: Color(0xFF6C63FF).withOpacity(0.1),
                          child: Text(
                            child.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('${child.name} (${child.age} Jahre)'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (ChildProfile? child) {
                  setState(() {
                    _selectedChild = child;
                    if (child != null) {
                      _age = child.age.toDouble();
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileSelector(),
            SizedBox(height: 24),
            _buildThemeSelector(),
            SizedBox(height: 24),
            _buildCustomPromptInput(),
            SizedBox(height: 24),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thema auswählen',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _themeOptions.map((theme) {
            final isSelected = _selectedTheme == theme.title;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedTheme = theme.title;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? theme.color : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.color,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      theme.icon,
                      color: isSelected ? Colors.white : theme.color,
                    ),
                    SizedBox(width: 8),
                    Text(
                      theme.title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomPromptInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eigene Ideen (optional)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'z.B. "Eine Geschichte über einen mutigen Drachen..."',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _customPrompt = value;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(
            Icons.auto_stories,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 16),
          Text(
            'Neue Geschichte',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHelp,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      padding: EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateStory,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF6C63FF),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: Size(double.infinity, 60),
        ),
        child: _isGenerating
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                ),
              )
            : Text(
                'Geschichte erstellen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _generateStory() async {
    if (!_formKey.currentState!.validate() || _selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bitte wählen Sie ein Kinderprofil aus'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final (title, content) = await _storyService.generateStory(
        theme: _selectedTheme,
        childName: _selectedChild!.name,
        ageGroup: _selectedChild!.age,
        additionalIdeas: _customPrompt.isNotEmpty ? _customPrompt : null,
      );

      final story = Story(
        id: const Uuid().v4(),
        title: title,
        content: content,
        theme: _selectedTheme,
        ageGroup: _selectedChild!.age,
        childName: _selectedChild!.name,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(days: 30)),
        isFavorite: false,
      );

      // Story zum Kinderprofil hinzufügen
      _selectedChild!.favoriteStories.add(story);
      await widget.storageService.updateChildProfile(_selectedChild!);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDisplayPage(story: story),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Fehler beim Erstellen der Geschichte: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hilfe'),
        content: Text(
          'Gib den Namen und das Alter des Kindes ein, '
          'wähle ein Thema und füge optional eigene Ideen hinzu. '
          'Die KI erstellt dann eine personalisierte Geschichte.',
        ),
        actions: [
          TextButton(
            child: Text('Verstanden'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Profile beim Zurückkehren zur Seite neu laden
    _loadChildProfiles();
  }
}

class ThemeOption {
  final String title;
  final IconData icon;
  final Color color;

  ThemeOption({
    required this.title,
    required this.icon,
    required this.color,
  });
}
