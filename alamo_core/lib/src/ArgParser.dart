final INT_REGEX = RegExp("[+-]?[0-9]+");
final BOOL_REGEX = RegExp("true|false");
final STR_REGEX = RegExp('"(\\"|[^"])*"');

class ArgumentParser {
  String content;
  ArgumentParser(this.content);

  int integer() {
    final match = INT_REGEX.matchAsPrefix(content);
    if (match == null) return null;
    content = content.substring(match.end).trim();
    return int.tryParse(match.group(0));
  }

  bool boolean() {
    final match = BOOL_REGEX.matchAsPrefix(content);
    if (match == null) return null;
    content = content.substring(match.end).trim();
    return match.group(0) == "true";
  }

  String string() {
    final match = STR_REGEX.matchAsPrefix(content);
    if (match == null) return null;
    content = content.substring(match.end).trim();
    final result = match.group(0);
    return result.substring(1, result.length - 1);
  }
}
