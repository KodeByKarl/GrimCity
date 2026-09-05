import React, { useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import { BatteryFull, Signal, Trophy, Wifi } from "lucide-react";
import type { IpadPlayerData } from "./Ipad";

type TabId = "turfwar" | "traphouse" | "party" | "topplayer";

const TABS: { id: TabId; label: string }[] = [
  { id: "turfwar", label: "Turfwar" },
  { id: "traphouse", label: "Traphouse" },
  { id: "party", label: "Party" },
  { id: "topplayer", label: "Top Player" },
];

interface RankRow {
  rank: number;
  name: string;
  gang?: string;
  score: string;
  subtitle?: string;
}

const MOCK: Record<TabId, RankRow[]> = {
  turfwar: [
    { rank: 1, name: "Ballas", gang: "South Side", score: "42 captures", subtitle: "Hot streak" },
    { rank: 2, name: "Families", gang: "Grove", score: "37 captures", subtitle: "Rising" },
    { rank: 3, name: "Vagos", gang: "East LS", score: "31 captures", subtitle: "Contested" },
    { rank: 4, name: "Lost MC", gang: "Blaine", score: "24 captures", subtitle: "Steady" },
    { rank: 5, name: "Marabunta", gang: "Rancho", score: "19 captures", subtitle: "Climbing" },
    { rank: 6, name: "The Triads", gang: "Little Seoul", score: "14 captures" },
    { rank: 7, name: "Aztecas", gang: "Cypress", score: "11 captures" },
    { rank: 8, name: "Independent", gang: "—", score: "6 captures" },
  ],
  traphouse: [
    { rank: 1, name: "Smoke King", gang: "Ballas", score: "$2.4M moved", subtitle: "Top cook" },
    { rank: 2, name: "Night Shift", gang: "Vagos", score: "$1.9M moved", subtitle: "Active" },
    { rank: 3, name: "Silent Bag", gang: "Families", score: "$1.6M moved" },
    { rank: 4, name: "Corner Boss", gang: "Marabunta", score: "$1.1M moved" },
    { rank: 5, name: "Lab Rat", gang: "Lost MC", score: "$890K moved" },
    { rank: 6, name: "Street Chem", gang: "Independent", score: "$640K moved" },
    { rank: 7, name: "Block Runner", gang: "Aztecas", score: "$420K moved" },
    { rank: 8, name: "Rookie Cook", gang: "—", score: "$180K moved" },
  ],
  party: [
    { rank: 1, name: "VIP Hosts", score: "128 parties", subtitle: "This week" },
    { rank: 2, name: "Rooftop Crew", score: "96 parties" },
    { rank: 3, name: "Yacht Club", score: "81 parties" },
    { rank: 4, name: "Club 77", score: "64 parties" },
    { rank: 5, name: "Beach Bash", score: "52 parties" },
    { rank: 6, name: "Warehouse Rave", score: "41 parties" },
    { rank: 7, name: "Casino Afters", score: "33 parties" },
    { rank: 8, name: "Local Spot", score: "18 parties" },
  ],
  topplayer: [
    { rank: 1, name: "Karl Dev", gang: "Staff", score: "98.4 rating", subtitle: "All-time" },
    { rank: 2, name: "Ace Walker", gang: "Families", score: "94.1 rating" },
    { rank: 3, name: "Nova Cruz", gang: "Ballas", score: "91.7 rating" },
    { rank: 4, name: "Rico Vale", gang: "Vagos", score: "88.2 rating" },
    { rank: 5, name: "Mia Storm", gang: "Independent", score: "85.6 rating" },
    { rank: 6, name: "Jay Knox", gang: "Lost MC", score: "82.0 rating" },
    { rank: 7, name: "Lena Park", gang: "Marabunta", score: "79.4 rating" },
    { rank: 8, name: "Tom Reed", gang: "Aztecas", score: "76.8 rating" },
  ],
};

const TAB_META: Record<TabId, { title: string; blurb: string; accent: string }> = {
  turfwar: {
    title: "Turfwar",
    blurb: "Gangs ranked by territory captures this season.",
    accent: "from-[#ff3b30] to-[#8b0000]",
  },
  traphouse: {
    title: "Traphouse",
    blurb: "Top movers by product volume and trap activity.",
    accent: "from-[#34c759] to-[#0b6b2f]",
  },
  party: {
    title: "Party",
    blurb: "Most active party hosts across Los Santos.",
    accent: "from-[#af52de] to-[#5856d6]",
  },
  topplayer: {
    title: "Top Player",
    blurb: "Overall standings across Grim City systems.",
    accent: "from-[#ff9f0a] to-[#ff3b30]",
  },
};

function StatusBar() {
  const [now, setNow] = useState(() => new Date());
  React.useEffect(() => {
    const id = window.setInterval(() => setNow(new Date()), 1000);
    return () => window.clearInterval(id);
  }, []);
  const time = now.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  return (
    <div className="relative z-40 flex items-center justify-between px-7 pt-[18px] text-[12px] font-semibold tracking-tight text-black">
      <span className="min-w-[54px]">{time}</span>
      <div className="flex items-center gap-1.5 opacity-90">
        <Signal className="h-3.5 w-3.5" strokeWidth={2.4} />
        <Wifi className="h-3.5 w-3.5" strokeWidth={2.4} />
        <BatteryFull className="h-4 w-4" strokeWidth={2.2} />
      </div>
    </div>
  );
}

function RankBadge({ rank }: { rank: number }) {
  const tone =
    rank === 1
      ? "bg-gradient-to-br from-[#ffd60a] to-[#ff9f0a] text-[#1c1c1e]"
      : rank === 2
        ? "bg-gradient-to-br from-[#e5e5ea] to-[#aeaeb2] text-[#1c1c1e]"
        : rank === 3
          ? "bg-gradient-to-br from-[#ff9f0a] to-[#c45c00] text-white"
          : "bg-[#e5e5ea] text-[#3a3a3c]";
  return (
    <div
      className={cn(
        "flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-[14px] font-bold shadow-sm",
        tone,
      )}
    >
      {rank}
    </div>
  );
}

export default function LeaderboardApp({
  player,
}: {
  player?: IpadPlayerData | null;
}) {
  const [tab, setTab] = useState<TabId>("turfwar");
  const rows = MOCK[tab];
  const meta = TAB_META[tab];
  const you = useMemo(() => {
    const n = [player?.firstName, player?.lastName].filter(Boolean).join(" ");
    return n || null;
  }, [player]);

  return (
    <div className="absolute inset-0 flex flex-col bg-[#f2f2f7] select-none">
      <StatusBar />

      <div className="flex items-center justify-center gap-2 px-3 pb-2 pt-2">
          <div className="flex h-7 w-7 items-center justify-center rounded-[8px] bg-[#e10600] text-white shadow-sm">
            <Trophy className="h-3.5 w-3.5" strokeWidth={2.4} fill="white" />
          </div>
          <p className="text-[17px] font-semibold text-black">Leaderboards</p>
        </div>

      <div className="min-h-0 flex-1 overflow-y-auto px-5 pb-3">
        <div
          className={cn(
            "mb-4 overflow-hidden rounded-[20px] bg-gradient-to-br p-5 text-white shadow-[0_12px_28px_rgba(0,0,0,0.18)]",
            meta.accent,
          )}
        >
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-[13px] font-semibold uppercase tracking-[0.12em] text-white/70">
                Season standings
              </p>
              <h2 className="mt-1 text-[28px] font-bold tracking-tight">{meta.title}</h2>
              <p className="mt-1.5 max-w-[420px] text-[14px] leading-snug text-white/85">{meta.blurb}</p>
            </div>
            <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-[18px] bg-[#e10600] text-white shadow-lg ring-2 ring-white/25">
              <Trophy className="h-8 w-8" strokeWidth={2.2} fill="white" />
            </div>
          </div>
          {you ? (
            <p className="mt-4 rounded-xl bg-black/20 px-3 py-2 text-[13px] text-white/90 backdrop-blur-sm">
              Signed in as <span className="font-semibold">{you}</span>
              {player?.gang ? ` · ${player.gang}` : ""}
            </p>
          ) : null}
        </div>

        <div className="overflow-hidden rounded-[16px] bg-white shadow-sm">
          {rows.map((row, i) => (
            <div
              key={`${tab}-${row.rank}-${row.name}`}
              className={cn(
                "flex items-center gap-3 px-4 py-3.5",
                i < rows.length - 1 && "border-b border-[#e5e5ea]",
              )}
            >
              <RankBadge rank={row.rank} />
              <div className="min-w-0 flex-1">
                <p className="truncate text-[16px] font-semibold text-[#1c1c1e]">{row.name}</p>
                <p className="truncate text-[13px] text-[#8e8e93]">
                  {row.gang ? `${row.gang}` : ""}
                  {row.gang && row.subtitle ? " · " : ""}
                  {row.subtitle || ""}
                </p>
              </div>
              <p className="shrink-0 text-right text-[14px] font-semibold text-[#3a3a3c]">{row.score}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Bottom nav — text only, no emoji */}
      <nav className="border-t border-black/8 bg-white/95 px-2 pb-5 pt-1.5 backdrop-blur-xl">
        <div className="mx-auto grid max-w-[720px] grid-cols-4 gap-1">
          {TABS.map((t) => {
            const active = tab === t.id;
            return (
              <button
                key={t.id}
                type="button"
                className={cn(
                  "rounded-[12px] px-1 py-2.5 text-center transition-colors",
                  active ? "bg-[#007aff]/12" : "active:bg-black/5",
                )}
                onClick={() => setTab(t.id)}
              >
                <span
                  className={cn(
                    "block text-[12px] font-semibold leading-tight tracking-tight",
                    active ? "text-[#007aff]" : "text-[#8e8e93]",
                  )}
                >
                  {t.label}
                </span>
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
}
