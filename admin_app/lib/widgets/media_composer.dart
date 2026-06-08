import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'golden_button.dart';

class MediaComposerResult {
  final List<XFile> files;
  final String caption;
  MediaComposerResult(this.files, this.caption);
}

/// Telegram-style media composer: preview the selected photos, remove any,
/// add more, type a caption, then send. Returns a [MediaComposerResult] (or
/// null if cancelled) via Navigator.pop.
class MediaComposer extends StatefulWidget {
  final List<XFile> initial;
  const MediaComposer({super.key, required this.initial});

  @override
  State<MediaComposer> createState() => _MediaComposerState();
}

class _MediaComposerState extends State<MediaComposer> {
  late final List<XFile> _files = [...widget.initial];
  final _caption = TextEditingController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _addMore() async {
    final more = await _picker.pickMultiImage(imageQuality: 70, maxWidth: 1600);
    if (more.isNotEmpty) setState(() => _files.addAll(more));
  }

  void _remove(int i) {
    setState(() => _files.removeAt(i));
    if (_files.isEmpty) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${_files.length} фото'),
        actions: [
          IconButton(
              onPressed: _addMore,
              icon: const Icon(Icons.add_photo_alternate_outlined)),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _files.length,
        itemBuilder: (context, i) => _tile(i),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _caption,
                  style: AppTextStyles.body,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Подпись…'),
                ),
              ),
              const SizedBox(width: 8),
              GoldenButton(
                label: 'Отправить',
                height: 48,
                onPressed: () => Navigator.pop(
                    context, MediaComposerResult(_files, _caption.text.trim())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(int i) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _Thumb(file: _files[i]),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _remove(i),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final XFile file;
  const _Thumb({required this.file});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container(color: AppColors.surfaceElevated);
        }
        return Image.memory(snap.data!, fit: BoxFit.cover);
      },
    );
  }
}
