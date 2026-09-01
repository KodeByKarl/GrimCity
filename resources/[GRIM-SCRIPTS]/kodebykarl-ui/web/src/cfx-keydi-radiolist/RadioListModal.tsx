import React, { useEffect } from "react";
import { X, Radio, Mic } from "lucide-react";
import pandoraLogo from "@/assets/pandora-city-logo.png";
import { RadioPlayer } from "./RadioListHud";

interface RadioListModalProps {
  visible?: boolean;
  channel?: string | null;
  players?: RadioPlayer[];
  onClose?: () => void;
}

export const RadioListModal: React.FC<RadioListModalProps> = ({
  visible = true,
  channel = "100.0 MHz",
  players = [],
  onClose
}) => {
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.key === "Escape" || e.key === "Backspace") && onClose) {
        onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [onClose]);

  if (!visible) return null;

  return (
    <div className="pandora fixed inset-0 z-[9999] flex items-center justify-center bg-black/60 backdrop-blur-sm select-none animate-in fade-in zoom-in-95 duration-200">
      {/* Radio Roster Card Shell */}
      <div 
        className="relative w-[380px] max-h-[520px] rounded-2xl border overflow-hidden font-sans text-white flex flex-col shadow-[0_22px_55px_rgba(0,0,0,0.95),0_0_35px_rgba(255,61,150,0.22)]"
        style={{
          background: "linear-gradient(180deg, #092849 0%, #05182d 100%)",
          borderColor: "rgba(255, 122, 181, 0.35)"
        }}
      >
        {/* Top Glow Accent Bar */}
        <div className="h-[3px] w-full bg-gradient-to-r from-[#ff3d96] via-[#35c7f2] to-[#ffd24c] shadow-[0_0_12px_rgba(255,61,150,0.6)]" />

        {/* Close Button */}
        {onClose && (
          <button
            onClick={onClose}
            className="absolute top-3 right-3 z-10 p-1 rounded-full bg-[#ff3d96]/20 text-[#ffa6ce] hover:text-white hover:bg-[#ff3d96]/40 transition-all cursor-pointer opacity-70 hover:opacity-100"
            title="Close (ESC / Backspace)"
          >
            <X className="w-4 h-4" />
          </button>
        )}

        {/* HEADER */}
        <div className="p-4 border-b border-[#ff3d96]/25 space-y-0.5">
          <div className="flex items-center space-x-2">
            <Radio className="w-4 h-4 text-[#35c7f2]" />
            <h2 className="text-base font-extrabold text-white uppercase tracking-tight">
              RADIO MEMBERS
            </h2>
          </div>
          <p className="text-[11px] font-bold text-[#8fe4ff]/80">
            {channel || "Disconnected"} · {players.length} connected
          </p>
        </div>

        {/* CONNECTED PLAYERS LIST */}
        <div className="p-3 flex-1 overflow-y-auto space-y-2 max-h-[360px]">
          {players.length > 0 ? (
            players.map((p) => (
              <div 
                key={p.id}
                className={`flex items-center justify-between p-2.5 rounded-xl border transition-colors ${
                  p.talking 
                    ? "bg-[#ff3d96]/15 border-[#ff3d96]/45" 
                    : p.self 
                    ? "bg-[#35c7f2]/10 border-[#35c7f2]/30" 
                    : "bg-[#041526]/80 border-[#35c7f2]/15"
                }`}
              >
                {/* Left Side: Indicator Dot & Name */}
                <div className="flex items-center space-x-2.5 min-w-0">
                  <div className="relative flex items-center justify-center shrink-0">
                    <div 
                      className={`w-2.5 h-2.5 rounded-full ${
                        p.talking ? "bg-[#ff3d96] shadow-[0_0_10px_#ff3d96]" : "bg-[#ffd24c]"
                      }`}
                    />
                    {p.talking && (
                      <div className="absolute w-4 h-4 rounded-full border border-[#ff3d96] animate-ping" />
                    )}
                  </div>

                  <span className="text-xs font-bold text-white truncate max-w-[170px]">
                    {p.name}
                  </span>
                </div>

                {/* Right Side: Tags (YOU / TALKING) */}
                <div className="flex items-center space-x-1.5 shrink-0">
                  {p.self && (
                    <span className="text-[9px] font-extrabold text-[#8fe4ff] bg-[#35c7f2]/20 border border-[#35c7f2]/40 px-2 py-0.5 rounded-full uppercase">
                      YOU
                    </span>
                  )}
                  {p.talking && (
                    <span className="flex items-center gap-1 text-[9px] font-black text-[#ff3d96] bg-[#ff3d96]/20 border border-[#ff3d96]/40 px-2 py-0.5 rounded-full uppercase animate-pulse">
                      <Mic className="w-3 h-3" /> TALKING...
                    </span>
                  )}
                </div>
              </div>
            ))
          ) : (
            <div className="py-8 text-center text-xs font-semibold text-[#9cc3e6]/60 italic">
              No players currently connected to this frequency.
            </div>
          )}
        </div>

        {/* FOOTER */}
        <div className="p-3 border-t border-[#ff3d96]/25 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <img src={pandoraLogo} alt="Pandora City" className="h-4.5 w-4.5 object-contain" />
            <span className="text-[10px] font-black text-[#ffa6ce] tracking-[0.18em]">
              PANDORA CITY RADIO
            </span>
          </div>

          <span className="text-[9px] font-extrabold text-[#8fe4ff]/60 uppercase tracking-wider">
            PRESS [ESC] TO CLOSE
          </span>
        </div>

      </div>
    </div>
  );
};

export default RadioListModal;
