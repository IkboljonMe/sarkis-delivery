import 'package:flutter/material.dart';

import '../../models/delivery_date_model.dart';
import '../../utils/constants.dart';

/// Dialog to create a new delivery date. Returns a [DeliveryDateModel] or null.
class AddDateDialog extends StatefulWidget {
  const AddDateDialog({super.key});

  @override
  State<AddDateDialog> createState() => _AddDateDialogState();
}

class _AddDateDialogState extends State<AddDateDialog> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  String _group = AppConstants.groupBerlin;
  bool _isOpen = true;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новая дата доставки'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: Text(
                '${_date.day}.${_date.month}.${_date.year}'),
            trailing: TextButton(
                onPressed: _pickDate, child: const Text('Выбрать')),
          ),
          DropdownButtonFormField<String>(
            value: _group,
            decoration: const InputDecoration(labelText: 'Группа'),
            items: AppConstants.groups
                .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(AppConstants.groupLabelsRu[g] ?? g),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _group = v!),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Открыта для заказов'),
            value: _isOpen,
            onChanged: (v) => setState(() => _isOpen = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              DeliveryDateModel(
                id: '',
                date: _date,
                group: _group,
                isOpen: _isOpen,
              ),
            );
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}
