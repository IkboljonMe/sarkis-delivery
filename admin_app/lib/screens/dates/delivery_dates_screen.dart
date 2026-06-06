import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../models/delivery_date_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import 'add_date_dialog.dart';

class DeliveryDatesScreen extends StatelessWidget {
  const DeliveryDatesScreen({super.key});

  Future<void> _addDate(BuildContext context) async {
    final result = await showDialog<DeliveryDateModel>(
      context: context,
      builder: (_) => const AddDateDialog(),
    );
    if (result != null) {
      try {
        await FirebaseService.instance.addDeliveryDate(result);
        Fluttertoast.showToast(msg: 'Дата добавлена');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Ошибка: $e');
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить дату?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Удалить')),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseService.instance.deleteDeliveryDate(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Даты доставки')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addDate(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<DeliveryDateModel>>(
        stream: FirebaseService.instance.allDeliveryDatesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final dates = snapshot.data ?? [];
          if (dates.isEmpty) {
            return const Center(
                child: Text('Нет дат доставки. Нажмите +'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: dates.length,
            itemBuilder: (context, i) {
              final d = dates[i];
              final label = DateFormat('EEE, d MMM yyyy').format(d.date);
              return Card(
                child: ListTile(
                  title: Text(label),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E7D2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                            AppConstants.groupLabelsRu[d.group] ?? d.group),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: d.isOpen,
                        onChanged: (v) => FirebaseService.instance
                            .setDeliveryDateOpen(d.id, v),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () => _confirmDelete(context, d.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
