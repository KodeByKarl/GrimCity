import React from "react";
import { 
  User, Shield, Activity, Clock, Trophy, Swords, 
  BarChart3, Heart, Lock, Unlock, Wifi, AlertTriangle, 
  Zap, Calendar, Sparkles, MapPin, Wrench 
} from "lucide-react";

interface PlayerStats {
  playTime: string;
  rank: string;
  kills: number;
  kd: string;
  health: number;
  armor: number;
}

interface JobStatus {
  name: string;
  online: number;
}

interface PriorityStatus {
  name: string;
  status: string; // Safe | Hold | Cooldown (mm:ss) | In Progress
}

interface WorldEvent {
  name: string;
  location: string;
  status: "ACTIVE" | "INACTIVE";
}

interface ActiveRobbery {
  name: string;
  location: string;
  timeLeft: string;
}

interface ScoreboardData {
  playerName: string;
  playerId: number;
  ping: number;
  avatarUrl?: string;
  stats: PlayerStats;
  population: {
    current: number;
    max: number;
  };
  jobs: JobStatus[];
  priorities: PriorityStatus[];
  worldEvents: WorldEvent[];
  robberies: ActiveRobbery[];
  toggleKey?: string;
  serverName?: string;
  enablePriorityStatus?: boolean;
}

const MOCK_DATA: ScoreboardData = {
  playerName: "Koseii Carpio",
  playerId: 1634,
  ping: 28,
  avatarUrl: "https://api.dicebear.com/7.x/adventurer/svg?seed=Koseii",
  stats: {
    playTime: "12m",
    rank: "-",
    kills: 0,
    kd: "0.00",
    health: 100,
    armor: 0,
  },
  population: {
    current: 392,
    max: 500,
  },
  jobs: [
    { name: "LS EMS", online: 9 },
    { name: "LS Police", online: 5 },
    { name: "Mechanic", online: 3 },
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
  toggleKey: "F10",
  serverName: "Pandora City",
  enablePriorityStatus: true,
};

const getJobIcon = (jobName: string) => {
  const name = jobName.toLowerCase();
  if (name.includes("police") || name.includes("sheriff")) {
    return <Shield className="h-3.5 w-3.5 text-[#ffa6ce]" />;
  }
  if (name.includes("ems") || name.includes("medical") || name.includes("ambulance")) {
    return <Activity className="h-3.5 w-3.5 text-[#ffa6ce]" />;
  }
  if (name.includes("mechanic")) {
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
    <div className="pandora animate-fade-in flex min-h-screen items-center justify-center p-6 bg-black/60 backdrop-blur-md select-none pointer-events-auto antialiased">
      {/* 3-Panel Scoreboard Grid with 3D Perspective */}
      <div 
        className="grid grid-cols-3 gap-6 max-w-6xl w-full h-[620px]"
        style={{ perspective: "1500px", transformStyle: "preserve-3d" }}
      >
        
        {/* PANEL 1: YOUR PROFILE */}
        <section 
          className="relative flex flex-col justify-between overflow-hidden rounded-3xl border p-5 backdrop-blur-2xl h-full transition-all duration-300 hover:border-[#ff3d96]/50"
          style={{
            background: "linear-gradient(180deg, rgba(10, 40, 70, 0.95), rgba(5, 25, 47, 0.98))",
            boxShadow: "0 20px 50px rgba(0, 0, 0, 0.85), 0 0 30px rgba(255, 61, 150, 0.15)",
            borderColor: "rgba(255, 61, 150, 0.28)",
            transform: "perspective(1200px) rotateY(8deg)",
            transformStyle: "preserve-3d",
            backfaceVisibility: "hidden",
          }}
        >
          {/* Grid Background Pattern */}
          <div className="panel-grid absolute inset-0 opacity-20 pointer-events-none" />
          
          <div className="relative z-10 flex flex-col gap-4">
            {/* Header */}
            <div 
              className="flex items-center gap-3 border-b pb-3"
              style={{ borderBottomColor: "rgba(255, 122, 181, 0.22)" }}
            >
              <div 
                className="flex h-8 w-8 items-center justify-center rounded-full border shadow-sm"
                style={{ backgroundColor: "rgba(255, 61, 150, 0.18)", borderColor: "rgba(255, 61, 150, 0.4)" }}
              >
                <span className="pandora-display text-[#ff3d96] font-extrabold text-base">P</span>
              </div>
              <div>
                <h2 className="text-xs font-black uppercase tracking-[0.2em] text-[#ff3d96] drop-shadow-sm">YOUR PROFILE</h2>
                <p className="text-[10px] font-medium text-[#9cc3e6]">Player card</p>
              </div>
            </div>

            {/* Profile Card */}
            <div 
              className="flex items-center gap-3.5 rounded-2xl border p-3.5"
              style={{ backgroundColor: "rgba(16, 55, 95, 0.75)", borderColor: "rgba(53, 199, 242, 0.3)" }}
            >
              {merged.avatarUrl ? (
                <img 
                  src={merged.avatarUrl} 
                  alt="avatar" 
                  className="h-14 w-14 rounded-xl border bg-black/40 object-cover shadow-sm"
                  style={{ borderColor: "rgba(255, 61, 150, 0.5)" }}
                />
              ) : (
                <div 
                  className="flex h-14 w-14 items-center justify-center rounded-xl border"
                  style={{ borderColor: "rgba(255, 61, 150, 0.5)", backgroundColor: "rgba(255, 122, 181, 0.2)" }}
                >
                  <User className="h-7 w-7 text-[#ff3d96]" />
                </div>
              )}
              
              <div className="flex flex-col gap-1">
                <h3 className="text-base font-extrabold tracking-tight text-white drop-shadow-sm">{merged.playerName}</h3>
                <div className="flex items-center gap-2">
                  <span 
                    className="rounded-lg bg-black/60 border px-2 py-0.5 text-[10px] font-bold text-[#cfe7ff] tracking-wider"
                    style={{ borderColor: "rgba(255, 122, 181, 0.3)" }}
                  >
                    ID <span className="text-[#ff3d96] font-extrabold">{merged.playerId}</span>
                  </span>
                  <span 
                    className="inline-flex items-center gap-1 rounded-lg border px-2 py-0.5 text-[10px] font-extrabold text-emerald-300"
                    style={{ backgroundColor: "rgba(16, 185, 129, 0.2)", borderColor: "rgba(16, 185, 129, 0.4)" }}
                  >
                    <Wifi className="h-3 w-3 animate-pulse text-emerald-400" /> {merged.ping}ms
                  </span>
                </div>
              </div>
            </div>

            {/* Global Stats */}
            <div className="flex flex-col gap-2">
              <p className="text-[10px] font-extrabold tracking-[0.25em] text-[#35c7f2] uppercase">GLOBAL STATS</p>
              <div className="grid grid-cols-2 gap-2.5">
                <div 
                  className="rounded-xl border bg-[#0b2c4e]/85 p-2.5 flex flex-col gap-1 shadow-sm"
                  style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                >
                  <div className="flex items-center gap-1 text-[#8fe4ff]">
                    <Clock className="h-3.5 w-3.5 text-[#ff3d96]" />
                    <span className="text-[9px] font-extrabold uppercase tracking-wider">PLAY TIME</span>
                  </div>
                  <span className="text-sm font-extrabold text-white">{merged.stats.playTime}</span>
                </div>

                <div 
                  className="rounded-xl border bg-[#0b2c4e]/85 p-2.5 flex flex-col gap-1 shadow-sm"
                  style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                >
                  <div className="flex items-center gap-1 text-[#8fe4ff]">
                    <Trophy className="h-3.5 w-3.5 text-[#ff3d96]" />
                    <span className="text-[9px] font-extrabold uppercase tracking-wider">RANK</span>
                  </div>
                  <span className="text-sm font-extrabold text-white">{merged.stats.rank}</span>
                </div>

                <div 
                  className="rounded-xl border bg-[#0b2c4e]/85 p-2.5 flex flex-col gap-1 shadow-sm"
                  style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                >
                  <div className="flex items-center gap-1 text-[#8fe4ff]">
                    <Swords className="h-3.5 w-3.5 text-[#ff3d96]" />
                    <span className="text-[9px] font-extrabold uppercase tracking-wider">KILLS</span>
                  </div>
                  <span className="text-sm font-extrabold text-white">{merged.stats.kills}</span>
                </div>

                <div 
                  className="rounded-xl border bg-[#0b2c4e]/85 p-2.5 flex flex-col gap-1 shadow-sm"
                  style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                >
                  <div className="flex items-center gap-1 text-[#8fe4ff]">
                    <BarChart3 className="h-3.5 w-3.5 text-[#ff3d96]" />
                    <span className="text-[9px] font-extrabold uppercase tracking-wider">K/D</span>
                  </div>
                  <span className="text-sm font-extrabold text-white">{merged.stats.kd}</span>
                </div>
              </div>
            </div>

            {/* Health & Armor Bars */}
            <div className="flex flex-col gap-2.5 mt-1">
              <div className="flex flex-col gap-1">
                <div className="flex justify-between text-[10px] font-extrabold text-white uppercase tracking-wider">
                  <span className="flex items-center gap-1 text-rose-400">
                    <Heart className="h-3.5 w-3.5 fill-rose-500/20" /> HEALTH
                  </span>
                  <span className="text-rose-300 font-extrabold">{merged.stats.health}%</span>
                </div>
                <div 
                  className="h-2 w-full overflow-hidden rounded-full bg-black/60 border"
                  style={{ borderColor: "rgba(244, 63, 94, 0.35)" }}
                >
                  <div 
                    className="h-full rounded-full transition-all duration-500"
                    style={{ 
                      width: `${merged.stats.health}%`,
                      background: "linear-gradient(90deg, #f43f5e, #ec4899)",
                      boxShadow: "0 0 10px rgba(244, 63, 94, 0.6)"
                    }}
                  />
                </div>
              </div>

              <div className="flex flex-col gap-1">
                <div className="flex justify-between text-[10px] font-extrabold text-white uppercase tracking-wider">
                  <span className="flex items-center gap-1 text-sky-400">
                    <Shield className="h-3.5 w-3.5 fill-sky-500/20" /> ARMOR
                  </span>
                  <span className="text-sky-300 font-extrabold">{merged.stats.armor}%</span>
                </div>
                <div 
                  className="h-2 w-full overflow-hidden rounded-full bg-black/60 border"
                  style={{ borderColor: "rgba(56, 189, 248, 0.35)" }}
                >
                  <div 
                    className="h-full rounded-full transition-all duration-500"
                    style={{ 
                      width: `${merged.stats.armor}%`,
                      background: "linear-gradient(90deg, #38bdf8, #6366f1)",
                      boxShadow: "0 0 10px rgba(56, 189, 248, 0.6)"
                    }}
                  />
                </div>
              </div>
            </div>

            {/* Achievements */}
            <div className="flex flex-col gap-1.5 mt-1">
              <p className="text-[10px] font-extrabold tracking-[0.25em] text-[#35c7f2] uppercase">ACHIEVEMENTS</p>
              <div 
                className="flex items-center justify-center rounded-xl border border-dashed bg-black/30 py-3"
                style={{ borderColor: "rgba(255, 122, 181, 0.25)" }}
              >
                <p className="text-xs font-semibold text-[#9cc3e6]">No badges yet</p>
              </div>
            </div>
          </div>

          {/* Footer branding */}
          <div 
            className="mt-4 flex items-center justify-between border-t pt-3 text-[10px] font-semibold text-[#8fe4ff]"
            style={{ borderTopColor: "rgba(53, 199, 242, 0.22)" }}
          >
            <span className="flex items-center gap-1.5">
              <Zap className="h-3 w-3 text-[#ff3d96]" /> Pandora City Scoreboard
            </span>
            <span className="pandora-display tracking-[0.2em] text-white font-extrabold hover:text-[#ff3d96] transition-colors cursor-pointer">PANDORA CITY</span>
          </div>
        </section>

        {/* PANEL 2: SERVER STATUS */}
        <section 
          className="relative flex flex-col justify-between overflow-hidden rounded-3xl border p-5 backdrop-blur-2xl h-full transition-all duration-300 hover:border-[#ff3d96]/50"
          style={{
            background: "linear-gradient(180deg, rgba(10, 40, 70, 0.95), rgba(5, 25, 47, 0.98))",
            boxShadow: "0 20px 50px rgba(0, 0, 0, 0.85), 0 0 30px rgba(255, 61, 150, 0.15)",
            borderColor: "rgba(255, 61, 150, 0.28)",
            transform: "perspective(1200px) rotateY(0deg)",
            transformStyle: "preserve-3d",
            backfaceVisibility: "hidden",
          }}
        >
          {/* Grid Background Pattern */}
          <div className="panel-grid absolute inset-0 opacity-20 pointer-events-none" />

          <div className="relative z-10 flex flex-col gap-4">
            {/* Header */}
            <div 
              className="flex items-center gap-3 border-b pb-3"
              style={{ borderBottomColor: "rgba(255, 122, 181, 0.22)" }}
            >
              <div 
                className="flex h-8 w-8 items-center justify-center rounded-full border shadow-sm"
                style={{ backgroundColor: "rgba(255, 61, 150, 0.18)", borderColor: "rgba(255, 61, 150, 0.4)" }}
              >
                <span className="text-[#ff3d96] font-extrabold text-base">S</span>
              </div>
              <div>
                <h2 className="text-xs font-black uppercase tracking-[0.2em] text-[#ff3d96] drop-shadow-sm">SERVER STATUS</h2>
                <p className="text-[10px] font-semibold text-[#8fe4ff]">{merged.serverName || "Pandora City"}</p>
              </div>
            </div>

            {/* Population Panel */}
            <div 
              className="flex flex-col gap-2 rounded-2xl border p-3.5 shadow-sm"
              style={{ backgroundColor: "rgba(16, 55, 95, 0.75)", borderColor: "rgba(53, 199, 242, 0.3)" }}
            >
              <span className="text-[10px] font-extrabold uppercase tracking-widest text-[#35c7f2]">POPULATION</span>
              <div className="flex items-baseline gap-1.5">
                <span className="text-3xl font-black text-white drop-shadow-sm">{merged.population.current}</span>
                <span className="text-xs font-bold text-[#cfe7ff]">/ {merged.population.max}</span>
              </div>
              <div 
                className="h-2.5 w-full overflow-hidden rounded-full bg-black/60 border"
                style={{ borderColor: "rgba(53, 199, 242, 0.3)" }}
              >
                <div 
                  className="h-full rounded-full transition-all duration-500"
                  style={{ 
                    width: `${popPercentage}%`,
                    backgroundColor: "#ff3d96",
                    boxShadow: "0 0 15px rgba(255, 61, 150, 0.85)"
                  }}
                />
              </div>
            </div>

            {/* Jobs Online */}
            <div className="flex flex-col gap-2">
              <p className="text-[10px] font-extrabold tracking-[0.25em] text-[#35c7f2] uppercase">JOBS ONLINE</p>
              <div className="flex flex-col gap-2">
                {merged.jobs.map((job, idx) => (
                  <div 
                    key={idx} 
                    className="flex items-center justify-between rounded-xl border bg-[#0b2c4e]/85 px-3.5 py-2 shadow-sm transition-colors hover:border-[#ff3d96]/45"
                    style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                  >
                    <div className="flex items-center gap-3">
                      <div 
                        className="flex h-7 w-7 items-center justify-center rounded-lg border text-[#ff3d96]"
                        style={{ backgroundColor: "rgba(255, 61, 150, 0.18)", borderColor: "rgba(255, 122, 181, 0.35)" }}
                      >
                        {getJobIcon(job.name)}
                      </div>
                      <span className="text-sm font-bold text-white tracking-wide">{job.name}</span>
                    </div>
                    <span className="text-sm font-black text-white">
                      {job.online} <span className="text-[10px] font-semibold text-[#8fe4ff] ml-1">online</span>
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Priority Status */}
            {merged.enablePriorityStatus && (
              <div className="flex flex-col gap-2">
                <p className="text-[10px] font-extrabold tracking-[0.25em] text-[#35c7f2] uppercase">PRIORITY STATUS</p>
                <div className="flex flex-col gap-2">
                  {merged.priorities.map((prio, idx) => (
                    <div 
                      key={idx} 
                      className="flex items-center justify-between rounded-xl border bg-[#0b2c4e]/85 px-3.5 py-2 shadow-sm"
                      style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                    >
                      <div className="flex flex-col">
                        <span className="text-sm font-bold text-white tracking-wide">{prio.name}</span>
                        <span className="text-[9px] font-bold text-[#8fe4ff] uppercase tracking-wider">VIEW ONLY</span>
                      </div>
                      {prio.status === "Safe" ? (
                        <span 
                          className="inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1 text-xs font-extrabold text-emerald-300 shadow-sm"
                          style={{ backgroundColor: "rgba(16, 185, 129, 0.2)", borderColor: "rgba(16, 185, 129, 0.45)" }}
                        >
                          <Unlock className="h-3.5 w-3.5 text-emerald-400" /> Safe
                        </span>
                      ) : prio.status === "In Progress" ? (
                        <span 
                          className="inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1 text-xs font-extrabold text-orange-300 shadow-sm"
                          style={{ backgroundColor: "rgba(249, 115, 22, 0.2)", borderColor: "rgba(249, 115, 22, 0.45)" }}
                        >
                          <Zap className="h-3.5 w-3.5 text-orange-400" /> In Progress
                        </span>
                      ) : typeof prio.status === "string" && prio.status.startsWith("Cooldown") ? (
                        <span 
                          className="inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1 text-xs font-extrabold text-amber-300 shadow-sm"
                          style={{ backgroundColor: "rgba(245, 158, 11, 0.2)", borderColor: "rgba(245, 158, 11, 0.45)" }}
                        >
                          <Clock className="h-3.5 w-3.5 text-amber-400" /> {prio.status}
                        </span>
                      ) : (
                        <span 
                          className="inline-flex items-center gap-1.5 rounded-lg border px-2.5 py-1 text-xs font-extrabold text-rose-300 shadow-sm"
                          style={{ backgroundColor: "rgba(244, 63, 94, 0.2)", borderColor: "rgba(244, 63, 94, 0.45)" }}
                        >
                          <Lock className="h-3.5 w-3.5 text-rose-400" /> Hold
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
            className="mt-4 flex items-center justify-between border-t pt-3 text-[10px] font-semibold text-[#8fe4ff]"
            style={{ borderTopColor: "rgba(53, 199, 242, 0.22)" }}
          >
            <span className="flex items-center gap-1.5">
              <Sparkles className="h-3 w-3 text-[#ff3d96]" /> Active session
            </span>
            <span className="pandora-display tracking-[0.2em] text-white font-extrabold hover:text-[#ff3d96] transition-colors cursor-pointer">PANDORA CITY</span>
          </div>
        </section>

        {/* PANEL 3: CRIME STATUS */}
        <section 
          className="relative flex flex-col justify-between overflow-hidden rounded-3xl border p-5 backdrop-blur-2xl h-full transition-all duration-300 hover:border-[#ff3d96]/50"
          style={{
            background: "linear-gradient(180deg, rgba(10, 40, 70, 0.95), rgba(5, 25, 47, 0.98))",
            boxShadow: "0 20px 50px rgba(0, 0, 0, 0.85), 0 0 30px rgba(255, 61, 150, 0.15)",
            borderColor: "rgba(255, 61, 150, 0.28)",
            transform: "perspective(1200px) rotateY(-8deg)",
            transformStyle: "preserve-3d",
            backfaceVisibility: "hidden",
          }}
        >
          {/* Grid Background Pattern */}
          <div className="panel-grid absolute inset-0 opacity-20 pointer-events-none" />

          <div className="relative z-10 flex flex-col gap-4">
            {/* Header */}
            <div 
              className="flex items-center gap-3 border-b pb-3"
              style={{ borderBottomColor: "rgba(255, 122, 181, 0.22)" }}
            >
              <div 
                className="flex h-8 w-8 items-center justify-center rounded-full border shadow-sm"
                style={{ backgroundColor: "rgba(255, 61, 150, 0.18)", borderColor: "rgba(255, 61, 150, 0.4)" }}
              >
                <span className="text-[#ff3d96] font-extrabold text-base">C</span>
              </div>
              <div>
                <h2 className="text-xs font-black uppercase tracking-[0.2em] text-[#ff3d96] drop-shadow-sm">CRIME STATUS</h2>
                <p className="text-[10px] font-semibold text-[#8fe4ff]">Live activity</p>
              </div>
            </div>

            {/* World Events */}
            <div className="flex flex-col gap-2">
              <p className="text-[10px] font-extrabold tracking-[0.25em] text-[#35c7f2] uppercase">WORLD EVENTS</p>
              <div className="flex flex-col gap-2">
                {merged.worldEvents.map((event, idx) => (
                  <div 
                    key={idx} 
                    className="flex items-center justify-between rounded-xl border bg-[#0b2c4e]/85 px-3.5 py-2 shadow-sm"
                    style={{ borderColor: "rgba(53, 199, 242, 0.25)" }}
                  >
                    <div className="flex flex-col gap-0.5">
                      <span className="text-sm font-bold text-white">{event.name}</span>
                      <span className="flex items-center gap-1 text-[10px] font-semibold text-[#8fe4ff]">
                        <MapPin className="h-3 w-3 text-[#ff3d96]" /> {event.location}
                      </span>
                    </div>
                    {event.status === "ACTIVE" ? (
                      <span 
                        className="inline-flex items-center rounded-lg border px-2 py-0.5 text-[10px] font-black text-amber-300 tracking-wider shadow-sm"
                        style={{ backgroundColor: "rgba(245, 158, 11, 0.2)", borderColor: "rgba(245, 158, 11, 0.45)" }}
                      >
                        ACTIVE
                      </span>
                    ) : (
                      <span 
                        className="inline-flex items-center rounded-lg border px-2 py-0.5 text-[10px] font-bold text-[#9cc3e6] tracking-wider"
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
            <div className="flex flex-col gap-2">
              <p className="text-[10px] font-extrabold tracking-[0.25em] text-[#35c7f2] uppercase">ACTIVE ROBBERIES</p>
              {merged.robberies.length > 0 ? (
                <div className="flex flex-col gap-2">
                  {merged.robberies.map((rob, idx) => (
                    <div 
                      key={idx} 
                      className="flex items-center justify-between rounded-xl border px-3.5 py-2 shadow-sm"
                      style={{ borderColor: "rgba(244, 63, 94, 0.3)", backgroundColor: "rgba(244, 63, 94, 0.12)" }}
                    >
                      <div className="flex flex-col gap-0.5">
                        <span className="text-sm font-bold text-rose-200">{rob.name}</span>
                        <span className="text-[10px] font-semibold text-rose-300/80">{rob.location}</span>
                      </div>
                      <span 
                        className="rounded-lg px-2.5 py-0.5 text-[10px] font-black text-rose-300 border border-rose-400/40"
                        style={{ backgroundColor: "rgba(244, 63, 94, 0.2)" }}
                      >
                        {rob.timeLeft}
                      </span>
                    </div>
                  ))}
                </div>
              ) : (
                <div 
                  className="flex flex-col items-center justify-center rounded-xl border border-dashed bg-black/30 py-5"
                  style={{ borderColor: "rgba(255, 122, 181, 0.25)" }}
                >
                  <p className="text-xs font-semibold text-[#9cc3e6]">No active robberies</p>
                </div>
              )}
            </div>
          </div>

          {/* Footer toggling guide */}
          <div 
            className="mt-4 flex flex-col gap-2.5 border-t pt-3"
            style={{ borderTopColor: "rgba(53, 199, 242, 0.22)" }}
          >
            <div className="flex items-center justify-center gap-1.5 text-[10px] font-extrabold uppercase tracking-[0.2em] text-[#ff3d96] drop-shadow-sm">
              <Zap className="h-3 w-3 animate-bounce text-[#ff3d96]" /> PRESS {merged.toggleKey?.toUpperCase() || "F10"} TO TOGGLE
            </div>
            
            <div className="flex items-center justify-between text-[10px] font-semibold text-[#8fe4ff]">
              <span className="flex items-center gap-1">
                <AlertTriangle className="h-3 w-3 text-[#ff3d96]" /> Server rules apply
              </span>
              <span className="pandora-display tracking-[0.2em] text-white font-extrabold hover:text-[#ff3d96] transition-colors cursor-pointer">PANDORA CITY</span>
            </div>
          </div>
        </section>

      </div>
    </div>
  );
}
