class LyricaResponse {
  final List<LyricLine> lyrics;
  final String mood;

  LyricaResponse({required this.lyrics, this.mood = "calm"});
}

class LyricLine {
  final Duration timestamp;
  final String text;

  LyricLine({required this.timestamp, required this.text});
}
