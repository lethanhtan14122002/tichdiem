import 'package:flutter/material.dart';
import '../models/customer_model.dart';

class LoyaltyCardFront extends StatelessWidget {
  final CustomerModel customer;

  const LoyaltyCardFront({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD78A), width: 1.5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06366F), Color(0xFF087DC1), Color(0xFF06417B)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06417B).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -40,
            child: _decorationCircle(150, const Color(0xFF35B99A)),
          ),
          Positioned(
            right: -40,
            bottom: -60,
            child: _decorationCircle(170, const Color(0xFF37A5DB)),
          ),
          Positioned(
            top: 55,
            right: 15,
            child: Icon(
              Icons.park_rounded,
              color: Colors.white.withValues(alpha: 0.13),
              size: 100,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: Color(0xFFA8F0CF),
                      size: 23,
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'VIC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    const Text('🌿', style: TextStyle(fontSize: 25)),
                  ],
                ),

                const Spacer(),

                const Text(
                  'THẺ TÍCH ĐIỂM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Tích điểm hôm nay - Nhận quà ngày mai',
                  style: TextStyle(
                    color: Color(0xFFFFE5B5),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    const Text('🐎', style: TextStyle(fontSize: 38)),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5E1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFFD78A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF103C70),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_android,
                                  size: 13,
                                  color: Color(0xFF54769B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '**** ${customer.lastFourPhone}',
                                  style: const TextStyle(
                                    color: Color(0xFF54769B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorationCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
    );
  }
}
