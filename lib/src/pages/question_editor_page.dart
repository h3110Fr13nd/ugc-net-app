import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/composite_question.dart';
import '../services/composite_question_service.dart';
import '../services/api_client.dart';
import '../services/media_service.dart';

/// Page for creating/editing composite questions
class QuestionEditorPage extends StatefulWidget {
  final CompositeQuestion? existingQuestion;

  const QuestionEditorPage({super.key, this.existingQuestion});

  @override
  State<QuestionEditorPage> createState() => _QuestionEditorPageState();
}

class _QuestionEditorPageState extends State<QuestionEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mediaService = MediaService(ApiClient());
  final _imagePicker = ImagePicker();

  AnswerType _answerType = AnswerType.options;
  int? _difficulty;
  int? _estimatedTimeSeconds;
  bool _isUploading = false;

  final List<_QuestionPartData> _questionParts = [];
  final List<_OptionData> _options = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingQuestion != null) {
      _loadExistingQuestion();
    } else {
      // Start with one text part
      _questionParts.add(_QuestionPartData(index: 0, partType: PartType.text));
    }
  }

  void _loadExistingQuestion() {
    final q = widget.existingQuestion!;
    _titleController.text = q.title ?? '';
    _descriptionController.text = q.description ?? '';
    _answerType = q.answerType;
    _difficulty = q.difficulty;
    _estimatedTimeSeconds = q.estimatedTimeSeconds;

    for (var i = 0; i < q.parts.length; i++) {
      final part = q.parts[i];
      _questionParts.add(_QuestionPartData(
        index: i,
        partType: part.partType,
        contentController: TextEditingController(text: part.content ?? ''),
        mediaId: part.mediaId,
        uploadedMedia: part.media,
      ));
    }

    for (var i = 0; i < q.options.length; i++) {
      final option = q.options[i];
      _options.add(_OptionData(
        index: i,
        labelController: TextEditingController(text: option.label ?? ''),
        isCorrect: option.isCorrect,
        parts: option.parts.map((p) => _OptionPartData(
          index: p.index,
          partType: p.partType,
          contentController: TextEditingController(text: p.content ?? ''),
        )).toList(),
      ));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var part in _questionParts) {
      part.contentController.dispose();
    }
    for (var option in _options) {
      option.labelController.dispose();
      for (var part in option.parts) {
        part.contentController.dispose();
      }
    }
    super.dispose();
  }

  void _addQuestionPart(PartType type) {
    setState(() {
      _questionParts.add(_QuestionPartData(
        index: _questionParts.length,
        partType: type,
      ));
    });
  }

  void _removeQuestionPart(int index) {
    setState(() {
      _questionParts[index].contentController.dispose();
      _questionParts.removeAt(index);
      // Re-index
      for (var i = 0; i < _questionParts.length; i++) {
        _questionParts[i].index = i;
      }
    });
  }

  void _addOption() {
    setState(() {
      final label = String.fromCharCode(65 + _options.length); // A, B, C, D...
      _options.add(_OptionData(
        index: _options.length,
        labelController: TextEditingController(text: label),
        parts: [_OptionPartData(index: 0, partType: PartType.text)],
      ));
    });
  }

  void _removeOption(int index) {
    setState(() {
      final option = _options[index];
      option.labelController.dispose();
      for (var part in option.parts) {
        part.contentController.dispose();
      }
      _options.removeAt(index);
      // Re-index
      for (var i = 0; i < _options.length; i++) {
        _options[i].index = i;
      }
    });
  }

  void _addOptionPart(int optionIndex, PartType type) {
    setState(() {
      _options[optionIndex].parts.add(_OptionPartData(
        index: _options[optionIndex].parts.length,
        partType: type,
      ));
    });
  }

  void _removeOptionPart(int optionIndex, int partIndex) {
    setState(() {
      _options[optionIndex].parts[partIndex].contentController.dispose();
      _options[optionIndex].parts.removeAt(partIndex);
      // Re-index
      for (var i = 0; i < _options[optionIndex].parts.length; i++) {
        _options[optionIndex].parts[i].index = i;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingQuestion == null ? 'Create Question' : 'Edit Question'),
        actions: [
          TextButton.icon(
            onPressed: _saveQuestion,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic info
            _buildBasicInfoSection(),
            const SizedBox(height: 24),

            // Question parts
            _buildQuestionPartsSection(),
            const SizedBox(height: 24),

            // Options (if answer type is options)
            if (_answerType == AnswerType.options) ...[
              _buildOptionsSection(),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AnswerType>(
              initialValue: _answerType,
              decoration: const InputDecoration(
                labelText: 'Answer Type',
                border: OutlineInputBorder(),
              ),
              items: AnswerType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _answerType = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Difficulty (1-5)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _difficulty?.toString(),
                    onChanged: (value) {
                      _difficulty = int.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Est. time (seconds)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _estimatedTimeSeconds?.toString(),
                    onChanged: (value) {
                      _estimatedTimeSeconds = int.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPartsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question Parts', style: Theme.of(context).textTheme.titleLarge),
                PopupMenuButton<PartType>(
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'Add part',
                  onSelected: _addQuestionPart,
                  itemBuilder: (context) {
                    return PartType.values.map((type) {
                      return PopupMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getPartTypeIcon(type), size: 18),
                            const SizedBox(width: 8),
                            Text('Add ${type.name}'),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._questionParts.asMap().entries.map((entry) {
              final index = entry.key;
              final part = entry.value;
              return _buildQuestionPartEditor(index, part);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPartEditor(int index, _QuestionPartData part) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getPartTypeIcon(part.partType), size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Part ${index + 1}: ${part.partType.name}'),
                  backgroundColor: colorScheme.secondaryContainer,
                  labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
                ),
                const Spacer(),
                IconButton.outlined(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove part',
                  iconSize: 20,
                  color: colorScheme.error,
                  onPressed: () => _removeQuestionPart(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (part.partType == PartType.text || part.partType == PartType.latex || part.partType == PartType.code)
              TextFormField(
                controller: part.contentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintText: part.partType == PartType.code
                      ? 'Enter code...'
                      : part.partType == PartType.latex
                          ? 'Enter LaTeX...'
                          : 'Enter text...',
                ),
                maxLines: part.partType == PartType.text ? 3 : 5,
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(4),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.upload_file, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            part.uploadedMedia != null 
                                ? 'Uploaded: ${part.uploadedMedia!.url.split('/').last}'
                                : 'Upload ${part.partType.name}...', 
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: part.uploadedMedia != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isUploading ? null : () => _handleFileUpload(index),
                          icon: _isUploading 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(part.uploadedMedia != null ? Icons.refresh : Icons.cloud_upload),
                          label: Text(_isUploading ? 'Uploading...' : (part.uploadedMedia != null ? 'Change' : 'Upload')),
                        ),
                      ],
                    ),
                    if (part.uploadedMedia != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'File ready: ${(part.uploadedMedia!.sizeBytes ?? 0) ~/ 1024} KB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Answer Options', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Option'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return _buildOptionEditor(index, option);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionEditor(int optionIndex, _OptionData option) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: option.isCorrect 
          ? colorScheme.primaryContainer.withValues(alpha: 0.3)
          : colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with label and actions
            Row(
              children: [
                // Option label input
                SizedBox(
                  width: 70,
                  child: TextFormField(
                    controller: option.labelController,
                    decoration: const InputDecoration(
                      labelText: 'Label',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      isDense: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Correct answer checkbox
                InkWell(
                  onTap: () {
                    setState(() {
                      option.isCorrect = !option.isCorrect;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: option.isCorrect 
                            ? colorScheme.primary 
                            : colorScheme.outline,
                        width: option.isCorrect ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: option.isCorrect 
                          ? colorScheme.primaryContainer 
                          : Colors.transparent,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          option.isCorrect ? Icons.check_circle : Icons.circle_outlined,
                          size: 20,
                          color: option.isCorrect 
                              ? colorScheme.primary 
                              : colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          option.isCorrect ? 'Correct' : 'Wrong',
                          style: TextStyle(
                            fontWeight: option.isCorrect ? FontWeight.bold : FontWeight.normal,
                            color: option.isCorrect 
                                ? colorScheme.primary 
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                
                // Add part button
                IconButton.outlined(
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add part',
                  iconSize: 20,
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        MediaQuery.of(context).size.width - 200,
                        kToolbarHeight,
                        20,
                        0,
                      ),
                      items: [PartType.text, PartType.image, PartType.latex].map((type) {
                        return PopupMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(_getPartTypeIcon(type), size: 18),
                              const SizedBox(width: 8),
                              Text('Add ${type.name}'),
                            ],
                          ),
                          onTap: () => _addOptionPart(optionIndex, type),
                        );
                      }).toList(),
                    );
                  },
                ),
                
                // Delete button
                IconButton.outlined(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete option',
                  iconSize: 20,
                  color: colorScheme.error,
                  onPressed: () => _removeOption(optionIndex),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Option parts
            ...option.parts.asMap().entries.map((partEntry) {
              final partIndex = partEntry.key;
              final part = partEntry.value;
              return _buildOptionPartEditor(optionIndex, partIndex, part);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionPartEditor(int optionIndex, int partIndex, _OptionPartData part) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 0,
      color: colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(_getPartTypeIcon(part.partType), size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Chip(
              label: Text(part.partType.name),
              visualDensity: VisualDensity.compact,
              backgroundColor: colorScheme.tertiaryContainer,
              labelStyle: TextStyle(
                color: colorScheme.onTertiaryContainer,
                fontSize: 12,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: part.partType == PartType.text || part.partType == PartType.latex
                  ? TextFormField(
                      controller: part.contentController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: colorScheme.surface,
                        hintText: part.partType == PartType.latex 
                            ? 'LaTeX formula...' 
                            : 'Option text...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.upload_file, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            'Media upload (not implemented)',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Remove',
              color: colorScheme.error,
              onPressed: () => _removeOptionPart(optionIndex, partIndex),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation
    if (_questionParts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one question part'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_answerType == AnswerType.options && _options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one option for multiple choice questions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if any option has no parts
    if (_answerType == AnswerType.options) {
      for (int i = 0; i < _options.length; i++) {
        if (_options[i].parts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Option ${_options[i].labelController.text} has no content. Please add at least one part.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }
    }

    // Show loading
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving question...'), duration: Duration(seconds: 1)),
    );

    try {
      final now = DateTime.now();
      
      // Build the question object
      final question = CompositeQuestion(
        id: widget.existingQuestion?.id ?? '',
        title: _titleController.text.isEmpty ? null : _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        answerType: _answerType,
        difficulty: _difficulty,
        estimatedTimeSeconds: _estimatedTimeSeconds,
        parts: _questionParts.map((part) => QuestionPart(
          id: '',
          questionId: '',
          index: part.index,
          partType: part.partType,
          content: part.contentController.text.isEmpty ? null : part.contentController.text,
          mediaId: part.mediaId,
        )).toList(),
        options: _options.map((option) => QuestionOption(
          id: '',
          questionId: '',
          label: option.labelController.text.isEmpty ? null : option.labelController.text,
          index: option.index,
          isCorrect: option.isCorrect,
          parts: option.parts.map((part) => OptionPart(
            id: '',
            optionId: '',
            index: part.index,
            partType: part.partType,
            content: part.contentController.text.isEmpty ? null : part.contentController.text,
          )).toList(),
          createdAt: now,
          updatedAt: now,
        )).toList(),
        createdAt: now,
        updatedAt: now,
      );

      // Call the API
      final service = CompositeQuestionService(ApiClient());
      final savedQuestion = widget.existingQuestion == null
          ? await service.createQuestion(question)
          : await service.updateQuestion(widget.existingQuestion!.id, question);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Question ${widget.existingQuestion == null ? "created" : "updated"} successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.of(context).pop(savedQuestion);
    } catch (e, stackTrace) {
      print('Error saving question: $e');
      print('Stack trace: $stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving question: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleFileUpload(int partIndex) async {
    final part = _questionParts[partIndex];
    
    try {
      setState(() => _isUploading = true);
      
      Media? uploadedMedia;
      
      // Handle different file types
      switch (part.partType) {
        case PartType.image:
        case PartType.diagram:
          // Pick image
          final pickedFile = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1920,
          );
          
          if (pickedFile != null) {
            final file = File(pickedFile.path);
            uploadedMedia = await _mediaService.uploadImage(file);
          }
          
        case PartType.video:
          // Pick video
          final result = await FilePicker.platform.pickFiles(
            type: FileType.video,
            allowMultiple: false,
          );
          
          if (result != null && result.files.single.path != null) {
            final file = File(result.files.single.path!);
            uploadedMedia = await _mediaService.uploadFile(file, mimeType: 'video/mp4');
          }
          
        case PartType.audio:
          // Pick audio
          final result = await FilePicker.platform.pickFiles(
            type: FileType.audio,
            allowMultiple: false,
          );
          
          if (result != null && result.files.single.path != null) {
            final file = File(result.files.single.path!);
            uploadedMedia = await _mediaService.uploadFile(file);
          }
          
        default:
          // Pick any file
          final result = await FilePicker.platform.pickFiles(
            allowMultiple: false,
          );
          
          if (result != null && result.files.single.path != null) {
            final file = File(result.files.single.path!);
            uploadedMedia = await _mediaService.uploadFile(file);
          }
      }
      
      if (uploadedMedia != null) {
        setState(() {
          part.uploadedMedia = uploadedMedia;
          part.mediaId = uploadedMedia!.id;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Helper method to get icon for part type
  IconData _getPartTypeIcon(PartType type) {
    switch (type) {
      case PartType.text:
        return Icons.text_fields;
      case PartType.image:
        return Icons.image;
      case PartType.diagram:
        return Icons.account_tree;
      case PartType.latex:
        return Icons.functions;
      case PartType.code:
        return Icons.code;
      case PartType.audio:
        return Icons.audiotrack;
      case PartType.video:
        return Icons.video_library;
      case PartType.table:
        return Icons.table_chart;
    }
  }
}

// Helper classes to manage editor state
class _QuestionPartData {
  int index;
  PartType partType;
  TextEditingController contentController;
  String? mediaId;
  Media? uploadedMedia;

  _QuestionPartData({
    required this.index,
    required this.partType,
    TextEditingController? contentController,
    this.mediaId,
    this.uploadedMedia,
  }) : contentController = contentController ?? TextEditingController();
}

class _OptionData {
  int index;
  TextEditingController labelController;
  bool isCorrect;
  List<_OptionPartData> parts;

  _OptionData({
    required this.index,
    required this.labelController,
    this.isCorrect = false,
    required this.parts,
  });
}

class _OptionPartData {
  int index;
  PartType partType;
  TextEditingController contentController;

  _OptionPartData({
    required this.index,
    required this.partType,
    TextEditingController? contentController,
  }) : contentController = contentController ?? TextEditingController();
}
