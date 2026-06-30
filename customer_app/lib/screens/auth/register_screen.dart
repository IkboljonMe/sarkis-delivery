import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/geocoding_service.dart';
import '../../services/region_group_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/gold_badge.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/static_map.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0; // 0 = name, 1 = address + map
  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _referredBy = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();

  GeoResult? _geo;
  String? _group; // delivery group resolved from the geocoded point
  bool _geocoding = false;

  @override
  void dispose() {
    _name.dispose();
    _lastName.dispose();
    _referredBy.dispose();
    _address.dispose();
    _city.dispose();
    _postal.dispose();
    super.dispose();
  }

  // Any address edit invalidates the previous geocode result.
  void _onAddressChanged() {
    if (_geo != null || _group != null) {
      setState(() {
        _geo = null;
        _group = null;
      });
    }
  }

  void _next() {
    if (_step == 0) {
      if (_name.text.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'Enter your name');
        return;
      }
      setState(() => _step = 1);
    }
  }

  void _back() => setState(() => _step = 0);

  Future<void> _checkOnMap(AppLocalizations t) async {
    if (_address.text.trim().isEmpty ||
        _city.text.trim().isEmpty ||
        _postal.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Fill all address fields');
      return;
    }
    setState(() {
      _geocoding = true;
      _geo = null;
    });
    final query =
        '${_address.text.trim()}, ${_postal.text.trim()} ${_city.text.trim()}, Germany';
    final result = await GeocodingService.instance.geocode(query);
    if (!mounted) return;
    // Resolve which map group the geocoded point falls inside.
    String? group;
    if (result != null) {
      group = await RegionGroupService.instance
          .resolveGroupName(result.lat, result.lng);
    }
    if (!mounted) return;
    setState(() {
      _geocoding = false;
      _geo = result;
      _group = group;
    });
    if (result == null) {
      Fluttertoast.showToast(msg: t.t('addressNotFound'));
    }
  }

  // Address step complete: stash the collected profile as a draft and move on
  // to the final step — phone number entry + code verification. If the user is
  // already signed in (e.g. they logged in but had no profile yet), there is
  // no phone step to do — just save the profile.
  Future<void> _continueToPhone(AppLocalizations t) async {
    final geo = _geo;
    if (geo == null) return;
    // An out-of-coverage customer registers with an empty group; the admin
    // schedules their deliveries manually.
    final group = _group ?? '';
    final auth = context.read<AuthProvider>();
    final locale = context.read<LocaleProvider>();
    final draft = RegistrationDraft()
      ..name = _name.text.trim()
      ..lastName = _lastName.text.trim()
      ..referredBy = _referredBy.text.trim()
      ..address = _address.text.trim()
      ..city = geo.city.isNotEmpty ? geo.city : _city.text.trim()
      ..postalCode =
          geo.postalCode.isNotEmpty ? geo.postalCode : _postal.text.trim()
      ..group = group
      ..lat = geo.lat
      ..lng = geo.lng
      ..language = locale.locale.languageCode;
    auth.authMode = 'register';
    auth.draft = draft;
    if (auth.isLoggedIn) {
      final ok = await auth.completeRegistration();
      if (!mounted) return;
      if (ok) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
      } else {
        Fluttertoast.showToast(msg: auth.error ?? 'Failed to save');
      }
      return;
    }
    Navigator.pushNamed(context, '/phone');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: _step > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back)
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _progressDots(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _step == 0 ? _nameStep(t) : _addressStep(t),
                  ),
                ),
              ),
              _bottomButton(t, auth.busy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomButton(AppLocalizations t, bool busy) {
    if (_step == 0) {
      return GoldenButton(label: t.continueLabel, onPressed: _next);
    }
    // Address step: a successful geocode is enough to finish. Being outside
    // every delivery group is allowed — the customer can still order and we
    // schedule delivery for them afterwards.
    final canFinish = _geo != null;
    if (canFinish) {
      return GoldenButton(
        label: t.continueLabel,
        loading: busy,
        onPressed: () => _continueToPhone(t),
      );
    }
    return GoldenButton(
      label: t.t('checkOnMap'),
      loading: _geocoding,
      onPressed: () => _checkOnMap(t),
    );
  }

  Widget _progressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i <= _step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  Widget _nameStep(AppLocalizations t) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.t('whatsName'), style: AppTextStyles.headingL),
        const SizedBox(height: 24),
        AppInputField(
          controller: _name,
          label: t.t('firstName'),
          prefixIcon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        AppInputField(
          controller: _lastName,
          label: t.t('lastName'),
          prefixIcon: Icons.badge_outlined,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        AppInputField(
          controller: _referredBy,
          label: t.t('referredByOptional'),
          prefixIcon: Icons.group_outlined,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _addressStep(AppLocalizations t) {
    final geo = _geo;
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.t('whereDeliver'), style: AppTextStyles.headingL),
        const SizedBox(height: 24),
        AppInputField(
          controller: _address,
          label: t.yourAddress,
          prefixIcon: Icons.home_outlined,
          onChanged: (_) => _onAddressChanged(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppInputField(
                controller: _postal,
                label: t.postalCode,
                prefixIcon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                onChanged: (_) => _onAddressChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: AppInputField(
                controller: _city,
                label: t.city,
                prefixIcon: Icons.location_city_outlined,
                onChanged: (_) => _onAddressChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (geo != null) _mapPreview(t, geo),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _mapPreview(AppLocalizations t, GeoResult geo) {
    final group = _group;
    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaticMap(
            lat: geo.lat,
            lng: geo.lng,
            apiKey: AppConstants.googleApiKey,
          ),
          const SizedBox(height: 12),
          Text(t.t('confirmAddressQuestion'), style: AppTextStyles.bodyBold),
          const SizedBox(height: 4),
          Text(geo.formattedAddress, style: AppTextStyles.caption),
          const SizedBox(height: 12),
          if (group != null)
            Row(
              children: [
                Text('${t.t('deliveryArea')}: ', style: AppTextStyles.caption),
                const SizedBox(width: 4),
                GoldBadge(text: group, icon: Icons.location_on),
              ],
            )
          else
            // Out of coverage: not an error — the customer can still order and
            // we schedule their delivery afterwards.
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(t.t('outsideDeliveryOrderAnyway'),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
