import 'package:flutter/material.dart';

/// Item trong thanh điều hướng SmartTravel Ngũ Hành Sơn.
class TourismNavItem {
  const TourismNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? badge;
}

/// [Ảnh Mẫu 2] Thanh điều hướng phong cách Shangri-La Deep Forest Green.
/// Màu xanh thẳm sang trọng (#132B2E / #173F35), bo góc tinh tế, biểu tượng vàng kim khi active.
class TourismBottomNavigation extends StatelessWidget {
  const TourismBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<TourismNavItem> items;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF132B2E), // Deep Forest Green luxury
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 8),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++)
                _NavItemWidget(
                  item: items[i],
                  isSelected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final TourismNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    size: 22,
                    color: isSelected ? const Color(0xFFFAF7F2) : const Color(0xFF8FA8A1),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: isSelected ? 0.2 : 0.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFFFAF7F2) : const Color(0xFF8FA8A1),
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE4B85E), // Soft Gold dot
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
