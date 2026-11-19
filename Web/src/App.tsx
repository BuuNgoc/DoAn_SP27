import React, { useState, useEffect } from 'react';
import { AuthProvider, useAuth } from './contexts/AuthContext';
import { LandingPage } from './pages/landing/LandingPage';
import { LoginPage } from './pages/auth/LoginPage';
import { Sidebar } from './components/Sidebar';
import { Topbar } from './components/Topbar';
import { DashboardOverview } from './components/DashboardOverview';

// CMS Modules (FE-17 to FE-28)
import { DestinationsCms } from './components/DestinationsCms';
import { VrHotspotCms } from './components/VrHotspotCms';
import { AnThuongCms } from './components/AnThuongCms';
import { BeachTourismCms } from './components/BeachTourismCms';
import { StoneContestCms } from './components/StoneContestCms';
import { WorkshopsCms } from './components/WorkshopsCms';
import { CampaignAnalyticsCms } from './components/CampaignAnalyticsCms';
import { AiAnalyticsView } from './components/AiAnalyticsView';
import { UsersRbacView } from './components/UsersRbacView';
import { AuditSystemView } from './components/AuditSystemView';

// Rich Datasets
import {
  initialDestinations,
  initialVrScenes,
  initialVendors,
  initialBeaches,
  initialContestEntries,
  initialBookings,
  initialCampaigns,
  initialUsers,
  initialAuditLogs,
} from './data/mockData';

const AppContent: React.FC = () => {
  const { currentUser, logout } = useAuth();

  // Navigation Route State: 'landing' | 'login' | 'admin'
  const [route, setRoute] = useState<'landing' | 'login' | 'admin'>(() => {
    const path = window.location.pathname;
    if (path.startsWith('/admin')) {
      return 'admin';
    }
    if (path === '/login') {
      return 'login';
    }
    return 'landing';
  });

  // Current Admin Tab
  const [currentAdminTab, setCurrentAdminTab] = useState<string>('dashboard');
  const [sidebarCollapsed, setSidebarCollapsed] = useState<boolean>(false);
  const [isRefreshing, setIsRefreshing] = useState<boolean>(false);
  const [searchQuery, setSearchQuery] = useState<string>('');

  // Synchronize browser history / URL path
  const navigateTo = (newRoute: 'landing' | 'login' | 'admin', adminTab?: string) => {
    setRoute(newRoute);
    if (newRoute === 'landing') {
      window.history.pushState({}, '', '/');
    } else if (newRoute === 'login') {
      window.history.pushState({}, '', '/login');
    } else if (newRoute === 'admin') {
      const tab = adminTab || currentAdminTab;
      if (adminTab) setCurrentAdminTab(adminTab);
      window.history.pushState({}, '', `/admin/${tab}`);
    }
  };

  // Handle browser popstate (back/forward buttons)
  useEffect(() => {
    const handlePopState = () => {
      const path = window.location.pathname;
      if (path.startsWith('/admin')) {
        const sub = path.replace('/admin/', '').replace('/admin', '');
        setRoute('admin');
        if (sub) setCurrentAdminTab(sub);
      } else if (path === '/login') {
        setRoute('login');
      } else {
        setRoute('landing');
      }
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  // Datasets State
  const [destinations, setDestinations] = useState(initialDestinations);
  const [scenes, setScenes] = useState(initialVrScenes);
  const [vendors, setVendors] = useState(initialVendors);
  const [beaches, setBeaches] = useState(initialBeaches);
  const [contests, setContests] = useState(initialContestEntries);
  const [bookings, setBookings] = useState(initialBookings);
  const [campaigns, setCampaigns] = useState(initialCampaigns);
  const [users, setUsers] = useState(initialUsers);
  const [auditLogs, setAuditLogs] = useState(initialAuditLogs);

  const handleRefreshData = () => {
    setIsRefreshing(true);
    setTimeout(() => {
      setIsRefreshing(false);
    }, 600);
  };

  // ── ROUTE 1: LANDING PAGE (PUBLIC) ───────────────────────────────────
  if (route === 'landing') {
    return (
      <LandingPage
        onNavigateToLogin={() => navigateTo('login')}
        onNavigateToAdmin={() => navigateTo('admin', 'dashboard')}
        isLoggedIn={Boolean(currentUser && currentUser.role !== 'TOURIST')}
      />
    );
  }

  // ── ROUTE 2: LOGIN PAGE (AUTHENTICATION) ──────────────────────────────
  if (route === 'login') {
    return (
      <LoginPage
        onLoginSuccess={() => navigateTo('admin', 'dashboard')}
        onNavigateHome={() => navigateTo('landing')}
      />
    );
  }

  // ── ROUTE 3: PROTECTED ADMIN PORTAL ───────────────────────────────────
  // RBAC Guard: If not logged in, redirect to login page
  if (!currentUser || currentUser.role === 'TOURIST') {
    return (
      <LoginPage
        onLoginSuccess={() => navigateTo('admin', 'dashboard')}
        onNavigateHome={() => navigateTo('landing')}
      />
    );
  }

  return (
    <div className="flex h-screen bg-[#FAF7F2] text-[#242824] overflow-hidden">
      {/* Collapsible Luxury Sidebar */}
      <Sidebar
        currentTab={currentAdminTab}
        onSelectTab={(tabId) => navigateTo('admin', tabId)}
        currentUser={currentUser}
        onLogout={async () => {
          await logout();
          navigateTo('landing');
        }}
        onNavigateLanding={() => navigateTo('landing')}
        collapsed={sidebarCollapsed}
        onToggleCollapsed={() => setSidebarCollapsed(!sidebarCollapsed)}
      />

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {/* Topbar */}
        <Topbar
          currentTab={currentAdminTab}
          currentUser={currentUser}
          onRefreshData={handleRefreshData}
          isRefreshing={isRefreshing}
          onNavigateLanding={() => navigateTo('landing')}
        />

        {/* Dynamic Page Content */}
        <main className="flex-1 overflow-y-auto p-4 sm:p-6 lg:p-8">
          <div className="max-w-7xl mx-auto">
            {/* Nhóm 0: Tổng quan */}
            {currentAdminTab === 'dashboard' && (
              <DashboardOverview
                onNavigateToTab={(tabId) => navigateTo('admin', tabId)}
                isLoading={isRefreshing}
              />
            )}

            {currentAdminTab === 'analytics' && (
              <AiAnalyticsView />
            )}

            {/* Nhóm 1: Nội dung Du lịch */}
            {currentAdminTab === 'destinations' && (
              <DestinationsCms
                destinations={destinations}
                onUpdateDestinations={setDestinations}
                searchQuery={searchQuery}
              />
            )}

            {currentAdminTab === 'specialized-zones' && (
              <div className="space-y-8">
                <AnThuongCms
                  vendors={vendors}
                  onUpdateVendors={setVendors}
                />
                <BeachTourismCms
                  beaches={beaches}
                  onUpdateBeaches={setBeaches}
                />
              </div>
            )}

            {currentAdminTab === 'multimedia' && (
              <VrHotspotCms
                scenes={scenes}
                onUpdateScenes={setScenes}
              />
            )}

            {/* Nhóm 2: Sự kiện & Làng nghề */}
            {currentAdminTab === 'events' && (
              <WorkshopsCms
                bookings={bookings}
                onUpdateBookings={setBookings}
              />
            )}

            {currentAdminTab === 'artisans' && (
              <StoneContestCms
                entries={contests}
                onUpdateEntries={setContests}
              />
            )}

            {currentAdminTab === 'contests' && (
              <StoneContestCms
                entries={contests}
                onUpdateEntries={setContests}
              />
            )}

            {/* Nhóm 3: Check-in, Quà tặng & Quảng bá */}
            {currentAdminTab === 'loyalty' && (
              <WorkshopsCms
                bookings={bookings}
                onUpdateBookings={setBookings}
              />
            )}

            {currentAdminTab === 'campaigns' && (
              <CampaignAnalyticsCms
                campaigns={campaigns}
                onUpdateCampaigns={setCampaigns}
              />
            )}

            {/* Nhóm 4: Quản trị Hệ thống (Admin Only) */}
            {currentAdminTab === 'users' && (
              <UsersRbacView
                users={users}
                onUpdateUsers={setUsers}
              />
            )}

            {currentAdminTab === 'system' && (
              <AuditSystemView
                logs={auditLogs}
              />
            )}
          </div>
        </main>
      </div>
    </div>
  );
};

export const App: React.FC = () => {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
};

export default App;
