import React, { useState, useEffect } from "react";
import { 
  Home, 
  Users, 
  Car, 
  ShieldAlert, 
  FileText, 
  Scale, 
  Radio, 
  Shield, 
  Settings, 
  Map as MapIcon,
  Flame,
  AlertTriangle,
  ChevronRight,
  LogOut
} from "lucide-react";
import { 
  MdtAppId, 
  MdtInitialData, 
  OfficerProfile, 
  Warrant, 
  Bolo, 
  IncidentReport, 
  DutyOfficer, 
  DispatchCall, 
  CitizenProfile, 
  VehicleRecord, 
  PenalCodeItem 
} from "./types/mdt";
import { mdtSound } from "./utils/sound";
import MdtHeader from "./components/MdtHeader";
import MdtHomeGrid from "./components/MdtHomeGrid";
import CitizenLookup from "./components/CitizenLookup";
import VehicleLookup from "./components/VehicleLookup";
import WarrantsBolos from "./components/WarrantsBolos";
import IncidentReports from "./components/IncidentReports";
import PenalCode from "./components/PenalCode";
import DispatchManager from "./components/DispatchManager";
import InteractiveMap from "./components/InteractiveMap";
import DepartmentRoster from "./components/DepartmentRoster";
import SettingsModal from "./components/SettingsModal";

function getResourceName() {
  return (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : "cfx-keydi-ui";
}

async function postNui(event: string, data: any = {}) {
  try {
    const res = await fetch(`https://${getResourceName()}/${event}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(data),
    });
    return await res.json();
  } catch {
    return null;
  }
}

interface MdtTabletProps {
  initialData?: MdtInitialData | null;
  onClose: () => void;
}

export default function MdtTablet({ initialData, onClose }: MdtTabletProps) {
  const [currentApp, setCurrentApp] = useState<MdtAppId>("dispatch");
  const [dutyStatus, setDutyStatus] = useState("10-8");
  const [officer, setOfficer] = useState<OfficerProfile | null>(initialData?.officer || null);
  const [warrants, setWarrants] = useState<Warrant[]>(initialData?.warrants || []);
  const [bolos, setBolos] = useState<Bolo[]>(initialData?.bolos || []);
  const [incidents, setIncidents] = useState<IncidentReport[]>(initialData?.recentIncidents || []);
  const [activeOfficers, setActiveOfficers] = useState<DutyOfficer[]>(initialData?.activeOfficers || []);
  const [dispatchCalls, setDispatchCalls] = useState<DispatchCall[]>(initialData?.dispatchCalls || []);
  const [penalCodes, setPenalCodes] = useState<PenalCodeItem[]>(initialData?.penalCodes || []);

  const [citizenSearchResults, setCitizenSearchResults] = useState<CitizenProfile[]>([]);
  const [vehicleSearchResults, setVehicleSearchResults] = useState<VehicleRecord[]>([]);

  // Alerts & Notifications
  const [activeAlert, setActiveAlert] = useState<{ type: string; title: string; message: string; priority?: string } | null>(null);

  // Settings
  const [accentColor, setAccentColor] = useState("cyan");
  const [wallpaper, setWallpaper] = useState("dark");
  const [isMuted, setIsMuted] = useState(false);

  // Sync state if initialData changes
  useEffect(() => {
    if (initialData) {
      if (initialData.officer) setOfficer(initialData.officer);
      if (initialData.warrants) setWarrants(initialData.warrants);
      if (initialData.bolos) setBolos(initialData.bolos);
      if (initialData.recentIncidents) setIncidents(initialData.recentIncidents);
      if (initialData.activeOfficers) setActiveOfficers(initialData.activeOfficers);
      if (initialData.dispatchCalls) setDispatchCalls(initialData.dispatchCalls);
      if (initialData.penalCodes) setPenalCodes(initialData.penalCodes);
    }
  }, [initialData]);

  // Window Message Event Listeners for Live FiveM Sync
  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const data = event.data;
      if (!data || !data.action) return;

      switch (data.action) {
        case "updateCitizenSearchResults":
          setCitizenSearchResults(data.data || []);
          break;

        case "updateVehicleSearchResults":
          setVehicleSearchResults(data.data || []);
          break;

        case "updateMdtWarrants":
          setWarrants(data.data || []);
          break;

        case "updateMdtBolos":
          setBolos(data.data || []);
          break;

        case "updateMdtIncidents":
          setIncidents(data.data || []);
          break;

        case "updateMdtDispatchCalls":
          setDispatchCalls(data.data || []);
          break;

        case "updateMdtDutyUnits":
          setActiveOfficers(data.data || []);
          break;

        case "updateMdtOfficerProfile":
          if (officer) {
            setOfficer({
              ...officer,
              callsign: data.data.callsign || officer.callsign,
              department: data.data.department || officer.department,
              badge_number: data.data.badge_number || officer.badge_number,
            });
          }
          break;

        case "broadcastMdtAlert":
          if (data.data) {
            setActiveAlert(data.data);
            if (data.data.type === 'panic' || data.data.priority === 'urgent') {
              mdtSound.playPanicAlert();
            } else if (data.data.type === 'dispatch') {
              mdtSound.playDispatchAlert();
            } else {
              mdtSound.playNotification();
            }
          }
          break;

        case "closeMdt":
          onClose();
          break;
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, [officer, onClose]);

  // Handle ESC key to close MDT
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        handleCloseTablet();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  const handleCloseTablet = () => {
    mdtSound.playTap();
    postNui("closeMdt");
    onClose();
  };

  const handleOpenApp = (app: MdtAppId) => {
    mdtSound.playTap();
    setCurrentApp(app);
  };

  const handleGoHome = () => {
    mdtSound.playTap();
    setCurrentApp("home");
  };

  const handleSetDutyStatus = (status: string) => {
    mdtSound.playTap();
    setDutyStatus(status);
    postNui("setDutyStatus", { status });
  };

  const handleToggleMute = () => {
    const newMute = !isMuted;
    setIsMuted(newMute);
    mdtSound.setMuted(newMute);
    if (!newMute) mdtSound.playNotification();
  };

  // NUI Actions
  const handleSearchCitizen = (query: string) => {
    mdtSound.playTap();
    postNui("searchCitizen", { query });
  };

  const handleAddCitizenNote = (identifier: string, note: string, imageUrl?: string) => {
    mdtSound.playTap();
    postNui("addCitizenNote", { identifier, note, imageUrl });
  };

  const handleSearchVehicle = (query: string) => {
    mdtSound.playTap();
    postNui("searchVehicle", { query });
  };

  const handleAddVehicleFlag = (plate: string, flagType: string, reason: string) => {
    mdtSound.playTap();
    postNui("addVehicleFlag", { plate, flagType, reason });
  };

  const handleRemoveVehicleFlag = (flagId: number, plate: string) => {
    mdtSound.playTap();
    postNui("removeVehicleFlag", { flagId, plate });
  };

  const handleCreateWarrant = (warrantData: any) => {
    mdtSound.playTap();
    postNui("createWarrant", warrantData);
  };

  const handleDeleteWarrant = (warrantId: number) => {
    mdtSound.playTap();
    postNui("deleteWarrant", { warrantId });
  };

  const handleCreateBolo = (boloData: any) => {
    mdtSound.playTap();
    postNui("createBolo", boloData);
  };

  const handleDeleteBolo = (boloId: number) => {
    mdtSound.playTap();
    postNui("deleteBolo", { boloId });
  };

  const handleSaveIncident = (incidentData: IncidentReport) => {
    mdtSound.playTap();
    postNui("saveIncident", incidentData);
  };

  const handleDeleteIncident = (incidentId: number) => {
    mdtSound.playTap();
    postNui("deleteIncident", { incidentId });
  };

  const handleUpdateProfile = (data: { callsign: string; department: string; badge_number: string }) => {
    mdtSound.playTap();
    postNui("updateOfficerProfile", data);
  };

  const handleAttachUnit = (callId: number) => {
    mdtSound.playTap();
    postNui("attachUnitToCall", { callId });
  };

  const handleResolveCall = (callId: number) => {
    mdtSound.playTap();
    postNui("resolveDispatchCall", { callId });
  };

  const handleSetGpsWaypoint = (coords: { x: number; y: number; z?: number }) => {
    mdtSound.playTap();
    postNui("setGpsWaypoint", { coords });
  };

  const handleTriggerPanic = () => {
    mdtSound.playPanicAlert();
    postNui("triggerPanic");
  };

  const activeWarrantsCount = warrants.filter(w => w.status === 'Active').length;
  const activeBolosCount = bolos.filter(b => b.status === 'active').length;
  const activeCallsCount = dispatchCalls.filter(c => c.status === 'active').length;

  const navItems = [
    { id: "dashboard" as MdtAppId, target: "home" as MdtAppId, label: "Overview", icon: Home, badge: 0 },
    { id: "dispatch" as MdtAppId, target: "dispatch" as MdtAppId, label: "CAD & GTA Map", icon: Radio, badge: activeCallsCount },
    { id: "map" as MdtAppId, target: "map" as MdtAppId, label: "Full Tactical Map", icon: MapIcon, badge: 0 },
    { id: "citizens" as MdtAppId, target: "citizens" as MdtAppId, label: "Citizens Database", icon: Users, badge: 0 },
    { id: "vehicles" as MdtAppId, target: "vehicles" as MdtAppId, label: "Vehicle Records", icon: Car, badge: 0 },
    { id: "warrants" as MdtAppId, target: "warrants" as MdtAppId, label: "Warrants & BOLOs", icon: ShieldAlert, badge: activeWarrantsCount + activeBolosCount },
    { id: "incidents" as MdtAppId, target: "incidents" as MdtAppId, label: "Incident Reports", icon: FileText, badge: incidents.length },
    { id: "penal" as MdtAppId, target: "penal" as MdtAppId, label: "Penal Code", icon: Scale, badge: 0 },
    { id: "roster" as MdtAppId, target: "roster" as MdtAppId, label: "Roster & Setup", icon: Shield, badge: activeOfficers.length },
    { id: "settings" as MdtAppId, target: "settings" as MdtAppId, label: "Terminal Settings", icon: Settings, badge: 0 },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-5 bg-black/80 backdrop-blur-md select-none">
      {/* iPad Outer Bezel with Solid Graphite Shell */}
      <div className="relative w-full max-w-[1440px] h-[92vh] max-h-[940px] rounded-[36px] bg-[#070b14] p-3 shadow-2xl ring-1 ring-slate-700/80 border-4 border-[#121827] flex flex-col overflow-hidden">
        
        {/* Inner Solid Display Screen */}
        <div className="relative flex-1 rounded-[26px] overflow-hidden flex flex-col bg-[#090d18] border border-slate-800 shadow-inner">
          
          {/* Top Status Bar & Dynamic Island */}
          <MdtHeader
            officer={officer}
            dutyStatus={dutyStatus}
            activeAlert={activeAlert}
            onClearAlert={() => setActiveAlert(null)}
            isMuted={isMuted}
            onToggleMute={handleToggleMute}
            onOpenPanic={handleTriggerPanic}
            onGoHome={handleGoHome}
          />

          {/* Body with Persistent Left Sidebar + Right Multi-Panel Workspace */}
          <div className="flex-1 flex overflow-hidden">
            
            {/* Left Persistent Navigation Sidebar */}
            <aside className="w-64 bg-[#070b14] border-r border-slate-800 flex flex-col justify-between shrink-0 p-3 select-none">
              <div className="space-y-3">
                {/* Officer Quick Badge Card */}
                <div className="p-3 rounded-2xl bg-[#0e1424] border border-slate-800 shadow-md">
                  <div className="flex items-center gap-2.5 mb-2">
                    <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-cyan-600 to-blue-700 flex items-center justify-center text-white font-black text-xs shadow-md border border-cyan-400/30">
                      <Shield className="w-5 h-5" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-xs font-black text-white truncate">
                        {officer ? officer.name : "Officer"}
                      </div>
                      <div className="text-[10px] font-mono text-cyan-300 font-bold truncate">
                        {officer?.department || "LSPD"} • {officer?.callsign || "1-A-01"}
                      </div>
                    </div>
                  </div>

                  {/* 10-Code Duty Status Selector */}
                  <div className="pt-2 border-t border-slate-800 flex items-center justify-between">
                    <span className="text-[10px] uppercase font-bold text-slate-400">Duty:</span>
                    <select
                      value={dutyStatus}
                      onChange={(e) => handleSetDutyStatus(e.target.value)}
                      className="px-2 py-0.5 rounded-lg bg-slate-900 border border-slate-700 text-white text-[11px] font-bold font-mono focus:outline-none focus:border-cyan-500 cursor-pointer"
                    >
                      <option value="10-8">10-8 Available</option>
                      <option value="10-6">10-6 Busy</option>
                      <option value="10-97">10-97 On Scene</option>
                      <option value="10-7">10-7 Off Duty</option>
                      <option value="10-99">10-99 Panic</option>
                    </select>
                  </div>
                </div>

                {/* Sidebar Navigation Items */}
                <nav className="space-y-1">
                  {navItems.map((item) => {
                    const Icon = item.icon;
                    const isActive = currentApp === item.target;
                    return (
                      <button
                        key={item.id}
                        onClick={() => handleOpenApp(item.target)}
                        className={`w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-bold transition-all ${
                          isActive
                            ? 'bg-cyan-600 text-white shadow-lg shadow-cyan-600/30 ring-1 ring-cyan-400/50'
                            : 'text-slate-400 hover:text-white hover:bg-slate-800/60'
                        }`}
                      >
                        <div className="flex items-center gap-2.5">
                          <Icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-slate-400'}`} />
                          <span>{item.label}</span>
                        </div>

                        {item.badge > 0 && (
                          <span className={`px-1.5 py-0.2 rounded-full text-[9px] font-black ${
                            isActive ? 'bg-white text-cyan-900' : 'bg-red-600 text-white shadow-sm'
                          }`}>
                            {item.badge}
                          </span>
                        )}
                      </button>
                    );
                  })}
                </nav>
              </div>

              {/* Bottom 911 Calls Quick Alert Ticker */}
              <div className="pt-3 border-t border-slate-800 space-y-2">
                <div 
                  onClick={() => handleOpenApp("dispatch")}
                  className="p-2.5 rounded-xl bg-[#0e1424] border border-cyan-500/30 hover:border-cyan-500 cursor-pointer transition-all flex items-center justify-between"
                >
                  <div className="flex items-center gap-2">
                    <span className="w-2 h-2 rounded-full bg-cyan-400 animate-ping" />
                    <span className="text-[11px] font-bold text-white">911 CAD Live</span>
                  </div>
                  <span className="text-[10px] font-mono text-cyan-300 font-bold px-1.5 py-0.2 rounded bg-cyan-950 border border-cyan-500/40">
                    {activeCallsCount} Active
                  </span>
                </div>

                <button
                  onClick={handleCloseTablet}
                  className="w-full py-1.5 rounded-xl bg-slate-900 hover:bg-red-600/30 border border-slate-800 hover:border-red-500/50 text-slate-400 hover:text-red-300 text-xs font-bold flex items-center justify-center gap-1.5 transition-all"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  Exit Terminal (ESC)
                </button>
              </div>
            </aside>

            {/* Main Center-Right Workspace Display */}
            <main className="flex-1 flex flex-col overflow-hidden bg-[#090d18] relative">
              {currentApp === "home" && (
                <MdtHomeGrid
                  officer={officer}
                  dutyStatus={dutyStatus}
                  onSetDutyStatus={handleSetDutyStatus}
                  onOpenApp={handleOpenApp}
                  warrants={warrants}
                  bolos={bolos}
                  incidents={incidents}
                  activeOfficers={activeOfficers}
                  dispatchCalls={dispatchCalls}
                />
              )}

              {currentApp === "dispatch" && (
                <DispatchManager
                  dispatchCalls={dispatchCalls}
                  activeOfficers={activeOfficers}
                  currentOfficer={officer}
                  onSetGpsWaypoint={handleSetGpsWaypoint}
                  onAttachUnit={handleAttachUnit}
                  onResolveCall={handleResolveCall}
                  onTriggerPanic={handleTriggerPanic}
                />
              )}

              {currentApp === "map" && (
                <div className="flex-1 p-3 flex flex-col bg-[#0a0e19] overflow-hidden">
                  <div className="flex items-center justify-between mb-2">
                    <div className="flex items-center gap-2">
                      <MapIcon className="w-4 h-4 text-cyan-400" />
                      <h3 className="text-xs font-bold uppercase tracking-wider text-white">
                        Full-Screen Tactical GTA 5 Map & Active Beacons
                      </h3>
                    </div>
                    <span className="text-[10px] font-mono text-cyan-400">PAN & ZOOM ENABLED</span>
                  </div>
                  <div className="flex-1 rounded-2xl overflow-hidden shadow-2xl border border-slate-800">
                    <InteractiveMap
                      dispatchCalls={dispatchCalls}
                      activeOfficers={activeOfficers}
                      currentOfficer={officer}
                      onSetGpsWaypoint={handleSetGpsWaypoint}
                      onAttachUnit={handleAttachUnit}
                      onResolveCall={handleResolveCall}
                    />
                  </div>
                </div>
              )}

              {currentApp === "citizens" && (
                <CitizenLookup
                  searchResults={citizenSearchResults}
                  onSearch={handleSearchCitizen}
                  onAddNote={handleAddCitizenNote}
                  onCreateWarrant={handleCreateWarrant}
                  onOpenVehicle={(plate) => {
                    handleSearchVehicle(plate);
                    handleOpenApp("vehicles");
                  }}
                  penalCodes={penalCodes}
                />
              )}

              {currentApp === "vehicles" && (
                <VehicleLookup
                  searchResults={vehicleSearchResults}
                  onSearch={handleSearchVehicle}
                  onAddFlag={handleAddVehicleFlag}
                  onRemoveFlag={handleRemoveVehicleFlag}
                  onOpenCitizen={(name) => {
                    handleSearchCitizen(name);
                    handleOpenApp("citizens");
                  }}
                />
              )}

              {currentApp === "warrants" && (
                <WarrantsBolos
                  warrants={warrants}
                  bolos={bolos}
                  onDeleteWarrant={handleDeleteWarrant}
                  onCreateBolo={handleCreateBolo}
                  onDeleteBolo={handleDeleteBolo}
                  onOpenCitizen={(name) => {
                    handleSearchCitizen(name);
                    handleOpenApp("citizens");
                  }}
                  onOpenVehicle={(plate) => {
                    handleSearchVehicle(plate);
                    handleOpenApp("vehicles");
                  }}
                />
              )}

              {currentApp === "incidents" && (
                <IncidentReports
                  incidents={incidents}
                  penalCodes={penalCodes}
                  currentOfficer={officer}
                  onSaveIncident={handleSaveIncident}
                  onDeleteIncident={handleDeleteIncident}
                  onOpenCitizen={(name) => {
                    handleSearchCitizen(name);
                    handleOpenApp("citizens");
                  }}
                />
              )}

              {currentApp === "penal" && (
                <PenalCode penalCodes={penalCodes} />
              )}

              {currentApp === "roster" && (
                <DepartmentRoster
                  currentOfficer={officer}
                  activeOfficers={activeOfficers}
                  onUpdateProfile={handleUpdateProfile}
                />
              )}

              {currentApp === "settings" && (
                <SettingsModal
                  accentColor={accentColor}
                  onSetAccentColor={setAccentColor}
                  wallpaper={wallpaper}
                  onSetWallpaper={setWallpaper}
                  isMuted={isMuted}
                  onToggleMute={handleToggleMute}
                />
              )}
            </main>
          </div>

          {/* iPad Bottom Home Gesture Indicator */}
          <footer className="relative z-30 py-1.5 flex items-center justify-center bg-[#070b14] border-t border-slate-800">
            <div
              onClick={handleCloseTablet}
              className="w-36 h-1 rounded-full bg-slate-600 hover:bg-cyan-400 hover:w-44 transition-all duration-300 cursor-pointer shadow-md"
              title="Click to Close MDT"
            />
          </footer>
        </div>
      </div>
    </div>
  );
}
