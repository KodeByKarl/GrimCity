import React, { useState, useRef, useEffect } from "react";
import { 
  ZoomIn, 
  ZoomOut, 
  RotateCcw, 
  MapPin, 
  Navigation, 
  UserCheck, 
  Users, 
  ShieldAlert, 
  Clock, 
  Radio, 
  Layers, 
  Crosshair, 
  Flame,
  CheckCircle2,
  X
} from "lucide-react";
import { DispatchCall, DutyOfficer, OfficerProfile } from "../types/mdt";
import mapNight from "../../assets/map_night.jpg";
import mapDay from "../../assets/map_day.jpg";

interface InteractiveMapProps {
  dispatchCalls: DispatchCall[];
  activeOfficers: DutyOfficer[];
  currentOfficer: OfficerProfile | null;
  onSetGpsWaypoint: (coords: { x: number; y: number; z?: number }) => void;
  onAttachUnit: (callId: number) => void;
  onResolveCall: (callId: number) => void;
  selectedCallId?: number | null;
}

export default function InteractiveMap({
  dispatchCalls,
  activeOfficers,
  currentOfficer,
  onSetGpsWaypoint,
  onAttachUnit,
  onResolveCall,
  selectedCallId
}: InteractiveMapProps) {
  const [zoom, setZoom] = useState(1.2);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [mapType, setMapType] = useState<"night" | "day">("night");
  const [focusedCall, setFocusedCall] = useState<DispatchCall | null>(null);

  const containerRef = useRef<HTMLDivElement>(null);

  // Sync focused call if selectedCallId prop passed
  useEffect(() => {
    if (selectedCallId) {
      const target = dispatchCalls.find(c => c.id === selectedCallId);
      if (target) setFocusedCall(target);
    }
  }, [selectedCallId, dispatchCalls]);

  // World to Map % conversion for GTA 5 Map Coordinates
  const worldToMapPercent = (x: number, y: number) => {
    // GTA V map boundaries
    const minX = -3750;
    const maxX = 4250;
    const minY = -4100;
    const maxY = 7900;
    const percentX = ((x - minX) / (maxX - minX)) * 100;
    const percentY = ((maxY - y) / (maxY - minY)) * 100;
    return {
      x: Math.max(2, Math.min(98, percentX)),
      y: Math.max(2, Math.min(98, percentY))
    };
  };

  const handleMouseDown = (e: React.MouseEvent) => {
    if (e.button !== 0) return;
    setIsDragging(true);
    setDragStart({ x: e.clientX - pan.x, y: e.clientY - pan.y });
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging) return;
    setPan({
      x: e.clientX - dragStart.x,
      y: e.clientY - dragStart.y
    });
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleZoomIn = () => setZoom(prev => Math.min(4.0, prev + 0.3));
  const handleZoomOut = () => setZoom(prev => Math.max(0.8, prev - 0.3));
  const handleResetView = () => {
    setZoom(1.2);
    setPan({ x: 0, y: 0 });
    setFocusedCall(null);
  };

  const handleWheel = (e: React.WheelEvent) => {
    e.preventDefault();
    if (e.deltaY < 0) {
      setZoom(prev => Math.min(4.0, prev + 0.15));
    } else {
      setZoom(prev => Math.max(0.8, prev - 0.15));
    }
  };

  const activeCalls = dispatchCalls.filter(c => c.status === 'active');

  return (
    <div className="relative w-full h-full bg-[#05070d] rounded-2xl overflow-hidden select-none border border-slate-800 flex flex-col">
      {/* Top Map Control Bar */}
      <div className="absolute top-3 left-3 z-30 flex items-center gap-2">
        <div className="flex items-center gap-1 bg-[#0b101b]/90 backdrop-blur-md p-1 rounded-xl border border-slate-700/80 shadow-2xl">
          <button
            onClick={handleZoomIn}
            className="p-1.5 rounded-lg bg-slate-800/80 hover:bg-cyan-600 text-slate-300 hover:text-white transition-colors"
            title="Zoom In"
          >
            <ZoomIn className="w-4 h-4" />
          </button>
          <button
            onClick={handleZoomOut}
            className="p-1.5 rounded-lg bg-slate-800/80 hover:bg-cyan-600 text-slate-300 hover:text-white transition-colors"
            title="Zoom Out"
          >
            <ZoomOut className="w-4 h-4" />
          </button>
          <button
            onClick={handleResetView}
            className="p-1.5 rounded-lg bg-slate-800/80 hover:bg-cyan-600 text-slate-300 hover:text-white transition-colors"
            title="Reset Map View"
          >
            <RotateCcw className="w-4 h-4" />
          </button>
        </div>

        {/* Map Style Toggle */}
        <div className="flex items-center bg-[#0b101b]/90 backdrop-blur-md p-1 rounded-xl border border-slate-700/80 shadow-2xl">
          <button
            onClick={() => setMapType("night")}
            className={`px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase transition-all ${
              mapType === "night" ? "bg-cyan-600 text-white shadow-sm" : "text-slate-400 hover:text-white"
            }`}
          >
            Tactical Night
          </button>
          <button
            onClick={() => setMapType("day")}
            className={`px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase transition-all ${
              mapType === "day" ? "bg-cyan-600 text-white shadow-sm" : "text-slate-400 hover:text-white"
            }`}
          >
            Day Satellite
          </button>
        </div>
      </div>

      {/* Top Right Live Stats Pill */}
      <div className="absolute top-3 right-3 z-30 flex items-center gap-2 pointer-events-none">
        <div className="flex items-center gap-2 bg-[#0b101b]/90 backdrop-blur-md px-3 py-1.5 rounded-xl border border-slate-700/80 shadow-2xl">
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
          <span className="text-[11px] font-mono font-bold text-slate-200">
            {activeOfficers.length} Units • {activeCalls.length} Active Calls
          </span>
        </div>
      </div>

      {/* Main Pan/Zoom Interactive Map Canvas */}
      <div
        ref={containerRef}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
        onWheel={handleWheel}
        className={`relative flex-1 w-full h-full cursor-${isDragging ? 'grabbing' : 'grab'} overflow-hidden`}
        style={{ touchAction: "none" }}
      >
        <div
          className="absolute inset-0 transition-transform duration-75 origin-center"
          style={{
            transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})`,
          }}
        >
          {/* Base GTA 5 Map Image */}
          <img
            src={mapType === "night" ? mapNight : mapDay}
            alt="GTA 5 Satellite Map"
            className="w-full h-full object-contain pointer-events-none opacity-90"
            draggable={false}
          />

          {/* Active 911 Dispatch Call Blips */}
          {activeCalls.map((call) => {
            const coords = call.coords || { x: 0, y: 0 };
            const pos = worldToMapPercent(coords.x, coords.y);
            const isUrgent = call.priority === 'urgent' || call.code === '10-99';
            const isSelected = focusedCall?.id === call.id;

            return (
              <div
                key={`call-${call.id}`}
                onClick={(e) => {
                  e.stopPropagation();
                  setFocusedCall(call);
                }}
                className="absolute z-20 -translate-x-1/2 -translate-y-1/2 cursor-pointer group"
                style={{ left: `${pos.x}%`, top: `${pos.y}%` }}
              >
                {/* Pulsing Danger Waves */}
                <div className={`absolute -inset-2 rounded-full animate-ping opacity-75 ${
                  isUrgent ? 'bg-red-500' : call.priority === 'high' ? 'bg-orange-500' : 'bg-cyan-500'
                }`} />

                {/* Core Beacon Pin */}
                <div className={`relative flex items-center justify-center w-7 h-7 rounded-full shadow-2xl border-2 transition-transform duration-200 group-hover:scale-125 ${
                  isSelected 
                    ? 'bg-white border-cyan-400 ring-4 ring-cyan-500/50 scale-125' 
                    : isUrgent 
                      ? 'bg-red-600 border-white text-white' 
                      : 'bg-cyan-600 border-white text-white'
                }`}>
                  {isUrgent ? <Flame className="w-3.5 h-3.5 animate-bounce" /> : <ShieldAlert className="w-3.5 h-3.5" />}
                </div>

                {/* Floating Call Code Label */}
                <div className="absolute top-8 left-1/2 -translate-x-1/2 whitespace-nowrap bg-black/90 text-white font-mono text-[9px] font-bold px-1.5 py-0.5 rounded border border-slate-700 shadow-lg pointer-events-none">
                  {call.code}
                </div>
              </div>
            );
          })}

          {/* Active Officers Blips */}
          {activeOfficers.map((officer, i) => {
            const coords = officer.coords || { x: -300 + (i * 80), y: -700 + (i * 60) };
            const pos = worldToMapPercent(coords.x, coords.y);
            const isPanic = officer.status === '10-99';

            return (
              <div
                key={`unit-${i}`}
                className="absolute z-10 -translate-x-1/2 -translate-y-1/2 pointer-events-none"
                style={{ left: `${pos.x}%`, top: `${pos.y}%` }}
              >
                <div className={`flex items-center gap-1 px-1.5 py-0.5 rounded-full border shadow-xl ${
                  isPanic 
                    ? 'bg-red-600 border-white text-white animate-bounce'
                    : 'bg-slate-900/90 border-cyan-400/80 text-cyan-300'
                }`}>
                  <span className={`w-1.5 h-1.5 rounded-full ${officer.status === '10-8' ? 'bg-emerald-400' : 'bg-amber-400'}`} />
                  <span className="font-mono text-[8px] font-bold">{officer.callsign || "1-A"}</span>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Floating Tactical Call Inspector Card */}
      {focusedCall && (
        <div className="absolute bottom-3 left-3 right-3 z-30 bg-[#0d1322]/95 backdrop-blur-xl border border-cyan-500/40 rounded-2xl p-4 shadow-2xl animate-in fade-in slide-in-from-bottom-3 duration-200">
          <div className="flex items-start justify-between gap-3 mb-2">
            <div className="flex items-center gap-2">
              <span className="px-2 py-0.5 rounded-full text-[10px] font-mono font-bold bg-cyan-500/20 text-cyan-300 border border-cyan-500/40">
                {focusedCall.code}
              </span>
              <h4 className="text-sm font-black text-white">{focusedCall.title}</h4>
            </div>
            <button
              onClick={() => setFocusedCall(null)}
              className="p-1 rounded-lg hover:bg-slate-800 text-slate-400 hover:text-white"
            >
              <X className="w-4 h-4" />
            </button>
          </div>

          <div className="flex items-center gap-4 text-xs text-slate-300 mb-2">
            <span className="flex items-center gap-1 text-cyan-300 font-semibold">
              <MapPin className="w-3.5 h-3.5" /> {focusedCall.street}
            </span>
            <span className="flex items-center gap-1 text-slate-400 font-mono text-[11px]">
              <Clock className="w-3.5 h-3.5" /> {focusedCall.time}
            </span>
          </div>

          <p className="text-xs text-slate-300 bg-slate-950/60 p-2.5 rounded-xl border border-white/5 mb-3 line-clamp-2">
            {focusedCall.message || "Dispatch alert triggered."}
          </p>

          <div className="flex items-center justify-between gap-2 flex-wrap">
            <div className="flex items-center gap-1 text-xs text-slate-400">
              <Users className="w-3.5 h-3.5" />
              <span>Units:</span>
              {focusedCall.units && focusedCall.units.length > 0 ? (
                <div className="flex gap-1">
                  {focusedCall.units.map((u, i) => (
                    <span key={i} className="px-1.5 py-0.2 rounded bg-cyan-950 text-cyan-300 text-[10px] font-mono font-bold border border-cyan-500/30">
                      {u.callsign || u.name}
                    </span>
                  ))}
                </div>
              ) : (
                <span className="text-[10px] text-amber-400 italic">None attached</span>
              )}
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={() => onSetGpsWaypoint(focusedCall.coords)}
                className="px-3 py-1.5 rounded-xl bg-cyan-600 hover:bg-cyan-500 text-white text-xs font-bold flex items-center gap-1.5 shadow-md shadow-cyan-600/30 transition-colors"
              >
                <Navigation className="w-3.5 h-3.5" />
                Set In-Game GPS
              </button>

              <button
                onClick={() => onAttachUnit(focusedCall.id)}
                className="px-3 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold flex items-center gap-1.5 shadow-md shadow-emerald-600/30 transition-colors"
              >
                <UserCheck className="w-3.5 h-3.5" />
                Respond (Attach)
              </button>

              <button
                onClick={() => onResolveCall(focusedCall.id)}
                className="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-xs font-bold transition-colors"
              >
                Resolve
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
