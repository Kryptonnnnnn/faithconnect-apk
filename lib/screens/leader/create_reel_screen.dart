import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/reel_service.dart';

class CreateReelScreen extends StatefulWidget {
  const CreateReelScreen({super.key});

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen> {
  final _captionCtrl = TextEditingController();
  final _picker = ImagePicker();
  final _service = ReelService();

  File? _videoFile;
  bool _loading = false;

  Future<void> _pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: 60), // enough for short reel
      );

      if (pickedFile != null) {
        setState(() {
          _videoFile = File(pickedFile.path);
        });
      } else {
        // User cancelled picker – do nothing
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick video: $e')),
      );
    }
  }

  Future<void> _uploadReel() async {
    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _service.uploadReel(
        videoFile: _videoFile!,
        caption: _captionCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context); // Back to dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = _videoFile != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Reel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text(hasVideo ? 'Change Video' : 'Pick Video'),
            ),
            if (hasVideo) ...[
              const SizedBox(height: 8),
              const Text(
                'Video selected ✔',
                style: TextStyle(color: Colors.green),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _captionCtrl,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _uploadReel,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload Reel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}