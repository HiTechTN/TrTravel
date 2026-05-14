import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/exchange_office_service.dart';
import '../services/currency_service.dart';

class ExchangeOfficesScreen extends StatefulWidget {
  const ExchangeOfficesScreen({super.key});

  @override
  State<ExchangeOfficesScreen> createState() => _ExchangeOfficesScreenState();
}

class _ExchangeOfficesScreenState extends State<ExchangeOfficesScreen> {
  final MapController _mapController = MapController();
  Position? _userPosition;
  String _fromCurrency = 'EUR';
  String _toCurrency = 'TRY';
  double _amount = 100;
  String _selectedMode = 'walking';
  ExchangeOffice? _selectedOffice;
  bool _isLocating = false;
  String _selectedCity = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExchangeOfficeService>().init();
    });
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLocating = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLocating = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );
      if (mounted) {
        setState(() {
          _userPosition = position;
          _isLocating = false;
        });
        context.read<ExchangeOfficeService>().setUserPosition(position);
      }
    } catch (e) {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Map<String, dynamic> _calculateRoute(ExchangeOffice office) {
    if (_userPosition == null) {
      return {'distance': 0.0, 'duration': 0, 'cost': 0.0};
    }

    final distance = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      office.latitude,
      office.longitude,
    ) / 1000;

    double speedKmH;
    double costPerKm;

    switch (_selectedMode) {
      case 'walking':
        speedKmH = 5.0;
        costPerKm = 0;
        break;
      case 'public':
        speedKmH = 20.0;
        costPerKm = 2.5;
        break;
      case 'taxi':
        speedKmH = 40.0;
        costPerKm = 8.0;
        break;
      default:
        speedKmH = 5.0;
        costPerKm = 0;
    }

    final minutes = ((distance / speedKmH) * 60).round();
    final cost = (distance * costPerKm).round();

    return {
      'distance': distance,
      'duration': minutes,
      'cost': cost.toDouble(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final exchangeService = context.watch<ExchangeOfficeService>();
    final currencyService = context.watch<CurrencyService>();
    final offices = exchangeService.getOffices();
    final sortedOffices = exchangeService.getOfficesSortedByRate(_fromCurrency, _toCurrency, amount: _amount);
    final bestOffice = sortedOffices.isNotEmpty ? sortedOffices.first : null;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.currency_exchange, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bureaux de change',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${offices.length} bureaux disponibles',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isLocating)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.my_location, color: Colors.white, size: 20),
                        ),
                        onPressed: _getUserLocation,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _fromCurrency,
                            isDense: true,
                            isExpanded: true,
                            items: currencyService.getAvailableCurrencies().map((c) => DropdownMenuItem(
                              value: c['code'],
                              child: Text('${c['flag']} ${c['code']}', style: const TextStyle(fontSize: 13)),
                            )).toList(),
                            onChanged: (val) => setState(() => _fromCurrency = val!),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF43A047).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.swap_horiz, color: Color(0xFF43A047), size: 20),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _toCurrency,
                            isDense: true,
                            isExpanded: true,
                            items: currencyService.getAvailableCurrencies().map((c) => DropdownMenuItem(
                              value: c['code'],
                              child: Text('${c['flag']} ${c['code']}', style: const TextStyle(fontSize: 13)),
                            )).toList(),
                            onChanged: (val) => setState(() => _toCurrency = val!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: '$_amount',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          controller: TextEditingController(text: _amount.toStringAsFixed(0)),
                          onChanged: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null) setState(() => _amount = parsed);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeChip('walking', Icons.directions_walk, 'Piéton'),
                    const SizedBox(width: 8),
                    _buildModeChip('public', Icons.directions_bus, 'Bus'),
                    const SizedBox(width: 8),
                    _buildModeChip('taxi', Icons.local_taxi, 'Taxi'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCity,
                            isDense: true,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('🏙️ Toutes les villes')),
                              DropdownMenuItem(value: 'Istanbul', child: Text('🏛️ Istanbul')),
                              DropdownMenuItem(value: 'Antalya', child: Text('🏖️ Antalya')),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedCity = val!);
                              context.read<ExchangeOfficeService>().setCityFilter(val!);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      _userPosition?.latitude ?? 41.0086,
                      _userPosition?.longitude ?? 28.9802,
                    ),
                    initialZoom: _userPosition != null ? 13 : 6,
                    onTap: (_, __) {
                      setState(() => _selectedOffice = null);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.trtravel.app',
                    ),
                    if (_userPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                            width: 44,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1E88E5).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person_pin, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: offices.map((office) {
                        final isBest = office == bestOffice;
                        final isSelected = office == _selectedOffice;
                        return Marker(
                          point: LatLng(office.latitude, office.longitude),
                          width: isSelected ? 56 : (isBest ? 50 : 42),
                          height: isSelected ? 56 : (isBest ? 50 : 42),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedOffice = office);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isBest ? const Color(0xFF43A047) : const Color(0xFFFF6D00),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: isSelected ? 3 : 0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isBest ? const Color(0xFF43A047) : const Color(0xFFFF6D00)).withValues(alpha: isSelected ? 0.5 : 0.3),
                                    blurRadius: isSelected ? 12 : 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.attach_money,
                                color: Colors.white,
                                size: isSelected ? 28 : (isBest ? 24 : 20),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (_selectedOffice != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildOfficeInfo(exchangeService),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.list, size: 22),
                      onPressed: () => _showAllOfficesList(exchangeService),
                      color: const Color(0xFF43A047),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildOfficesScroll(sortedOffices, exchangeService, bestOffice),
        ],
      ),
    );
  }

  Widget _buildModeChip(String mode, IconData icon, String label) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF43A047) : Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF43A047) : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeInfo(ExchangeOfficeService service) {
    final office = _selectedOffice!;
    final route = _calculateRoute(office);
    final benefit = office.getBenefit(_fromCurrency, _toCurrency, _amount);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.attach_money, color: Color(0xFF43A047), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            office.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (office == context.read<ExchangeOfficeService>().getBestRateOffice(_fromCurrency, _toCurrency, amount: _amount))
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events, color: Colors.amber, size: 12),
                                const SizedBox(width: 3),
                                const Text('Meilleur taux', style: TextStyle(fontSize: 10, color: Colors.amber)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Text(office.address, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: () => setState(() => _selectedOffice = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('${office.rating}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
              if (office.openingHours != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(office.openingHours!, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                ),
              ],
              if (office.phone != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(office.phone!, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vous recevrez', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(
                        '${benefit.toStringAsFixed(2)} $_toCurrency',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF43A047)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getTransportLabel(_selectedMode), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 2),
                      Text(
                        '${route['distance'].toStringAsFixed(1)} km',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '~${route['duration']} min',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      if ((route['cost'] as double) > 0)
                        Text(
                          'Coût: ${route['cost'].toStringAsFixed(0)} TL',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFFF6D00)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    _mapController.move(LatLng(office.latitude, office.longitude), 16);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list, size: 18),
                  label: const Text('Tous les bureaux'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF43A047)),
                  ),
                  onPressed: () => _showAllOfficesList(service),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfficesScroll(List<ExchangeOffice> offices, ExchangeOfficeService service, ExchangeOffice? best) {
    return Container(
      height: 140,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: offices.length,
        itemBuilder: (context, index) {
          final office = offices[index];
          final isBest = office == best;
          final isSelected = office == _selectedOffice;
          final distance = service.getDistanceToOffice(office);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedOffice = office);
              _mapController.move(LatLng(office.latitude, office.longitude), 15);
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF43A047).withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF43A047) : (isBest ? Colors.amber[200]! : Colors.grey[200]!),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isBest) ...[
                        const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          office.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    office.city,
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber[600]),
                      const SizedBox(width: 2),
                      Text('${office.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (distance != null) ...[
                        Icon(Icons.near_me, size: 11, color: Colors.grey[400]),
                        const SizedBox(width: 2),
                        Text(
                          '${distance.toStringAsFixed(1)} km',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    office.city,
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAllOfficesList(ExchangeOfficeService service) {
    final offices = service.getOfficesSortedByRate(_fromCurrency, _toCurrency, amount: _amount);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.list_alt, color: Color(0xFF43A047)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Tous les bureaux (${offices.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: offices.length,
                itemBuilder: (context, index) {
                  final office = offices[index];
                  final isFirst = index == 0;
                  final benefit = office.getBenefit(_fromCurrency, _toCurrency, _amount);
                  final distance = service.getDistanceToOffice(office);

                  return Container(
                    decoration: BoxDecoration(
                      color: isFirst ? const Color(0xFF43A047).withValues(alpha: 0.05) : Colors.transparent,
                      border: Border(
                        left: isFirst ? const BorderSide(color: Color(0xFF43A047), width: 4) : BorderSide.none,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isFirst ? Colors.amber[100] : const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: isFirst
                            ? const Icon(Icons.emoji_events, color: Colors.amber, size: 22)
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                        ),
                      ),
                      title: Text(office.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(office.address, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.amber[600]),
                              const SizedBox(width: 2),
                              Text('${office.rating}', style: const TextStyle(fontSize: 11)),
                              if (distance != null) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.near_me, size: 12, color: Colors.grey[400]),
                                const SizedBox(width: 2),
                                Text('${distance.toStringAsFixed(1)} km', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${benefit.toStringAsFixed(0)} $_toCurrency',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isFirst ? const Color(0xFF43A047) : const Color(0xFF1A1A2E),
                            ),
                          ),
                          if (isFirst)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Meilleur', style: TextStyle(fontSize: 9, color: Colors.amber, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _selectedOffice = office);
                        _mapController.move(LatLng(office.latitude, office.longitude), 15);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTransportLabel(String mode) {
    switch (mode) {
      case 'walking': return 'Piéton';
      case 'public': return 'Bus/Métro';
      case 'taxi': return 'Taxi';
      default: return 'Trajet';
    }
  }
}