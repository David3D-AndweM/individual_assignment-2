import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/books_repository.dart';
import '../models/book_model.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/firebase_constants.dart';

class BooksRepositoryImpl implements BooksRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  BooksRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  @override
  Future<Either<Failure, String>> createBook(BookEntity book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      final docRef = await _firestore
          .collection(FirebaseConstants.booksCollection)
          .add(bookModel.toFirestore());
      
      return Right(docRef.id);
    } catch (e) {
      return Left(FirestoreFailure('Failed to create book: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getAllBooks() async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.booksCollection)
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final books = querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();

      return Right(books);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch books: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BookEntity>>> getUserBooks(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(FirebaseConstants.booksCollection)
          .where('ownerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final books = querySnapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList();

      return Right(books);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch user books: $e'));
    }
  }

  @override
  Future<Either<Failure, BookEntity>> getBookById(String bookId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.booksCollection)
          .doc(bookId)
          .get();

      if (!doc.exists) {
        return const Left(FirestoreFailure('Book not found'));
      }

      final book = BookModel.fromFirestore(doc);
      return Right(book);
    } catch (e) {
      return Left(FirestoreFailure('Failed to fetch book: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBook(BookEntity book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      await _firestore
          .collection(FirebaseConstants.booksCollection)
          .doc(book.id)
          .update(bookModel.toFirestore());

      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure('Failed to update book: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(String bookId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.booksCollection)
          .doc(bookId)
          .delete();

      return const Right(null);
    } catch (e) {
      return Left(FirestoreFailure('Failed to delete book: $e'));
    }
  }

  @override
  Stream<List<BookEntity>> getBooksStream() {
    return _firestore
        .collection(FirebaseConstants.booksCollection)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<BookEntity>> getUserBooksStream(String userId) {
    return _firestore
        .collection(FirebaseConstants.booksCollection)
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
  }

  Future<Either<Failure, String>> uploadBookImage(String filePath) async {
    try {
      final fileName = 'books/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      
      await ref.putFile(File(filePath));
      final downloadUrl = await ref.getDownloadURL();
      
      return Right(downloadUrl);
    } catch (e) {
      return Left(FirestoreFailure('Failed to upload image: $e'));
    }
  }
}