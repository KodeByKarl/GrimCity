import React, { useState } from "react";
import { 
  ShieldAlert, 
  AlertTriangle, 
  Plus, 
  Search, 
  CheckCircle2, 
  Trash2, 
  User, 
  Car, 
  MapPin, 
  Clock,
  Sparkles,
  Flame
} from "lucide-react";
import { Warrant, Bolo, PenalCodeItem } from "../types/mdt";

interface WarrantsBolosProps {
  warrants: Warrant[];
  bolos: Bolo[];
  onDeleteWarrant: (warrantId: number) => void;
  onCreateBolo: (boloData: any) => void;
  onDeleteBolo: (boloId: number) => void;
  onOpenCitizen: (nameOrId: string) => void;
  onOpenVehicle: (plate: string) => void;
}

export default function WarrantsBolos({
  warrants,
  bolos,
  onDeleteWarrant,
  onCreateBolo,
  onDeleteBolo,
  onOpenCitizen,
  onOpenVehicle
}: WarrantsBolosProps) {
  const [activeTab, setActiveTab] = useState<"warrants" | "bolos">("warrants");
  const [searchQuery, setSearchQuery] = useState("");
  const [showCreateBoloModal, setShowCreateBoloModal] = useState(false);

  // BOLO Form state
  const [boloType, setBoloType] = useState<"person" | "vehicle" | "area">("person");
  const [boloTitle, setBoloTitle] = useState("");
  const [boloTarget, setBoloTarget] = useState("");
  const [boloDescription, setBoloDescription] = useState("");
  const [boloPriority, setBoloPriority] = useState<"low" | "medium" | "high" | "urgent">("medium");
  const [boloImageUrl, setBoloImageUrl] = useState("");

  const filteredWarrants = warrants.filter(w => 
    w.status === 'Active' &&
    (w.suspect_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
     w.reason.toLowerCase().includes(searchQuery.toLowerCase()) ||
     w.issuing_officer.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  const filteredBolos = bolos.filter(b =>
    b.status === 'active' &&
    (b.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
     b.target.toLowerCase().includes(searchQuery.toLowerCase()) ||
     b.description.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  const handleCreateBoloSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!boloTitle.trim() || !boloTarget.trim()) return;

    onCreateBolo({
      type: boloType,
      title: boloTitle.trim(),
      target: boloTarget.trim(),
      description: boloDescription.trim(),
      priority: boloPriority,
      imageUrl: boloImageUrl.trim()
    });

    setBoloTitle("");
    setBoloTarget("");
    setBoloDescription("");
    setBoloImageUrl("");
    setShowCreateBoloModal(false);
  };

  return (
    <div className="flex-1 flex flex-col p-6 overflow-hidden">
      {/* Header & Tabs */}
      <div className="flex items-center justify-between gap-4 mb-6 flex-wrap">
        <div className="flex items-center gap-3">
          <div className="p-1 rounded-2xl bg-slate-900/80 border border-white/10 flex items-center gap-1">
            <button
              onClick={() => setActiveTab("warrants")}
              className={`px-5 py-2 rounded-xl text-xs font-bold transition-all duration-200 flex items-center gap-2 ${
                activeTab === "warrants"
                  ? 'bg-red-600 text-white shadow-lg shadow-red-600/30'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              <ShieldAlert className="w-4 h-4" />
              Arrest Warrants ({warrants.filter(w => w.status === 'Active').length})
            </button>
            <button
              onClick={() => setActiveTab("bolos")}
              className={`px-5 py-2 rounded-xl text-xs font-bold transition-all duration-200 flex items-center gap-2 ${
                activeTab === "bolos"
                  ? 'bg-amber-600 text-white shadow-lg shadow-amber-600/30'
                  : 'text-slate-400 hover:text-white'
              }`}
            >
              <AlertTriangle className="w-4 h-4" />
              Active BOLOs ({bolos.filter(b => b.status === 'active').length})
            </button>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <div className="relative">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Filter by name, plate, or reason..."
              className="pl-9 pr-4 py-2 rounded-xl bg-slate-900/80 border border-white/10 text-white placeholder-slate-500 text-xs focus:outline-none focus:border-cyan-500/50 w-64"
            />
          </div>

          {activeTab === "bolos" && (
            <button
              onClick={() => setShowCreateBoloModal(true)}
              className="px-4 py-2 rounded-xl bg-amber-600 hover:bg-amber-500 text-white text-xs font-bold flex items-center gap-1.5 shadow-lg shadow-amber-600/20 transition-colors"
            >
              <Plus className="w-4 h-4" />
              Issue New BOLO
            </button>
          )}
        </div>
      </div>

      {/* Main Content Grid */}
      <div className="flex-1 overflow-y-auto pr-1 custom-scrollbar">
        {activeTab === "warrants" ? (
          /* Warrants Grid */
          filteredWarrants.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-center p-12 text-slate-500">
              <ShieldAlert className="w-16 h-16 mb-3 stroke-1 opacity-30 text-red-500" />
              <h3 className="text-base font-bold text-slate-300 mb-1">No Active Warrants</h3>
              <p className="text-xs max-w-sm">All judicial warrants have been served or no warrants match your filter query.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filteredWarrants.map((warrant) => (
                <div
                  key={warrant.id}
                  className="bg-slate-900/70 backdrop-blur-xl border border-red-500/30 rounded-3xl p-5 shadow-xl flex flex-col justify-between hover:border-red-500/60 transition-all duration-200"
                >
                  <div>
                    <div className="flex items-start justify-between gap-2 mb-3">
                      <div>
                        <span className="text-[10px] font-mono font-bold uppercase tracking-wider text-red-400">
                          Warrant #{warrant.id}
                        </span>
                        <h4 
                          onClick={() => onOpenCitizen(warrant.suspect_name)}
                          className="text-base font-black text-white hover:text-cyan-300 cursor-pointer transition-colors"
                        >
                          {warrant.suspect_name}
                        </h4>
                      </div>
                      <span className="px-2.5 py-1 rounded-full text-[10px] font-bold uppercase bg-red-600/20 text-red-300 border border-red-500/40 animate-pulse">
                        WANTED
                      </span>
                    </div>

                    <p className="text-xs text-slate-300 mb-4 bg-slate-950/40 p-3 rounded-2xl border border-white/5 line-clamp-3">
                      {warrant.reason}
                    </p>

                    {/* Attached Charges */}
                    {warrant.charges && warrant.charges.length > 0 && (
                      <div className="mb-4">
                        <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400 block mb-1.5">
                          Attached Offenses:
                        </span>
                        <div className="flex flex-wrap gap-1.5">
                          {warrant.charges.slice(0, 3).map((c: any, i) => (
                            <span key={i} className="px-2 py-0.5 rounded-lg bg-red-950/60 border border-red-500/30 text-[10px] font-semibold text-red-200">
                              {typeof c === 'string' ? c : `${c.code} - ${c.title}`}
                            </span>
                          ))}
                          {warrant.charges.length > 3 && (
                            <span className="text-[10px] text-slate-400 self-center">
                              +{warrant.charges.length - 3} more
                            </span>
                          )}
                        </div>
                      </div>
                    )}
                  </div>

                  <div className="pt-3 border-t border-white/10 flex items-center justify-between text-xs">
                    <div className="text-[11px] text-slate-400">
                      <div>Issued by: <strong className="text-slate-200">{warrant.issuing_officer}</strong></div>
                      <div className="font-mono text-[10px] text-slate-500">{warrant.created_at || "Active"}</div>
                    </div>
                    <button
                      onClick={() => onDeleteWarrant(warrant.id)}
                      className="px-3 py-1.5 rounded-xl bg-emerald-600/20 border border-emerald-500/40 hover:bg-emerald-600 hover:text-white text-emerald-300 text-xs font-bold flex items-center gap-1.5 transition-all"
                    >
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      Mark Served
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )
        ) : (
          /* BOLOs Grid */
          filteredBolos.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-center p-12 text-slate-500">
              <AlertTriangle className="w-16 h-16 mb-3 stroke-1 opacity-30 text-amber-500" />
              <h3 className="text-base font-bold text-slate-300 mb-1">No Active BOLOs</h3>
              <p className="text-xs max-w-sm">There are currently no active Be On the Lookout alerts broadcasted to units.</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filteredBolos.map((bolo) => {
                const isUrgent = bolo.priority === 'urgent' || bolo.priority === 'high';
                return (
                  <div
                    key={bolo.id}
                    className={`bg-slate-900/70 backdrop-blur-xl border rounded-3xl p-5 shadow-xl flex flex-col justify-between transition-all duration-200 ${
                      isUrgent ? 'border-red-500/40 hover:border-red-500/70 shadow-red-500/10' : 'border-amber-500/30 hover:border-amber-500/60'
                    }`}
                  >
                    <div>
                      <div className="flex items-start justify-between gap-2 mb-3">
                        <div className="flex items-center gap-2">
                          <div className={`w-8 h-8 rounded-xl flex items-center justify-center text-white ${
                            bolo.type === 'person' ? 'bg-blue-600' : bolo.type === 'vehicle' ? 'bg-emerald-600' : 'bg-purple-600'
                          }`}>
                            {bolo.type === 'person' && <User className="w-4 h-4" />}
                            {bolo.type === 'vehicle' && <Car className="w-4 h-4" />}
                            {bolo.type === 'area' && <MapPin className="w-4 h-4" />}
                          </div>
                          <div>
                            <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                              BOLO #{bolo.id} • {bolo.type}
                            </span>
                            <h4 className="text-sm font-black text-white">{bolo.title}</h4>
                          </div>
                        </div>

                        <span className={`px-2 py-0.5 rounded-full text-[9px] font-bold uppercase border ${
                          isUrgent ? 'bg-red-600/20 text-red-300 border-red-500/40 animate-pulse' : 'bg-amber-600/20 text-amber-300 border-amber-500/40'
                        }`}>
                          {bolo.priority}
                        </span>
                      </div>

                      {/* Target Pill */}
                      <div 
                        onClick={() => {
                          if (bolo.type === 'vehicle') onOpenVehicle(bolo.target);
                          else if (bolo.type === 'person') onOpenCitizen(bolo.target);
                        }}
                        className="px-3 py-1.5 rounded-xl bg-slate-800/80 border border-white/10 mb-3 text-xs font-mono font-bold text-cyan-300 cursor-pointer hover:border-cyan-500/40 transition-colors flex items-center justify-between"
                      >
                        <span>Target: {bolo.target}</span>
                        <span className="text-[10px] text-slate-400 font-sans">Inspect</span>
                      </div>

                      <p className="text-xs text-slate-300 mb-4 bg-slate-950/40 p-3 rounded-2xl border border-white/5">
                        {bolo.description}
                      </p>

                      {bolo.image_url && (
                        <div className="mb-4 rounded-2xl overflow-hidden border border-white/10 h-32 bg-slate-950">
                          <img src={bolo.image_url} alt="BOLO Evidence" className="w-full h-full object-cover" />
                        </div>
                      )}
                    </div>

                    <div className="pt-3 border-t border-white/10 flex items-center justify-between text-xs">
                      <div className="text-[11px] text-slate-400">
                        <div>Author: <strong className="text-slate-200">{bolo.author_name}</strong></div>
                        <div className="font-mono text-[10px] text-slate-500">{bolo.created_at || "Recent"}</div>
                      </div>
                      <button
                        onClick={() => onDeleteBolo(bolo.id)}
                        className="px-3 py-1.5 rounded-xl bg-slate-800 hover:bg-red-600 text-slate-300 hover:text-white text-xs font-bold flex items-center gap-1.5 transition-colors"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                        Clear BOLO
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )
        )}
      </div>

      {/* Create BOLO Modal */}
      {showCreateBoloModal && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-md flex items-center justify-center p-6">
          <div className="bg-slate-900 border border-amber-500/40 rounded-3xl p-6 max-w-lg w-full shadow-2xl space-y-4">
            <div className="flex items-center justify-between border-b border-white/10 pb-3">
              <h3 className="text-lg font-black text-white flex items-center gap-2">
                <AlertTriangle className="w-5 h-5 text-amber-500" />
                Broadcast New BOLO (APB)
              </h3>
              <button onClick={() => setShowCreateBoloModal(false)} className="text-slate-400 hover:text-white text-xs font-bold">
                Cancel
              </button>
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-slate-400 mb-1">BOLO Category</label>
                <select
                  value={boloType}
                  onChange={(e) => setBoloType(e.target.value as any)}
                  className="w-full p-2.5 rounded-xl bg-slate-800 border border-white/10 text-white text-xs"
                >
                  <option value="person">Person / Suspect BOLO</option>
                  <option value="vehicle">Vehicle / License Plate BOLO</option>
                  <option value="area">Area / Zone Lockdown BOLO</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-400 mb-1">Broadcast Priority</label>
                <select
                  value={boloPriority}
                  onChange={(e) => setBoloPriority(e.target.value as any)}
                  className="w-full p-2.5 rounded-xl bg-slate-800 border border-white/10 text-white text-xs"
                >
                  <option value="low">Low (Standard Advisory)</option>
                  <option value="medium">Medium (Patrol Alert)</option>
                  <option value="high">High (Armed & Dangerous)</option>
                  <option value="urgent">Urgent (Immediate Pursuit)</option>
                </select>
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-400 mb-1">BOLO Title</label>
              <input
                type="text"
                value={boloTitle}
                onChange={(e) => setBoloTitle(e.target.value)}
                placeholder="e.g. Armed Robbery Suspect Fleeing in Black Dominator"
                className="w-full p-2.5 rounded-xl bg-slate-800 border border-white/10 text-white text-xs"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-400 mb-1">Target (Name, License Plate, or Location)</label>
              <input
                type="text"
                value={boloTarget}
                onChange={(e) => setBoloTarget(e.target.value)}
                placeholder="e.g. John Doe, 44ABC123, or Legion Square"
                className="w-full p-2.5 rounded-xl bg-slate-800 border border-white/10 text-white text-xs font-mono"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-400 mb-1">Description & Officer Instructions</label>
              <textarea
                value={boloDescription}
                onChange={(e) => setBoloDescription(e.target.value)}
                placeholder="Describe last seen direction, weapon involved, suspect clothing, or backup instructions..."
                rows={3}
                className="w-full p-2.5 rounded-xl bg-slate-800 border border-white/10 text-white text-xs"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-400 mb-1">Evidence Photo / Mugshot URL (Optional)</label>
              <input
                type="text"
                value={boloImageUrl}
                onChange={(e) => setBoloImageUrl(e.target.value)}
                placeholder="https://..."
                className="w-full p-2.5 rounded-xl bg-slate-800 border border-white/10 text-white text-xs font-mono"
              />
            </div>

            <div className="flex justify-end gap-2 pt-3 border-t border-white/10">
              <button
                type="button"
                onClick={() => setShowCreateBoloModal(false)}
                className="px-4 py-2 rounded-xl bg-slate-800 text-slate-300 text-xs font-bold hover:bg-slate-700"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleCreateBoloSubmit}
                disabled={!boloTitle.trim() || !boloTarget.trim()}
                className="px-5 py-2 rounded-xl bg-amber-600 hover:bg-amber-500 disabled:opacity-50 text-white text-xs font-bold transition-colors shadow-lg shadow-amber-600/30"
              >
                Broadcast to All Units
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
