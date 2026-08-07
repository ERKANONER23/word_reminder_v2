class Word {
  final int? id;
  final String english;
  final String turkish;

  Word({this.id, required this.english, required this.turkish});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'turkish': turkish,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      english: map['english'],
      turkish: map['turkish'],
    );
  }

  Word copyWith({int? id, String? english, String? turkish}) {
    return Word(
      id: id ?? this.id,
      english: english ?? this.english,
      turkish: turkish ?? this.turkish,
    );
  }
}