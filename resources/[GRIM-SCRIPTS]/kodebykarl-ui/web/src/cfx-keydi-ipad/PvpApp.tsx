import React, { useState } from "react";
import { cn } from "@/lib/utils";
import {
  BatteryFull,
  FolderOpen,
  Home,
  Plus,
  Shield,
  Signal,
  Users,
  Wifi,
  Zap,
} from "lucide-react";
import type { IpadPlayerData } from "./Ipad";

type TabId = "arena" | "normal" | "tdm";

const PUBLIC_ARENAS = [
  { id: 1, name: "Headshot Arena PvP #1", players: "5/15", tags: ["Stamina", "Headshot"], open: true },
  { id: 2, name: "Headshot Arena PvP #2", players: "2/15", tags: ["Stamina", "Headshot"], open: true },
  { id: 3, name: "Headshot Arena PvP #3", players: "0/15", tags: ["Stamina", "Headshot"], open: true },
  { id: 4, name: "Gun Game Plaza", players: "8/12", tags: ["Stamina", "All weapons"], open: true },
  { id: 5, name: "Aim Lab Circle", players: "3/10", tags: ["No stamina", "Pistols"], open: true },
  { id: 6, name: "Night Fight Pit", players: "12/12", tags: ["Stamina", "Headshot"], open: false },
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

export default function PvpApp({
  player,
}: {
  player?: IpadPlayerData | null;
}) {
  const [tab, setTab] = useState<TabId>("arena");
  const [joined, setJoined] = useState<number | null>(null);
  const [toast, setToast] = useState<string | null>(null);
  const [queue, setQueue] = useState(false);

  const flash = (msg: string) => {
    setToast(msg);
    window.setTimeout(() => setToast(null), 2000);
  };

  return (
    <div
      className="absolute inset-0 flex flex-col select-none"
      style={{
        background:
          "radial-gradient(ellipse at 70% 0%, rgba(249,115,22,0.18), transparent 48%), linear-gradient(165deg, #100a06 0%, #16100c 50%, #0c0907 100%)",
      }}
    >
      <StatusBar />

      <div className="flex items-start gap-2 px-5 pb-2 pt-2">
        <div>
          <div className="flex flex-wrap items-center gap-2">
            <Zap className="h-5 w-5 text-[#fb923c]" strokeWidth={2.2} fill="#fb923c" />
            <h1 className="text-[22px] font-bold tracking-wide text-white">PvP</h1>
          </div>
          <p className="mt-1 text-[12px] text-white/45">
            Public arenas · private lobbies · {[player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Player"}
          </p>
        </div>
      </div>

      <div className="flex gap-2 overflow-x-auto px-5 pb-3">
        {(
          [
            { id: "arena" as const, label: "Arena", icon: Zap },
            { id: "normal" as const, label: "Normal", icon: Home },
            { id: "tdm" as const, label: "Team Deathmatch", icon: Users },
          ] as const
        ).map((t) => {
          const active = tab === t.id;
          return (
            <button
              key={t.id}
              type="button"
              className={cn(
                "flex shrink-0 items-center gap-1.5 rounded-full px-3.5 py-1.5 text-[12px] font-semibold transition-colors",
                active
                  ? "border border-[#f97316] bg-[#f97316]/15 text-[#fdba74]"
                  : "bg-white/6 text-white/55 hover:bg-white/10",
              )}
              onClick={() => setTab(t.id)}
            >
              <t.icon className="h-3.5 w-3.5" strokeWidth={2.4} />
              {t.label}
            </button>
          );
        })}
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto px-5 pb-6">
        {tab === "arena" && (
          <div className="space-y-5">
            <div>
              <p className="mb-3 text-[11px] font-semibold uppercase tracking-[0.16em] text-white/40">
                Public arenas
              </p>
              <div className="grid grid-cols-3 gap-3">
                {PUBLIC_ARENAS.map((a) => {
                  const isJoined = joined === a.id;
                  return (
                    <div
                      key={a.id}
                      className="flex flex-col rounded-2xl border border-white/8 bg-[#1c1917] p-3.5 shadow-md"
                    >
                      <div className="mb-2 flex items-start justify-between gap-2">
                        <p className="text-[14px] font-semibold leading-snug text-white">{a.name}</p>
                        <span
                          className={cn(
                            "shrink-0 rounded-md px-1.5 py-0.5 text-[10px] font-bold uppercase",
                            a.open ? "bg-[#14532d] text-[#4ade80]" : "bg-[#7f1d1d] text-[#fca5a5]",
                          )}
                        >
                          {a.open ? "Open" : "Full"}
                        </span>
                      </div>
                      <div className="mb-2 flex items-center gap-1 text-[12px] text-white/45">
                        <Users className="h-3.5 w-3.5" />
                        {a.players}
                      </div>
                      <div className="mb-3 flex flex-wrap gap-1.5">
                        {a.tags.map((tag) => (
                          <span
                            key={tag}
                            className="inline-flex items-center gap-1 rounded-full bg-white/6 px-2 py-0.5 text-[10px] font-medium text-white/60"
                          >
                            {tag === "Headshot" ? (
                              <Shield className="h-2.5 w-2.5" />
                            ) : (
                              <Zap className="h-2.5 w-2.5" />
                            )}
                            {tag}
                          </span>
                        ))}
                      </div>
                      <button
                        type="button"
                        disabled={!a.open && !isJoined}
                        className={cn(
                          "mt-auto w-full rounded-xl py-2 text-[13px] font-bold transition-colors",
                          isJoined
                            ? "bg-white/10 text-white"
                            : "bg-[#f97316] text-white hover:bg-[#ea580c] disabled:opacity-40",
                        )}
                        onClick={() => {
                          if (isJoined) {
                            setJoined(null);
                            flash("Left arena");
                          } else {
                            setJoined(a.id);
                            flash(`Joined ${a.name}`);
                          }
                        }}
                      >
                        {isJoined ? "Leave" : "Join"}
                      </button>
                    </div>
                  );
                })}
              </div>
            </div>

            <div>
              <div className="mb-3 flex items-center justify-between">
                <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-white/40">
                  Private arenas
                </p>
                <button
                  type="button"
                  className="inline-flex items-center gap-1 rounded-full border border-[#f97316]/50 px-3 py-1 text-[11px] font-bold text-[#fdba74]"
                  onClick={() => flash("Create private arena (preview)")}
                >
                  <Plus className="h-3 w-3" />
                  Create
                </button>
              </div>
              <div className="flex flex-col items-center justify-center rounded-2xl border border-dashed border-white/15 bg-white/[0.02] px-6 py-10 text-center">
                <FolderOpen className="mb-2 h-8 w-8 text-white/25" />
                <p className="text-[16px] font-bold text-white">Oh snap!</p>
                <p className="mt-1 text-[13px] text-white/40">
                  No private arenas right now. Create one above.
                </p>
              </div>
            </div>
          </div>
        )}

        {tab === "normal" && (
          <div className="mx-auto max-w-[440px] rounded-2xl border border-white/8 bg-[#1c1917] px-6 py-10 text-center">
            <Home className="mx-auto mb-3 h-8 w-8 text-[#fb923c]" />
            <h2 className="text-[20px] font-bold text-white">1v1 Queue</h2>
            <p className="mt-2 text-[13px] text-white/50">
              Match against a random opponent. Bucket + spawn wires live later.
            </p>
            <button
              type="button"
              className={cn(
                "mt-5 rounded-full px-6 py-2.5 text-[13px] font-bold text-white",
                queue ? "bg-white/15" : "bg-[#f97316]",
              )}
              onClick={() => {
                setQueue((q) => !q);
                flash(queue ? "Left queue" : "Searching for opponent…");
              }}
            >
              {queue ? "Cancel search" : "Find match"}
            </button>
          </div>
        )}

        {tab === "tdm" && (
          <div className="mx-auto max-w-[480px] space-y-3">
            <p className="text-center text-[13px] text-white/45">Pick a side · 4v4 Team Deathmatch</p>
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                className="rounded-2xl border border-[#2563eb]/40 bg-[#0f172a] px-4 py-8 text-center transition-transform active:scale-[0.98]"
                onClick={() => flash("Joined Blue team (preview)")}
              >
                <Users className="mx-auto mb-2 h-7 w-7 text-[#60a5fa]" />
                <p className="text-[16px] font-bold text-white">Blue</p>
                <p className="mt-1 text-[12px] text-white/40">2 / 4 slots</p>
              </button>
              <button
                type="button"
                className="rounded-2xl border border-[#dc2626]/40 bg-[#1c1010] px-4 py-8 text-center transition-transform active:scale-[0.98]"
                onClick={() => flash("Joined Red team (preview)")}
              >
                <Users className="mx-auto mb-2 h-7 w-7 text-[#f87171]" />
                <p className="text-[16px] font-bold text-white">Red</p>
                <p className="mt-1 text-[12px] text-white/40">3 / 4 slots</p>
              </button>
            </div>
          </div>
        )}
      </div>

      {toast ? (
        <div className="pointer-events-none absolute bottom-8 left-1/2 z-50 -translate-x-1/2 rounded-full bg-[#c2410c] px-4 py-2 text-[13px] font-semibold text-white shadow-lg">
          {toast}
        </div>
      ) : null}
    </div>
  );
}
