import React, { createContext, useContext, useState, useEffect } from 'react';
import {
  auth,
  getUserRole,
  loginWithRbac,
  logoutAdmin,
  AdminUserProfile,
  UserRole,
} from '../services/firebase';
import { onAuthStateChanged } from 'firebase/auth';

interface AuthContextType {
  currentUser: AdminUserProfile | null;
  loading: boolean;
  login: (email: string, pass: string) => Promise<AdminUserProfile>;
  logout: () => Promise<void>;
  demoLogin: (role: UserRole) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const DEMO_USERS: Record<UserRole, AdminUserProfile> = {
  ADMIN: {
    uid: 'demo-admin-ubnd-001',
    email: 'admin.nhs@danang.gov.vn',
    displayName: 'ThS. Nguyễn Văn Quản Trị',
    role: 'ADMIN',
    department: 'Trung tâm CNTT & Giám sát Thông minh Ngũ Hành Sơn',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
  },
  TOURISM_MANAGER: {
    uid: 'demo-manager-bql-002',
    email: 'quanly.danhthang@danang.gov.vn',
    displayName: 'Lê Hoàng Minh',
    role: 'TOURISM_MANAGER',
    department: 'Ban Quản Lý Di Tích & Danh Thắng Ngũ Hành Sơn',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
  },
  TOURIST: {
    uid: 'demo-tourist-003',
    email: 'alex.tourist@gmail.com',
    displayName: 'Alex Smith',
    role: 'TOURIST',
    department: 'Khách du lịch quốc tế',
    avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=200&q=80',
  },
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [currentUser, setCurrentUser] = useState<AdminUserProfile | null>(() => {
    // Check local storage for quick reload preservation
    const saved = localStorage.getItem('smarttravel_admin_session');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        return null;
      }
    }
    return null;
  });

  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (fbUser) => {
      if (fbUser) {
        try {
          const role = await getUserRole(fbUser);
          if (role !== 'TOURIST') {
            const profile: AdminUserProfile = {
              uid: fbUser.uid,
              email: fbUser.email,
              displayName: fbUser.displayName || (role === 'ADMIN' ? 'Tổng Quản Trị' : 'Cán Bộ Du Lịch'),
              role,
              department: role === 'ADMIN' ? 'Quản Trị Hệ Thống' : 'Ban Quản Lý Danh Thắng',
            };
            setCurrentUser(profile);
            localStorage.setItem('smarttravel_admin_session', JSON.stringify(profile));
          } else {
            // Tourist is blocked from admin session
            setCurrentUser(null);
            localStorage.removeItem('smarttravel_admin_session');
          }
        } catch {
          setCurrentUser(null);
        }
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const login = async (email: string, pass: string): Promise<AdminUserProfile> => {
    setLoading(true);
    try {
      const profile = await loginWithRbac(email, pass);
      setCurrentUser(profile);
      localStorage.setItem('smarttravel_admin_session', JSON.stringify(profile));
      return profile;
    } finally {
      setLoading(false);
    }
  };

  const demoLogin = (role: UserRole) => {
    if (role === 'TOURIST') {
      throw new Error('Tài khoản Du khách (TOURIST) không có quyền truy cập Cổng Quản trị.');
    }
    const profile = DEMO_USERS[role];
    setCurrentUser(profile);
    localStorage.setItem('smarttravel_admin_session', JSON.stringify(profile));
  };

  const logout = async () => {
    try {
      await logoutAdmin();
    } catch {
      // Ignore if was demo session
    }
    setCurrentUser(null);
    localStorage.removeItem('smarttravel_admin_session');
  };

  return (
    <AuthContext.Provider value={{ currentUser, loading, login, logout, demoLogin }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
