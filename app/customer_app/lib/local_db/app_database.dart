import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Mirror of the server's own `User` row for the signed-in customer — a
/// single-row table (id doubles as primary key) so `watch()` on it gives the
/// UI a reactive "current profile" stream instead of the old in-memory-only
/// `ApiClient.currentUser` map.
class LocalUser extends Table {
  TextColumn get id => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get email => text().withDefault(const Constant(''))();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get postalCode => text().withDefault(const Constant(''))();
  TextColumn get group => text().withDefault(const Constant(''))();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get photoUrl => text().withDefault(const Constant(''))();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class RegistrationDrafts extends Table {
  TextColumn get id => text().withDefault(const Constant('draft'))();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  TextColumn get referredBy => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get postalCode => text().withDefault(const Constant(''))();
  TextColumn get groupName => text().withDefault(const Constant(''))();
  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();
  TextColumn get language => text().withDefault(const Constant('en'))();

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
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get discountType => text().withDefault(const Constant('none'))();
  RealColumn get discountValue => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Replaces the partial `shared_preferences` cart blob (`cart_provider.dart`)
/// which today loses the selected shift/coupon on restart.
class CartItems extends Table {
  TextColumn get productId => text()();
  IntColumn get qty => integer()();

  @override
  Set<Column> get primaryKey => {productId};
}

/// Single-row table for cart-level selections that aren't per-item.
class CartMeta extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  TextColumn get shiftId => text().withDefault(const Constant(''))();
  TextColumn get couponCode => text().withDefault(const Constant(''))();
  TextColumn get editingOrderId => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get status => text()();
  TextColumn get driverId => text().withDefault(const Constant(''))();
  TextColumn get shiftId => text().withDefault(const Constant(''))();
  DateTimeColumn get shiftDate => dateTime().nullable()();
  TextColumn get shiftLabel => text().withDefault(const Constant(''))();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  TextColumn get couponCode => text().withDefault(const Constant(''))();
  RealColumn get totalPrice => real().withDefault(const Constant(0))();
  TextColumn get userName => text().withDefault(const Constant(''))();
  TextColumn get userAddress => text().withDefault(const Constant(''))();
  TextColumn get userCity => text().withDefault(const Constant(''))();
  TextColumn get adminNote => text().withDefault(const Constant(''))();
  BoolColumn get pendingApproval => boolean().withDefault(const Constant(false))();
  BoolColumn get awaitingSchedule => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  // Set on optimistic local writes (place/edit order) until the server ack
  // lands and reconciles this row — see MutationQueue.
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class OrderItemRows extends Table {
  TextColumn get id => text()(); // server id, or `local_<orderId>_<productId>` for optimistic rows
  TextColumn get orderId => text()();
  TextColumn get productId => text().withDefault(const Constant(''))();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get qty => integer()();
  RealColumn get unitPrice => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class ChatTopics extends Table {
  TextColumn get id => text()(); // == customer userId
  TextColumn get userName => text().withDefault(const Constant(''))();
  TextColumn get lastMessage => text().withDefault(const Constant(''))();
  DateTimeColumn get lastAt => dateTime().nullable()();
  BoolColumn get lastFromAdmin => boolean().withDefault(const Constant(false))();
  IntColumn get customerUnread => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text()();
  TextColumn get senderId => text()();
  TextColumn get senderName => text()();
  BoolColumn get isFromAdmin => boolean()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get type => text()();
  // Named `textContent`, not `text` — `text` collides with Drift's
  // TextColumn builder method on this class and breaks codegen.
  TextColumn get textContent => text().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get replyToId => text().withDefault(const Constant(''))();
  TextColumn get replyToText => text().withDefault(const Constant(''))();
  TextColumn get replyToSender => text().withDefault(const Constant(''))();
  TextColumn get mediaUrl => text().nullable()();
  TextColumn get mediaUrlsJson => text().nullable()();
  IntColumn get durationMs => integer().withDefault(const Constant(0))();
  TextColumn get orderId => text().withDefault(const Constant(''))();
  TextColumn get waveformJson => text().nullable()();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  BoolColumn get uploading => boolean().withDefault(const Constant(false))();
  IntColumn get uploadCount => integer().withDefault(const Constant(0))();
  TextColumn get reactionsJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  // Local media path cache for offline viewing, keyed by original mediaUrl.
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
  TextColumn get code => text()();
  TextColumn get type => text().withDefault(const Constant('percent'))();
  RealColumn get value => real().withDefault(const Constant(0))();
  RealColumn get minOrder => real().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {code};
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

  @override
  Set<Column> get primaryKey => {id};
}

class RegionZones extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer().withDefault(const Constant(0))();
  TextColumn get polygonsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Approvals extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().withDefault(const Constant('profile'))();
  TextColumn get changesJson => text().withDefault(const Constant('{}'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Offline write queue: any mutating call that fails due to connectivity is
/// recorded here (with the local row it optimistically wrote already applied)
/// and replayed FIFO by MutationQueue once connectivity returns.
class PendingMutations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // order | message | profile | ...
  TextColumn get method => text()(); // POST | PATCH | DELETE
  TextColumn get path => text()();
  TextColumn get bodyJson => text().withDefault(const Constant('{}'))();
  TextColumn get localRefId => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().withDefault(const Constant(''))();
}

/// Per-table `since` watermark so SyncEngine's delta pulls (and reconnect
/// catch-up) know where they left off. Column named `entity`, not
/// `tableName` — `tableName` collides with Table's own tableName override
/// getter and breaks codegen.
class SyncCursors extends Table {
  TextColumn get entity => text()();
  DateTimeColumn get since => dateTime()();

  @override
  Set<Column> get primaryKey => {entity};
}

@DriftDatabase(tables: [
  LocalUser,
  RegistrationDrafts,
  Categories,
  Products,
  CartItems,
  CartMeta,
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
  AppDatabase._() : super(_openConnection());
  static final AppDatabase instance = AppDatabase._();

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

  /// Wipes every table — called on logout so nothing from the previous
  /// account lingers locally.
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
    final file = File(p.join(dir.path, 'sarko_customer.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
