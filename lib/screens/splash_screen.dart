import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;
import 'login_screen.dart';
import 'main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _loopController;
  
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<double> _textOffset;
  
  @override
  void initState() {
    super.initState();
    
    // Intro sequence (Scale in, slide up texts)
    _introController = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 1500)
    );
    
    _logoScale = CurvedAnimation(parent: _introController, curve: const Interval(0.2, 0.8, curve: Curves.elasticOut));
    _textOpacity = CurvedAnimation(parent: _introController, curve: const Interval(0.6, 1.0, curve: Curves.easeIn));
    _textOffset = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic))
    );

    // Continuous wiggles and bounces
    _loopController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 3)
    )..repeat();

    _introController.forward();

    // 4 seconds to allow the full intro animation + looping to be admired
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1B365D), // Deep Navy Blue
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
          // 1. Geometric Scattered Background
          ...List.generate(20, (i) {
             final leftPercent = (i % 5) * 0.25;
             final topPercent = (i ~/ 5) * 0.25;
             
             return Positioned(
               left: size.width * leftPercent,
               top: size.height * topPercent,
               child: Transform.rotate(
                 angle: math.pi / 4, // 45 degrees
                 child: FadeTransition(
                   opacity: CurvedAnimation(
                      parent: _introController, 
                      curve: Interval((i * 0.05).clamp(0.0, 1.0), 1.0, curve: Curves.easeIn)
                   ),
                   child: Container(
                     width: 90, height: 90,
                     decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 2)
                     ),
                   ),
                 ),
               ),
             );
          }),

          // 2. Central Logo and Text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                 scale: _logoScale,
                 child: AnimatedBuilder(
                    animation: _loopController,
                    builder: (context, child) {
                       // Wiggle rotation (-5 to 5 degrees -> converted to radians)
                       final angle = math.sin(_loopController.value * math.pi * 2) * (5 * math.pi / 180);
                       return Transform.rotate(
                          angle: angle,
                          child: SizedBox(
                            width: 100, height: 100,
                            child: CustomPaint(
                               painter: _GeometricLogoPainter(),
                            ),
                          ),
                       );
                    },
                 ),
              ),
              
              const SizedBox(height: 32),
              
              AnimatedBuilder(
                 animation: _introController,
                 builder: (context, child) {
                    return Transform.translate(
                       offset: Offset(0, _textOffset.value),
                       child: Opacity(
                          opacity: _textOpacity.value,
                          child: Column(
                             children: [
                               const Text(
                                 "BudiLingua",
                                 style: TextStyle(
                                   color: Colors.white,
                                   fontSize: 42,
                                   fontWeight: FontWeight.bold,
                                   letterSpacing: -0.5,
                                 ),
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 "Learn languages, honor culture",
                                 style: TextStyle(
                                   color: Colors.white.withValues(alpha: 0.7),
                                   fontSize: 16,
                                 ),
                               ),
                             ],
                          ),
                       ),
                    );
                 }
              )
            ],
          ),

          // 3. Staggered Dotted Loader
          Positioned(
             bottom: 60,
             child: AnimatedBuilder(
                animation: _loopController,
                builder: (context, child) {
                   return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                         // Math trick for rolling staggered effect
                         double val = (_loopController.value * 3 - i + 3) % 3;
                         double scale = 1.0;
                         double opacity = 0.5;
                         
                         if (val < 1.0) {
                            scale = 1.0 + (math.sin(val * math.pi) * 0.5); // Peak at 1.5
                            opacity = 0.5 + (math.sin(val * math.pi) * 0.5); // Peak at 1.0
                         }
                         
                         return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Transform.scale(
                               scale: scale,
                               child: Opacity(
                                  opacity: opacity,
                                  child: Container(
                                     width: 10, height: 10,
                                     decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle
                                     ),
                                  ),
                               ),
                            ),
                         );
                      }),
                   );
                }
             ),
          )
        ],
      ),
      ),
    );
  }
}

class _GeometricLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Warm Gold Outer Diamond (50,10 -> 90,50 -> 50,90 -> 10,50)
    final goldPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.9)
      ..lineTo(size.width * 0.1, size.height * 0.5)
      ..close();

    final goldPaint = Paint()
      ..color = const Color(0xFFFFC857)
      ..style = PaintingStyle.fill;
    
    final goldStroke = Paint()
      ..color = const Color(0xFFFFC857)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Vibrant Green Inner Diamond (50,25 -> 75,50 -> 50,75 -> 25,50)
    final greenPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.25)
      ..lineTo(size.width * 0.75, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.75)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..close();

    final greenPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final greenStroke = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // 1. Draw Gold Fill + Stroke
    canvas.drawPath(goldPath, goldPaint..color = goldPaint.color.withValues(alpha: 0.2));
    canvas.drawPath(goldPath, goldStroke);

    // 2. Draw Green Fill + Stroke
    canvas.drawPath(greenPath, greenPaint..color = greenPaint.color.withValues(alpha: 0.2));
    canvas.drawPath(greenPath, greenStroke);

    // 3. Center White Circle (r=8)
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, size.width * 0.08, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
