import React, { useState } from "react";
import { 
  Search, 
  User, 
  Car, 
  ShieldAlert, 
  FileText, 
  Award, 
  Phone, 
  Calendar, 
  MapPin, 
  Plus, 
  Trash2, 
  AlertCircle,
  ExternalLink,
  ChevronRight
} from "lucide-react";
import { CitizenProfile, Warrant, IncidentReport, PenalCodeItem } from "../types/mdt";

interface CitizenLookupProps {
  searchResults: CitizenProfile[];
  onSearch: (query: string) => void;
  onAddNote: (identifier: string, note: string, imageUrl?: string) => void;
  onCreateWarrant: (warrantData: any) => void;
  onOpenVehicle: (plate: string) => void;
  penalCodes: PenalCodeItem[];
}

export default function CitizenLookup({
  searchResults,
  onSearch,
  onAddNote,
  onCreateWarrant,
  onOpenVehicle,
  penalCodes
}: CitizenLookupProps) {
  const [query, setQuery] = useState("");
  const [selectedCitizen, setSelectedCitizen] = useState<CitizenProfile | null>(null);
  const [newNoteText, setNewNoteText] = useState("");
  const [newNoteImage, setNewNoteImage] = useState("");
  const [showWarrantModal, setShowWarrantModal] = useState(false);
  const [warrantReason, setWarrantReason] = useState("");
  const [selectedCharges, setSelectedCharges] = useState<PenalCodeItem[]>([]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (query.trim()) {
      onSearch(query.trim());
    }
  };

  const handleSelectCitizen = (citizen: CitizenProfile) => {
    setSelectedCitizen(citizen);
  };

  const handleAddNoteSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCitizen || !newNoteText.trim()) return;
    onAddNote(selectedCitizen.identifier, newNoteText.trim(), newNoteImage.trim());
    setNewNoteText("");
    setNewNoteImage("");
  };

  const handleCreateWarrantSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCitizen || !warrantReason.trim()) return;
    onCreateWarrant({
      suspectIdentifier: selectedCitizen.identifier,
      suspectName: `${selectedCitizen.firstname} ${selectedCitizen.lastname}`,
      charges: selectedCharges,
      reason: warrantReason.trim()
    });
    setWarrantReason("");
    setSelectedCharges([]);
    setShowWarrantModal(false);
  };

  const toggleChargeSelection = (charge: PenalCodeItem) => {
    if (selectedCharges.some(c => c.code === charge.code)) {
      setSelectedCharges(selectedCharges.filter(c => c.code !== charge.code));
    } else {
      setSelectedCharges([...selectedCharges, charge]);
    }
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
            placeholder="Search citizen by Name, DOB, Citizen ID, or Phone..."
            className="w-full pl-10 pr-24 py-2 rounded-xl bg-slate-900 border border-slate-700 text-white placeholder-slate-500 text-xs focus:outline-none focus:border-cyan-500 shadow-inner"
          />
          <button
            type="submit"
            className="absolute right-1.5 top-1/2 -translate-y-1/2 px-3 py-1 rounded-lg bg-cyan-600 hover:bg-cyan-500 text-white text-xs font-bold transition-colors shadow-sm"
          >
            Search
          </button>
        </form>
      </div>

      {/* Main Split Grid */}
      <div className="flex-1 grid grid-cols-12 gap-3 overflow-hidden">
        {/* Left Column: Search Results List */}
        <div className="col-span-12 md:col-span-4 bg-[#0e1424] border border-slate-800 rounded-2xl p-3 flex flex-col overflow-hidden shadow-lg">
          <div className="flex items-center justify-between pb-2 border-b border-slate-800 mb-2">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-300">Search Results</span>
            <span className="text-[10px] font-mono text-cyan-400 font-bold">{searchResults.length} Profiles</span>
          </div>

          <div className="flex-1 overflow-y-auto space-y-1.5 pr-1 custom-scrollbar">
            {searchResults.length === 0 ? (
              <div className="h-full flex flex-col items-center justify-center text-center p-6 text-slate-500">
                <User className="w-10 h-10 mb-2 stroke-1 opacity-30 text-slate-400" />
                <p className="text-xs font-semibold text-slate-400">No Citizens Found</p>
                <p className="text-[11px]">Enter a name or identifier to search database.</p>
              </div>
            ) : (
              searchResults.map((citizen) => (
                <div
                  key={citizen.identifier}
                  onClick={() => handleSelectCitizen(citizen)}
                  className={`p-2.5 rounded-xl border transition-all cursor-pointer flex items-center justify-between ${
                    selectedCitizen?.identifier === citizen.identifier
                      ? 'bg-[#152038] border-cyan-500 shadow-md ring-1 ring-cyan-500/40'
                      : 'bg-slate-900/80 border-slate-800 hover:border-slate-700'
                  }`}
                >
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-lg bg-slate-800 border border-slate-700 flex items-center justify-center text-cyan-400 font-bold text-xs shrink-0">
                      {citizen.firstname.charAt(0)}{citizen.lastname.charAt(0)}
                    </div>
                    <div>
                      <div className="text-xs font-bold text-white flex items-center gap-1.5">
                        {citizen.firstname} {citizen.lastname}
                        {citizen.warrants && citizen.warrants.length > 0 && (
                          <span className="px-1.5 py-0.2 text-[8px] font-bold rounded bg-red-600 text-white animate-pulse">
                            WARRANT
                          </span>
                        )}
                      </div>
                      <div className="text-[10px] text-slate-400 font-mono">
                        DOB: {citizen.dateofbirth} • {citizen.job}
                      </div>
                    </div>
                  </div>
                  <ChevronRight className="w-3.5 h-3.5 text-slate-400" />
                </div>
              ))
            )}
          </div>
        </div>

        {/* Right Column: Citizen Profile Dossier */}
        <div className="col-span-12 md:col-span-8 bg-[#0e1424] border border-slate-800 rounded-2xl p-4 flex flex-col overflow-y-auto custom-scrollbar shadow-lg">
          {!selectedCitizen ? (
            <div className="h-full flex flex-col items-center justify-center text-center p-8 text-slate-500">
              <User className="w-14 h-14 mb-2 stroke-1 opacity-25 text-slate-400" />
              <h3 className="text-sm font-bold text-slate-300 mb-1">Select a Citizen Profile</h3>
              <p className="text-xs max-w-sm">Select a person from search results to view criminal history, licenses, vehicles, warrants, and notes.</p>
            </div>
          ) : (
            <div className="space-y-4">
              {/* Header Bio */}
              <div className="flex items-start justify-between gap-4 pb-3 border-b border-slate-800 flex-wrap">
                <div className="flex items-center gap-3.5">
                  <div className="w-14 h-14 rounded-xl bg-slate-800 border border-slate-700 overflow-hidden flex items-center justify-center text-slate-300 font-black text-lg shrink-0 shadow-md">
                    {selectedCitizen.mugshotUrl ? (
                      <img src={selectedCitizen.mugshotUrl} alt="Mugshot" className="w-full h-full object-cover" />
                    ) : (
                      <span>{selectedCitizen.firstname.charAt(0)}{selectedCitizen.lastname.charAt(0)}</span>
                    )}
                  </div>
                  <div>
                    <div className="flex items-center gap-2">
                      <h2 className="text-lg font-black text-white">
                        {selectedCitizen.firstname} {selectedCitizen.lastname}
                      </h2>
                      {selectedCitizen.warrants && selectedCitizen.warrants.length > 0 && (
                        <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-red-600 text-white shadow-md flex items-center gap-1">
                          <ShieldAlert className="w-3 h-3" /> WANTED
                        </span>
                      )}
                    </div>
                    <div className="text-[11px] font-mono text-cyan-400 mt-0.5">
                      Citizen ID: {selectedCitizen.identifier}
                    </div>
                    <div className="flex items-center gap-3 text-xs text-slate-300 mt-1">
                      <span className="flex items-center gap-1"><Calendar className="w-3 h-3 text-slate-400" /> {selectedCitizen.dateofbirth}</span>
                      <span className="flex items-center gap-1"><Phone className="w-3 h-3 text-slate-400" /> {selectedCitizen.phone}</span>
                      <span>Gender: {selectedCitizen.gender}</span>
                    </div>
                  </div>
                </div>

                <button
                  onClick={() => setShowWarrantModal(true)}
                  className="px-3.5 py-1.5 rounded-xl bg-red-600 hover:bg-red-500 text-white text-xs font-bold flex items-center gap-1.5 shadow-md shadow-red-600/30 transition-colors"
                >
                  <ShieldAlert className="w-3.5 h-3.5" />
                  Issue Warrant
                </button>
              </div>

              {/* Licenses Section */}
              <div className="p-3 rounded-xl bg-slate-900/80 border border-slate-800">
                <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400 block mb-1.5">
                  Licenses on Record
                </span>
                <div className="flex flex-wrap gap-1.5">
                  {selectedCitizen.licenses && selectedCitizen.licenses.length > 0 ? (
                    selectedCitizen.licenses.map((lic, i) => (
                      <span key={i} className="px-2.5 py-1 rounded-lg text-xs font-semibold bg-emerald-950/80 border border-emerald-500/40 text-emerald-300 flex items-center gap-1">
                        <Award className="w-3 h-3" /> {lic.toUpperCase()}
                      </span>
                    ))
                  ) : (
                    <span className="text-xs text-slate-500 italic">No registered licenses</span>
                  )}
                </div>
              </div>

              {/* Registered Vehicles */}
              <div className="p-3 rounded-xl bg-slate-900/80 border border-slate-800">
                <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400 block mb-1.5">
                  Registered Vehicles ({selectedCitizen.vehicles?.length || 0})
                </span>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                  {selectedCitizen.vehicles && selectedCitizen.vehicles.length > 0 ? (
                    selectedCitizen.vehicles.map((veh, i) => (
                      <div 
                        key={i} 
                        onClick={() => onOpenVehicle(veh.plate)}
                        className="p-2.5 rounded-xl bg-slate-800/80 border border-slate-700 hover:border-cyan-500 flex items-center justify-between cursor-pointer transition-colors"
                      >
                        <div className="flex items-center gap-2">
                          <Car className="w-3.5 h-3.5 text-cyan-400" />
                          <div>
                            <div className="font-mono text-xs font-bold text-white">{veh.plate}</div>
                            <div className="text-[10px] text-slate-400">{veh.model}</div>
                          </div>
                        </div>
                        <ExternalLink className="w-3 h-3 text-slate-400" />
                      </div>
                    ))
                  ) : (
                    <div className="text-xs text-slate-500 italic col-span-2">No vehicles registered.</div>
                  )}
                </div>
              </div>

              {/* Active Warrants */}
              {selectedCitizen.warrants && selectedCitizen.warrants.length > 0 && (
                <div className="p-3 rounded-xl bg-red-950/40 border border-red-500/30">
                  <span className="text-[11px] font-bold uppercase tracking-wider text-red-400 block mb-1.5 flex items-center gap-1">
                    <ShieldAlert className="w-3.5 h-3.5" /> Active Arrest Warrants
                  </span>
                  <div className="space-y-1.5">
                    {selectedCitizen.warrants.map((w) => (
                      <div key={w.id} className="p-2.5 rounded-lg bg-red-900/40 border border-red-500/20 text-xs">
                        <div className="flex items-center justify-between mb-0.5">
                          <span className="font-bold text-red-200">Warrant #{w.id}</span>
                          <span className="text-[10px] text-slate-400 font-mono">By: {w.issuing_officer}</span>
                        </div>
                        <p className="text-slate-200 text-[11px]">{w.reason}</p>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Officer Notes */}
              <div className="p-3 rounded-xl bg-slate-900/80 border border-slate-800">
                <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400 block mb-2">
                  Officer Notes & Flags
                </span>

                <form onSubmit={handleAddNoteSubmit} className="mb-3 space-y-2">
                  <textarea
                    value={newNoteText}
                    onChange={(e) => setNewNoteText(e.target.value)}
                    placeholder="Log officer observation, aliases, gang affiliation, or warnings..."
                    rows={2}
                    className="w-full p-2.5 rounded-xl bg-slate-950 border border-slate-700 text-white placeholder-slate-500 text-xs focus:outline-none focus:border-cyan-500"
                  />
                  <div className="flex justify-end">
                    <button
                      type="submit"
                      disabled={!newNoteText.trim()}
                      className="px-3 py-1 rounded-lg bg-cyan-600 hover:bg-cyan-500 disabled:opacity-50 text-white text-xs font-bold flex items-center gap-1 transition-colors"
                    >
                      <Plus className="w-3 h-3" /> Add Note
                    </button>
                  </div>
                </form>

                <div className="space-y-1.5">
                  {selectedCitizen.notes && selectedCitizen.notes.length > 0 ? (
                    selectedCitizen.notes.map((note) => (
                      <div key={note.id} className="p-2.5 rounded-lg bg-slate-800/60 border border-slate-700 text-xs">
                        <div className="flex items-center justify-between text-[10px] text-slate-400 mb-0.5">
                          <span className="font-semibold text-cyan-300">Officer {note.author_name}</span>
                          <span className="font-mono">{note.created_at || "Recent"}</span>
                        </div>
                        <p className="text-slate-200 text-[11px]">{note.note}</p>
                      </div>
                    ))
                  ) : (
                    <div className="text-xs text-slate-500 italic">No notes logged.</div>
                  )}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Issue Warrant Modal */}
      {showWarrantModal && selectedCitizen && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-md flex items-center justify-center p-6">
          <div className="bg-[#0e1424] border border-red-500/50 rounded-2xl p-5 max-w-lg w-full shadow-2xl space-y-3">
            <div className="flex items-center justify-between border-b border-slate-800 pb-2.5">
              <h3 className="text-sm font-black text-white flex items-center gap-2">
                <ShieldAlert className="w-4 h-4 text-red-500" />
                Issue Arrest Warrant: {selectedCitizen.firstname} {selectedCitizen.lastname}
              </h3>
              <button onClick={() => setShowWarrantModal(false)} className="text-slate-400 hover:text-white text-xs font-bold">
                Cancel
              </button>
            </div>

            <div>
              <label className="block text-[11px] font-semibold text-slate-400 mb-1">Probable Cause & Justification</label>
              <textarea
                value={warrantReason}
                onChange={(e) => setWarrantReason(e.target.value)}
                placeholder="State the justification for this warrant..."
                rows={3}
                className="w-full p-2.5 rounded-xl bg-slate-900 border border-slate-700 text-white text-xs focus:outline-none focus:border-red-500"
              />
            </div>

            <div>
              <label className="block text-[11px] font-semibold text-slate-400 mb-1">Attached Charges</label>
              <div className="max-h-36 overflow-y-auto space-y-1 p-2 rounded-xl bg-slate-900 border border-slate-800 custom-scrollbar">
                {penalCodes.map((pc) => {
                  const isSelected = selectedCharges.some(c => c.code === pc.code);
                  return (
                    <div
                      key={pc.code}
                      onClick={() => toggleChargeSelection(pc)}
                      className={`p-1.5 rounded-lg text-xs cursor-pointer flex items-center justify-between ${
                        isSelected ? 'bg-red-600/30 border border-red-500/50 text-red-200' : 'bg-slate-800 text-slate-300 hover:bg-slate-700'
                      }`}
                    >
                      <span className="font-semibold">{pc.code} - {pc.title}</span>
                      <span className="font-mono text-[10px] opacity-75">${pc.fine} | {pc.jail_time}m</span>
                    </div>
                  );
                })}
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-2 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setShowWarrantModal(false)}
                className="px-3 py-1.5 rounded-lg bg-slate-800 text-slate-300 text-xs font-bold hover:bg-slate-700"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleCreateWarrantSubmit}
                disabled={!warrantReason.trim()}
                className="px-4 py-1.5 rounded-lg bg-red-600 hover:bg-red-500 disabled:opacity-50 text-white text-xs font-bold shadow-md"
              >
                Confirm Warrant
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
