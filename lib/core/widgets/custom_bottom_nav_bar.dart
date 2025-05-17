import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF00897B);
    const inactiveColor = Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(
                icon: Icons.home,
                label: 'Beranda',
                index: 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildItem(
                icon: Icons.calculate,
                label: 'Kalkulator',
                index: 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildItem(
                icon: Icons.schedule,
                label: 'Jadwal',
                index: 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildItem(
                icon: Icons.history,
                label: 'Riwayat',
                index: 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildItem(
                icon: Icons.person_outline,
                label: 'Profil',
                index: 4,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isActive ? 12 : 8),
            decoration: BoxDecoration(
              color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isActive ? 28 : 24,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}