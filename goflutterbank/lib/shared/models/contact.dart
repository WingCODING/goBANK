class Contact {
  final String initials;
  final String shortName;

  /// Raw 11-digit CPF (no punctuation).
  final String cpf;

  const Contact({
    required this.initials,
    required this.shortName,
    required this.cpf,
  });
}
