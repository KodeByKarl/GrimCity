import React, { useState, useEffect } from "react";
import { 
  Wifi, 
  Battery, 
  Radio, 
  ShieldAlert, 
  X,
  Volume2,
  VolumeX,
  Flame,
  Shield
} from "lucide-react";
import { OfficerProfile } from "../types/mdt";

interface MdtHeaderProps {
  officer: OfficerProfile | null;
  dutyStatus: string;
  activeAlert: { type: string; title: string; message: string; priority?: string } | null;
  onClearAlert: () => void;
  isMuted: boolean;
  onToggleMute: () => void;
  onOpenPanic: () => void;
  onGoHome: () => void;
}

export default function MdtHeader({
  officer,
  dutyStatus,
  activeAlert,
  onClearAlert,
  isMuted,
  onToggleMute,
  onOpenPanic,
  onGoHome
}: MdtHeaderProps) {
  const [time, setTime] = useState("");

  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      setTime(now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }));
    };
    updateTime();
    const interval = setInterval(updateTime, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <header className="relative z-30 px-5 py-2.5 flex items-center justify-between text-xs select-none border-b border-slate-800 bg-[#090d19]">
      {/* Left: Department & In-Game Time */}
      <div className="flex items-center gap-3 text-slate-300 font-medium">
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-lg bg-cyan-600/30 border border-cyan-500/40 flex items-center justify-center text-cyan-300">
            <Shield className="w-3.5 h-3.5" />
          </div>
          <span className="font-mono font-bold text-white text-xs tracking-wider">
            {officer?.department || "LSPD"} MOBILE DATA TERMINAL
          </span>
        </div>
        <span className="text-slate-600">|</span>
        <span className="font-semibold tracking-wider text-slate-200 text-xs">{time || "09:41"}</span>
        <div className="flex items-center gap-1 opacity-90 text-[11px] font-mono text-cyan-400">
          <Radio className="w-3.5 h-3.5" />
          <span>5G ENCRYPTED</span>
        </div>
      </div>

      {/* Center: Dynamic Island Alert Banner */}
      <div className="absolute left-1/2 -translate-x-1/2 top-1.5">
        <div 
          onClick={activeAlert ? onClearAlert : onGoHome}
          className={`group flex items-center gap-2 px-3.5 py-1 rounded-full border transition-all duration-300 cursor-pointer shadow-xl ${
            activeAlert 
              ? activeAlert.priority === 'urgent' || activeAlert.type === 'panic'
                ? 'bg-red-950 border-red-500 text-red-200 shadow-red-500/40 ring-2 ring-red-500/40 animate-pulse'
                : 'bg-amber-950 border-amber-500/60 text-amber-200 shadow-amber-500/20'
              : 'bg-[#0f172a] border-slate-700/80 hover:border-cyan-500/50 shadow-black'
          }`}
        >
          <div className="w-2 h-2 rounded-full bg-slate-900 ring-1 ring-slate-700 flex items-center justify-center">
            <div className="w-1 h-1 rounded-full bg-cyan-400 animate-ping opacity-75" />
          </div>

          {activeAlert ? (
            <div className="flex items-center gap-2 max-w-sm">
              <ShieldAlert className="w-3.5 h-3.5 text-red-400 shrink-0" />
              <div className="truncate text-left">
                <span className="font-bold uppercase tracking-wider text-red-300 text-[10px] mr-1.5">
                  {activeAlert.title}
                </span>
                <span className="text-slate-300 text-[11px] truncate">{activeAlert.message}</span>
              </div>
              <X className="w-3 h-3 text-slate-400 hover:text-white shrink-0 ml-1" />
            </div>
          ) : (
            <div className="flex items-center gap-2">
              <div className={`w-2 h-2 rounded-full ${dutyStatus === '10-8' ? 'bg-emerald-400' : 'bg-amber-400'}`} />
              <span className="text-[11px] font-bold text-slate-200">
                {officer ? `${officer.name} (${officer.callsign})` : "OFFICER ON DUTY"}
              </span>
              <span className="text-[9px] uppercase font-mono px-1.5 py-0.2 rounded bg-slate-800 text-slate-300 border border-slate-700">
                {dutyStatus}
              </span>
            </div>
          )}
        </div>
      </div>

      {/* Right: Panic Button, Audio, and Battery */}
      <div className="flex items-center gap-3 text-slate-300">
        {/* Panic Button 10-99 */}
        <button
          onClick={onOpenPanic}
          className="flex items-center gap-1.5 px-3 py-1 rounded-xl bg-red-600/20 border border-red-500/50 text-red-300 hover:bg-red-600 hover:text-white transition-all shadow-md active:scale-95"
          title="Broadcast Emergency 10-99 Distress Beacon"
        >
          <Flame className="w-3.5 h-3.5 text-red-400 animate-pulse" />
          <span className="font-black text-[10px] tracking-wider">10-99 PANIC</span>
        </button>

        {/* Audio Toggle */}
        <button
          onClick={onToggleMute}
          className="p-1.5 rounded-lg bg-slate-800/80 hover:bg-slate-700 text-slate-300 hover:text-white transition-colors border border-slate-700"
          title={isMuted ? "Unmute Audio" : "Mute Audio"}
        >
          {isMuted ? <VolumeX className="w-3.5 h-3.5 text-slate-500" /> : <Volume2 className="w-3.5 h-3.5 text-cyan-400" />}
        </button>

        {/* Wi-Fi & Battery */}
        <div className="flex items-center gap-1.5 bg-slate-800/80 px-2 py-1 rounded-lg border border-slate-700 text-[11px] font-mono">
          <Wifi className="w-3.5 h-3.5 text-cyan-400" />
          <span className="text-slate-200 font-bold">100%</span>
          <Battery className="w-3.5 h-3.5 text-emerald-400" />
        </div>
      </div>
    </header>
  );
}
