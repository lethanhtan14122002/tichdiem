import 'package:flutter/material.dart';

class LoyaltyCardBack1 extends StatelessWidget {
  final int points;
  final VoidCallback onStampTap;
  final VoidCallback onRedeemTap;
  final VoidCallback onRedeem7Tap;
  final VoidCallback onRedeem15Tap;
  final VoidCallback onPrivilegesTap;
  final VoidCallback onMinusOneTap;

  const LoyaltyCardBack1({
    super.key,
    required this.points,
    required this.onStampTap,
    required this.onRedeemTap,
    required this.onRedeem7Tap,
    required this.onRedeem15Tap,
    required this.onPrivilegesTap,
    required this.onMinusOneTap,
  });

  @override
  Widget build(BuildContext context) {
    final earnedPoints = points.clamp(0, 35);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFD9B66E), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF07345C).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Nền rừng xanh
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF061F49),
                    Color(0xFF075B91),
                    Color(0xFF087C83),
                    Color(0xFF06294E),
                  ],
                ),
              ),
            ),
          ),

          // Ánh sáng trang trí
          Positioned(
            top: -70,
            right: -45,
            child: _glow(190, const Color(0xFF54D8B2)),
          ),
          Positioned(
            bottom: -85,
            left: -55,
            child: _glow(190, const Color(0xFF278CD0)),
          ),

          // Cây trang trí
          const Positioned(
            left: 5,
            top: 75,
            child: Icon(
              Icons.park_rounded,
              size: 105,
              color: Color(0x2535D5A0),
            ),
          ),
          const Positioned(
            right: 0,
            bottom: 75,
            child: Icon(
              Icons.forest_rounded,
              size: 120,
              color: Color(0x2635D5A0),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFD88A),
                      size: 20,
                    ),
                    SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        'TÍCH ĐIỂM - NHẬN QUÀ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(width: 9),
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFFFD88A),
                      size: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                const Text(
                  'Mỗi dấu móng ngựa là một món quà đang đến gần',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFD6EAF5), fontSize: 10),
                ),

                const SizedBox(height: 25),

                // 35 ô tích điểm
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 35,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final isEarned = index < earnedPoints;
                    final isNextStamp =
                        index == earnedPoints && earnedPoints < 35;

                    return GestureDetector(
                      onTap: isNextStamp ? onStampTap : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isEarned
                                ? const [Color(0xFFFFE6A6), Color(0xFFD99A3B)]
                                : const [Color(0xFFDDF5EB), Color(0xFF9FD5C2)],
                          ),
                          border: Border.all(
                            color: isEarned
                                ? const Color(0xFFFFF0C4)
                                : const Color(0xFFBCEAD5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isEarned
                              ? const CustomPaint(
                                  size: Size(29, 29),
                                  painter: HorseHoofPainter(),
                                )
                              : const Icon(
                                  Icons.eco_rounded,
                                  color: Color(0xFF438C70),
                                  size: 25,
                                ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                // Thanh tiến trình
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 23,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE9B5), Color(0xFFE9BD69)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    '$earnedPoints / 35 ĐIỂM',
                    style: const TextStyle(
                      color: Color(0xFF493216),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Divider(color: Color(0x55FFFFFF)),

                const SizedBox(height: 13),

                // Các nút tự xuống dòng khi màn hình hẹp
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _Benefit(
                      icon: Icons.card_giftcard_rounded,
                      text: 'Đổi quà',
                      onTap: onRedeemTap,
                    ),
                    _Benefit(
                      icon: Icons.card_giftcard_rounded,
                      text: 'Đổi quà 7',
                      onTap: onRedeem7Tap,
                    ),
                    _Benefit(
                      icon: Icons.card_giftcard_rounded,
                      text: 'Đổi quà 15',
                      onTap: onRedeem15Tap,
                    ),
                    _Benefit(
                      icon: Icons.workspace_premium_rounded,
                      text: 'Lưu Tháng mới',
                      onTap: onPrivilegesTap,
                    ),
                    _Benefit(
                      icon: Icons.remove_circle_outline_rounded,
                      text: 'Giảm 1 lần',
                      onTap: onMinusOneTap,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  'VIC • THANK YOU FOR YOUR LOYALTY',
                  style: TextStyle(
                    color: Color(0xFFB9D9E9),
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
    );
  }
}

// Tự vẽ dấu móng ngựa
class HorseHoofPainter extends CustomPainter {
  const HorseHoofPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF71451F)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(size.width * 0.16, size.height * 0.15);
    path.quadraticBezierTo(
      size.width * 0.03,
      size.height * 0.27,
      size.width * 0.15,
      size.height * 0.67,
    );
    path.quadraticBezierTo(
      size.width * 0.24,
      size.height * 0.94,
      size.width * 0.50,
      size.height * 0.96,
    );
    path.quadraticBezierTo(
      size.width * 0.76,
      size.height * 0.94,
      size.width * 0.85,
      size.height * 0.67,
    );
    path.quadraticBezierTo(
      size.width * 0.97,
      size.height * 0.27,
      size.width * 0.84,
      size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.72,
      size.height * 0.06,
      size.width * 0.65,
      size.height * 0.30,
    );
    path.quadraticBezierTo(
      size.width * 0.50,
      size.height * 0.39,
      size.width * 0.35,
      size.height * 0.30,
    );
    path.quadraticBezierTo(
      size.width * 0.28,
      size.height * 0.06,
      size.width * 0.16,
      size.height * 0.15,
    );

    path.close();

    canvas.drawPath(path, paint);

    final highlight = Paint()
      ..color = const Color(0xFFFFD88A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    canvas.drawPath(path, highlight);
  }

  @override
  bool shouldRepaint(covariant HorseHoofPainter oldDelegate) => false;
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _Benefit({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFD98E), size: 26),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
