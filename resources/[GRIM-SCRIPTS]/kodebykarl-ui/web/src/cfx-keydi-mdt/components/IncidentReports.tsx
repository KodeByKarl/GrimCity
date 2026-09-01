import React, { useState } from "react";
import { 
  FileText, 
  Plus, 
  Search, 
  Trash2, 
  Save, 
  User, 
  Users, 
  Scale, 
  Camera, 
  MapPin, 
  DollarSign, 
  Clock, 
  ShieldAlert,
  ChevronRight,
  Sparkles
} from "lucide-react";
import { IncidentReport, PenalCodeItem, OfficerProfile } from "../types/mdt";

interface IncidentReportsProps {
  incidents: IncidentReport[];
  penalCodes: PenalCodeItem[];
  currentOfficer: OfficerProfile | null;
  onSaveIncident: (incidentData: IncidentReport) => void;
  onDeleteIncident: (incidentId: number) => void;
  onOpenCitizen: (nameOrId: string) => void;
}

export default function IncidentReports({
  incidents,
  penalCodes,
  currentOfficer,
  onSaveIncident,
  onDeleteIncident,
  onOpenCitizen
}: IncidentReportsProps) {
  const [selectedIncident, setSelectedIncident] = useState<IncidentReport | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

  // Editor Form State
  const [title, setTitle] = useState("");
  const [location, setLocation] = useState("");
  const [description, setDescription] = useState("");
  const [status, setStatus] = useState<'Draft' | 'Open' | 'Under Investigation' | 'Closed'>("Closed");
  const [suspects, setSuspects] = useState<{ name: string; identifier?: string; dob?: string }[]>([]);
  const [officers, setOfficers] = useState<{ name: string; callsign?: string }[]>([]);
  const [charges, setCharges] = useState<PenalCodeItem[]>([]);
  const [evidence, setEvidence] = useState<{ type: string; description: string; imageUrl?: string }[]>([]);

  // Charge Selector State
  const [showChargePicker, setShowChargePicker] = useState(false);
  const [chargeSearch, setChargeSearch] = useState("");

  // Quick Suspect Input
  const [suspectInput, setSuspectInput] = useState("");
  const [officerInput, setOfficerInput] = useState("");
  const [evidenceDesc, setEvidenceDesc] = useState("");
  const [evidenceType, setEvidenceType] = useState("Firearm / Weapon");
  const [evidenceImg, setEvidenceImg] = useState("");

  // Total Fine and Total Jail Time Auto-Sum
  const totalFine = charges.reduce((sum, c) => sum + (c.fine || 0), 0);
  const totalJail = charges.reduce((sum, c) => sum + (c.jail_time || 0), 0);

  const startNewReport = () => {
    setSelectedIncident(null);
    setTitle("");
    setLocation("Los Santos");
    setDescription("");
    setStatus("Closed");
    setSuspects([]);
    setOfficers(currentOfficer ? [{ name: currentOfficer.name, callsign: currentOfficer.callsign }] : []);
    setCharges([]);
    setEvidence([]);
    setIsEditing(true);
  };

  const loadIncidentForView = (inc: IncidentReport) => {
    setSelectedIncident(inc);
    setTitle(inc.title);
    setLocation(inc.location || "Los Santos");
    setDescription(inc.description || "");
    setStatus(inc.status || "Closed");
    setSuspects(inc.suspects || []);
    setOfficers(inc.officers || []);
    setCharges(inc.charges || []);
    setEvidence(inc.evidence || []);
    setIsEditing(false);
  };

  const loadIncidentForEdit = (inc: IncidentReport) => {
    loadIncidentForView(inc);
    setIsEditing(true);
  };

  const handleAddSuspect = () => {
    if (!suspectInput.trim()) return;
    setSuspects([...suspects, { name: suspectInput.trim() }]);
    setSuspectInput("");
  };

  const handleRemoveSuspect = (index: number) => {
    setSuspects(suspects.filter((_, i) => i !== index));
  };

  const handleAddOfficer = () => {
    if (!officerInput.trim()) return;
    setOfficers([...officers, { name: officerInput.trim() }]);
    setOfficerInput("");
  };

  const handleRemoveOfficer = (index: number) => {
    setOfficers(officers.filter((_, i) => i !== index));
  };

  const handleAddEvidence = () => {
    if (!evidenceDesc.trim()) return;
    setEvidence([...evidence, {
      type: evidenceType,
      description: evidenceDesc.trim(),
      imageUrl: evidenceImg.trim() || undefined
    }]);
    setEvidenceDesc("");
    setEvidenceImg("");
  };

  const handleRemoveEvidence = (index: number) => {
    setEvidence(evidence.filter((_, i) => i !== index));
  };

  const toggleCharge = (item: PenalCodeItem) => {
    if (charges.some(c => c.code === item.code)) {
      setCharges(charges.filter(c => c.code !== item.code));
    } else {
      setCharges([...charges, item]);
    }
  };

  const handleSaveSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !description.trim()) return;

    const payload: IncidentReport = {
      id: selectedIncident?.id,
      title: title.trim(),
      description: description.trim(),
      location: location.trim() || "Los Santos",
      reporting_officer: selectedIncident?.reporting_officer || currentOfficer?.name || "Officer",
      suspects: suspects,
      officers: officers,
      charges: charges,
      evidence: evidence,
      status: status,
      total_fine: totalFine,
      total_jail: totalJail
    };

    onSaveIncident(payload);
    setIsEditing(false);
  };

  const filteredIncidents = incidents.filter(inc =>
    inc.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    inc.location.toLowerCase().includes(searchQuery.toLowerCase()) ||
    inc.reporting_officer.toLowerCase().includes(searchQuery.toLowerCase()) ||
    (inc.id && inc.id.toString().includes(searchQuery))
  );

  const filteredPenalCodes = penalCodes.filter(pc =>
    pc.code.toLowerCase().includes(chargeSearch.toLowerCase()) ||
    pc.title.toLowerCase().includes(chargeSearch.toLowerCase()) ||
    pc.category.toLowerCase().includes(chargeSearch.toLowerCase())
  );

  return (
    <div className="flex-1 flex flex-col p-6 overflow-hidden">
      {/* Search and Top Actions Bar */}
      <div className="flex items-center justify-between gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search incident reports by title, ID, officer, or street..."
            className="w-full pl-9 pr-4 py-2.5 rounded-2xl bg-slate-900/80 border border-white/10 text-white placeholder-slate-400 text-xs focus:outline-none focus:border-cyan-500/50 shadow-inner"
          />
        </div>

        <button
          onClick={startNewReport}
          className="px-4 py-2.5 rounded-2xl bg-cyan-600 hover:bg-cyan-500 text-white text-xs font-bold flex items-center gap-2 shadow-lg shadow-cyan-600/30 transition-all hover:scale-105"
        >
          <Plus className="w-4 h-4" />
          Create Incident Report
        </button>
      </div>

      {/* Main Layout Grid */}
      <div className="flex-1 grid grid-cols-12 gap-6 overflow-hidden">
        {/* Left: Incident Reports List */}
        <div className="col-span-12 md:col-span-4 bg-slate-900/60 backdrop-blur-xl border border-white/10 rounded-3xl p-4 flex flex-col overflow-hidden">
          <div className="flex items-center justify-between pb-3 border-b border-white/10 mb-3">
            <span className="text-xs font-bold uppercase tracking-wider text-slate-400">Incident Archive</span>
            <span className="text-xs font-mono text-cyan-400">{filteredIncidents.length} Reports</span>
          </div>

          <div className="flex-1 overflow-y-auto space-y-2 pr-1 custom-scrollbar">
            {filteredIncidents.length === 0 ? (
              <div className="h-full flex flex-col items-center justify-center text-center p-6 text-slate-500">
                <FileText className="w-12 h-12 mb-2 stroke-1 opacity-40" />
                <p className="text-xs">No incident records found. Click 'Create Incident Report' to draft an official case.</p>
              </div>
            ) : (
              filteredIncidents.map((inc) => (
                <div
                  key={inc.id}
                  onClick={() => loadIncidentForView(inc)}
                  className={`p-3.5 rounded-2xl border transition-all cursor-pointer flex items-center justify-between ${
                    selectedIncident?.id === inc.id && !isEditing
                      ? 'bg-cyan-950/60 border-cyan-500/60 shadow-md ring-1 ring-cyan-500/30'
                      : 'bg-slate-800/40 border-white/5 hover:bg-slate-800/80 hover:border-white/15'
                  }`}
                >
                  <div>
                    <div className="flex items-center gap-2 text-xs mb-1">
                      <span className="font-mono text-[10px] font-bold text-cyan-400">#{inc.id}</span>
                      <span className={`px-2 py-0.2 rounded-full text-[9px] font-bold uppercase border ${
                        inc.status === 'Open' ? 'bg-amber-600/20 text-amber-300 border-amber-500/30' :
                        inc.status === 'Under Investigation' ? 'bg-blue-600/20 text-blue-300 border-blue-500/30' :
                        'bg-slate-700/30 text-slate-300 border-slate-600/30'
                      }`}>
                        {inc.status}
                      </span>
                    </div>
                    <h4 className="text-sm font-bold text-white line-clamp-1">{inc.title}</h4>
                    <div className="text-[11px] text-slate-400 mt-0.5">
                      By {inc.reporting_officer} • {inc.location}
                    </div>
                  </div>
                  <ChevronRight className="w-4 h-4 text-slate-400 shrink-0" />
                </div>
              ))
            )}
          </div>
        </div>

        {/* Right: Incident Viewer / Editor */}
        <div className="col-span-12 md:col-span-8 bg-slate-900/60 backdrop-blur-xl border border-white/10 rounded-3xl p-6 flex flex-col overflow-y-auto custom-scrollbar">
          {!isEditing && !selectedIncident ? (
            <div className="h-full flex flex-col items-center justify-center text-center p-12 text-slate-500">
              <FileText className="w-16 h-16 mb-3 stroke-1 opacity-30" />
              <h3 className="text-base font-bold text-slate-300 mb-1">Select or Draft an Incident Report</h3>
              <p className="text-xs max-w-sm">Select an incident from the log or click 'Create Incident Report' to file an official criminal citation, attached charges, and evidence.</p>
            </div>
          ) : isEditing ? (
            /* Editing / Creating Mode */
            <form onSubmit={handleSaveSubmit} className="space-y-6">
              <div className="flex items-center justify-between pb-4 border-b border-white/10">
                <h3 className="text-xl font-black text-white flex items-center gap-2">
                  <FileText className="w-5 h-5 text-cyan-400" />
                  {selectedIncident ? `Edit Incident #${selectedIncident.id}` : "Draft New Incident Report"}
                </h3>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setIsEditing(false)}
                    className="px-3 py-1.5 rounded-xl bg-slate-800 text-slate-300 text-xs font-bold hover:bg-slate-700"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-1.5 rounded-xl bg-cyan-600 hover:bg-cyan-500 text-white text-xs font-bold flex items-center gap-1.5 shadow-lg shadow-cyan-600/30"
                  >
                    <Save className="w-4 h-4" />
                    Save Incident
                  </button>
                </div>
              </div>

              {/* Title & Status */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="md:col-span-2">
                  <label className="block text-xs font-semibold text-slate-400 mb-1">Incident Title</label>
                  <input
                    type="text"
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    placeholder="e.g. 10-90 Armed Bank Robbery at Legion Square"
                    className="w-full p-2.5 rounded-xl bg-slate-800 border border-white/10 text-white text-xs font-bold focus:outline-none focus:border-cyan-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-slate-400 mb-1">Case Status</label>
                  <select
                    value={status}
                    onChange={(e) => setStatus(e.target.value as any)}
                    className="w-full p-2.5 rounded-xl bg-slate-800 border border-white/10 text-white text-xs"
                  >
                    <option value="Closed">Closed / Convicted</option>
                    <option value="Open">Open</option>
                    <option value="Under Investigation">Under Investigation</option>
                    <option value="Draft">Draft</option>
                  </select>
                </div>
              </div>

              {/* Location */}
              <div>
                <label className="block text-xs font-semibold text-slate-400 mb-1">Incident Location / Postal</label>
                <input
                  type="text"
                  value={location}
                  onChange={(e) => setLocation(e.target.value)}
                  placeholder="e.g. Vinewood Blvd / Postal 7012"
                  className="w-full p-2.5 rounded-xl bg-slate-800 border border-white/10 text-white text-xs focus:outline-none focus:border-cyan-500"
                />
              </div>

              {/* Suspects & Involved Officers */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* Suspects Card */}
                <div className="p-4 rounded-2xl bg-slate-800/40 border border-white/10">
                  <label className="block text-xs font-semibold text-slate-300 mb-2 flex items-center gap-1.5">
                    <User className="w-3.5 h-3.5 text-red-400" />
                    Involved Suspects
                  </label>
                  <div className="flex gap-2 mb-2">
                    <input
                      type="text"
                      value={suspectInput}
                      onChange={(e) => setSuspectInput(e.target.value)}
                      placeholder="Suspect Name / Citizen ID..."
                      className="flex-1 p-2 rounded-xl bg-slate-900 border border-white/10 text-white text-xs"
                    />
                    <button
                      type="button"
                      onClick={handleAddSuspect}
                      className="px-3 py-1.5 rounded-xl bg-red-600/30 border border-red-500/40 text-red-200 text-xs font-bold hover:bg-red-600 hover:text-white transition-colors"
                    >
                      Add
                    </button>
                  </div>
                  <div className="flex flex-wrap gap-1.5">
                    {suspects.map((s, i) => (
                      <span key={i} className="px-2.5 py-1 rounded-xl bg-red-950/60 border border-red-500/40 text-red-300 text-xs flex items-center gap-1.5">
                        {s.name}
                        <Trash2 onClick={() => handleRemoveSuspect(i)} className="w-3 h-3 cursor-pointer hover:text-white" />
                      </span>
                    ))}
                  </div>
                </div>

                {/* Officers Card */}
                <div className="p-4 rounded-2xl bg-slate-800/40 border border-white/10">
                  <label className="block text-xs font-semibold text-slate-300 mb-2 flex items-center gap-1.5">
                    <Users className="w-3.5 h-3.5 text-cyan-400" />
                    Involved Officers
                  </label>
                  <div className="flex gap-2 mb-2">
                    <input
                      type="text"
                      value={officerInput}
                      onChange={(e) => setOfficerInput(e.target.value)}
                      placeholder="Officer Name / Callsign..."
                      className="flex-1 p-2 rounded-xl bg-slate-900 border border-white/10 text-white text-xs"
                    />
                    <button
                      type="button"
                      onClick={handleAddOfficer}
                      className="px-3 py-1.5 rounded-xl bg-cyan-600/30 border border-cyan-500/40 text-cyan-200 text-xs font-bold hover:bg-cyan-600 hover:text-white transition-colors"
                    >
                      Add
                    </button>
                  </div>
                  <div className="flex flex-wrap gap-1.5">
                    {officers.map((o, i) => (
                      <span key={i} className="px-2.5 py-1 rounded-xl bg-cyan-950/60 border border-cyan-500/40 text-cyan-300 text-xs flex items-center gap-1.5">
                        {o.name}
                        <Trash2 onClick={() => handleRemoveOfficer(i)} className="w-3 h-3 cursor-pointer hover:text-white" />
                      </span>
                    ))}
                  </div>
                </div>
              </div>

              {/* Penal Charges & Calculator */}
              <div className="p-4 rounded-2xl bg-slate-800/40 border border-white/10">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <Scale className="w-4 h-4 text-purple-400" />
                    <span className="text-xs font-bold uppercase tracking-wider text-slate-300">
                      Penal Code Charges Multi-Selector
                    </span>
                  </div>
                  <button
                    type="button"
                    onClick={() => setShowChargePicker(!showChargePicker)}
                    className="px-3 py-1 rounded-xl bg-purple-600 hover:bg-purple-500 text-white text-xs font-bold flex items-center gap-1.5 transition-colors shadow-sm"
                  >
                    <Plus className="w-3.5 h-3.5" />
                    {showChargePicker ? "Close Charge Catalog" : "Add Charges"}
                  </button>
                </div>

                {/* Charge Picker Overlay */}
                {showChargePicker && (
                  <div className="mb-4 p-3 rounded-2xl bg-slate-900 border border-purple-500/40 space-y-3">
                    <input
                      type="text"
                      value={chargeSearch}
                      onChange={(e) => setChargeSearch(e.target.value)}
                      placeholder="Filter laws by title, code (10-101), or felony/misdemeanor..."
                      className="w-full p-2 rounded-xl bg-slate-800 border border-white/10 text-white text-xs"
                    />
                    <div className="max-h-48 overflow-y-auto space-y-1.5 pr-1 custom-scrollbar">
                      {filteredPenalCodes.map((pc) => {
                        const isSelected = charges.some(c => c.code === pc.code);
                        return (
                          <div
                            key={pc.code}
                            onClick={() => toggleCharge(pc)}
                            className={`p-2.5 rounded-xl text-xs cursor-pointer flex items-center justify-between transition-colors ${
                              isSelected ? 'bg-purple-600/30 border border-purple-500/60 text-purple-200' : 'bg-slate-800/80 hover:bg-slate-800 text-slate-300'
                            }`}
                          >
                            <div>
                              <span className="font-bold text-white mr-2">{pc.code} - {pc.title}</span>
                              <span className="text-[10px] text-slate-400">({pc.class})</span>
                            </div>
                            <div className="font-mono text-xs font-bold text-purple-300">
                              ${pc.fine} | {pc.jail_time}m
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                )}

                {/* Selected Charges Summary & Auto Calculation Bar */}
                <div className="space-y-2 mb-3">
                  {charges.length === 0 ? (
                    <div className="text-xs text-slate-500 italic">No charges attached yet.</div>
                  ) : (
                    charges.map((c, i) => (
                      <div key={i} className="p-2 rounded-xl bg-slate-900/80 border border-white/5 flex items-center justify-between text-xs">
                        <div className="flex items-center gap-2">
                          <span className="font-mono font-bold text-purple-400">{c.code}</span>
                          <span className="font-semibold text-white">{c.title}</span>
                        </div>
                        <div className="flex items-center gap-3">
                          <span className="font-mono text-emerald-400 font-bold">${c.fine}</span>
                          <span className="font-mono text-amber-400 font-bold">{c.jail_time} mins</span>
                          <Trash2 onClick={() => toggleCharge(c)} className="w-3.5 h-3.5 text-slate-400 hover:text-red-400 cursor-pointer" />
                        </div>
                      </div>
                    ))
                  )}
                </div>

                {/* Auto Calculated Sums */}
                <div className="pt-3 border-t border-white/10 flex items-center justify-between text-xs bg-slate-950/40 p-3 rounded-2xl">
                  <span className="font-bold uppercase tracking-wider text-slate-400">Recommended Penalties:</span>
                  <div className="flex items-center gap-4 font-mono font-black text-sm">
                    <span className="text-emerald-400 flex items-center gap-1">
                      <DollarSign className="w-4 h-4" /> Total Fine: ${totalFine.toLocaleString()}
                    </span>
                    <span className="text-amber-400 flex items-center gap-1">
                      <Clock className="w-4 h-4" /> Total Jail: {totalJail} Minutes
                    </span>
                  </div>
                </div>
              </div>

              {/* Narrative Summary */}
              <div>
                <label className="block text-xs font-semibold text-slate-400 mb-1">
                  Statement of Facts / Officer Narrative
                </label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Provide a detailed chronological narrative of the incident, probable cause, suspect statements, and Miranda rights advisement..."
                  rows={6}
                  className="w-full p-3 rounded-2xl bg-slate-800 border border-white/10 text-white text-xs focus:outline-none focus:border-cyan-500 custom-scrollbar"
                />
              </div>
            </form>
          ) : (
            /* View Mode */
            selectedIncident && (
              <div className="space-y-6">
                <div className="flex items-start justify-between pb-4 border-b border-white/10 flex-wrap gap-4">
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <span className="font-mono text-xs font-bold text-cyan-400">Case #{selectedIncident.id}</span>
                      <span className="px-2.5 py-0.5 rounded-full text-xs font-bold uppercase bg-slate-800 text-slate-300 border border-white/10">
                        {selectedIncident.status}
                      </span>
                    </div>
                    <h2 className="text-2xl font-black text-white">{selectedIncident.title}</h2>
                    <div className="text-xs text-slate-400 mt-1 flex items-center gap-3">
                      <span>Reporting Officer: <strong className="text-white">{selectedIncident.reporting_officer}</strong></span>
                      <span>Location: <strong className="text-white">{selectedIncident.location}</strong></span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => loadIncidentForEdit(selectedIncident)}
                      className="px-4 py-2 rounded-xl bg-cyan-600 hover:bg-cyan-500 text-white text-xs font-bold transition-colors"
                    >
                      Edit Report
                    </button>
                    <button
                      onClick={() => selectedIncident.id && onDeleteIncident(selectedIncident.id)}
                      className="p-2 rounded-xl bg-slate-800 hover:bg-red-600 text-slate-400 hover:text-white transition-colors"
                      title="Delete Incident"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                {/* Suspects & Officers */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="p-4 rounded-2xl bg-slate-800/40 border border-white/10">
                    <span className="text-xs font-bold uppercase tracking-wider text-red-400 block mb-2">Suspects</span>
                    <div className="flex flex-wrap gap-2">
                      {selectedIncident.suspects && selectedIncident.suspects.length > 0 ? (
                        selectedIncident.suspects.map((s, i) => (
                          <span 
                            key={i} 
                            onClick={() => onOpenCitizen(s.name)}
                            className="px-3 py-1 rounded-xl bg-red-950/60 border border-red-500/40 text-red-300 text-xs font-semibold cursor-pointer hover:border-red-400 transition-colors"
                          >
                            {s.name}
                          </span>
                        ))
                      ) : (
                        <span className="text-xs text-slate-500 italic">No named suspects</span>
                      )}
                    </div>
                  </div>

                  <div className="p-4 rounded-2xl bg-slate-800/40 border border-white/10">
                    <span className="text-xs font-bold uppercase tracking-wider text-cyan-400 block mb-2">Officers</span>
                    <div className="flex flex-wrap gap-2">
                      {selectedIncident.officers && selectedIncident.officers.length > 0 ? (
                        selectedIncident.officers.map((o, i) => (
                          <span key={i} className="px-3 py-1 rounded-xl bg-cyan-950/60 border border-cyan-500/40 text-cyan-300 text-xs font-semibold">
                            {o.name}
                          </span>
                        ))
                      ) : (
                        <span className="text-xs text-slate-500 italic">No additional officers</span>
                      )}
                    </div>
                  </div>
                </div>

                {/* Charges & Sentences */}
                <div className="p-4 rounded-2xl bg-slate-800/40 border border-white/10">
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-xs font-bold uppercase tracking-wider text-purple-400">Attached Charges</span>
                    <div className="font-mono text-xs font-bold text-slate-300">
                      Fine: <span className="text-emerald-400">${(selectedIncident.total_fine || 0).toLocaleString()}</span> | Jail: <span className="text-amber-400">{selectedIncident.total_jail || 0} Months</span>
                    </div>
                  </div>

                  <div className="space-y-1.5">
                    {selectedIncident.charges && selectedIncident.charges.length > 0 ? (
                      selectedIncident.charges.map((c, i) => (
                        <div key={i} className="p-2 rounded-xl bg-slate-900/60 border border-white/5 flex items-center justify-between text-xs">
                          <span className="font-semibold text-white">{c.code} - {c.title}</span>
                          <span className="font-mono text-slate-400">${c.fine} | {c.jail_time}m</span>
                        </div>
                      ))
                    ) : (
                      <div className="text-xs text-slate-500 italic">No formal charges attached.</div>
                    )}
                  </div>
                </div>

                {/* Narrative Statement */}
                <div>
                  <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400 mb-2">Incident Narrative</h4>
                  <div className="p-4 rounded-2xl bg-slate-950/60 border border-white/10 text-xs text-slate-200 whitespace-pre-wrap leading-relaxed">
                    {selectedIncident.description}
                  </div>
                </div>
              </div>
            )
          )}
        </div>
      </div>
    </div>
  );
}
