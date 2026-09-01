import React from "react";
import { 
  Settings, 
  Palette, 
  Image as ImageIcon, 
  Volume2, 
  VolumeX, 
  Shield, 
  Check, 
  Sparkles,
  Info
} from "lucide-react";

interface SettingsModalProps {
  accentColor: string;
  onSetAccentColor: (color: string) => void;
  wallpaper: string;
  onSetWallpaper: (wallpaper: string) => void;
  isMuted: boolean;
  onToggleMute: () => void;
}

export default function SettingsModal({
  accentColor,
  onSetAccentColor,
  wallpaper,
  onSetWallpaper,
  isMuted,
  onToggleMute
}: SettingsModalProps) {
  const colorOptions = [
    { id: "cyan", name: "Police Cyan", hex: "#06b6d4", class: "from-cyan-600 to-blue-600" },
    { id: "emerald", name: "Sheriff Emerald", hex: "#10b981", class: "from-emerald-600 to-teal-700" },
    { id: "amber", name: "Trooper Gold", hex: "#f59e0b", class: "from-amber-600 to-yellow-600" },
    { id: "indigo", name: "FIB Royal Blue", hex: "#6366f1", class: "from-indigo-600 to-blue-700" },
    { id: "rose", name: "Tactical Crimson", hex: "#f43f5e", class: "from-rose-600 to-red-700" },
  ];

  const wallpaperOptions = [
    { id: "dark", name: "Midnight Glass", desc: "Frosted dark slate glassmorphism with subtle glow" },
    { id: "carbon", name: "Carbon Tactical", desc: "Textured high-tech carbon fiber finish" },
    { id: "cyber", name: "Cyberpunk Grid", desc: "Electric cyan and neon blue gradient matrix" },
    { id: "police", name: "Patrol Blue", desc: "Classic law enforcement navy gradient" }
  ];

  return (
    <div className="flex-1 flex flex-col p-6 overflow-y-auto custom-scrollbar">
      <div className="max-w-3xl mx-auto w-full space-y-6">
        <div>
          <h2 className="text-xl font-black text-white flex items-center gap-2">
            <Settings className="w-5 h-5 text-cyan-400" />
            MDT Terminal System Settings
          </h2>
          <p className="text-xs text-slate-400">
            Personalize your iPad MDT user interface, tactical accent styling, and audio settings.
          </p>
        </div>

        {/* Accent Colors */}
        <div className="bg-slate-900/60 backdrop-blur-xl border border-white/10 rounded-3xl p-6 shadow-xl">
          <div className="flex items-center gap-2 mb-4">
            <Palette className="w-4 h-4 text-cyan-400" />
            <h3 className="text-xs uppercase font-bold tracking-wider text-slate-300">
              Department Accent Theme
            </h3>
          </div>

          <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
            {colorOptions.map((opt) => {
              const isSelected = accentColor === opt.id;
              return (
                <button
                  key={opt.id}
                  onClick={() => onSetAccentColor(opt.id)}
                  className={`p-3 rounded-2xl border transition-all duration-200 flex flex-col items-center gap-2 ${
                    isSelected
                      ? 'bg-slate-800 border-white shadow-lg ring-2 ring-cyan-500/50 scale-105'
                      : 'bg-slate-800/40 border-white/10 hover:bg-slate-800/80 hover:border-white/20'
                  }`}
                >
                  <div className={`w-8 h-8 rounded-full bg-gradient-to-tr ${opt.class} flex items-center justify-center text-white shadow-md`}>
                    {isSelected && <Check className="w-4 h-4 stroke-[3]" />}
                  </div>
                  <span className="text-xs font-bold text-white text-center">{opt.name}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Wallpaper Picker */}
        <div className="bg-slate-900/60 backdrop-blur-xl border border-white/10 rounded-3xl p-6 shadow-xl">
          <div className="flex items-center gap-2 mb-4">
            <ImageIcon className="w-4 h-4 text-cyan-400" />
            <h3 className="text-xs uppercase font-bold tracking-wider text-slate-300">
              Tablet Background Wallpaper
            </h3>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {wallpaperOptions.map((wp) => {
              const isSelected = wallpaper === wp.id;
              return (
                <button
                  key={wp.id}
                  onClick={() => onSetWallpaper(wp.id)}
                  className={`p-4 rounded-2xl border text-left transition-all duration-200 flex items-start justify-between ${
                    isSelected
                      ? 'bg-slate-800 border-cyan-500/60 shadow-lg ring-1 ring-cyan-500/30'
                      : 'bg-slate-800/40 border-white/10 hover:bg-slate-800/80 hover:border-white/20'
                  }`}
                >
                  <div>
                    <div className="text-sm font-bold text-white flex items-center gap-2">
                      {wp.name}
                      {isSelected && <span className="px-2 py-0.5 rounded bg-cyan-500/20 text-cyan-300 text-[10px] font-mono">ACTIVE</span>}
                    </div>
                    <div className="text-xs text-slate-400 mt-1">{wp.desc}</div>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Audio Toggles */}
        <div className="bg-slate-900/60 backdrop-blur-xl border border-white/10 rounded-3xl p-6 shadow-xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-3 rounded-2xl bg-cyan-600/20 border border-cyan-500/30 text-cyan-300">
                {isMuted ? <VolumeX className="w-6 h-6" /> : <Volume2 className="w-6 h-6" />}
              </div>
              <div>
                <h4 className="text-sm font-bold text-white">Audio & Emergency Siren Engine</h4>
                <p className="text-xs text-slate-400">Tactile iPad click sounds, radio chimes, and 10-99 panic horn synthesizer.</p>
              </div>
            </div>

            <button
              onClick={onToggleMute}
              className={`px-5 py-2.5 rounded-2xl text-xs font-bold transition-all ${
                isMuted
                  ? 'bg-slate-800 text-slate-400 hover:text-white border border-white/10'
                  : 'bg-cyan-600 hover:bg-cyan-500 text-white shadow-lg shadow-cyan-600/30'
              }`}
            >
              {isMuted ? "Enable Audio" : "Muted"}
            </button>
          </div>
        </div>

        {/* System Info */}
        <div className="p-4 rounded-2xl bg-slate-950/40 border border-white/5 flex items-center justify-between text-xs text-slate-400 font-mono">
          <div className="flex items-center gap-2">
            <Info className="w-4 h-4 text-slate-500" />
            <span>cfx-keydi-mdt v2.0 • Cerulean Framework</span>
          </div>
          <span>ESX / oxmysql Integrated</span>
        </div>
      </div>
    </div>
  );
}
