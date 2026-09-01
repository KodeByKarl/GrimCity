import React, { useState } from "react";
import { 
  Search, 
  Car, 
  User, 
  AlertTriangle, 
  Plus, 
  Trash2, 
  Warehouse, 
  CheckCircle2, 
  Phone,
  ChevronRight
} from "lucide-react";
import { VehicleRecord } from "../types/mdt";

interface VehicleLookupProps {
  searchResults: VehicleRecord[];
  onSearch: (query: string) => void;
  onAddFlag: (plate: string, flagType: string, reason: string) => void;
  onRemoveFlag: (flagId: number, plate: string) => void;
  onOpenCitizen: (nameOrId: string) => void;
}

export default function VehicleLookup({
  searchResults,
  onSearch,
  onAddFlag,
  onRemoveFlag,
  onOpenCitizen
}: VehicleLookupProps) {
  const [query, setQuery] = useState("");
  const [selectedVehicle, setSelectedVehicle] = useState<VehicleRecord | null>(null);
  const [showAddFlagModal, setShowAddFlagModal] = useState(false);
  const [flagType, setFlagType] = useState("Stolen Vehicle");
  const [flagReason, setFlagReason] = useState("");

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (query.trim()) {
      onSearch(query.trim());
    }
  };

  const handleSelectVehicle = (veh: VehicleRecord) => {
    setSelectedVehicle(veh);
  };

  const handleAddFlagSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedVehicle || !flagReason.trim()) return;
    onAddFlag(selectedVehicle.plate, flagType, flagReason.trim());
    setFlagReason("");
    setShowAddFlagModal(false);
  };

  return (
    <div className="flex-1 flex flex-col p-4 overflow-hidden bg-[#0a0e19]">
      {/* Search Header Bar */}
      <div className="flex items-center justify-between gap-4 mb-3 pb-2.5 border-b border-slate-800">
        <form onSubmit={handleSearchSubmit} className="flex-1 relative">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search vehicle by License Plate or Model name..."
            className="w-full pl-10 pr-24 py-2 rounded-xl bg-slate-900 border border-slate-700 text-white placeholder-slate-500 text-xs focus:outline-none focus:border-cyan-500 shadow-inner"
          />
          <button
            type="submit"
            className="absolute right-1.5 top-1/2 -translate-y-1/2 px-3 py-1 rounded-lg bg-cyan-600 hover:bg-cyan-500 text-white text-xs font-bold transition-colors shadow-sm"
          >
            Search Plate
          </button>
        </form>
      </div>

      {/* Main Split Grid */}
      <div className="flex-1 grid grid-cols-12 gap-3 overflow-hidden">
        {/* Left Column: Vehicle List */}
        <div className="col-span-12 md:col-span-4 bg-[#0e1424] border border-slate-800 rounded-2xl p-3 flex flex-col overflow-hidden shadow-lg">
          <div className="flex items-center justify-between pb-2 border-b border-slate-800 mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-300">Vehicle Registry</span>
            <span className="text-[10px] font-mono text-cyan-400 font-bold">{searchResults.length} Records</span>
          </div>

          <div className="flex-1 overflow-y-auto space-y-1.5 pr-1 custom-scrollbar">
            {searchResults.length === 0 ? (
              <div className="h-full flex flex-col items-center justify-center text-center p-6 text-slate-500">
                <Car className="w-10 h-10 mb-2 stroke-1 opacity-30 text-slate-400" />
                <p className="text-xs font-semibold text-slate-400">No Vehicles Found</p>
                <p className="text-[11px]">Enter a license plate to search DMV.</p>
              </div>
            ) : (
              searchResults.map((veh) => (
                <div
                  key={veh.plate}
                  onClick={() => handleSelectVehicle(veh)}
                  className={`p-2.5 rounded-xl border transition-all cursor-pointer flex items-center justify-between ${
                    selectedVehicle?.plate === veh.plate
                      ? 'bg-[#152038] border-cyan-500 shadow-md ring-1 ring-cyan-500/40'
                      : 'bg-slate-900/80 border-slate-800 hover:border-slate-700'
                  }`}
                >
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-lg bg-slate-800 border border-slate-700 flex items-center justify-center text-cyan-400 shrink-0 font-bold text-xs">
                      <Car className="w-4 h-4" />
                    </div>
                    <div>
                      <div className="text-xs font-black text-white font-mono tracking-wider flex items-center gap-1.5">
                        {veh.plate}
                        {veh.flags && veh.flags.length > 0 && (
                          <span className="px-1.5 py-0.2 text-[8px] font-bold rounded bg-red-600 text-white animate-pulse">
                            FLAGGED
                          </span>
                        )}
                      </div>
                      <div className="text-[10px] text-slate-400">
                        {veh.model} • {veh.owner}
                      </div>
                    </div>
                  </div>
                  <ChevronRight className="w-3.5 h-3.5 text-slate-400" />
                </div>
              ))
            )}
          </div>
        </div>

        {/* Right Column: Selected Vehicle Details */}
        <div className="col-span-12 md:col-span-8 bg-[#0e1424] border border-slate-800 rounded-2xl p-4 flex flex-col overflow-y-auto custom-scrollbar shadow-lg">
          {!selectedVehicle ? (
            <div className="h-full flex flex-col items-center justify-center text-center p-8 text-slate-500">
              <Car className="w-14 h-14 mb-2 stroke-1 opacity-25 text-slate-400" />
              <h3 className="text-sm font-bold text-slate-300 mb-1">Select a Vehicle Record</h3>
              <p className="text-xs max-w-sm">Select a plate from search results to inspect registration, owner, impound status, and police flags.</p>
            </div>
          ) : (
            <div className="space-y-4">
              {/* Header Plate */}
              <div className="flex items-start justify-between gap-4 pb-3 border-b border-slate-800 flex-wrap">
                <div>
                  <div className="flex items-center gap-2.5">
                    <div className="px-3.5 py-1.5 rounded-xl bg-slate-900 border-2 border-cyan-500/60 text-lg font-mono font-black text-white tracking-widest shadow-md">
                      {selectedVehicle.plate}
                    </div>
                    {selectedVehicle.flags && selectedVehicle.flags.length > 0 && (
                      <span className="px-2.5 py-1 rounded text-[10px] font-bold bg-red-600 text-white shadow-md flex items-center gap-1">
                        <AlertTriangle className="w-3 h-3" /> POLICE FLAGGED
                      </span>
                    )}
                  </div>
                  <div className="text-xs font-semibold text-slate-300 mt-1.5">
                    Model: <span className="text-white">{selectedVehicle.model}</span> | Color: <span className="text-slate-300">{selectedVehicle.color}</span>
                  </div>
                </div>

                <button
                  onClick={() => setShowAddFlagModal(true)}
                  className="px-3.5 py-1.5 rounded-xl bg-red-600 hover:bg-red-500 text-white text-xs font-bold flex items-center gap-1.5 shadow-md shadow-red-600/30 transition-colors"
                >
                  <Plus className="w-3.5 h-3.5" />
                  Add Flag
                </button>
              </div>

              {/* Ownership & Garage */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div 
                  onClick={() => selectedVehicle.owner && onOpenCitizen(selectedVehicle.owner)}
                  className="p-3 rounded-xl bg-slate-900/80 border border-slate-800 hover:border-cyan-500 cursor-pointer transition-colors"
                >
                  <div className="flex items-center justify-between mb-0.5">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Registered Owner</span>
                    <User className="w-3.5 h-3.5 text-cyan-400" />
                  </div>
                  <div className="text-sm font-bold text-white">
                    {selectedVehicle.owner || "Unknown"}
                  </div>
                  <div className="text-[10px] text-slate-400 flex items-center gap-1 mt-0.5 font-mono">
                    <Phone className="w-3 h-3" /> Phone: {selectedVehicle.phone || "N/A"}
                  </div>
                </div>

                <div className="p-3 rounded-xl bg-slate-900/80 border border-slate-800">
                  <div className="flex items-center justify-between mb-0.5">
                    <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">Storage / Impound Status</span>
                    <Warehouse className="w-3.5 h-3.5 text-slate-400" />
                  </div>
                  <div className="text-sm font-bold text-white">
                    {selectedVehicle.stored ? (
                      <span className="text-emerald-400 flex items-center gap-1">
                        <CheckCircle2 className="w-3.5 h-3.5" /> Stored in Garage
                      </span>
                    ) : (
                      <span className="text-amber-400 flex items-center gap-1">
                        <Car className="w-3.5 h-3.5" /> Out in City
                      </span>
                    )}
                  </div>
                  <div className="text-[10px] text-slate-400 mt-0.5">Garage: {selectedVehicle.garage || "Public Garage"}</div>
                </div>
              </div>

              {/* Police Flags */}
              <div className="p-3 rounded-xl bg-slate-900/80 border border-slate-800">
                <span className="text-[11px] font-bold uppercase tracking-wider text-red-400 block mb-2 flex items-center gap-1">
                  <AlertTriangle className="w-3.5 h-3.5" /> Active Flags & Warnings ({selectedVehicle.flags?.length || 0})
                </span>

                <div className="space-y-1.5">
                  {selectedVehicle.flags && selectedVehicle.flags.length > 0 ? (
                    selectedVehicle.flags.map((flag) => (
                      <div key={flag.id} className="p-2.5 rounded-lg bg-red-950/40 border border-red-500/30 flex items-center justify-between text-xs">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="font-bold text-red-300 uppercase">{flag.flag_type}</span>
                            <span className="text-slate-400 font-mono text-[10px]">by {flag.author_name}</span>
                          </div>
                          <p className="text-slate-200 text-[11px] mt-0.5">{flag.reason}</p>
                        </div>
                        <button
                          onClick={() => onRemoveFlag(flag.id, selectedVehicle.plate)}
                          className="p-1 rounded bg-slate-800 hover:bg-red-600 text-slate-400 hover:text-white transition-colors"
                          title="Remove Flag"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>
                    ))
                  ) : (
                    <div className="text-xs text-slate-500 italic">No active police flags on this vehicle.</div>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Add Flag Modal */}
      {showAddFlagModal && selectedVehicle && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-6">
          <div className="bg-[#0e1424] border border-red-500/50 rounded-2xl p-5 max-w-md w-full shadow-2xl space-y-3">
            <div className="flex items-center justify-between border-b border-slate-800 pb-2.5">
              <h3 className="text-sm font-black text-white flex items-center gap-2">
                <AlertTriangle className="w-4 h-4 text-red-500" />
                Add Vehicle Flag: {selectedVehicle.plate}
              </h3>
              <button onClick={() => setShowAddFlagModal(false)} className="text-slate-400 hover:text-white text-xs font-bold">
                Cancel
              </button>
            </div>

            <div>
              <label className="block text-[11px] font-semibold text-slate-400 mb-1">Flag Type</label>
              <select
                value={flagType}
                onChange={(e) => setFlagType(e.target.value)}
                className="w-full p-2 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs"
              >
                <option value="Stolen Vehicle">Stolen Vehicle (10-99 Hot Plate)</option>
                <option value="Armed Felon Vehicle">Suspect in Armed Robbery</option>
                <option value="Suspended Registration">Expired / Suspended Registration</option>
                <option value="Impound Order">Impound Upon Sighting Order</option>
                <option value="Traffic Warning">Persistent Traffic Violator</option>
              </select>
            </div>

            <div>
              <label className="block text-[11px] font-semibold text-slate-400 mb-1">Reason / Notes</label>
              <textarea
                value={flagReason}
                onChange={(e) => setFlagReason(e.target.value)}
                placeholder="Reason for flagging this plate..."
                rows={3}
                className="w-full p-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs focus:outline-none focus:border-red-500"
              />
            </div>

            <div className="flex justify-end gap-2 pt-2 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setShowAddFlagModal(false)}
                className="px-3 py-1.5 rounded-lg bg-slate-800 text-slate-300 text-xs font-bold hover:bg-slate-700"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleAddFlagSubmit}
                disabled={!flagReason.trim()}
                className="px-4 py-1.5 rounded-lg bg-red-600 hover:bg-red-500 disabled:opacity-50 text-white text-xs font-bold shadow-md"
              >
                Apply Flag
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
