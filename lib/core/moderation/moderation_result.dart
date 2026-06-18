class ModerationResult {
  const ModerationResult({
    required this.censoredText,
    required this.hadViolation,
    required this.shouldBlock,
  });

  final String censoredText;
  final bool hadViolation;
  final bool shouldBlock;

  factory ModerationResult.allowed(String text) => ModerationResult(
        censoredText: text,
        hadViolation: false,
        shouldBlock: false,
      );
}
