abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem(this.title, this.year);

  String describe();

  bool get isOld => year <= 1000;
}

class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: (json['name'] as String?) ?? '',
      country: json['country'] as String?,
    );
  }

  @override
  String toString() {
    return "My name is $name, I'm from ${country ?? "Kazakhstan"}";
  }
}

enum Genre {
  craft("Craft"),
  theory("Theory"),
  unknown("Unknown");

  final String label;

  const Genre(this.label);

  static Genre fromString(String? raw) {
    return Genre.values.firstWhere(
      (genre) => genre.name == raw?.toLowerCase(),
      orElse: () => Genre.unknown,
    );
  }
}

mixin Borrowable on LibraryItem {
  String borrowLabel() {
    return "Borrow: $title";
  }
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required String title,
    required int year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  }) : super(title, year);

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: (json['title'] as String?) ?? '',
      year: (json['year'] as int?) ?? 0,
      pages: (json['pages'] as int?) ?? 0,
      author: Author(name: (json['author'] as String?) ?? ''),
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?,
    );
  }

  bool get isLong => pages > 400;

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  @override
  String describe() {
    return "Book: $title, author: ${author.name}, genre: ${genre.label}";
  }

  @override
  String toString() {
    return "Book(title: $title, year: $year, pages: $pages, "
        "author: ${author.name}, genre: ${genre.label}, "
        "description: $description)";
  }
}

class Magazine extends LibraryItem {
  final String issue;

  Magazine(super.title, super.year, this.issue);

  @override
  String describe() {
    return "Magazine: $title, year: $year, issue: $issue";
  }
}

class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  Ghost(this.title, this.year);

  @override
  String describe() {
    return "Ghost: $title, year: $year";
  }

  @override
  bool get isOld => year <= 1000;
}
