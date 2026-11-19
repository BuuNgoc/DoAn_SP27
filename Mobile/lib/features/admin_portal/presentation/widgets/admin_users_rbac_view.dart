import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

class AdminUserAccount {
  AdminUserAccount({
    required this.uid,
    required this.name,
    required this.email,
    required this.role, // 'ADMIN', 'TOURISM_MANAGER', 'TOURIST'
    required this.department,
    required this.isActive,
    required this.lastLogin,
  });

  final String uid;
  final String name;
  final String email;
  String role;
  final String department;
  bool isActive;
  final String lastLogin;
}

/// [FE-26, FE-27] Quản Lý Người Dùng & Phân Quyền Vai Trò RBAC (Website Admin Portal)
class AdminUsersRbacView extends StatefulWidget {
  const AdminUsersRbacView({super.key});

  @override
  State<AdminUsersRbacView> createState() => _AdminUsersRbacViewState();
}

class _AdminUsersRbacViewState extends State<AdminUsersRbacView> {
  late final List<AdminUserAccount> _users = [
    AdminUserAccount(
      uid: 'user_01',
      name: 'Nguyễn Ngọc Bữu',
      email: 'buunnde180722@fpt.edu.vn',
      role: 'ADMIN',
      department: 'Ban Quản Trị Hệ Thống NHS360',
      isActive: true,
      lastLogin: 'Hôm nay 19:45',
    ),
    AdminUserAccount(
      uid: 'user_02',
      name: 'Lê Thiện Nhật Quang',
      email: 'quangltn3@fe.edu.vn',
      role: 'ADMIN',
      department: 'Phụ Trách Kỹ Thuật & AI Service',
      isActive: true,
      lastLogin: 'Hôm nay 18:20',
    ),
    AdminUserAccount(
      uid: 'user_03',
      name: 'Văn Đức Tài',
      email: 'taivdde180369@fpt.edu.vn',
      role: 'TOURISM_MANAGER',
      department: 'Phòng Quản Lý Điểm Đến & Biển',
      isActive: true,
      lastLogin: 'Hôm nay 16:10',
    ),
    AdminUserAccount(
      uid: 'user_04',
      name: 'Vương Mai Ngân',
      email: 'nganvmde180218@fpt.edu.vn',
      role: 'TOURISM_MANAGER',
      department: 'Phòng Sự Kiện, Làng Nghề & Phố An Thượng',
      isActive: true,
      lastLogin: 'Hôm qua 15:30',
    ),
    AdminUserAccount(
      uid: 'user_05',
      name: 'Du Khách Mẫu Trải Nghiệm',
      email: 'tourist.demo@fe.edu.vn',
      role: 'TOURIST',
      department: 'Tài khoản khách du lịch',
      isActive: true,
      lastLogin: '18/11/2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return TourismCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phân Quyền Vai Trò & Quản Trị Tài Khoản RBAC (FE-26, FE-27)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Chính sách kiểm soát truy cập phân tầng: ADMIN (Toàn quyền), TOURISM_MANAGER (Nội dung CMS & Vận hành) và TOURIST (Du khách)',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openAddUserDialog(context),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('+ Thêm Tài Khoản Quản Trị'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Users Table
          Table(
            border: TableBorder.all(color: AppColors.border, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(2.6),
              1: FlexColumnWidth(2.6),
              2: FlexColumnWidth(2.0),
              3: FlexColumnWidth(2.2),
              4: FlexColumnWidth(1.6),
              5: FlexColumnWidth(1.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: [
                  for (final h in ['Họ Tên Quản Trị Viên', 'Email Tài Khoản', 'Vai Trò (Role)', 'Đơn Vị Phụ Trách', 'Đăng Nhập Gần Nhất', 'Thao Tác'])
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                    ),
                ],
              ),
              for (final u in _users)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(u.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _roleBadgeColor(u.role).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          u.role,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: _roleBadgeColor(u.role)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(u.department, style: const TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(u.lastLogin, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.manage_accounts_rounded, size: 18, color: AppColors.primary),
                            tooltip: 'Đổi quyền',
                            onPressed: () => _openChangeRoleDialog(context, u),
                          ),
                        ],
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

  Color _roleBadgeColor(String role) {
    switch (role) {
      case 'ADMIN':
        return const Color(0xFFDC2626); // Red
      case 'TOURISM_MANAGER':
        return AppColors.primary;
      default:
        return const Color(0xFF475569);
    }
  }

  void _openAddUserDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final deptCtrl = TextEditingController();
    String role = 'TOURISM_MANAGER';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Thêm Tài Khoản Quản Trị Viên (FE-26)'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ và Tên*', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Đăng Nhập (@fpt.edu.vn / @fe.edu.vn)*', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Phân Quyền Vai Trò*', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN - Quản Trị Viên Toàn Quyền')),
                    DropdownMenuItem(value: 'TOURISM_MANAGER', child: Text('TOURISM_MANAGER - Cán Bộ Quản Lý Du Lịch')),
                    DropdownMenuItem(value: 'TOURIST', child: Text('TOURIST - Du Khách Trải Nghiệm')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => role = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Bộ Phận / Phòng Ban Phụ Trách', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                  setState(() {
                    _users.add(
                      AdminUserAccount(
                        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text,
                        email: emailCtrl.text,
                        role: role,
                        department: deptCtrl.text.isNotEmpty ? deptCtrl.text : 'Ban Quản Trị',
                        isActive: true,
                        lastLogin: 'Chưa đăng nhập',
                      ),
                    );
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Tạo Tài Khoản'),
            ),
          ],
        ),
      ),
    );
  }

  void _openChangeRoleDialog(BuildContext context, AdminUserAccount user) {
    String currentRole = user.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Đổi Vai Trò: ${user.name}'),
          content: DropdownButtonFormField<String>(
            value: currentRole,
            decoration: const InputDecoration(labelText: 'Vai Trò Phân Quyền', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN (Toàn quyền hệ thống & RBAC)')),
              DropdownMenuItem(value: 'TOURISM_MANAGER', child: Text('TOURISM_MANAGER (Quản lý CMS du lịch)')),
              DropdownMenuItem(value: 'TOURIST', child: Text('TOURIST (Du khách)')),
            ],
            onChanged: (v) {
              if (v != null) setDialogState(() => currentRole = v);
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                setState(() => user.role = currentRole);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Cập Nhật Vai Trò'),
            ),
          ],
        ),
      ),
    );
  }
}
