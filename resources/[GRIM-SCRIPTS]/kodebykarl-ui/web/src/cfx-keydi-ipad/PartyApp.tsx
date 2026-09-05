import React, { useState } from "react";
import { cn } from "@/lib/utils";
import {
  BatteryFull,
  MapPin,
  Plus,
  Signal,
  Users,
  Wifi,
} from "lucide-react";
import type { IpadPlayerData } from "./Ipad";

type TabId = "party" | "robberies";

const ROBBERIES = [
  { id: "fleeca", name: "Fleeca Bank", need: "4 players", difficulty: "Medium", status: "Available" },
  { id: "store", name: "24/7 Store", need: "2 players", difficulty: "Easy", status: "Available" },
  { id: "jewelry", name: "Vangelico", need: "5 players", difficulty: "Hard", status: "Party required" },
  { id: "pacific", name: "Pacific Standard", need: "6 players", difficulty: "Extreme", status: "Locked" },
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

export default function PartyApp({
  player,
}: {
  player?: IpadPlayerData | null;
}) {
  const [tab, setTab] = useState<TabId>("party");
  const [hasParty, setHasParty] = useState(false);
  const [invites] = useState(0);
  const [inviteId, setInviteId] = useState("");
  const [members, setMembers] = useState<{ id: number; name: string; leader?: boolean }[]>([]);
  const [toast, setToast] = useState<string | null>(null);

  const you = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "You";

  const flash = (msg: string) => {
    setToast(msg);
    window.setTimeout(() => setToast(null), 2000);
  };

  const createParty = () => {
    setHasParty(true);
    setMembers([{ id: 1, name: you, leader: true }]);
    flash("Party created");
  };

  const invitePlayer = () => {
    const id = inviteId.trim();
    if (!id) return;
    setMembers((m) => [...m, { id: Date.now(), name: `Player #${id}` }]);
    setInviteId("");
    flash(`Invite sent to ID ${id}`);
  };

  const leaveParty = () => {
    setHasParty(false);
    setMembers([]);
    flash("Left party");
  };

  return (
    <div
      className="absolute inset-0 flex flex-col select-none"
      style={{
        background:
          "radial-gradient(ellipse at 30% 0%, rgba(45,212,191,0.16), transparent 50%), linear-gradient(165deg, #071210 0%, #0a1614 50%, #060d0c 100%)",
      }}
    >
      <StatusBar />

      <div className="flex items-start justify-between gap-3 px-5 pb-2 pt-2">
        <div className="min-w-0">
          <div className="flex flex-wrap items-center gap-2">
            <Users className="h-5 w-5 text-[#5eead4]" strokeWidth={2.2} />
            <h1 className="text-[22px] font-bold tracking-wide text-white">Party</h1>
          </div>
          <p className="mt-1 text-[12px] text-white/45">Squad up for crime · invite by server ID</p>
        </div>
        <button
          type="button"
          className="shrink-0 rounded-full border border-[#2dd4bf]/45 px-3 py-1.5 text-[12px] font-semibold text-[#5eead4]"
        >
          {invites} invites
        </button>
      </div>

      <div className="flex gap-2 px-5 pb-3">
        {(
          [
            { id: "party" as const, label: "Party", icon: Users },
            { id: "robberies" as const, label: "Robberies", icon: MapPin },
          ] as const
        ).map((t) => {
          const active = tab === t.id;
          return (
            <button
              key={t.id}
              type="button"
              className={cn(
                "flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-[12px] font-semibold transition-colors",
                active
                  ? "bg-[#14b8a6] text-white shadow-[0_4px_16px_rgba(20,184,166,0.35)]"
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
        {tab === "party" && (
          <div className="space-y-4">
            <div className="rounded-2xl border border-[#2dd4bf]/35 bg-[#0c1f1c] px-5 py-4">
              <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[#5eead4]">
                Squad up
              </p>
              <p className="mt-1 text-[22px] font-bold text-[#99f6e4]">
                {hasParty ? `${members.length} in party` : "No active party"}
              </p>
              <p className="mt-1 text-[13px] text-white/45">
                Create a squad, invite players by server ID, and stay grouped for crime activities.
              </p>
            </div>

            {!hasParty ? (
              <div className="mx-auto max-w-[420px] rounded-2xl border border-white/10 bg-[#111827]/80 px-6 py-8 text-center shadow-xl">
                <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-[#134e4a] text-[#5eead4]">
                  <Users className="h-7 w-7" strokeWidth={2} />
                </div>
                <h2 className="text-[20px] font-bold text-white">Start a party</h2>
                <p className="mt-2 text-[13px] leading-snug text-white/50">
                  Launch your own squad and send invites from the leader panel once created.
                </p>
                <button
                  type="button"
                  className="mt-5 inline-flex items-center gap-1.5 rounded-full border border-[#2dd4bf]/55 px-5 py-2.5 text-[13px] font-bold text-white transition-colors hover:bg-[#14b8a6]/20"
                  onClick={createParty}
                >
                  <Plus className="h-4 w-4" />
                  Create Party
                </button>
              </div>
            ) : (
              <div className="space-y-3">
                <div className="overflow-hidden rounded-2xl border border-white/8 bg-[#111827]">
                  {members.map((m, i) => (
                    <div
                      key={m.id}
                      className={cn(
                        "flex items-center gap-3 px-4 py-3",
                        i < members.length - 1 && "border-b border-white/6",
                      )}
                    >
                      <div className="flex h-9 w-9 items-center justify-center rounded-full bg-[#134e4a] text-[12px] font-bold text-[#5eead4]">
                        {m.name.slice(0, 1)}
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="truncate text-[15px] font-semibold text-white">{m.name}</p>
                        <p className="text-[12px] text-white/40">{m.leader ? "Leader" : "Member"}</p>
                      </div>
                    </div>
                  ))}
                </div>

                <div className="flex flex-wrap gap-2 rounded-2xl border border-white/8 bg-[#111827] p-3">
                  <input
                    value={inviteId}
                    onChange={(e) => setInviteId(e.target.value)}
                    placeholder="Server ID to invite"
                    className="min-w-[140px] flex-1 rounded-xl border border-white/10 bg-black/35 px-3 py-2.5 text-[14px] text-white outline-none placeholder:text-white/30"
                  />
                  <button
                    type="button"
                    className="rounded-full bg-[#14b8a6] px-4 py-2.5 text-[12px] font-bold uppercase text-white"
                    onClick={invitePlayer}
                  >
                    Invite
                  </button>
                  <button
                    type="button"
                    className="rounded-full bg-white/8 px-4 py-2.5 text-[12px] font-bold uppercase text-white/70"
                    onClick={leaveParty}
                  >
                    Leave
                  </button>
                </div>
              </div>
            )}
          </div>
        )}

        {tab === "robberies" && (
          <div className="space-y-2">
            <p className="mb-2 text-[12px] font-semibold uppercase tracking-[0.14em] text-white/40">
              Available jobs
            </p>
            {ROBBERIES.map((r) => (
              <div
                key={r.id}
                className="flex items-center gap-3 rounded-2xl border border-white/8 bg-[#111827] px-4 py-3.5"
              >
                <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#134e4a] text-[#5eead4]">
                  <MapPin className="h-5 w-5" />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-[15px] font-semibold text-white">{r.name}</p>
                  <p className="text-[12px] text-white/40">
                    {r.need} · {r.difficulty}
                  </p>
                </div>
                <span
                  className={cn(
                    "rounded-full px-2.5 py-1 text-[11px] font-semibold",
                    r.status === "Available"
                      ? "bg-[#14532d]/50 text-[#4ade80]"
                      : r.status === "Party required"
                        ? "bg-[#134e4a]/60 text-[#5eead4]"
                        : "bg-white/8 text-white/40",
                  )}
                >
                  {r.status}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>

      {toast ? (
        <div className="pointer-events-none absolute bottom-8 left-1/2 z-50 -translate-x-1/2 rounded-full bg-[#0f766e] px-4 py-2 text-[13px] font-semibold text-white shadow-lg">
          {toast}
        </div>
      ) : null}
    </div>
  );
}
