import 'package:dartz/dartz.dart';
import '../entities/book_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class BooksRepository {
  Future<Either<Failure, String>> createBook(BookEntity book);
  Future<Either<Failure, List<BookEntity>>> getAllBooks();
  Future<Either<Failure, List<BookEntity>>> getUserBooks(String userId);
  Future<Either<Failure, BookEntity>> getBookById(String bookId);
  Future<Either<Failure, void>> updateBook(BookEntity book);
  Future<Either<Failure, void>> deleteBook(String bookId);
  Stream<List<BookEntity>> getBooksStream();
  Stream<List<BookEntity>> getUserBooksStream(String userId);
}