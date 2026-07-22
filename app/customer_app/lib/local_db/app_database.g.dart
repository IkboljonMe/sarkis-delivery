// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalUserTable extends LocalUser
    with TableInfo<$LocalUserTable, LocalUserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _postalCodeMeta =
      const VerificationMeta('postalCode');
  @override
  late final GeneratedColumn<String> postalCode = GeneratedColumn<String>(
      'postal_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
      'group', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isVerifiedMeta =
      const VerificationMeta('isVerified');
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
      'is_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        phone,
        email,
        name,
        lastName,
        address,
        city,
        postalCode,
        group,
        lat,
        lng,
        language,
        photoUrl,
        isVerified,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user';
  @override
  VerificationContext validateIntegrity(Insertable<LocalUserData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('postal_code')) {
      context.handle(
          _postalCodeMeta,
          postalCode.isAcceptableOrUnknown(
              data['postal_code']!, _postalCodeMeta));
    }
    if (data.containsKey('group')) {
      context.handle(
          _groupMeta, group.isAcceptableOrUnknown(data['group']!, _groupMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('is_verified')) {
      context.handle(
          _isVerifiedMeta,
          isVerified.isAcceptableOrUnknown(
              data['is_verified']!, _isVerifiedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city'])!,
      postalCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}postal_code'])!,
      group: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng']),
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url'])!,
      isVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_verified'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalUserTable createAlias(String alias) {
    return $LocalUserTable(attachedDatabase, alias);
  }
}

class LocalUserData extends DataClass implements Insertable<LocalUserData> {
  final String id;
  final String phone;
  final String email;
  final String name;
  final String lastName;
  final String address;
  final String city;
  final String postalCode;
  final String group;
  final double? lat;
  final double? lng;
  final String language;
  final String photoUrl;
  final bool isVerified;
  final DateTime updatedAt;
  const LocalUserData(
      {required this.id,
      required this.phone,
      required this.email,
      required this.name,
      required this.lastName,
      required this.address,
      required this.city,
      required this.postalCode,
      required this.group,
      this.lat,
      this.lng,
      required this.language,
      required this.photoUrl,
      required this.isVerified,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['phone'] = Variable<String>(phone);
    map['email'] = Variable<String>(email);
    map['name'] = Variable<String>(name);
    map['last_name'] = Variable<String>(lastName);
    map['address'] = Variable<String>(address);
    map['city'] = Variable<String>(city);
    map['postal_code'] = Variable<String>(postalCode);
    map['group'] = Variable<String>(group);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['language'] = Variable<String>(language);
    map['photo_url'] = Variable<String>(photoUrl);
    map['is_verified'] = Variable<bool>(isVerified);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalUserCompanion toCompanion(bool nullToAbsent) {
    return LocalUserCompanion(
      id: Value(id),
      phone: Value(phone),
      email: Value(email),
      name: Value(name),
      lastName: Value(lastName),
      address: Value(address),
      city: Value(city),
      postalCode: Value(postalCode),
      group: Value(group),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      language: Value(language),
      photoUrl: Value(photoUrl),
      isVerified: Value(isVerified),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalUserData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserData(
      id: serializer.fromJson<String>(json['id']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String>(json['name']),
      lastName: serializer.fromJson<String>(json['lastName']),
      address: serializer.fromJson<String>(json['address']),
      city: serializer.fromJson<String>(json['city']),
      postalCode: serializer.fromJson<String>(json['postalCode']),
      group: serializer.fromJson<String>(json['group']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      language: serializer.fromJson<String>(json['language']),
      photoUrl: serializer.fromJson<String>(json['photoUrl']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String>(name),
      'lastName': serializer.toJson<String>(lastName),
      'address': serializer.toJson<String>(address),
      'city': serializer.toJson<String>(city),
      'postalCode': serializer.toJson<String>(postalCode),
      'group': serializer.toJson<String>(group),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'language': serializer.toJson<String>(language),
      'photoUrl': serializer.toJson<String>(photoUrl),
      'isVerified': serializer.toJson<bool>(isVerified),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalUserData copyWith(
          {String? id,
          String? phone,
          String? email,
          String? name,
          String? lastName,
          String? address,
          String? city,
          String? postalCode,
          String? group,
          Value<double?> lat = const Value.absent(),
          Value<double?> lng = const Value.absent(),
          String? language,
          String? photoUrl,
          bool? isVerified,
          DateTime? updatedAt}) =>
      LocalUserData(
        id: id ?? this.id,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        name: name ?? this.name,
        lastName: lastName ?? this.lastName,
        address: address ?? this.address,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode,
        group: group ?? this.group,
        lat: lat.present ? lat.value : this.lat,
        lng: lng.present ? lng.value : this.lng,
        language: language ?? this.language,
        photoUrl: photoUrl ?? this.photoUrl,
        isVerified: isVerified ?? this.isVerified,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalUserData copyWithCompanion(LocalUserCompanion data) {
    return LocalUserData(
      id: data.id.present ? data.id.value : this.id,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      postalCode:
          data.postalCode.present ? data.postalCode.value : this.postalCode,
      group: data.group.present ? data.group.value : this.group,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      language: data.language.present ? data.language.value : this.language,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      isVerified:
          data.isVerified.present ? data.isVerified.value : this.isVerified,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserData(')
          ..write('id: $id, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('postalCode: $postalCode, ')
          ..write('group: $group, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('language: $language, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isVerified: $isVerified, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      phone,
      email,
      name,
      lastName,
      address,
      city,
      postalCode,
      group,
      lat,
      lng,
      language,
      photoUrl,
      isVerified,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserData &&
          other.id == this.id &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.name == this.name &&
          other.lastName == this.lastName &&
          other.address == this.address &&
          other.city == this.city &&
          other.postalCode == this.postalCode &&
          other.group == this.group &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.language == this.language &&
          other.photoUrl == this.photoUrl &&
          other.isVerified == this.isVerified &&
          other.updatedAt == this.updatedAt);
}

class LocalUserCompanion extends UpdateCompanion<LocalUserData> {
  final Value<String> id;
  final Value<String> phone;
  final Value<String> email;
  final Value<String> name;
  final Value<String> lastName;
  final Value<String> address;
  final Value<String> city;
  final Value<String> postalCode;
  final Value<String> group;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String> language;
  final Value<String> photoUrl;
  final Value<bool> isVerified;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalUserCompanion({
    this.id = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.lastName = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.group = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.language = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUserCompanion.insert({
    required String id,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.lastName = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.group = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.language = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<LocalUserData> custom({
    Expression<String>? id,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? name,
    Expression<String>? lastName,
    Expression<String>? address,
    Expression<String>? city,
    Expression<String>? postalCode,
    Expression<String>? group,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? language,
    Expression<String>? photoUrl,
    Expression<bool>? isVerified,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (lastName != null) 'last_name': lastName,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (group != null) 'group': group,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (language != null) 'language': language,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (isVerified != null) 'is_verified': isVerified,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUserCompanion copyWith(
      {Value<String>? id,
      Value<String>? phone,
      Value<String>? email,
      Value<String>? name,
      Value<String>? lastName,
      Value<String>? address,
      Value<String>? city,
      Value<String>? postalCode,
      Value<String>? group,
      Value<double?>? lat,
      Value<double?>? lng,
      Value<String>? language,
      Value<String>? photoUrl,
      Value<bool>? isVerified,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalUserCompanion(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      group: group ?? this.group,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      language: language ?? this.language,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (postalCode.present) {
      map['postal_code'] = Variable<String>(postalCode.value);
    }
    if (group.present) {
      map['group'] = Variable<String>(group.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserCompanion(')
          ..write('id: $id, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('postalCode: $postalCode, ')
          ..write('group: $group, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('language: $language, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('isVerified: $isVerified, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RegistrationDraftsTable extends RegistrationDrafts
    with TableInfo<$RegistrationDraftsTable, RegistrationDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistrationDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _referredByMeta =
      const VerificationMeta('referredBy');
  @override
  late final GeneratedColumn<String> referredBy = GeneratedColumn<String>(
      'referred_by', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
      'city', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _postalCodeMeta =
      const VerificationMeta('postalCode');
  @override
  late final GeneratedColumn<String> postalCode = GeneratedColumn<String>(
      'postal_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        lastName,
        referredBy,
        address,
        city,
        postalCode,
        groupName,
        lat,
        lng,
        language
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registration_drafts';
  @override
  VerificationContext validateIntegrity(Insertable<RegistrationDraft> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    }
    if (data.containsKey('referred_by')) {
      context.handle(
          _referredByMeta,
          referredBy.isAcceptableOrUnknown(
              data['referred_by']!, _referredByMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('city')) {
      context.handle(
          _cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    if (data.containsKey('postal_code')) {
      context.handle(
          _postalCodeMeta,
          postalCode.isAcceptableOrUnknown(
              data['postal_code']!, _postalCodeMeta));
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegistrationDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistrationDraft(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      referredBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}referred_by'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      city: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city'])!,
      postalCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}postal_code'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat']),
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng']),
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
    );
  }

  @override
  $RegistrationDraftsTable createAlias(String alias) {
    return $RegistrationDraftsTable(attachedDatabase, alias);
  }
}

class RegistrationDraft extends DataClass
    implements Insertable<RegistrationDraft> {
  final String id;
  final String name;
  final String lastName;
  final String referredBy;
  final String address;
  final String city;
  final String postalCode;
  final String groupName;
  final double? lat;
  final double? lng;
  final String language;
  const RegistrationDraft(
      {required this.id,
      required this.name,
      required this.lastName,
      required this.referredBy,
      required this.address,
      required this.city,
      required this.postalCode,
      required this.groupName,
      this.lat,
      this.lng,
      required this.language});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['last_name'] = Variable<String>(lastName);
    map['referred_by'] = Variable<String>(referredBy);
    map['address'] = Variable<String>(address);
    map['city'] = Variable<String>(city);
    map['postal_code'] = Variable<String>(postalCode);
    map['group_name'] = Variable<String>(groupName);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['language'] = Variable<String>(language);
    return map;
  }

  RegistrationDraftsCompanion toCompanion(bool nullToAbsent) {
    return RegistrationDraftsCompanion(
      id: Value(id),
      name: Value(name),
      lastName: Value(lastName),
      referredBy: Value(referredBy),
      address: Value(address),
      city: Value(city),
      postalCode: Value(postalCode),
      groupName: Value(groupName),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      language: Value(language),
    );
  }

  factory RegistrationDraft.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistrationDraft(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lastName: serializer.fromJson<String>(json['lastName']),
      referredBy: serializer.fromJson<String>(json['referredBy']),
      address: serializer.fromJson<String>(json['address']),
      city: serializer.fromJson<String>(json['city']),
      postalCode: serializer.fromJson<String>(json['postalCode']),
      groupName: serializer.fromJson<String>(json['groupName']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      language: serializer.fromJson<String>(json['language']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'lastName': serializer.toJson<String>(lastName),
      'referredBy': serializer.toJson<String>(referredBy),
      'address': serializer.toJson<String>(address),
      'city': serializer.toJson<String>(city),
      'postalCode': serializer.toJson<String>(postalCode),
      'groupName': serializer.toJson<String>(groupName),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'language': serializer.toJson<String>(language),
    };
  }

  RegistrationDraft copyWith(
          {String? id,
          String? name,
          String? lastName,
          String? referredBy,
          String? address,
          String? city,
          String? postalCode,
          String? groupName,
          Value<double?> lat = const Value.absent(),
          Value<double?> lng = const Value.absent(),
          String? language}) =>
      RegistrationDraft(
        id: id ?? this.id,
        name: name ?? this.name,
        lastName: lastName ?? this.lastName,
        referredBy: referredBy ?? this.referredBy,
        address: address ?? this.address,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode,
        groupName: groupName ?? this.groupName,
        lat: lat.present ? lat.value : this.lat,
        lng: lng.present ? lng.value : this.lng,
        language: language ?? this.language,
      );
  RegistrationDraft copyWithCompanion(RegistrationDraftsCompanion data) {
    return RegistrationDraft(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      referredBy:
          data.referredBy.present ? data.referredBy.value : this.referredBy,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      postalCode:
          data.postalCode.present ? data.postalCode.value : this.postalCode,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      language: data.language.present ? data.language.value : this.language,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistrationDraft(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastName: $lastName, ')
          ..write('referredBy: $referredBy, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('postalCode: $postalCode, ')
          ..write('groupName: $groupName, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('language: $language')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, lastName, referredBy, address, city,
      postalCode, groupName, lat, lng, language);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistrationDraft &&
          other.id == this.id &&
          other.name == this.name &&
          other.lastName == this.lastName &&
          other.referredBy == this.referredBy &&
          other.address == this.address &&
          other.city == this.city &&
          other.postalCode == this.postalCode &&
          other.groupName == this.groupName &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.language == this.language);
}

class RegistrationDraftsCompanion extends UpdateCompanion<RegistrationDraft> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> lastName;
  final Value<String> referredBy;
  final Value<String> address;
  final Value<String> city;
  final Value<String> postalCode;
  final Value<String> groupName;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String> language;
  final Value<int> rowid;
  const RegistrationDraftsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastName = const Value.absent(),
    this.referredBy = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.groupName = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.language = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RegistrationDraftsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastName = const Value.absent(),
    this.referredBy = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.groupName = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.language = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<RegistrationDraft> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? lastName,
    Expression<String>? referredBy,
    Expression<String>? address,
    Expression<String>? city,
    Expression<String>? postalCode,
    Expression<String>? groupName,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? language,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lastName != null) 'last_name': lastName,
      if (referredBy != null) 'referred_by': referredBy,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      if (groupName != null) 'group_name': groupName,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (language != null) 'language': language,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RegistrationDraftsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? lastName,
      Value<String>? referredBy,
      Value<String>? address,
      Value<String>? city,
      Value<String>? postalCode,
      Value<String>? groupName,
      Value<double?>? lat,
      Value<double?>? lng,
      Value<String>? language,
      Value<int>? rowid}) {
    return RegistrationDraftsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      referredBy: referredBy ?? this.referredBy,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      groupName: groupName ?? this.groupName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      language: language ?? this.language,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (referredBy.present) {
      map['referred_by'] = Variable<String>(referredBy.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (postalCode.present) {
      map['postal_code'] = Variable<String>(postalCode.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistrationDraftsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastName: $lastName, ')
          ..write('referredBy: $referredBy, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('postalCode: $postalCode, ')
          ..write('groupName: $groupName, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('language: $language, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameJsonMeta =
      const VerificationMeta('nameJson');
  @override
  late final GeneratedColumn<String> nameJson = GeneratedColumn<String>(
      'name_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, nameJson, imageUrl, sortOrder, isActive, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name_json')) {
      context.handle(_nameJsonMeta,
          nameJson.isAcceptableOrUnknown(data['name_json']!, _nameJsonMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nameJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_json'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String nameJson;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime updatedAt;
  const Category(
      {required this.id,
      required this.nameJson,
      required this.imageUrl,
      required this.sortOrder,
      required this.isActive,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name_json'] = Variable<String>(nameJson);
    map['image_url'] = Variable<String>(imageUrl);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      nameJson: Value(nameJson),
      imageUrl: Value(imageUrl),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      nameJson: serializer.fromJson<String>(json['nameJson']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nameJson': serializer.toJson<String>(nameJson),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Category copyWith(
          {String? id,
          String? nameJson,
          String? imageUrl,
          int? sortOrder,
          bool? isActive,
          DateTime? updatedAt}) =>
      Category(
        id: id ?? this.id,
        nameJson: nameJson ?? this.nameJson,
        imageUrl: imageUrl ?? this.imageUrl,
        sortOrder: sortOrder ?? this.sortOrder,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      nameJson: data.nameJson.present ? data.nameJson.value : this.nameJson,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('nameJson: $nameJson, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nameJson, imageUrl, sortOrder, isActive, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.nameJson == this.nameJson &&
          other.imageUrl == this.imageUrl &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> nameJson;
  final Value<String> imageUrl;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.nameJson = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    this.nameJson = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? nameJson,
    Expression<String>? imageUrl,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameJson != null) 'name_json': nameJson,
      if (imageUrl != null) 'image_url': imageUrl,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? nameJson,
      Value<String>? imageUrl,
      Value<int>? sortOrder,
      Value<bool>? isActive,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      nameJson: nameJson ?? this.nameJson,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nameJson.present) {
      map['name_json'] = Variable<String>(nameJson.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('nameJson: $nameJson, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameJsonMeta =
      const VerificationMeta('nameJson');
  @override
  late final GeneratedColumn<String> nameJson = GeneratedColumn<String>(
      'name_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _descriptionJsonMeta =
      const VerificationMeta('descriptionJson');
  @override
  late final GeneratedColumn<String> descriptionJson = GeneratedColumn<String>(
      'description_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _maxQtyMeta = const VerificationMeta('maxQty');
  @override
  late final GeneratedColumn<int> maxQty = GeneratedColumn<int>(
      'max_qty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _imagesJsonMeta =
      const VerificationMeta('imagesJson');
  @override
  late final GeneratedColumn<String> imagesJson = GeneratedColumn<String>(
      'images_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountTypeMeta =
      const VerificationMeta('discountType');
  @override
  late final GeneratedColumn<String> discountType = GeneratedColumn<String>(
      'discount_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _discountValueMeta =
      const VerificationMeta('discountValue');
  @override
  late final GeneratedColumn<double> discountValue = GeneratedColumn<double>(
      'discount_value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        nameJson,
        descriptionJson,
        price,
        unit,
        maxQty,
        imageUrl,
        imagesJson,
        isActive,
        sortOrder,
        discountType,
        discountValue,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name_json')) {
      context.handle(_nameJsonMeta,
          nameJson.isAcceptableOrUnknown(data['name_json']!, _nameJsonMeta));
    }
    if (data.containsKey('description_json')) {
      context.handle(
          _descriptionJsonMeta,
          descriptionJson.isAcceptableOrUnknown(
              data['description_json']!, _descriptionJsonMeta));
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('max_qty')) {
      context.handle(_maxQtyMeta,
          maxQty.isAcceptableOrUnknown(data['max_qty']!, _maxQtyMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('images_json')) {
      context.handle(
          _imagesJsonMeta,
          imagesJson.isAcceptableOrUnknown(
              data['images_json']!, _imagesJsonMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('discount_type')) {
      context.handle(
          _discountTypeMeta,
          discountType.isAcceptableOrUnknown(
              data['discount_type']!, _discountTypeMeta));
    }
    if (data.containsKey('discount_value')) {
      context.handle(
          _discountValueMeta,
          discountValue.isAcceptableOrUnknown(
              data['discount_value']!, _discountValueMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      nameJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_json'])!,
      descriptionJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}description_json'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      maxQty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_qty'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      imagesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}images_json'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      discountType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}discount_type'])!,
      discountValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount_value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final String id;
  final String categoryId;
  final String nameJson;
  final String descriptionJson;
  final double price;
  final String unit;
  final int maxQty;
  final String imageUrl;
  final String imagesJson;
  final bool isActive;
  final int sortOrder;
  final String discountType;
  final double discountValue;
  final DateTime updatedAt;
  const Product(
      {required this.id,
      required this.categoryId,
      required this.nameJson,
      required this.descriptionJson,
      required this.price,
      required this.unit,
      required this.maxQty,
      required this.imageUrl,
      required this.imagesJson,
      required this.isActive,
      required this.sortOrder,
      required this.discountType,
      required this.discountValue,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['name_json'] = Variable<String>(nameJson);
    map['description_json'] = Variable<String>(descriptionJson);
    map['price'] = Variable<double>(price);
    map['unit'] = Variable<String>(unit);
    map['max_qty'] = Variable<int>(maxQty);
    map['image_url'] = Variable<String>(imageUrl);
    map['images_json'] = Variable<String>(imagesJson);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['discount_type'] = Variable<String>(discountType);
    map['discount_value'] = Variable<double>(discountValue);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      nameJson: Value(nameJson),
      descriptionJson: Value(descriptionJson),
      price: Value(price),
      unit: Value(unit),
      maxQty: Value(maxQty),
      imageUrl: Value(imageUrl),
      imagesJson: Value(imagesJson),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      discountType: Value(discountType),
      discountValue: Value(discountValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      nameJson: serializer.fromJson<String>(json['nameJson']),
      descriptionJson: serializer.fromJson<String>(json['descriptionJson']),
      price: serializer.fromJson<double>(json['price']),
      unit: serializer.fromJson<String>(json['unit']),
      maxQty: serializer.fromJson<int>(json['maxQty']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      imagesJson: serializer.fromJson<String>(json['imagesJson']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      discountType: serializer.fromJson<String>(json['discountType']),
      discountValue: serializer.fromJson<double>(json['discountValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'nameJson': serializer.toJson<String>(nameJson),
      'descriptionJson': serializer.toJson<String>(descriptionJson),
      'price': serializer.toJson<double>(price),
      'unit': serializer.toJson<String>(unit),
      'maxQty': serializer.toJson<int>(maxQty),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'imagesJson': serializer.toJson<String>(imagesJson),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'discountType': serializer.toJson<String>(discountType),
      'discountValue': serializer.toJson<double>(discountValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Product copyWith(
          {String? id,
          String? categoryId,
          String? nameJson,
          String? descriptionJson,
          double? price,
          String? unit,
          int? maxQty,
          String? imageUrl,
          String? imagesJson,
          bool? isActive,
          int? sortOrder,
          String? discountType,
          double? discountValue,
          DateTime? updatedAt}) =>
      Product(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        nameJson: nameJson ?? this.nameJson,
        descriptionJson: descriptionJson ?? this.descriptionJson,
        price: price ?? this.price,
        unit: unit ?? this.unit,
        maxQty: maxQty ?? this.maxQty,
        imageUrl: imageUrl ?? this.imageUrl,
        imagesJson: imagesJson ?? this.imagesJson,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
        discountType: discountType ?? this.discountType,
        discountValue: discountValue ?? this.discountValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      nameJson: data.nameJson.present ? data.nameJson.value : this.nameJson,
      descriptionJson: data.descriptionJson.present
          ? data.descriptionJson.value
          : this.descriptionJson,
      price: data.price.present ? data.price.value : this.price,
      unit: data.unit.present ? data.unit.value : this.unit,
      maxQty: data.maxQty.present ? data.maxQty.value : this.maxQty,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      imagesJson:
          data.imagesJson.present ? data.imagesJson.value : this.imagesJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      discountType: data.discountType.present
          ? data.discountType.value
          : this.discountType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('nameJson: $nameJson, ')
          ..write('descriptionJson: $descriptionJson, ')
          ..write('price: $price, ')
          ..write('unit: $unit, ')
          ..write('maxQty: $maxQty, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      categoryId,
      nameJson,
      descriptionJson,
      price,
      unit,
      maxQty,
      imageUrl,
      imagesJson,
      isActive,
      sortOrder,
      discountType,
      discountValue,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.nameJson == this.nameJson &&
          other.descriptionJson == this.descriptionJson &&
          other.price == this.price &&
          other.unit == this.unit &&
          other.maxQty == this.maxQty &&
          other.imageUrl == this.imageUrl &&
          other.imagesJson == this.imagesJson &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.discountType == this.discountType &&
          other.discountValue == this.discountValue &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> nameJson;
  final Value<String> descriptionJson;
  final Value<double> price;
  final Value<String> unit;
  final Value<int> maxQty;
  final Value<String> imageUrl;
  final Value<String> imagesJson;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<String> discountType;
  final Value<double> discountValue;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.nameJson = const Value.absent(),
    this.descriptionJson = const Value.absent(),
    this.price = const Value.absent(),
    this.unit = const Value.absent(),
    this.maxQty = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.imagesJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String categoryId,
    this.nameJson = const Value.absent(),
    this.descriptionJson = const Value.absent(),
    required double price,
    this.unit = const Value.absent(),
    this.maxQty = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.imagesJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.discountType = const Value.absent(),
    this.discountValue = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        categoryId = Value(categoryId),
        price = Value(price),
        updatedAt = Value(updatedAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? nameJson,
    Expression<String>? descriptionJson,
    Expression<double>? price,
    Expression<String>? unit,
    Expression<int>? maxQty,
    Expression<String>? imageUrl,
    Expression<String>? imagesJson,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<String>? discountType,
    Expression<double>? discountValue,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (nameJson != null) 'name_json': nameJson,
      if (descriptionJson != null) 'description_json': descriptionJson,
      if (price != null) 'price': price,
      if (unit != null) 'unit': unit,
      if (maxQty != null) 'max_qty': maxQty,
      if (imageUrl != null) 'image_url': imageUrl,
      if (imagesJson != null) 'images_json': imagesJson,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (discountType != null) 'discount_type': discountType,
      if (discountValue != null) 'discount_value': discountValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? categoryId,
      Value<String>? nameJson,
      Value<String>? descriptionJson,
      Value<double>? price,
      Value<String>? unit,
      Value<int>? maxQty,
      Value<String>? imageUrl,
      Value<String>? imagesJson,
      Value<bool>? isActive,
      Value<int>? sortOrder,
      Value<String>? discountType,
      Value<double>? discountValue,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      nameJson: nameJson ?? this.nameJson,
      descriptionJson: descriptionJson ?? this.descriptionJson,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      maxQty: maxQty ?? this.maxQty,
      imageUrl: imageUrl ?? this.imageUrl,
      imagesJson: imagesJson ?? this.imagesJson,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (nameJson.present) {
      map['name_json'] = Variable<String>(nameJson.value);
    }
    if (descriptionJson.present) {
      map['description_json'] = Variable<String>(descriptionJson.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (maxQty.present) {
      map['max_qty'] = Variable<int>(maxQty.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (imagesJson.present) {
      map['images_json'] = Variable<String>(imagesJson.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (discountType.present) {
      map['discount_type'] = Variable<String>(discountType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<double>(discountValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('nameJson: $nameJson, ')
          ..write('descriptionJson: $descriptionJson, ')
          ..write('price: $price, ')
          ..write('unit: $unit, ')
          ..write('maxQty: $maxQty, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('discountType: $discountType, ')
          ..write('discountValue: $discountValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CartItemsTable extends CartItems
    with TableInfo<$CartItemsTable, CartItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
      'qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [productId, qty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cart_items';
  @override
  VerificationContext validateIntegrity(Insertable<CartItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
          _qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  CartItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartItem(
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      qty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty'])!,
    );
  }

  @override
  $CartItemsTable createAlias(String alias) {
    return $CartItemsTable(attachedDatabase, alias);
  }
}

class CartItem extends DataClass implements Insertable<CartItem> {
  final String productId;
  final int qty;
  const CartItem({required this.productId, required this.qty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['qty'] = Variable<int>(qty);
    return map;
  }

  CartItemsCompanion toCompanion(bool nullToAbsent) {
    return CartItemsCompanion(
      productId: Value(productId),
      qty: Value(qty),
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartItem(
      productId: serializer.fromJson<String>(json['productId']),
      qty: serializer.fromJson<int>(json['qty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'qty': serializer.toJson<int>(qty),
    };
  }

  CartItem copyWith({String? productId, int? qty}) => CartItem(
        productId: productId ?? this.productId,
        qty: qty ?? this.qty,
      );
  CartItem copyWithCompanion(CartItemsCompanion data) {
    return CartItem(
      productId: data.productId.present ? data.productId.value : this.productId,
      qty: data.qty.present ? data.qty.value : this.qty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartItem(')
          ..write('productId: $productId, ')
          ..write('qty: $qty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, qty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItem &&
          other.productId == this.productId &&
          other.qty == this.qty);
}

class CartItemsCompanion extends UpdateCompanion<CartItem> {
  final Value<String> productId;
  final Value<int> qty;
  final Value<int> rowid;
  const CartItemsCompanion({
    this.productId = const Value.absent(),
    this.qty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CartItemsCompanion.insert({
    required String productId,
    required int qty,
    this.rowid = const Value.absent(),
  })  : productId = Value(productId),
        qty = Value(qty);
  static Insertable<CartItem> custom({
    Expression<String>? productId,
    Expression<int>? qty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (qty != null) 'qty': qty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CartItemsCompanion copyWith(
      {Value<String>? productId, Value<int>? qty, Value<int>? rowid}) {
    return CartItemsCompanion(
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartItemsCompanion(')
          ..write('productId: $productId, ')
          ..write('qty: $qty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CartMetaTable extends CartMeta
    with TableInfo<$CartMetaTable, CartMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _shiftIdMeta =
      const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
      'shift_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _couponCodeMeta =
      const VerificationMeta('couponCode');
  @override
  late final GeneratedColumn<String> couponCode = GeneratedColumn<String>(
      'coupon_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _editingOrderIdMeta =
      const VerificationMeta('editingOrderId');
  @override
  late final GeneratedColumn<String> editingOrderId = GeneratedColumn<String>(
      'editing_order_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns =>
      [id, shiftId, couponCode, editingOrderId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cart_meta';
  @override
  VerificationContext validateIntegrity(Insertable<CartMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta,
          shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    }
    if (data.containsKey('coupon_code')) {
      context.handle(
          _couponCodeMeta,
          couponCode.isAcceptableOrUnknown(
              data['coupon_code']!, _couponCodeMeta));
    }
    if (data.containsKey('editing_order_id')) {
      context.handle(
          _editingOrderIdMeta,
          editingOrderId.isAcceptableOrUnknown(
              data['editing_order_id']!, _editingOrderIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CartMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartMetaData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      shiftId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_id'])!,
      couponCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coupon_code'])!,
      editingOrderId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}editing_order_id'])!,
    );
  }

  @override
  $CartMetaTable createAlias(String alias) {
    return $CartMetaTable(attachedDatabase, alias);
  }
}

class CartMetaData extends DataClass implements Insertable<CartMetaData> {
  final int id;
  final String shiftId;
  final String couponCode;
  final String editingOrderId;
  const CartMetaData(
      {required this.id,
      required this.shiftId,
      required this.couponCode,
      required this.editingOrderId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shift_id'] = Variable<String>(shiftId);
    map['coupon_code'] = Variable<String>(couponCode);
    map['editing_order_id'] = Variable<String>(editingOrderId);
    return map;
  }

  CartMetaCompanion toCompanion(bool nullToAbsent) {
    return CartMetaCompanion(
      id: Value(id),
      shiftId: Value(shiftId),
      couponCode: Value(couponCode),
      editingOrderId: Value(editingOrderId),
    );
  }

  factory CartMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartMetaData(
      id: serializer.fromJson<int>(json['id']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      couponCode: serializer.fromJson<String>(json['couponCode']),
      editingOrderId: serializer.fromJson<String>(json['editingOrderId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shiftId': serializer.toJson<String>(shiftId),
      'couponCode': serializer.toJson<String>(couponCode),
      'editingOrderId': serializer.toJson<String>(editingOrderId),
    };
  }

  CartMetaData copyWith(
          {int? id,
          String? shiftId,
          String? couponCode,
          String? editingOrderId}) =>
      CartMetaData(
        id: id ?? this.id,
        shiftId: shiftId ?? this.shiftId,
        couponCode: couponCode ?? this.couponCode,
        editingOrderId: editingOrderId ?? this.editingOrderId,
      );
  CartMetaData copyWithCompanion(CartMetaCompanion data) {
    return CartMetaData(
      id: data.id.present ? data.id.value : this.id,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      couponCode:
          data.couponCode.present ? data.couponCode.value : this.couponCode,
      editingOrderId: data.editingOrderId.present
          ? data.editingOrderId.value
          : this.editingOrderId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartMetaData(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('couponCode: $couponCode, ')
          ..write('editingOrderId: $editingOrderId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shiftId, couponCode, editingOrderId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartMetaData &&
          other.id == this.id &&
          other.shiftId == this.shiftId &&
          other.couponCode == this.couponCode &&
          other.editingOrderId == this.editingOrderId);
}

class CartMetaCompanion extends UpdateCompanion<CartMetaData> {
  final Value<int> id;
  final Value<String> shiftId;
  final Value<String> couponCode;
  final Value<String> editingOrderId;
  const CartMetaCompanion({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.couponCode = const Value.absent(),
    this.editingOrderId = const Value.absent(),
  });
  CartMetaCompanion.insert({
    this.id = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.couponCode = const Value.absent(),
    this.editingOrderId = const Value.absent(),
  });
  static Insertable<CartMetaData> custom({
    Expression<int>? id,
    Expression<String>? shiftId,
    Expression<String>? couponCode,
    Expression<String>? editingOrderId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shiftId != null) 'shift_id': shiftId,
      if (couponCode != null) 'coupon_code': couponCode,
      if (editingOrderId != null) 'editing_order_id': editingOrderId,
    });
  }

  CartMetaCompanion copyWith(
      {Value<int>? id,
      Value<String>? shiftId,
      Value<String>? couponCode,
      Value<String>? editingOrderId}) {
    return CartMetaCompanion(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      couponCode: couponCode ?? this.couponCode,
      editingOrderId: editingOrderId ?? this.editingOrderId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (couponCode.present) {
      map['coupon_code'] = Variable<String>(couponCode.value);
    }
    if (editingOrderId.present) {
      map['editing_order_id'] = Variable<String>(editingOrderId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartMetaCompanion(')
          ..write('id: $id, ')
          ..write('shiftId: $shiftId, ')
          ..write('couponCode: $couponCode, ')
          ..write('editingOrderId: $editingOrderId')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _driverIdMeta =
      const VerificationMeta('driverId');
  @override
  late final GeneratedColumn<String> driverId = GeneratedColumn<String>(
      'driver_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _shiftIdMeta =
      const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
      'shift_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _shiftDateMeta =
      const VerificationMeta('shiftDate');
  @override
  late final GeneratedColumn<DateTime> shiftDate = GeneratedColumn<DateTime>(
      'shift_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _shiftLabelMeta =
      const VerificationMeta('shiftLabel');
  @override
  late final GeneratedColumn<String> shiftLabel = GeneratedColumn<String>(
      'shift_label', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _couponCodeMeta =
      const VerificationMeta('couponCode');
  @override
  late final GeneratedColumn<String> couponCode = GeneratedColumn<String>(
      'coupon_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _totalPriceMeta =
      const VerificationMeta('totalPrice');
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
      'total_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _userNameMeta =
      const VerificationMeta('userName');
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
      'user_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _userAddressMeta =
      const VerificationMeta('userAddress');
  @override
  late final GeneratedColumn<String> userAddress = GeneratedColumn<String>(
      'user_address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _userCityMeta =
      const VerificationMeta('userCity');
  @override
  late final GeneratedColumn<String> userCity = GeneratedColumn<String>(
      'user_city', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _adminNoteMeta =
      const VerificationMeta('adminNote');
  @override
  late final GeneratedColumn<String> adminNote = GeneratedColumn<String>(
      'admin_note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _pendingApprovalMeta =
      const VerificationMeta('pendingApproval');
  @override
  late final GeneratedColumn<bool> pendingApproval = GeneratedColumn<bool>(
      'pending_approval', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pending_approval" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _awaitingScheduleMeta =
      const VerificationMeta('awaitingSchedule');
  @override
  late final GeneratedColumn<bool> awaitingSchedule = GeneratedColumn<bool>(
      'awaiting_schedule', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("awaiting_schedule" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pendingSyncMeta =
      const VerificationMeta('pendingSync');
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
      'pending_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pending_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        status,
        driverId,
        shiftId,
        shiftDate,
        shiftLabel,
        subtotal,
        discount,
        couponCode,
        totalPrice,
        userName,
        userAddress,
        userCity,
        adminNote,
        pendingApproval,
        awaitingSchedule,
        createdAt,
        updatedAt,
        pendingSync
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<Order> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('driver_id')) {
      context.handle(_driverIdMeta,
          driverId.isAcceptableOrUnknown(data['driver_id']!, _driverIdMeta));
    }
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta,
          shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    }
    if (data.containsKey('shift_date')) {
      context.handle(_shiftDateMeta,
          shiftDate.isAcceptableOrUnknown(data['shift_date']!, _shiftDateMeta));
    }
    if (data.containsKey('shift_label')) {
      context.handle(
          _shiftLabelMeta,
          shiftLabel.isAcceptableOrUnknown(
              data['shift_label']!, _shiftLabelMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('coupon_code')) {
      context.handle(
          _couponCodeMeta,
          couponCode.isAcceptableOrUnknown(
              data['coupon_code']!, _couponCodeMeta));
    }
    if (data.containsKey('total_price')) {
      context.handle(
          _totalPriceMeta,
          totalPrice.isAcceptableOrUnknown(
              data['total_price']!, _totalPriceMeta));
    }
    if (data.containsKey('user_name')) {
      context.handle(_userNameMeta,
          userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta));
    }
    if (data.containsKey('user_address')) {
      context.handle(
          _userAddressMeta,
          userAddress.isAcceptableOrUnknown(
              data['user_address']!, _userAddressMeta));
    }
    if (data.containsKey('user_city')) {
      context.handle(_userCityMeta,
          userCity.isAcceptableOrUnknown(data['user_city']!, _userCityMeta));
    }
    if (data.containsKey('admin_note')) {
      context.handle(_adminNoteMeta,
          adminNote.isAcceptableOrUnknown(data['admin_note']!, _adminNoteMeta));
    }
    if (data.containsKey('pending_approval')) {
      context.handle(
          _pendingApprovalMeta,
          pendingApproval.isAcceptableOrUnknown(
              data['pending_approval']!, _pendingApprovalMeta));
    }
    if (data.containsKey('awaiting_schedule')) {
      context.handle(
          _awaitingScheduleMeta,
          awaitingSchedule.isAcceptableOrUnknown(
              data['awaiting_schedule']!, _awaitingScheduleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
          _pendingSyncMeta,
          pendingSync.isAcceptableOrUnknown(
              data['pending_sync']!, _pendingSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      driverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}driver_id'])!,
      shiftId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_id'])!,
      shiftDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}shift_date']),
      shiftLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_label'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      couponCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}coupon_code'])!,
      totalPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_price'])!,
      userName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_name'])!,
      userAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_address'])!,
      userCity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_city'])!,
      adminNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}admin_note'])!,
      pendingApproval: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending_approval'])!,
      awaitingSchedule: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}awaiting_schedule'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      pendingSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending_sync'])!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final String id;
  final String userId;
  final String status;
  final String driverId;
  final String shiftId;
  final DateTime? shiftDate;
  final String shiftLabel;
  final double subtotal;
  final double discount;
  final String couponCode;
  final double totalPrice;
  final String userName;
  final String userAddress;
  final String userCity;
  final String adminNote;
  final bool pendingApproval;
  final bool awaitingSchedule;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool pendingSync;
  const Order(
      {required this.id,
      required this.userId,
      required this.status,
      required this.driverId,
      required this.shiftId,
      this.shiftDate,
      required this.shiftLabel,
      required this.subtotal,
      required this.discount,
      required this.couponCode,
      required this.totalPrice,
      required this.userName,
      required this.userAddress,
      required this.userCity,
      required this.adminNote,
      required this.pendingApproval,
      required this.awaitingSchedule,
      required this.createdAt,
      required this.updatedAt,
      required this.pendingSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['status'] = Variable<String>(status);
    map['driver_id'] = Variable<String>(driverId);
    map['shift_id'] = Variable<String>(shiftId);
    if (!nullToAbsent || shiftDate != null) {
      map['shift_date'] = Variable<DateTime>(shiftDate);
    }
    map['shift_label'] = Variable<String>(shiftLabel);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount'] = Variable<double>(discount);
    map['coupon_code'] = Variable<String>(couponCode);
    map['total_price'] = Variable<double>(totalPrice);
    map['user_name'] = Variable<String>(userName);
    map['user_address'] = Variable<String>(userAddress);
    map['user_city'] = Variable<String>(userCity);
    map['admin_note'] = Variable<String>(adminNote);
    map['pending_approval'] = Variable<bool>(pendingApproval);
    map['awaiting_schedule'] = Variable<bool>(awaitingSchedule);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['pending_sync'] = Variable<bool>(pendingSync);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      userId: Value(userId),
      status: Value(status),
      driverId: Value(driverId),
      shiftId: Value(shiftId),
      shiftDate: shiftDate == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftDate),
      shiftLabel: Value(shiftLabel),
      subtotal: Value(subtotal),
      discount: Value(discount),
      couponCode: Value(couponCode),
      totalPrice: Value(totalPrice),
      userName: Value(userName),
      userAddress: Value(userAddress),
      userCity: Value(userCity),
      adminNote: Value(adminNote),
      pendingApproval: Value(pendingApproval),
      awaitingSchedule: Value(awaitingSchedule),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      pendingSync: Value(pendingSync),
    );
  }

  factory Order.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      status: serializer.fromJson<String>(json['status']),
      driverId: serializer.fromJson<String>(json['driverId']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      shiftDate: serializer.fromJson<DateTime?>(json['shiftDate']),
      shiftLabel: serializer.fromJson<String>(json['shiftLabel']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discount: serializer.fromJson<double>(json['discount']),
      couponCode: serializer.fromJson<String>(json['couponCode']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
      userName: serializer.fromJson<String>(json['userName']),
      userAddress: serializer.fromJson<String>(json['userAddress']),
      userCity: serializer.fromJson<String>(json['userCity']),
      adminNote: serializer.fromJson<String>(json['adminNote']),
      pendingApproval: serializer.fromJson<bool>(json['pendingApproval']),
      awaitingSchedule: serializer.fromJson<bool>(json['awaitingSchedule']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'status': serializer.toJson<String>(status),
      'driverId': serializer.toJson<String>(driverId),
      'shiftId': serializer.toJson<String>(shiftId),
      'shiftDate': serializer.toJson<DateTime?>(shiftDate),
      'shiftLabel': serializer.toJson<String>(shiftLabel),
      'subtotal': serializer.toJson<double>(subtotal),
      'discount': serializer.toJson<double>(discount),
      'couponCode': serializer.toJson<String>(couponCode),
      'totalPrice': serializer.toJson<double>(totalPrice),
      'userName': serializer.toJson<String>(userName),
      'userAddress': serializer.toJson<String>(userAddress),
      'userCity': serializer.toJson<String>(userCity),
      'adminNote': serializer.toJson<String>(adminNote),
      'pendingApproval': serializer.toJson<bool>(pendingApproval),
      'awaitingSchedule': serializer.toJson<bool>(awaitingSchedule),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pendingSync': serializer.toJson<bool>(pendingSync),
    };
  }

  Order copyWith(
          {String? id,
          String? userId,
          String? status,
          String? driverId,
          String? shiftId,
          Value<DateTime?> shiftDate = const Value.absent(),
          String? shiftLabel,
          double? subtotal,
          double? discount,
          String? couponCode,
          double? totalPrice,
          String? userName,
          String? userAddress,
          String? userCity,
          String? adminNote,
          bool? pendingApproval,
          bool? awaitingSchedule,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? pendingSync}) =>
      Order(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        status: status ?? this.status,
        driverId: driverId ?? this.driverId,
        shiftId: shiftId ?? this.shiftId,
        shiftDate: shiftDate.present ? shiftDate.value : this.shiftDate,
        shiftLabel: shiftLabel ?? this.shiftLabel,
        subtotal: subtotal ?? this.subtotal,
        discount: discount ?? this.discount,
        couponCode: couponCode ?? this.couponCode,
        totalPrice: totalPrice ?? this.totalPrice,
        userName: userName ?? this.userName,
        userAddress: userAddress ?? this.userAddress,
        userCity: userCity ?? this.userCity,
        adminNote: adminNote ?? this.adminNote,
        pendingApproval: pendingApproval ?? this.pendingApproval,
        awaitingSchedule: awaitingSchedule ?? this.awaitingSchedule,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        pendingSync: pendingSync ?? this.pendingSync,
      );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      status: data.status.present ? data.status.value : this.status,
      driverId: data.driverId.present ? data.driverId.value : this.driverId,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      shiftDate: data.shiftDate.present ? data.shiftDate.value : this.shiftDate,
      shiftLabel:
          data.shiftLabel.present ? data.shiftLabel.value : this.shiftLabel,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discount: data.discount.present ? data.discount.value : this.discount,
      couponCode:
          data.couponCode.present ? data.couponCode.value : this.couponCode,
      totalPrice:
          data.totalPrice.present ? data.totalPrice.value : this.totalPrice,
      userName: data.userName.present ? data.userName.value : this.userName,
      userAddress:
          data.userAddress.present ? data.userAddress.value : this.userAddress,
      userCity: data.userCity.present ? data.userCity.value : this.userCity,
      adminNote: data.adminNote.present ? data.adminNote.value : this.adminNote,
      pendingApproval: data.pendingApproval.present
          ? data.pendingApproval.value
          : this.pendingApproval,
      awaitingSchedule: data.awaitingSchedule.present
          ? data.awaitingSchedule.value
          : this.awaitingSchedule,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pendingSync:
          data.pendingSync.present ? data.pendingSync.value : this.pendingSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('driverId: $driverId, ')
          ..write('shiftId: $shiftId, ')
          ..write('shiftDate: $shiftDate, ')
          ..write('shiftLabel: $shiftLabel, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('couponCode: $couponCode, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('userName: $userName, ')
          ..write('userAddress: $userAddress, ')
          ..write('userCity: $userCity, ')
          ..write('adminNote: $adminNote, ')
          ..write('pendingApproval: $pendingApproval, ')
          ..write('awaitingSchedule: $awaitingSchedule, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      status,
      driverId,
      shiftId,
      shiftDate,
      shiftLabel,
      subtotal,
      discount,
      couponCode,
      totalPrice,
      userName,
      userAddress,
      userCity,
      adminNote,
      pendingApproval,
      awaitingSchedule,
      createdAt,
      updatedAt,
      pendingSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.status == this.status &&
          other.driverId == this.driverId &&
          other.shiftId == this.shiftId &&
          other.shiftDate == this.shiftDate &&
          other.shiftLabel == this.shiftLabel &&
          other.subtotal == this.subtotal &&
          other.discount == this.discount &&
          other.couponCode == this.couponCode &&
          other.totalPrice == this.totalPrice &&
          other.userName == this.userName &&
          other.userAddress == this.userAddress &&
          other.userCity == this.userCity &&
          other.adminNote == this.adminNote &&
          other.pendingApproval == this.pendingApproval &&
          other.awaitingSchedule == this.awaitingSchedule &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.pendingSync == this.pendingSync);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> status;
  final Value<String> driverId;
  final Value<String> shiftId;
  final Value<DateTime?> shiftDate;
  final Value<String> shiftLabel;
  final Value<double> subtotal;
  final Value<double> discount;
  final Value<String> couponCode;
  final Value<double> totalPrice;
  final Value<String> userName;
  final Value<String> userAddress;
  final Value<String> userCity;
  final Value<String> adminNote;
  final Value<bool> pendingApproval;
  final Value<bool> awaitingSchedule;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> pendingSync;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.driverId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.shiftDate = const Value.absent(),
    this.shiftLabel = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.couponCode = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.userName = const Value.absent(),
    this.userAddress = const Value.absent(),
    this.userCity = const Value.absent(),
    this.adminNote = const Value.absent(),
    this.pendingApproval = const Value.absent(),
    this.awaitingSchedule = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required String userId,
    required String status,
    this.driverId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.shiftDate = const Value.absent(),
    this.shiftLabel = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.couponCode = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.userName = const Value.absent(),
    this.userAddress = const Value.absent(),
    this.userCity = const Value.absent(),
    this.adminNote = const Value.absent(),
    this.pendingApproval = const Value.absent(),
    this.awaitingSchedule = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.pendingSync = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Order> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? status,
    Expression<String>? driverId,
    Expression<String>? shiftId,
    Expression<DateTime>? shiftDate,
    Expression<String>? shiftLabel,
    Expression<double>? subtotal,
    Expression<double>? discount,
    Expression<String>? couponCode,
    Expression<double>? totalPrice,
    Expression<String>? userName,
    Expression<String>? userAddress,
    Expression<String>? userCity,
    Expression<String>? adminNote,
    Expression<bool>? pendingApproval,
    Expression<bool>? awaitingSchedule,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? pendingSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (driverId != null) 'driver_id': driverId,
      if (shiftId != null) 'shift_id': shiftId,
      if (shiftDate != null) 'shift_date': shiftDate,
      if (shiftLabel != null) 'shift_label': shiftLabel,
      if (subtotal != null) 'subtotal': subtotal,
      if (discount != null) 'discount': discount,
      if (couponCode != null) 'coupon_code': couponCode,
      if (totalPrice != null) 'total_price': totalPrice,
      if (userName != null) 'user_name': userName,
      if (userAddress != null) 'user_address': userAddress,
      if (userCity != null) 'user_city': userCity,
      if (adminNote != null) 'admin_note': adminNote,
      if (pendingApproval != null) 'pending_approval': pendingApproval,
      if (awaitingSchedule != null) 'awaiting_schedule': awaitingSchedule,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? status,
      Value<String>? driverId,
      Value<String>? shiftId,
      Value<DateTime?>? shiftDate,
      Value<String>? shiftLabel,
      Value<double>? subtotal,
      Value<double>? discount,
      Value<String>? couponCode,
      Value<double>? totalPrice,
      Value<String>? userName,
      Value<String>? userAddress,
      Value<String>? userCity,
      Value<String>? adminNote,
      Value<bool>? pendingApproval,
      Value<bool>? awaitingSchedule,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? pendingSync,
      Value<int>? rowid}) {
    return OrdersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      shiftId: shiftId ?? this.shiftId,
      shiftDate: shiftDate ?? this.shiftDate,
      shiftLabel: shiftLabel ?? this.shiftLabel,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      couponCode: couponCode ?? this.couponCode,
      totalPrice: totalPrice ?? this.totalPrice,
      userName: userName ?? this.userName,
      userAddress: userAddress ?? this.userAddress,
      userCity: userCity ?? this.userCity,
      adminNote: adminNote ?? this.adminNote,
      pendingApproval: pendingApproval ?? this.pendingApproval,
      awaitingSchedule: awaitingSchedule ?? this.awaitingSchedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pendingSync: pendingSync ?? this.pendingSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (driverId.present) {
      map['driver_id'] = Variable<String>(driverId.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (shiftDate.present) {
      map['shift_date'] = Variable<DateTime>(shiftDate.value);
    }
    if (shiftLabel.present) {
      map['shift_label'] = Variable<String>(shiftLabel.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (couponCode.present) {
      map['coupon_code'] = Variable<String>(couponCode.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (userAddress.present) {
      map['user_address'] = Variable<String>(userAddress.value);
    }
    if (userCity.present) {
      map['user_city'] = Variable<String>(userCity.value);
    }
    if (adminNote.present) {
      map['admin_note'] = Variable<String>(adminNote.value);
    }
    if (pendingApproval.present) {
      map['pending_approval'] = Variable<bool>(pendingApproval.value);
    }
    if (awaitingSchedule.present) {
      map['awaiting_schedule'] = Variable<bool>(awaitingSchedule.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('driverId: $driverId, ')
          ..write('shiftId: $shiftId, ')
          ..write('shiftDate: $shiftDate, ')
          ..write('shiftLabel: $shiftLabel, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('couponCode: $couponCode, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('userName: $userName, ')
          ..write('userAddress: $userAddress, ')
          ..write('userCity: $userCity, ')
          ..write('adminNote: $adminNote, ')
          ..write('pendingApproval: $pendingApproval, ')
          ..write('awaitingSchedule: $awaitingSchedule, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemRowsTable extends OrderItemRows
    with TableInfo<$OrderItemRowsTable, OrderItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
      'order_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
      'qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, productId, name, qty, unitPrice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_item_rows';
  @override
  VerificationContext validateIntegrity(Insertable<OrderItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('qty')) {
      context.handle(
          _qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      qty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
    );
  }

  @override
  $OrderItemRowsTable createAlias(String alias) {
    return $OrderItemRowsTable(attachedDatabase, alias);
  }
}

class OrderItemRow extends DataClass implements Insertable<OrderItemRow> {
  final String id;
  final String orderId;
  final String productId;
  final String name;
  final int qty;
  final double unitPrice;
  const OrderItemRow(
      {required this.id,
      required this.orderId,
      required this.productId,
      required this.name,
      required this.qty,
      required this.unitPrice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    map['product_id'] = Variable<String>(productId);
    map['name'] = Variable<String>(name);
    map['qty'] = Variable<int>(qty);
    map['unit_price'] = Variable<double>(unitPrice);
    return map;
  }

  OrderItemRowsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemRowsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: Value(productId),
      name: Value(name),
      qty: Value(qty),
      unitPrice: Value(unitPrice),
    );
  }

  factory OrderItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItemRow(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      productId: serializer.fromJson<String>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      qty: serializer.fromJson<int>(json['qty']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'productId': serializer.toJson<String>(productId),
      'name': serializer.toJson<String>(name),
      'qty': serializer.toJson<int>(qty),
      'unitPrice': serializer.toJson<double>(unitPrice),
    };
  }

  OrderItemRow copyWith(
          {String? id,
          String? orderId,
          String? productId,
          String? name,
          int? qty,
          double? unitPrice}) =>
      OrderItemRow(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        productId: productId ?? this.productId,
        name: name ?? this.name,
        qty: qty ?? this.qty,
        unitPrice: unitPrice ?? this.unitPrice,
      );
  OrderItemRow copyWithCompanion(OrderItemRowsCompanion data) {
    return OrderItemRow(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      qty: data.qty.present ? data.qty.value : this.qty,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemRow(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('unitPrice: $unitPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, productId, name, qty, unitPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItemRow &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.qty == this.qty &&
          other.unitPrice == this.unitPrice);
}

class OrderItemRowsCompanion extends UpdateCompanion<OrderItemRow> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String> productId;
  final Value<String> name;
  final Value<int> qty;
  final Value<double> unitPrice;
  final Value<int> rowid;
  const OrderItemRowsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.qty = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderItemRowsCompanion.insert({
    required String id,
    required String orderId,
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    required int qty,
    required double unitPrice,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        orderId = Value(orderId),
        qty = Value(qty),
        unitPrice = Value(unitPrice);
  static Insertable<OrderItemRow> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? productId,
    Expression<String>? name,
    Expression<int>? qty,
    Expression<double>? unitPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (qty != null) 'qty': qty,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderItemRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? orderId,
      Value<String>? productId,
      Value<String>? name,
      Value<int>? qty,
      Value<double>? unitPrice,
      Value<int>? rowid}) {
    return OrderItemRowsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemRowsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatTopicsTable extends ChatTopics
    with TableInfo<$ChatTopicsTable, ChatTopic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userNameMeta =
      const VerificationMeta('userName');
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
      'user_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lastMessageMeta =
      const VerificationMeta('lastMessage');
  @override
  late final GeneratedColumn<String> lastMessage = GeneratedColumn<String>(
      'last_message', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _lastAtMeta = const VerificationMeta('lastAt');
  @override
  late final GeneratedColumn<DateTime> lastAt = GeneratedColumn<DateTime>(
      'last_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastFromAdminMeta =
      const VerificationMeta('lastFromAdmin');
  @override
  late final GeneratedColumn<bool> lastFromAdmin = GeneratedColumn<bool>(
      'last_from_admin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("last_from_admin" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _customerUnreadMeta =
      const VerificationMeta('customerUnread');
  @override
  late final GeneratedColumn<int> customerUnread = GeneratedColumn<int>(
      'customer_unread', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userName, lastMessage, lastAt, lastFromAdmin, customerUnread];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_topics';
  @override
  VerificationContext validateIntegrity(Insertable<ChatTopic> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(_userNameMeta,
          userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta));
    }
    if (data.containsKey('last_message')) {
      context.handle(
          _lastMessageMeta,
          lastMessage.isAcceptableOrUnknown(
              data['last_message']!, _lastMessageMeta));
    }
    if (data.containsKey('last_at')) {
      context.handle(_lastAtMeta,
          lastAt.isAcceptableOrUnknown(data['last_at']!, _lastAtMeta));
    }
    if (data.containsKey('last_from_admin')) {
      context.handle(
          _lastFromAdminMeta,
          lastFromAdmin.isAcceptableOrUnknown(
              data['last_from_admin']!, _lastFromAdminMeta));
    }
    if (data.containsKey('customer_unread')) {
      context.handle(
          _customerUnreadMeta,
          customerUnread.isAcceptableOrUnknown(
              data['customer_unread']!, _customerUnreadMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatTopic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatTopic(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_name'])!,
      lastMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_message'])!,
      lastAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_at']),
      lastFromAdmin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}last_from_admin'])!,
      customerUnread: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_unread'])!,
    );
  }

  @override
  $ChatTopicsTable createAlias(String alias) {
    return $ChatTopicsTable(attachedDatabase, alias);
  }
}

class ChatTopic extends DataClass implements Insertable<ChatTopic> {
  final String id;
  final String userName;
  final String lastMessage;
  final DateTime? lastAt;
  final bool lastFromAdmin;
  final int customerUnread;
  const ChatTopic(
      {required this.id,
      required this.userName,
      required this.lastMessage,
      this.lastAt,
      required this.lastFromAdmin,
      required this.customerUnread});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_name'] = Variable<String>(userName);
    map['last_message'] = Variable<String>(lastMessage);
    if (!nullToAbsent || lastAt != null) {
      map['last_at'] = Variable<DateTime>(lastAt);
    }
    map['last_from_admin'] = Variable<bool>(lastFromAdmin);
    map['customer_unread'] = Variable<int>(customerUnread);
    return map;
  }

  ChatTopicsCompanion toCompanion(bool nullToAbsent) {
    return ChatTopicsCompanion(
      id: Value(id),
      userName: Value(userName),
      lastMessage: Value(lastMessage),
      lastAt:
          lastAt == null && nullToAbsent ? const Value.absent() : Value(lastAt),
      lastFromAdmin: Value(lastFromAdmin),
      customerUnread: Value(customerUnread),
    );
  }

  factory ChatTopic.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatTopic(
      id: serializer.fromJson<String>(json['id']),
      userName: serializer.fromJson<String>(json['userName']),
      lastMessage: serializer.fromJson<String>(json['lastMessage']),
      lastAt: serializer.fromJson<DateTime?>(json['lastAt']),
      lastFromAdmin: serializer.fromJson<bool>(json['lastFromAdmin']),
      customerUnread: serializer.fromJson<int>(json['customerUnread']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userName': serializer.toJson<String>(userName),
      'lastMessage': serializer.toJson<String>(lastMessage),
      'lastAt': serializer.toJson<DateTime?>(lastAt),
      'lastFromAdmin': serializer.toJson<bool>(lastFromAdmin),
      'customerUnread': serializer.toJson<int>(customerUnread),
    };
  }

  ChatTopic copyWith(
          {String? id,
          String? userName,
          String? lastMessage,
          Value<DateTime?> lastAt = const Value.absent(),
          bool? lastFromAdmin,
          int? customerUnread}) =>
      ChatTopic(
        id: id ?? this.id,
        userName: userName ?? this.userName,
        lastMessage: lastMessage ?? this.lastMessage,
        lastAt: lastAt.present ? lastAt.value : this.lastAt,
        lastFromAdmin: lastFromAdmin ?? this.lastFromAdmin,
        customerUnread: customerUnread ?? this.customerUnread,
      );
  ChatTopic copyWithCompanion(ChatTopicsCompanion data) {
    return ChatTopic(
      id: data.id.present ? data.id.value : this.id,
      userName: data.userName.present ? data.userName.value : this.userName,
      lastMessage:
          data.lastMessage.present ? data.lastMessage.value : this.lastMessage,
      lastAt: data.lastAt.present ? data.lastAt.value : this.lastAt,
      lastFromAdmin: data.lastFromAdmin.present
          ? data.lastFromAdmin.value
          : this.lastFromAdmin,
      customerUnread: data.customerUnread.present
          ? data.customerUnread.value
          : this.customerUnread,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatTopic(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastAt: $lastAt, ')
          ..write('lastFromAdmin: $lastFromAdmin, ')
          ..write('customerUnread: $customerUnread')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userName, lastMessage, lastAt, lastFromAdmin, customerUnread);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatTopic &&
          other.id == this.id &&
          other.userName == this.userName &&
          other.lastMessage == this.lastMessage &&
          other.lastAt == this.lastAt &&
          other.lastFromAdmin == this.lastFromAdmin &&
          other.customerUnread == this.customerUnread);
}

class ChatTopicsCompanion extends UpdateCompanion<ChatTopic> {
  final Value<String> id;
  final Value<String> userName;
  final Value<String> lastMessage;
  final Value<DateTime?> lastAt;
  final Value<bool> lastFromAdmin;
  final Value<int> customerUnread;
  final Value<int> rowid;
  const ChatTopicsCompanion({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.lastFromAdmin = const Value.absent(),
    this.customerUnread = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatTopicsCompanion.insert({
    required String id,
    this.userName = const Value.absent(),
    this.lastMessage = const Value.absent(),
    this.lastAt = const Value.absent(),
    this.lastFromAdmin = const Value.absent(),
    this.customerUnread = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ChatTopic> custom({
    Expression<String>? id,
    Expression<String>? userName,
    Expression<String>? lastMessage,
    Expression<DateTime>? lastAt,
    Expression<bool>? lastFromAdmin,
    Expression<int>? customerUnread,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userName != null) 'user_name': userName,
      if (lastMessage != null) 'last_message': lastMessage,
      if (lastAt != null) 'last_at': lastAt,
      if (lastFromAdmin != null) 'last_from_admin': lastFromAdmin,
      if (customerUnread != null) 'customer_unread': customerUnread,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatTopicsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userName,
      Value<String>? lastMessage,
      Value<DateTime?>? lastAt,
      Value<bool>? lastFromAdmin,
      Value<int>? customerUnread,
      Value<int>? rowid}) {
    return ChatTopicsCompanion(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastAt: lastAt ?? this.lastAt,
      lastFromAdmin: lastFromAdmin ?? this.lastFromAdmin,
      customerUnread: customerUnread ?? this.customerUnread,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (lastMessage.present) {
      map['last_message'] = Variable<String>(lastMessage.value);
    }
    if (lastAt.present) {
      map['last_at'] = Variable<DateTime>(lastAt.value);
    }
    if (lastFromAdmin.present) {
      map['last_from_admin'] = Variable<bool>(lastFromAdmin.value);
    }
    if (customerUnread.present) {
      map['customer_unread'] = Variable<int>(customerUnread.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatTopicsCompanion(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('lastMessage: $lastMessage, ')
          ..write('lastAt: $lastAt, ')
          ..write('lastFromAdmin: $lastFromAdmin, ')
          ..write('customerUnread: $customerUnread, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderNameMeta =
      const VerificationMeta('senderName');
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
      'sender_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFromAdminMeta =
      const VerificationMeta('isFromAdmin');
  @override
  late final GeneratedColumn<bool> isFromAdmin = GeneratedColumn<bool>(
      'is_from_admin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_from_admin" IN (0, 1))'));
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textContentMeta =
      const VerificationMeta('textContent');
  @override
  late final GeneratedColumn<String> textContent = GeneratedColumn<String>(
      'text_content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deletedMeta =
      const VerificationMeta('deleted');
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
      'deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _replyToIdMeta =
      const VerificationMeta('replyToId');
  @override
  late final GeneratedColumn<String> replyToId = GeneratedColumn<String>(
      'reply_to_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _replyToTextMeta =
      const VerificationMeta('replyToText');
  @override
  late final GeneratedColumn<String> replyToText = GeneratedColumn<String>(
      'reply_to_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _replyToSenderMeta =
      const VerificationMeta('replyToSender');
  @override
  late final GeneratedColumn<String> replyToSender = GeneratedColumn<String>(
      'reply_to_sender', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _mediaUrlMeta =
      const VerificationMeta('mediaUrl');
  @override
  late final GeneratedColumn<String> mediaUrl = GeneratedColumn<String>(
      'media_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mediaUrlsJsonMeta =
      const VerificationMeta('mediaUrlsJson');
  @override
  late final GeneratedColumn<String> mediaUrlsJson = GeneratedColumn<String>(
      'media_urls_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
      'order_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _waveformJsonMeta =
      const VerificationMeta('waveformJson');
  @override
  late final GeneratedColumn<String> waveformJson = GeneratedColumn<String>(
      'waveform_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _uploadingMeta =
      const VerificationMeta('uploading');
  @override
  late final GeneratedColumn<bool> uploading = GeneratedColumn<bool>(
      'uploading', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("uploading" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _uploadCountMeta =
      const VerificationMeta('uploadCount');
  @override
  late final GeneratedColumn<int> uploadCount = GeneratedColumn<int>(
      'upload_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reactionsJsonMeta =
      const VerificationMeta('reactionsJson');
  @override
  late final GeneratedColumn<String> reactionsJson = GeneratedColumn<String>(
      'reactions_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _localMediaPathMeta =
      const VerificationMeta('localMediaPath');
  @override
  late final GeneratedColumn<String> localMediaPath = GeneratedColumn<String>(
      'local_media_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _pendingSyncMeta =
      const VerificationMeta('pendingSync');
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
      'pending_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pending_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sendFailedMeta =
      const VerificationMeta('sendFailed');
  @override
  late final GeneratedColumn<bool> sendFailed = GeneratedColumn<bool>(
      'send_failed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("send_failed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        topicId,
        senderId,
        senderName,
        isFromAdmin,
        isRead,
        type,
        textContent,
        deleted,
        replyToId,
        replyToText,
        replyToSender,
        mediaUrl,
        mediaUrlsJson,
        durationMs,
        orderId,
        waveformJson,
        sizeBytes,
        uploading,
        uploadCount,
        reactionsJson,
        createdAt,
        updatedAt,
        localMediaPath,
        pendingSync,
        sendFailed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
          _senderNameMeta,
          senderName.isAcceptableOrUnknown(
              data['sender_name']!, _senderNameMeta));
    } else if (isInserting) {
      context.missing(_senderNameMeta);
    }
    if (data.containsKey('is_from_admin')) {
      context.handle(
          _isFromAdminMeta,
          isFromAdmin.isAcceptableOrUnknown(
              data['is_from_admin']!, _isFromAdminMeta));
    } else if (isInserting) {
      context.missing(_isFromAdminMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('text_content')) {
      context.handle(
          _textContentMeta,
          textContent.isAcceptableOrUnknown(
              data['text_content']!, _textContentMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta,
          deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('reply_to_id')) {
      context.handle(
          _replyToIdMeta,
          replyToId.isAcceptableOrUnknown(
              data['reply_to_id']!, _replyToIdMeta));
    }
    if (data.containsKey('reply_to_text')) {
      context.handle(
          _replyToTextMeta,
          replyToText.isAcceptableOrUnknown(
              data['reply_to_text']!, _replyToTextMeta));
    }
    if (data.containsKey('reply_to_sender')) {
      context.handle(
          _replyToSenderMeta,
          replyToSender.isAcceptableOrUnknown(
              data['reply_to_sender']!, _replyToSenderMeta));
    }
    if (data.containsKey('media_url')) {
      context.handle(_mediaUrlMeta,
          mediaUrl.isAcceptableOrUnknown(data['media_url']!, _mediaUrlMeta));
    }
    if (data.containsKey('media_urls_json')) {
      context.handle(
          _mediaUrlsJsonMeta,
          mediaUrlsJson.isAcceptableOrUnknown(
              data['media_urls_json']!, _mediaUrlsJsonMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    }
    if (data.containsKey('waveform_json')) {
      context.handle(
          _waveformJsonMeta,
          waveformJson.isAcceptableOrUnknown(
              data['waveform_json']!, _waveformJsonMeta));
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    }
    if (data.containsKey('uploading')) {
      context.handle(_uploadingMeta,
          uploading.isAcceptableOrUnknown(data['uploading']!, _uploadingMeta));
    }
    if (data.containsKey('upload_count')) {
      context.handle(
          _uploadCountMeta,
          uploadCount.isAcceptableOrUnknown(
              data['upload_count']!, _uploadCountMeta));
    }
    if (data.containsKey('reactions_json')) {
      context.handle(
          _reactionsJsonMeta,
          reactionsJson.isAcceptableOrUnknown(
              data['reactions_json']!, _reactionsJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('local_media_path')) {
      context.handle(
          _localMediaPathMeta,
          localMediaPath.isAcceptableOrUnknown(
              data['local_media_path']!, _localMediaPathMeta));
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
          _pendingSyncMeta,
          pendingSync.isAcceptableOrUnknown(
              data['pending_sync']!, _pendingSyncMeta));
    }
    if (data.containsKey('send_failed')) {
      context.handle(
          _sendFailedMeta,
          sendFailed.isAcceptableOrUnknown(
              data['send_failed']!, _sendFailedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      senderName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_name'])!,
      isFromAdmin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_from_admin'])!,
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      textContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_content']),
      deleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted'])!,
      replyToId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_to_id'])!,
      replyToText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reply_to_text'])!,
      replyToSender: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reply_to_sender'])!,
      mediaUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_url']),
      mediaUrlsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_urls_json']),
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_id'])!,
      waveformJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}waveform_json']),
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      uploading: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}uploading'])!,
      uploadCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}upload_count'])!,
      reactionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reactions_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      localMediaPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_media_path'])!,
      pendingSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending_sync'])!,
      sendFailed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}send_failed'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String topicId;
  final String senderId;
  final String senderName;
  final bool isFromAdmin;
  final bool isRead;
  final String type;
  final String? textContent;
  final bool deleted;
  final String replyToId;
  final String replyToText;
  final String replyToSender;
  final String? mediaUrl;
  final String? mediaUrlsJson;
  final int durationMs;
  final String orderId;
  final String? waveformJson;
  final int sizeBytes;
  final bool uploading;
  final int uploadCount;
  final String? reactionsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String localMediaPath;
  final bool pendingSync;
  final bool sendFailed;
  const Message(
      {required this.id,
      required this.topicId,
      required this.senderId,
      required this.senderName,
      required this.isFromAdmin,
      required this.isRead,
      required this.type,
      this.textContent,
      required this.deleted,
      required this.replyToId,
      required this.replyToText,
      required this.replyToSender,
      this.mediaUrl,
      this.mediaUrlsJson,
      required this.durationMs,
      required this.orderId,
      this.waveformJson,
      required this.sizeBytes,
      required this.uploading,
      required this.uploadCount,
      this.reactionsJson,
      required this.createdAt,
      required this.updatedAt,
      required this.localMediaPath,
      required this.pendingSync,
      required this.sendFailed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['topic_id'] = Variable<String>(topicId);
    map['sender_id'] = Variable<String>(senderId);
    map['sender_name'] = Variable<String>(senderName);
    map['is_from_admin'] = Variable<bool>(isFromAdmin);
    map['is_read'] = Variable<bool>(isRead);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || textContent != null) {
      map['text_content'] = Variable<String>(textContent);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['reply_to_id'] = Variable<String>(replyToId);
    map['reply_to_text'] = Variable<String>(replyToText);
    map['reply_to_sender'] = Variable<String>(replyToSender);
    if (!nullToAbsent || mediaUrl != null) {
      map['media_url'] = Variable<String>(mediaUrl);
    }
    if (!nullToAbsent || mediaUrlsJson != null) {
      map['media_urls_json'] = Variable<String>(mediaUrlsJson);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['order_id'] = Variable<String>(orderId);
    if (!nullToAbsent || waveformJson != null) {
      map['waveform_json'] = Variable<String>(waveformJson);
    }
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['uploading'] = Variable<bool>(uploading);
    map['upload_count'] = Variable<int>(uploadCount);
    if (!nullToAbsent || reactionsJson != null) {
      map['reactions_json'] = Variable<String>(reactionsJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['local_media_path'] = Variable<String>(localMediaPath);
    map['pending_sync'] = Variable<bool>(pendingSync);
    map['send_failed'] = Variable<bool>(sendFailed);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      topicId: Value(topicId),
      senderId: Value(senderId),
      senderName: Value(senderName),
      isFromAdmin: Value(isFromAdmin),
      isRead: Value(isRead),
      type: Value(type),
      textContent: textContent == null && nullToAbsent
          ? const Value.absent()
          : Value(textContent),
      deleted: Value(deleted),
      replyToId: Value(replyToId),
      replyToText: Value(replyToText),
      replyToSender: Value(replyToSender),
      mediaUrl: mediaUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaUrl),
      mediaUrlsJson: mediaUrlsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaUrlsJson),
      durationMs: Value(durationMs),
      orderId: Value(orderId),
      waveformJson: waveformJson == null && nullToAbsent
          ? const Value.absent()
          : Value(waveformJson),
      sizeBytes: Value(sizeBytes),
      uploading: Value(uploading),
      uploadCount: Value(uploadCount),
      reactionsJson: reactionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(reactionsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      localMediaPath: Value(localMediaPath),
      pendingSync: Value(pendingSync),
      sendFailed: Value(sendFailed),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String>(json['topicId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderName: serializer.fromJson<String>(json['senderName']),
      isFromAdmin: serializer.fromJson<bool>(json['isFromAdmin']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      type: serializer.fromJson<String>(json['type']),
      textContent: serializer.fromJson<String?>(json['textContent']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      replyToId: serializer.fromJson<String>(json['replyToId']),
      replyToText: serializer.fromJson<String>(json['replyToText']),
      replyToSender: serializer.fromJson<String>(json['replyToSender']),
      mediaUrl: serializer.fromJson<String?>(json['mediaUrl']),
      mediaUrlsJson: serializer.fromJson<String?>(json['mediaUrlsJson']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      orderId: serializer.fromJson<String>(json['orderId']),
      waveformJson: serializer.fromJson<String?>(json['waveformJson']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      uploading: serializer.fromJson<bool>(json['uploading']),
      uploadCount: serializer.fromJson<int>(json['uploadCount']),
      reactionsJson: serializer.fromJson<String?>(json['reactionsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      localMediaPath: serializer.fromJson<String>(json['localMediaPath']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      sendFailed: serializer.fromJson<bool>(json['sendFailed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topicId': serializer.toJson<String>(topicId),
      'senderId': serializer.toJson<String>(senderId),
      'senderName': serializer.toJson<String>(senderName),
      'isFromAdmin': serializer.toJson<bool>(isFromAdmin),
      'isRead': serializer.toJson<bool>(isRead),
      'type': serializer.toJson<String>(type),
      'textContent': serializer.toJson<String?>(textContent),
      'deleted': serializer.toJson<bool>(deleted),
      'replyToId': serializer.toJson<String>(replyToId),
      'replyToText': serializer.toJson<String>(replyToText),
      'replyToSender': serializer.toJson<String>(replyToSender),
      'mediaUrl': serializer.toJson<String?>(mediaUrl),
      'mediaUrlsJson': serializer.toJson<String?>(mediaUrlsJson),
      'durationMs': serializer.toJson<int>(durationMs),
      'orderId': serializer.toJson<String>(orderId),
      'waveformJson': serializer.toJson<String?>(waveformJson),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'uploading': serializer.toJson<bool>(uploading),
      'uploadCount': serializer.toJson<int>(uploadCount),
      'reactionsJson': serializer.toJson<String?>(reactionsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'localMediaPath': serializer.toJson<String>(localMediaPath),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'sendFailed': serializer.toJson<bool>(sendFailed),
    };
  }

  Message copyWith(
          {String? id,
          String? topicId,
          String? senderId,
          String? senderName,
          bool? isFromAdmin,
          bool? isRead,
          String? type,
          Value<String?> textContent = const Value.absent(),
          bool? deleted,
          String? replyToId,
          String? replyToText,
          String? replyToSender,
          Value<String?> mediaUrl = const Value.absent(),
          Value<String?> mediaUrlsJson = const Value.absent(),
          int? durationMs,
          String? orderId,
          Value<String?> waveformJson = const Value.absent(),
          int? sizeBytes,
          bool? uploading,
          int? uploadCount,
          Value<String?> reactionsJson = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? localMediaPath,
          bool? pendingSync,
          bool? sendFailed}) =>
      Message(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        isFromAdmin: isFromAdmin ?? this.isFromAdmin,
        isRead: isRead ?? this.isRead,
        type: type ?? this.type,
        textContent: textContent.present ? textContent.value : this.textContent,
        deleted: deleted ?? this.deleted,
        replyToId: replyToId ?? this.replyToId,
        replyToText: replyToText ?? this.replyToText,
        replyToSender: replyToSender ?? this.replyToSender,
        mediaUrl: mediaUrl.present ? mediaUrl.value : this.mediaUrl,
        mediaUrlsJson:
            mediaUrlsJson.present ? mediaUrlsJson.value : this.mediaUrlsJson,
        durationMs: durationMs ?? this.durationMs,
        orderId: orderId ?? this.orderId,
        waveformJson:
            waveformJson.present ? waveformJson.value : this.waveformJson,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        uploading: uploading ?? this.uploading,
        uploadCount: uploadCount ?? this.uploadCount,
        reactionsJson:
            reactionsJson.present ? reactionsJson.value : this.reactionsJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        localMediaPath: localMediaPath ?? this.localMediaPath,
        pendingSync: pendingSync ?? this.pendingSync,
        sendFailed: sendFailed ?? this.sendFailed,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderName:
          data.senderName.present ? data.senderName.value : this.senderName,
      isFromAdmin:
          data.isFromAdmin.present ? data.isFromAdmin.value : this.isFromAdmin,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      type: data.type.present ? data.type.value : this.type,
      textContent:
          data.textContent.present ? data.textContent.value : this.textContent,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      replyToId: data.replyToId.present ? data.replyToId.value : this.replyToId,
      replyToText:
          data.replyToText.present ? data.replyToText.value : this.replyToText,
      replyToSender: data.replyToSender.present
          ? data.replyToSender.value
          : this.replyToSender,
      mediaUrl: data.mediaUrl.present ? data.mediaUrl.value : this.mediaUrl,
      mediaUrlsJson: data.mediaUrlsJson.present
          ? data.mediaUrlsJson.value
          : this.mediaUrlsJson,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      waveformJson: data.waveformJson.present
          ? data.waveformJson.value
          : this.waveformJson,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      uploading: data.uploading.present ? data.uploading.value : this.uploading,
      uploadCount:
          data.uploadCount.present ? data.uploadCount.value : this.uploadCount,
      reactionsJson: data.reactionsJson.present
          ? data.reactionsJson.value
          : this.reactionsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      localMediaPath: data.localMediaPath.present
          ? data.localMediaPath.value
          : this.localMediaPath,
      pendingSync:
          data.pendingSync.present ? data.pendingSync.value : this.pendingSync,
      sendFailed:
          data.sendFailed.present ? data.sendFailed.value : this.sendFailed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('isFromAdmin: $isFromAdmin, ')
          ..write('isRead: $isRead, ')
          ..write('type: $type, ')
          ..write('textContent: $textContent, ')
          ..write('deleted: $deleted, ')
          ..write('replyToId: $replyToId, ')
          ..write('replyToText: $replyToText, ')
          ..write('replyToSender: $replyToSender, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('mediaUrlsJson: $mediaUrlsJson, ')
          ..write('durationMs: $durationMs, ')
          ..write('orderId: $orderId, ')
          ..write('waveformJson: $waveformJson, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('uploading: $uploading, ')
          ..write('uploadCount: $uploadCount, ')
          ..write('reactionsJson: $reactionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('localMediaPath: $localMediaPath, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('sendFailed: $sendFailed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        topicId,
        senderId,
        senderName,
        isFromAdmin,
        isRead,
        type,
        textContent,
        deleted,
        replyToId,
        replyToText,
        replyToSender,
        mediaUrl,
        mediaUrlsJson,
        durationMs,
        orderId,
        waveformJson,
        sizeBytes,
        uploading,
        uploadCount,
        reactionsJson,
        createdAt,
        updatedAt,
        localMediaPath,
        pendingSync,
        sendFailed
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.senderId == this.senderId &&
          other.senderName == this.senderName &&
          other.isFromAdmin == this.isFromAdmin &&
          other.isRead == this.isRead &&
          other.type == this.type &&
          other.textContent == this.textContent &&
          other.deleted == this.deleted &&
          other.replyToId == this.replyToId &&
          other.replyToText == this.replyToText &&
          other.replyToSender == this.replyToSender &&
          other.mediaUrl == this.mediaUrl &&
          other.mediaUrlsJson == this.mediaUrlsJson &&
          other.durationMs == this.durationMs &&
          other.orderId == this.orderId &&
          other.waveformJson == this.waveformJson &&
          other.sizeBytes == this.sizeBytes &&
          other.uploading == this.uploading &&
          other.uploadCount == this.uploadCount &&
          other.reactionsJson == this.reactionsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.localMediaPath == this.localMediaPath &&
          other.pendingSync == this.pendingSync &&
          other.sendFailed == this.sendFailed);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> topicId;
  final Value<String> senderId;
  final Value<String> senderName;
  final Value<bool> isFromAdmin;
  final Value<bool> isRead;
  final Value<String> type;
  final Value<String?> textContent;
  final Value<bool> deleted;
  final Value<String> replyToId;
  final Value<String> replyToText;
  final Value<String> replyToSender;
  final Value<String?> mediaUrl;
  final Value<String?> mediaUrlsJson;
  final Value<int> durationMs;
  final Value<String> orderId;
  final Value<String?> waveformJson;
  final Value<int> sizeBytes;
  final Value<bool> uploading;
  final Value<int> uploadCount;
  final Value<String?> reactionsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> localMediaPath;
  final Value<bool> pendingSync;
  final Value<bool> sendFailed;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderName = const Value.absent(),
    this.isFromAdmin = const Value.absent(),
    this.isRead = const Value.absent(),
    this.type = const Value.absent(),
    this.textContent = const Value.absent(),
    this.deleted = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.replyToText = const Value.absent(),
    this.replyToSender = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.mediaUrlsJson = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.orderId = const Value.absent(),
    this.waveformJson = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.uploading = const Value.absent(),
    this.uploadCount = const Value.absent(),
    this.reactionsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.localMediaPath = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.sendFailed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String topicId,
    required String senderId,
    required String senderName,
    required bool isFromAdmin,
    this.isRead = const Value.absent(),
    required String type,
    this.textContent = const Value.absent(),
    this.deleted = const Value.absent(),
    this.replyToId = const Value.absent(),
    this.replyToText = const Value.absent(),
    this.replyToSender = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.mediaUrlsJson = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.orderId = const Value.absent(),
    this.waveformJson = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.uploading = const Value.absent(),
    this.uploadCount = const Value.absent(),
    this.reactionsJson = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.localMediaPath = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.sendFailed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        topicId = Value(topicId),
        senderId = Value(senderId),
        senderName = Value(senderName),
        isFromAdmin = Value(isFromAdmin),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<String>? senderId,
    Expression<String>? senderName,
    Expression<bool>? isFromAdmin,
    Expression<bool>? isRead,
    Expression<String>? type,
    Expression<String>? textContent,
    Expression<bool>? deleted,
    Expression<String>? replyToId,
    Expression<String>? replyToText,
    Expression<String>? replyToSender,
    Expression<String>? mediaUrl,
    Expression<String>? mediaUrlsJson,
    Expression<int>? durationMs,
    Expression<String>? orderId,
    Expression<String>? waveformJson,
    Expression<int>? sizeBytes,
    Expression<bool>? uploading,
    Expression<int>? uploadCount,
    Expression<String>? reactionsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? localMediaPath,
    Expression<bool>? pendingSync,
    Expression<bool>? sendFailed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (senderId != null) 'sender_id': senderId,
      if (senderName != null) 'sender_name': senderName,
      if (isFromAdmin != null) 'is_from_admin': isFromAdmin,
      if (isRead != null) 'is_read': isRead,
      if (type != null) 'type': type,
      if (textContent != null) 'text_content': textContent,
      if (deleted != null) 'deleted': deleted,
      if (replyToId != null) 'reply_to_id': replyToId,
      if (replyToText != null) 'reply_to_text': replyToText,
      if (replyToSender != null) 'reply_to_sender': replyToSender,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (mediaUrlsJson != null) 'media_urls_json': mediaUrlsJson,
      if (durationMs != null) 'duration_ms': durationMs,
      if (orderId != null) 'order_id': orderId,
      if (waveformJson != null) 'waveform_json': waveformJson,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (uploading != null) 'uploading': uploading,
      if (uploadCount != null) 'upload_count': uploadCount,
      if (reactionsJson != null) 'reactions_json': reactionsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (localMediaPath != null) 'local_media_path': localMediaPath,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (sendFailed != null) 'send_failed': sendFailed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? topicId,
      Value<String>? senderId,
      Value<String>? senderName,
      Value<bool>? isFromAdmin,
      Value<bool>? isRead,
      Value<String>? type,
      Value<String?>? textContent,
      Value<bool>? deleted,
      Value<String>? replyToId,
      Value<String>? replyToText,
      Value<String>? replyToSender,
      Value<String?>? mediaUrl,
      Value<String?>? mediaUrlsJson,
      Value<int>? durationMs,
      Value<String>? orderId,
      Value<String?>? waveformJson,
      Value<int>? sizeBytes,
      Value<bool>? uploading,
      Value<int>? uploadCount,
      Value<String?>? reactionsJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? localMediaPath,
      Value<bool>? pendingSync,
      Value<bool>? sendFailed,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      isFromAdmin: isFromAdmin ?? this.isFromAdmin,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      textContent: textContent ?? this.textContent,
      deleted: deleted ?? this.deleted,
      replyToId: replyToId ?? this.replyToId,
      replyToText: replyToText ?? this.replyToText,
      replyToSender: replyToSender ?? this.replyToSender,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaUrlsJson: mediaUrlsJson ?? this.mediaUrlsJson,
      durationMs: durationMs ?? this.durationMs,
      orderId: orderId ?? this.orderId,
      waveformJson: waveformJson ?? this.waveformJson,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      uploading: uploading ?? this.uploading,
      uploadCount: uploadCount ?? this.uploadCount,
      reactionsJson: reactionsJson ?? this.reactionsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localMediaPath: localMediaPath ?? this.localMediaPath,
      pendingSync: pendingSync ?? this.pendingSync,
      sendFailed: sendFailed ?? this.sendFailed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (isFromAdmin.present) {
      map['is_from_admin'] = Variable<bool>(isFromAdmin.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (textContent.present) {
      map['text_content'] = Variable<String>(textContent.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (replyToId.present) {
      map['reply_to_id'] = Variable<String>(replyToId.value);
    }
    if (replyToText.present) {
      map['reply_to_text'] = Variable<String>(replyToText.value);
    }
    if (replyToSender.present) {
      map['reply_to_sender'] = Variable<String>(replyToSender.value);
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (mediaUrlsJson.present) {
      map['media_urls_json'] = Variable<String>(mediaUrlsJson.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (waveformJson.present) {
      map['waveform_json'] = Variable<String>(waveformJson.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (uploading.present) {
      map['uploading'] = Variable<bool>(uploading.value);
    }
    if (uploadCount.present) {
      map['upload_count'] = Variable<int>(uploadCount.value);
    }
    if (reactionsJson.present) {
      map['reactions_json'] = Variable<String>(reactionsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (localMediaPath.present) {
      map['local_media_path'] = Variable<String>(localMediaPath.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (sendFailed.present) {
      map['send_failed'] = Variable<bool>(sendFailed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('isFromAdmin: $isFromAdmin, ')
          ..write('isRead: $isRead, ')
          ..write('type: $type, ')
          ..write('textContent: $textContent, ')
          ..write('deleted: $deleted, ')
          ..write('replyToId: $replyToId, ')
          ..write('replyToText: $replyToText, ')
          ..write('replyToSender: $replyToSender, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('mediaUrlsJson: $mediaUrlsJson, ')
          ..write('durationMs: $durationMs, ')
          ..write('orderId: $orderId, ')
          ..write('waveformJson: $waveformJson, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('uploading: $uploading, ')
          ..write('uploadCount: $uploadCount, ')
          ..write('reactionsJson: $reactionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('localMediaPath: $localMediaPath, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('sendFailed: $sendFailed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationRowsTable extends NotificationRows
    with TableInfo<$NotificationRowsTable, NotificationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('system'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dataJsonMeta =
      const VerificationMeta('dataJson');
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
      'data_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
      'order_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
      'read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, title, body, dataJson, orderId, topicId, read, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_rows';
  @override
  VerificationContext validateIntegrity(Insertable<NotificationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('data_json')) {
      context.handle(_dataJsonMeta,
          dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    }
    if (data.containsKey('read')) {
      context.handle(
          _readMeta, read.isAcceptableOrUnknown(data['read']!, _readMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      dataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_json'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id'])!,
      read: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}read'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NotificationRowsTable createAlias(String alias) {
    return $NotificationRowsTable(attachedDatabase, alias);
  }
}

class NotificationRow extends DataClass implements Insertable<NotificationRow> {
  final String id;
  final String type;
  final String title;
  final String body;
  final String dataJson;
  final String orderId;
  final String topicId;
  final bool read;
  final DateTime createdAt;
  const NotificationRow(
      {required this.id,
      required this.type,
      required this.title,
      required this.body,
      required this.dataJson,
      required this.orderId,
      required this.topicId,
      required this.read,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['data_json'] = Variable<String>(dataJson);
    map['order_id'] = Variable<String>(orderId);
    map['topic_id'] = Variable<String>(topicId);
    map['read'] = Variable<bool>(read);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotificationRowsCompanion toCompanion(bool nullToAbsent) {
    return NotificationRowsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      dataJson: Value(dataJson),
      orderId: Value(orderId),
      topicId: Value(topicId),
      read: Value(read),
      createdAt: Value(createdAt),
    );
  }

  factory NotificationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      orderId: serializer.fromJson<String>(json['orderId']),
      topicId: serializer.fromJson<String>(json['topicId']),
      read: serializer.fromJson<bool>(json['read']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'dataJson': serializer.toJson<String>(dataJson),
      'orderId': serializer.toJson<String>(orderId),
      'topicId': serializer.toJson<String>(topicId),
      'read': serializer.toJson<bool>(read),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NotificationRow copyWith(
          {String? id,
          String? type,
          String? title,
          String? body,
          String? dataJson,
          String? orderId,
          String? topicId,
          bool? read,
          DateTime? createdAt}) =>
      NotificationRow(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        dataJson: dataJson ?? this.dataJson,
        orderId: orderId ?? this.orderId,
        topicId: topicId ?? this.topicId,
        read: read ?? this.read,
        createdAt: createdAt ?? this.createdAt,
      );
  NotificationRow copyWithCompanion(NotificationRowsCompanion data) {
    return NotificationRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      read: data.read.present ? data.read.value : this.read,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('dataJson: $dataJson, ')
          ..write('orderId: $orderId, ')
          ..write('topicId: $topicId, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, type, title, body, dataJson, orderId, topicId, read, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.dataJson == this.dataJson &&
          other.orderId == this.orderId &&
          other.topicId == this.topicId &&
          other.read == this.read &&
          other.createdAt == this.createdAt);
}

class NotificationRowsCompanion extends UpdateCompanion<NotificationRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String> dataJson;
  final Value<String> orderId;
  final Value<String> topicId;
  final Value<bool> read;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotificationRowsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.orderId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.read = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationRowsCompanion.insert({
    required String id,
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.orderId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.read = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt);
  static Insertable<NotificationRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? dataJson,
    Expression<String>? orderId,
    Expression<String>? topicId,
    Expression<bool>? read,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (dataJson != null) 'data_json': dataJson,
      if (orderId != null) 'order_id': orderId,
      if (topicId != null) 'topic_id': topicId,
      if (read != null) 'read': read,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? title,
      Value<String>? body,
      Value<String>? dataJson,
      Value<String>? orderId,
      Value<String>? topicId,
      Value<bool>? read,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return NotificationRowsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      dataJson: dataJson ?? this.dataJson,
      orderId: orderId ?? this.orderId,
      topicId: topicId ?? this.topicId,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationRowsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('dataJson: $dataJson, ')
          ..write('orderId: $orderId, ')
          ..write('topicId: $topicId, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CouponsTable extends Coupons with TableInfo<$CouponsTable, Coupon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CouponsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('percent'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minOrderMeta =
      const VerificationMeta('minOrder');
  @override
  late final GeneratedColumn<double> minOrder = GeneratedColumn<double>(
      'min_order', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [code, type, value, minOrder, isActive, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coupons';
  @override
  VerificationContext validateIntegrity(Insertable<Coupon> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('min_order')) {
      context.handle(_minOrderMeta,
          minOrder.isAcceptableOrUnknown(data['min_order']!, _minOrderMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Coupon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Coupon(
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value'])!,
      minOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_order'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CouponsTable createAlias(String alias) {
    return $CouponsTable(attachedDatabase, alias);
  }
}

class Coupon extends DataClass implements Insertable<Coupon> {
  final String code;
  final String type;
  final double value;
  final double minOrder;
  final bool isActive;
  final DateTime updatedAt;
  const Coupon(
      {required this.code,
      required this.type,
      required this.value,
      required this.minOrder,
      required this.isActive,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<double>(value);
    map['min_order'] = Variable<double>(minOrder);
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CouponsCompanion toCompanion(bool nullToAbsent) {
    return CouponsCompanion(
      code: Value(code),
      type: Value(type),
      value: Value(value),
      minOrder: Value(minOrder),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
    );
  }

  factory Coupon.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Coupon(
      code: serializer.fromJson<String>(json['code']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<double>(json['value']),
      minOrder: serializer.fromJson<double>(json['minOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<double>(value),
      'minOrder': serializer.toJson<double>(minOrder),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Coupon copyWith(
          {String? code,
          String? type,
          double? value,
          double? minOrder,
          bool? isActive,
          DateTime? updatedAt}) =>
      Coupon(
        code: code ?? this.code,
        type: type ?? this.type,
        value: value ?? this.value,
        minOrder: minOrder ?? this.minOrder,
        isActive: isActive ?? this.isActive,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Coupon copyWithCompanion(CouponsCompanion data) {
    return Coupon(
      code: data.code.present ? data.code.value : this.code,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      minOrder: data.minOrder.present ? data.minOrder.value : this.minOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Coupon(')
          ..write('code: $code, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('minOrder: $minOrder, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, type, value, minOrder, isActive, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Coupon &&
          other.code == this.code &&
          other.type == this.type &&
          other.value == this.value &&
          other.minOrder == this.minOrder &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class CouponsCompanion extends UpdateCompanion<Coupon> {
  final Value<String> code;
  final Value<String> type;
  final Value<double> value;
  final Value<double> minOrder;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CouponsCompanion({
    this.code = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.minOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CouponsCompanion.insert({
    required String code,
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.minOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : code = Value(code),
        updatedAt = Value(updatedAt);
  static Insertable<Coupon> custom({
    Expression<String>? code,
    Expression<String>? type,
    Expression<double>? value,
    Expression<double>? minOrder,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (minOrder != null) 'min_order': minOrder,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CouponsCompanion copyWith(
      {Value<String>? code,
      Value<String>? type,
      Value<double>? value,
      Value<double>? minOrder,
      Value<bool>? isActive,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CouponsCompanion(
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrder: minOrder ?? this.minOrder,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (minOrder.present) {
      map['min_order'] = Variable<double>(minOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CouponsCompanion(')
          ..write('code: $code, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('minOrder: $minOrder, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, Shift> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
      'group', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _isOpenMeta = const VerificationMeta('isOpen');
  @override
  late final GeneratedColumn<bool> isOpen = GeneratedColumn<bool>(
      'is_open', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_open" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _cancelDaysBeforeMeta =
      const VerificationMeta('cancelDaysBefore');
  @override
  late final GeneratedColumn<int> cancelDaysBefore = GeneratedColumn<int>(
      'cancel_days_before', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _editDaysBeforeMeta =
      const VerificationMeta('editDaysBefore');
  @override
  late final GeneratedColumn<int> editDaysBefore = GeneratedColumn<int>(
      'edit_days_before', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        group,
        date,
        label,
        isOpen,
        cancelDaysBefore,
        editDaysBefore,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(Insertable<Shift> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group')) {
      context.handle(
          _groupMeta, group.isAcceptableOrUnknown(data['group']!, _groupMeta));
    } else if (isInserting) {
      context.missing(_groupMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('is_open')) {
      context.handle(_isOpenMeta,
          isOpen.isAcceptableOrUnknown(data['is_open']!, _isOpenMeta));
    }
    if (data.containsKey('cancel_days_before')) {
      context.handle(
          _cancelDaysBeforeMeta,
          cancelDaysBefore.isAcceptableOrUnknown(
              data['cancel_days_before']!, _cancelDaysBeforeMeta));
    }
    if (data.containsKey('edit_days_before')) {
      context.handle(
          _editDaysBeforeMeta,
          editDaysBefore.isAcceptableOrUnknown(
              data['edit_days_before']!, _editDaysBeforeMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shift map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shift(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      group: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      isOpen: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_open'])!,
      cancelDaysBefore: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}cancel_days_before'])!,
      editDaysBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}edit_days_before'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class Shift extends DataClass implements Insertable<Shift> {
  final String id;
  final String group;
  final DateTime date;
  final String label;
  final bool isOpen;
  final int cancelDaysBefore;
  final int editDaysBefore;
  final DateTime updatedAt;
  const Shift(
      {required this.id,
      required this.group,
      required this.date,
      required this.label,
      required this.isOpen,
      required this.cancelDaysBefore,
      required this.editDaysBefore,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group'] = Variable<String>(group);
    map['date'] = Variable<DateTime>(date);
    map['label'] = Variable<String>(label);
    map['is_open'] = Variable<bool>(isOpen);
    map['cancel_days_before'] = Variable<int>(cancelDaysBefore);
    map['edit_days_before'] = Variable<int>(editDaysBefore);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      group: Value(group),
      date: Value(date),
      label: Value(label),
      isOpen: Value(isOpen),
      cancelDaysBefore: Value(cancelDaysBefore),
      editDaysBefore: Value(editDaysBefore),
      updatedAt: Value(updatedAt),
    );
  }

  factory Shift.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shift(
      id: serializer.fromJson<String>(json['id']),
      group: serializer.fromJson<String>(json['group']),
      date: serializer.fromJson<DateTime>(json['date']),
      label: serializer.fromJson<String>(json['label']),
      isOpen: serializer.fromJson<bool>(json['isOpen']),
      cancelDaysBefore: serializer.fromJson<int>(json['cancelDaysBefore']),
      editDaysBefore: serializer.fromJson<int>(json['editDaysBefore']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'group': serializer.toJson<String>(group),
      'date': serializer.toJson<DateTime>(date),
      'label': serializer.toJson<String>(label),
      'isOpen': serializer.toJson<bool>(isOpen),
      'cancelDaysBefore': serializer.toJson<int>(cancelDaysBefore),
      'editDaysBefore': serializer.toJson<int>(editDaysBefore),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Shift copyWith(
          {String? id,
          String? group,
          DateTime? date,
          String? label,
          bool? isOpen,
          int? cancelDaysBefore,
          int? editDaysBefore,
          DateTime? updatedAt}) =>
      Shift(
        id: id ?? this.id,
        group: group ?? this.group,
        date: date ?? this.date,
        label: label ?? this.label,
        isOpen: isOpen ?? this.isOpen,
        cancelDaysBefore: cancelDaysBefore ?? this.cancelDaysBefore,
        editDaysBefore: editDaysBefore ?? this.editDaysBefore,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Shift copyWithCompanion(ShiftsCompanion data) {
    return Shift(
      id: data.id.present ? data.id.value : this.id,
      group: data.group.present ? data.group.value : this.group,
      date: data.date.present ? data.date.value : this.date,
      label: data.label.present ? data.label.value : this.label,
      isOpen: data.isOpen.present ? data.isOpen.value : this.isOpen,
      cancelDaysBefore: data.cancelDaysBefore.present
          ? data.cancelDaysBefore.value
          : this.cancelDaysBefore,
      editDaysBefore: data.editDaysBefore.present
          ? data.editDaysBefore.value
          : this.editDaysBefore,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shift(')
          ..write('id: $id, ')
          ..write('group: $group, ')
          ..write('date: $date, ')
          ..write('label: $label, ')
          ..write('isOpen: $isOpen, ')
          ..write('cancelDaysBefore: $cancelDaysBefore, ')
          ..write('editDaysBefore: $editDaysBefore, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, group, date, label, isOpen,
      cancelDaysBefore, editDaysBefore, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shift &&
          other.id == this.id &&
          other.group == this.group &&
          other.date == this.date &&
          other.label == this.label &&
          other.isOpen == this.isOpen &&
          other.cancelDaysBefore == this.cancelDaysBefore &&
          other.editDaysBefore == this.editDaysBefore &&
          other.updatedAt == this.updatedAt);
}

class ShiftsCompanion extends UpdateCompanion<Shift> {
  final Value<String> id;
  final Value<String> group;
  final Value<DateTime> date;
  final Value<String> label;
  final Value<bool> isOpen;
  final Value<int> cancelDaysBefore;
  final Value<int> editDaysBefore;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.group = const Value.absent(),
    this.date = const Value.absent(),
    this.label = const Value.absent(),
    this.isOpen = const Value.absent(),
    this.cancelDaysBefore = const Value.absent(),
    this.editDaysBefore = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required String group,
    required DateTime date,
    this.label = const Value.absent(),
    this.isOpen = const Value.absent(),
    this.cancelDaysBefore = const Value.absent(),
    this.editDaysBefore = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        group = Value(group),
        date = Value(date),
        updatedAt = Value(updatedAt);
  static Insertable<Shift> custom({
    Expression<String>? id,
    Expression<String>? group,
    Expression<DateTime>? date,
    Expression<String>? label,
    Expression<bool>? isOpen,
    Expression<int>? cancelDaysBefore,
    Expression<int>? editDaysBefore,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (group != null) 'group': group,
      if (date != null) 'date': date,
      if (label != null) 'label': label,
      if (isOpen != null) 'is_open': isOpen,
      if (cancelDaysBefore != null) 'cancel_days_before': cancelDaysBefore,
      if (editDaysBefore != null) 'edit_days_before': editDaysBefore,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith(
      {Value<String>? id,
      Value<String>? group,
      Value<DateTime>? date,
      Value<String>? label,
      Value<bool>? isOpen,
      Value<int>? cancelDaysBefore,
      Value<int>? editDaysBefore,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ShiftsCompanion(
      id: id ?? this.id,
      group: group ?? this.group,
      date: date ?? this.date,
      label: label ?? this.label,
      isOpen: isOpen ?? this.isOpen,
      cancelDaysBefore: cancelDaysBefore ?? this.cancelDaysBefore,
      editDaysBefore: editDaysBefore ?? this.editDaysBefore,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (group.present) {
      map['group'] = Variable<String>(group.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (isOpen.present) {
      map['is_open'] = Variable<bool>(isOpen.value);
    }
    if (cancelDaysBefore.present) {
      map['cancel_days_before'] = Variable<int>(cancelDaysBefore.value);
    }
    if (editDaysBefore.present) {
      map['edit_days_before'] = Variable<int>(editDaysBefore.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('group: $group, ')
          ..write('date: $date, ')
          ..write('label: $label, ')
          ..write('isOpen: $isOpen, ')
          ..write('cancelDaysBefore: $cancelDaysBefore, ')
          ..write('editDaysBefore: $editDaysBefore, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RegionZonesTable extends RegionZones
    with TableInfo<$RegionZonesTable, RegionZone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegionZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _polygonsJsonMeta =
      const VerificationMeta('polygonsJson');
  @override
  late final GeneratedColumn<String> polygonsJson = GeneratedColumn<String>(
      'polygons_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, colorValue, polygonsJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'region_zones';
  @override
  VerificationContext validateIntegrity(Insertable<RegionZone> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    }
    if (data.containsKey('polygons_json')) {
      context.handle(
          _polygonsJsonMeta,
          polygonsJson.isAcceptableOrUnknown(
              data['polygons_json']!, _polygonsJsonMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegionZone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegionZone(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      polygonsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}polygons_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RegionZonesTable createAlias(String alias) {
    return $RegionZonesTable(attachedDatabase, alias);
  }
}

class RegionZone extends DataClass implements Insertable<RegionZone> {
  final String id;
  final String name;
  final int colorValue;
  final String polygonsJson;
  final DateTime updatedAt;
  const RegionZone(
      {required this.id,
      required this.name,
      required this.colorValue,
      required this.polygonsJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_value'] = Variable<int>(colorValue);
    map['polygons_json'] = Variable<String>(polygonsJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RegionZonesCompanion toCompanion(bool nullToAbsent) {
    return RegionZonesCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: Value(colorValue),
      polygonsJson: Value(polygonsJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory RegionZone.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegionZone(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      polygonsJson: serializer.fromJson<String>(json['polygonsJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int>(colorValue),
      'polygonsJson': serializer.toJson<String>(polygonsJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RegionZone copyWith(
          {String? id,
          String? name,
          int? colorValue,
          String? polygonsJson,
          DateTime? updatedAt}) =>
      RegionZone(
        id: id ?? this.id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        polygonsJson: polygonsJson ?? this.polygonsJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RegionZone copyWithCompanion(RegionZonesCompanion data) {
    return RegionZone(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      polygonsJson: data.polygonsJson.present
          ? data.polygonsJson.value
          : this.polygonsJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegionZone(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('polygonsJson: $polygonsJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, colorValue, polygonsJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegionZone &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue &&
          other.polygonsJson == this.polygonsJson &&
          other.updatedAt == this.updatedAt);
}

class RegionZonesCompanion extends UpdateCompanion<RegionZone> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> colorValue;
  final Value<String> polygonsJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RegionZonesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.polygonsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RegionZonesCompanion.insert({
    required String id,
    required String name,
    this.colorValue = const Value.absent(),
    this.polygonsJson = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        updatedAt = Value(updatedAt);
  static Insertable<RegionZone> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<String>? polygonsJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (polygonsJson != null) 'polygons_json': polygonsJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RegionZonesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? colorValue,
      Value<String>? polygonsJson,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return RegionZonesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      polygonsJson: polygonsJson ?? this.polygonsJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (polygonsJson.present) {
      map['polygons_json'] = Variable<String>(polygonsJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegionZonesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('polygonsJson: $polygonsJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApprovalsTable extends Approvals
    with TableInfo<$ApprovalsTable, Approval> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApprovalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('profile'));
  static const VerificationMeta _changesJsonMeta =
      const VerificationMeta('changesJson');
  @override
  late final GeneratedColumn<String> changesJson = GeneratedColumn<String>(
      'changes_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, changesJson, status, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'approvals';
  @override
  VerificationContext validateIntegrity(Insertable<Approval> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('changes_json')) {
      context.handle(
          _changesJsonMeta,
          changesJson.isAcceptableOrUnknown(
              data['changes_json']!, _changesJsonMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Approval map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Approval(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      changesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}changes_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ApprovalsTable createAlias(String alias) {
    return $ApprovalsTable(attachedDatabase, alias);
  }
}

class Approval extends DataClass implements Insertable<Approval> {
  final String id;
  final String type;
  final String changesJson;
  final String status;
  final DateTime createdAt;
  const Approval(
      {required this.id,
      required this.type,
      required this.changesJson,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['changes_json'] = Variable<String>(changesJson);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ApprovalsCompanion toCompanion(bool nullToAbsent) {
    return ApprovalsCompanion(
      id: Value(id),
      type: Value(type),
      changesJson: Value(changesJson),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Approval.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Approval(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      changesJson: serializer.fromJson<String>(json['changesJson']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'changesJson': serializer.toJson<String>(changesJson),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Approval copyWith(
          {String? id,
          String? type,
          String? changesJson,
          String? status,
          DateTime? createdAt}) =>
      Approval(
        id: id ?? this.id,
        type: type ?? this.type,
        changesJson: changesJson ?? this.changesJson,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  Approval copyWithCompanion(ApprovalsCompanion data) {
    return Approval(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      changesJson:
          data.changesJson.present ? data.changesJson.value : this.changesJson,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Approval(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('changesJson: $changesJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, changesJson, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Approval &&
          other.id == this.id &&
          other.type == this.type &&
          other.changesJson == this.changesJson &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class ApprovalsCompanion extends UpdateCompanion<Approval> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> changesJson;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ApprovalsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.changesJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApprovalsCompanion.insert({
    required String id,
    this.type = const Value.absent(),
    this.changesJson = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt);
  static Insertable<Approval> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? changesJson,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (changesJson != null) 'changes_json': changesJson,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApprovalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? changesJson,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ApprovalsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      changesJson: changesJson ?? this.changesJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (changesJson.present) {
      map['changes_json'] = Variable<String>(changesJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApprovalsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('changesJson: $changesJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingMutationsTable extends PendingMutations
    with TableInfo<$PendingMutationsTable, PendingMutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingMutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyJsonMeta =
      const VerificationMeta('bodyJson');
  @override
  late final GeneratedColumn<String> bodyJson = GeneratedColumn<String>(
      'body_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _localRefIdMeta =
      const VerificationMeta('localRefId');
  @override
  late final GeneratedColumn<String> localRefId = GeneratedColumn<String>(
      'local_ref_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        method,
        path,
        bodyJson,
        localRefId,
        createdAt,
        retryCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_mutations';
  @override
  VerificationContext validateIntegrity(Insertable<PendingMutation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('body_json')) {
      context.handle(_bodyJsonMeta,
          bodyJson.isAcceptableOrUnknown(data['body_json']!, _bodyJsonMeta));
    }
    if (data.containsKey('local_ref_id')) {
      context.handle(
          _localRefIdMeta,
          localRefId.isAcceptableOrUnknown(
              data['local_ref_id']!, _localRefIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingMutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingMutation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      bodyJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_json'])!,
      localRefId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_ref_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error'])!,
    );
  }

  @override
  $PendingMutationsTable createAlias(String alias) {
    return $PendingMutationsTable(attachedDatabase, alias);
  }
}

class PendingMutation extends DataClass implements Insertable<PendingMutation> {
  final int id;
  final String entityType;
  final String method;
  final String path;
  final String bodyJson;
  final String localRefId;
  final DateTime createdAt;
  final int retryCount;
  final String lastError;
  const PendingMutation(
      {required this.id,
      required this.entityType,
      required this.method,
      required this.path,
      required this.bodyJson,
      required this.localRefId,
      required this.createdAt,
      required this.retryCount,
      required this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['method'] = Variable<String>(method);
    map['path'] = Variable<String>(path);
    map['body_json'] = Variable<String>(bodyJson);
    map['local_ref_id'] = Variable<String>(localRefId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    map['last_error'] = Variable<String>(lastError);
    return map;
  }

  PendingMutationsCompanion toCompanion(bool nullToAbsent) {
    return PendingMutationsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      method: Value(method),
      path: Value(path),
      bodyJson: Value(bodyJson),
      localRefId: Value(localRefId),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: Value(lastError),
    );
  }

  factory PendingMutation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingMutation(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      method: serializer.fromJson<String>(json['method']),
      path: serializer.fromJson<String>(json['path']),
      bodyJson: serializer.fromJson<String>(json['bodyJson']),
      localRefId: serializer.fromJson<String>(json['localRefId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'method': serializer.toJson<String>(method),
      'path': serializer.toJson<String>(path),
      'bodyJson': serializer.toJson<String>(bodyJson),
      'localRefId': serializer.toJson<String>(localRefId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String>(lastError),
    };
  }

  PendingMutation copyWith(
          {int? id,
          String? entityType,
          String? method,
          String? path,
          String? bodyJson,
          String? localRefId,
          DateTime? createdAt,
          int? retryCount,
          String? lastError}) =>
      PendingMutation(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        method: method ?? this.method,
        path: path ?? this.path,
        bodyJson: bodyJson ?? this.bodyJson,
        localRefId: localRefId ?? this.localRefId,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError ?? this.lastError,
      );
  PendingMutation copyWithCompanion(PendingMutationsCompanion data) {
    return PendingMutation(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      method: data.method.present ? data.method.value : this.method,
      path: data.path.present ? data.path.value : this.path,
      bodyJson: data.bodyJson.present ? data.bodyJson.value : this.bodyJson,
      localRefId:
          data.localRefId.present ? data.localRefId.value : this.localRefId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutation(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('localRefId: $localRefId, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, method, path, bodyJson,
      localRefId, createdAt, retryCount, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMutation &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.method == this.method &&
          other.path == this.path &&
          other.bodyJson == this.bodyJson &&
          other.localRefId == this.localRefId &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class PendingMutationsCompanion extends UpdateCompanion<PendingMutation> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> method;
  final Value<String> path;
  final Value<String> bodyJson;
  final Value<String> localRefId;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String> lastError;
  const PendingMutationsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.method = const Value.absent(),
    this.path = const Value.absent(),
    this.bodyJson = const Value.absent(),
    this.localRefId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  PendingMutationsCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String method,
    required String path,
    this.bodyJson = const Value.absent(),
    this.localRefId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : entityType = Value(entityType),
        method = Value(method),
        path = Value(path);
  static Insertable<PendingMutation> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? method,
    Expression<String>? path,
    Expression<String>? bodyJson,
    Expression<String>? localRefId,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (method != null) 'method': method,
      if (path != null) 'path': path,
      if (bodyJson != null) 'body_json': bodyJson,
      if (localRefId != null) 'local_ref_id': localRefId,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  PendingMutationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? method,
      Value<String>? path,
      Value<String>? bodyJson,
      Value<String>? localRefId,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String>? lastError}) {
    return PendingMutationsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      method: method ?? this.method,
      path: path ?? this.path,
      bodyJson: bodyJson ?? this.bodyJson,
      localRefId: localRefId ?? this.localRefId,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (bodyJson.present) {
      map['body_json'] = Variable<String>(bodyJson.value);
    }
    if (localRefId.present) {
      map['local_ref_id'] = Variable<String>(localRefId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutationsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('method: $method, ')
          ..write('path: $path, ')
          ..write('bodyJson: $bodyJson, ')
          ..write('localRefId: $localRefId, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sinceMeta = const VerificationMeta('since');
  @override
  late final GeneratedColumn<DateTime> since = GeneratedColumn<DateTime>(
      'since', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [entity, since];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(Insertable<SyncCursor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('since')) {
      context.handle(
          _sinceMeta, since.isAcceptableOrUnknown(data['since']!, _sinceMeta));
    } else if (isInserting) {
      context.missing(_sinceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      since: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}since'])!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String entity;
  final DateTime since;
  const SyncCursor({required this.entity, required this.since});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['since'] = Variable<DateTime>(since);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      entity: Value(entity),
      since: Value(since),
    );
  }

  factory SyncCursor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      entity: serializer.fromJson<String>(json['entity']),
      since: serializer.fromJson<DateTime>(json['since']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'since': serializer.toJson<DateTime>(since),
    };
  }

  SyncCursor copyWith({String? entity, DateTime? since}) => SyncCursor(
        entity: entity ?? this.entity,
        since: since ?? this.since,
      );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      entity: data.entity.present ? data.entity.value : this.entity,
      since: data.since.present ? data.since.value : this.since,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('entity: $entity, ')
          ..write('since: $since')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, since);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.entity == this.entity &&
          other.since == this.since);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> entity;
  final Value<DateTime> since;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.entity = const Value.absent(),
    this.since = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String entity,
    required DateTime since,
    this.rowid = const Value.absent(),
  })  : entity = Value(entity),
        since = Value(since);
  static Insertable<SyncCursor> custom({
    Expression<String>? entity,
    Expression<DateTime>? since,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (since != null) 'since': since,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith(
      {Value<String>? entity, Value<DateTime>? since, Value<int>? rowid}) {
    return SyncCursorsCompanion(
      entity: entity ?? this.entity,
      since: since ?? this.since,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (since.present) {
      map['since'] = Variable<DateTime>(since.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('entity: $entity, ')
          ..write('since: $since, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalUserTable localUser = $LocalUserTable(this);
  late final $RegistrationDraftsTable registrationDrafts =
      $RegistrationDraftsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $CartItemsTable cartItems = $CartItemsTable(this);
  late final $CartMetaTable cartMeta = $CartMetaTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $OrderItemRowsTable orderItemRows = $OrderItemRowsTable(this);
  late final $ChatTopicsTable chatTopics = $ChatTopicsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $NotificationRowsTable notificationRows =
      $NotificationRowsTable(this);
  late final $CouponsTable coupons = $CouponsTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $RegionZonesTable regionZones = $RegionZonesTable(this);
  late final $ApprovalsTable approvals = $ApprovalsTable(this);
  late final $PendingMutationsTable pendingMutations =
      $PendingMutationsTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localUser,
        registrationDrafts,
        categories,
        products,
        cartItems,
        cartMeta,
        orders,
        orderItemRows,
        chatTopics,
        messages,
        notificationRows,
        coupons,
        shifts,
        regionZones,
        approvals,
        pendingMutations,
        syncCursors
      ];
}

typedef $$LocalUserTableCreateCompanionBuilder = LocalUserCompanion Function({
  required String id,
  Value<String> phone,
  Value<String> email,
  Value<String> name,
  Value<String> lastName,
  Value<String> address,
  Value<String> city,
  Value<String> postalCode,
  Value<String> group,
  Value<double?> lat,
  Value<double?> lng,
  Value<String> language,
  Value<String> photoUrl,
  Value<bool> isVerified,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$LocalUserTableUpdateCompanionBuilder = LocalUserCompanion Function({
  Value<String> id,
  Value<String> phone,
  Value<String> email,
  Value<String> name,
  Value<String> lastName,
  Value<String> address,
  Value<String> city,
  Value<String> postalCode,
  Value<String> group,
  Value<double?> lat,
  Value<double?> lng,
  Value<String> language,
  Value<String> photoUrl,
  Value<bool> isVerified,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalUserTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserTable> {
  $$LocalUserTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postalCode => $composableBuilder(
      column: $table.postalCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalUserTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserTable> {
  $$LocalUserTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postalCode => $composableBuilder(
      column: $table.postalCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalUserTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserTable> {
  $$LocalUserTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get postalCode => $composableBuilder(
      column: $table.postalCode, builder: (column) => column);

  GeneratedColumn<String> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<bool> get isVerified => $composableBuilder(
      column: $table.isVerified, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalUserTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalUserTable,
    LocalUserData,
    $$LocalUserTableFilterComposer,
    $$LocalUserTableOrderingComposer,
    $$LocalUserTableAnnotationComposer,
    $$LocalUserTableCreateCompanionBuilder,
    $$LocalUserTableUpdateCompanionBuilder,
    (
      LocalUserData,
      BaseReferences<_$AppDatabase, $LocalUserTable, LocalUserData>
    ),
    LocalUserData,
    PrefetchHooks Function()> {
  $$LocalUserTableTableManager(_$AppDatabase db, $LocalUserTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> postalCode = const Value.absent(),
            Value<String> group = const Value.absent(),
            Value<double?> lat = const Value.absent(),
            Value<double?> lng = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUserCompanion(
            id: id,
            phone: phone,
            email: email,
            name: name,
            lastName: lastName,
            address: address,
            city: city,
            postalCode: postalCode,
            group: group,
            lat: lat,
            lng: lng,
            language: language,
            photoUrl: photoUrl,
            isVerified: isVerified,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> phone = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> postalCode = const Value.absent(),
            Value<String> group = const Value.absent(),
            Value<double?> lat = const Value.absent(),
            Value<double?> lng = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> photoUrl = const Value.absent(),
            Value<bool> isVerified = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUserCompanion.insert(
            id: id,
            phone: phone,
            email: email,
            name: name,
            lastName: lastName,
            address: address,
            city: city,
            postalCode: postalCode,
            group: group,
            lat: lat,
            lng: lng,
            language: language,
            photoUrl: photoUrl,
            isVerified: isVerified,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalUserTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalUserTable,
    LocalUserData,
    $$LocalUserTableFilterComposer,
    $$LocalUserTableOrderingComposer,
    $$LocalUserTableAnnotationComposer,
    $$LocalUserTableCreateCompanionBuilder,
    $$LocalUserTableUpdateCompanionBuilder,
    (
      LocalUserData,
      BaseReferences<_$AppDatabase, $LocalUserTable, LocalUserData>
    ),
    LocalUserData,
    PrefetchHooks Function()>;
typedef $$RegistrationDraftsTableCreateCompanionBuilder
    = RegistrationDraftsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> lastName,
  Value<String> referredBy,
  Value<String> address,
  Value<String> city,
  Value<String> postalCode,
  Value<String> groupName,
  Value<double?> lat,
  Value<double?> lng,
  Value<String> language,
  Value<int> rowid,
});
typedef $$RegistrationDraftsTableUpdateCompanionBuilder
    = RegistrationDraftsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> lastName,
  Value<String> referredBy,
  Value<String> address,
  Value<String> city,
  Value<String> postalCode,
  Value<String> groupName,
  Value<double?> lat,
  Value<double?> lng,
  Value<String> language,
  Value<int> rowid,
});

class $$RegistrationDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $RegistrationDraftsTable> {
  $$RegistrationDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referredBy => $composableBuilder(
      column: $table.referredBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get postalCode => $composableBuilder(
      column: $table.postalCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));
}

class $$RegistrationDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $RegistrationDraftsTable> {
  $$RegistrationDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referredBy => $composableBuilder(
      column: $table.referredBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city => $composableBuilder(
      column: $table.city, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get postalCode => $composableBuilder(
      column: $table.postalCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));
}

class $$RegistrationDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegistrationDraftsTable> {
  $$RegistrationDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get referredBy => $composableBuilder(
      column: $table.referredBy, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get postalCode => $composableBuilder(
      column: $table.postalCode, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);
}

class $$RegistrationDraftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RegistrationDraftsTable,
    RegistrationDraft,
    $$RegistrationDraftsTableFilterComposer,
    $$RegistrationDraftsTableOrderingComposer,
    $$RegistrationDraftsTableAnnotationComposer,
    $$RegistrationDraftsTableCreateCompanionBuilder,
    $$RegistrationDraftsTableUpdateCompanionBuilder,
    (
      RegistrationDraft,
      BaseReferences<_$AppDatabase, $RegistrationDraftsTable, RegistrationDraft>
    ),
    RegistrationDraft,
    PrefetchHooks Function()> {
  $$RegistrationDraftsTableTableManager(
      _$AppDatabase db, $RegistrationDraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistrationDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistrationDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegistrationDraftsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String> referredBy = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> postalCode = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<double?> lat = const Value.absent(),
            Value<double?> lng = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RegistrationDraftsCompanion(
            id: id,
            name: name,
            lastName: lastName,
            referredBy: referredBy,
            address: address,
            city: city,
            postalCode: postalCode,
            groupName: groupName,
            lat: lat,
            lng: lng,
            language: language,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String> referredBy = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<String> city = const Value.absent(),
            Value<String> postalCode = const Value.absent(),
            Value<String> groupName = const Value.absent(),
            Value<double?> lat = const Value.absent(),
            Value<double?> lng = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RegistrationDraftsCompanion.insert(
            id: id,
            name: name,
            lastName: lastName,
            referredBy: referredBy,
            address: address,
            city: city,
            postalCode: postalCode,
            groupName: groupName,
            lat: lat,
            lng: lng,
            language: language,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RegistrationDraftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RegistrationDraftsTable,
    RegistrationDraft,
    $$RegistrationDraftsTableFilterComposer,
    $$RegistrationDraftsTableOrderingComposer,
    $$RegistrationDraftsTableAnnotationComposer,
    $$RegistrationDraftsTableCreateCompanionBuilder,
    $$RegistrationDraftsTableUpdateCompanionBuilder,
    (
      RegistrationDraft,
      BaseReferences<_$AppDatabase, $RegistrationDraftsTable, RegistrationDraft>
    ),
    RegistrationDraft,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  Value<String> nameJson,
  Value<String> imageUrl,
  Value<int> sortOrder,
  Value<bool> isActive,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> nameJson,
  Value<String> imageUrl,
  Value<int> sortOrder,
  Value<bool> isActive,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameJson => $composableBuilder(
      column: $table.nameJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameJson => $composableBuilder(
      column: $table.nameJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameJson =>
      $composableBuilder(column: $table.nameJson, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nameJson = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            nameJson: nameJson,
            imageUrl: imageUrl,
            sortOrder: sortOrder,
            isActive: isActive,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> nameJson = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            nameJson: nameJson,
            imageUrl: imageUrl,
            sortOrder: sortOrder,
            isActive: isActive,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
    Category,
    PrefetchHooks Function()>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String categoryId,
  Value<String> nameJson,
  Value<String> descriptionJson,
  required double price,
  Value<String> unit,
  Value<int> maxQty,
  Value<String> imageUrl,
  Value<String> imagesJson,
  Value<bool> isActive,
  Value<int> sortOrder,
  Value<String> discountType,
  Value<double> discountValue,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> categoryId,
  Value<String> nameJson,
  Value<String> descriptionJson,
  Value<double> price,
  Value<String> unit,
  Value<int> maxQty,
  Value<String> imageUrl,
  Value<String> imagesJson,
  Value<bool> isActive,
  Value<int> sortOrder,
  Value<String> discountType,
  Value<double> discountValue,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameJson => $composableBuilder(
      column: $table.nameJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptionJson => $composableBuilder(
      column: $table.descriptionJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxQty => $composableBuilder(
      column: $table.maxQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagesJson => $composableBuilder(
      column: $table.imagesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get discountType => $composableBuilder(
      column: $table.discountType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discountValue => $composableBuilder(
      column: $table.discountValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameJson => $composableBuilder(
      column: $table.nameJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionJson => $composableBuilder(
      column: $table.descriptionJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxQty => $composableBuilder(
      column: $table.maxQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagesJson => $composableBuilder(
      column: $table.imagesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get discountType => $composableBuilder(
      column: $table.discountType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discountValue => $composableBuilder(
      column: $table.discountValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get nameJson =>
      $composableBuilder(column: $table.nameJson, builder: (column) => column);

  GeneratedColumn<String> get descriptionJson => $composableBuilder(
      column: $table.descriptionJson, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get maxQty =>
      $composableBuilder(column: $table.maxQty, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get imagesJson => $composableBuilder(
      column: $table.imagesJson, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get discountType => $composableBuilder(
      column: $table.discountType, builder: (column) => column);

  GeneratedColumn<double> get discountValue => $composableBuilder(
      column: $table.discountValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String> nameJson = const Value.absent(),
            Value<String> descriptionJson = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<int> maxQty = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<String> imagesJson = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> discountType = const Value.absent(),
            Value<double> discountValue = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            categoryId: categoryId,
            nameJson: nameJson,
            descriptionJson: descriptionJson,
            price: price,
            unit: unit,
            maxQty: maxQty,
            imageUrl: imageUrl,
            imagesJson: imagesJson,
            isActive: isActive,
            sortOrder: sortOrder,
            discountType: discountType,
            discountValue: discountValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String categoryId,
            Value<String> nameJson = const Value.absent(),
            Value<String> descriptionJson = const Value.absent(),
            required double price,
            Value<String> unit = const Value.absent(),
            Value<int> maxQty = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<String> imagesJson = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> discountType = const Value.absent(),
            Value<double> discountValue = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            categoryId: categoryId,
            nameJson: nameJson,
            descriptionJson: descriptionJson,
            price: price,
            unit: unit,
            maxQty: maxQty,
            imageUrl: imageUrl,
            imagesJson: imagesJson,
            isActive: isActive,
            sortOrder: sortOrder,
            discountType: discountType,
            discountValue: discountValue,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()>;
typedef $$CartItemsTableCreateCompanionBuilder = CartItemsCompanion Function({
  required String productId,
  required int qty,
  Value<int> rowid,
});
typedef $$CartItemsTableUpdateCompanionBuilder = CartItemsCompanion Function({
  Value<String> productId,
  Value<int> qty,
  Value<int> rowid,
});

class $$CartItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CartItemsTable> {
  $$CartItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnFilters(column));
}

class $$CartItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CartItemsTable> {
  $$CartItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnOrderings(column));
}

class $$CartItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartItemsTable> {
  $$CartItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);
}

class $$CartItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CartItemsTable,
    CartItem,
    $$CartItemsTableFilterComposer,
    $$CartItemsTableOrderingComposer,
    $$CartItemsTableAnnotationComposer,
    $$CartItemsTableCreateCompanionBuilder,
    $$CartItemsTableUpdateCompanionBuilder,
    (CartItem, BaseReferences<_$AppDatabase, $CartItemsTable, CartItem>),
    CartItem,
    PrefetchHooks Function()> {
  $$CartItemsTableTableManager(_$AppDatabase db, $CartItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> productId = const Value.absent(),
            Value<int> qty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CartItemsCompanion(
            productId: productId,
            qty: qty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String productId,
            required int qty,
            Value<int> rowid = const Value.absent(),
          }) =>
              CartItemsCompanion.insert(
            productId: productId,
            qty: qty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CartItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CartItemsTable,
    CartItem,
    $$CartItemsTableFilterComposer,
    $$CartItemsTableOrderingComposer,
    $$CartItemsTableAnnotationComposer,
    $$CartItemsTableCreateCompanionBuilder,
    $$CartItemsTableUpdateCompanionBuilder,
    (CartItem, BaseReferences<_$AppDatabase, $CartItemsTable, CartItem>),
    CartItem,
    PrefetchHooks Function()>;
typedef $$CartMetaTableCreateCompanionBuilder = CartMetaCompanion Function({
  Value<int> id,
  Value<String> shiftId,
  Value<String> couponCode,
  Value<String> editingOrderId,
});
typedef $$CartMetaTableUpdateCompanionBuilder = CartMetaCompanion Function({
  Value<int> id,
  Value<String> shiftId,
  Value<String> couponCode,
  Value<String> editingOrderId,
});

class $$CartMetaTableFilterComposer
    extends Composer<_$AppDatabase, $CartMetaTable> {
  $$CartMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get couponCode => $composableBuilder(
      column: $table.couponCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editingOrderId => $composableBuilder(
      column: $table.editingOrderId,
      builder: (column) => ColumnFilters(column));
}

class $$CartMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $CartMetaTable> {
  $$CartMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get couponCode => $composableBuilder(
      column: $table.couponCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editingOrderId => $composableBuilder(
      column: $table.editingOrderId,
      builder: (column) => ColumnOrderings(column));
}

class $$CartMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $CartMetaTable> {
  $$CartMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get couponCode => $composableBuilder(
      column: $table.couponCode, builder: (column) => column);

  GeneratedColumn<String> get editingOrderId => $composableBuilder(
      column: $table.editingOrderId, builder: (column) => column);
}

class $$CartMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CartMetaTable,
    CartMetaData,
    $$CartMetaTableFilterComposer,
    $$CartMetaTableOrderingComposer,
    $$CartMetaTableAnnotationComposer,
    $$CartMetaTableCreateCompanionBuilder,
    $$CartMetaTableUpdateCompanionBuilder,
    (CartMetaData, BaseReferences<_$AppDatabase, $CartMetaTable, CartMetaData>),
    CartMetaData,
    PrefetchHooks Function()> {
  $$CartMetaTableTableManager(_$AppDatabase db, $CartMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> shiftId = const Value.absent(),
            Value<String> couponCode = const Value.absent(),
            Value<String> editingOrderId = const Value.absent(),
          }) =>
              CartMetaCompanion(
            id: id,
            shiftId: shiftId,
            couponCode: couponCode,
            editingOrderId: editingOrderId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> shiftId = const Value.absent(),
            Value<String> couponCode = const Value.absent(),
            Value<String> editingOrderId = const Value.absent(),
          }) =>
              CartMetaCompanion.insert(
            id: id,
            shiftId: shiftId,
            couponCode: couponCode,
            editingOrderId: editingOrderId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CartMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CartMetaTable,
    CartMetaData,
    $$CartMetaTableFilterComposer,
    $$CartMetaTableOrderingComposer,
    $$CartMetaTableAnnotationComposer,
    $$CartMetaTableCreateCompanionBuilder,
    $$CartMetaTableUpdateCompanionBuilder,
    (CartMetaData, BaseReferences<_$AppDatabase, $CartMetaTable, CartMetaData>),
    CartMetaData,
    PrefetchHooks Function()>;
typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  required String id,
  required String userId,
  required String status,
  Value<String> driverId,
  Value<String> shiftId,
  Value<DateTime?> shiftDate,
  Value<String> shiftLabel,
  Value<double> subtotal,
  Value<double> discount,
  Value<String> couponCode,
  Value<double> totalPrice,
  Value<String> userName,
  Value<String> userAddress,
  Value<String> userCity,
  Value<String> adminNote,
  Value<bool> pendingApproval,
  Value<bool> awaitingSchedule,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<bool> pendingSync,
  Value<int> rowid,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> status,
  Value<String> driverId,
  Value<String> shiftId,
  Value<DateTime?> shiftDate,
  Value<String> shiftLabel,
  Value<double> subtotal,
  Value<double> discount,
  Value<String> couponCode,
  Value<double> totalPrice,
  Value<String> userName,
  Value<String> userAddress,
  Value<String> userCity,
  Value<String> adminNote,
  Value<bool> pendingApproval,
  Value<bool> awaitingSchedule,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> pendingSync,
  Value<int> rowid,
});

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get shiftDate => $composableBuilder(
      column: $table.shiftDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiftLabel => $composableBuilder(
      column: $table.shiftLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get couponCode => $composableBuilder(
      column: $table.couponCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userAddress => $composableBuilder(
      column: $table.userAddress, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userCity => $composableBuilder(
      column: $table.userCity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get adminNote => $composableBuilder(
      column: $table.adminNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendingApproval => $composableBuilder(
      column: $table.pendingApproval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get awaitingSchedule => $composableBuilder(
      column: $table.awaitingSchedule,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnFilters(column));
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get driverId => $composableBuilder(
      column: $table.driverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get shiftDate => $composableBuilder(
      column: $table.shiftDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiftLabel => $composableBuilder(
      column: $table.shiftLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get couponCode => $composableBuilder(
      column: $table.couponCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userAddress => $composableBuilder(
      column: $table.userAddress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userCity => $composableBuilder(
      column: $table.userCity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adminNote => $composableBuilder(
      column: $table.adminNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendingApproval => $composableBuilder(
      column: $table.pendingApproval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get awaitingSchedule => $composableBuilder(
      column: $table.awaitingSchedule,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnOrderings(column));
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get driverId =>
      $composableBuilder(column: $table.driverId, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<DateTime> get shiftDate =>
      $composableBuilder(column: $table.shiftDate, builder: (column) => column);

  GeneratedColumn<String> get shiftLabel => $composableBuilder(
      column: $table.shiftLabel, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<String> get couponCode => $composableBuilder(
      column: $table.couponCode, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
      column: $table.totalPrice, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get userAddress => $composableBuilder(
      column: $table.userAddress, builder: (column) => column);

  GeneratedColumn<String> get userCity =>
      $composableBuilder(column: $table.userCity, builder: (column) => column);

  GeneratedColumn<String> get adminNote =>
      $composableBuilder(column: $table.adminNote, builder: (column) => column);

  GeneratedColumn<bool> get pendingApproval => $composableBuilder(
      column: $table.pendingApproval, builder: (column) => column);

  GeneratedColumn<bool> get awaitingSchedule => $composableBuilder(
      column: $table.awaitingSchedule, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => column);
}

class $$OrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
    Order,
    PrefetchHooks Function()> {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> driverId = const Value.absent(),
            Value<String> shiftId = const Value.absent(),
            Value<DateTime?> shiftDate = const Value.absent(),
            Value<String> shiftLabel = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<String> couponCode = const Value.absent(),
            Value<double> totalPrice = const Value.absent(),
            Value<String> userName = const Value.absent(),
            Value<String> userAddress = const Value.absent(),
            Value<String> userCity = const Value.absent(),
            Value<String> adminNote = const Value.absent(),
            Value<bool> pendingApproval = const Value.absent(),
            Value<bool> awaitingSchedule = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> pendingSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion(
            id: id,
            userId: userId,
            status: status,
            driverId: driverId,
            shiftId: shiftId,
            shiftDate: shiftDate,
            shiftLabel: shiftLabel,
            subtotal: subtotal,
            discount: discount,
            couponCode: couponCode,
            totalPrice: totalPrice,
            userName: userName,
            userAddress: userAddress,
            userCity: userCity,
            adminNote: adminNote,
            pendingApproval: pendingApproval,
            awaitingSchedule: awaitingSchedule,
            createdAt: createdAt,
            updatedAt: updatedAt,
            pendingSync: pendingSync,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String status,
            Value<String> driverId = const Value.absent(),
            Value<String> shiftId = const Value.absent(),
            Value<DateTime?> shiftDate = const Value.absent(),
            Value<String> shiftLabel = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<String> couponCode = const Value.absent(),
            Value<double> totalPrice = const Value.absent(),
            Value<String> userName = const Value.absent(),
            Value<String> userAddress = const Value.absent(),
            Value<String> userCity = const Value.absent(),
            Value<String> adminNote = const Value.absent(),
            Value<bool> pendingApproval = const Value.absent(),
            Value<bool> awaitingSchedule = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<bool> pendingSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion.insert(
            id: id,
            userId: userId,
            status: status,
            driverId: driverId,
            shiftId: shiftId,
            shiftDate: shiftDate,
            shiftLabel: shiftLabel,
            subtotal: subtotal,
            discount: discount,
            couponCode: couponCode,
            totalPrice: totalPrice,
            userName: userName,
            userAddress: userAddress,
            userCity: userCity,
            adminNote: adminNote,
            pendingApproval: pendingApproval,
            awaitingSchedule: awaitingSchedule,
            createdAt: createdAt,
            updatedAt: updatedAt,
            pendingSync: pendingSync,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
    Order,
    PrefetchHooks Function()>;
typedef $$OrderItemRowsTableCreateCompanionBuilder = OrderItemRowsCompanion
    Function({
  required String id,
  required String orderId,
  Value<String> productId,
  Value<String> name,
  required int qty,
  required double unitPrice,
  Value<int> rowid,
});
typedef $$OrderItemRowsTableUpdateCompanionBuilder = OrderItemRowsCompanion
    Function({
  Value<String> id,
  Value<String> orderId,
  Value<String> productId,
  Value<String> name,
  Value<int> qty,
  Value<double> unitPrice,
  Value<int> rowid,
});

class $$OrderItemRowsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemRowsTable> {
  $$OrderItemRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));
}

class $$OrderItemRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemRowsTable> {
  $$OrderItemRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));
}

class $$OrderItemRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemRowsTable> {
  $$OrderItemRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);
}

class $$OrderItemRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderItemRowsTable,
    OrderItemRow,
    $$OrderItemRowsTableFilterComposer,
    $$OrderItemRowsTableOrderingComposer,
    $$OrderItemRowsTableAnnotationComposer,
    $$OrderItemRowsTableCreateCompanionBuilder,
    $$OrderItemRowsTableUpdateCompanionBuilder,
    (
      OrderItemRow,
      BaseReferences<_$AppDatabase, $OrderItemRowsTable, OrderItemRow>
    ),
    OrderItemRow,
    PrefetchHooks Function()> {
  $$OrderItemRowsTableTableManager(_$AppDatabase db, $OrderItemRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> qty = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderItemRowsCompanion(
            id: id,
            orderId: orderId,
            productId: productId,
            name: name,
            qty: qty,
            unitPrice: unitPrice,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String orderId,
            Value<String> productId = const Value.absent(),
            Value<String> name = const Value.absent(),
            required int qty,
            required double unitPrice,
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderItemRowsCompanion.insert(
            id: id,
            orderId: orderId,
            productId: productId,
            name: name,
            qty: qty,
            unitPrice: unitPrice,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrderItemRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderItemRowsTable,
    OrderItemRow,
    $$OrderItemRowsTableFilterComposer,
    $$OrderItemRowsTableOrderingComposer,
    $$OrderItemRowsTableAnnotationComposer,
    $$OrderItemRowsTableCreateCompanionBuilder,
    $$OrderItemRowsTableUpdateCompanionBuilder,
    (
      OrderItemRow,
      BaseReferences<_$AppDatabase, $OrderItemRowsTable, OrderItemRow>
    ),
    OrderItemRow,
    PrefetchHooks Function()>;
typedef $$ChatTopicsTableCreateCompanionBuilder = ChatTopicsCompanion Function({
  required String id,
  Value<String> userName,
  Value<String> lastMessage,
  Value<DateTime?> lastAt,
  Value<bool> lastFromAdmin,
  Value<int> customerUnread,
  Value<int> rowid,
});
typedef $$ChatTopicsTableUpdateCompanionBuilder = ChatTopicsCompanion Function({
  Value<String> id,
  Value<String> userName,
  Value<String> lastMessage,
  Value<DateTime?> lastAt,
  Value<bool> lastFromAdmin,
  Value<int> customerUnread,
  Value<int> rowid,
});

class $$ChatTopicsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatTopicsTable> {
  $$ChatTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAt => $composableBuilder(
      column: $table.lastAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get lastFromAdmin => $composableBuilder(
      column: $table.lastFromAdmin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get customerUnread => $composableBuilder(
      column: $table.customerUnread,
      builder: (column) => ColumnFilters(column));
}

class $$ChatTopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatTopicsTable> {
  $$ChatTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userName => $composableBuilder(
      column: $table.userName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAt => $composableBuilder(
      column: $table.lastAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get lastFromAdmin => $composableBuilder(
      column: $table.lastFromAdmin,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get customerUnread => $composableBuilder(
      column: $table.customerUnread,
      builder: (column) => ColumnOrderings(column));
}

class $$ChatTopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatTopicsTable> {
  $$ChatTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get lastMessage => $composableBuilder(
      column: $table.lastMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAt =>
      $composableBuilder(column: $table.lastAt, builder: (column) => column);

  GeneratedColumn<bool> get lastFromAdmin => $composableBuilder(
      column: $table.lastFromAdmin, builder: (column) => column);

  GeneratedColumn<int> get customerUnread => $composableBuilder(
      column: $table.customerUnread, builder: (column) => column);
}

class $$ChatTopicsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatTopicsTable,
    ChatTopic,
    $$ChatTopicsTableFilterComposer,
    $$ChatTopicsTableOrderingComposer,
    $$ChatTopicsTableAnnotationComposer,
    $$ChatTopicsTableCreateCompanionBuilder,
    $$ChatTopicsTableUpdateCompanionBuilder,
    (ChatTopic, BaseReferences<_$AppDatabase, $ChatTopicsTable, ChatTopic>),
    ChatTopic,
    PrefetchHooks Function()> {
  $$ChatTopicsTableTableManager(_$AppDatabase db, $ChatTopicsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userName = const Value.absent(),
            Value<String> lastMessage = const Value.absent(),
            Value<DateTime?> lastAt = const Value.absent(),
            Value<bool> lastFromAdmin = const Value.absent(),
            Value<int> customerUnread = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatTopicsCompanion(
            id: id,
            userName: userName,
            lastMessage: lastMessage,
            lastAt: lastAt,
            lastFromAdmin: lastFromAdmin,
            customerUnread: customerUnread,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> userName = const Value.absent(),
            Value<String> lastMessage = const Value.absent(),
            Value<DateTime?> lastAt = const Value.absent(),
            Value<bool> lastFromAdmin = const Value.absent(),
            Value<int> customerUnread = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatTopicsCompanion.insert(
            id: id,
            userName: userName,
            lastMessage: lastMessage,
            lastAt: lastAt,
            lastFromAdmin: lastFromAdmin,
            customerUnread: customerUnread,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatTopicsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatTopicsTable,
    ChatTopic,
    $$ChatTopicsTableFilterComposer,
    $$ChatTopicsTableOrderingComposer,
    $$ChatTopicsTableAnnotationComposer,
    $$ChatTopicsTableCreateCompanionBuilder,
    $$ChatTopicsTableUpdateCompanionBuilder,
    (ChatTopic, BaseReferences<_$AppDatabase, $ChatTopicsTable, ChatTopic>),
    ChatTopic,
    PrefetchHooks Function()>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String topicId,
  required String senderId,
  required String senderName,
  required bool isFromAdmin,
  Value<bool> isRead,
  required String type,
  Value<String?> textContent,
  Value<bool> deleted,
  Value<String> replyToId,
  Value<String> replyToText,
  Value<String> replyToSender,
  Value<String?> mediaUrl,
  Value<String?> mediaUrlsJson,
  Value<int> durationMs,
  Value<String> orderId,
  Value<String?> waveformJson,
  Value<int> sizeBytes,
  Value<bool> uploading,
  Value<int> uploadCount,
  Value<String?> reactionsJson,
  required DateTime createdAt,
  Value<DateTime> updatedAt,
  Value<String> localMediaPath,
  Value<bool> pendingSync,
  Value<bool> sendFailed,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> topicId,
  Value<String> senderId,
  Value<String> senderName,
  Value<bool> isFromAdmin,
  Value<bool> isRead,
  Value<String> type,
  Value<String?> textContent,
  Value<bool> deleted,
  Value<String> replyToId,
  Value<String> replyToText,
  Value<String> replyToSender,
  Value<String?> mediaUrl,
  Value<String?> mediaUrlsJson,
  Value<int> durationMs,
  Value<String> orderId,
  Value<String?> waveformJson,
  Value<int> sizeBytes,
  Value<bool> uploading,
  Value<int> uploadCount,
  Value<String?> reactionsJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> localMediaPath,
  Value<bool> pendingSync,
  Value<bool> sendFailed,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFromAdmin => $composableBuilder(
      column: $table.isFromAdmin, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyToId => $composableBuilder(
      column: $table.replyToId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyToText => $composableBuilder(
      column: $table.replyToText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get replyToSender => $composableBuilder(
      column: $table.replyToSender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaUrl => $composableBuilder(
      column: $table.mediaUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mediaUrlsJson => $composableBuilder(
      column: $table.mediaUrlsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get waveformJson => $composableBuilder(
      column: $table.waveformJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get uploading => $composableBuilder(
      column: $table.uploading, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get uploadCount => $composableBuilder(
      column: $table.uploadCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reactionsJson => $composableBuilder(
      column: $table.reactionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localMediaPath => $composableBuilder(
      column: $table.localMediaPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sendFailed => $composableBuilder(
      column: $table.sendFailed, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFromAdmin => $composableBuilder(
      column: $table.isFromAdmin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deleted => $composableBuilder(
      column: $table.deleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyToId => $composableBuilder(
      column: $table.replyToId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyToText => $composableBuilder(
      column: $table.replyToText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get replyToSender => $composableBuilder(
      column: $table.replyToSender,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaUrl => $composableBuilder(
      column: $table.mediaUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mediaUrlsJson => $composableBuilder(
      column: $table.mediaUrlsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get waveformJson => $composableBuilder(
      column: $table.waveformJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get uploading => $composableBuilder(
      column: $table.uploading, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get uploadCount => $composableBuilder(
      column: $table.uploadCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reactionsJson => $composableBuilder(
      column: $table.reactionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localMediaPath => $composableBuilder(
      column: $table.localMediaPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sendFailed => $composableBuilder(
      column: $table.sendFailed, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
      column: $table.senderName, builder: (column) => column);

  GeneratedColumn<bool> get isFromAdmin => $composableBuilder(
      column: $table.isFromAdmin, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get textContent => $composableBuilder(
      column: $table.textContent, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get replyToId =>
      $composableBuilder(column: $table.replyToId, builder: (column) => column);

  GeneratedColumn<String> get replyToText => $composableBuilder(
      column: $table.replyToText, builder: (column) => column);

  GeneratedColumn<String> get replyToSender => $composableBuilder(
      column: $table.replyToSender, builder: (column) => column);

  GeneratedColumn<String> get mediaUrl =>
      $composableBuilder(column: $table.mediaUrl, builder: (column) => column);

  GeneratedColumn<String> get mediaUrlsJson => $composableBuilder(
      column: $table.mediaUrlsJson, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get waveformJson => $composableBuilder(
      column: $table.waveformJson, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get uploading =>
      $composableBuilder(column: $table.uploading, builder: (column) => column);

  GeneratedColumn<int> get uploadCount => $composableBuilder(
      column: $table.uploadCount, builder: (column) => column);

  GeneratedColumn<String> get reactionsJson => $composableBuilder(
      column: $table.reactionsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get localMediaPath => $composableBuilder(
      column: $table.localMediaPath, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => column);

  GeneratedColumn<bool> get sendFailed => $composableBuilder(
      column: $table.sendFailed, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> topicId = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<String> senderName = const Value.absent(),
            Value<bool> isFromAdmin = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> textContent = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String> replyToId = const Value.absent(),
            Value<String> replyToText = const Value.absent(),
            Value<String> replyToSender = const Value.absent(),
            Value<String?> mediaUrl = const Value.absent(),
            Value<String?> mediaUrlsJson = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<String?> waveformJson = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<bool> uploading = const Value.absent(),
            Value<int> uploadCount = const Value.absent(),
            Value<String?> reactionsJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> localMediaPath = const Value.absent(),
            Value<bool> pendingSync = const Value.absent(),
            Value<bool> sendFailed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            topicId: topicId,
            senderId: senderId,
            senderName: senderName,
            isFromAdmin: isFromAdmin,
            isRead: isRead,
            type: type,
            textContent: textContent,
            deleted: deleted,
            replyToId: replyToId,
            replyToText: replyToText,
            replyToSender: replyToSender,
            mediaUrl: mediaUrl,
            mediaUrlsJson: mediaUrlsJson,
            durationMs: durationMs,
            orderId: orderId,
            waveformJson: waveformJson,
            sizeBytes: sizeBytes,
            uploading: uploading,
            uploadCount: uploadCount,
            reactionsJson: reactionsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            localMediaPath: localMediaPath,
            pendingSync: pendingSync,
            sendFailed: sendFailed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String topicId,
            required String senderId,
            required String senderName,
            required bool isFromAdmin,
            Value<bool> isRead = const Value.absent(),
            required String type,
            Value<String?> textContent = const Value.absent(),
            Value<bool> deleted = const Value.absent(),
            Value<String> replyToId = const Value.absent(),
            Value<String> replyToText = const Value.absent(),
            Value<String> replyToSender = const Value.absent(),
            Value<String?> mediaUrl = const Value.absent(),
            Value<String?> mediaUrlsJson = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<String?> waveformJson = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<bool> uploading = const Value.absent(),
            Value<int> uploadCount = const Value.absent(),
            Value<String?> reactionsJson = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> localMediaPath = const Value.absent(),
            Value<bool> pendingSync = const Value.absent(),
            Value<bool> sendFailed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            topicId: topicId,
            senderId: senderId,
            senderName: senderName,
            isFromAdmin: isFromAdmin,
            isRead: isRead,
            type: type,
            textContent: textContent,
            deleted: deleted,
            replyToId: replyToId,
            replyToText: replyToText,
            replyToSender: replyToSender,
            mediaUrl: mediaUrl,
            mediaUrlsJson: mediaUrlsJson,
            durationMs: durationMs,
            orderId: orderId,
            waveformJson: waveformJson,
            sizeBytes: sizeBytes,
            uploading: uploading,
            uploadCount: uploadCount,
            reactionsJson: reactionsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            localMediaPath: localMediaPath,
            pendingSync: pendingSync,
            sendFailed: sendFailed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$NotificationRowsTableCreateCompanionBuilder
    = NotificationRowsCompanion Function({
  required String id,
  Value<String> type,
  Value<String> title,
  Value<String> body,
  Value<String> dataJson,
  Value<String> orderId,
  Value<String> topicId,
  Value<bool> read,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$NotificationRowsTableUpdateCompanionBuilder
    = NotificationRowsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> title,
  Value<String> body,
  Value<String> dataJson,
  Value<String> orderId,
  Value<String> topicId,
  Value<bool> read,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$NotificationRowsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationRowsTable> {
  $$NotificationRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataJson => $composableBuilder(
      column: $table.dataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get read => $composableBuilder(
      column: $table.read, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$NotificationRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationRowsTable> {
  $$NotificationRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataJson => $composableBuilder(
      column: $table.dataJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get read => $composableBuilder(
      column: $table.read, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$NotificationRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationRowsTable> {
  $$NotificationRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationRowsTable,
    NotificationRow,
    $$NotificationRowsTableFilterComposer,
    $$NotificationRowsTableOrderingComposer,
    $$NotificationRowsTableAnnotationComposer,
    $$NotificationRowsTableCreateCompanionBuilder,
    $$NotificationRowsTableUpdateCompanionBuilder,
    (
      NotificationRow,
      BaseReferences<_$AppDatabase, $NotificationRowsTable, NotificationRow>
    ),
    NotificationRow,
    PrefetchHooks Function()> {
  $$NotificationRowsTableTableManager(
      _$AppDatabase db, $NotificationRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> dataJson = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<String> topicId = const Value.absent(),
            Value<bool> read = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationRowsCompanion(
            id: id,
            type: type,
            title: title,
            body: body,
            dataJson: dataJson,
            orderId: orderId,
            topicId: topicId,
            read: read,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> dataJson = const Value.absent(),
            Value<String> orderId = const Value.absent(),
            Value<String> topicId = const Value.absent(),
            Value<bool> read = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationRowsCompanion.insert(
            id: id,
            type: type,
            title: title,
            body: body,
            dataJson: dataJson,
            orderId: orderId,
            topicId: topicId,
            read: read,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationRowsTable,
    NotificationRow,
    $$NotificationRowsTableFilterComposer,
    $$NotificationRowsTableOrderingComposer,
    $$NotificationRowsTableAnnotationComposer,
    $$NotificationRowsTableCreateCompanionBuilder,
    $$NotificationRowsTableUpdateCompanionBuilder,
    (
      NotificationRow,
      BaseReferences<_$AppDatabase, $NotificationRowsTable, NotificationRow>
    ),
    NotificationRow,
    PrefetchHooks Function()>;
typedef $$CouponsTableCreateCompanionBuilder = CouponsCompanion Function({
  required String code,
  Value<String> type,
  Value<double> value,
  Value<double> minOrder,
  Value<bool> isActive,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CouponsTableUpdateCompanionBuilder = CouponsCompanion Function({
  Value<String> code,
  Value<String> type,
  Value<double> value,
  Value<double> minOrder,
  Value<bool> isActive,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CouponsTableFilterComposer
    extends Composer<_$AppDatabase, $CouponsTable> {
  $$CouponsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minOrder => $composableBuilder(
      column: $table.minOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CouponsTableOrderingComposer
    extends Composer<_$AppDatabase, $CouponsTable> {
  $$CouponsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minOrder => $composableBuilder(
      column: $table.minOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CouponsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CouponsTable> {
  $$CouponsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<double> get minOrder =>
      $composableBuilder(column: $table.minOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CouponsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CouponsTable,
    Coupon,
    $$CouponsTableFilterComposer,
    $$CouponsTableOrderingComposer,
    $$CouponsTableAnnotationComposer,
    $$CouponsTableCreateCompanionBuilder,
    $$CouponsTableUpdateCompanionBuilder,
    (Coupon, BaseReferences<_$AppDatabase, $CouponsTable, Coupon>),
    Coupon,
    PrefetchHooks Function()> {
  $$CouponsTableTableManager(_$AppDatabase db, $CouponsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CouponsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CouponsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CouponsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> code = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<double> minOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CouponsCompanion(
            code: code,
            type: type,
            value: value,
            minOrder: minOrder,
            isActive: isActive,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String code,
            Value<String> type = const Value.absent(),
            Value<double> value = const Value.absent(),
            Value<double> minOrder = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CouponsCompanion.insert(
            code: code,
            type: type,
            value: value,
            minOrder: minOrder,
            isActive: isActive,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CouponsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CouponsTable,
    Coupon,
    $$CouponsTableFilterComposer,
    $$CouponsTableOrderingComposer,
    $$CouponsTableAnnotationComposer,
    $$CouponsTableCreateCompanionBuilder,
    $$CouponsTableUpdateCompanionBuilder,
    (Coupon, BaseReferences<_$AppDatabase, $CouponsTable, Coupon>),
    Coupon,
    PrefetchHooks Function()>;
typedef $$ShiftsTableCreateCompanionBuilder = ShiftsCompanion Function({
  required String id,
  required String group,
  required DateTime date,
  Value<String> label,
  Value<bool> isOpen,
  Value<int> cancelDaysBefore,
  Value<int> editDaysBefore,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ShiftsTableUpdateCompanionBuilder = ShiftsCompanion Function({
  Value<String> id,
  Value<String> group,
  Value<DateTime> date,
  Value<String> label,
  Value<bool> isOpen,
  Value<int> cancelDaysBefore,
  Value<int> editDaysBefore,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOpen => $composableBuilder(
      column: $table.isOpen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cancelDaysBefore => $composableBuilder(
      column: $table.cancelDaysBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get editDaysBefore => $composableBuilder(
      column: $table.editDaysBefore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOpen => $composableBuilder(
      column: $table.isOpen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cancelDaysBefore => $composableBuilder(
      column: $table.cancelDaysBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get editDaysBefore => $composableBuilder(
      column: $table.editDaysBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get isOpen =>
      $composableBuilder(column: $table.isOpen, builder: (column) => column);

  GeneratedColumn<int> get cancelDaysBefore => $composableBuilder(
      column: $table.cancelDaysBefore, builder: (column) => column);

  GeneratedColumn<int> get editDaysBefore => $composableBuilder(
      column: $table.editDaysBefore, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ShiftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShiftsTable,
    Shift,
    $$ShiftsTableFilterComposer,
    $$ShiftsTableOrderingComposer,
    $$ShiftsTableAnnotationComposer,
    $$ShiftsTableCreateCompanionBuilder,
    $$ShiftsTableUpdateCompanionBuilder,
    (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
    Shift,
    PrefetchHooks Function()> {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> group = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<bool> isOpen = const Value.absent(),
            Value<int> cancelDaysBefore = const Value.absent(),
            Value<int> editDaysBefore = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftsCompanion(
            id: id,
            group: group,
            date: date,
            label: label,
            isOpen: isOpen,
            cancelDaysBefore: cancelDaysBefore,
            editDaysBefore: editDaysBefore,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String group,
            required DateTime date,
            Value<String> label = const Value.absent(),
            Value<bool> isOpen = const Value.absent(),
            Value<int> cancelDaysBefore = const Value.absent(),
            Value<int> editDaysBefore = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftsCompanion.insert(
            id: id,
            group: group,
            date: date,
            label: label,
            isOpen: isOpen,
            cancelDaysBefore: cancelDaysBefore,
            editDaysBefore: editDaysBefore,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShiftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShiftsTable,
    Shift,
    $$ShiftsTableFilterComposer,
    $$ShiftsTableOrderingComposer,
    $$ShiftsTableAnnotationComposer,
    $$ShiftsTableCreateCompanionBuilder,
    $$ShiftsTableUpdateCompanionBuilder,
    (Shift, BaseReferences<_$AppDatabase, $ShiftsTable, Shift>),
    Shift,
    PrefetchHooks Function()>;
typedef $$RegionZonesTableCreateCompanionBuilder = RegionZonesCompanion
    Function({
  required String id,
  required String name,
  Value<int> colorValue,
  Value<String> polygonsJson,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RegionZonesTableUpdateCompanionBuilder = RegionZonesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<int> colorValue,
  Value<String> polygonsJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$RegionZonesTableFilterComposer
    extends Composer<_$AppDatabase, $RegionZonesTable> {
  $$RegionZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get polygonsJson => $composableBuilder(
      column: $table.polygonsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$RegionZonesTableOrderingComposer
    extends Composer<_$AppDatabase, $RegionZonesTable> {
  $$RegionZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get polygonsJson => $composableBuilder(
      column: $table.polygonsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$RegionZonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegionZonesTable> {
  $$RegionZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<String> get polygonsJson => $composableBuilder(
      column: $table.polygonsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RegionZonesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RegionZonesTable,
    RegionZone,
    $$RegionZonesTableFilterComposer,
    $$RegionZonesTableOrderingComposer,
    $$RegionZonesTableAnnotationComposer,
    $$RegionZonesTableCreateCompanionBuilder,
    $$RegionZonesTableUpdateCompanionBuilder,
    (RegionZone, BaseReferences<_$AppDatabase, $RegionZonesTable, RegionZone>),
    RegionZone,
    PrefetchHooks Function()> {
  $$RegionZonesTableTableManager(_$AppDatabase db, $RegionZonesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegionZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegionZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegionZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<String> polygonsJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RegionZonesCompanion(
            id: id,
            name: name,
            colorValue: colorValue,
            polygonsJson: polygonsJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> colorValue = const Value.absent(),
            Value<String> polygonsJson = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RegionZonesCompanion.insert(
            id: id,
            name: name,
            colorValue: colorValue,
            polygonsJson: polygonsJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RegionZonesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RegionZonesTable,
    RegionZone,
    $$RegionZonesTableFilterComposer,
    $$RegionZonesTableOrderingComposer,
    $$RegionZonesTableAnnotationComposer,
    $$RegionZonesTableCreateCompanionBuilder,
    $$RegionZonesTableUpdateCompanionBuilder,
    (RegionZone, BaseReferences<_$AppDatabase, $RegionZonesTable, RegionZone>),
    RegionZone,
    PrefetchHooks Function()>;
typedef $$ApprovalsTableCreateCompanionBuilder = ApprovalsCompanion Function({
  required String id,
  Value<String> type,
  Value<String> changesJson,
  Value<String> status,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ApprovalsTableUpdateCompanionBuilder = ApprovalsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> changesJson,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ApprovalsTableFilterComposer
    extends Composer<_$AppDatabase, $ApprovalsTable> {
  $$ApprovalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changesJson => $composableBuilder(
      column: $table.changesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ApprovalsTableOrderingComposer
    extends Composer<_$AppDatabase, $ApprovalsTable> {
  $$ApprovalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changesJson => $composableBuilder(
      column: $table.changesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ApprovalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApprovalsTable> {
  $$ApprovalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get changesJson => $composableBuilder(
      column: $table.changesJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ApprovalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ApprovalsTable,
    Approval,
    $$ApprovalsTableFilterComposer,
    $$ApprovalsTableOrderingComposer,
    $$ApprovalsTableAnnotationComposer,
    $$ApprovalsTableCreateCompanionBuilder,
    $$ApprovalsTableUpdateCompanionBuilder,
    (Approval, BaseReferences<_$AppDatabase, $ApprovalsTable, Approval>),
    Approval,
    PrefetchHooks Function()> {
  $$ApprovalsTableTableManager(_$AppDatabase db, $ApprovalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApprovalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApprovalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApprovalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> changesJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ApprovalsCompanion(
            id: id,
            type: type,
            changesJson: changesJson,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> type = const Value.absent(),
            Value<String> changesJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ApprovalsCompanion.insert(
            id: id,
            type: type,
            changesJson: changesJson,
            status: status,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ApprovalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ApprovalsTable,
    Approval,
    $$ApprovalsTableFilterComposer,
    $$ApprovalsTableOrderingComposer,
    $$ApprovalsTableAnnotationComposer,
    $$ApprovalsTableCreateCompanionBuilder,
    $$ApprovalsTableUpdateCompanionBuilder,
    (Approval, BaseReferences<_$AppDatabase, $ApprovalsTable, Approval>),
    Approval,
    PrefetchHooks Function()>;
typedef $$PendingMutationsTableCreateCompanionBuilder
    = PendingMutationsCompanion Function({
  Value<int> id,
  required String entityType,
  required String method,
  required String path,
  Value<String> bodyJson,
  Value<String> localRefId,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String> lastError,
});
typedef $$PendingMutationsTableUpdateCompanionBuilder
    = PendingMutationsCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> method,
  Value<String> path,
  Value<String> bodyJson,
  Value<String> localRefId,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String> lastError,
});

class $$PendingMutationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyJson => $composableBuilder(
      column: $table.bodyJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localRefId => $composableBuilder(
      column: $table.localRefId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$PendingMutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyJson => $composableBuilder(
      column: $table.bodyJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localRefId => $composableBuilder(
      column: $table.localRefId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$PendingMutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingMutationsTable> {
  $$PendingMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get bodyJson =>
      $composableBuilder(column: $table.bodyJson, builder: (column) => column);

  GeneratedColumn<String> get localRefId => $composableBuilder(
      column: $table.localRefId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingMutationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingMutationsTable,
    PendingMutation,
    $$PendingMutationsTableFilterComposer,
    $$PendingMutationsTableOrderingComposer,
    $$PendingMutationsTableAnnotationComposer,
    $$PendingMutationsTableCreateCompanionBuilder,
    $$PendingMutationsTableUpdateCompanionBuilder,
    (
      PendingMutation,
      BaseReferences<_$AppDatabase, $PendingMutationsTable, PendingMutation>
    ),
    PendingMutation,
    PrefetchHooks Function()> {
  $$PendingMutationsTableTableManager(
      _$AppDatabase db, $PendingMutationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<String> bodyJson = const Value.absent(),
            Value<String> localRefId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> lastError = const Value.absent(),
          }) =>
              PendingMutationsCompanion(
            id: id,
            entityType: entityType,
            method: method,
            path: path,
            bodyJson: bodyJson,
            localRefId: localRefId,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String method,
            required String path,
            Value<String> bodyJson = const Value.absent(),
            Value<String> localRefId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String> lastError = const Value.absent(),
          }) =>
              PendingMutationsCompanion.insert(
            id: id,
            entityType: entityType,
            method: method,
            path: path,
            bodyJson: bodyJson,
            localRefId: localRefId,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingMutationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingMutationsTable,
    PendingMutation,
    $$PendingMutationsTableFilterComposer,
    $$PendingMutationsTableOrderingComposer,
    $$PendingMutationsTableAnnotationComposer,
    $$PendingMutationsTableCreateCompanionBuilder,
    $$PendingMutationsTableUpdateCompanionBuilder,
    (
      PendingMutation,
      BaseReferences<_$AppDatabase, $PendingMutationsTable, PendingMutation>
    ),
    PendingMutation,
    PrefetchHooks Function()>;
typedef $$SyncCursorsTableCreateCompanionBuilder = SyncCursorsCompanion
    Function({
  required String entity,
  required DateTime since,
  Value<int> rowid,
});
typedef $$SyncCursorsTableUpdateCompanionBuilder = SyncCursorsCompanion
    Function({
  Value<String> entity,
  Value<DateTime> since,
  Value<int> rowid,
});

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get since => $composableBuilder(
      column: $table.since, builder: (column) => ColumnFilters(column));
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get since => $composableBuilder(
      column: $table.since, builder: (column) => ColumnOrderings(column));
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<DateTime> get since =>
      $composableBuilder(column: $table.since, builder: (column) => column);
}

class $$SyncCursorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncCursorsTable,
    SyncCursor,
    $$SyncCursorsTableFilterComposer,
    $$SyncCursorsTableOrderingComposer,
    $$SyncCursorsTableAnnotationComposer,
    $$SyncCursorsTableCreateCompanionBuilder,
    $$SyncCursorsTableUpdateCompanionBuilder,
    (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
    SyncCursor,
    PrefetchHooks Function()> {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entity = const Value.absent(),
            Value<DateTime> since = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsCompanion(
            entity: entity,
            since: since,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entity,
            required DateTime since,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsCompanion.insert(
            entity: entity,
            since: since,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncCursorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncCursorsTable,
    SyncCursor,
    $$SyncCursorsTableFilterComposer,
    $$SyncCursorsTableOrderingComposer,
    $$SyncCursorsTableAnnotationComposer,
    $$SyncCursorsTableCreateCompanionBuilder,
    $$SyncCursorsTableUpdateCompanionBuilder,
    (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
    SyncCursor,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalUserTableTableManager get localUser =>
      $$LocalUserTableTableManager(_db, _db.localUser);
  $$RegistrationDraftsTableTableManager get registrationDrafts =>
      $$RegistrationDraftsTableTableManager(_db, _db.registrationDrafts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$CartItemsTableTableManager get cartItems =>
      $$CartItemsTableTableManager(_db, _db.cartItems);
  $$CartMetaTableTableManager get cartMeta =>
      $$CartMetaTableTableManager(_db, _db.cartMeta);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$OrderItemRowsTableTableManager get orderItemRows =>
      $$OrderItemRowsTableTableManager(_db, _db.orderItemRows);
  $$ChatTopicsTableTableManager get chatTopics =>
      $$ChatTopicsTableTableManager(_db, _db.chatTopics);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$NotificationRowsTableTableManager get notificationRows =>
      $$NotificationRowsTableTableManager(_db, _db.notificationRows);
  $$CouponsTableTableManager get coupons =>
      $$CouponsTableTableManager(_db, _db.coupons);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$RegionZonesTableTableManager get regionZones =>
      $$RegionZonesTableTableManager(_db, _db.regionZones);
  $$ApprovalsTableTableManager get approvals =>
      $$ApprovalsTableTableManager(_db, _db.approvals);
  $$PendingMutationsTableTableManager get pendingMutations =>
      $$PendingMutationsTableTableManager(_db, _db.pendingMutations);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
}
