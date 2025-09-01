class TimestampedMessage {
  final Duration time;
  final String message;

  TimestampedMessage({required this.time, required this.message});

  factory TimestampedMessage.fromLine(String line) {
    // Supports HH:MM:SS or MM:SS
    final match = RegExp(
      r'^(?:(\d{2}):)?(\d{2}):(\d{2})\s+(.*)',
    ).firstMatch(line.trim());
    if (match == null) {
      throw FormatException('Invalid timestamped message format: $line');
    }
    final hasHours = match.group(1) != null;
    final hours = hasHours ? int.parse(match.group(1)!) : 0;
    final minutes = int.parse(match.group(2)!);
    final seconds = int.parse(match.group(3)!);
    final message = match.group(4)!;
    return TimestampedMessage(
      time: Duration(hours: hours, minutes: minutes, seconds: seconds),
      message: message,
    );
  }
}
