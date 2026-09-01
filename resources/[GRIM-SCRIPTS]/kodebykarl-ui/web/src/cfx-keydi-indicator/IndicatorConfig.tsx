import React, { useState, useEffect, useRef } from "react";
import { 
  Skull, HeartCrack, Ghost, AlertTriangle, X, Ban, 
  Smile, Sparkles, ChevronDown, Sliders, Eye, Palette, Type, Shield, Check
} from "lucide-react";
import { cn } from "@/lib/utils";
import grimLogo from "@/assets/grim-city-logo.png";

interface IndicatorSettings {
  deadText: string;
  deadIcon: string;
  fontFamily: string;
  fontSize: number;
  duration: number;
  healthColor: string;
  armorColor: string;
}

interface IndicatorConfigProps {
  settings: IndicatorSettings;
  onClose: () => void;
}

const FONTS = ["Outfit", "JetBrains Mono", "Inter", "Roboto", "Arial", "Consolas"];

const ICONS = [
  { id: "skull", name: "Skull", icon: <Skull className="h-4 w-4" /> },
  { id: "crossbones", name: "Crossbones", icon: <Skull className="h-4 w-4 rotate-12" /> },
  { id: "heart-crack", name: "Heart Crack", icon: <HeartCrack className="h-4 w-4" /> },
  { id: "ghost", name: "Ghost", icon: <Ghost className="h-4 w-4" /> },
  { id: "danger", name: "Danger", icon: <AlertTriangle className="h-4 w-4" /> },
  { id: "sick", name: "Sick", icon: <Smile className="h-4 w-4 rotate-180" /> },
  { id: "x-mark", name: "X Mark", icon: <X className="h-4 w-4" /> },
  { id: "skull-io", name: "Skull (Io)", icon: <Skull className="h-4 w-4 text-[#ff8080]" /> },
  { id: "ban", name: "Ban", icon: <Ban className="h-4 w-4" /> },
];

function CustomDropdown({
  value,
  options,
  onChange,
}: {
  value: string;
  options: string[];
  onChange: (val: string) => void;
}) {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <div ref={containerRef} className="relative w-full">
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between rounded-xl border border-[#ff3a3a]/40 bg-[#0d0d12] px-3.5 py-2 text-xs font-bold text-white hover:border-[#ff3a3a] transition cursor-pointer"
      >
        <span style={{ fontFamily: value }}>{value}</span>
        <ChevronDown className={cn("h-3.5 w-3.5 text-[#ff4d4d] transition-transform duration-200", isOpen && "rotate-180")} />
      </button>

      {isOpen && (
        <div className="absolute left-0 right-0 top-full mt-1.5 z-50 rounded-xl border border-[#ff3a3a] bg-[#140d11] p-1.5 shadow-2xl overflow-hidden animate-in fade-in slide-in-from-top-2 duration-150">
          <div className="flex flex-col gap-1 max-h-48 overflow-y-auto custom-scrollbar">
            {options.map((opt) => {
              const isSelected = opt === value;
              return (
                <button
                  key={opt}
                  type="button"
                  onClick={() => {
                    onChange(opt);
                    setIsOpen(false);
                  }}
                  className={cn(
                    "flex items-center justify-between px-3 py-2 rounded-lg text-xs font-bold transition cursor-pointer text-left",
                    isSelected
                      ? "bg-[#ff3a3a]/25 text-[#ff4d4d] border border-[#ff3a3a]/40"
                      : "text-white/80 hover:bg-[#ff3a3a]/15 hover:text-white"
                  )}
                >
                  <span style={{ fontFamily: opt }}>{opt}</span>
                  {isSelected && <Check className="h-3.5 w-3.5 text-[#ff4d4d]" />}
                </button>
              );
            })}
          </div>
        </div>
      )}
    </div>
  );
}

export default function IndicatorConfig({ settings: initialSettings, onClose }: IndicatorConfigProps) {
  const [settings, setSettings] = useState<IndicatorSettings>({ ...initialSettings });
  const [showDeadState, setShowDeadState] = useState(false);
  const [previewDamage, setPreviewDamage] = useState<{ id: number; type: string; amount: string; offset: number }[]>([]);

  // ESC Key listener
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [onClose]);

  // Periodically generate damage numbers in the preview panel
  useEffect(() => {
    const triggerPreview = (type: string, amount: string | number) => {
      const id = Date.now() + Math.random();
      const offset = Math.random() * 40 - 20;

      setPreviewDamage((prev) => [...prev, { id, type, amount: String(amount), offset }]);

      setTimeout(() => {
        setPreviewDamage((prev) => prev.filter((item) => item.id !== id));
      }, 1800);
    };

    const interval = setInterval(() => {
      if (showDeadState) {
        triggerPreview("dead", settings.deadText || "Dead");
      } else {
        const type = Math.random() > 0.5 ? "health" : "armor";
        const amt = type === "health" 
          ? `-${Math.floor(Math.random() * 30 + 15)}` 
          : `-${Math.floor(Math.random() * 20 + 5)}`;
        triggerPreview(type, amt);
      }
    }, 1200);

    return () => clearInterval(interval);
  }, [showDeadState, settings.deadText]);

  // Post update to game client whenever settings change (Auto-Save)
  const updateSetting = (key: keyof IndicatorSettings, value: any) => {
    const updated = { ...settings, [key]: value };
    setSettings(updated);

    const resourceName = (window as any).GetParentResourceName 
      ? (window as any).GetParentResourceName() 
      : "cfx-keydi-ui";

    fetch(`https://${resourceName}/indicator:updateSettings`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: JSON.stringify(updated)
    }).catch(() => {});
  };

  const getSelectedIconElement = () => {
    const item = ICONS.find((i) => i.id === settings.deadIcon);
    return item ? item.icon : <Skull className="h-4 w-4" />;
  };

  return (
    <div className="pandora fixed inset-0 flex items-center justify-center p-8 bg-black/80 backdrop-blur-[6px] select-none pointer-events-auto animate-fade-in font-sans z-40">
      <div className="pandora-panel flex flex-col w-full max-w-5xl rounded-2xl border-2 border-[#ff3a3a] overflow-hidden h-[620px] bg-[#0d0d12] relative">
        <div className="panel-grid absolute inset-0 pointer-events-none opacity-30" />

        {/* HEADER BAR */}
        <div className="relative z-10 flex items-center justify-between border-b border-[#ff3a3a]/30 px-6 py-4 shrink-0 bg-[#140d11]">
          <div className="flex items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#ff3a3a]/20 border border-[#ff3a3a] text-white">
              <Sliders className="h-4.5 w-4.5 text-[#ff4d4d]" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-[#ff4d4d]">COMBAT UI CONFIG</span>
                <span className="px-2 py-0.5 rounded text-[8px] font-black uppercase tracking-wider bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                  AUTO-SAVED
                </span>
              </div>
              <h2 className="text-sm font-black text-white tracking-tight mt-0.5">Damage Indicator Settings</h2>
            </div>
          </div>

          <button 
            onClick={onClose}
            className="flex items-center gap-1.5 px-3 py-1 rounded-lg border border-[#ff3a3a]/30 text-white/80 hover:text-white hover:border-[#ff3a3a] bg-[#181216] text-[11px] font-semibold transition cursor-pointer"
          >
            <span>Esc</span>
            <X className="h-3.5 w-3.5 text-[#ff4d4d]" />
          </button>
        </div>

        {/* MAIN SPLIT CONTENT BODY */}
        <div className="relative z-10 grid grid-cols-2 gap-6 p-6 flex-1 min-h-0">

          {/* LEFT COLUMN: LIVE PREVIEW VIEWPORT */}
          <div className="flex flex-col h-full justify-between rounded-xl border border-[#ff3a3a]/30 p-4 bg-[#140d11] min-h-0">
            <div className="flex items-center justify-between border-b border-[#ff3a3a]/20 pb-2.5 shrink-0">
              <div className="flex items-center gap-2 text-[#ff4d4d]">
                <Eye className="h-4 w-4" />
                <span className="text-[10px] font-black uppercase tracking-wider">LIVE VIEWPORT PREVIEW</span>
              </div>
              <span className="text-[9px] font-bold text-[#a08890]">Real-time simulation</span>
            </div>

            {/* Target Crosshair & Flying Damage Area */}
            <div className="relative flex-1 my-3 rounded-xl border border-[#ff3a3a]/20 overflow-hidden bg-[#0d0d12] flex items-center justify-center">
              {/* Grid Background */}
              <div className="panel-grid absolute inset-0 pointer-events-none opacity-40" />

              {/* Center Crosshair Dot */}
              <div className="absolute left-1/2 top-1/2 h-2 w-2 rounded-full -translate-x-1/2 -translate-y-1/2 bg-[#ff3a3a] z-10" />
              <div className="absolute left-1/2 top-1/2 w-6 h-0.5 -translate-x-1/2 -translate-y-1/2 bg-[#ff3a3a]/40" />
              <div className="absolute left-1/2 top-1/2 h-6 w-0.5 -translate-x-1/2 -translate-y-1/2 bg-[#ff3a3a]/40" />

              {/* Animated Flying Damage Numbers */}
              <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                {previewDamage.map((d) => (
                  <div 
                    key={d.id}
                    className="absolute animate-preview-float text-center font-black"
                    style={{
                      fontFamily: settings.fontFamily,
                      fontSize: `${settings.fontSize}px`,
                      color: d.type === "health" 
                        ? settings.healthColor 
                        : (d.type === "armor" ? settings.armorColor : "#ffffff"),
                      textShadow: "0 2px 4px rgba(0,0,0,0.9)",
                      ["--offset" as any]: `${d.offset}px`
                    }}
                  >
                    {d.type === "dead" && (
                      <span className="inline-flex items-center gap-1 uppercase">
                        {getSelectedIconElement()}
                        {d.amount}
                      </span>
                    )}
                    {d.type !== "dead" && d.amount}
                  </div>
                ))}
              </div>
            </div>

            {/* Live Toggle Bar */}
            <div className="flex items-center justify-between p-3 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] shrink-0">
              <div className="flex items-center gap-2">
                <Skull className="h-4 w-4 text-[#ff4d4d]" />
                <span className="text-[11px] font-bold text-white">Preview Dead State</span>
              </div>
              <button 
                type="button"
                onClick={() => setShowDeadState(!showDeadState)}
                className={`relative inline-flex h-5.5 w-10 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out ${showDeadState ? "bg-[#ff3a3a]" : "bg-zinc-700"}`}
              >
                <span className={`pointer-events-none inline-block h-4.5 w-4.5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${showDeadState ? "translate-x-4.5" : "translate-x-0"}`} />
              </button>
            </div>
          </div>

          {/* RIGHT COLUMN: CONTROLS & STYLING */}
          <div className="flex flex-col h-full justify-between overflow-y-auto custom-scrollbar pr-1 space-y-4">
            
            {/* SECTION 1: DEAD STATE TEXT & ICONS */}
            <div className="p-4 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] space-y-3">
              <div className="flex items-center gap-2 text-[#ff4d4d] border-b border-[#ff3a3a]/20 pb-2">
                <Skull className="h-4 w-4" />
                <span className="text-[10px] font-black uppercase tracking-wider">DEAD STATE LABEL & ICON</span>
              </div>

              <div>
                <label className="text-[9px] font-black uppercase tracking-wider text-[#ff4d4d] block mb-1">DEAD LABEL TEXT</label>
                <input 
                  type="text" 
                  value={settings.deadText}
                  onChange={(e) => updateSetting("deadText", e.target.value)}
                  placeholder="e.g. DEAD, ELIMINATED"
                  className="w-full rounded-xl border border-[#ff3a3a]/40 bg-[#0d0d12] px-3.5 py-2 text-xs font-semibold text-white placeholder:text-[#a08890]/60 focus:outline-none focus:border-[#ff3a3a]"
                  maxLength={16}
                />
              </div>

              <div>
                <label className="text-[9px] font-black uppercase tracking-wider text-[#ff4d4d] block mb-1.5">DEAD ICON SELECTOR</label>
                <div className="grid grid-cols-5 gap-1.5">
                  {ICONS.map((ico) => (
                    <button
                      key={ico.id}
                      type="button"
                      onClick={() => updateSetting("deadIcon", ico.id)}
                      className={`flex flex-col items-center justify-center rounded-xl border p-2 py-2 gap-1 transition-all cursor-pointer ${
                        settings.deadIcon === ico.id 
                          ? "border-[#ff3a3a] bg-[#ff3a3a]/25 text-[#ff4d4d]" 
                          : "border-white/10 bg-[#0d0d12] text-[#a08890] hover:text-white"
                      }`}
                    >
                      {ico.icon}
                      <span className="text-[8.5px] font-bold tracking-tight truncate w-full text-center">{ico.name}</span>
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* SECTION 2: TYPOGRAPHY & TIMING */}
            <div className="p-4 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] space-y-3">
              <div className="flex items-center gap-2 text-[#ff4d4d] border-b border-[#ff3a3a]/20 pb-2">
                <Type className="h-4 w-4" />
                <span className="text-[10px] font-black uppercase tracking-wider">TYPOGRAPHY & DURATION</span>
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="text-[9px] font-black uppercase tracking-wider text-[#ff4d4d] block mb-1">FONT FAMILY</label>
                  <CustomDropdown
                    value={settings.fontFamily}
                    options={FONTS}
                    onChange={(val) => updateSetting("fontFamily", val)}
                  />
                </div>

                <div>
                  <label className="text-[9px] font-black uppercase tracking-wider text-[#ff4d4d] block mb-1">FONT SIZE (PX)</label>
                  <input 
                    type="number" 
                    value={settings.fontSize}
                    onChange={(e) => updateSetting("fontSize", Math.max(10, Math.min(40, parseInt(e.target.value) || 10)))}
                    className="w-full rounded-xl border border-[#ff3a3a]/40 bg-[#0d0d12] px-3 py-2 text-xs font-semibold text-white focus:outline-none focus:border-[#ff3a3a]"
                    min={10}
                    max={40}
                  />
                </div>

                <div>
                  <label className="text-[9px] font-black uppercase tracking-wider text-[#ff4d4d] block mb-1">DURATION (SEC)</label>
                  <input 
                    type="number" 
                    step="0.5"
                    value={settings.duration}
                    onChange={(e) => updateSetting("duration", Math.max(0.5, Math.min(10, parseFloat(e.target.value) || 1)))}
                    className="w-full rounded-xl border border-[#ff3a3a]/40 bg-[#0d0d12] px-3 py-2 text-xs font-semibold text-white focus:outline-none focus:border-[#ff3a3a]"
                    min={0.5}
                    max={10}
                  />
                </div>
              </div>
            </div>

            {/* SECTION 3: COLORS */}
            <div className="p-4 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] space-y-3">
              <div className="flex items-center gap-2 text-[#ff4d4d] border-b border-[#ff3a3a]/20 pb-2">
                <Palette className="h-4 w-4" />
                <span className="text-[10px] font-black uppercase tracking-wider">DAMAGE COLOR SCHEME</span>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-[9px] font-black uppercase tracking-wider text-[#ff4d4d] block mb-1">HEALTH DAMAGE</label>
                  <div className="flex gap-2">
                    <div 
                      className="h-8.5 w-8.5 rounded-xl border border-[#ff3a3a]/40 shrink-0 cursor-pointer hover:border-[#ff3a3a] transition-colors relative overflow-hidden"
                      style={{ backgroundColor: settings.healthColor }}
                      onClick={() => document.getElementById("healthColorPicker")?.click()}
                    >
                      <input 
                        type="color" 
                        id="healthColorPicker"
                        value={settings.healthColor}
                        onChange={(e) => updateSetting("healthColor", e.target.value)}
                        className="absolute inset-0 opacity-0 cursor-pointer w-full h-full"
                      />
                    </div>
                    <input 
                      type="text" 
                      value={settings.healthColor}
                      onChange={(e) => updateSetting("healthColor", e.target.value)}
                      className="flex-1 rounded-xl border border-[#ff3a3a]/40 bg-[#0d0d12] px-3 py-2 text-xs font-semibold text-white focus:outline-none focus:border-[#ff3a3a]"
                      placeholder="#ff4d4d"
                      maxLength={7}
                    />
                  </div>
                </div>

                <div>
                  <label className="text-[9px] font-black uppercase tracking-wider text-[#ff4d4d] block mb-1">ARMOUR DAMAGE</label>
                  <div className="flex gap-2">
                    <div 
                      className="h-8.5 w-8.5 rounded-xl border border-[#ff3a3a]/40 shrink-0 cursor-pointer hover:border-[#ff3a3a] transition-colors relative overflow-hidden"
                      style={{ backgroundColor: settings.armorColor }}
                      onClick={() => document.getElementById("armorColorPicker")?.click()}
                    >
                      <input 
                        type="color" 
                        id="armorColorPicker"
                        value={settings.armorColor}
                        onChange={(e) => updateSetting("armorColor", e.target.value)}
                        className="absolute inset-0 opacity-0 cursor-pointer w-full h-full"
                      />
                    </div>
                    <input 
                      type="text" 
                      value={settings.armorColor}
                      onChange={(e) => updateSetting("armorColor", e.target.value)}
                      className="flex-1 rounded-xl border border-[#ff3a3a]/40 bg-[#0d0d12] px-3 py-2 text-xs font-semibold text-white focus:outline-none focus:border-[#ff3a3a]"
                      placeholder="#38bdf8"
                      maxLength={7}
                    />
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>

        {/* FOOTER */}
        <div className="relative z-10 flex items-center justify-between border-t border-[#ff3a3a]/30 px-6 py-3 shrink-0 bg-[#140d11]">
          <div className="flex items-center gap-2.5">
            <img src={grimLogo} alt="Grim City" className="h-5 w-5 object-contain" />
            <span className="text-[10px] font-black tracking-[0.2em] text-white uppercase">
              GRIM CITY ROLEPLAY
            </span>
          </div>
          <span className="text-[10px] tracking-[0.16em] text-[#a08890]">
            Powered by <strong className="text-[#ff4d4d]">KodeByKarl.Net</strong>
          </span>
        </div>
      </div>
    </div>
  );
}
