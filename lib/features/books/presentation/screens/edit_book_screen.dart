import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/book_entity.dart';
import '../../../../shared/providers/books_provider.dart';
import '../../../../features/auth/presentation/widgets/auth_text_field.dart';

class EditBookScreen extends StatefulWidget {
  final BookEntity book;

  const EditBookScreen({
    super.key,
    required this.book,
  });

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late BookCondition _selectedCondition;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _selectedCondition = widget.book.condition;
    
    // Listen for changes
    _titleController.addListener(_onFieldChanged);
    _authorController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onConditionChanged(BookCondition? condition) {
    if (condition != null && condition != _selectedCondition) {
      setState(() {
        _selectedCondition = condition;
        _hasChanges = true;
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final booksProvider = context.read<BooksProvider>();

      // Handle image upload if there's a new image
      String? imageUrl = widget.book.imageUrl;
      if (booksProvider.selectedImage != null) {
        // Upload new image - the provider will handle this
        // For now, we'll keep the existing URL
        imageUrl = widget.book.imageUrl;
      }

      final updatedBook = BookEntity(
        id: widget.book.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _selectedCondition,
        imageUrl: imageUrl,
        ownerId: widget.book.ownerId,
        ownerName: widget.book.ownerName,
        createdAt: widget.book.createdAt,
        updatedAt: DateTime.now(),
        isAvailable: widget.book.isAvailable,
        status: widget.book.status,
      );

      await booksProvider.updateBook(updatedBook);

      if (booksProvider.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(booksProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Book Cover'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                context.read<BooksProvider>().pickImage();
                _onFieldChanged();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                context.read<BooksProvider>().takePhoto();
                _onFieldChanged();
              },
            ),
            if (widget.book.imageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Current Image'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<BooksProvider>().clearSelectedImage();
                  _onFieldChanged();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Book'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: _hasChanges ? _handleSubmit : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _hasChanges ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Book Cover Section
                  Consumer<BooksProvider>(
                    builder: (context, booksProvider, child) {
                      return GestureDetector(
                        onTap: _showImagePickerDialog,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Stack(
                            children: [
                              // Image Display
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImageWidget(booksProvider),
                              ),
                              // Edit Overlay
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Title Field
                  AuthTextField(
                    controller: _titleController,
                    labelText: 'Book Title',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the book title';
                      }
                      if (value.trim().length < 2) {
                        return 'Title must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Author Field
                  AuthTextField(
                    controller: _authorController,
                    labelText: 'Author',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the author name';
                      }
                      if (value.trim().length < 2) {
                        return 'Author name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Condition Dropdown
                  DropdownButtonFormField<BookCondition>(
                    value: _selectedCondition,
                    decoration: InputDecoration(
                      labelText: 'Condition',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    items: BookCondition.values.map((condition) {
                      return DropdownMenuItem(
                        value: condition,
                        child: Text(condition.displayName),
                      );
                    }).toList(),
                    onChanged: _onConditionChanged,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Consumer<BooksProvider>(
                    builder: (context, booksProvider, child) {
                      return ElevatedButton(
                        onPressed: booksProvider.isLoading || !_hasChanges
                            ? null
                            : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: booksProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _hasChanges ? 'Update Book' : 'No Changes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(BooksProvider booksProvider) {
    // Priority: new selected image > existing image > placeholder
    if (booksProvider.selectedImage != null) {
      return Image.file(
        booksProvider.selectedImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (widget.book.imageUrl != null) {
      return Image.network(
        widget.book.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to update cover',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
