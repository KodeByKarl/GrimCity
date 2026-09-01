import React, { useState } from "react";
import { 
  Shield, 
  User, 
  Award, 
  Edit3, 
  Save, 
  Radio, 
  Megaphone, 
  CheckCircle2, 
  Sparkles
} from "lucide-react";
import { DutyOfficer, OfficerProfile } from "../types/mdt";

interface DepartmentRosterProps {
  currentOfficer: OfficerProfile | null;
  activeOfficers: DutyOfficer[];
  onUpdateProfile: (data: { callsign: string; department: string; badge_number: string }) => void;
}

export default function DepartmentRoster({
  currentOfficer,
  activeOfficers,
  onUpdateProfile
}: DepartmentRosterProps) {
  const [callsign, setCallsign] = useState(currentOfficer?.callsign || "1-A-01");
  const [department, setDepartment] = useState(currentOfficer?.department || "LSPD");
  const [badgeNumber, setBadgeNumber] = useState(currentOfficer?.badge_number || "001");
  const [isSaved, setIsSaved] = useState(false);

  const handleSaveProfile = (e: React.FormEvent) => {
    e.preventDefault();
    onUpdateProfile({
      callsign: callsign.trim(),
      department: department.trim(),
      badge_number: badgeNumber.trim()
    });
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 3000);
  };

  const announcements = [
    {
      id: 1,
      title: "Operation Safe Streets - Citywide Patrol Order",
      author: "Chief of Police",
      date: "Today",
      content: "All units on 10-8 patrol are instructed to increase surveillance around high-traffic banking districts and convenience store corridors due to heightened gang activity."
    },
    {
      id: 2,
      title: "New MDT System Integration & BOLO Broadcasts",
      author: "Department Administrator",
      date: "Yesterday",
      content: "Officers are reminded to immediately file official incident reports with complete penal charge attachments to ensure automatic fine processing and prison sentencing."
    }
  ];

  return (
    <div className="flex-1 flex flex-col p-6 overflow-hidden">
      <div className="grid grid-cols-12 gap-6 overflow-hidden flex-1">
        {/* Left Column: Officer Profile & Customizer */}
        <div className="col-span-12 lg:col-span-5 bg-slate-900/60 backdrop-blur-xl border border-white/10 rounded-3xl p-6 flex flex-col justify-between overflow-y-auto custom-scrollbar">
          <div>
            <div className="flex items-center gap-3 pb-4 border-b border-white/10 mb-6">
              <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-cyan-600 to-blue-700 flex items-center justify-center text-white font-black text-xl shadow-lg border border-white/20">
                <Shield className="w-7 h-7" />
              </div>
              <div>
                <h3 className="text-lg font-black text-white">{currentOfficer?.name || "Officer Profile"}</h3>
                <div className="text-xs text-cyan-300 font-mono">
                  {currentOfficer?.rank} • Grade {currentOfficer?.grade}
                </div>
              </div>
            </div>

            {/* Callsign & Identity Form */}
            <form onSubmit={handleSaveProfile} className="space-y-4">
              <h4 className="text-xs uppercase font-bold tracking-wider text-slate-400">
                Radio Identity & Unit Setup
              </h4>

              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">Radio Callsign</label>
                <input
                  type="text"
                  value={callsign}
                  onChange={(e) => setCallsign(e.target.value)}
                  placeholder="e.g. 1-A-12, LINCOLN-04, KING-99"
                  className="w-full p-3 rounded-2xl bg-slate-800 border border-white/10 text-white font-mono font-bold text-xs focus:outline-none focus:border-cyan-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">Department</label>
                <select
                  value={department}
                  onChange={(e) => setDepartment(e.target.value)}
                  className="w-full p-3 rounded-2xl bg-slate-800 border border-white/10 text-white text-xs font-semibold focus:outline-none focus:border-cyan-500"
                >
                  <option value="LSPD">Los Santos Police Department (LSPD)</option>
                  <option value="BCSO">Blaine County Sheriff Office (BCSO)</option>
                  <option value="SASP">San Andreas State Police (SASP)</option>
                  <option value="SAHP">San Andreas Highway Patrol (SAHP)</option>
                  <option value="FIB">Federal Investigation Bureau (FIB)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">Badge Number</label>
                <input
                  type="text"
                  value={badgeNumber}
                  onChange={(e) => setBadgeNumber(e.target.value)}
                  placeholder="e.g. 402, 108"
                  className="w-full p-3 rounded-2xl bg-slate-800 border border-white/10 text-white font-mono text-xs focus:outline-none focus:border-cyan-500"
                />
              </div>

              <button
                type="submit"
                className="w-full py-3 rounded-2xl bg-cyan-600 hover:bg-cyan-500 text-white text-xs font-bold flex items-center justify-center gap-2 shadow-lg shadow-cyan-600/30 transition-all hover:scale-[1.02]"
              >
                <Save className="w-4 h-4" />
                {isSaved ? "Identity Profile Saved!" : "Save Unit Configuration"}
              </button>
            </form>
          </div>

          <div className="pt-4 border-t border-white/10 text-[11px] text-slate-400 flex items-center justify-between">
            <span>Jurisdiction: San Andreas</span>
            <span className="font-mono text-emerald-400">AUTHENTICATED</span>
          </div>
        </div>

        {/* Right Column: Active Duty Roster & Department Bulletins */}
        <div className="col-span-12 lg:col-span-7 flex flex-col gap-6 overflow-hidden">
          {/* Department Announcements */}
          <div className="bg-slate-900/60 backdrop-blur-xl border border-white/10 rounded-3xl p-5 flex flex-col">
            <div className="flex items-center gap-2 pb-3 border-b border-white/10 mb-3">
              <Megaphone className="w-4 h-4 text-amber-400" />
              <span className="text-xs font-bold uppercase tracking-wider text-slate-300">
                Department Directives & Bulletins
              </span>
            </div>

            <div className="space-y-3">
              {announcements.map((item) => (
                <div key={item.id} className="p-3.5 rounded-2xl bg-slate-800/40 border border-white/5">
                  <div className="flex items-center justify-between text-xs mb-1">
                    <span className="font-bold text-white">{item.title}</span>
                    <span className="text-slate-400 font-mono text-[10px]">{item.author} • {item.date}</span>
                  </div>
                  <p className="text-xs text-slate-300">{item.content}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Active Officers Roster */}
          <div className="flex-1 bg-slate-900/60 backdrop-blur-xl border border-white/10 rounded-3xl p-5 flex flex-col overflow-hidden">
            <div className="flex items-center justify-between pb-3 border-b border-white/10 mb-3">
              <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
                Logged-In Officer Roster ({activeOfficers.length || 1})
              </span>
              <span className="text-xs font-mono text-cyan-400">ENCRYPTED NET</span>
            </div>

            <div className="flex-1 overflow-y-auto space-y-2 pr-1 custom-scrollbar">
              {activeOfficers.map((off, i) => (
                <div
                  key={i}
                  className="p-3 rounded-2xl bg-slate-800/40 border border-white/5 flex items-center justify-between text-xs"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl bg-slate-800 border border-white/10 flex items-center justify-center font-mono font-bold text-cyan-400">
                      {off.callsign || "1-A"}
                    </div>
                    <div>
                      <div className="font-bold text-white flex items-center gap-2">
                        {off.name}
                        <span className="text-[10px] font-mono text-cyan-300 font-normal">[{off.department}]</span>
                      </div>
                      <div className="text-[11px] text-slate-400">
                        {off.rank} • Badge #{off.badge_number || "001"}
                      </div>
                    </div>
                  </div>

                  <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold font-mono ${
                    off.status === '10-8' ? 'bg-emerald-600/30 text-emerald-300 border border-emerald-500/40' :
                    off.status === '10-6' ? 'bg-amber-600/30 text-amber-300 border border-amber-500/40' :
                    'bg-slate-700/40 text-slate-300 border border-slate-600/40'
                  }`}>
                    {off.status}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
