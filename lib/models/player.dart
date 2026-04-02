class Player {
  const Player({
    required this.id,
    required this.displayName,
    required this.avatarSeed,
    this.isImposter = false,
    this.assignedWord,
  });

  final int id;
  final String displayName;
  final String avatarSeed;
  final bool isImposter;
  final String? assignedWord;

  Player copyWith({
    int? id,
    String? displayName,
    String? avatarSeed,
    bool? isImposter,
    String? assignedWord,
  }) {
    return Player(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarSeed: avatarSeed ?? this.avatarSeed,
      isImposter: isImposter ?? this.isImposter,
      assignedWord: assignedWord ?? this.assignedWord,
    );
  }
}
