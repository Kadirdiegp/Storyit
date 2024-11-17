import 'package:flutter/material.dart';

class InspirationPage extends StatelessWidget {
  const InspirationPage({Key? key}) : super(key: key);

  static final List<InspirationCard> _inspirations = [
    InspirationCard(
      title: 'Magische Wesen',
      description: 'Entdecke Einhörner, Drachen und sprechende Tiere',
      icon: Icons.auto_awesome,
      color: Color(0xFF9C27B0),
      tags: ['Fantasie', 'Abenteuer', 'Magie'],
      examples: [
        'Ein freundlicher Drache, der Angst vor Feuer hat',
        'Ein Einhorn, das seine magischen Kräfte entdeckt',
        'Eine weise sprechende Eule als Ratgeber'
      ],
    ),
    InspirationCard(
      title: 'Naturentdecker',
      description: 'Geschichten über die Wunder der Natur',
      icon: Icons.eco,
      color: Color(0xFF4CAF50),
      tags: ['Natur', 'Lehrreich', 'Umwelt'],
      examples: [
        'Der kleine Regentropfen auf seiner Reise',
        'Der mutige Schmetterling auf Wanderschaft',
        'Der weise alte Baum und seine Geschichten'
      ],
    ),
    InspirationCard(
      title: 'Alltagshelden',
      description: 'Kleine Helden in großen Abenteuern',
      icon: Icons.emoji_people,
      color: Color(0xFF2196F3),
      tags: ['Alltag', 'Mut', 'Freundschaft'],
      examples: [
        'Das schüchterne Kind, das Freunde findet',
        'Der erste Schultag wird zum Abenteuer',
        'Gemeinsam stark sein'
      ],
    ),
    // Weitere Inspirationskarten...
  ];

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _inspirations.length,
                  itemBuilder: (context, index) {
                    return _buildInspirationCard(_inspirations[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inspirationen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Entdecke magische Ideen für deine nächste Geschichte',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationCard(InspirationCard inspiration) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Icon(
          inspiration.icon,
          color: inspiration.color,
          size: 32,
        ),
        title: Text(
          inspiration.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(inspiration.description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: inspiration.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: inspiration.color.withOpacity(0.1),
                      labelStyle: TextStyle(color: inspiration.color),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                Text(
                  'Beispiele:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                ...inspiration.examples.map((example) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_right, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(example),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InspirationCard {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> tags;
  final List<String> examples;

  InspirationCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tags,
    required this.examples,
  });
}
