import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lyrica_flutter/models/lyrics_line_model.dart';

class LyricsService {
  final String baseUrl = "http://127.0.0.1:9999";

  Future<LyricaResponse> fetchSyncedLyrics(String artist, String song) async {
    final cleanSong = song.split(' - ')[0].split(' (')[0].trim();
    final cleanArtist = artist.split(',')[0].split(' feat.')[0].trim();

    final encodedArtist = Uri.encodeComponent(cleanArtist);
    final encodedSong = Uri.encodeComponent(cleanSong);

    final url = Uri.parse(
      "$baseUrl/lyrics/?artist=$encodedArtist&song=$encodedSong&timestamps=true&fast=true&mood=true",
    );

    try {
      print("Sending request to: $url");
      final response = await http.get(url);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final nestedData = responseData['data'];

        String extractedMood = "calm";
        if (responseData['mood_analysis'] != null &&
            responseData['mood_analysis']['sentiment'] != null) {
          extractedMood = responseData['mood_analysis']['sentiment']['mood']
              .toString()
              .toLowerCase();
        }

        if (responseData['mood_analysis'] != null &&
            responseData['mood_analysis']['sentiment'] != null) {
          final sentiment = responseData['mood_analysis']['sentiment'];
          final overallMood =
              sentiment['overall_mood']?.toString().toLowerCase() ?? "";
          final rawMood = sentiment['mood']?.toString().toLowerCase() ?? "";

          if (overallMood.contains('sad') ||
              overallMood.contains('emotional') ||
              overallMood.contains('emo')) {
            extractedMood = 'emo';
          } else if (rawMood == 'negative') {
            extractedMood = 'sad';
          } else {
            extractedMood = rawMood; // captures positive, calm, etc.
          }
        }

        if (responseData['mood_analysis'] != null &&
            responseData['mood_analysis']['top_words'] != null) {
          final positiveWords =
              responseData['mood_analysis']['top_words']['positive_words']
                  as List?;
          if (positiveWords != null) {
            final hasHotWord = positiveWords.any(
              (item) => item['word'] == 'hot',
            );
            if (hasHotWord) {
              extractedMood = 'hot';
            }
          }
        }

        if (extractedMood == 'positive') extractedMood = 'romantic';
        if (extractedMood == 'negative') extractedMood = 'sad';

        List<LyricLine> parsedLines = [];

        if (nestedData != null && nestedData['timed_lyrics'] is List) {
          List<dynamic> linesJson = nestedData['timed_lyrics'];
          parsedLines = linesJson.map((line) {
            return LyricLine(
              timestamp: Duration(milliseconds: line['start_time'] ?? 0),
              text: line['text'] ?? "",
            );
          }).toList();
        } else if (nestedData != null && nestedData['lyrics'] is String) {
          String rawLyrics = nestedData['lyrics'];
          List<String> rawLines = rawLyrics.split('\n');

          int estimatedOffsetMs = 0;
          for (var lineText in rawLines) {
            if (lineText.trim().isNotEmpty) {
              parsedLines.add(
                LyricLine(
                  timestamp: Duration(milliseconds: estimatedOffsetMs),
                  text: lineText.trim(),
                ),
              );
              estimatedOffsetMs += 4000;
            }
          }
        }

        return LyricaResponse(lyrics: parsedLines, mood: extractedMood);
      }
    } catch (e) {
      print("Critical Mood/Lyrics Error Block: $e");
    }

    return LyricaResponse(
      lyrics: [
        LyricLine(timestamp: Duration.zero, text: "Lyrics unavailable 🎵"),
      ],
      mood: "calm",
    );
  }
}
