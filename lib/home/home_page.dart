import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../cells/cells_page.dart';
import '../charging/charging_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DateTime _now;
  Timer? _timer;

  double currentSpeed = 54;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTime(_now);

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          const designSize = Size(1024, 600);
          // Layout the dashboard at a fixed "design size" then scale it to fit.
          // This avoids overflows when the app runs in smaller windows/tests.
          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: designSize.width,
                height: designSize.height,
                child: _DashboardView(
                  gear: 6,
                  speed: currentSpeed.round(),
                  rideKm: 3.6,
                  odoKm: 2495.2,
                  rangeKm: 137,
                  batteryPercent: 100,
                  efficiencyLabel: 'EFF',
                  efficiencyValue: '71 W',
                  modeLabel: 'ATTACK',
                  regenLabel: 'REGEN',
                  timeText: timeText,
                  currentSpeed: currentSpeed,
                  onSpeedChanged: (v) => setState(() => currentSpeed = v),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$h:$mm';
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.gear,
    required this.speed,
    required this.rideKm,
    required this.odoKm,
    required this.rangeKm,
    required this.batteryPercent,
    required this.efficiencyLabel,
    required this.efficiencyValue,
    required this.modeLabel,
    required this.regenLabel,
    required this.timeText,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  final int gear;
  final int speed;
  final double rideKm;
  final double odoKm;
  final int rangeKm;
  final int batteryPercent;
  final String efficiencyLabel;
  final String efficiencyValue;
  final String modeLabel;
  final String regenLabel;
  final String timeText;
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  static const _green = Color(0xFF33FF33);
  static const _panelText = Color(0xFFB8B8B8);
  static const _warnRed = Color(0xFFB00020);
  static const _attackRed = Color(0xFFB30000);
  static const _accentBlue = Color(0xFF006DFF);


  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          _background(),
          _topRow(context),
          _leftRail(),
          _speedCluster(),
          _rightPanel(),
          _redPowerBar(),
          _bottomBars(),
        ],
      ),
    );
  }


  Widget _background() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black,
      ),
    );
  }

  Widget _topRow(BuildContext context) {
    return Positioned(
      left: 30,
      right: 48,
      top: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ChargingPage()),
              );
            },
            child: SvgPicture.asset(
              "assets/icons/arrow_left.svg",
              width: 60,
              colorFilter: const ColorFilter.mode(_green, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _metricBlock(
                  title: 'THIS RIDE',
                  value: '${rideKm.toStringAsFixed(1)} KM',
                  align: CrossAxisAlignment.start,
                ),
                const SizedBox(width: 84),
                _centerStatus(timeText: timeText),
                const SizedBox(width: 84),
                _metricBlock(
                  title: 'ODO',
                  value: '${odoKm.toStringAsFixed(1)} KM',
                  align: CrossAxisAlignment.start,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CellsPage()),
              );
            },
            child: SvgPicture.asset(
              "assets/icons/arrow_right.svg",
              width: 60,
              colorFilter: const ColorFilter.mode(_green, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBlock({
    required String title,
    required String value,
    required CrossAxisAlignment align,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _panelText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _centerStatus({required String timeText}) {
    return Column(
      children: [
        Icon(Icons.network_cell, color: _panelText.withValues(alpha: 0.7), size: 18),
        const SizedBox(height: 6),
        Text(
          timeText,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _leftRail() {
    return Positioned(
      left: 40,
      top: 160,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          _railGlyph(
            child: SvgPicture.asset(
              "assets/icons/1.svg",
              width: 100,
              colorFilter: ColorFilter.mode(_accentBlue, BlendMode.srcIn),
            ),
          ),

          const SizedBox(height: 4),

          _railGlyph(
            child: SvgPicture.asset(
              "assets/icons/2.svg",
              width: 45,
              colorFilter: const ColorFilter.mode(
                Color(0xFFAD6200),
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(height: 4),

          _railGlyph(
            child: SvgPicture.asset(
              "assets/icons/3.svg",
              width: 80,
              colorFilter: const ColorFilter.mode(
                Color(0xFFAD6200),
                BlendMode.srcIn,
              ),
            ),
          ),

          const SizedBox(height: 2),

          _railGlyph(
            child: SvgPicture.asset(
              "assets/icons/4.svg",
              width: 80,
              colorFilter: const ColorFilter.mode(
                Color(0xFFAD6200),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _railGlyph({required Widget child}) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Center(child: child),
    );
  }

  Widget _speedCluster() {
    final speedText = speed.toString().padLeft(3, '0');

    return Positioned(
      left: 110,     // shift right slightly
      right: 210,    // allow more space for speed digits
      top: 180,      // lower slightly
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [

            /// GEAR
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '$gear',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  color: Color(0xFF8C0000),
                  fontSize: 75,   // reduced from 98
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(width: 18),

            /// SPEED
            _metallicText(
              speedText,
              fontSize: 170,     // reduced from 210
              fontWeight: FontWeight.w600,
              skew: -0.15,
            ),

            const SizedBox(width: 8),

            /// KM/H
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'KM/H',
                style: TextStyle(
                  color: _panelText.withValues(alpha: 0.9),
                  fontSize: 22,   // slightly smaller
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metallicText(
      String text, {
        required double fontSize,
        required FontWeight fontWeight,
        double skew = 0,
      }) {
    return Transform(
      transform: Matrix4.identity()..setEntry(0, 1, skew),
      alignment: Alignment.center,
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF2F2F2),
              Color(0xFFDADADA),
              Color(0xFFDADADA),
              Color(0xFFF5F5F5),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.srcIn,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: FontStyle.italic,
            letterSpacing: 3,
            height: 0.9,
          ),
        ),
      ),
    );
  }

  Widget _rightPanel() {
    return Positioned(
      right: 35,   // move slightly closer to screen edge
      top: 170,     // lower slightly so it aligns with speed digits
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// RANGE BAR
          ClipPath(
            clipper: _RangeBarClipper(),
            child: Container(
              width: 12,
              height: 150,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6E6E6E),
                    Color(0xFF00C12C),
                    Color(0xFF00FF3A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _green.withValues(alpha: 0.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// RANGE + BATTERY PANEL
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// RANGE LABEL
              Text(
                "RANGE",
                style: TextStyle(
                  color: _panelText.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 4),

              /// RANGE VALUE
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  Text(
                    "$rangeKm",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,   // reduced from 78
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "KM",
                      style: TextStyle(
                        color: _panelText.withValues(alpha: 0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// BATTERY LABEL
              Text(
                "BATTERY",
                style: TextStyle(
                  color: _panelText.withValues(alpha: 0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 4),

              /// BATTERY VALUE
              Row(
                children: [
                  const Icon(Icons.bolt, color: _green, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    "$batteryPercent%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _redPowerBar() {
    return Positioned(
      left: 65,
      right: 40,
      bottom: 180,
      child: SizedBox(
        height: 75,
        child: ClipPath(
          clipper: const _HudTopStripClipper(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final normalized = (currentSpeed / 160).clamp(0.0, 1.0);
              final filledW = w * normalized;

              void setFromDx(double dx) {
                final n = (dx / w).clamp(0.0, 1.0);
                final v = (n * 160).clamp(0.0, 160.0);
                onSpeedChanged(v);
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragDown: (d) => setFromDx(d.localPosition.dx),
                onHorizontalDragUpdate: (d) => setFromDx(d.localPosition.dx),
                onTapDown: (d) => setFromDx(d.localPosition.dx),
                child: Stack(
                  children: [
                    // Inactive (right side): grey/black gradient.
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF050505),
                              Color(0xFF1A1A1A),
                              Color(0xFF3A3A3A),
                              Color(0xFF9A9A9A),
                            ],
                            stops: [0.0, 0.45, 0.8, 1.0],
                          ),
                        ),
                        foregroundDecoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x44FFFFFF), // subtle top highlight
                              Color(0x00FFFFFF),
                            ],
                            stops: [0.0, 0.35],
                          ),
                        ),
                      ),
                    ),

                    // Active (left side): red gradient up to current speed.
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      curve: Curves.easeOut,
                      width: filledW,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF2A0000),
                              Color(0xFF8C0000),
                              Color(0xFFFF1A1A),
                              Color(0xFF8C0000),
                              Color(0xFF2A0000),
                            ],
                            stops: [0.0, 0.30, 0.55, 0.78, 1.0],
                          ),
                        ),
                        foregroundDecoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x66FFFFFF), // top highlight
                              Color(0x00FFFFFF),
                            ],
                            stops: [0.0, 0.3],
                          ),
                        ),
                      ),
                    ),

                    // Knob indicator.
                    Positioned(
                      left: (filledW - 6).clamp(0.0, w - 12),
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF1A1A).withValues(alpha: 0.65),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF1A1A).withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _bottomBars() {
    return Positioned(
      left: 70,
      right: 20,
      bottom: 80,   // lowered from 80 → prevents overlapping speed
      child: SizedBox(
        height: 70,  // reduced from 96
        child: Stack(
          children: [

            /// SMALL REGEN PLATE
          Positioned(
          right: 195,
          bottom: 30,
          width: 140,
          height: 45,
          child: ClipPath(
            clipper: const _HudPlateClipper(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF0B0B0B),  // deep black start
                    Color(0xFF2A2A2A),  // dark metallic grey
                    Color(0xFF3F3F3F),  // transition grey
                    Color(0xFF8C0000),  // red fade
                    Color(0xFFFF1A1A),  // red highlight
                    Color(0xFF8C0000),  // metallic grey tip
                  ],
                  stops: [0.0, 0.28, 0.45, 0.65, 0.82, 1.0],
                ),
              ),
            ),
          ),
        ),
            /// BOTTOM CONTENT ROW
            Positioned(
              left: 0,
              right: 120,
              bottom: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  /// EFF
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _slantedMarks(),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            efficiencyLabel,
                            style: TextStyle(
                              color: _panelText.withValues(alpha: 0.95),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            efficiencyValue,
                            style: const TextStyle(
                              fontFamily: 'Orbitron',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// ATTACK BUTTON

                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: _attackButton(modeLabel),
                  ),

                  const Spacer(),

                  /// REGEN
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      regenLabel,
                      style: TextStyle(
                        color: _panelText.withValues(alpha: 0.92),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),

                  /// WARNING ICON
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: _warnRed,
                      size: 56,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _attackButton(String label) {
    return ClipPath(
      clipper: const _AttackButtonClipper(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // smaller
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B0B),
          border: Border.all(
            color: _attackRed.withValues(alpha: 0.95),
            width: 1.6, // slightly thinner border
          ),
          boxShadow: [
            BoxShadow(
              color: _attackRed.withValues(alpha: 0.25),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              '<',
              style: TextStyle(
                color: _attackRed.withValues(alpha: 0.95),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(width: 8),

            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12, // reduced from 14
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '>',
              style: TextStyle(
                color: _attackRed.withValues(alpha: 0.95),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _slantedMarks() {
    return Transform.translate(
        offset: const Offset(0, -8), // move upward (adjust if needed)
        child: SizedBox(
      width: 90,
      height: 24,
      child: CustomPaint(
        painter: _SlantedMarksPainter(color: _panelText.withValues(alpha: 0.9)),
      ),
        )
    );
  }
}

class _SlantedMarksPainter extends CustomPainter {
  const _SlantedMarksPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / 5;
    final gap = barWidth * 0.35;
    final slant = barWidth * 0.45; // increased slant

    for (int i = 0; i < 3; i++) {
      final x = i * (barWidth + gap);

      final path = Path()
        ..moveTo(x + slant, 0)
        ..lineTo(x + barWidth + slant, 0)
        ..lineTo(x + barWidth, size.height)
        ..lineTo(x, size.height)
        ..close();

      // white outline
      final outlinePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawPath(path, outlinePaint);

      // fill color
      final fillPaint = Paint()
        ..color = color.withValues(alpha: 1.0 - (i * 0.3))
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SlantedMarksPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HudTopStripClipper extends CustomClipper<Path> {
  const _HudTopStripClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();

    // top-left cut
    path.moveTo(w * 0.10, 0);

    // top-right cut
    path.lineTo(w * 0.92, 0);

    // bottom-right cut
    path.lineTo(w * 0.82, h);

    // bottom-left cut
    path.lineTo(w * 0.00, h);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}



class _HudPlateClipper extends CustomClipper<Path> {
  const _HudPlateClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();

    // left slanted edge
    path.moveTo(30, 0);

    // top edge
    path.lineTo(w, 0);

    // angled right edge
    path.lineTo(w - 25, h);

    // bottom edge
    path.lineTo(0, h);

    // back to start
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _RangeBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {

    final w = size.width;
    final h = size.height;

    final path = Path();

    path.moveTo(0, h * 0.06);
    path.lineTo(w, 0);

    path.lineTo(w, h * 0.45);

    /// middle notch
    path.lineTo(0, h * 0.55);

    path.lineTo(0, h * 0.94);
    path.lineTo(w, h);

    path.lineTo(w, h * 0.55);
    path.lineTo(0, h * 0.45);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _AttackButtonClipper extends CustomClipper<Path> {
  const _AttackButtonClipper();

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final p = Path();

    p.moveTo(w * 0.18, 0);  // top-left slant
    p.lineTo(w, 0);         // top-right
    p.lineTo(w * 0.82, h);  // bottom-right slant
    p.lineTo(0, h);         // bottom-left

    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

