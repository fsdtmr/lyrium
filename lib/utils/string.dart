String replaceFirstCaseInsensitive(
  String source,
  String pattern, [
  String to = "",
]) {
  final lowerSource = source.toLowerCase();
  final lowerPattern = pattern.toLowerCase();

  final index = lowerSource.indexOf(lowerPattern);
  if (index == -1) return source; // nothing to replace

  return source.replaceRange(index, index + pattern.length, to);
}

extension ValidString on String? {
  get isValid => this != null && this!.isNotEmpty;
}
