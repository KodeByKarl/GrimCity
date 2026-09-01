import React from "react";
import { 
  Users, 
  Car, 
  ShieldAlert, 
  FileText, 
  Scale, 
  Radio, 
  Shield, 
  Settings, 
  AlertTriangle, 
  Flame, 
  Clock, 
  CheckCircle2, 
  ChevronRight,
  TrendingUp
} from "lucide-react";
import { MdtAppId, OfficerProfile, Warrant, Bolo, IncidentReport, DutyOfficer, DispatchCall } from "../types/mdt";

interface MdtHomeGridProps {
  officer: OfficerProfile | null;
  dutyStatus: string;
  onSetDutyStatus: (status: string) => void;
  onOpenApp: (app: MdtAppId) => void;
  warrants: Warrant[];
  bolos: Bolo[];
  incidents: IncidentReport[];
  activeOfficers: DutyOfficer[];
  dispatchCalls: DispatchCall[];
}

export default function MdtHomeGrid({
  officer,
  dutyStatus,
  onSetDutyStatus,
  onOpenApp,
  warrants,
  bolos,
  incidents,
  activeOfficers,
  dispatchCalls
}: MdtHomeGridProps) {
  const activeWarrantsCount = warrants.filter(w => w.status === 'Active').length;
  const activeBolosCount = bolos.filter(b => b.status === 'active').length;
  const activeCallsCount = dispatchCalls.filter(c => c.status === 'active').length;

  const appIcons = [
    {
      id: "citizens" as MdtAppId,
      label: "Citizens",
      sub: "Profiles & Priors",
      icon: Users,
      badge: 0,
      gradient: "from-blue-600 to-indigo-700",
      glow: "hover:shadow-blue-500/30 hover:border-blue-400/50"
    },
    {
      id: "vehicles" as MdtAppId,
      label: "Vehicles",
      sub: "Plates & Flags",
      icon: Car,
      badge: 0,
      gradient: "from-emerald-600 to-teal-700",
      glow: "hover:shadow-emerald-500/30 hover:border-emerald-400/50"
    },
    {
      id: "warrants" as MdtAppId,
      label: "Warrants & BOLOs",
      sub: "Arrests & APBs",
      icon: ShieldAlert,
      badge: activeWarrantsCount + activeBolosCount,
      gradient: "from-red-600 to-rose-700",
      glow: "hover:shadow-red-500/30 hover:border-red-400/50"
    },
    {
      id: "incidents" as MdtAppId,
      label: "Incidents",
      sub: "Reports & Evidence",
      icon: FileText,
      badge: incidents.length,
      gradient: "from-amber-600 to-orange-700",
      glow: "hover:shadow-amber-500/30 hover:border-amber-400/50"
    },
    {
      id: "penal" as MdtAppId,
      label: "Penal Code",
      sub: "Laws & Calculator",
      icon: Scale,
      badge: 0,
      gradient: "from-purple-600 to-violet-700",
      glow: "hover:shadow-purple-500/30 hover:border-purple-400/50"
    },
    {
      id: "dispatch" as MdtAppId,
      label: "Dispatch & Radar",
      sub: "911 Calls & Units",
      icon: Radio,
      badge: activeCallsCount,
      gradient: "from-cyan-600 to-sky-700",
      glow: "hover:shadow-cyan-500/30 hover:border-cyan-400/50"
    },
    {
      id: "roster" as MdtAppId,
      label: "Roster",
      sub: "Duty & Bulletins",
      icon: Shield,
      badge: activeOfficers.length,
      gradient: "from-slate-700 to-slate-900",
      glow: "hover:shadow-slate-500/30 hover:border-slate-400/50"
    },
    {
      id: "settings" as MdtAppId,
      label: "Settings",
      sub: "Themes & Audio",
      icon: Settings,
      badge: 0,
      gradient: "from-zinc-700 to-zinc-900",
      glow: "hover:shadow-zinc-500/30 hover:border-zinc-400/50"
    },
  ];

  return (
    <div className="flex-1 flex flex-col p-8 overflow-y-auto custom-scrollbar">
      {/* Top Welcome / Officer Briefing & Widgets */}
      <div className="grid grid-cols-12 gap-6 mb-8">
        {/* Officer Status Card */}
        <div className="col-span-12 lg:col-span-7 bg-slate-900/70 backdrop-blur-xl border border-white/10 rounded-3xl p-6 shadow-xl relative overflow-hidden flex flex-col justify-between">
          <div className="absolute top-0 right-0 w-64 h-64 bg-cyan-500/10 rounded-full blur-3xl -mr-16 -mt-16 pointer-events-none" />

          <div>
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span className="px-2.5 py-1 rounded-full text-[10px] font-bold tracking-wider uppercase bg-cyan-500/20 text-cyan-300 border border-cyan-500/30">
                  {officer?.department || "LSPD"} HEADQUARTERS
                </span>
                <span className="text-xs text-slate-400">Badge #{officer?.badge_number || "001"}</span>
              </div>
              <span className="text-xs font-mono text-emerald-400 flex items-center gap-1.5 font-semibold">
                <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                SYSTEM ONLINE
              </span>
            </div>

            <h1 className="text-2xl font-black tracking-tight text-white mb-1">
              Welcome, {officer ? `${officer.rank} ${officer.name}` : "Officer"}
            </h1>
            <p className="text-xs text-slate-300">
              Callsign <strong className="text-cyan-300 font-mono">{officer?.callsign || "1-A-01"}</strong>. Stay alert and coordinate with active patrol units.
            </p>
          </div>

          {/* Quick 10-Code Duty Status Switcher */}
          <div className="mt-6 pt-4 border-t border-white/10 flex items-center justify-between gap-2 flex-wrap">
            <span className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Patrol Status:</span>
            <div className="flex items-center gap-2">
              {[
                { code: "10-8", label: "10-8 Available", color: "bg-emerald-600/30 border-emerald-500/40 text-emerald-300 hover:bg-emerald-600/50" },
                { code: "10-6", label: "10-6 Busy", color: "bg-amber-600/30 border-amber-500/40 text-amber-300 hover:bg-amber-600/50" },
                { code: "10-97", label: "10-97 Scene", color: "bg-cyan-600/30 border-cyan-500/40 text-cyan-300 hover:bg-cyan-600/50" },
                { code: "10-7", label: "10-7 Off Duty", color: "bg-slate-700/40 border-slate-600/40 text-slate-300 hover:bg-slate-700/60" },
              ].map((s) => (
                <button
                  key={s.code}
                  onClick={() => onSetDutyStatus(s.code)}
                  className={`px-3 py-1.5 rounded-xl text-xs font-semibold border transition-all duration-200 ${s.color} ${
                    dutyStatus === s.code ? 'ring-2 ring-white/60 shadow-lg scale-105' : 'opacity-70 hover:opacity-100'
                  }`}
                >
                  {s.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Live Metrics Grid */}
        <div className="col-span-12 lg:col-span-5 grid grid-cols-2 gap-4">
          <div 
            onClick={() => onOpenApp("warrants")}
            className="bg-slate-900/60 backdrop-blur-xl border border-white/10 hover:border-red-500/40 rounded-3xl p-4 cursor-pointer transition-all duration-200 hover:scale-[1.02] shadow-lg group"
          >
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Active Warrants</span>
              <ShieldAlert className="w-4 h-4 text-red-400 group-hover:scale-110 transition-transform" />
            </div>
            <div className="text-3xl font-black text-white">{activeWarrantsCount}</div>
            <div className="text-[10px] text-red-300 mt-1 flex items-center gap-1">
              <span>View arrest orders</span>
              <ChevronRight className="w-3 h-3" />
            </div>
          </div>

          <div 
            onClick={() => onOpenApp("warrants")}
            className="bg-slate-900/60 backdrop-blur-xl border border-white/10 hover:border-amber-500/40 rounded-3xl p-4 cursor-pointer transition-all duration-200 hover:scale-[1.02] shadow-lg group"
          >
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Active BOLOs</span>
              <AlertTriangle className="w-4 h-4 text-amber-400 group-hover:scale-110 transition-transform" />
            </div>
            <div className="text-3xl font-black text-white">{activeBolosCount}</div>
            <div className="text-[10px] text-amber-300 mt-1 flex items-center gap-1">
              <span>View broadcasts</span>
              <ChevronRight className="w-3 h-3" />
            </div>
          </div>

          <div 
            onClick={() => onOpenApp("dispatch")}
            className="bg-slate-900/60 backdrop-blur-xl border border-white/10 hover:border-cyan-500/40 rounded-3xl p-4 cursor-pointer transition-all duration-200 hover:scale-[1.02] shadow-lg group"
          >
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">911 Calls</span>
              <Radio className="w-4 h-4 text-cyan-400 group-hover:scale-110 transition-transform" />
            </div>
            <div className="text-3xl font-black text-white">{activeCallsCount}</div>
            <div className="text-[10px] text-cyan-300 mt-1 flex items-center gap-1">
              <span>Open live queue</span>
              <ChevronRight className="w-3 h-3" />
            </div>
          </div>

          <div 
            onClick={() => onOpenApp("roster")}
            className="bg-slate-900/60 backdrop-blur-xl border border-white/10 hover:border-indigo-500/40 rounded-3xl p-4 cursor-pointer transition-all duration-200 hover:scale-[1.02] shadow-lg group"
          >
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Units On Duty</span>
              <Shield className="w-4 h-4 text-indigo-400 group-hover:scale-110 transition-transform" />
            </div>
            <div className="text-3xl font-black text-white">{activeOfficers.length || 1}</div>
            <div className="text-[10px] text-indigo-300 mt-1 flex items-center gap-1">
              <span>View active units</span>
              <ChevronRight className="w-3 h-3" />
            </div>
          </div>
        </div>
      </div>

      {/* SpringBoard App Grid */}
      <div className="mb-4">
        <h2 className="text-xs uppercase font-bold tracking-widest text-slate-400 mb-4 px-1">
          MDT Terminal Applications
        </h2>

        <div className="grid grid-cols-2 sm:grid-cols-4 gap-6">
          {appIcons.map((app) => {
            const Icon = app.icon;
            return (
              <button
                key={app.id}
                onClick={() => onOpenApp(app.id)}
                className={`group relative flex flex-col items-center p-5 rounded-3xl bg-slate-900/50 hover:bg-slate-900/80 backdrop-blur-md border border-white/10 transition-all duration-300 hover:scale-[1.04] shadow-xl text-center ${app.glow}`}
              >
                {/* App Badge */}
                {app.badge > 0 && (
                  <span className="absolute -top-2 -right-2 px-2 py-0.5 rounded-full bg-red-600 text-white font-bold text-[10px] shadow-lg ring-2 ring-slate-950 animate-bounce">
                    {app.badge}
                  </span>
                )}

                {/* Squircle App Icon */}
                <div className={`w-16 h-16 rounded-2xl bg-gradient-to-br ${app.gradient} flex items-center justify-center text-white shadow-lg mb-3 group-hover:shadow-2xl transition-all duration-300 border border-white/20`}>
                  <Icon className="w-8 h-8 group-hover:scale-110 transition-transform duration-300" />
                </div>

                <div className="text-sm font-bold text-white tracking-tight group-hover:text-cyan-300 transition-colors">
                  {app.label}
                </div>
                <div className="text-[11px] text-slate-400 font-medium mt-0.5">
                  {app.sub}
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
