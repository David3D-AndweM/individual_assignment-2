import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/books/domain/entities/book_entity.dart';
import '../../features/books/domain/repositories/books_repository.dart';
import '../../features/books/data/repositories/books_repository_impl.dart';

class BooksProvider extends ChangeNotifier {
  final BooksRepository _booksRepository;
  final ImagePicker _imagePicker = ImagePicker();
  
  List<BookEntity> _allBooks = [];
  List<BookEntity> _userBooks = [];
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;

  BooksProvider()
      : _booksRepository = BooksRepositoryImpl(
          firestore: FirebaseFirestore.instance,
          storage: FirebaseStorage.instance,
        ) {
    _initializeBooksStream();
  }

  List<BookEntity> get allBooks => _allBooks;
  List<BookEntity> get userBooks => _userBooks;
  List<BookEntity> get books => _allBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get selectedImage => _selectedImage;

  void _initializeBooksStream() {
    _booksRepository.getBooksStream().listen((books) {
      _allBooks = books;
      notifyListeners();
    });
  }

  void initializeUserBooksStream(String userId) {
    _booksRepository.getUserBooksStream(userId).listen((books) {
      _userBooks = books;
      notifyListeners();
    });
  }

  Future<void> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    String? bookImageUrl,
    required String ownerId,
    required String ownerName,
    required String requesterId,
    required String requesterName,
    String? message,
  }) async {
    // This method would typically call a swaps repository
    // For now, just a placeholder
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _booksRepository.getAllBooks();
      result.fold(
        (failure) {
          _errorMessage = failure.message;
        },
        (books) {
          _allBooks = books;
          _errorMessage = null;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to load books: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBook({
    required String title,
    required String author,
    required BookCondition condition,
    required String ownerId,
    required String ownerName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      String? imageUrl;
      
      // Upload image if selected
      if (_selectedImage != null) {
        final fileName = 'books/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      final now = DateTime.now();
      final book = BookEntity(
        id: '', // Will be set by Firestore
        title: title,
        author: author,
        condition: condition,
        imageUrl: imageUrl,
        ownerId: ownerId,
        ownerName: ownerName,
        createdAt: now,
        updatedAt: now,
        isAvailable: true,
        status: BookStatus.available,
      );

      final result = await _booksRepository.createBook(book);
      
      result.fold(
        (failure) => _setError(failure.message),
        (bookId) {
          _selectedImage = null; // Clear selected image
          // Books will be updated via stream
        },
      );
    } catch (e) {
      _setError('Failed to create book: $e');
    }

    _setLoading(false);
  }

  Future<void> updateBook(BookEntity book) async {
    _setLoading(true);
    _clearError();

    final updatedBook = BookEntity(
      id: book.id,
      title: book.title,
      author: book.author,
      condition: book.condition,
      imageUrl: book.imageUrl,
      ownerId: book.ownerId,
      ownerName: book.ownerName,
      createdAt: book.createdAt,
      updatedAt: DateTime.now(),
      isAvailable: book.isAvailable,
      status: book.status,
    );

    final result = await _booksRepository.updateBook(updatedBook);
    
    result.fold(
      (failure) => _setError(failure.message),
      (_) {
        // Books will be updated via stream
      },
    );

    _setLoading(false);
  }

  Future<void> deleteBook(String bookId) async {
    _setLoading(true);
    _clearError();

    final result = await _booksRepository.deleteBook(bookId);
    
    result.fold(
      (failure) => _setError(failure.message),
      (_) {
        // Books will be updated via stream
      },
    );

    _setLoading(false);
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pick image: $e');
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        _selectedImage = File(image.path);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to take photo: $e');
    }
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}