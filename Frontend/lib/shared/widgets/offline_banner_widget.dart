import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/connectivity_cubit.dart';

/// Dải thông báo tự hiện khi mất mạng; nội dung đã lưu đệm vẫn xem được.
class OfflineBannerWidget extends StatelessWidget {
  const OfflineBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isOnline) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) =>
              SizeTransition(sizeFactor: animation, alignment: Alignment.topCenter, child: child),
          child: isOnline
              ? const SizedBox(width: double.infinity)
              : Container(
                  key: const ValueKey('offline'),
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16, MediaQuery.paddingOf(context).top + 8, 16, 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF4E6),
                    border: Border(bottom: BorderSide(color: Color(0xFFF7D9B5))),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.warning),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bạn đang ngoại tuyến. Địa điểm yêu thích và nội dung đã lưu vẫn xem được.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF8A5A22),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
