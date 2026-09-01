import React from "react";
import { 
  User, 
  Activity, 
  Shield, 
  Wrench, 
  MapPin, 
  Wifi, 
  AlertTriangle, 
  Sparkles, 
  Lock, 
  Unlock, 
  Clock, 
  Zap 
} from "lucide-react";

interface PlayerDetails {
  name: string;
  avatarUrl?: string;
  rank: string;
  kills: number;
  kd: string;
  playTime: string;
  ping: number;
}

interface PopulationData {
  current: number;
  max: number;
}

interface JobData {
  name: string;
  online: number;
}

interface PriorityData {
  name: string;
  status: "Safe" | "In Progress" | "Cooldown" | "Hold" | string;
}

interface WorldEventData {
  name: string;
  location: string;
  status: "ACTIVE" | "INACTIVE";
}

interface ActiveRobberyData {
  name: string;
  location: string;
  timeLeft: string;
}

interface ScoreboardData {
  toggleKey?: string;
  serverName: string;
  enablePriorityStatus: boolean;
  playerName: string;
  playerId: number;
  ping: number;
  avatarUrl?: string;
  stats: {
    playTime: string;
    rank: string;
    kills: number;
    kd: string;
    health: number;
    armor: number;
  };
  population: PopulationData;
  jobs: JobData[];
  priorities: PriorityData[];
  worldEvents: WorldEventData[];
  robberies: ActiveRobberyData[];
}

const MOCK_DATA: ScoreboardData = {
  toggleKey: "F10",
  serverName: "Pandora City",
  enablePriorityStatus: true,
  playerName: "dawdadda dwadadadaw",
  playerId: 1,
  ping: 13,
  avatarUrl: "https://api.dicebear.com/7.x/bottts/svg?seed=dawdadda",
  stats: {
    playTime: "0m",
    rank: "Player",
    kills: 0,
    kd: "0.00",
    health: 100,
    armor: 0,
  },
  population: {
    current: 1,
    max: 2,
  },
  jobs: [
    { name: "LS EMS", online: 0 },
    { name: "LS Police", online: 1 },
    { name: "Mechanic", online: 0 },
  ],
  priorities: [
    { name: "LS Police", status: "Safe" },
    { name: "Paleto Sheriff", status: "Safe" },
  ],
  worldEvents: [
    { name: "Airdrop", location: "Sandy Shores", status: "INACTIVE" },
    { name: "Traphouse", location: "Unknown", status: "INACTIVE" },
    { name: "Turf Wars", location: "Unknown", status: "INACTIVE" },
  ],
  robberies: [],
};

const getJobIcon = (name: string) => {
  const lower = name.toLowerCase();
  if (lower.includes("ems") || lower.includes("medical") || lower.includes("ambulance")) {
    return <Activity className="h-3.5 w-3.5 text-[#ffa6ce]" />;
  }
  if (lower.includes("mechanic")) {
    return <Wrench className="h-3.5 w-3.5 text-[#ffa6ce]" />;
  }
  return <Shield className="h-3.5 w-3.5 text-[#ffa6ce]" />;
};

interface ScoreboardProps {
  data?: Partial<ScoreboardData>;
}

export default function Scoreboard({ data = {} }: ScoreboardProps) {
  const merged: ScoreboardData = {
    ...MOCK_DATA,
    ...data,
    stats: {
      ...MOCK_DATA.stats,
      ...data.stats,
    },
    population: {
      ...MOCK_DATA.population,
      ...data.population,
    },
    jobs: data.jobs || MOCK_DATA.jobs,
    priorities: data.priorities || MOCK_DATA.priorities,
    worldEvents: data.worldEvents || MOCK_DATA.worldEvents,
    robberies: data.robberies || MOCK_DATA.robberies,
  };

  const popPercentage = Math.min((merged.population.current / merged.population.max) * 100, 100);

  return (
    <div className="pandora animate-fade-in flex min-h-screen items-center justify-center p-3 bg-black/60 backdrop-blur-md select-none pointer-events-auto antialiased">
      {/* 3-Panel Scoreboard Grid with 3D Perspective - Compact Non-Stretched */}
      <div 
        className="grid grid-cols-3 gap-3 max-w-[680px] w-full items-start"
        style={{ perspective: "1200px", transformStyle: "preserve-3d" }}
      >
        
        {/* PANEL 1: YOUR PROFILE */}
        <section 
          className="relative flex flex-col justify-between overflow-hidden rounded-2xl border p-3.5 backdrop-blur-2xl transition-all duration-300 hover:border-[#ff3d96]/50"
          style={{
            background: "linear-gradient(180deg, rgba(10, 40, 70, 0.95), rgba(5, 25, 47, 0.98))",
            boxShadow: "0 15px 35px rgba(0, 0, 0, 0.85), 0 0 20px rgba(255, 61, 150, 0.15)",
            borderColor: "rgba(255, 61, 150, 0.28)",
            transform: "perspective(1200px) rotateY(5deg)",
            transformStyle: "preserve-3d",
            backfaceVisibility: "hidden",
          }}
        >
          {/* Grid Background Pattern */}
          <div className="panel-grid absolute inset-0 opacity-20 pointer-events-none" />
          
          <div className="relative z-10 flex flex-col gap-3">
            {/* Header */}
            <div 
              className="flex items-center gap-2.5 border-b pb-2.5"
              style={{ borderBottomColor: "rgba(255, 122, 181, 0.22)" }}
            >
              <div 
                className="flex h-7 w-7 items-center justify-center rounded-full border shadow-sm"
                style={{ backgroundColor: "rgba(255, 61, 150, 0.18)", borderColor: "rgba(255, 61, 150, 0.4)" }}
              >
                <span className="pandora-display text-[#ff3d96] font-extrabold text-sm">P</span>
              </div>
              <div>
                <h2 className="text-[11px] font-black uppercase tracking-[0.18em] text-[#ff3d96] drop-shadow-sm">YOUR PROFILE</h2>
                <p className="text-[9px] font-medium text-[#9cc3e6]">Player card</p>
              </div>
            </div>

            {/* Profile Card */}
            <div 
              className="flex items-center gap-3 rounded-xl border p-2.5"
              style={{ backgroundColor: "rgba(16, 55, 95, 0.75)", borderColor: "rgba(53, 199, 242, 0.3)" }}
            >
              {merged.avatarUrl ? (
                <img 
                  src={merged.avatarUrl} 
                  alt="avatar" 
                  className="h-11 w-11 rounded-lg border bg-black/40 object-cover shadow-sm"
                  style={{ borderColor: "rgba(255, 61, 150, 0.5)" }}
                />
              ) : (
                <div 
                  className="flex h-11 w-11 items-center justify-center rounded-lg border"
                  style={{ borderColor: "rgba(255, 61, 150, 0.5)", backgroundColor: "rgba(255, 122, 181, 0.2)" }}
                >
                  <User className="h-5 w-5 text-[#ff3d96]" />
                </div>
              )}
              
              <div className="flex flex-col gap-0.5 min-w-0">
                <h3 className="text-sm font-extrabold tracking-tight text-white drop-shadow-sm truncate">{merged.playerName}</h3>
                <div className="flex items-center gap-1.5">
                  <span 
                    className="rounded bg-black/60 border px-1.5 py-0.5 text-[9px] font-bold text-[#cfe7ff] tracking-wider"
                    style={{ borderColor: "rgba(255, 122, 181, 0.3)" }}
                  >
                    ID <span className="text-[#ff3d96] font-extrabold">{merged.playerId}</span>
                  </span>
                  <span 
                    className="inline-flex items-center gap-1 rounded border px-1.5 py-0.5 text-[9px] font-extrabold text-emerald-300"
                    style={{ backgroundColor: "rgba(16, 185, 129, 0.2)", borderColor: "rgba(16, 185, 129, 0.4)" }}
                  >
                    <Wifi className="h-2.5 w-2.5 animate-pulse text-emerald-400" /> {merged.ping}ms
                  </span>
                </div>
              </div>
            </div>

            {/* Global Stats */}
            <div className="flex flex-col gap-1.5">
              <p className="text-[9px] font-extrabold tracking-[0.2em] text-[#35c7f2] uppercase">GLOBAL STATS</p>
              <div className="grid grid-cols-2 gap-2">
                <div 
                  className="rounded-lg border bg-[#0b2c4e]/85 p-2 flex flex-col gap-0.5 shadow-sm"
                  style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                >
                  <span className="flex items-center gap-1 text-[9px] font-bold text-[#8fe4ff] uppercase">
                    <Clock className="h-3 w-3 text-[#ff3d96]" /> PLAY TIME
                  </span>
                  <span className="text-xs font-black text-white">{merged.stats.playTime}</span>
                </div>

                <div 
                  className="rounded-lg border bg-[#0b2c4e]/85 p-2 flex flex-col gap-0.5 shadow-sm"
                  style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                >
                  <span className="flex items-center gap-1 text-[9px] font-bold text-[#8fe4ff] uppercase">
                    <Sparkles className="h-3 w-3 text-[#ff3d96]" /> RANK
                  </span>
                  <span className="text-xs font-black text-white truncate">{merged.stats.rank}</span>
                </div>

                <div 
                  className="rounded-lg border bg-[#0b2c4e]/85 p-2 flex flex-col gap-0.5 shadow-sm"
                  style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                >
                  <span className="flex items-center gap-1 text-[9px] font-bold text-[#8fe4ff] uppercase">
                    <Zap className="h-3 w-3 text-[#ff3d96]" /> KILLS
                  </span>
                  <span className="text-xs font-black text-white">{merged.stats.kills}</span>
                </div>

                <div 
                  className="rounded-lg border bg-[#0b2c4e]/85 p-2 flex flex-col gap-0.5 shadow-sm"
                  style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                >
                  <span className="flex items-center gap-1 text-[9px] font-bold text-[#8fe4ff] uppercase">
                    <Activity className="h-3 w-3 text-[#ff3d96]" /> K/D
                  </span>
                  <span className="text-xs font-black text-white">{merged.stats.kd}</span>
                </div>
              </div>
            </div>

            {/* Vitals */}
            <div className="flex flex-col gap-2 rounded-xl border bg-black/40 p-2.5" style={{ borderColor: "rgba(53, 199, 242, 0.2)" }}>
              {/* Health */}
              <div className="flex flex-col gap-1">
                <div className="flex justify-between text-[9px] font-bold">
                  <span className="flex items-center gap-1 text-[#ff7ab5]">
                    <span className="h-1.5 w-1.5 rounded-full bg-[#ff3d96]" /> HEALTH
                  </span>
                  <span className="text-white font-extrabold">{merged.stats.health}%</span>
                </div>
                <div className="h-1.5 w-full overflow-hidden rounded-full bg-black/60 border border-white/10">
                  <div 
                    className="h-full rounded-full transition-all duration-500"
                    style={{ 
                      width: `${merged.stats.health}%`,
                      background: "linear-gradient(90deg, #ff3d96, #ff7ab5)",
                      boxShadow: "0 0 8px rgba(255, 61, 150, 0.6)"
                    }}
                  />
                </div>
              </div>

              {/* Armor */}
              <div className="flex flex-col gap-1">
                <div className="flex justify-between text-[9px] font-bold">
                  <span className="flex items-center gap-1 text-[#8fe4ff]">
                    <span className="h-1.5 w-1.5 rounded-full bg-[#35c7f2]" /> ARMOR
                  </span>
                  <span className="text-white font-extrabold">{merged.stats.armor}%</span>
                </div>
                <div className="h-1.5 w-full overflow-hidden rounded-full bg-black/60 border border-white/10">
                  <div 
                    className="h-full rounded-full transition-all duration-500"
                    style={{ 
                      width: `${merged.stats.armor}%`,
                      background: "linear-gradient(90deg, #38bdf8, #6366f1)",
                      boxShadow: "0 0 8px rgba(56, 189, 248, 0.6)"
                    }}
                  />
                </div>
              </div>
            </div>

            {/* Achievements */}
            <div className="flex flex-col gap-1">
              <p className="text-[9px] font-extrabold tracking-[0.2em] text-[#35c7f2] uppercase">ACHIEVEMENTS</p>
              <div 
                className="flex items-center justify-center rounded-lg border border-dashed bg-black/30 py-2"
                style={{ borderColor: "rgba(255, 122, 181, 0.25)" }}
              >
                <p className="text-[11px] font-semibold text-[#9cc3e6]">No badges yet</p>
              </div>
            </div>
          </div>

          {/* Footer branding */}
          <div 
            className="mt-3 flex items-center justify-between border-t pt-2.5 text-[9px] font-semibold text-[#8fe4ff]"
            style={{ borderTopColor: "rgba(53, 199, 242, 0.22)" }}
          >
            <span className="flex items-center gap-1">
              <Zap className="h-3 w-3 text-[#ff3d96]" /> Pandora City Scoreboard
            </span>
            <span className="pandora-display tracking-[0.18em] text-white font-extrabold hover:text-[#ff3d96] transition-colors cursor-pointer">PANDORA CITY</span>
          </div>
        </section>

        {/* PANEL 2: SERVER STATUS */}
        <section 
          className="relative flex flex-col justify-between overflow-hidden rounded-2xl border p-3.5 backdrop-blur-2xl transition-all duration-300 hover:border-[#ff3d96]/50"
          style={{
            background: "linear-gradient(180deg, rgba(10, 40, 70, 0.95), rgba(5, 25, 47, 0.98))",
            boxShadow: "0 15px 35px rgba(0, 0, 0, 0.85), 0 0 20px rgba(255, 61, 150, 0.15)",
            borderColor: "rgba(255, 61, 150, 0.28)",
            transform: "perspective(1200px) rotateY(0deg)",
            transformStyle: "preserve-3d",
            backfaceVisibility: "hidden",
          }}
        >
          {/* Grid Background Pattern */}
          <div className="panel-grid absolute inset-0 opacity-20 pointer-events-none" />

          <div className="relative z-10 flex flex-col gap-3">
            {/* Header */}
            <div 
              className="flex items-center gap-2.5 border-b pb-2.5"
              style={{ borderBottomColor: "rgba(255, 122, 181, 0.22)" }}
            >
              <div 
                className="flex h-7 w-7 items-center justify-center rounded-full border shadow-sm"
                style={{ backgroundColor: "rgba(255, 61, 150, 0.18)", borderColor: "rgba(255, 61, 150, 0.4)" }}
              >
                <span className="text-[#ff3d96] font-extrabold text-sm">S</span>
              </div>
              <div>
                <h2 className="text-[11px] font-black uppercase tracking-[0.18em] text-[#ff3d96] drop-shadow-sm">SERVER STATUS</h2>
                <p className="text-[9px] font-semibold text-[#8fe4ff]">{merged.serverName || "Pandora City"}</p>
              </div>
            </div>

            {/* Population Panel */}
            <div 
              className="flex flex-col gap-1.5 rounded-xl border p-2.5 shadow-sm"
              style={{ backgroundColor: "rgba(16, 55, 95, 0.75)", borderColor: "rgba(53, 199, 242, 0.3)" }}
            >
              <span className="text-[9px] font-extrabold uppercase tracking-widest text-[#35c7f2]">POPULATION</span>
              <div className="flex items-baseline gap-1">
                <span className="text-2xl font-black text-white drop-shadow-sm">{merged.population.current}</span>
                <span className="text-[11px] font-bold text-[#cfe7ff]">/ {merged.population.max}</span>
              </div>
              <div 
                className="h-2 w-full overflow-hidden rounded-full bg-black/60 border"
                style={{ borderColor: "rgba(53, 199, 242, 0.3)" }}
              >
                <div 
                  className="h-full rounded-full transition-all duration-500"
                  style={{ 
                    width: `${popPercentage}%`,
                    backgroundColor: "#ff3d96",
                    boxShadow: "0 0 10px rgba(255, 61, 150, 0.85)"
                  }}
                />
              </div>
            </div>

            {/* Jobs Online */}
            <div className="flex flex-col gap-1.5">
              <p className="text-[9px] font-extrabold tracking-[0.2em] text-[#35c7f2] uppercase">JOBS ONLINE</p>
              <div className="flex flex-col gap-1.5">
                {merged.jobs.map((job, idx) => (
                  <div 
                    key={idx} 
                    className="flex items-center justify-between rounded-lg border bg-[#0b2c4e]/85 px-2.5 py-1.5 shadow-sm transition-colors hover:border-[#ff3d96]/45"
                    style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                  >
                    <div className="flex items-center gap-2">
                      <div 
                        className="flex h-6 w-6 items-center justify-center rounded border text-[#ff3d96]"
                        style={{ backgroundColor: "rgba(255, 61, 150, 0.18)", borderColor: "rgba(255, 122, 181, 0.35)" }}
                      >
                        {getJobIcon(job.name)}
                      </div>
                      <span className="text-xs font-bold text-white tracking-wide">{job.name}</span>
                    </div>
                    <span className="text-xs font-black text-white">
                      {job.online} <span className="text-[9px] font-semibold text-[#8fe4ff] ml-0.5">online</span>
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Priority Status */}
            {merged.enablePriorityStatus && (
              <div className="flex flex-col gap-1.5">
                <p className="text-[9px] font-extrabold tracking-[0.2em] text-[#35c7f2] uppercase">PRIORITY STATUS</p>
                <div className="flex flex-col gap-1.5">
                  {merged.priorities.map((prio, idx) => (
                    <div 
                      key={idx} 
                      className="flex items-center justify-between rounded-lg border bg-[#0b2c4e]/85 px-2.5 py-1.5 shadow-sm"
                      style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                    >
                      <div className="flex flex-col">
                        <span className="text-xs font-bold text-white tracking-wide">{prio.name}</span>
                        <span className="text-[8px] font-bold text-[#8fe4ff] uppercase tracking-wider">VIEW ONLY</span>
                      </div>
                      {prio.status === "Safe" ? (
                        <span 
                          className="inline-flex items-center gap-1 rounded border px-2 py-0.5 text-[10px] font-extrabold text-emerald-300 shadow-sm"
                          style={{ backgroundColor: "rgba(16, 185, 129, 0.2)", borderColor: "rgba(16, 185, 129, 0.45)" }}
                        >
                          <Unlock className="h-3 w-3 text-emerald-400" /> Safe
                        </span>
                      ) : prio.status === "In Progress" ? (
                        <span 
                          className="inline-flex items-center gap-1 rounded border px-2 py-0.5 text-[10px] font-extrabold text-orange-300 shadow-sm"
                          style={{ backgroundColor: "rgba(249, 115, 22, 0.2)", borderColor: "rgba(249, 115, 22, 0.45)" }}
                        >
                          <Zap className="h-3 w-3 text-orange-400" /> In Progress
                        </span>
                      ) : typeof prio.status === "string" && prio.status.startsWith("Cooldown") ? (
                        <span 
                          className="inline-flex items-center gap-1 rounded border px-2 py-0.5 text-[10px] font-extrabold text-amber-300 shadow-sm"
                          style={{ backgroundColor: "rgba(245, 158, 11, 0.2)", borderColor: "rgba(245, 158, 11, 0.45)" }}
                        >
                          <Clock className="h-3 w-3 text-amber-400" /> {prio.status}
                        </span>
                      ) : (
                        <span 
                          className="inline-flex items-center gap-1 rounded border px-2 py-0.5 text-[10px] font-extrabold text-rose-300 shadow-sm"
                          style={{ backgroundColor: "rgba(244, 63, 94, 0.2)", borderColor: "rgba(244, 63, 94, 0.45)" }}
                        >
                          <Lock className="h-3 w-3 text-rose-400" /> Hold
                        </span>
                      )}
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Footer branding */}
          <div 
            className="mt-3 flex items-center justify-between border-t pt-2.5 text-[9px] font-semibold text-[#8fe4ff]"
            style={{ borderTopColor: "rgba(53, 199, 242, 0.22)" }}
          >
            <span className="flex items-center gap-1">
              <Sparkles className="h-3 w-3 text-[#ff3d96]" /> Active session
            </span>
            <span className="pandora-display tracking-[0.18em] text-white font-extrabold hover:text-[#ff3d96] transition-colors cursor-pointer">PANDORA CITY</span>
          </div>
        </section>

        {/* PANEL 3: CRIME STATUS */}
        <section 
          className="relative flex flex-col justify-between overflow-hidden rounded-2xl border p-3.5 backdrop-blur-2xl transition-all duration-300 hover:border-[#ff3d96]/50"
          style={{
            background: "linear-gradient(180deg, rgba(10, 40, 70, 0.95), rgba(5, 25, 47, 0.98))",
            boxShadow: "0 15px 35px rgba(0, 0, 0, 0.85), 0 0 20px rgba(255, 61, 150, 0.15)",
            borderColor: "rgba(255, 61, 150, 0.28)",
            transform: "perspective(1200px) rotateY(-5deg)",
            transformStyle: "preserve-3d",
            backfaceVisibility: "hidden",
          }}
        >
          {/* Grid Background Pattern */}
          <div className="panel-grid absolute inset-0 opacity-20 pointer-events-none" />

          <div className="relative z-10 flex flex-col gap-3">
            {/* Header */}
            <div 
              className="flex items-center gap-2.5 border-b pb-2.5"
              style={{ borderBottomColor: "rgba(255, 122, 181, 0.22)" }}
            >
              <div 
                className="flex h-7 w-7 items-center justify-center rounded-full border shadow-sm"
                style={{ backgroundColor: "rgba(255, 61, 150, 0.18)", borderColor: "rgba(255, 61, 150, 0.4)" }}
              >
                <span className="text-[#ff3d96] font-extrabold text-sm">C</span>
              </div>
              <div>
                <h2 className="text-[11px] font-black uppercase tracking-[0.18em] text-[#ff3d96] drop-shadow-sm">CRIME STATUS</h2>
                <p className="text-[9px] font-semibold text-[#8fe4ff]">Live activity</p>
              </div>
            </div>

            {/* World Events */}
            <div className="flex flex-col gap-1.5">
              <p className="text-[9px] font-extrabold tracking-[0.2em] text-[#35c7f2] uppercase">WORLD EVENTS</p>
              <div className="flex flex-col gap-1.5">
                {merged.worldEvents.map((event, idx) => (
                  <div 
                    key={idx} 
                    className="flex items-center justify-between rounded-lg border bg-[#0b2c4e]/85 px-2.5 py-1.5 shadow-sm"
                    style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                  >
                    <div className="flex flex-col gap-0.5">
                      <span className="text-xs font-bold text-white">{event.name}</span>
                      <span className="flex items-center gap-1 text-[9px] font-semibold text-[#8fe4ff]">
                        <MapPin className="h-2.5 w-2.5 text-[#ff3d96]" /> {event.location}
                      </span>
                    </div>
                    {event.status === "ACTIVE" ? (
                      <span 
                        className="inline-flex items-center rounded border px-1.5 py-0.5 text-[9px] font-black text-amber-300 tracking-wider shadow-sm"
                        style={{ backgroundColor: "rgba(245, 158, 11, 0.2)", borderColor: "rgba(245, 158, 11, 0.45)" }}
                      >
                        ACTIVE
                      </span>
                    ) : (
                      <span 
                        className="inline-flex items-center rounded border px-1.5 py-0.5 text-[9px] font-bold text-[#9cc3e6] tracking-wider"
                        style={{ backgroundColor: "rgba(0,0,0,0.4)", borderColor: "rgba(255, 122, 181, 0.25)" }}
                      >
                        INACTIVE
                      </span>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Active Robberies */}
            <div className="flex flex-col gap-1.5">
              <p className="text-[9px] font-extrabold tracking-[0.2em] text-[#35c7f2] uppercase">ACTIVE ROBBERIES</p>
              {merged.robberies.length > 0 ? (
                <div className="flex flex-col gap-1.5">
                  {merged.robberies.map((rob, idx) => (
                    <div 
                      key={idx} 
                      className="flex items-center justify-between rounded-lg border px-2.5 py-1.5 shadow-sm"
                      style={{ borderColor: "rgba(244, 63, 94, 0.3)", backgroundColor: "rgba(244, 63, 94, 0.12)" }}
                    >
                      <div className="flex flex-col gap-0.5">
                        <span className="text-xs font-bold text-rose-200">{rob.name}</span>
                        <span className="text-[9px] font-semibold text-rose-300/80">{rob.location}</span>
                      </div>
                      <span 
                        className="rounded px-2 py-0.5 text-[9px] font-black text-rose-300 border border-rose-400/40"
                        style={{ backgroundColor: "rgba(244, 63, 94, 0.2)" }}
                      >
                        {rob.timeLeft}
                      </span>
                    </div>
                  ))}
                </div>
              ) : (
                <div 
                  className="flex flex-col items-center justify-center rounded-lg border border-dashed bg-black/30 py-3"
                  style={{ borderColor: "rgba(255, 122, 181, 0.25)" }}
                >
                  <p className="text-[11px] font-semibold text-[#9cc3e6]">No active robberies</p>
                </div>
              )}
            </div>
          </div>

          {/* Footer toggling guide */}
          <div 
            className="mt-3 flex flex-col gap-2 border-t pt-2.5"
            style={{ borderTopColor: "rgba(53, 199, 242, 0.22)" }}
          >
            <div className="flex items-center justify-center gap-1 text-[9px] font-extrabold uppercase tracking-[0.18em] text-[#ff3d96] drop-shadow-sm">
              <Zap className="h-2.5 w-2.5 animate-bounce text-[#ff3d96]" /> PRESS {merged.toggleKey?.toUpperCase() || "F10"} TO TOGGLE
            </div>
            
            <div className="flex items-center justify-between text-[9px] font-semibold text-[#8fe4ff]">
              <span className="flex items-center gap-1">
                <AlertTriangle className="h-2.5 w-2.5 text-[#ff3d96]" /> Server rules apply
              </span>
              <span className="pandora-display tracking-[0.18em] text-white font-extrabold hover:text-[#ff3d96] transition-colors cursor-pointer">PANDORA CITY</span>
            </div>
          </div>
        </section>

      </div>
    </div>
  );
}
