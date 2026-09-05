import type { CSSProperties, ReactNode } from "react";
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
  Zap,
} from "lucide-react";

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
  timeLeft?: string;
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
  serverName: "Grim City",
  enablePriorityStatus: true,
  playerName: "Player",
  playerId: 1,
  ping: 13,
  stats: {
    playTime: "0m",
    rank: "Student (Freshman)",
    kills: 0,
    kd: "0.00",
    health: 100,
    armor: 0,
  },
  population: {
    current: 1,
    max: 128,
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
    { name: "Airdrop", location: "—", status: "INACTIVE", timeLeft: "45:00" },
    { name: "Traphouse", location: "Mirror Park TrapHouse", status: "ACTIVE", timeLeft: "12:30" },
    { name: "Turf Wars", location: "—", status: "INACTIVE", timeLeft: "28:00" },
  ],
  robberies: [],
};

const getJobIcon = (name: string) => {
  const lower = name.toLowerCase();
  if (lower.includes("ems") || lower.includes("medical") || lower.includes("ambulance")) {
    return <Activity className="h-3.5 w-3.5 text-[#ff8080]" />;
  }
  if (lower.includes("mechanic")) {
    return <Wrench className="h-3.5 w-3.5 text-[#ff8080]" />;
  }
  return <Shield className="h-3.5 w-3.5 text-[#ff8080]" />;
};

function PanelShell({
  transform,
  header,
  footer,
  children,
  heightClass = "h-[min(520px,76vh)]",
}: {
  transform: string;
  header: ReactNode;
  footer: ReactNode;
  children: ReactNode;
  heightClass?: string;
}) {
  const panelBase: CSSProperties = {
    backgroundColor: "rgba(14, 12, 16, 0.97)",
    borderColor: "rgba(255, 58, 58, 0.85)",
    boxShadow: "0 14px 40px rgba(0, 0, 0, 0.88), 0 0 22px rgba(255, 58, 58, 0.1)",
    transform,
    transformStyle: "preserve-3d",
    backfaceVisibility: "hidden",
  };

  return (
    <section
      className={`relative flex min-h-0 flex-col overflow-hidden rounded-2xl border-2 ${heightClass}`}
      style={panelBase}
    >
      <div className="pointer-events-none absolute inset-0 opacity-20 panel-grid" />

      {/* Header — fixed */}
      <div className="relative z-20 shrink-0 border-b border-[#ff3a3a]/35 px-4 pb-2.5 pt-3.5">
        {header}
      </div>

      {/* Body — scrolls inside panel, never under footer */}
      <div className="relative z-10 min-h-0 flex-1 space-y-3 overflow-y-auto overflow-x-hidden px-4 py-3 custom-scrollbar">
        {children}
      </div>

      {/* Footer — solid bar so content cannot overlap */}
      <div
        className="relative z-20 shrink-0 border-t border-[#ff3a3a]/35 px-4 py-2.5 text-[10px] text-[#8a8086]"
        style={{ backgroundColor: "rgba(10, 8, 10, 0.98)" }}
      >
        {footer}
      </div>
    </section>
  );
}

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

  const popPercentage = Math.min((merged.population.current / Math.max(1, merged.population.max)) * 100, 100);
  const brand = merged.serverName || "Grim City";

  return (
    <div className="pointer-events-auto fixed inset-0 z-[99930] flex items-center justify-center bg-transparent px-4 py-5 font-sans select-none">
      {/* Per-panel heights — Profile & Crime taller first; Server Status next */}
      <div
        className="grid w-full max-w-[1120px] grid-cols-3 items-center gap-4"
        style={{ perspective: "1600px", transformStyle: "preserve-3d" }}
      >
        {/* PANEL 1 — YOUR PROFILE */}
        <PanelShell
          heightClass="h-[min(600px,84vh)]"
          transform="perspective(1600px) rotateY(9deg)"
          header={
            <div className="flex items-center gap-2.5">
              <div
                className="flex h-9 w-9 items-center justify-center rounded-full border border-[#ff3a3a]/60"
                style={{ backgroundColor: "rgba(255, 58, 58, 0.2)" }}
              >
                <span className="text-base font-black text-[#ff3a3a]">G</span>
              </div>
              <div>
                <h2 className="text-[18px] font-black uppercase leading-none tracking-wide text-white">
                  Your Profile
                </h2>
                <p className="mt-1 text-[9px] font-bold uppercase tracking-[0.2em] text-[#ff3a3a]">
                  Player card
                </p>
              </div>
            </div>
          }
          footer={
            <div className="flex items-center justify-between">
              <span className="inline-flex items-center gap-1.5">
                <Zap className="h-3.5 w-3.5 text-[#ff4d4d]" /> Scoreboard
              </span>
              <span className="font-black uppercase tracking-[0.16em] text-white/80">{brand}</span>
            </div>
          }
        >
          <div
            className="flex items-center gap-3 rounded-xl border border-[#ff3a3a]/45 px-3 py-2.5"
            style={{ backgroundColor: "rgba(8, 8, 10, 0.95)" }}
          >
            {merged.avatarUrl ? (
              <img
                src={merged.avatarUrl}
                alt="avatar"
                className="h-12 w-12 rounded-xl border border-[#ff3a3a]/50 object-cover"
              />
            ) : (
              <div
                className="flex h-12 w-12 items-center justify-center rounded-xl border border-[#ff3a3a]/50"
                style={{ backgroundColor: "rgba(255, 58, 58, 0.18)" }}
              >
                <User className="h-6 w-6 text-[#ff8080]" />
              </div>
            )}
            <div className="min-w-0 flex-1">
              <h3 className="truncate text-[15px] font-black uppercase tracking-wide text-white">
                {merged.playerName}
              </h3>
              <div className="mt-1 flex flex-wrap items-center gap-1.5">
                <span
                  className="rounded-md border border-[#ff3a3a]/50 px-1.5 py-0.5 text-[9px] font-black text-[#ffb0b0]"
                  style={{ backgroundColor: "rgba(255, 58, 58, 0.22)" }}
                >
                  ID {merged.playerId}
                </span>
                <span
                  className="inline-flex items-center gap-1 rounded-md border border-emerald-500/40 px-1.5 py-0.5 text-[9px] font-black text-emerald-300"
                  style={{ backgroundColor: "rgba(16, 185, 129, 0.18)" }}
                >
                  <Wifi className="h-2.5 w-2.5" /> {merged.ping}ms
                </span>
              </div>
            </div>
          </div>

          <div>
            <p className="mb-1.5 text-[9px] font-bold uppercase tracking-[0.18em] text-[#ff4d4d]">
              Global Stats
            </p>
            <div className="grid grid-cols-2 gap-2">
              {[
                { icon: Clock, label: "Play Time", value: merged.stats.playTime },
                { icon: Sparkles, label: "Rank", value: merged.stats.rank },
                { icon: Zap, label: "Kills", value: merged.stats.kills },
                { icon: Activity, label: "K/D", value: merged.stats.kd },
              ].map((stat) => (
                <div
                  key={stat.label}
                  className="rounded-xl border border-[#ff3a3a]/40 px-2.5 py-2"
                  style={{ backgroundColor: "rgba(10, 10, 12, 0.96)" }}
                >
                  <span className="flex items-center gap-1 text-[8px] font-bold uppercase tracking-[0.14em] text-[#ff4d4d]">
                    <stat.icon className="h-3 w-3" /> {stat.label}
                  </span>
                  <p className="mt-0.5 truncate text-[13px] font-black uppercase tracking-wide text-white">
                    {stat.value}
                  </p>
                </div>
              ))}
            </div>
          </div>

          <div
            className="space-y-2.5 rounded-xl border border-[#ff3a3a]/40 px-3 py-2.5"
            style={{ backgroundColor: "rgba(8, 8, 10, 0.95)" }}
          >
            <div>
              <div className="mb-1 flex justify-between text-[9px] font-bold">
                <span className="uppercase tracking-wider text-[#ff7ab5]">Health</span>
                <span className="text-white">{merged.stats.health}%</span>
              </div>
              <div className="h-2 overflow-hidden rounded-full" style={{ backgroundColor: "rgba(255,255,255,0.1)" }}>
                <div
                  className="h-full rounded-full"
                  style={{
                    width: `${merged.stats.health}%`,
                    background: "linear-gradient(90deg, #ff3a3a, #ff8080)",
                  }}
                />
              </div>
            </div>
            <div>
              <div className="mb-1 flex justify-between text-[9px] font-bold">
                <span className="uppercase tracking-wider text-[#c8c0c4]">Armor</span>
                <span className="text-white">{merged.stats.armor}%</span>
              </div>
              <div className="h-2 overflow-hidden rounded-full" style={{ backgroundColor: "rgba(255,255,255,0.1)" }}>
                <div
                  className="h-full rounded-full"
                  style={{
                    width: `${merged.stats.armor}%`,
                    background: "linear-gradient(90deg, #94a3b8, #e2e8f0)",
                  }}
                />
              </div>
            </div>
          </div>

          <div>
            <p className="mb-1.5 text-[9px] font-bold uppercase tracking-[0.18em] text-[#ff4d4d]">
              Achievements
            </p>
            <div
              className="rounded-xl border border-dashed border-white/25 px-3 py-3 text-center text-[11px] text-[#8a8086]"
              style={{ backgroundColor: "rgba(8, 8, 10, 0.9)" }}
            >
              No badges yet
            </div>
          </div>
        </PanelShell>

        {/* PANEL 2 — SERVER STATUS (same height as sides — no inner scroll) */}
        <PanelShell
          heightClass="h-[min(600px,84vh)]"
          transform="perspective(1600px) rotateY(0deg)"
          header={
            <div className="flex items-center gap-2.5">
              <div
                className="flex h-9 w-9 items-center justify-center rounded-full border border-[#ff3a3a]/60"
                style={{ backgroundColor: "rgba(255, 58, 58, 0.2)" }}
              >
                <span className="text-base font-black text-[#ff3a3a]">S</span>
              </div>
              <div>
                <h2 className="text-[18px] font-black uppercase leading-none tracking-wide text-white">
                  Server Status
                </h2>
                <p className="mt-1 text-[9px] font-bold uppercase tracking-[0.2em] text-[#ff3a3a]">
                  {brand}
                </p>
              </div>
            </div>
          }
          footer={
            <div className="flex items-center justify-between">
              <span className="inline-flex items-center gap-1.5">
                <Sparkles className="h-3.5 w-3.5 text-[#ff4d4d]" /> Live session
              </span>
              <span className="font-black uppercase tracking-[0.16em] text-white/80">{brand}</span>
            </div>
          }
        >
          <div
            className="rounded-xl border border-[#ff3a3a]/45 px-3 py-2.5"
            style={{ backgroundColor: "rgba(8, 8, 10, 0.95)" }}
          >
            <span className="text-[9px] font-bold uppercase tracking-[0.18em] text-[#ff4d4d]">
              Population
            </span>
            <div className="mt-1 flex items-baseline gap-1.5">
              <span className="text-[28px] font-black leading-none text-white">
                {merged.population.current}
              </span>
              <span className="text-[13px] font-bold text-[#8a8086]">/ {merged.population.max}</span>
            </div>
            <div
              className="mt-2.5 h-2.5 overflow-hidden rounded-full border border-white/10"
              style={{ backgroundColor: "rgba(0,0,0,0.55)" }}
            >
              <div
                className="h-full rounded-full"
                style={{
                  width: `${popPercentage}%`,
                  backgroundColor: "#ff3a3a",
                  boxShadow: "0 0 12px rgba(255, 58, 58, 0.7)",
                }}
              />
            </div>
          </div>

          <div>
            <p className="mb-1.5 text-[9px] font-bold uppercase tracking-[0.18em] text-[#ff4d4d]">
              Jobs Online
            </p>
            <div className="flex flex-col gap-1.5">
              {merged.jobs.map((job, idx) => (
                <div
                  key={idx}
                  className="flex items-center justify-between rounded-xl border border-[#ff3a3a]/35 px-2.5 py-2"
                  style={{ backgroundColor: "rgba(10, 10, 12, 0.96)" }}
                >
                  <div className="flex items-center gap-2">
                    <div
                      className="flex h-8 w-8 items-center justify-center rounded-lg border border-[#ff3a3a]/45"
                      style={{ backgroundColor: "rgba(255, 58, 58, 0.16)" }}
                    >
                      {getJobIcon(job.name)}
                    </div>
                    <span className="text-[12px] font-bold text-white">{job.name}</span>
                  </div>
                  <span className="text-[13px] font-black text-white">
                    {job.online}{" "}
                    <span className="text-[9px] font-semibold text-[#8a8086]">online</span>
                  </span>
                </div>
              ))}
            </div>
          </div>

          {merged.enablePriorityStatus && (
            <div>
              <p className="mb-1.5 text-[9px] font-bold uppercase tracking-[0.18em] text-[#ff4d4d]">
                Priority Status
              </p>
              <div className="flex flex-col gap-1.5">
                {merged.priorities.map((prio, idx) => (
                  <div
                    key={idx}
                    className="flex items-center justify-between rounded-xl border border-[#ff3a3a]/35 px-2.5 py-2"
                    style={{ backgroundColor: "rgba(10, 10, 12, 0.96)" }}
                  >
                    <div>
                      <span className="block text-[12px] font-bold text-white">{prio.name}</span>
                      <span className="text-[8px] font-bold uppercase tracking-wider text-[#8a8086]">
                        View only
                      </span>
                    </div>
                    {prio.status === "Safe" ? (
                      <span
                        className="inline-flex items-center gap-1 rounded-md border border-emerald-500/45 px-2 py-0.5 text-[10px] font-black text-emerald-300"
                        style={{ backgroundColor: "rgba(16, 185, 129, 0.18)" }}
                      >
                        <Unlock className="h-3 w-3" /> Safe
                      </span>
                    ) : prio.status === "In Progress" ? (
                      <span
                        className="inline-flex items-center gap-1 rounded-md border border-orange-500/45 px-2 py-0.5 text-[10px] font-black text-orange-300"
                        style={{ backgroundColor: "rgba(249, 115, 22, 0.18)" }}
                      >
                        <Zap className="h-3 w-3" /> In Progress
                      </span>
                    ) : typeof prio.status === "string" && prio.status.startsWith("Cooldown") ? (
                      <span
                        className="inline-flex items-center gap-1 rounded-md border border-amber-500/45 px-2 py-0.5 text-[10px] font-black text-amber-300"
                        style={{ backgroundColor: "rgba(245, 158, 11, 0.18)" }}
                      >
                        <Clock className="h-3 w-3" /> {prio.status}
                      </span>
                    ) : (
                      <span
                        className="inline-flex items-center gap-1 rounded-md border border-rose-500/45 px-2 py-0.5 text-[10px] font-black text-rose-300"
                        style={{ backgroundColor: "rgba(244, 63, 94, 0.18)" }}
                      >
                        <Lock className="h-3 w-3" /> Hold
                      </span>
                    )}
                  </div>
                ))}
              </div>
            </div>
          )}
        </PanelShell>

        {/* PANEL 3 — CRIME STATUS */}
        <PanelShell
          heightClass="h-[min(600px,84vh)]"
          transform="perspective(1600px) rotateY(-9deg)"
          header={
            <div className="flex items-center gap-2.5">
              <div
                className="flex h-9 w-9 items-center justify-center rounded-full border border-[#ff3a3a]/60"
                style={{ backgroundColor: "rgba(255, 58, 58, 0.2)" }}
              >
                <span className="text-base font-black text-[#ff3a3a]">C</span>
              </div>
              <div>
                <h2 className="text-[18px] font-black uppercase leading-none tracking-wide text-white">
                  Crime Status
                </h2>
                <p className="mt-1 text-[9px] font-bold uppercase tracking-[0.2em] text-[#ff3a3a]">
                  Live activity
                </p>
              </div>
            </div>
          }
          footer={
            <div className="flex flex-col gap-1.5">
              <div className="flex items-center justify-center gap-1.5 text-[10px] font-black uppercase tracking-[0.16em] text-[#ff3a3a]">
                <Zap className="h-3 w-3 animate-bounce" />
                Press {merged.toggleKey?.toUpperCase() || "F10"} to toggle
              </div>
              <div className="flex items-center justify-between">
                <span className="inline-flex items-center gap-1.5">
                  <AlertTriangle className="h-3.5 w-3.5 text-[#ff4d4d]" /> Server rules apply
                </span>
                <span className="font-black uppercase tracking-[0.16em] text-white/80">{brand}</span>
              </div>
            </div>
          }
        >
          <div>
            <p className="mb-1.5 text-[9px] font-bold uppercase tracking-[0.18em] text-[#ff4d4d]">
              World Events
            </p>
            <div className="flex flex-col gap-1.5">
              {merged.worldEvents.map((event, idx) => (
                <div
                  key={idx}
                  className="flex items-center justify-between rounded-xl border border-[#ff3a3a]/35 px-2.5 py-2"
                  style={{ backgroundColor: "rgba(10, 10, 12, 0.96)" }}
                >
                  <div>
                    <span className="block text-[12px] font-bold text-white">{event.name}</span>
                    <span className="mt-0.5 flex items-center gap-1 text-[10px] font-semibold text-[#8a8086]">
                      {event.status === "ACTIVE" ? (
                        <>
                          <MapPin className="h-2.5 w-2.5 text-[#ff4d4d]" /> {event.location}
                        </>
                      ) : (
                        <>
                          <Clock className="h-2.5 w-2.5 text-[#ff4d4d]" />{" "}
                          {event.timeLeft || event.location || "Waiting"}
                        </>
                      )}
                    </span>
                  </div>
                  {event.status === "ACTIVE" ? (
                    <span
                      className="rounded-md border border-amber-500/45 px-1.5 py-0.5 text-[9px] font-black tracking-wider text-amber-300"
                      style={{ backgroundColor: "rgba(245, 158, 11, 0.18)" }}
                    >
                      ACTIVE
                    </span>
                  ) : (
                    <span
                      className="rounded-md border border-white/20 px-1.5 py-0.5 text-[9px] font-bold tracking-wider text-[#8a8086]"
                      style={{ backgroundColor: "rgba(0,0,0,0.45)" }}
                    >
                      INACTIVE
                    </span>
                  )}
                </div>
              ))}
            </div>
          </div>

          <div>
            <p className="mb-1.5 text-[9px] font-bold uppercase tracking-[0.18em] text-[#ff4d4d]">
              Active Robberies
            </p>
            {merged.robberies.length > 0 ? (
              <div className="flex flex-col gap-1.5">
                {merged.robberies.map((rob, idx) => (
                  <div
                    key={idx}
                    className="flex items-center justify-between rounded-xl border border-rose-500/40 px-2.5 py-2"
                    style={{ backgroundColor: "rgba(244, 63, 94, 0.12)" }}
                  >
                    <div>
                      <span className="block text-[12px] font-bold text-rose-200">{rob.name}</span>
                      <span className="text-[10px] font-semibold text-rose-300/80">{rob.location}</span>
                    </div>
                    <span
                      className="rounded-md border border-rose-400/40 px-1.5 py-0.5 text-[10px] font-black text-rose-300"
                      style={{ backgroundColor: "rgba(244, 63, 94, 0.2)" }}
                    >
                      {rob.timeLeft}
                    </span>
                  </div>
                ))}
              </div>
            ) : (
              <div
                className="rounded-xl border border-dashed border-white/25 px-3 py-4 text-center text-[11px] text-[#8a8086]"
                style={{ backgroundColor: "rgba(8, 8, 10, 0.9)" }}
              >
                No active robberies
              </div>
            )}
          </div>
        </PanelShell>
      </div>
    </div>
  );
}
