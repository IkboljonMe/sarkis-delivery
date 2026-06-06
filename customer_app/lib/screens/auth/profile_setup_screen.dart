import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/geocoding_service.dart';
import '../../utils/constants.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();

  bool _loading = false;
  GeocodeResult? _geocode;
  String? _manualGroup;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    super.dispose();
  }

  Future<void> _validateAddress() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final raw =
        '${_addressController.text}, ${_postalController.text} ${_cityController.text}';
    final result = await GeocodingService.instance.lookup(raw);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result == null) {
      Fluttertoast.showToast(
          msg: 'Could not verify address. You can still continue.');
      // Fall back to using the manually entered data.
      setState(() {
        _geocode = GeocodeResult(
          formattedAddress: raw,
          postalCode: _postalController.text.trim(),
          city: _cityController.text.trim(),
        );
      });
    } else {
      setState(() => _geocode = result);
      if (result.postalCode.isNotEmpty) {
        _postalController.text = result.postalCode;
      }
      if (result.city.isNotEmpty) {
        _cityController.text = result.city;
      }
    }
    _showAddressPreview();
  }

  void _showAddressPreview() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Is this your address?'),
        content: Text(_geocode?.formattedAddress ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NO, EDIT'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _confirmAndSave();
            },
            child: const Text('YES'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndSave() async {
    final postal = _postalController.text.trim();
    String? group = AppConstants.groupForPostalCode(postal);

    if (group == null) {
      group = await _askGroup();
      if (group == null) return;
    }

    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final locale = context.read<LocaleProvider>();

    final ok = await auth.saveProfile(
      name: _nameController.text.trim(),
      address: _geocode?.formattedAddress ?? _addressController.text.trim(),
      city: _cityController.text.trim(),
      postalCode: postal,
      group: group,
      language: locale.locale.languageCode,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      Fluttertoast.showToast(msg: auth.errorMessage ?? 'Failed to save profile');
    }
  }

  Future<String?> _askGroup() async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select your delivery group'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, AppConstants.groupBerlin),
            child: const Text('Berlin'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, AppConstants.groupHamburg),
            child: const Text('Hamburg'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete your profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration:
                      const InputDecoration(labelText: 'Street Address'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _postalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _validateAddress,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
