import React, { useState, useEffect } from "react";
import { 
  Bug, Zap, Rocket, FileText, ChevronRight, ArrowLeft, Video, Briefcase, Power, CheckCircle2, ShieldAlert, Camera, Save, Trash2, Circle, X, Server, Globe, Shield, Activity, RefreshCw, LogOut, Users, Lock, ShieldCheck, HelpCircle, Briefcase as JobIcon, Info 
} from "lucide-react";
import { cn } from "@/lib/utils";
import grimLogo from "@/assets/grim-city-logo.png";

async function fetchNui<T = any>(eventName: string, data?: any): Promise<T> {
  const options = {
    method: 'post',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: JSON.stringify(data),
  };

  const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : 'cfx-keydi-ui';

  const resp = await fetch(`https://${resourceName}/${eventName}`, options);
  const respFormatted = await resp.json();
  return respFormatted;
}

interface ModulesMenuProps {
  onClose: () => void;
  onOpenDamageIndicator: () => void;
  onOpenFpsOptimizer: () => void;
  onOpenReport: () => void;
  onOpenBanking: () => void;
  onOpenRockstarEditor?: () => void;
  updates?: PatchNote[];
}

type SubView = "grid" | "patchnotes" | "multijob" | "rockstar" | "server";
type ServerTab = "public" | "jobs" | "faq";

interface JobItem {
  job: string;
  grade: number;
  label: string;
  grade_label: string;
  is_active: number;
}

interface PatchNote {
  version: string;
  date: string;
  title: string;
  tag: string;
  notes: string[];
}

export interface ServerRealm {
  id: string;
  name: string;
  tag: string;
  description: string;
  onlinePlayers: number;
  maxPlayers: number;
  ping: string;
  cfxUrl?: string;
  ip?: string;
  status: "ONLINE" | "FULL" | "WHITELIST" | string;
  isCurrent?: boolean;
  functions?: string[];
  type?: string;
}

export interface SideJobServer {
  id: string;
  name: string;
  tag: string;
  description: string;
  onlinePlayers: number;
  maxPlayers: number;
  isCurrent?: boolean;
  functions?: string[];
}

// Public realms (Region 1 Farm / Region 2 School / Region 3-4 Turf)
const DEFAULT_PUBLIC_SERVERS: ServerRealm[] = [
  {
    id: "region1",
    name: "Region 1 · All Farm",
    tag: "FARM REALM",
    description: "All farms available here — autofarm, hunting, weed, and orange picking.",
    onlinePlayers: 0,
    maxPlayers: 0,
    ping: "16 ms",
    status: "ONLINE",
    functions: ["grind", "autofarm", "raven", "weedfarm", "job_orange"],
  },
  {
    id: "region2",
    name: "Region 2 · School",
    tag: "SCHOOL REALM",
    description: "School / city RP. Jobs, housing, and social roleplay.",
    onlinePlayers: 0,
    maxPlayers: 0,
    ping: "16 ms",
    status: "ONLINE",
    isCurrent: true,
    functions: ["main", "jobs", "housing", "school"],
  },
  {
    id: "region3",
    name: "Region 3 · Turf War",
    tag: "TURF REALM",
    description: "Turf War instance. Gang wars only work here and on Region 4.",
    onlinePlayers: 0,
    maxPlayers: 0,
    ping: "18 ms",
    status: "ONLINE",
    functions: ["turfwar"],
  },
  {
    id: "region4",
    name: "Region 4 · Turf War",
    tag: "TURF REALM",
    description: "Second Turf War instance. Isolated from Region 3 players.",
    onlinePlayers: 0,
    maxPlayers: 0,
    ping: "18 ms",
    status: "ONLINE",
    functions: ["turfwar"],
  },
];

// Side Job Instances (Orange only)
const DEFAULT_JOB_SERVERS: SideJobServer[] = [
  { id: "job_orange", name: "Orange Picking Instance", tag: "ORANGE JOB", maxPlayers: 30, onlinePlayers: 0, description: "Pick oranges in a dedicated orchard instance." },
];

export default function ModulesMenu({ 
  onClose, 
  onOpenDamageIndicator, 
  onOpenFpsOptimizer, 
  onOpenReport, 
  onOpenBanking, 
  onOpenRockstarEditor, 
  updates 
}: ModulesMenuProps) {
  const [currentView, setCurrentView] = useState<SubView>("grid");
  const [serverSubTab, setServerSubTab] = useState<ServerTab>("public");

  const [jobsList, setJobsList] = useState<JobItem[]>([]);
  const [activeJob, setActiveJob] = useState<string | null>(null);
  const [isOnDuty, setIsOnDuty] = useState<boolean>(false);
  const [loadingJobs, setLoadingJobs] = useState<boolean>(false);
  const [patchNotes, setPatchNotes] = useState<PatchNote[]>(updates || []);
  const [recording, setRecording] = useState(false);
  const [rockstarBusy, setRockstarBusy] = useState(false);
  
  // Instance Splitting Server Changer State
  const [publicServers, setPublicServers] = useState<ServerRealm[]>(DEFAULT_PUBLIC_SERVERS);
  const [jobServers, setJobServers] = useState<SideJobServer[]>(DEFAULT_JOB_SERVERS);
  const [inSafezone, setInSafezone] = useState<boolean>(true);
  const [isLocked, setIsLocked] = useState<boolean>(false);
  const [lockReason, setLockReason] = useState<string | null>(null);
  const [loadingServers, setLoadingServers] = useState(false);
  const [switchingServer, setSwitchingServer] = useState<string | null>(null);

  useEffect(() => {
    if (updates && updates.length > 0) {
      setPatchNotes(updates);
      return;
    }
    fetchNui<{ updates?: PatchNote[] }>("cfx-keydi-modules:getPatchNotes", {})
      .then((res) => {
        if (res?.updates) setPatchNotes(res.updates);
      })
      .catch(() => {});
  }, [updates]);

  const loadMultiJobs = () => {
    setLoadingJobs(true);
    fetchNui<{ jobs: JobItem[]; activeJob: string | null; isOnDuty: boolean }>("cfx-keydi-modules:getJobs", {})
      .then((res) => {
        if (res) {
          setJobsList(res.jobs || []);
          setActiveJob(res.activeJob || null);
          setIsOnDuty(!!res.isOnDuty);
        }
      })
      .catch(() => {})
      .finally(() => setLoadingJobs(false));
  };

  const loadServerRealms = () => {
    setLoadingServers(true);
    fetchNui<{ 
      publicServers?: ServerRealm[]; 
      sideJobServers?: SideJobServer[];
      inSafezone?: boolean; 
      isLocked?: boolean; 
      lockReason?: string 
    }>("cfx-keydi-modules:getServers", {})
      .then((res) => {
        if (res) {
          if (res.publicServers && res.publicServers.length > 0) setPublicServers(res.publicServers);
          if (res.sideJobServers && res.sideJobServers.length > 0) setJobServers(res.sideJobServers);
          if (typeof res.inSafezone === "boolean") setInSafezone(res.inSafezone);
          if (typeof res.isLocked === "boolean") setIsLocked(res.isLocked);
          setLockReason(res.lockReason || null);
        }
      })
      .catch(() => {})
      .finally(() => setLoadingServers(false));
  };

  useEffect(() => {
    if (currentView === "multijob") {
      loadMultiJobs();
    }
    if (currentView === "server") {
      loadServerRealms();
    }
    if (currentView === "rockstar") {
      fetchNui<{ recording?: boolean }>("cfx-keydi-modules:getRockstarState", {})
        .then((res) => setRecording(!!res?.recording))
        .catch(() => {});
    }
  }, [currentView]);

  const handleToggleJobDuty = (jobName: string) => {
    fetchNui("cfx-keydi-modules:toggleJobDuty", { job: jobName })
      .then(() => {
        setTimeout(() => loadMultiJobs(), 300);
      })
      .catch(() => {});
  };

  const handleRockstarAction = (button: "record" | "save" | "delete" | "photo" | "open") => {
    if (rockstarBusy) return;
    setRockstarBusy(true);
    fetchNui<{ ok?: boolean; recording?: boolean; close?: boolean }>("cfx-keydi-modules:rockstarAction", { button })
      .then((res) => {
        if (typeof res?.recording === "boolean") setRecording(res.recording);
      })
      .catch(() => {})
      .finally(() => setRockstarBusy(false));
  };

  const handleSwitchServer = (realm: { id: string; name: string; isCurrent?: boolean }) => {
    if (realm.isCurrent || switchingServer || !inSafezone || isLocked) return;
    setSwitchingServer(realm.id);
    fetchNui("cfx-keydi-modules:connectServer", { id: realm.id, name: realm.name })
      .catch(() => {})
      .finally(() => {
        setTimeout(() => setSwitchingServer(null), 2500);
      });
  };

  useEffect(() => {
    const handleLocalKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        if (currentView !== "grid") {
          setCurrentView("grid");
        } else {
          onClose();
        }
      }
    };
    window.addEventListener("keydown", handleLocalKeyDown);
    return () => window.removeEventListener("keydown", handleLocalKeyDown);
  }, [currentView, onClose]);

  const moduleItems = [
    {
      id: "report",
      name: "Report System",
      desc: "Communicate directly with active staff for technical or RP issues.",
      icon: <Bug className="h-5 w-5 text-[#ff4d4d]" />,
      action: onOpenReport,
      tag: "SUPPORT",
    },
    {
      id: "indicator",
      name: "Damage Indicator",
      desc: "Personalize hitmarkers, damage fonts, colors, and timing.",
      icon: <Zap className="h-5 w-5 text-[#ff4d4d]" />,
      action: onOpenDamageIndicator,
      tag: "COMBAT",
    },
    {
      id: "fps",
      name: "FPS Optimizer",
      desc: "Instant graphics presets to maximize your frame rate.",
      icon: <Rocket className="h-5 w-5 text-[#ff4d4d]" />,
      action: onOpenFpsOptimizer,
      tag: "PERFORMANCE",
    },
    {
      id: "patchnotes",
      name: "Patch Notes",
      desc: "Read the latest server releases, bug fixes, and features.",
      icon: <FileText className="h-5 w-5 text-[#ff4d4d]" />,
      action: () => setCurrentView("patchnotes"),
      tag: "CHANGELOG",
    },
    {
      id: "multijob",
      name: "Multi-Job Roster",
      desc: "Switch active job duty position on demand (Max 3 held jobs).",
      icon: <Briefcase className="h-5 w-5 text-[#ff4d4d]" />,
      action: () => setCurrentView("multijob"),
      tag: "CAREER",
    },
    {
      id: "server",
      name: "Regions",
      desc: "Switch in-game between Farm, School, and Turf War regions. Each region is isolated.",
      icon: <Server className="h-5 w-5 text-[#ff4d4d]" />,
      action: () => setCurrentView("server"),
      tag: "INSTANCING",
    },
    {
      id: "rockstar",
      name: "Rockstar Recording",
      desc: "Record clips in-game, save, photo, or open the editor.",
      icon: <Video className="h-5 w-5 text-[#ff4d4d]" />,
      action: () => setCurrentView("rockstar"),
      tag: "MEDIA",
    },
  ];

  return (
    <div className="pandora fixed inset-0 flex items-center justify-center p-8 bg-black/80 backdrop-blur-[6px] select-none pointer-events-auto animate-fade-in font-sans z-40">
      <div className="pandora-panel flex w-full max-w-6xl rounded-2xl border-2 border-[#ff3a3a] overflow-hidden h-[590px] relative bg-[#0d0d12]">
        
        {/* LEFT SIDE PANEL: Grim City Hero Sidebar */}
        <div 
          className="relative w-[32%] flex flex-col justify-between overflow-hidden p-7 border-r border-[#ff3a3a]"
          style={{ background: "linear-gradient(180deg, #140d11 0%, #0d0d12 100%)" }}
        >
          <div className="panel-grid absolute inset-0 pointer-events-none opacity-30" />
          
          <div className="relative z-10 flex flex-col items-center text-center gap-4 mt-1">
            <img src={grimLogo} alt="Grim City" className="w-[145px] object-contain drop-shadow" />
            
            <div>
              <span className="inline-block bg-[#ff3a3a]/20 border border-[#ff3a3a] text-[#ff4d4d] text-[9px] font-black tracking-[0.2em] px-3 py-1 rounded-md uppercase mb-2">
                GRIM CITY ROLEPLAY
              </span>
              <h1 className="text-2xl font-black text-white tracking-tight mt-1">MODULE CONTROL</h1>
              <p className="mx-auto mt-2 max-w-[210px] text-[11px] leading-relaxed text-[#ffc2c2]">
                Configure settings, optimize FPS, check job duty, or switch server instances.
              </p>
            </div>

            {/* Live System Status Badges */}
            <div className="flex flex-col gap-2 w-full mt-2">
              <div className="flex items-center justify-between p-2.5 rounded-xl border border-[#ff3a3a]/30 bg-[#181216]">
                <span className="text-[9.5px] font-bold text-[#a08890]">Active Modules</span>
                <span className="text-[10px] font-black text-[#ff4d4d]">{moduleItems.length} Ready</span>
              </div>
              <div className="flex items-center justify-between p-2.5 rounded-xl border border-[#ff3a3a]/30 bg-[#181216]">
                <span className="text-[9.5px] font-bold text-[#a08890]">Instance Splitting</span>
                <span className="flex items-center gap-1.5 text-[9.5px] font-black text-emerald-400">
                  <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                  2 SERVERS ACTIVE
                </span>
              </div>
            </div>
          </div>

          <div className="relative z-10 text-center border-t border-[#ff3a3a]/25 pt-3">
            <span className="text-[10px] tracking-[0.16em] text-[#a08890]">
              Powered by <strong className="text-[#ff4d4d]">KodeByKarl.Net</strong>
            </span>
          </div>
        </div>

        {/* RIGHT SIDE PANEL: Content Area */}
        <div className="flex-1 p-7 flex flex-col h-full bg-transparent">
          
          {/* Header Row */}
          <div className="flex items-center justify-between border-b border-[#ff3a3a]/30 pb-4 mb-4 shrink-0">
            <div className="flex items-center gap-3">
              {currentView !== "grid" && (
                <button 
                  onClick={() => setCurrentView("grid")}
                  className="flex items-center gap-1 px-2.5 py-1 rounded-lg border border-[#ff3a3a]/40 bg-[#181216] text-[#ff4d4d] hover:bg-[#ff3a3a]/20 text-[10px] font-black uppercase transition cursor-pointer"
                >
                  <ArrowLeft className="h-3.5 w-3.5" /> Back
                </button>
              )}
              <div>
                <span className="text-xs font-black tracking-[0.2em] text-[#ff4d4d] uppercase">
                  {currentView === "grid" && "MODULE MATRIX"}
                  {currentView === "patchnotes" && "SERVER DEVELOPMENTS"}
                  {currentView === "multijob" && "MULTI-JOB ROSTER"}
                  {currentView === "server" && "REGIONS"}
                  {currentView === "rockstar" && "ROCKSTAR RECORDING"}
                </span>
                <p className="text-[11px] text-[#a08890] mt-0.5">
                  {currentView === "grid" && "Select a module below to launch its configuration window."}
                  {currentView === "patchnotes" && "Read release notes and changelogs from the developers."}
                  {currentView === "multijob" && "Switch active job duty position on demand."}
                  {currentView === "server" && "Switch regions in-game. Region 1 Farm · Region 2 School · Region 3–4 Turf."}
                  {currentView === "rockstar" && "Record clips in-game, save, photo, or open Single Player editor."}
                </p>
              </div>
            </div>

            {/* Header Action Buttons: Server Changer & Close */}
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => setCurrentView("server")}
                className={cn(
                  "flex items-center gap-1.5 px-3 py-1 rounded-lg border text-[11px] font-black uppercase transition cursor-pointer",
                  currentView === "server"
                    ? "bg-[#ff3a3a] text-white border-[#ff3a3a]"
                    : "border-[#ff3a3a]/40 bg-[#ff3a3a]/15 text-[#ff4d4d] hover:bg-[#ff3a3a]/30"
                )}
              >
                <Server className="h-3.5 w-3.5" />
                <span>Regions</span>
              </button>
              <button 
                type="button"
                onClick={onClose}
                className="flex items-center gap-1.5 px-3 py-1 rounded-lg border border-[#ff3a3a]/30 text-white/80 hover:text-white hover:border-[#ff3a3a] bg-[#181216] text-[11px] font-semibold transition cursor-pointer"
              >
                <span>Esc</span>
                <X className="h-3.5 w-3.5 text-[#ff4d4d]" />
              </button>
            </div>
          </div>

          {/* MAIN GRID VIEW */}
          {currentView === "grid" && (
            <div className="flex-1 flex flex-col justify-between min-h-0">
              <div className="flex-1 flex flex-col min-h-0">
                {/* 2 Column Module Cards Grid */}
                <div className="grid grid-cols-2 gap-3 flex-1 overflow-y-auto custom-scrollbar p-1.5 pr-2">
                  {moduleItems.map((item) => (
                    <div 
                      key={item.id}
                      onClick={item.action}
                      className="group flex items-center justify-between p-4 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] hover:border-[#ff3a3a] hover:bg-[#ff3a3a]/25 transition-all cursor-pointer"
                    >
                      <div className="flex items-center gap-3.5 min-w-0 flex-1">
                        <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-[#ff3a3a]/20 border border-[#ff3a3a] text-white">
                          {item.icon}
                        </div>
                        <div className="flex flex-col text-left min-w-0 flex-1">
                          <div className="flex items-center gap-2">
                            <span className="text-xs font-black text-white truncate">{item.name}</span>
                            <span className="text-[8px] font-black uppercase tracking-wider px-1.5 py-0.5 rounded bg-[#ff3a3a]/20 text-[#ff8080] border border-[#ff3a3a]/40">
                              {item.tag}
                            </span>
                          </div>
                          <span className="text-[10px] text-[#a08890] mt-1 leading-snug line-clamp-2 pr-2">
                            {item.desc}
                          </span>
                        </div>
                      </div>
                      <ChevronRight className="h-4 w-4 text-[#ff4d4d] group-hover:translate-x-1 transition shrink-0 ml-2" />
                    </div>
                  ))}
                </div>
              </div>
              
              {/* Official Modern Footer */}
              <div className="flex items-center justify-between border-t border-[#ff3a3a]/25 pt-3.5 mt-3 shrink-0">
                <div className="flex items-center gap-2.5">
                  <img src={grimLogo} alt="Grim City" className="h-5 w-5 object-contain" />
                  <div className="flex flex-col text-left">
                    <span className="text-[10px] font-black tracking-[0.2em] text-white">
                      GRIM CITY ROLEPLAY
                    </span>
                    <span className="text-[8px] font-semibold text-[#a08890] tracking-wider">
                      INSTANCE SPLITTING ARCHITECTURE
                    </span>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-[#ff3a3a]/15 border border-[#ff3a3a]/40 text-[9px] font-black uppercase text-[#ff4d4d]">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#ff3a3a] animate-pulse" />
                    VERIFIED v2.4
                  </div>
                  <span className="text-[10px] tracking-[0.16em] text-[#a08890]">
                    Powered by <strong className="text-[#ff4d4d]">KodeByKarl.Net</strong>
                  </span>
                </div>
              </div>
            </div>
          )}

          {/* SUBVIEW: Server Instance Changer */}
          {currentView === "server" && (
            <div className="flex-1 flex flex-col justify-between overflow-hidden">
              
              {/* Top Navigation Tabs & Status Bar */}
              <div className="space-y-3 shrink-0 mb-3">
                {/* Safezone & Lock Validation Status Banner */}
                <div className={cn(
                  "border rounded-xl px-4 py-2.5 flex items-center justify-between transition",
                  inSafezone && !isLocked
                    ? "border-emerald-500/40 bg-emerald-500/10 text-emerald-400"
                    : "border-red-500/40 bg-red-500/10 text-red-400"
                )}>
                  <div className="flex items-center gap-2.5 text-xs font-bold">
                    {inSafezone && !isLocked ? (
                      <>
                        <ShieldCheck className="h-4 w-4 text-emerald-400 shrink-0" />
                        <span>Safezone Verified — Server switching unlocked</span>
                      </>
                    ) : (
                      <>
                        <Lock className="h-4 w-4 text-red-400 shrink-0" />
                        <span>Server switching locked — {lockReason || "Outside Safezone / In Jail / In Job"}</span>
                      </>
                    )}
                  </div>
                  <button
                    type="button"
                    onClick={loadServerRealms}
                    disabled={loadingServers}
                    className="flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-black/40 border border-white/10 hover:border-white/30 text-[9.5px] font-black uppercase tracking-wider text-white transition cursor-pointer"
                  >
                    <RefreshCw className={cn("h-3 w-3", loadingServers && "animate-spin")} />
                    Refresh
                  </button>
                </div>

                {/* Category Sub-Tabs */}
                <div className="flex items-center gap-2 border-b border-[#ff3a3a]/25 pb-2">
                  <button
                    type="button"
                    onClick={() => setServerSubTab("public")}
                    className={cn(
                      "flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-black uppercase tracking-wider transition cursor-pointer border",
                      serverSubTab === "public"
                        ? "bg-[#ff3a3a] text-white border-[#ff3a3a]"
                        : "bg-[#181216] text-[#a08890] border-white/10 hover:text-white"
                    )}
                  >
                    <Server className="h-3.5 w-3.5" />
                    <span>Public Servers ({publicServers.length})</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setServerSubTab("jobs")}
                    className={cn(
                      "flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-black uppercase tracking-wider transition cursor-pointer border",
                      serverSubTab === "jobs"
                        ? "bg-[#ff3a3a] text-white border-[#ff3a3a]"
                        : "bg-[#181216] text-[#a08890] border-white/10 hover:text-white"
                    )}
                  >
                    <Briefcase className="h-3.5 w-3.5" />
                    <span>Side Job Servers ({jobServers.length})</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setServerSubTab("faq")}
                    className={cn(
                      "flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-black uppercase tracking-wider transition cursor-pointer border",
                      serverSubTab === "faq"
                        ? "bg-[#ff3a3a] text-white border-[#ff3a3a]"
                        : "bg-[#181216] text-[#a08890] border-white/10 hover:text-white"
                    )}
                  >
                    <HelpCircle className="h-3.5 w-3.5" />
                    <span>Why Instances Exist?</span>
                  </button>
                </div>
              </div>

              {/* TAB 1: Public City Servers (4 Instances - 600 Players Each) */}
              {serverSubTab === "public" && (
                <div className="flex-1 overflow-y-auto custom-scrollbar pr-2 mb-2 space-y-3">
                  {publicServers.map((realm) => {
                    const isBusy = switchingServer === realm.id;
                    const cap = realm.maxPlayers > 0 ? realm.maxPlayers : 1
                    const playerPct = Math.min(100, Math.round((realm.onlinePlayers / cap) * 100));
                    const canSwitch = inSafezone && !isLocked && !realm.isCurrent;

                    return (
                      <div
                        key={realm.id}
                        className={cn(
                          "flex flex-col gap-2.5 p-3.5 border rounded-xl transition bg-[#181216]",
                          realm.isCurrent
                            ? "border-[#ff3a3a] bg-[#ff3a3a]/15"
                            : "border-white/10 hover:border-[#ff3a3a]/50"
                        )}
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-3.5">
                            <div
                              className={cn(
                                "h-10 w-10 rounded-xl flex items-center justify-center border shrink-0",
                                realm.isCurrent
                                  ? "bg-[#ff3a3a] text-white border-[#ff3a3a]"
                                  : "bg-[#0d0d12] text-[#a08890] border-white/10"
                              )}
                            >
                              <Server className="h-5 w-5" />
                            </div>
                            <div className="flex flex-col text-left">
                              <div className="flex items-center gap-2">
                                <span className="text-xs font-black text-white">{realm.name}</span>
                                <span className="text-[8px] font-black uppercase tracking-wider px-1.5 py-0.5 rounded bg-[#ff3a3a]/20 text-[#ff8080] border border-[#ff3a3a]/40">
                                  {realm.tag}
                                </span>
                                {realm.isCurrent && (
                                  <span className="flex items-center gap-1 text-[8.5px] font-black uppercase text-emerald-400 bg-emerald-500/15 border border-emerald-500/30 px-2 py-0.5 rounded-md">
                                    <CheckCircle2 className="h-3 w-3" /> CONNECTED (CURRENT)
                                  </span>
                                )}
                              </div>
                              <span className="text-[10px] text-[#a08890] mt-0.5">
                                {realm.description}
                              </span>
                              {realm.functions && realm.functions.length > 0 && (
                                <div className="flex flex-wrap gap-1 mt-1">
                                  {realm.functions.map((fn) => (
                                    <span
                                      key={fn}
                                      className="text-[8px] font-black uppercase tracking-wider px-1.5 py-0.5 rounded bg-black/40 text-[#ffc2c2] border border-[#ff3a3a]/30"
                                    >
                                      {fn}
                                    </span>
                                  ))}
                                </div>
                              )}
                            </div>
                          </div>

                          {realm.isCurrent ? (
                            <span className="text-[10px] font-black text-emerald-400 uppercase tracking-wider px-3 py-1.5 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
                              Active Server
                            </span>
                          ) : (
                            <button
                              type="button"
                              onClick={() => handleSwitchServer(realm)}
                              disabled={!canSwitch || isBusy}
                              className={cn(
                                "flex items-center gap-1.5 px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider transition cursor-pointer shrink-0 border",
                                canSwitch
                                  ? "bg-gradient-to-r from-[#ff4d4d] via-[#e61e1e] to-[#b30000] text-white border-[#ff3a3a] hover:brightness-110"
                                  : "bg-[#181216] text-[#a08890] border-white/10 opacity-50 cursor-not-allowed"
                              )}
                            >
                              {isBusy ? (
                                <>
                                  <RefreshCw className="h-3.5 w-3.5 animate-spin" />
                                  Connecting...
                                </>
                              ) : !canSwitch ? (
                                <>
                                  <Lock className="h-3.5 w-3.5 text-red-400" />
                                  Locked (Outside Safezone)
                                </>
                              ) : (
                                <>
                                  <LogOut className="h-3.5 w-3.5" />
                                  Switch Server
                                </>
                              )}
                            </button>
                          )}
                        </div>

                        {/* Live Players Capacity Bar */}
                        <div className="flex items-center gap-3 pt-1 border-t border-white/5">
                          <div className="flex items-center gap-1.5 text-[10px] text-white font-bold shrink-0">
                            <Users className="h-3.5 w-3.5 text-[#ff4d4d]" />
                            <span>{realm.onlinePlayers} / {realm.maxPlayers} Players</span>
                          </div>

                          <div className="flex-1 h-2 rounded-full bg-[#0d0d12] border border-white/10 overflow-hidden">
                            <div
                              className={cn(
                                "h-full transition-all duration-500 rounded-full",
                                playerPct >= 90 ? "bg-amber-500" : "bg-[#ff3a3a]"
                              )}
                              style={{ width: `${playerPct}%` }}
                            />
                          </div>

                          <span className="text-[9.5px] font-bold text-[#a08890] shrink-0">
                            {playerPct}% Capacity
                          </span>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}

              {/* TAB 2: Side Job Servers (Dedicated Grinding Instances - 30 Max Each) */}
              {serverSubTab === "jobs" && (
                <div className="flex-1 overflow-y-auto custom-scrollbar pr-2 mb-2 space-y-3">
                  <div className="border border-[#ff3a3a]/40 rounded-xl p-3.5 bg-[#ff3a3a]/10 space-y-2">
                    <div className="flex items-center gap-2 text-white font-bold text-xs">
                      <Briefcase className="h-4 w-4 text-[#ff4d4d]" />
                      <span>Side Job Instance Protocol & How to Join</span>
                    </div>
                    <ul className="grid grid-cols-2 gap-2 text-[10px] text-[#a08890] leading-relaxed">
                      <li className="flex items-center gap-1.5 bg-[#0d0d12]/60 p-2 rounded-lg border border-white/5">
                        <span className="text-[#ff4d4d] font-black">1.</span> Open Regions in Control Center (F5).
                      </li>
                      <li className="flex items-center gap-1.5 bg-[#0d0d12]/60 p-2 rounded-lg border border-white/5">
                        <span className="text-[#ff4d4d] font-black">2.</span> Join the Orange instance from this tab.
                      </li>
                      <li className="flex items-center gap-1.5 bg-[#0d0d12]/60 p-2 rounded-lg border border-white/5">
                        <span className="text-[#ff4d4d] font-black">3.</span> Grind oranges without Farm-region lag.
                      </li>
                      <li className="flex items-center gap-1.5 bg-[#0d0d12]/60 p-2 rounded-lg border border-white/5">
                        <span className="text-[#ff4d4d] font-black">4.</span> Switch back to Region 1 · All Farm when finished.
                      </li>
                    </ul>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    {jobServers.map((jobSrv) => {
                      const isBusy = switchingServer === jobSrv.id;
                      const canSwitch = inSafezone && !isLocked && !jobSrv.isCurrent;
                      return (
                      <div key={jobSrv.id} className={cn("p-3.5 rounded-xl border flex flex-col justify-between gap-2.5", jobSrv.isCurrent ? "border-[#ff3a3a] bg-[#ff3a3a]/15" : "border-[#ff3a3a]/30 bg-[#181216]")}>
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2.5">
                            <div className="h-8 w-8 rounded-lg bg-[#ff3a3a]/20 border border-[#ff3a3a] flex items-center justify-center text-white">
                              <Briefcase className="h-4 w-4" />
                            </div>
                            <div className="flex flex-col text-left">
                              <span className="text-xs font-bold text-white">{jobSrv.name}</span>
                              <span className="text-[9px] text-[#a08890]">{jobSrv.description}</span>
                            </div>
                          </div>
                          <span className="px-2 py-0.5 rounded text-[8px] font-black uppercase tracking-wider bg-[#ff3a3a]/20 text-[#ff8080] border border-[#ff3a3a]/40">
                            {jobSrv.tag}
                          </span>
                        </div>

                        <div className="flex items-center justify-between border-t border-white/5 pt-2 text-[10px]">
                          <span className="text-[#a08890]">{jobSrv.onlinePlayers} / {jobSrv.maxPlayers} Players</span>
                          {jobSrv.isCurrent ? (
                            <span className="text-[9px] font-black text-emerald-400 uppercase">Active Instance</span>
                          ) : (
                            <button
                              type="button"
                              onClick={() => handleSwitchServer(jobSrv)}
                              disabled={!canSwitch || isBusy}
                              className={cn(
                                "flex items-center gap-1 px-2.5 py-1 rounded-lg text-[9px] font-black uppercase tracking-wider transition cursor-pointer border",
                                canSwitch
                                  ? "bg-[#ff3a3a] text-white border-[#ff3a3a] hover:brightness-110"
                                  : "bg-[#181216] text-[#a08890] border-white/10 opacity-50 cursor-not-allowed"
                              )}
                            >
                              {isBusy ? "Joining..." : "Join Instance"}
                            </button>
                          )}
                        </div>
                      </div>
                      );
                    })}
                  </div>
                </div>
              )}

              {/* TAB 3: Why Instances Exist FAQ */}
              {serverSubTab === "faq" && (
                <div className="flex-1 overflow-y-auto custom-scrollbar pr-2 mb-2 space-y-3">
                  <div className="p-4 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] space-y-3">
                    <div className="flex items-center gap-2 text-[#ff4d4d] border-b border-[#ff3a3a]/20 pb-2">
                      <Info className="h-4.5 w-4.5" />
                      <span className="text-xs font-black uppercase tracking-wider">Why Instance Splitting Exists?</span>
                    </div>

                    <p className="text-[11px] text-[#a08890] leading-relaxed">
                      Regions split the city in-game (same character, same inventory). Region 1 = All Farm. Region 2 = School. Region 3 & 4 = Turf War. Players only see others in the same region. Your last region is saved and restored when you reconnect.
                    </p>

                    <div className="grid grid-cols-3 gap-3 pt-1">
                      <div className="p-3 rounded-xl border border-[#ff3a3a]/20 bg-[#0d0d12]">
                        <span className="text-[10px] font-black text-[#ff4d4d] uppercase block mb-1">Zero Wipe</span>
                        <span className="text-[9.5px] text-[#a08890]">Your character, inventory, weapons, and money are 100% shared across all instances.</span>
                      </div>

                      <div className="p-3 rounded-xl border border-[#ff3a3a]/20 bg-[#0d0d12]">
                        <span className="text-[10px] font-black text-[#ff4d4d] uppercase block mb-1">Smooth Performance</span>
                        <span className="text-[9.5px] text-[#a08890]">Eliminates frame drops in high-density areas like Legion Square and police department.</span>
                      </div>

                      <div className="p-3 rounded-xl border border-[#ff3a3a]/20 bg-[#0d0d12]">
                        <span className="text-[10px] font-black text-[#ff4d4d] uppercase block mb-1">Safezone Protection</span>
                        <span className="text-[9.5px] text-[#a08890]">Server switching is locked outside safezones or during jail/combat to prevent combat logging.</span>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              <div className="flex justify-end border-t border-[#ff3a3a]/25 pt-3.5 mt-2">
                <button
                  type="button"
                  onClick={() => setCurrentView("grid")}
                  className="px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider bg-[#ff3a3a] text-white border border-[#ff3a3a] hover:brightness-110 transition cursor-pointer"
                >
                  Return to Modules
                </button>
              </div>
            </div>
          )}

          {/* SUBVIEW: Multi-Job Roster */}
          {currentView === "multijob" && (
            <div className="flex-1 flex flex-col justify-between overflow-hidden">
              <div className="flex-1 overflow-y-auto custom-scrollbar pr-2 mb-2 space-y-3">
                <div className="border border-[#ff3a3a]/40 rounded-xl p-3.5 flex items-center justify-between bg-[#ff3a3a]/10">
                  <div className="flex items-center gap-3">
                    <ShieldAlert className="h-4.5 w-4.5 text-[#ff4d4d] shrink-0" />
                    <div className="flex flex-col text-left">
                      <span className="text-[11px] font-bold text-white">Multi-Job Duty Protocol</span>
                      <span className="text-[9.5px] text-[#a08890] mt-0.5">
                        Maximum 3 held jobs allowed. You can only be ON DUTY at 1 job at a time.
                      </span>
                    </div>
                  </div>
                  <span className="px-2.5 py-1 rounded-lg bg-[#ff3a3a] text-white text-[10px] font-black tracking-wider uppercase shrink-0 border border-[#ff3a3a]">
                    {jobsList.length} / 3 HELD
                  </span>
                </div>

                {loadingJobs ? (
                  <div className="text-center text-xs text-[#a08890] py-8">Loading Multi-Job Roster...</div>
                ) : jobsList.length === 0 ? (
                  <div className="text-center text-xs text-[#a08890] py-8">No employment positions found. Get hired by a business or gang!</div>
                ) : (
                  jobsList.map((jobItem) => {
                    const isJobActive = activeJob === jobItem.job;
                    return (
                      <div key={jobItem.job} className={cn("flex items-center justify-between p-3.5 border rounded-xl transition bg-[#181216]", isJobActive ? "border-[#ff3a3a] bg-[#ff3a3a]/15" : "border-white/10")}>
                        <div className="flex items-center gap-3">
                          <div className={cn("h-9 w-9 rounded-lg flex items-center justify-center border", isJobActive ? "bg-[#ff3a3a] text-white border-[#ff3a3a]" : "bg-[#0d0d12] text-[#a08890] border-white/10")}>
                            <Briefcase className="h-4.5 w-4.5" />
                          </div>
                          <div className="flex flex-col text-left">
                            <div className="flex items-center gap-2">
                              <span className="text-xs font-bold text-white">{jobItem.label}</span>
                              {isJobActive && (
                                <span className="flex items-center gap-1 text-[8.5px] font-black uppercase text-emerald-400 bg-emerald-500/15 border border-emerald-500/30 px-2 py-0.5 rounded-md">
                                  <CheckCircle2 className="h-3 w-3" /> ACTIVE ON DUTY
                                </span>
                              )}
                            </div>
                            <span className="text-[9.5px] text-[#a08890] mt-0.5">
                              Rank Grade: {jobItem.grade_label} (Grade {jobItem.grade})
                            </span>
                          </div>
                        </div>

                        <button
                          onClick={() => handleToggleJobDuty(jobItem.job)}
                          className={cn(
                            "flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg text-xs font-black uppercase tracking-wider transition cursor-pointer shrink-0 border",
                            isJobActive
                              ? "bg-red-500/20 text-red-400 border-red-500/40 hover:bg-red-500/30"
                              : "bg-[#ff3a3a] text-white border-[#ff3a3a] hover:brightness-110"
                          )}
                        >
                          <Power className="h-3.5 w-3.5" />
                          {isJobActive ? "Clock Off" : "Clock On"}
                        </button>
                      </div>
                    );
                  })
                )}
              </div>

              <div className="flex justify-end border-t border-[#ff3a3a]/25 pt-3.5 mt-2">
                <button
                  onClick={() => setCurrentView("grid")}
                  className="px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider bg-[#ff3a3a] text-white border border-[#ff3a3a] hover:brightness-110 transition cursor-pointer"
                >
                  Return to Modules
                </button>
              </div>
            </div>
          )}

          {/* SUBVIEW: Rockstar Recording */}
          {currentView === "rockstar" && (
            <div className="flex-1 flex flex-col justify-between overflow-hidden">
              <div className="flex-1 overflow-y-auto custom-scrollbar pr-2 mb-2 space-y-3">
                <div className={cn(
                  "border rounded-xl p-3.5 flex items-center justify-between bg-[#181216]",
                  recording ? "border-red-500 bg-red-500/10" : "border-[#ff3a3a]/40"
                )}>
                  <div className="flex items-center gap-2.5">
                    <Circle className={cn("h-3 w-3", recording ? "fill-red-500 text-red-500 animate-pulse" : "text-[#a08890]")} />
                    <div className="flex flex-col text-left">
                      <span className="text-[11px] font-bold text-white">{recording ? "Recording in-game" : "Not recording"}</span>
                      <span className="text-[9.5px] text-[#a08890] mt-0.5">
                        {recording
                          ? "Play normally, then save or discard the clip here."
                          : "Start a clip without leaving the server."}
                      </span>
                    </div>
                  </div>
                  <span className={cn(
                    "px-2.5 py-1 rounded-lg text-[10px] font-black tracking-wider uppercase border",
                    recording ? "bg-red-500 text-white border-red-500" : "bg-[#0d0d12] text-[#a08890] border-white/10"
                  )}>
                    {recording ? "REC" : "IDLE"}
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-2.5">
                  <button
                    type="button"
                    disabled={rockstarBusy || recording}
                    onClick={() => handleRockstarAction("record")}
                    className="flex items-center gap-3 p-3.5 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] text-left transition hover:border-[#ff3a3a] disabled:opacity-40 cursor-pointer"
                  >
                    <Circle className="h-4 w-4 fill-red-500 text-red-500 shrink-0" />
                    <div className="flex flex-col">
                      <span className="text-xs font-bold text-white">Record</span>
                      <span className="text-[9.5px] text-[#a08890]">Start in-game clip</span>
                    </div>
                  </button>
                  <button
                    type="button"
                    disabled={rockstarBusy || !recording}
                    onClick={() => handleRockstarAction("save")}
                    className="flex items-center gap-3 p-3.5 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] text-left transition hover:border-[#ff3a3a] disabled:opacity-40 cursor-pointer"
                  >
                    <Save className="h-4 w-4 text-[#ff4d4d] shrink-0" />
                    <div className="flex flex-col">
                      <span className="text-xs font-bold text-white">Save clip</span>
                      <span className="text-[9.5px] text-[#a08890]">Keep to editor gallery</span>
                    </div>
                  </button>
                  <button
                    type="button"
                    disabled={rockstarBusy || !recording}
                    onClick={() => handleRockstarAction("delete")}
                    className="flex items-center gap-3 p-3.5 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] text-left transition hover:border-[#ff3a3a] disabled:opacity-40 cursor-pointer"
                  >
                    <Trash2 className="h-4 w-4 text-red-400 shrink-0" />
                    <div className="flex flex-col">
                      <span className="text-xs font-bold text-white">Discard</span>
                      <span className="text-[9.5px] text-[#a08890]">Throw away this take</span>
                    </div>
                  </button>
                  <button
                    type="button"
                    disabled={rockstarBusy}
                    onClick={() => handleRockstarAction("photo")}
                    className="flex items-center gap-3 p-3.5 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] text-left transition hover:border-[#ff3a3a] disabled:opacity-40 cursor-pointer"
                  >
                    <Camera className="h-4 w-4 text-cyan-400 shrink-0" />
                    <div className="flex flex-col">
                      <span className="text-xs font-bold text-white">Photo</span>
                      <span className="text-[9.5px] text-[#a08890]">High quality screenshot</span>
                    </div>
                  </button>
                </div>
              </div>

              <div className="flex justify-end border-t border-[#ff3a3a]/25 pt-3.5 mt-2">
                <button
                  onClick={() => setCurrentView("grid")}
                  className="px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider bg-[#ff3a3a] text-white border border-[#ff3a3a] hover:brightness-110 transition cursor-pointer"
                >
                  Return to Modules
                </button>
              </div>
            </div>
          )}

          {/* SUBVIEW: Patch Notes */}
          {currentView === "patchnotes" && (
            <div className="flex-1 flex flex-col justify-between overflow-hidden">
              <div className="flex-1 overflow-y-auto custom-scrollbar pr-2 mb-2 space-y-3.5 max-h-[320px]">
                {patchNotes.length === 0 ? (
                  <p className="rounded-xl border border-[#ff3a3a]/30 p-8 text-center text-xs text-[#a08890]">
                    No patch notes available.
                  </p>
                ) : (
                  patchNotes.map((patch, idx) => (
                    <div key={`${patch.version}-${idx}`} className="rounded-xl border border-[#ff3a3a]/30 bg-[#181216] p-4">
                      <div className="flex items-center justify-between border-b border-[#ff3a3a]/20 pb-2 mb-2">
                        <div className="flex items-center gap-2">
                          <span className="text-[10px] font-bold text-[#ff4d4d] tracking-wider">{patch.version}</span>
                          <span className="text-[10px] text-[#a08890]">· {patch.date}</span>
                          {idx === 0 && (
                            <span className="text-[9px] font-black uppercase tracking-wider text-[#ff4d4d]">Latest</span>
                          )}
                        </div>
                        <span className="text-[9px] font-black uppercase px-2 py-0.5 rounded bg-[#ff3a3a]/20 text-[#ff8080] border border-[#ff3a3a]/40">
                          {patch.tag}
                        </span>
                      </div>
                      <h4 className="text-xs font-bold text-white">{patch.title}</h4>
                      <ul className="mt-2 space-y-1 pl-1">
                        {(patch.notes || []).map((note, nIdx) => (
                          <li key={nIdx} className="text-[10px] text-[#a08890] list-disc list-inside leading-relaxed">
                            {note}
                          </li>
                        ))}
                      </ul>
                    </div>
                  ))
                )}
              </div>

              <div className="flex justify-end border-t border-[#ff3a3a]/25 pt-3.5 mt-2">
                <button
                  onClick={() => setCurrentView("grid")}
                  className="px-4 py-2 rounded-xl text-xs font-black uppercase tracking-wider bg-[#ff3a3a] text-white border border-[#ff3a3a] hover:brightness-110 transition cursor-pointer"
                >
                  Return to Modules
                </button>
              </div>
            </div>
          )}

        </div>

      </div>
    </div>
  );
}
