import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/child_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  static const String _apiKeyKey = 'api_key';
  static const String _onboardingKey = 'has_completed_onboarding';
  static const String _childProfilesKey = 'child_profiles';

  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  String? getApiKey() {
    return _prefs.getString(_apiKeyKey);
  }

  Future<void> setApiKey(String apiKey) async {
    await _prefs.setString(_apiKeyKey, apiKey);
  }

  bool hasCompletedOnboarding() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  Future<void> reset() async {
    await _prefs.clear();
  }

  Future<List<ChildProfile>> getChildProfiles() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Hole alle Profile
      final profilesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profiles')
          .get();

      // Hole für jedes Profil die zugehörigen Stories
      final profiles = await Future.wait(profilesSnapshot.docs.map((doc) async {
        final profileData = doc.data();
        profileData['id'] = doc.id;

        // Hole die Stories für dieses Profil
        final storiesSnapshot = await doc.reference.collection('stories').get();
        final stories = storiesSnapshot.docs.map((storyDoc) {
          final storyData = storyDoc.data();
          storyData['id'] = storyDoc.id;
          return storyData;
        }).toList();

        profileData['favoriteStories'] = stories;
        return ChildProfile.fromJson(profileData);
      }));

      return profiles;
    } catch (e) {
      print('Error loading profiles: $e');
      return [];
    }
  }

  Future<void> saveChildProfile(ChildProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Bereite die Daten für Firestore vor
      final profileData = profile.toJson();

      // Entferne die Stories aus den Hauptdaten
      final stories = profileData.remove('favoriteStories') as List;

      // Speichere das Hauptprofil
      final profileRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profiles')
          .doc(profile.id);

      await profileRef.set(profileData);

      // Speichere die Stories als separate Dokumente
      final batch = _firestore.batch();
      for (final story in stories) {
        final storyRef = profileRef.collection('stories').doc(story['id']);
        batch.set(storyRef, story);
      }
      await batch.commit();

      // Lokales Backup
      final profiles = await getChildProfiles();
      final index = profiles.indexWhere((p) => p.id == profile.id);
      if (index >= 0) {
        profiles[index] = profile;
      } else {
        profiles.add(profile);
      }
      await _prefs.setString(
        _childProfilesKey,
        jsonEncode(profiles.map((p) => p.toJson()).toList()),
      );
    } catch (e) {
      print('Error saving profile: $e');
      throw e;
    }
  }

  Future<void> deleteChildProfile(String profileId) async {
    final profiles = await getChildProfiles();
    profiles.removeWhere((p) => p.id == profileId);

    await _prefs.setString(
      _childProfilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );
  }

  Future<void> addDiaryEntry(String profileId, DiaryEntry entry) async {
    final profiles = await getChildProfiles();
    final profile = profiles.firstWhere((p) => p.id == profileId);
    profile.diaryEntries.add(entry);
    await saveChildProfile(profile);
  }

  Future<void> updateChildProfile(ChildProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // In Firestore aktualisieren
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profiles')
          .doc(profile.id)
          .update(profile.toJson());

      // Lokal aktualisieren
      final profiles = await getChildProfiles();
      final index = profiles.indexWhere((p) => p.id == profile.id);
      if (index != -1) {
        profiles[index] = profile;
        await _prefs.setString(
          _childProfilesKey,
          jsonEncode(profiles.map((p) => p.toJson()).toList()),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw e;
    }
  }
}
