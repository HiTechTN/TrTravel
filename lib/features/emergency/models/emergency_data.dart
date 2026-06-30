class EmergencyContact {
  final String name;
  final String number;
  final String description;
  final String emoji;

  const EmergencyContact({
    required this.name,
    required this.number,
    required this.description,
    required this.emoji,
  });
}

class EmergencyInfo {
  static const List<EmergencyContact> nationalNumbers = [
    EmergencyContact(name: 'Police', number: '155', description: 'Urgences police nationale', emoji: '👮'),
    EmergencyContact(name: 'Gendarmerie', number: '156', description: 'Gendarmerie (zones rurales)', emoji: '👮'),
    EmergencyContact(name: 'Ambulance', number: '112', description: 'Urgences médicales', emoji: '🚑'),
    EmergencyContact(name: 'Pompiers', number: '110', description: 'Incendies et secours', emoji: '🚒'),
    EmergencyContact(name: 'Police Touristique', number: '118', description: 'Assistance touristes Istanbul', emoji: '🛂'),
    EmergencyContact(name: 'SAMU Turquie', number: '112', description: 'Service d\'aide médicale urgente', emoji: '🏥'),
    EmergencyContact(name: 'Urgence Route', number: '154', description: 'Assistance routière', emoji: '🛞'),
    EmergencyContact(name: 'Gaz', number: '187', description: 'Urgence fuite de gaz', emoji: '🔥'),
  ];

  static const List<EmergencyContact> embassyPhones = [
    EmergencyContact(name: 'Ambassade de France', number: '+90 212 334 87 30', description: 'İstanbul', emoji: '🇫🇷'),
    EmergencyContact(name: 'Consulat de France', number: '+90 212 317 16 60', description: 'İstanbul - Beyoğlu', emoji: '🇫🇷'),
    EmergencyContact(name: 'Ambassade UK', number: '+90 312 455 33 44', description: 'Ankara', emoji: '🇬🇧'),
    EmergencyContact(name: 'Ambassade USA', number: '+90 312 455 55 55', description: 'Ankara', emoji: '🇺🇸'),
    EmergencyContact(name: 'Consulat USA', number: '+90 212 335 90 00', description: 'İstanbul', emoji: '🇺🇸'),
    EmergencyContact(name: 'Ambassade Canada', number: '+90 312 409 27 00', description: 'Ankara', emoji: '🇨🇦'),
    EmergencyContact(name: 'Ambassade Allemagne', number: '+90 312 455 51 00', description: 'Ankara', emoji: '🇩🇪'),
    EmergencyContact(name: 'Consulat Allemagne', number: '+90 212 334 62 00', description: 'İstanbul', emoji: '🇩🇪'),
  ];

  static const List<EmergencyContact> hospitals = [
    EmergencyContact(name: 'American Hospital', number: '+90 212 311 20 00', description: 'Nişantaşı, İstanbul - 24h', emoji: '🏥'),
    EmergencyContact(name: 'Acıbadem International', number: '+90 212 304 44 44', description: 'Yeşilköy, İstanbul', emoji: '🏥'),
    EmergencyContact(name: 'Memorial Hospital', number: '+90 212 444 77 88', description: 'Şişli, İstanbul', emoji: '🏥'),
    EmergencyContact(name: 'Medikal Park Antalya', number: '+90 242 249 09 00', description: 'Antalya - 24h', emoji: '🏥'),
    EmergencyContact(name: 'Özel Antalya Hospital', number: '+90 242 238 50 50', description: 'Antalya', emoji: '🏥'),
  ];

  static const List<EmergencyContact> pharmacies = [
    EmergencyContact(name: 'Pharmacie de Garde', number: '177', description: 'Nöbetçi eczane - service 24h', emoji: '💊'),
  ];
}
