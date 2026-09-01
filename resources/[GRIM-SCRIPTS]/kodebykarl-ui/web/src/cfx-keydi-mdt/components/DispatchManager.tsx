import React, { useState } from "react";
import { 
  Radio, 
  MapPin, 
  Navigation, 
  CheckCircle2, 
  UserCheck, 
  Flame, 
  ShieldAlert, 
  Phone, 
  Clock, 
  Users, 
  Shield,
  ChevronRight,
  Crosshair,
  Search,
  AlertTriangle
} from "lucide-react";
import { DispatchCall, DutyOfficer, OfficerProfile } from "../types/mdt";
import InteractiveMap from "./InteractiveMap";

interface DispatchManagerProps {
  dispatchCalls: DispatchCall[];
  activeOfficers: DutyOfficer[];
  currentOfficer: OfficerProfile | null;
  onSetGpsWaypoint: (coords: { x: number; y: number; z?: number }) => void;
  onAttachUnit: (callId: number) => void;
  onResolveCall: (callId: number) => void;
  onTriggerPanic: () => void;
}

export default function DispatchManager({
  dispatchCalls,
  activeOfficers,
  currentOfficer,
  onSetGpsWaypoint,
  onAttachUnit,
  onResolveCall,
  onTriggerPanic
}: DispatchManagerProps) {
  const [selectedCallId, setSelectedCallId] = useState<number | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterPriority, setFilterPriority] = useState<string>("all");

  const activeCalls = dispatchCalls.filter(c => c.status === 'active');

  const filteredCalls = activeCalls.filter(call => {
    const matchesSearch = 
      call.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      call.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
      call.street.toLowerCase().includes(searchQuery.toLowerCase()) ||
      call.message.toLowerCase().includes(searchQuery.toLowerCase());
    
    const matchesPriority = filterPriority === "all" || call.priority === filterPriority;
    return matchesSearch && matchesPriority;
  });

  const getPriorityBadge = (priority: string) => {
    switch (priority) {
      case 'urgent': return 'bg-red-600/30 text-red-300 border-red-500/50 animate-pulse';
      case 'high': return 'bg-orange-600/30 text-orange-300 border-orange-500/50';
      case 'medium': return 'bg-amber-600/30 text-amber-300 border-amber-500/50';
      default: return 'bg-emerald-600/30 text-emerald-300 border-emerald-500/50';
    }
  };

  const getOfficerStatusColor = (status: string) => {
    switch (status) {
      case '10-8': return 'bg-emerald-500 text-emerald-950';
      case '10-6': return 'bg-amber-500 text-amber-950';
      case '10-97': return 'bg-cyan-400 text-cyan-950';
      case '10-99': return 'bg-red-500 text-white animate-pulse';
      default: return 'bg-slate-500 text-white';
    }
  };

  return (
    <div className="flex-1 flex flex-col p-4 overflow-hidden bg-[#0a0e19]">
      {/* Top CAD Sub-Header */}
      <div className="flex items-center justify-between gap-4 mb-3 pb-2.5 border-b border-slate-800">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-xl bg-cyan-600/20 border border-cyan-500/40 flex items-center justify-center text-cyan-400">
            <Radio className="w-4 h-4" />
          </div>
          <div>
            <h2 className="text-sm font-black text-white uppercase tracking-wider flex items-center gap-2">
              CAD Dispatch & Live Tactical Radar
            </h2>
            <div className="text-[11px] text-slate-400">
              Active 911 Calls Feed & Real-Time GPS Tracking of All Units
            </div>
          </div>
        </div>

        {/* Priority Filter & Search */}
        <div className="flex items-center gap-2">
          <div className="relative">
            <Search className="w-3.5 h-3.5 text-slate-400 absolute left-2.5 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search call code, street..."
              className="pl-8 pr-3 py-1.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs placeholder-slate-500 focus:outline-none focus:border-cyan-500 w-52"
            />
          </div>

          <div className="flex items-center p-0.5 rounded-xl bg-slate-900 border border-slate-700 text-[11px]">
            {["all", "urgent", "high", "medium"].map((p) => (
              <button
                key={p}
                onClick={() => setFilterPriority(p)}
                className={`px-2.5 py-1 rounded-lg font-bold uppercase transition-all ${
                  filterPriority === p
                    ? p === 'urgent' ? 'bg-red-600 text-white' : 'bg-cyan-600 text-white'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                {p}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Main Split Interface: Left Calls & Units / Right Interactive GTA 5 Map */}
      <div className="flex-1 grid grid-cols-12 gap-3 overflow-hidden">
        {/* Left Column: Active 911 Queue & Duty Officers */}
        <div className="col-span-12 lg:col-span-5 flex flex-col gap-3 overflow-hidden">
          {/* Active Calls List */}
          <div className="flex-1 bg-[#0e1424] border border-slate-800 rounded-2xl p-3 flex flex-col overflow-hidden shadow-lg">
            <div className="flex items-center justify-between pb-2 border-b border-slate-800 mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-300 flex items-center gap-1.5">
                <span className="w-2 h-2 rounded-full bg-cyan-400 animate-ping" />
                Active 911 Calls ({filteredCalls.length})
              </span>
              <span className="text-[10px] font-mono text-cyan-400 font-bold">CLICK TO LOCATE</span>
            </div>

            <div className="flex-1 overflow-y-auto space-y-2 pr-1 custom-scrollbar">
              {filteredCalls.length === 0 ? (
                <div className="h-full flex flex-col items-center justify-center text-center p-6 text-slate-500">
                  <CheckCircle2 className="w-10 h-10 mb-2 text-emerald-500 opacity-40" />
                  <p className="text-xs font-semibold text-slate-400">Dispatch Queue Clear</p>
                  <p className="text-[11px]">No active 911 calls matching filter.</p>
                </div>
              ) : (
                filteredCalls.map((call) => {
                  const isSelected = selectedCallId === call.id;
                  const isAttached = call.units?.some(u => u.name === currentOfficer?.name || u.callsign === currentOfficer?.callsign);
                  return (
                    <div
                      key={call.id}
                      onClick={() => setSelectedCallId(call.id)}
                      className={`p-3 rounded-xl border transition-all cursor-pointer ${
                        isSelected
                          ? 'bg-[#152038] border-cyan-500 shadow-md ring-1 ring-cyan-500/40'
                          : call.priority === 'urgent'
                            ? 'bg-red-950/30 border-red-500/40 hover:border-red-400'
                            : 'bg-slate-900/80 border-slate-800 hover:border-slate-700'
                      }`}
                    >
                      <div className="flex items-start justify-between gap-2 mb-1.5">
                        <div className="flex items-center gap-2">
                          <span className="font-mono font-bold text-cyan-400 text-xs">{call.code}</span>
                          <span className={`px-2 py-0.2 rounded text-[9px] font-bold uppercase border ${getPriorityBadge(call.priority)}`}>
                            {call.priority}
                          </span>
                        </div>
                        <span className="font-mono text-[10px] text-slate-400 flex items-center gap-1">
                          <Clock className="w-3 h-3" /> {call.time}
                        </span>
                      </div>

                      <h4 className="text-xs font-bold text-white mb-1">{call.title}</h4>

                      <div className="text-[11px] text-cyan-300 font-semibold flex items-center gap-1 mb-1.5">
                        <MapPin className="w-3.5 h-3.5 text-cyan-400 shrink-0" />
                        <span className="truncate">{call.street}</span>
                      </div>

                      <p className="text-[11px] text-slate-300 line-clamp-2 bg-slate-950/70 p-2 rounded-lg border border-slate-800 mb-2">
                        {call.message}
                      </p>

                      {/* Action Buttons */}
                      <div className="flex items-center justify-between gap-2 pt-2 border-t border-slate-800/80">
                        <div className="text-[10px] text-slate-400 flex items-center gap-1 truncate">
                          <Users className="w-3 h-3" />
                          <span>{call.units?.length || 0} units attached</span>
                        </div>

                        <div className="flex items-center gap-1.5">
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onSetGpsWaypoint(call.coords);
                            }}
                            className="px-2.5 py-1 rounded-lg bg-cyan-600 hover:bg-cyan-500 text-white text-[11px] font-bold flex items-center gap-1 transition-colors shadow-sm"
                          >
                            <Navigation className="w-3 h-3" />
                            GPS
                          </button>

                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onAttachUnit(call.id);
                            }}
                            className={`px-2.5 py-1 rounded-lg text-[11px] font-bold flex items-center gap-1 transition-colors ${
                              isAttached
                                ? 'bg-amber-600 text-white hover:bg-amber-700'
                                : 'bg-emerald-600 text-white hover:bg-emerald-500'
                            }`}
                          >
                            <UserCheck className="w-3 h-3" />
                            {isAttached ? "Detach" : "Attach"}
                          </button>

                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              onResolveCall(call.id);
                            }}
                            className="px-2 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-[11px] font-semibold transition-colors"
                          >
                            Resolve
                          </button>
                        </div>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>

          {/* Bottom Compact On-Duty Units List */}
          <div className="h-44 bg-[#0e1424] border border-slate-800 rounded-2xl p-3 flex flex-col overflow-hidden shadow-lg">
            <div className="flex items-center justify-between pb-2 border-b border-slate-800 mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-300 flex items-center gap-1.5">
                <Shield className="w-3.5 h-3.5 text-indigo-400" />
                Active Patrol Units ({activeOfficers.length || 1})
              </span>
              <span className="text-[10px] font-mono text-emerald-400">ONLINE</span>
            </div>

            <div className="flex-1 overflow-y-auto space-y-1.5 pr-1 custom-scrollbar">
              {activeOfficers.map((off, i) => (
                <div
                  key={i}
                  className="p-2 rounded-xl bg-slate-900/80 border border-slate-800 flex items-center justify-between text-xs"
                >
                  <div className="flex items-center gap-2.5">
                    <div className="w-7 h-7 rounded-lg bg-slate-800 border border-slate-700 flex items-center justify-center font-mono font-bold text-cyan-400 text-[11px]">
                      {off.callsign || "1-A"}
                    </div>
                    <div>
                      <div className="font-bold text-white text-xs">{off.name}</div>
                      <div className="text-[10px] text-slate-400 font-mono">
                        {off.department} • Radio: {off.radio || "100.1"}
                      </div>
                    </div>
                  </div>

                  <span className={`px-2 py-0.5 rounded text-[9px] font-mono font-bold ${getOfficerStatusColor(off.status)}`}>
                    {off.status}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right Column: Full Interactive GTA 5 Map */}
        <div className="col-span-12 lg:col-span-7 h-full rounded-2xl overflow-hidden shadow-xl border border-slate-800">
          <InteractiveMap
            dispatchCalls={dispatchCalls}
            activeOfficers={activeOfficers}
            currentOfficer={currentOfficer}
            onSetGpsWaypoint={onSetGpsWaypoint}
            onAttachUnit={onAttachUnit}
            onResolveCall={onResolveCall}
            selectedCallId={selectedCallId}
          />
        </div>
      </div>
    </div>
  );
}
