# TrTravel 🇹🇷

Application mobile Flutter pour un voyage en Turquie (Istanbul & Antalya) — compagnon de voyage tout-en-un avec cartes hors ligne, traduction, itinéraire, et plus.

## Fonctionnalités

| Module | Description |
|---|---|
| **Itinéraire** | Programme de 11 jours chargé depuis JSON, CRUD complet |
| **Carte interactive** | flutter_map + OpenStreetMap, routing OSRM, guidance vocale |
| **Hors ligne** | Cache de tuiles, téléchargement de cartes, données locales |
| **Traduction** | Traducteur texte + traduction par caméra (OCR via Google ML Kit) |
| **Devises** | Taux de change en temps réel, bureau de change |
| **Assistant voyage** | Moteur de recommandation pour Istanbul/Antalya |
| **Wiki voyage** | Encyclopédie des attractions turques avec prix et horaires |
| **Météo** | Prévisions 7 jours via Open-Meteo API |
| **Heures de prière** | Pour les villes turques |
| **Urgences** | Numéros d'urgence, hôpitaux, ambassades |
| **Checklist** | Préparation des bagages |
| **Budget** | Suivi des dépenses |
| **Journal photo** | Carnet de voyage avec photos |
| **Notifications push** | Firebase Cloud Messaging |
| **Mise à jour** | Vérification automatique de version |

## Stack technique

- **Framework** : Flutter 3.x (Material 3)
- **Langage** : Dart
- **State Management** : Provider (ChangeNotifier)
- **Cartes** : flutter_map + OpenStreetMap
- **Base de données** : sqflite (SQLite)
- **Firebase** : firebase_core, firebase_messaging
- **OCR** : camera + google_mlkit_text_recognition
- **TTS** : flutter_tts (guidance vocale)
- **CI/CD** : GitHub Actions (APK Android)

## Prérequis

- Flutter SDK `>=3.19.0`
- Dart SDK `>=3.4.0 <4.0.0`
- Android SDK (compileSdk 34+)
- NDK `26.3.11579264`

## Installation

```bash
# Cloner le dépôt
git clone https://github.com/HiTechTN/TrTravel.git
cd TrTravel

# Installer les dépendances
flutter pub get

# Lancer en mode debug
flutter run
```

## Build APK

```bash
# APK release
flutter build apk --release

# APK debug
flutter build apk --debug
```

L'APK sera disponible dans `build/app/outputs/flutter-apk/`.

## Structure du projet

```
lib/
├── main.dart                    # Point d'entrée, Firebase, Provider, thème
├── core/
│   ├── theme_constants.dart     # Couleurs, ombres, rayons (AppColors, etc.)
│   └── cache_manager.dart       # Gestion du cache image/réseau
├── models/                      # 11 modèles de données
├── screens/                     # 22 écrans
├── services/                    # 17 services (API, BDD, local)
├── data/                        # 17 fichiers de données (POI, phrases, wiki)
└── widgets/                     # Widgets réutilisables
```

## Plateformes cibles

- Android ✅
- iOS
- Linux
- macOS
- Windows
- Web

## License

Projet personnel — usage privé.
