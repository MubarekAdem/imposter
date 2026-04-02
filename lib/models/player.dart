class Player {
  const Player({
    required this.id,
    required this.displayName,
    this.isImposter = false,
    this.assignedWord,
  });

  final int id;
  final String displayName;
  final bool isImposter;
  final String? assignedWord;

  Player copyWith({
    int? id,
    String? displayName,
    bool? isImposter,
    String? assignedWord,
  }) {
    return Player(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      isImposter: isImposter ?? this.isImposter,
      assignedWord: assignedWord ?? this.assignedWord,
    );
  }
}
