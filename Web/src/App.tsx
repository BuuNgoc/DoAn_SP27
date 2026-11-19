import React, { useState } from 'react';
import { Sidebar, navItems } from './components/Sidebar';
import { Topbar } from './components/Topbar';
import { DashboardOverview } from './components/DashboardOverview';
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

// Mock Data
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

export const App: React.FC = () => {
  const [currentTab, setCurrentTab] = useState<number>(0);
  const [searchQuery, setSearchQuery] = useState<string>('');

  // Datasets State
  const [destinations, setDestinations] = useState(initialDestinations);
  const [scenes, setScenes] = useState(initialVrScenes);
  const [vendors, setVendors] = useState(initialVendors);
  const [beaches, setBeaches] = useState(initialBeaches);
  const [contestEntries, setContestEntries] = useState(initialContestEntries);
  const [bookings, setBookings] = useState(initialBookings);
  const [campaigns, setCampaigns] = useState(initialCampaigns);
  const [users, setUsers] = useState(initialUsers);
  const [auditLogs, setAuditLogs] = useState(initialAuditLogs);

  const activeNav = navItems.find((n) => n.id === currentTab) || navItems[0];

  const renderContent = () => {
    switch (currentTab) {
      case 0:
        return <DashboardOverview onNavigateToTab={(idx) => setCurrentTab(idx)} />;
      case 1:
        return (
          <DestinationsCms
            destinations={destinations}
            onUpdateDestinations={setDestinations}
            searchQuery={searchQuery}
          />
        );
      case 2:
        return <VrHotspotCms scenes={scenes} onUpdateScenes={setScenes} />;
      case 3:
        return <AnThuongCms vendors={vendors} onUpdateVendors={setVendors} />;
      case 4:
        return <BeachTourismCms beaches={beaches} onUpdateBeaches={setBeaches} />;
      case 5:
        return (
          <StoneContestCms
            entries={contestEntries}
            onUpdateEntries={setContestEntries}
          />
        );
      case 6:
        return (
          <WorkshopsCms
            bookings={bookings}
            onUpdateBookings={setBookings}
          />
        );
      case 7:
        return (
          <CampaignAnalyticsCms
            campaigns={campaigns}
            onUpdateCampaigns={setCampaigns}
          />
        );
      case 8:
        return <AiAnalyticsView />;
      case 9:
        return <UsersRbacView users={users} onUpdateUsers={setUsers} />;
      case 10:
        return <AuditSystemView logs={auditLogs} />;
      default:
        return <DashboardOverview onNavigateToTab={(idx) => setCurrentTab(idx)} />;
    }
  };

  return (
    <div className="flex h-screen bg-[#F1F5F9] overflow-hidden">
      {/* ── 1. Desktop Sidebar ────────────────────────────────────────── */}
      <Sidebar currentTab={currentTab} onSelectTab={setCurrentTab} />

      {/* ── 2. Main Workspace ─────────────────────────────────────────── */}
      <div className="flex-1 flex flex-col h-screen overflow-hidden">
        <Topbar
          title={activeNav.title}
          badge={activeNav.badge}
          searchQuery={searchQuery}
          onSearchChange={setSearchQuery}
        />

        <main className="flex-1 overflow-y-auto p-8">
          <div className="max-w-7xl mx-auto">{renderContent()}</div>
        </main>
      </div>
    </div>
  );
};

export default App;
