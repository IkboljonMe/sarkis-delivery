import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/geocoding_service.dart';
import '../../services/phone_check_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/static_map.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 0 = name, 1 = address, 2 = phone number.
  int _step = 0;

  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _referredBy = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();
  final _phone = TextEditingController();
  String _countryCode = '+49';

  String? _nameError;
  String? _lastNameError;
  String? _phoneError;

  // Required legal consent before registration can proceed.
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  static const _termsUrl = AppConstants.termsUrl;
  static const _privacyUrl = AppConstants.privacyUrl;

  // Live phone state for step 3.
  bool _phoneValid = false; // enough digits typed
  bool? _phoneExists; // null = unknown/not yet checked
  bool _checkingPhone = false;
  Timer? _phoneTimer;

  GeoResult? _geo;
  bool _geocoding = false;

  List<AddressSuggestion> _suggestions = const [];
  Timer? _acTimer;

  // Matches the most common emoji / pictograph ranges.
  static final RegExp _emoji = RegExp(
    r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2190}-\u{21FF}\u{2B00}-\u{2BFF}'
    r'\u{FE00}-\u{FE0F}\u{1F1E6}-\u{1F1FF}\u{200D}\u{20E3}\u{2122}\u{2139}]',
    unicode: true,
  );

  @override
  void initState() {
    super.initState();
    // Prefill from an already-established identity (e.g. Google sign-in), so a
    // new social user only has to accept the terms and set their location.
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      if (user.name.trim().isNotEmpty) _name.text = user.name;
      if (user.lastName.trim().isNotEmpty) _lastName.text = user.lastName;
    }
  }

  @override
  void dispose() {
    _acTimer?.cancel();
    _phoneTimer?.cancel();
    _name.dispose();
    _lastName.dispose();
    _referredBy.dispose();
    _address.dispose();
    _city.dispose();
    _postal.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  /// Validates a person's name/surname. Returns a localized error or null.
  String? _nameProblem(String raw, AppLocalizations t, {required bool isLast}) {
    final v = raw.trim();
    if (v.isEmpty) {
      return isLast ? t.t('errLastNameRequired') : t.t('errNameRequired');
    }
    if (v.length < 3) return t.t('errTooShort');
    if (v.length > 15) return t.t('errTooLong');
    if (_emoji.hasMatch(v)) return t.t('errNoEmoji');
    return null;
  }

  // ---- Step 1: name ----
  void _next(AppLocalizations t) {
    _dismissKeyboard();
    final ne = _nameProblem(_name.text, t, isLast: false);
    final le = _nameProblem(_lastName.text, t, isLast: true);
    setState(() {
      _nameError = ne;
      _lastNameError = le;
    });
    if (ne != null || le != null) return;
    setState(() => _step = 1);
  }

  void _back() {
    _dismissKeyboard();
    setState(() => _step = (_step - 1).clamp(0, 2));
  }

  // ---- Step 2: address ----
  void _onAddressTyping(String v) {
    if (_geo != null) setState(() => _geo = null);
    _acTimer?.cancel();
    if (v.trim().length < 3) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
      return;
    }
    _acTimer = Timer(const Duration(milliseconds: 350), () async {
      final res = await GeocodingService.instance.autocomplete(v);
      if (!mounted) return;
      setState(() => _suggestions = res);
    });
  }

  void _onCityPostalChanged() {
    if (_geo != null) setState(() => _geo = null);
  }

  Future<void> _pickSuggestion(AddressSuggestion s) async {
    _dismissKeyboard();
    _address.text = s.mainText.isNotEmpty ? s.mainText : s.description;
    setState(() {
      _suggestions = const [];
      _geocoding = true;
      _geo = null;
    });
    final result = await GeocodingService.instance.geocode(s.description);
    if (!mounted) return;
    setState(() {
      _geocoding = false;
      _geo = result;
      if (result != null) {
        if (result.postalCode.isNotEmpty) _postal.text = result.postalCode;
        if (result.city.isNotEmpty) _city.text = result.city;
      }
    });
  }

  Future<void> _checkOnMap(AppLocalizations t) async {
    _dismissKeyboard();
    if (_address.text.trim().isEmpty ||
        _city.text.trim().isEmpty ||
        _postal.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: t.t('fillAllAddress'));
      return;
    }
    setState(() {
      _geocoding = true;
      _geo = null;
      _suggestions = const [];
    });
    final query =
        '${_address.text.trim()}, ${_postal.text.trim()} ${_city.text.trim()}, Germany';
    final result = await GeocodingService.instance.geocode(query);
    if (!mounted) return;
    setState(() {
      _geocoding = false;
      _geo = result;
    });
    if (result == null) Fluttertoast.showToast(msg: t.t('addressNotFound'));
  }

  // Address confirmed: build the draft and move on. A user who is already
  // signed in (logged in but no profile) has no phone step — just save.
  Future<void> _continueFromAddress() async {
    final geo = _geo;
    if (geo == null) return;
    _dismissKeyboard();
    final auth = context.read<AuthProvider>();
    final locale = context.read<LocaleProvider>();
    // group is resolved from lat/lng after the phone is verified
    // (AuthProvider.completeRegistration).
    final draft = RegistrationDraft()
      ..name = _name.text.trim()
      ..lastName = _lastName.text.trim()
      ..referredBy = _referredBy.text.trim()
      ..address = _address.text.trim()
      ..city = geo.city.isNotEmpty ? geo.city : _city.text.trim()
      ..postalCode =
          geo.postalCode.isNotEmpty ? geo.postalCode : _postal.text.trim()
      ..lat = geo.lat
      ..lng = geo.lng
      ..language = locale.locale.languageCode;
    auth.authMode = 'register';
    auth.saveDraft(draft);
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
    setState(() => _step = 2);
  }

  // ---- Step 3: phone ----
  // Live-validates the number and (debounced) checks whether it already belongs
  // to a registered customer, so Continue stays disabled until it's a new,
  // valid number.
  void _onPhoneChanged() {
    if (_phoneError != null) _phoneError = null;
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    final valid = digits.length >= 6;
    setState(() {
      _phoneValid = valid;
      _phoneExists = null;
      _checkingPhone = valid;
    });
    _phoneTimer?.cancel();
    if (!valid) return;
    final number = AuthProvider.buildE164(_countryCode, _phone.text);
    _phoneTimer = Timer(const Duration(milliseconds: 600), () async {
      final exists = await PhoneCheckService.instance.exists(number);
      if (!mounted) return;
      setState(() {
        _checkingPhone = false;
        _phoneExists = exists;
      });
    });
  }

  // "Log in" shortcut when the entered number is already registered: verify the
  // same number in login mode.
  Future<void> _loginWithNumber(AppLocalizations t) async {
    final auth = context.read<AuthProvider>();
    auth.authMode = 'login';
    auth.clearDraft();
    await _submitPhone(t);
  }

  Future<void> _submitPhone(AppLocalizations t) async {
    _dismissKeyboard();
    final raw = _phone.text.trim();
    if (raw.isEmpty) {
      setState(() => _phoneError = t.t('errPhoneRequired'));
      return;
    }
    setState(() => _phoneError = null);
    final number = AuthProvider.buildE164(_countryCode, raw);
    final auth = context.read<AuthProvider>();
    await auth.startPhoneVerification(number);
    if (!mounted) return;
    if (auth.status == AuthStatus.codeSent) {
      Navigator.pushNamed(context, '/otp', arguments: number);
    } else if (auth.status == AuthStatus.authenticated) {
      // Instant verification on this device — no code screen needed.
      if (auth.user != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
      } else {
        final ok = await auth.completeRegistration();
        if (!mounted) return;
        if (ok) {
          Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
        } else {
          Fluttertoast.showToast(msg: auth.error ?? 'Failed to save');
        }
      }
    } else if (auth.error != null) {
      Fluttertoast.showToast(msg: auth.error!);
      auth.resetError();
    }
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
                    child: _stepBody(t),
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

  Widget _stepBody(AppLocalizations t) {
    switch (_step) {
      case 0:
        return _nameStep(t);
      case 1:
        return _addressStep(t);
      default:
        return _phoneStep(t);
    }
  }

  Widget _bottomButton(AppLocalizations t, bool busy) {
    if (_step == 0) {
      final canContinue = _agreeTerms && _agreePrivacy;
      return GoldenButton(
        label: t.continueLabel,
        onPressed: canContinue ? () => _next(t) : null,
      );
    }
    if (_step == 2) {
      // Number already registered → offer to log in instead.
      if (_phoneExists == true) {
        return GoldenButton(
          label: t.t('login'),
          loading: busy,
          onPressed: () => _loginWithNumber(t),
        );
      }
      // Disabled until a valid, not-yet-registered number is entered.
      final canSend =
          _phoneValid && !_checkingPhone && _phoneExists != true;
      return GoldenButton(
        label: t.continueLabel,
        loading: busy,
        onPressed: canSend ? () => _submitPhone(t) : null,
      );
    }
    // Address step.
    final canFinish = _geo != null;
    if (canFinish) {
      return GoldenButton(
        label: t.continueLabel,
        onPressed: _continueFromAddress,
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
          textInputAction: TextInputAction.next,
          errorText: _nameError,
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
          },
        ),
        const SizedBox(height: 16),
        AppInputField(
          controller: _lastName,
          label: t.t('lastName'),
          prefixIcon: Icons.badge_outlined,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          errorText: _lastNameError,
          onChanged: (_) {
            if (_lastNameError != null) setState(() => _lastNameError = null);
          },
        ),
        const SizedBox(height: 16),
        AppInputField(
          controller: _referredBy,
          label: t.t('referredByOptional'),
          prefixIcon: Icons.group_outlined,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        _consentTile(
          value: _agreeTerms,
          onChanged: (v) => setState(() => _agreeTerms = v),
          prefix: t.t('iAccept'),
          linkText: t.t('termsOfService'),
          onLinkTap: () => _openUrl(_termsUrl),
        ),
        const SizedBox(height: 4),
        _consentTile(
          value: _agreePrivacy,
          onChanged: (v) => setState(() => _agreePrivacy = v),
          prefix: t.t('iAccept'),
          linkText: t.t('privacyPolicy'),
          onLinkTap: () => _openUrl(_privacyUrl),
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  /// One required-consent row: a checkbox plus a "prefix + tappable link".
  Widget _consentTile({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String prefix,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('$prefix ', style: AppTextStyles.caption),
              GestureDetector(
                onTap: onLinkTap,
                child: Text(
                  linkText,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: url);
    }
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
          onChanged: _onAddressTyping,
        ),
        if (_suggestions.isNotEmpty && geo == null) _suggestionList(),
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
                onChanged: (_) => _onCityPostalChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: AppInputField(
                controller: _city,
                label: t.city,
                prefixIcon: Icons.location_city_outlined,
                onChanged: (_) => _onCityPostalChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (geo != null) _mapPreview(t, geo),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _suggestionList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _suggestions.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            InkWell(
              onTap: () => _pickSuggestion(_suggestions[i]),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.error, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _suggestions[i].mainText.isNotEmpty
                                ? _suggestions[i].mainText
                                : _suggestions[i].description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyBold,
                          ),
                          if (_suggestions[i].secondaryText.isNotEmpty)
                            Text(
                              _suggestions[i].secondaryText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _phoneStep(AppLocalizations t) {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.t('yourPhoneNumber'), style: AppTextStyles.headingL),
        const SizedBox(height: 8),
        Text(t.enterPhone, style: AppTextStyles.caption),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _countryCode,
                  dropdownColor: AppColors.surfaceElevated,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  style: AppTextStyles.body,
                  items: AppConstants.countryCodes
                      .map((c) => DropdownMenuItem(
                            value: c['code'],
                            child: Text('${c['flag']} ${c['code']}'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _countryCode = v!);
                    _onPhoneChanged(); // re-check against the new country code
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppInputField(
                controller: _phone,
                label: t.phone,
                hint: '170 1234567',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                errorText: _phoneError,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                ],
                onChanged: (_) => _onPhoneChanged(),
                onSubmitted: (_) {
                  if (_phoneValid && _phoneExists != true && !_checkingPhone) {
                    _submitPhone(t);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _phoneStatus(t),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  /// Inline status under the phone field: a spinner while checking, or an
  /// "already registered" notice when the number belongs to an existing account.
  Widget _phoneStatus(AppLocalizations t) {
    if (_checkingPhone) {
      return Row(
        children: [
          const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary)),
          const SizedBox(width: 10),
          Text(t.t('checkingNumber'), style: AppTextStyles.caption),
        ],
      );
    }
    if (_phoneExists == true) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.error.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(t.t('numberAlreadyRegistered'),
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.error)),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _mapPreview(AppLocalizations t, GeoResult geo) {
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
        ],
      ),
    );
  }
}
