import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_travel_app/core/constants/app_colors.dart';
import 'package:smart_travel_app/core/constants/app_dimensions.dart';
import 'package:smart_travel_app/shared/widgets/tourism_bottom_navigation.dart';
import 'package:smart_travel_app/shared/widgets/tourism_components.dart';

void main() {
  group('Shangri-La Luxury Design Tokens Tests', () {
    test('AppColors matches Shangri-La luxury hospitality specifications', () {
      expect(AppColors.primary, const Color(0xFF173F35));
      expect(AppColors.primaryLight, const Color(0xFF244C40));
      expect(AppColors.warmIvory, const Color(0xFFF8F6F0));
      expect(AppColors.sandBeige, const Color(0xFFE8DFD0));
      expect(AppColors.softGold, const Color(0xFFB69A67));
      expect(AppColors.textPrimary, const Color(0xFF242824));
      expect(AppColors.textSecondary, const Color(0xFF777A73));
      expect(AppColors.textMuted, const Color(0xFFA1A39D));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.background, const Color(0xFFF8F7F3));
    });

    test('AppDimensions complies with 4-8-12-16-24-32-40-48 spacing scale', () {
      expect(AppDimensions.s4, 4.0);
      expect(AppDimensions.s8, 8.0);
      expect(AppDimensions.s12, 12.0);
      expect(AppDimensions.s16, 16.0);
      expect(AppDimensions.s24, 24.0);
      expect(AppDimensions.s32, 32.0);
      expect(AppDimensions.s40, 40.0);
      expect(AppDimensions.s48, 48.0);

      expect(AppDimensions.radius8, 8.0);
      expect(AppDimensions.radius12, 12.0);
      expect(AppDimensions.radius16, 16.0);
      expect(AppDimensions.radius20, 20.0);
    });
  });

  group('Shangri-La Components Widget Tests', () {
    testWidgets('HotelCard displays hotel name, stars, location and price per night', (tester) async {
      bool bookingTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotelCard(
              name: 'Shangri-La Da Nang Resort',
              imageUrl: '',
              location: 'Non Nuoc Beach',
              pricePerNight: '4.850.000đ',
              stars: 5,
              onBookingTap: () => bookingTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Shangri-La Da Nang Resort'), findsOneWidget);
      expect(find.text('5-STAR LUXURY'), findsOneWidget);
      expect(find.text('Non Nuoc Beach'), findsOneWidget);
      expect(find.text('4.850.000đ'), findsOneWidget);
      expect(find.text('Đặt phòng'), findsOneWidget);

      await tester.tap(find.text('Đặt phòng'));
      expect(bookingTapped, isTrue);
    });

    testWidgets('ExperienceCard displays workshop details and action button', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExperienceCard(
              title: 'Workshop Điêu Khắc Đá Non Nước',
              imageUrl: '',
              location: 'Làng Đá Non Nước',
              duration: '90 phút',
              price: '350.000đ',
              category: 'LÀNG NGHỀ TRUYỀN THỐNG',
              onActionTap: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Workshop Điêu Khắc Đá Non Nước'), findsOneWidget);
      expect(find.text('Làng Đá Non Nước'), findsOneWidget);
      expect(find.text('90 phút'), findsOneWidget);
      expect(find.text('350.000đ'), findsOneWidget);
      expect(find.text('LÀNG NGHỀ TRUYỀN THỐNG'), findsOneWidget);
      expect(find.text('Khám phá'), findsOneWidget);

      await tester.tap(find.text('Khám phá'));
      expect(actionTapped, isTrue);
    });

    testWidgets('TourismBottomNavigation renders 5 tabs and fires onTap correctly', (tester) async {
      int tappedIndex = -1;

      final items = [
        const TourismNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Trang chủ'),
        const TourismNavItem(icon: Icons.explore_outlined, selectedIcon: Icons.explore, label: 'Khám phá'),
        const TourismNavItem(icon: Icons.map_outlined, selectedIcon: Icons.map, label: 'Bản đồ'),
        const TourismNavItem(icon: Icons.luggage_outlined, selectedIcon: Icons.luggage, label: 'Hành trình'),
        const TourismNavItem(icon: Icons.person_outlined, selectedIcon: Icons.person, label: 'Cá nhân'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TourismBottomNavigation(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
              items: items,
            ),
          ),
        ),
      );

      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Khám phá'), findsOneWidget);
      expect(find.text('Bản đồ'), findsOneWidget);
      expect(find.text('Hành trình'), findsOneWidget);
      expect(find.text('Cá nhân'), findsOneWidget);

      await tester.tap(find.text('Khám phá'));
      expect(tappedIndex, equals(1));

      await tester.tap(find.text('Hành trình'));
      expect(tappedIndex, equals(3));
    });
  });
}
