import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/occurrence.dart';
import '../providers/occurrence_provider.dart';
import '../services/address_service.dart';
import '../services/location_service.dart';
import '../theme/design_system.dart';
import '../widgets/category_chips.dart';
import '../widgets/occurrence_image.dart';
import '../widgets/privacy_notice.dart';

typedef ImagePathPicker = Future<String?> Function(ImageSource source);

Future<String?> _defaultPicker(ImageSource source) async {
  final file = await ImagePicker().pickImage(
    source: source,
    imageQuality: 70,
    maxWidth: 1280, // evita decodificar fotos de 12 MP inteiras
  );
  return file?.path;
}

class NewOccurrenceScreen extends StatefulWidget {
  const NewOccurrenceScreen({
    super.key,
    this.locationService,
    this.addressService,
    this.pickImagePath,
  });

  final LocationService? locationService;
  final AddressService? addressService;
  final ImagePathPicker? pickImagePath;

  @override
  State<NewOccurrenceScreen> createState() => _NewOccurrenceScreenState();
}

class _NewOccurrenceScreenState extends State<NewOccurrenceScreen>
    with WidgetsBindingObserver {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final LocationService _locationService =
      widget.locationService ?? GeolocatorLocationService();
  late final AddressService _addressService =
      widget.addressService ?? NominatimAddressService();
  late final ImagePathPicker _pickImagePath =
      widget.pickImagePath ?? _defaultPicker;

  OccurrenceCategory? _category;
  String? _imagePath;
  LatLng? _location;
  LocationResult? _locationResult;
  String? _address;
  bool _loadingLocation = false;
  bool _loadingAddress = false;
  bool _allowPop = false;
  bool _awaitingSettings = false;

  bool get _dirty =>
      _imagePath != null ||
      _category != null ||
      _titleController.text.trim().isNotEmpty ||
      _descriptionController.text.trim().isNotEmpty;

  List<String> get _missing => [
    if (_imagePath == null) 'foto',
    if (_category == null) 'categoria',
    if (_location == null) 'localização',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _titleController.addListener(_refresh);
    _descriptionController.addListener(_refresh);
    _getLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Ao voltar das configurações do sistema (e só nesse caso), tenta de novo.
  /// Não repete ao voltar da câmera: reabriria o pedido de permissão.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingSettings) {
      _awaitingSettings = false;
      if (_location == null && !_loadingLocation) _getLocation();
    }
  }

  void _refresh() => setState(() {});

  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    final result = await _locationService.current();
    if (!mounted) return;
    setState(() {
      _loadingLocation = false;
      _locationResult = result;
      if (result is LocationOk) _location = result.position;
    });
    if (result is LocationOk) _loadAddress(result.position);
  }

  Future<void> _loadAddress(LatLng position) async {
    setState(() => _loadingAddress = true);
    final address = await _addressService.reverse(position);
    if (!mounted) return;
    setState(() {
      _address = address;
      _loadingAddress = false;
    });
  }

  Future<void> _onLocationAction() async {
    switch (_locationResult) {
      case LocationServiceDisabled():
        _awaitingSettings = true;
        await _locationService.openLocationSettings();
      case LocationDeniedForever():
        _awaitingSettings = true;
        await _locationService.openAppSettings();
      default:
        await _getLocation();
    }
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final path = await _pickImagePath(source);
      if (path != null && mounted) setState(() => _imagePath = path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir a câmera ou a galeria.'),
          backgroundColor: DesignSystem.error,
        ),
      );
    }
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar ocorrência?'),
        content: const Text('Os dados preenchidos serão perdidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar editando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Descartar',
              style: TextStyle(color: DesignSystem.error),
            ),
          ),
        ],
      ),
    );
    return discard == true;
  }

  void _publish() {
    final category = _category!;
    final occurrence = Occurrence(
      title: Occurrence.titleFor(_titleController.text, category),
      description: _descriptionController.text.trim(),
      category: category,
      location: _location!,
      address: _address,
      imagePath: _imagePath,
    );
    context.read<OccurrenceProvider>().addOccurrence(occurrence);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _allowPop = true);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Ocorrência registrada com sucesso!'),
        backgroundColor: DesignSystem.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final missing = _missing;

    return PopScope(
      canPop: !_dirty || _allowPop,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _confirmDiscard()) {
          setState(() => _allowPop = true);
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Registrar ocorrência')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPhoto(),
              const SizedBox(height: 16),
              const Text(
                'Categoria',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              CategoryChips(
                selected: _category,
                onSelected: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text(
                  'Detalhes (opcional)',
                  style: TextStyle(fontSize: 14),
                ),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título breve',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const PrivacyNotice(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: missing.isEmpty ? _publish : null,
                child: const Text('Publicar'),
              ),
              if (missing.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Falta: ${missing.join(', ')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: DesignSystem.secondary,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoto() {
    final path = _imagePath;
    if (path != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: OccurrenceImage(
              path: path,
              height: 200,
              width: double.infinity,
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _imagePath = null),
            icon: const Icon(Icons.delete, color: DesignSystem.error),
            label: const Text(
              'Remover foto',
              style: TextStyle(color: DesignSystem.error),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _photoButton(Icons.camera_alt, 'Câmera', ImageSource.camera),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _photoButton(
            Icons.photo_library,
            'Galeria',
            ImageSource.gallery,
          ),
        ),
      ],
    );
  }

  Widget _photoButton(IconData icon, String label, ImageSource source) {
    return OutlinedButton.icon(
      onPressed: () => _pick(source),
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64)),
    );
  }

  Widget _buildLocationCard() {
    final result = _locationResult;
    final failed = !_loadingLocation && _location == null && result != null;

    return Semantics(
      key: const Key('location-card'),
      liveRegion: true, // leitores de tela anunciam "capturada"/erro
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: DesignSystem.tertiary,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (_loadingLocation)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_location != null)
                const Icon(Icons.check_circle, color: DesignSystem.success)
              else
                const Icon(Icons.error, color: DesignSystem.error),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _loadingLocation
                          ? 'Obtendo localização atual...'
                          : _location != null
                          ? 'Localização capturada'
                          : (result?.message ?? 'Localização indisponível'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_location != null)
                      Text(
                        _loadingAddress
                            ? 'Buscando endereço...'
                            : (_address ?? 'Endereço indisponível'),
                        style: const TextStyle(
                          color: DesignSystem.secondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (failed && result.actionLabel != null)
                TextButton(
                  onPressed: _onLocationAction,
                  child: Text(result.actionLabel!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
