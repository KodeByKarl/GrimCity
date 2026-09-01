import React, { useState, useEffect, useRef } from "react";
import { Users, Move } from "lucide-react";

export interface RadioPlayer {
  id: number;
  serverId: number;
  name: string;
  self: boolean;
  talking: boolean;
}

interface RadioListHudProps {
  channel?: string | null;
  players?: RadioPlayer[];
  editMode?: boolean;
  hudVisible?: boolean;
  onExitEdit?: () => void;
}

export const RadioListHud: React.FC<RadioListHudProps> = ({
  channel = "100.0 MHz",
  players = [],
  editMode = false,
  hudVisible = true,
  onExitEdit
}) => {
  const [pos, setPos] = useState(() => {
    const saved = localStorage.getItem("pandora_radio_pos");
    if (saved) {
      try { return JSON.parse(saved); } catch (e) {}
    }
    return {
      x: window.innerWidth - 220,
      y: window.innerHeight / 2 - 100,
    };
  });

  const dragRef = useRef({
    down: false,
    sx: 0,
    sy: 0,
    bx: 0,
    by: 0,
  });

  const startDrag = (e: React.MouseEvent) => {
    if (!editMode) return;
    dragRef.current.down = true;
    dragRef.current.sx = e.clientX;
    dragRef.current.sy = e.clientY;
    dragRef.current.bx = pos.x;
    dragRef.current.by = pos.y;
  };

  useEffect(() => {
    const onMouseMove = (e: MouseEvent) => {
      if (!dragRef.current.down) return;
      const dx = e.clientX - dragRef.current.sx;
      const dy = e.clientY - dragRef.current.sy;
      setPos({ x: dragRef.current.bx + dx, y: dragRef.current.by + dy });
    };

    const onMouseUp = () => {
      if (!dragRef.current.down) return;
      dragRef.current.down = false;
      localStorage.setItem("pandora_radio_pos", JSON.stringify(pos));
    };

    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("mouseup", onMouseUp);
    return () => {
      window.removeEventListener("mousemove", onMouseMove);
      window.removeEventListener("mouseup", onMouseUp);
    };
  }, [pos]);

  if (!hudVisible && !editMode) return null;

  const activeTalkers = players.filter((p) => p.talking);

  return (
    <div
      style={{ left: pos.x, top: pos.y }}
      className={`pandora fixed z-[9990] select-none transition-shadow ${
        editMode ? "cursor-grab ring-2 ring-[#ff3d96] ring-offset-2 ring-offset-black/50" : ""
      }`}
      onMouseDown={startDrag}
    >
      {/* Pandora City Radio HUD Card */}
      <div 
        className="w-44 rounded-xl border overflow-hidden text-white font-sans shadow-[0_12px_30px_rgba(0,0,0,0.85),0_0_20px_rgba(255,61,150,0.18)]"
        style={{
          background: "linear-gradient(180deg, #082645 0%, #04182b 100%)",
          borderColor: "rgba(255, 122, 181, 0.35)"
        }}
      >
        {/* Top Glow Accent Bar */}
        <div className="h-[2px] w-full bg-gradient-to-r from-[#ff3d96] via-[#35c7f2] to-[#ffd24c]" />

        {/* HEADER */}
        <div className="py-2 px-3 border-b border-[#ff3d96]/20 flex items-center justify-between">
          {/* Signal Indicator Bars */}
          <div className="flex items-end gap-[2px]">
            <div className="w-1 h-1.5 bg-[#35c7f2]/50 rounded-sm" />
            <div className="w-1 h-2 bg-[#35c7f2]/70 rounded-sm" />
            <div className="w-1 h-2.5 bg-[#35c7f2]/90 rounded-sm" />
            <div className="w-1 h-3 bg-[#ff3d96] rounded-sm shadow-[0_0_6px_#ff3d96]" />
          </div>

          <h3 className="text-xs font-black tracking-wider text-[#35c7f2] uppercase">
            RADIO
          </h3>

          {/* Channel Frequency Badge */}
          <span className="text-[10px] font-black text-[#ffa6ce] bg-[#ff3d96]/20 border border-[#ff3d96]/40 px-1.5 py-0.5 rounded shadow-[0_0_8px_rgba(255,61,150,0.2)]">
            {channel || "—"}
          </span>
        </div>

        {/* ACTIVE TALKERS */}
        <div className="py-2 px-3 space-y-1.5 min-h-[36px] max-h-36 overflow-y-auto">
          {activeTalkers.length > 0 ? (
            activeTalkers.map((p) => (
              <div key={p.id} className="flex items-center justify-between gap-1.5">
                <div className="flex items-center gap-2 min-w-0">
                  <div className="relative flex items-center justify-center shrink-0">
                    <div className="w-2 h-2 rounded-full bg-[#ff3d96] shadow-[0_0_8px_#ff3d96]" />
                    <div className="absolute w-4 h-4 rounded-full border border-[#ff3d96]/60 animate-ping" />
                  </div>
                  <span className="text-[11px] font-bold text-white truncate max-w-[95px]">
                    {p.name}
                  </span>
                </div>
                <span className="text-[9px] font-black text-[#ff3d96] tracking-wider uppercase shrink-0">
                  TNC
                </span>
              </div>
            ))
          ) : (
            <div className="text-[10px] font-semibold text-[#9cc3e6]/60 text-center py-1 italic">
              {editMode ? "Drag to reposition HUD" : "No active talkers"}
            </div>
          )}
        </div>

        {/* FOOTER */}
        <div className="py-1.5 px-3 border-t border-[#ff3d96]/20 flex items-center justify-between text-[10px]">
          {editMode ? (
            <span className="text-[9px] font-black text-[#ffd24c] uppercase tracking-wider flex items-center gap-1">
              <Move className="w-3 h-3" /> DRAG MODE
            </span>
          ) : (
            <span className="text-[9px] font-bold text-[#8fe4ff]/70 tracking-widest uppercase">
              PANDORA
            </span>
          )}

          <div className="flex items-center gap-1 text-[#ffa6ce] font-extrabold">
            <Users className="w-3 h-3 text-[#35c7f2]" />
            <span>{players.length}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RadioListHud;
