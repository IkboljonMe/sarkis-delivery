import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Mirror of the signed-in staff member's own `User` row.
class LocalUser extends Table {
  TextColumn get id => text()();
  TextColumn get role => text().withDefault(const Constant('ADMIN'))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get nameJson => text().withDefault(const Constant('{}'))();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get nameJson => text().withDefault(const Constant('{}'))();
  TextColumn get descriptionJson => text().withDefault(const Constant('{}'))();
  RealColumn get price => real()();
  TextColumn get unit => text().withDefault(const Constant(''))();
  IntColumn get maxQty => integer().withDefault(const Constant(0))();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  TextColumn get imagesJson => text().withDefault(const Constant('[]'))();
  TextColumn get photosJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get discountType => text().withDefault(const Constant('none'))();
  RealColumn get discountValue => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Every order in the staff member's operating scope (today: unfiltered —
/// the app has no role-based order filtering, see plan.md non-goals).
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get status => text()();
  TextColumn get driverId => text().withDefault(const Constant(''))();
  TextColumn get driverName => text().withDefault(const Constant(''))();
  TextColumn get shiftId => text().withDefault(const Constant(''))();
  DateTimeColumn get shiftDate => dateTime().nullable()();
  TextColumn get shiftLabel => text().withDefault(const Constant(''))();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  TextColumn get couponCode => text().withDefault(const Constant(''))();
  RealColumn get totalPrice => real().withDefault(const Constant(0))();
  TextColumn get userName => text().withDefault(const Constant(''))();
  TextColumn get userPhone => text().withDefault(const Constant(''))();
  TextColumn get userAddress => text().withDefault(const Constant(''))();
  TextColumn get userCity => text().withDefault(const Constant(''))();
  TextColumn get userGroup => text().withDefault(const Constant(''))();
  TextColumn get adminNote => text().withDefault(const Constant(''))();
  BoolColumn get pendingApproval => boolean().withDefault(const Constant(false))();
  BoolColumn get awaitingSchedule => boolean().withDefault(const Constant(false))();
  BoolColumn get cashCollected => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class OrderItemRows extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text()();
  TextColumn get productId => text().withDefault(const Constant(''))();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get qty => integer()();
  RealColumn get unitPrice => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// All customer chat topics (staff sees every conversation, unlike the
/// customer app which only ever has its own one topic).
class ChatTopics extends Table {
  TextColumn get id => text()();
  TextColumn get userName => text().withDefault(const Constant(''))();
  TextColumn get userGroup => text().withDefault(const Constant(''))();
  TextColumn get lastMessage => text().withDefault(const Constant(''))();
  DateTimeColumn get lastAt => dateTime().nullable()();
  BoolColumn get lastFromAdmin => boolean().withDefault(const Constant(false))();
  IntColumn get adminUnread => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text()();
  TextColumn get senderId => text()();
  TextColumn get senderName => text().withDefault(const Constant(''))();
  BoolColumn get isFromAdmin => boolean().withDefault(const Constant(false))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withDefault(const Constant('text'))();
  TextColumn get content => text().withDefault(const Constant(''))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get extraJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get localMediaPath => text().withDefault(const Constant(''))();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
  // Set when the server rejected this optimistic message (non-connectivity
  // failure) so the bubble can show a "failed — tap to retry" state.
  BoolColumn get sendFailed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class NotificationRows extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().withDefault(const Constant('system'))();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get dataJson => text().withDefault(const Constant('{}'))();
  TextColumn get orderId => text().withDefault(const Constant(''))();
  TextColumn get topicId => text().withDefault(const Constant(''))();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Coupons extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get type => text().withDefault(const Constant('percent'))();
  RealColumn get value => real().withDefault(const Constant(0))();
  RealColumn get minOrder => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get usageLimit => integer().withDefault(const Constant(0))();
  IntColumn get usedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get group => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get label => text().withDefault(const Constant(''))();
  BoolColumn get isOpen => boolean().withDefault(const Constant(true))();
  IntColumn get cancelDaysBefore => integer().withDefault(const Constant(1))();
  IntColumn get editDaysBefore => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class RegionZones extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().withDefault(const Constant(0))();
  TextColumn get polygonsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// All pending/resolved profile-change approvals (staff sees every request).
class Approvals extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().withDefault(const Constant('profile'))();
  TextColumn get userId => text()();
  TextColumn get userName => text().withDefault(const Constant(''))();
  TextColumn get changesJson => text().withDefault(const Constant('{}'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PendingMutations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get method => text()();
  TextColumn get path => text()();
  TextColumn get bodyJson => text().withDefault(const Constant('{}'))();
  TextColumn get localRefId => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().withDefault(const Constant(''))();
}

class SyncCursors extends Table {
  TextColumn get entity => text()();
  DateTimeColumn get since => dateTime()();

  @override
  Set<Column> get primaryKey => {entity};
}

@DriftDatabase(tables: [
  LocalUser,
  Categories,
  Products,
  Orders,
  OrderItemRows,
  ChatTopics,
  Messages,
  NotificationRows,
  Coupons,
  Shifts,
  RegionZones,
  Approvals,
  PendingMutations,
  SyncCursors,
])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase instance = AppDatabase();
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(messages, messages.sendFailed);
          }
        },
      );

  Future<void> wipeAll() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'sarko_admin.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
