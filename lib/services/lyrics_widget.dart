import 'package:lyrica_flutter/models/lyrics_line_model.dart';

import 'package:flutter/material.dart';
import 'package:lyrica_flutter/mood/mood_widget.dart';
import 'dart:ui'; // CRUCIAL: Required for ImageFilter
import 'package:flutter/material.dart';

class LyricWidgetBody extends StatefulWidget {
  final List<LyricLine> lyrics;
  final Duration currentPlaybackPosition;
  final String songMood;

  const LyricWidgetBody({
    super.key,
    required this.lyrics,
    required this.currentPlaybackPosition,
    required this.songMood,
  });

  @override
  State<LyricWidgetBody> createState() => _LyricWidgetBodyState();
}

class _LyricWidgetBodyState extends State<LyricWidgetBody> {
  final ScrollController _scrollController = ScrollController();
  int _activeIndex = -1;
  Map<String, List<Color>> get _moodGradients {
    return {
      'emo': [
        const Color(0xFF1A1A2E).withOpacity(0.40),
        const Color(0xFF16213E).withOpacity(0.20),
      ],
      'hot': [
        const Color(0xFFD32F2F).withOpacity(0.35), // Crimson Lava Accent
        const Color(0xFFFF8F00).withOpacity(0.12), // Neon Amber
      ],
      'romantic': [
        Colors.pink.withOpacity(0.25),
        Colors.purple.withOpacity(0.12),
      ],
      'happy': [
        Colors.amber.withOpacity(0.25),
        Colors.orange.withOpacity(0.12),
      ],
      'energetic': [
        Colors.red.withOpacity(0.28),
        Colors.orange.withOpacity(0.12),
      ],
      'sad': [
        Colors.blueGrey.withOpacity(0.30),
        Colors.indigo.withOpacity(0.15),
      ],
      'calm': [
        // Colors.teal.withOpacity(0.20), Colors.blue.withOpacity(0.08)
        //
        const Color(0xFF1A1A2E).withOpacity(0.40), // Deep Midnight Slate
        const Color(0xFF16213E).withOpacity(0.20),
      ],
    };
  }

  @override
  void didUpdateWidget(covariant LyricWidgetBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lyrics.isEmpty) return;

    int newIndex = -1;
    for (int i = 0; i < widget.lyrics.length; i++) {
      if (widget.currentPlaybackPosition >= widget.lyrics[i].timestamp) {
        newIndex = i;
      } else {
        break;
      }
    }

    if (newIndex != -1 && newIndex != _activeIndex) {
      _activeIndex = newIndex;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _activeIndex * 55.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeGradient =
        _moodGradients[widget.songMood] ?? _moodGradients['calm']!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFF121212).withOpacity(0.15)),
          ),

          // LAYER 1: The Frosted Glass Blur Filter Engine
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 18.0,
                sigmaY: 18.0,
              ), // Bumped blur slightly
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: activeGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(
                      0.12,
                    ), // Brighter line definition
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // LAYER 2: Falling Particles (Drifting inside the glass)
          Positioned.fill(child: MoodParticlesWidget(mood: widget.songMood)),

          // LAYER 3: The Auto-Scrolling Lyrics Text
          Positioned.fill(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: widget.lyrics.length,
              padding: const EdgeInsets.symmetric(vertical: 90.0),
              itemBuilder: (context, index) {
                final isHighlighted = index == _activeIndex;
                return Container(
                  height: 55,
                  alignment: Alignment.center,
                  child: Text(
                    widget.lyrics[index].text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isHighlighted ? 22 : 16,
                      fontWeight: isHighlighted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isHighlighted ? Colors.white : Colors.white60,
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
