import React, { useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import {
  BatteryFull,
  ClipboardList,
  MapPin,
  Radio,
  Search,
  Shield,
  Signal,
  Siren,
  Users,
  Wifi,
} from "lucide-react";
import type { IpadPlayerData } from "./Ipad";

type TabId = "home" | "announce" | "units" | "bolos";

const TABS: { id: TabId; label: string }[] = [
  { id: "home", label: "Home" },
  { id: "announce", label: "Announcements" },
  { id: "units", label: "Units" },
  { id: "bolos", label: "BOLOs" },
];

const ANNOUNCEMENTS = [
  {
    id: 1,
    title: "Citywide Code 2",
    body: "Increase patrol density downtown. Report suspicious vehicles immediately.",
    author: "Karl Dev · Boss",
    time: "10m ago",
    priority: true,
  },
  {
    id: 2,
    title: "Shift Briefing",
    body: "New cadets ride with FTO only. Radio channel 1 for primary.",
    author: "Ace Walker · Boss",
    time: "2h ago",
    priority: false,
  },
  {
    id: 3,
    title: "Evidence Lockers",
    body: "Locker 3 under maintenance until Friday. Use locker 1–2 only.",
    author: "Dispatch",
    time: "Yesterday",
    priority: false,
  },
];

const UNITS = [
  { callsign: "Lincoln-1", name: "Karl Dev", status: "Available", loc: "Mission Row PD" },
  { callsign: "Adam-12", name: "Ace Walker", status: "Busy", loc: "Legion Square" },
  { callsign: "Boy-7", name: "Rico Vale", status: "Available", loc: "Vinewood Blvd" },
];

const BOLOS = [
  {
    id: 1,
    plate: "GRIM 882",
    desc: "Black Sultan RS · armed robbery suspect · last seen Sandy Shores",
    time: "25m ago",
  },
  {
    id: 2,
    plate: "UNKNOWN",
    desc: "Male, blue hoodie, left scene of 211 at LTD Grove",
    time: "1h ago",
  },
];

function StatusBar() {
  const [now, setNow] = useState(() => new Date());
  React.useEffect(() => {
    const id = window.setInterval(() => setNow(new Date()), 1000);
    return () => window.clearInterval(id);
  }, []);
  const time = now.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  return (
    <div className="relative z-40 flex items-center justify-between px-7 pt-[18px] text-[12px] font-semibold tracking-tight text-white/90">
      <span className="min-w-[54px]">{time}</span>
      <div className="flex items-center gap-1.5 opacity-90">
        <Signal className="h-3.5 w-3.5" strokeWidth={2.4} />
        <Wifi className="h-3.5 w-3.5" strokeWidth={2.4} />
        <BatteryFull className="h-4 w-4" strokeWidth={2.2} />
      </div>
    </div>
  );
}

export default function PoliceMdtApp({
  player,
}: {
  player?: IpadPlayerData | null;
}) {
  const [tab, setTab] = useState<TabId>("home");
  const [query, setQuery] = useState("");
  const name = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Officer";

  const filteredAnnounce = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return ANNOUNCEMENTS;
    return ANNOUNCEMENTS.filter(
      (a) => a.title.toLowerCase().includes(q) || a.body.toLowerCase().includes(q),
    );
  }, [query]);

  return (
    <div
      className="absolute inset-0 flex flex-col select-none"
      style={{
        background:
          "radial-gradient(ellipse at 80% 0%, rgba(30,64,175,0.25), transparent 50%), linear-gradient(180deg, #060910 0%, #0b1220 50%, #070a12 100%)",
      }}
    >
      <StatusBar />

      <div className="flex items-start justify-between gap-3 px-5 pb-2 pt-2">
        <div className="min-w-0">
          <div className="flex flex-wrap items-center gap-2">
            <ClipboardList className="h-5 w-5 text-[#93c5fd]" strokeWidth={2.2} />
            <h1 className="text-[22px] font-bold tracking-wide text-white">Police MDT</h1>
            <span className="rounded-md bg-[#1e3a8a] px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-[#bfdbfe]">
              LSPD
            </span>
          </div>
          <p className="mt-1 text-[12px] text-white/45">
            Signed in as {name} · Announcements sync from Police Boss
          </p>
        </div>
      </div>

      <div className="flex gap-2 overflow-x-auto px-5 pb-3">
        {TABS.map((t) => {
          const active = tab === t.id;
          return (
            <button
              key={t.id}
              type="button"
              className={cn(
                "shrink-0 rounded-full px-3.5 py-1.5 text-[12px] font-semibold transition-colors",
                active
                  ? "bg-[#1d4ed8] text-white"
                  : "bg-white/6 text-white/55 hover:bg-white/10",
              )}
              onClick={() => setTab(t.id)}
            >
              {t.label}
            </button>
          );
        })}
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto px-5 pb-6">
        {tab === "home" && (
          <div className="space-y-4">
            <div className="grid grid-cols-3 gap-3">
              <div className="rounded-2xl border border-white/8 bg-[#111827] p-4">
                <Users className="mb-2 h-5 w-5 text-[#60a5fa]" />
                <p className="text-[22px] font-bold text-white">{UNITS.length}</p>
                <p className="text-[12px] text-white/45">Units online</p>
              </div>
              <div className="rounded-2xl border border-white/8 bg-[#111827] p-4">
                <Siren className="mb-2 h-5 w-5 text-[#f87171]" />
                <p className="text-[22px] font-bold text-white">{BOLOS.length}</p>
                <p className="text-[12px] text-white/45">Active BOLOs</p>
              </div>
              <div className="rounded-2xl border border-white/8 bg-[#111827] p-4">
                <Radio className="mb-2 h-5 w-5 text-[#4ade80]" />
                <p className="text-[22px] font-bold text-white">CH-1</p>
                <p className="text-[12px] text-white/45">Primary radio</p>
              </div>
            </div>

            <div className="rounded-2xl border border-[#2563eb]/35 bg-[#0f172a] p-4">
              <div className="mb-2 flex items-center gap-2">
                <Shield className="h-4 w-4 text-[#60a5fa]" />
                <p className="text-[12px] font-semibold uppercase tracking-[0.12em] text-[#60a5fa]">
                  Latest boss announcement
                </p>
              </div>
              <p className="text-[17px] font-semibold text-white">{ANNOUNCEMENTS[0].title}</p>
              <p className="mt-1 text-[13px] leading-snug text-white/65">{ANNOUNCEMENTS[0].body}</p>
              <p className="mt-2 text-[11px] text-white/35">
                {ANNOUNCEMENTS[0].author} · {ANNOUNCEMENTS[0].time}
              </p>
            </div>

            <div className="rounded-2xl border border-dashed border-white/15 bg-white/[0.03] px-4 py-6 text-center">
              <MapPin className="mx-auto mb-2 h-6 w-6 text-white/30" />
              <p className="text-[14px] font-semibold text-white/70">Dispatch map</p>
              <p className="mt-1 text-[12px] text-white/35">Live calls map wires here later</p>
            </div>
          </div>
        )}

        {tab === "announce" && (
          <div className="space-y-3">
            <div className="flex items-center gap-2 rounded-xl border border-white/10 bg-[#111827] px-3 py-2.5">
              <Search className="h-4 w-4 text-white/35" />
              <input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Search announcements..."
                className="w-full bg-transparent text-[14px] text-white outline-none placeholder:text-white/30"
              />
            </div>
            {filteredAnnounce.map((a) => (
              <div
                key={a.id}
                className={cn(
                  "rounded-2xl border px-4 py-3",
                  a.priority
                    ? "border-[#2563eb]/45 bg-[#0f172a]"
                    : "border-white/8 bg-[#111827]",
                )}
              >
                <div className="flex items-baseline justify-between gap-2">
                  <p className="text-[15px] font-semibold text-white">{a.title}</p>
                  <span className="text-[11px] text-white/35">{a.time}</span>
                </div>
                <p className="mt-1 text-[13px] leading-snug text-white/60">{a.body}</p>
                <p className="mt-2 text-[11px] text-[#93c5fd]">{a.author}</p>
              </div>
            ))}
          </div>
        )}

        {tab === "units" && (
          <div className="overflow-hidden rounded-2xl border border-white/8 bg-[#111827]">
            {UNITS.map((u, i) => (
              <div
                key={u.callsign}
                className={cn(
                  "flex items-center gap-3 px-4 py-3.5",
                  i < UNITS.length - 1 && "border-b border-white/6",
                )}
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#1e3a8a] text-[11px] font-bold text-white">
                  {u.callsign.split("-")[0].slice(0, 1)}
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-[15px] font-semibold text-white">
                    {u.callsign} · {u.name}
                  </p>
                  <p className="text-[12px] text-white/40">{u.loc}</p>
                </div>
                <span
                  className={cn(
                    "rounded-full px-2.5 py-1 text-[11px] font-semibold",
                    u.status === "Available"
                      ? "bg-[#14532d]/60 text-[#4ade80]"
                      : "bg-[#713f12]/50 text-[#fbbf24]",
                  )}
                >
                  {u.status}
                </span>
              </div>
            ))}
          </div>
        )}

        {tab === "bolos" && (
          <div className="space-y-2">
            {BOLOS.map((b) => (
              <div key={b.id} className="rounded-2xl border border-[#7f1d1d]/50 bg-[#1c1010] px-4 py-3">
                <div className="flex items-baseline justify-between gap-2">
                  <p className="text-[15px] font-bold tracking-wide text-[#fca5a5]">{b.plate}</p>
                  <span className="text-[11px] text-white/35">{b.time}</span>
                </div>
                <p className="mt-1 text-[13px] leading-snug text-white/70">{b.desc}</p>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
