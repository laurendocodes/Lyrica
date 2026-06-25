import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lyrica_flutter/mood/mood_particle.dart';

class MoodParticlesWidget extends StatefulWidget {
  final String mood;
  const MoodParticlesWidget({super.key, required this.mood});

  @override
  State<MoodParticlesWidget> createState() => _MoodParticlesWidgetState();
}

class _MoodParticlesWidgetState extends State<MoodParticlesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<MoodParticle> _particles = [];
  final Random _random = Random();

  String get _moodEmoji {
    switch (widget.mood) {
      case 'emo':
        return '🖤⛓️';
      case 'hot':
        return '🌶️ ';
      case 'romantic':
        return '💕';
      case 'happy':
        return '✨';
      case 'energetic':
        return '⚡';
      case 'sad':
        return '💧';
      default:
        return '🕸️';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Pre-populate particles across screen coordinates
    for (int i = 0; i < 20; i++) {
      _particles.add(_createParticle(isInitial: true));
    }
  }

  MoodParticle _createParticle({bool isInitial = false}) {
    return MoodParticle(
      x: _random.nextDouble(),
      y: isInitial ? _random.nextDouble() : -0.1,
      size: _random.nextDouble() * 14 + 10,
      speed: _random.nextDouble() * 0.004 + 0.002,
      opacity: _random.nextDouble() * 0.4 + 0.2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var particle in _particles) {
          particle.y += particle.speed;
          if (particle.y > 1.1) {
            _particles[_particles.indexOf(particle)] = _createParticle();
          }
        }

        return CustomPaint(
          painter: ParticlePainter(particles: _particles, emoji: _moodEmoji),
          child: Container(),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<MoodParticle> particles;
  final String emoji;

  ParticlePainter({required this.particles, required this.emoji});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: emoji,
          style: TextStyle(
            fontSize: particle.size,
            color: Colors.white.withOpacity(particle.opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Calculate layout canvas positions
      final offset = Offset(particle.x * size.width, particle.y * size.height);

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
