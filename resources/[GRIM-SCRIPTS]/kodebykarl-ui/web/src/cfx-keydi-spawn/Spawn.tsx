import React, { useState, useEffect, useRef } from "react";
import { 
  Clock, Minimize2, MapPin, BarChart3, Sun, Moon, X, 
  ZoomIn, ZoomOut, RotateCcw, Move
} from "lucide-react";
import pandoraLogo from "@/assets/pandora-city-logo.png";
import { SPAWN_MAP_DAY, SPAWN_MAP_NIGHT, preloadSpawnMaps } from "./preloadMaps";

export interface SpawnLocation {
  id: string;
  name: string;
  description: string;
  coords: { x: number; y: number; z: number; heading?: number };
  mapX: number; // Percentage X for map marker placement (0 - 100)
  mapY: number; // Percentage Y for map marker placement (0 - 100)
  type?: "garage" | "food" | "hospital" | "motel" | "landmark" | "last" | "police";
  image?: string;
  jobs?: string[];
}

export interface SpawnRecap {
  killer?: { name: string; id: number };
  combat?: {
    weapon?: string;
    distance?: number;
    damageReceived?: number;
    damageDealt?: number;
    headshot?: boolean;
    fatalZone?: string;
    hitZones?: {
      head?: number;
      neck?: number;
      torso?: number;
      arm?: number;
      leg?: number;
    };
  };
  isSuicide?: boolean;
}

export interface SpawnData {
  isDeathCam?: boolean;
  respawnTimer?: number; // seconds
  allowEarlySpawn?: boolean;
  isBleedout?: boolean;
  locations?: SpawnLocation[];
  recap?: SpawnRecap | null;
}

interface SpawnProps {
  visible?: boolean;
  data?: SpawnData;
  onClose?: () => void;
}

const DEFAULT_LOCATIONS: SpawnLocation[] = [
  {
    id: "stl_morgue",
    name: "STL Spawn (Morgue)",
    description: "Rockford Hills morgue — $1,000 fee · 5 min recovery (2 min crutch).",
    coords: { x: -1679.9622, y: -291.5636, z: 51.8834, heading: 151.5166 },
    mapX: 36.5,
    mapY: 66.8,
    type: "hospital",
    image: "https://images.unsplash.com/photo-1586773860418-d37222d8fce3?q=80&w=600&auto=format&fit=crop"
  },
  {
    id: "police_station",
    name: "Police Station",
    description: "Mission Row PD respawn — Police only.",
    coords: { x: 485.8881, y: -916.4838, z: 26.2386, heading: 272.8872 },
    mapX: 54.2,
    mapY: 71.5,
    type: "police",
    jobs: ["police"],
    image: "https://images.unsplash.com/photo-1589829545856-d10d557cf95f?q=80&w=600&auto=format&fit=crop"
  },
];

const fetchNui = async (eventName: string, data?: any) => {
  try {
    const resourceName = (window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'cfx-keydi-ui';
    const response = await fetch(`https://${resourceName}/${eventName}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data || {})
    });
    return await response.json();
  } catch (err) {
    return null;
  }
};

export const Spawn: React.FC<SpawnProps> = ({ visible = true, data, onClose }) => {
  const isDeathCam      = data?.isDeathCam ?? true;
  const initialLocations = data?.locations?.length ? data.locations : DEFAULT_LOCATIONS;
  
  const [selectedId, setSelectedId] = useState<string>(initialLocations[0]?.id || "stop_car");
  const [activeTab, setActiveTab] = useState<"spawn" | "recap">("spawn");
  const [timeLeft, setTimeLeft] = useState<number>(data?.respawnTimer ?? 900);
  const [allowEarlySpawn, setAllowEarlySpawn] = useState<boolean>(data?.allowEarlySpawn !== false);
  const [isBleedout, setIsBleedout] = useState<boolean>(data?.isBleedout === true);
  const [isNightMode, setIsNightMode] = useState<boolean>(true);
  const [showPopup, setShowPopup] = useState<boolean>(true);
  const [liveRecap, setLiveRecap] = useState<SpawnRecap | null>(data?.recap || null);
  const [zoom, setZoom] = useState<number>(1);
  const [pan, setPan] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState<boolean>(false);
  const [dragStart, setDragStart] = useState<{ x: number; y: number }>({ x: 0, y: 0 });
  const mapRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    preloadSpawnMaps();
  }, []);

  useEffect(() => {
    if (!visible) return;
    setZoom(1);
    setPan({ x: 0, y: 0 });
    setShowPopup(true);
    setActiveTab("spawn");
    setSelectedId(initialLocations[0]?.id || "stop_car");
  }, [visible]);

  // Sync timer when opened or updated from ambulance death timer
  useEffect(() => {
    if (typeof data?.respawnTimer === 'number') {
      setTimeLeft(Math.max(0, data.respawnTimer));
    }
    setAllowEarlySpawn(data?.allowEarlySpawn !== false);
    setIsBleedout(data?.isBleedout === true);
  }, [data?.respawnTimer, data?.allowEarlySpawn, data?.isBleedout, visible]);

  useEffect(() => {
    setLiveRecap(data?.recap || null);
  }, [data?.recap, visible]);

  useEffect(() => {
    const onMessage = (event: MessageEvent) => {
      const payload = event.data;
      if (payload?.action === 'cfx-keydi-spawn:updateTimer' && typeof payload.data?.respawnTimer === 'number') {
        setTimeLeft(Math.max(0, payload.data.respawnTimer));
      }
      if (payload?.action === 'cfx-keydi-spawn:setPhase') {
        if (typeof payload.data?.respawnTimer === 'number') {
          setTimeLeft(Math.max(0, payload.data.respawnTimer));
        }
        if (typeof payload.data?.allowEarlySpawn === 'boolean') {
          setAllowEarlySpawn(payload.data.allowEarlySpawn);
        }
        if (typeof payload.data?.isBleedout === 'boolean') {
          setIsBleedout(payload.data.isBleedout);
        }
      }
      if (payload?.action === 'cfx-keydi-spawn:updateRecap') {
        setLiveRecap(payload.data?.recap || null);
      }
    };
    window.addEventListener('message', onMessage);
    return () => window.removeEventListener('message', onMessage);
  }, []);

  // Countdown timer effect
  useEffect(() => {
    if (!visible) return;
    const interval = setInterval(() => {
      setTimeLeft((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(interval);
  }, [visible]);

  // Handle location selection (UI only — camera stays at death spot until Spawn Here)
  const handleSelectLocation = (loc: SpawnLocation) => {
    setSelectedId(loc.id);
    setShowPopup(true);
  };

  // Drag Panning Handlers with Clamping
  const handleMouseDown = (e: React.MouseEvent) => {
    if (e.button !== 0) return;
    setIsDragging(true);
    setDragStart({ x: e.clientX - pan.x, y: e.clientY - pan.y });
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging) return;
    const rawX = e.clientX - dragStart.x;
    const rawY = e.clientY - dragStart.y;

    if (!mapRef.current) {
      setPan({ x: rawX, y: rawY });
      return;
    }

    const rect = mapRef.current.getBoundingClientRect();
    const maxPanX = Math.max((rect.width * Math.max(zoom, 1)) / 2, rect.width * 0.6);
    const maxPanY = Math.max((rect.height * Math.max(zoom, 1)) / 2, rect.height * 0.6);

    const clampedX = Math.min(Math.max(rawX, -maxPanX), maxPanX);
    const clampedY = Math.min(Math.max(rawY, -maxPanY), maxPanY);

    setPan({ x: clampedX, y: clampedY });
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  // Scroll Zoom Handler (min: 0.2 for super far zoom out, max: 6.0)
  const handleWheel = (e: React.WheelEvent) => {
    const zoomFactor = e.deltaY < 0 ? 1.25 : 0.8;
    setZoom((prev) => Math.min(Math.max(prev * zoomFactor, 0.2), 6));
  };

  const handleZoomIn = () => {
    setZoom((prev) => Math.min(prev * 1.3, 6));
  };

  const handleZoomOut = () => {
    setZoom((prev) => Math.max(prev / 1.3, 0.2));
  };

  const handleResetMap = () => {
    setZoom(1);
    setPan({ x: 0, y: 0 });
  };

  // Dynamic pin scaling for readable markers at any zoom level
  const pinScale = Math.min(Math.max(1 / Math.pow(zoom, 0.55), 0.6), 2.2);

  // Format time MM:SS
  const formatTime = (seconds: number) => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m.toString().padStart(2, "0")}:${s.toString().padStart(2, "0")}`;
  };

  const selectedLoc = initialLocations.find((l) => l.id === selectedId) || initialLocations[0];

  const recap = liveRecap || data?.recap || null;
  const recapCombat = recap?.combat;
  const hasRecap = Boolean(recap?.killer || recapCombat);
  const killerName = recap?.isSuicide
    ? recap?.killer?.name
      ? `${recap.killer.name} (Suicide)`
      : "Yourself"
    : recap?.killer?.name || "Unknown";
  const killerId = recap?.killer?.id;
  const fatalZone = recapCombat?.fatalZone || (recapCombat?.headshot ? "Head" : "Unknown");
  const damageReceived = Math.max(0, Math.floor(recapCombat?.damageReceived || 0));
  const distanceRaw = Number(recapCombat?.distance || 0);
  const distanceLabel = recap?.isSuicide
    ? "—"
    : `${Number.isInteger(distanceRaw) ? distanceRaw : distanceRaw.toFixed(1)} m`;
  const weaponLabel = recapCombat?.weapon || "Unknown";
  const hitZones = recapCombat?.hitZones || {};
  const zoneHits = [
    { key: "head", label: "Head", count: hitZones.head || 0 },
    { key: "neck", label: "Neck", count: hitZones.neck || 0 },
    { key: "torso", label: "Torso", count: hitZones.torso || 0 },
    { key: "arm", label: "Arms", count: hitZones.arm || 0 },
    { key: "leg", label: "Legs", count: hitZones.leg || 0 },
  ];
  const hasZoneHits = zoneHits.some((z) => z.count > 0);

  // Spawn when forced (timer expired) OR when countdown finished
  const canSpawn = allowEarlySpawn === false || timeLeft <= 0;

  const handleSpawn = () => {
    if (!selectedLoc) return;
    if (!canSpawn) return;  // blocked while STL timer is still running
    fetchNui("cfx-keydi-spawn:selectSpawn", { id: selectedLoc.id, coords: selectedLoc.coords });
    if (onClose) onClose();
  };

  const handleMinimize = () => {
    fetchNui("cfx-keydi-spawn:close");
    if (onClose) onClose();
  };

  if (!visible) return null;

  return (
    <div className="pandora fixed inset-0 z-50 flex flex-col items-center justify-center bg-[#030d1a]/92 p-6 font-sans select-none text-white">
      
      {/* Main Container Grid (2 Columns, Pandora Theme) */}
      <div className="w-full max-w-[1240px] h-[90vh] grid grid-cols-12 gap-5 relative">
        
        {/* ========================================== */}
        {/* LEFT PANEL: RESPAWN COMMAND                */}
        {/* ========================================== */}
        <div className="col-span-4 bg-[#05192f] border border-[rgba(255,122,181,0.35)] rounded-3xl p-6 flex flex-col justify-between overflow-hidden shadow-[0_20px_60px_rgba(0,0,0,0.9),0_0_50px_rgba(255,61,150,0.2)] relative">
          
          {/* Pandora Neon Ambient Glow */}
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-72 h-72 rounded-full bg-[#ff3d96]/10 pointer-events-none" />
          <div className="absolute bottom-0 right-0 w-64 h-64 rounded-full bg-[#35c7f2]/8 pointer-events-none" />

          <div className="flex flex-col gap-4 overflow-hidden relative z-10">
            
            {/* Top Pandora City Logo & Header Info */}
            <div className="text-center flex flex-col items-center pt-2">
              <div className="w-16 h-16 rounded-full bg-gradient-to-br from-[#ff3d96] via-[#d3106f] to-[#0a2743] p-0.5 shadow-lg shadow-[#ff3d96]/30 border border-[#ff7ab5]/50 flex items-center justify-center mb-3">
                <img
                  src={pandoraLogo}
                  alt="Pandora City Logo"
                  className="w-11 h-11 object-contain drop-shadow"
                />
              </div>
              <span className="text-[11px] font-black uppercase tracking-[0.2em] text-[#35c7f2] drop-shadow-sm mb-1">
                GRIM CITY • {isDeathCam ? (isBleedout ? 'BLEEDOUT' : (allowEarlySpawn ? 'DEATH CAM' : 'FORCED SPAWN')) : 'SPAWN SYSTEM'}
              </span>
              <h1 className="text-2xl font-extrabold tracking-tight bg-gradient-to-r from-[#ff3d96] via-[#8fe4ff] to-[#ffd24c] bg-clip-text text-transparent">
                Respawn Command
              </h1>
              <p className="text-xs text-[#9cc3e6]/70 max-w-[270px] leading-relaxed mt-1">
                Review your final engagement or select a safe return point.
              </p>
            </div>

            {/* Respawn Timer Card */}
            <div className="p-4 rounded-2xl bg-gradient-to-r from-[#0a2743] to-[#0b2c4e] border border-[rgba(255,122,181,0.3)] text-center shadow-md">
              <div className="text-[10px] tracking-[0.2em] uppercase text-[#35c7f2] font-mono font-bold mb-2">
                {isBleedout ? 'BLEEDOUT' : 'RESPAWN IN'}
              </div>
              <div className="text-4xl font-black font-mono tracking-widest text-[#ff3d96] drop-shadow-[0_0_18px_rgba(255,61,150,0.8)]">
                {formatTime(timeLeft)}
              </div>
              <div className="mt-1 text-[10px] text-[#9cc3e6]/60 font-mono">
                {allowEarlySpawn
                  ? (timeLeft > 0 ? 'until early spawn' : 'READY TO SPAWN')
                  : (timeLeft > 0 ? 'you can spawn now' : 'SELECT A SPAWN LOCATION')}
              </div>
            </div>

            {/* Navigation Tabs (Stacked Vertical Buttons) */}
            <div className="flex flex-col gap-2.5">
              {/* Spawn Tab */}
              <button
                onClick={() => setActiveTab("spawn")}
                className={`p-3.5 rounded-2xl border transition-all cursor-pointer flex items-center justify-between text-left ${
                  activeTab === "spawn"
                    ? "bg-gradient-to-r from-[#ff3d96]/30 via-[#0b2c4e] to-[#0a2743] border-[#ff3d96] shadow-[0_0_20px_rgba(255,61,150,0.35)] text-white"
                    : "bg-[#0a2846]/70 border-[rgba(255,122,181,0.2)] text-[#9cc3e6] hover:bg-[#0f3a68]/70 hover:border-[#ff3d96]/40"
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${
                    activeTab === "spawn" ? "bg-[#ff3d96] text-white shadow-md shadow-[#ff3d96]/40" : "bg-[#082038] text-[#35c7f2]"
                  }`}>
                    <MapPin className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="text-sm font-bold text-white">Spawn</div>
                    <div className="text-[11px] text-[#9cc3e6]/60">Pick a return location</div>
                  </div>
                </div>
                <span className="px-2 py-0.5 rounded-lg text-xs font-mono font-bold bg-[#05192f] text-[#ff7ab5] border border-[rgba(255,122,181,0.25)]">
                  {initialLocations.length}
                </span>
              </button>

              {/* Recap Tab */}
              <button
                onClick={() => setActiveTab("recap")}
                className={`p-3.5 rounded-2xl border transition-all cursor-pointer flex items-center justify-between text-left ${
                  activeTab === "recap"
                    ? "bg-gradient-to-r from-[#ff3d96]/30 via-[#0b2c4e] to-[#0a2743] border-[#ff3d96] shadow-[0_0_20px_rgba(255,61,150,0.35)] text-white"
                    : "bg-[#0a2846]/70 border-[rgba(255,122,181,0.2)] text-[#9cc3e6] hover:bg-[#0f3a68]/70 hover:border-[#ff3d96]/40"
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className={`w-9 h-9 rounded-xl flex items-center justify-center ${
                    activeTab === "recap" ? "bg-[#ff3d96] text-white shadow-md shadow-[#ff3d96]/40" : "bg-[#082038] text-[#35c7f2]"
                  }`}>
                    <BarChart3 className="w-4 h-4" />
                  </div>
                  <div>
                    <div className="text-sm font-bold text-white">Recap</div>
                    <div className="text-[11px] text-[#9cc3e6]/60">Damage and engagement data</div>
                  </div>
                </div>
                <span className="px-2 py-0.5 rounded-lg text-xs font-mono font-bold bg-[#05192f] text-[#ff7ab5] border border-[rgba(255,122,181,0.25)]">
                  {hasRecap ? 1 : 0}
                </span>
              </button>
            </div>

            {/* Stats Row */}
            <div className="grid grid-cols-2 gap-3">
              <div className="p-3 rounded-2xl bg-[#0a2743]/80 border border-[rgba(255,122,181,0.2)] text-center">
                <div className="text-[10px] font-black tracking-widest uppercase text-[#35c7f2] mb-1">
                  LOCATIONS
                </div>
                <div className="text-xl font-extrabold text-white">
                  {initialLocations.length}
                </div>
              </div>
              <div className="p-3 rounded-2xl bg-[#0a2743]/80 border border-[rgba(255,122,181,0.2)] text-center">
                <div className="text-[10px] font-black tracking-widest uppercase text-[#ffd24c] mb-1">
                  ENGAGEMENTS
                </div>
                <div className="text-xl font-extrabold text-[#ffd24c]">
                  {hasRecap ? 1 : 0}
                </div>
              </div>
            </div>

            {/* Spawn Locations Scrollable List */}
            {activeTab === "spawn" ? (
              <div className="flex-1 flex flex-col min-h-0 overflow-hidden">
                <div className="text-[11px] font-black tracking-[0.15em] uppercase text-[#35c7f2] my-2">
                  SPAWN LOCATIONS
                </div>

                <div className="flex-1 overflow-y-auto space-y-2 pr-1 custom-scrollbar">
                  {initialLocations.map((loc, index) => {
                    const isSelected = loc.id === selectedId;
                    return (
                      <div
                        key={loc.id}
                        onClick={() => handleSelectLocation(loc)}
                        className={`p-3 rounded-2xl border transition-all cursor-pointer flex items-center gap-3 relative overflow-hidden group ${
                          isSelected
                            ? "bg-gradient-to-r from-[#ff3d96]/30 via-[#0b2c4e] to-[#0a2743] border-[#ff3d96] shadow-[0_0_15px_rgba(255,61,150,0.3)] text-white"
                            : "bg-[#0b2c4e]/70 border-[rgba(255,122,181,0.2)] hover:border-[#ff3d96]/40 hover:bg-[#0f3a68]"
                        }`}
                      >
                        {/* Pandora Glow Selection Bar Indicator */}
                        {isSelected && (
                          <div className="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-[#ff3d96] via-[#8fe4ff] to-[#35c7f2]" />
                        )}

                        {/* Number Badge */}
                        <div
                          className={`w-7 h-7 rounded-xl flex items-center justify-center text-xs font-black shrink-0 transition-colors ${
                            isSelected
                              ? "bg-gradient-to-br from-[#ff3d96] to-[#d3106f] text-white shadow"
                              : "bg-[#0a2743] text-[#8fe4ff] border border-[rgba(255,122,181,0.25)] group-hover:bg-[#0f3a68]"
                          }`}
                        >
                          {index + 1}
                        </div>

                        {/* Text Content */}
                        <div className="flex-1 min-w-0">
                          <h4 className="text-xs font-extrabold truncate text-white">
                            {loc.name}
                          </h4>
                          <p className="text-[11px] text-[#9cc3e6]/70 truncate mt-0.5">
                            {loc.description}
                          </p>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>
            ) : (
              /* Recap Tab View */
              <div className="flex-1 p-4 rounded-2xl bg-[#0b2c4e]/70 border border-[rgba(255,122,181,0.25)] flex flex-col gap-2.5 overflow-y-auto">
                <div className="text-[11px] font-black tracking-wider uppercase text-[#35c7f2]">
                  LAST ENGAGEMENT RECAP
                </div>
                {hasRecap ? (
                  <>
                    <div className="p-3 rounded-xl bg-[#0a2743]/90 border border-[rgba(255,122,181,0.2)] text-xs space-y-2">
                      <div className="flex justify-between gap-3 text-[#9cc3e6]">
                        <span>Killed By:</span>
                        <span className="font-bold text-white text-right truncate max-w-[160px]">
                          {killerName}
                          {typeof killerId === "number" && killerId > 0 ? (
                            <span className="text-[#ff7ab5]"> #{killerId}</span>
                          ) : null}
                        </span>
                      </div>
                      <div className="flex justify-between text-[#9cc3e6]">
                        <span>Target Zone:</span>
                        <span className="font-bold text-white">
                          {fatalZone}
                          {recapCombat?.headshot ? (
                            <span className="ml-1 text-[#ff3d96]">HS</span>
                          ) : null}
                        </span>
                      </div>
                      <div className="flex justify-between text-[#9cc3e6]">
                        <span>Damage Received:</span>
                        <span className="font-bold text-[#ff3d96]">{damageReceived} HP</span>
                      </div>
                      <div className="flex justify-between text-[#9cc3e6]">
                        <span>Distance:</span>
                        <span className="font-bold text-white">{distanceLabel}</span>
                      </div>
                      <div className="flex justify-between gap-3 text-[#9cc3e6]">
                        <span>Weapon:</span>
                        <span className="font-bold text-[#8fe4ff] text-right truncate max-w-[160px]">{weaponLabel}</span>
                      </div>
                    </div>
                    {hasZoneHits && (
                      <div className="grid grid-cols-5 gap-1">
                        {zoneHits.map((z) => (
                          <div
                            key={z.key}
                            className={`rounded-lg border px-1 py-1.5 text-center ${
                              z.count > 0
                                ? "bg-[#ff3d96]/15 border-[#ff3d96]/40"
                                : "bg-[#0a2743]/80 border-[rgba(255,122,181,0.15)]"
                            }`}
                          >
                            <div className="text-xs font-black text-white">{z.count}</div>
                            <div className="text-[8px] font-bold uppercase tracking-wide text-[#9cc3e6]">{z.label}</div>
                          </div>
                        ))}
                      </div>
                    )}
                  </>
                ) : (
                  <div className="p-3 rounded-xl bg-[#0a2743]/90 border border-dashed border-[rgba(255,122,181,0.25)] text-xs text-center text-[#9cc3e6]/70">
                    No engagement data yet. This fills in from your last death screen.
                  </div>
                )}
              </div>
            )}

          </div>

        </div>

        {/* ========================================== */}
        {/* RIGHT PANEL: WORLD MAP                     */}
        {/* ========================================== */}
        <div className="col-span-8 bg-[#05192f] border border-[rgba(255,122,181,0.35)] rounded-3xl p-6 flex flex-col justify-between overflow-hidden shadow-[0_20px_60px_rgba(0,0,0,0.9),0_0_50px_rgba(255,61,150,0.2)] relative">
          
          {/* Top Header Bar of Right Panel */}
          <div className="flex items-center justify-between pb-4 border-b border-[rgba(255,122,181,0.25)]">
            <div>
              <div className="text-[11px] font-black uppercase tracking-widest text-[#35c7f2]">
                WORLD MAP
              </div>
              <p className="text-xs text-[#9cc3e6]/80 mt-0.5">
                Choose a safe return point on the map or from the list.
              </p>
            </div>

            <div className="flex items-center gap-3">
              {/* Respawn Timer Badge */}
              <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-[#0a2743] border border-[#ff3d96]/40 text-[#ffa6ce] font-mono text-xs shadow-[0_0_12px_rgba(255,61,150,0.2)]">
                <Clock className="w-3.5 h-3.5 text-[#ff3d96]" />
                <span className="font-bold">
                  {formatTime(timeLeft)}
                </span>
              </div>

              {/* Minimize Button — hidden when forced (player must choose) */}
              {allowEarlySpawn && (
                <button
                  onClick={handleMinimize}
                  className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-xl bg-[#0b2c4e]/70 hover:bg-[#0f3a68] border border-[rgba(255,122,181,0.3)] text-xs font-semibold text-[#cfe7ff] transition-all cursor-pointer shadow-sm"
                >
                  <Minimize2 className="w-3.5 h-3.5 text-[#35c7f2]" />
                  <span>Minimize</span>
                </button>
              )}
            </div>
          </div>

          {/* Subheader: WORLD MAP Banner above Canvas */}
          <div className="flex items-center justify-between pt-3 pb-2">
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 rounded-lg bg-[#0b2c4e] flex items-center justify-center text-[#ff3d96] border border-[rgba(255,122,181,0.3)]">
                <MapPin className="w-3.5 h-3.5" />
              </div>
              <div>
                <span className="text-xs font-extrabold text-white uppercase tracking-wider">WORLD MAP</span>
                <span className="text-xs text-[#9cc3e6]/70 ml-2">Click a marker to select</span>
              </div>
            </div>

            {/* Map Tools Toolbar */}
            <div className="flex items-center bg-[#0a2743] border border-[rgba(255,122,181,0.3)] rounded-xl p-0.5 gap-1">
              <button
                onClick={() => setIsNightMode(!isNightMode)}
                title="Toggle Day/Night Map"
                className="p-1.5 hover:bg-[#0f3a68] text-[#cfe7ff] rounded-lg transition-all cursor-pointer"
              >
                {isNightMode ? <Moon className="w-3.5 h-3.5 text-[#35c7f2]" /> : <Sun className="w-3.5 h-3.5 text-[#ffd24c]" />}
              </button>
              <button
                onClick={handleZoomIn}
                title="Zoom In (+)"
                className="p-1.5 hover:bg-[#0f3a68] text-[#cfe7ff] rounded-lg transition-all cursor-pointer"
              >
                <ZoomIn className="w-3.5 h-3.5" />
              </button>
              <button
                onClick={handleZoomOut}
                title="Zoom Out (-)"
                className="p-1.5 hover:bg-[#0f3a68] text-[#cfe7ff] rounded-lg transition-all cursor-pointer"
              >
                <ZoomOut className="w-3.5 h-3.5" />
              </button>
              <button
                onClick={handleResetMap}
                title="Reset View"
                className="p-1.5 hover:bg-[#0f3a68] text-[#cfe7ff] rounded-lg transition-all cursor-pointer"
              >
                <RotateCcw className="w-3.5 h-3.5 text-[#35c7f2]" />
              </button>
            </div>
          </div>

          {/* Interactive World Map Canvas Viewport (Non-transparent, Seamless Ocean Blue) */}
          <div
            ref={mapRef}
            onMouseDown={handleMouseDown}
            onMouseMove={handleMouseMove}
            onMouseUp={handleMouseUp}
            onMouseLeave={handleMouseUp}
            onWheel={handleWheel}
            className={`flex-1 relative rounded-2xl border border-[rgba(255,122,181,0.3)] overflow-hidden shadow-inner transition-colors duration-300 ${
              isNightMode ? "bg-[#051728]" : "bg-[#0da1d7]"
            } ${isDragging ? "cursor-grabbing" : "cursor-grab"}`}
          >
            {/* Map Transform Wrapper (Pan & Zoom) */}
            <div
              style={{
                transform: `translate3d(${pan.x}px, ${pan.y}px, 0) scale(${zoom})`,
                transformOrigin: "center center",
                willChange: "transform",
                transition: isDragging ? "none" : "transform 0.08s linear"
              }}
              className="w-full h-full relative flex items-center justify-center"
            >
              {/* Full Edge-to-Edge GTA V Map Image — both kept mounted so CEF does not re-decode */}
              <img
                src={SPAWN_MAP_NIGHT}
                alt=""
                decoding="async"
                fetchPriority="high"
                className={`absolute inset-0 w-full h-full object-contain select-none pointer-events-none ${isNightMode ? "opacity-100" : "opacity-0"}`}
                draggable={false}
              />
              <img
                src={SPAWN_MAP_DAY}
                alt=""
                decoding="async"
                className={`absolute inset-0 w-full h-full object-contain select-none pointer-events-none ${isNightMode ? "opacity-0" : "opacity-100"}`}
                draggable={false}
              />

              {/* Grid Lines Overlay */}
              <div 
                className="absolute inset-0 opacity-10 pointer-events-none"
                style={{
                  backgroundImage: `linear-gradient(to right, #35c7f2 1px, transparent 1px), linear-gradient(to bottom, #35c7f2 1px, transparent 1px)`,
                  backgroundSize: '48px 48px'
                }}
              />

              {/* Map Marker Pins */}
              <div className="absolute inset-0 pointer-events-auto">
                {initialLocations.map((loc) => {
                  const isSelected = loc.id === selectedId;
                  return (
                    <button
                      key={loc.id}
                      onClick={(e) => {
                        e.stopPropagation();
                        handleSelectLocation(loc);
                      }}
                      style={{
                        left: `${loc.mapX}%`,
                        top: `${loc.mapY}%`,
                        transform: `translate(-50%, -50%) scale(${pinScale})`
                      }}
                      className="absolute group/pin cursor-pointer focus:outline-none z-20"
                    >
                      {/* Pulse Ring if Selected */}
                      {isSelected && (
                        <div className="absolute -inset-3 rounded-full bg-[#a855f7]/50 animate-ping pointer-events-none" />
                      )}

                      {/* Marker Pin Circle */}
                      <div
                        className={`w-7 h-7 rounded-full flex items-center justify-center transition-all shadow-xl ${
                          isSelected
                            ? "bg-[#a855f7] ring-4 ring-white scale-125 z-20 shadow-[0_0_18px_rgba(168,85,247,0.8)]"
                            : "bg-[#ea580c] border-2 border-white hover:scale-110 hover:bg-[#f97316] z-10 shadow"
                        }`}
                      >
                        <div className="w-2.5 h-2.5 rounded-full bg-white shadow-inner" />
                      </div>

                      {/* Tooltip on Hover */}
                      <div className="absolute left-1/2 -top-9 -translate-x-1/2 px-2.5 py-1 rounded-lg bg-[#0a2743]/95 border border-[#ff3d96]/40 text-[10px] font-bold text-white whitespace-nowrap opacity-0 group-hover/pin:opacity-100 transition-opacity pointer-events-none shadow-2xl z-30">
                        {loc.name}
                      </div>
                    </button>
                  );
                })}

                {/* Floating Preview Card for Selected Location */}
                {selectedLoc && showPopup && (
                  <div
                    style={{
                      left: `${selectedLoc.mapX}%`,
                      top: `${selectedLoc.mapY}%`,
                      transform: `translate(-50%, -100%) scale(${pinScale})`,
                      transformOrigin: "bottom center"
                    }}
                    className="absolute z-40 -mt-5 w-72 bg-[#0b2c4e] rounded-2xl border border-[#ff3d96]/60 shadow-[0_15px_40px_rgba(0,0,0,0.85)] overflow-hidden pointer-events-auto"
                  >
                    {/* Location Image */}
                    <div className="relative h-40 w-full p-2 bg-[#05192f]">
                      <div className="w-full h-full rounded-xl overflow-hidden relative ring-2 ring-[#ff3d96]/80 shadow-[0_0_18px_rgba(255,61,150,0.5)]">
                        <img
                          src={selectedLoc.image || "https://images.unsplash.com/photo-1617814076367-b759c7d7e738?q=80&w=600&auto=format&fit=crop"}
                          alt={selectedLoc.name}
                          loading="lazy"
                          decoding="async"
                          className="w-full h-full object-cover"
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-[#0b2c4e] via-transparent to-black/30" />

                        {/* Close X — hidden when forced */}
                        {allowEarlySpawn && (
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              setShowPopup(false);
                            }}
                            className="absolute top-2 right-2 w-6 h-6 rounded-full bg-black/70 hover:bg-black border border-white/30 text-white flex items-center justify-center transition-all cursor-pointer shadow-lg"
                          >
                            <X className="w-3.5 h-3.5" />
                          </button>
                        )}
                      </div>
                    </div>

                    {/* Location Info */}
                    <div className="p-4 bg-[#0b2c4e]">
                      <h3 className="text-sm font-black text-white tracking-tight">
                        {selectedLoc.name}
                      </h3>
                      <p className="text-xs text-[#cfe7ff]/80 mt-1 leading-relaxed">
                        {selectedLoc.description}
                      </p>
                    </div>

                    {/* Pointer Triangle */}
                    <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-0 h-0 border-l-[8px] border-l-transparent border-r-[8px] border-r-transparent border-t-[8px] border-t-[#0b2c4e]" />
                  </div>
                )}
              </div>

            </div>

            {/* Bottom-left Drag Hint */}
            <div className="absolute bottom-3 left-3 z-30 pointer-events-none flex items-center gap-2">
              <div className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#0a2743]/90 border border-[rgba(255,122,181,0.3)] text-[10px] font-bold text-[#8fe4ff] shadow-lg backdrop-blur-sm">
                <Move className="w-3 h-3 text-[#ff3d96]" />
                <span>Drag to Move • Scroll to Zoom</span>
                <span className="ml-1.5 px-1.5 py-0.5 rounded bg-[#0b2c4e] text-[#35c7f2] font-mono">
                  {Math.round(zoom * 100)}%
                </span>
              </div>
              {(zoom !== 1 || pan.x !== 0 || pan.y !== 0) && (
                <button
                  onClick={handleResetMap}
                  className="pointer-events-auto px-3 py-1 rounded-full bg-[#ff3d96] hover:bg-[#ff5ca7] border border-[#ff7ab5] text-[10px] font-extrabold text-white shadow-lg transition-all cursor-pointer flex items-center gap-1"
                >
                  <RotateCcw className="w-3 h-3" />
                  <span>Reset View</span>
                </button>
              )}
            </div>
          </div>

          {/* Bottom Footer of Right Panel (Selected Location & Spawn Action Button) */}
          <div className="pt-4 flex items-center justify-between border-t border-[rgba(255,122,181,0.25)]">
            <div>
              <div className="text-[10px] uppercase tracking-widest text-[#35c7f2] font-black">
                SELECTED LOCATION
              </div>
              <h3 className="text-base font-extrabold text-white">
                {selectedLoc?.name || "Select a location"}
              </h3>
              <p className="text-xs text-[#9cc3e6]">
                {selectedLoc?.description || "Pick a return point from the map or list."}
              </p>
            </div>

            {/* Pandora Gradient Spawn Action Button */}
            <button
              onClick={handleSpawn}
              disabled={!canSpawn}
              className={`px-8 py-3 rounded-2xl text-white text-xs font-black uppercase tracking-wider transition-all border border-white/20 active:scale-95 ${
                canSpawn
                  ? 'bg-gradient-to-r from-[#ff3d96] via-[#d3106f] to-[#35c7f2] hover:brightness-110 shadow-[0_0_25px_rgba(255,61,150,0.4)] cursor-pointer'
                  : 'bg-[#0a2743] border-[rgba(255,122,181,0.2)] text-[#4a7a9b] cursor-not-allowed opacity-60'
              }`}
            >
              {canSpawn ? 'Spawn Here' : `Wait  ${formatTime(timeLeft)}`}
            </button>
          </div>

        </div>

      </div>

      {/* Pandora Footer Credit */}
      <div className="mt-3 flex items-center justify-center gap-1.5 text-[11px] text-[#9cc3e6]/40 font-mono tracking-wider">
        <div className="w-3 h-3 rounded-full bg-[#ff3d96]/20 border border-[#ff7ab5]/40 flex items-center justify-center text-[9px] font-bold text-[#ff3d96]">
          p
        </div>
        <span>keydi,net</span>
      </div>

    </div>
  );
};

export default Spawn;
