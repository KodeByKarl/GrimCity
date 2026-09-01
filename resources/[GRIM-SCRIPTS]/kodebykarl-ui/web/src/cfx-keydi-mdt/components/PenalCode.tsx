import React, { useState } from "react";
import { 
  Scale, 
  Search, 
  Filter, 
  DollarSign, 
  Clock, 
  Award, 
  ShieldAlert, 
  AlertCircle, 
  FileText,
  ChevronRight
} from "lucide-react";
import { PenalCodeItem } from "../types/mdt";

interface PenalCodeProps {
  penalCodes: PenalCodeItem[];
  onOpenReportWithCharge?: (charge: PenalCodeItem) => void;
}

export default function PenalCode({ penalCodes, onOpenReportWithCharge }: PenalCodeProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string>("all");
  const [selectedClass, setSelectedClass] = useState<string>("all");

  const categories = ["all", ...Array.from(new Set(penalCodes.map(pc => pc.category)))];

  const filteredCodes = penalCodes.filter(pc => {
    const matchesSearch = 
      pc.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
      pc.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      pc.description.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesCategory = selectedCategory === "all" || pc.category === selectedCategory;
    const matchesClass = selectedClass === "all" || pc.class.toLowerCase() === selectedClass.toLowerCase();

    return matchesSearch && matchesCategory && matchesClass;
  });

  return (
    <div className="flex-1 flex flex-col p-6 overflow-hidden">
      {/* Header Controls */}
      <div className="flex items-center justify-between gap-4 mb-6 flex-wrap">
        {/* Search */}
        <div className="relative flex-1 min-w-[240px]">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search statutes, code (e.g. 10-103), or crime description..."
            className="w-full pl-10 pr-4 py-2.5 rounded-2xl bg-slate-900/80 border border-white/10 text-white placeholder-slate-400 text-xs focus:outline-none focus:border-purple-500/50 shadow-inner"
          />
        </div>

        {/* Filters */}
        <div className="flex items-center gap-3">
          {/* Class Filter */}
          <div className="p-1 rounded-2xl bg-slate-900/80 border border-white/10 flex items-center gap-1">
            {["all", "Infraction", "Misdemeanor", "Felony"].map((cls) => (
              <button
                key={cls}
                onClick={() => setSelectedClass(cls)}
                className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all ${
                  selectedClass === cls
                    ? cls === 'Felony' ? 'bg-red-600 text-white shadow-md' :
                      cls === 'Misdemeanor' ? 'bg-amber-600 text-white shadow-md' :
                      cls === 'Infraction' ? 'bg-blue-600 text-white shadow-md' :
                      'bg-purple-600 text-white shadow-md'
                    : 'text-slate-400 hover:text-white'
                }`}
              >
                {cls === "all" ? "All Classes" : cls}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Categories Bar */}
      <div className="flex items-center gap-2 overflow-x-auto pb-3 mb-4 custom-scrollbar">
        {categories.map((cat) => (
          <button
            key={cat}
            onClick={() => setSelectedCategory(cat)}
            className={`px-4 py-1.5 rounded-xl text-xs font-bold whitespace-nowrap transition-all border ${
              selectedCategory === cat
                ? 'bg-purple-600/30 border-purple-500/60 text-purple-200 shadow-md ring-1 ring-purple-500/40'
                : 'bg-slate-900/40 border-white/5 text-slate-400 hover:text-white hover:border-white/15'
            }`}
          >
            {cat === "all" ? "All Categories" : cat}
          </button>
        ))}
      </div>

      {/* Statutes Catalog Grid */}
      <div className="flex-1 overflow-y-auto pr-1 custom-scrollbar">
        {filteredCodes.length === 0 ? (
          <div className="h-full flex flex-col items-center justify-center text-center p-12 text-slate-500">
            <Scale className="w-16 h-16 mb-3 stroke-1 opacity-30 text-purple-500" />
            <h3 className="text-base font-bold text-slate-300 mb-1">No Statutes Found</h3>
            <p className="text-xs max-w-sm">No penal code offenses match your search filter or selected category.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filteredCodes.map((pc) => {
              const isFelony = pc.class === 'Felony';
              const isMisdemeanor = pc.class === 'Misdemeanor';
              return (
                <div
                  key={pc.code}
                  className={`bg-slate-900/70 backdrop-blur-xl border rounded-3xl p-5 shadow-xl flex flex-col justify-between transition-all duration-200 hover:scale-[1.01] ${
                    isFelony ? 'border-red-500/30 hover:border-red-500/60' :
                    isMisdemeanor ? 'border-amber-500/30 hover:border-amber-500/60' :
                    'border-blue-500/30 hover:border-blue-500/60'
                  }`}
                >
                  <div>
                    <div className="flex items-start justify-between gap-2 mb-2">
                      <div>
                        <span className="font-mono text-[11px] font-bold text-purple-400">
                          § {pc.code} • {pc.category}
                        </span>
                        <h4 className="text-sm font-black text-white">{pc.title}</h4>
                      </div>
                      <span className={`px-2 py-0.5 rounded-full text-[9px] font-bold uppercase border ${
                        isFelony ? 'bg-red-600/20 text-red-300 border-red-500/40' :
                        isMisdemeanor ? 'bg-amber-600/20 text-amber-300 border-amber-500/40' :
                        'bg-blue-600/20 text-blue-300 border-blue-500/40'
                      }`}>
                        {pc.class}
                      </span>
                    </div>

                    <p className="text-xs text-slate-300 mb-4 bg-slate-950/40 p-3 rounded-2xl border border-white/5 line-clamp-3">
                      {pc.description}
                    </p>
                  </div>

                  <div className="pt-3 border-t border-white/10 flex items-center justify-between text-xs font-mono font-bold">
                    <div className="flex items-center gap-3">
                      <span className="text-emerald-400 flex items-center gap-0.5">
                        <DollarSign className="w-3.5 h-3.5" /> ${pc.fine.toLocaleString()}
                      </span>
                      <span className="text-amber-400 flex items-center gap-0.5">
                        <Clock className="w-3.5 h-3.5" /> {pc.jail_time}m
                      </span>
                    </div>

                    {pc.points && pc.points > 0 ? (
                      <span className="text-blue-400 text-[10px] flex items-center gap-1 font-sans font-bold">
                        <Award className="w-3.5 h-3.5" /> {pc.points} pts
                      </span>
                    ) : null}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
