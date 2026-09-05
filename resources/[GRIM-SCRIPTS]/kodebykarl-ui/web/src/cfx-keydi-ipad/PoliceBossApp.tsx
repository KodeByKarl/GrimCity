import React, { useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import {
  BatteryFull,
  Bell,
  DollarSign,
  Megaphone,
  Search,
  Shield,
  Signal,
  UserMinus,
  UserPlus,
  Users,
  Wifi,
} from "lucide-react";
import type { IpadPlayerData } from "./Ipad";

type TabId = "funds" | "members" | "online" | "announce";

const TABS: { id: TabId; label: string }[] = [
  { id: "funds", label: "Society Funds" },
  { id: "members", label: "Members" },
  { id: "online", label: "Online" },
  { id: "announce", label: "Announce" },
];

const MOCK_MEMBERS = [
  { id: 1, name: "Karl Dev", grade: "Director", gradeNum: 6, badge: "100", online: true },
  { id: 2, name: "Ace Walker", grade: "Chief of Police", gradeNum: 5, badge: "101", online: true },
  { id: 3, name: "Nova Cruz", grade: "Captain", gradeNum: 3, badge: "214", online: false },
  { id: 4, name: "Rico Vale", grade: "Police Officer", gradeNum: 1, badge: "318", online: true },
  { id: 5, name: "Mia Storm", grade: "Cadet", gradeNum: 0, badge: "401", online: false },
];

const MOCK_ONLINE = MOCK_MEMBERS.filter((m) => m.online);

const MOCK_ANNOUNCEMENTS = [
  {
    id: 1,
    title: "Citywide Code 2",
    body: "Increase patrol density downtown. Report suspicious vehicles immediately.",
    author: "Karl Dev",
    time: "10m ago",
  },
  {
    id: 2,
    title: "Shift Briefing",
    body: "New cadets ride with FTO only. Radio channel 1 for primary.",
    author: "Ace Walker",
    time: "2h ago",
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

export default function PoliceBossApp({
  player,
}: {
  player?: IpadPlayerData | null;
}) {
  const [tab, setTab] = useState<TabId>("funds");
  const [balance, setBalance] = useState(2450000);
  const [amount, setAmount] = useState("");
  const [query, setQuery] = useState("");
  const [annTitle, setAnnTitle] = useState("");
  const [annBody, setAnnBody] = useState("");
  const [announcements, setAnnouncements] = useState(MOCK_ANNOUNCEMENTS);
  const [toast, setToast] = useState<string | null>(null);
  const [hireId, setHireId] = useState("");

  const members = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return MOCK_MEMBERS;
    return MOCK_MEMBERS.filter(
      (m) => m.name.toLowerCase().includes(q) || m.badge.includes(q) || m.grade.toLowerCase().includes(q),
    );
  }, [query]);

  const flash = (msg: string) => {
    setToast(msg);
    window.setTimeout(() => setToast(null), 2000);
  };

  const deposit = () => {
    const n = Math.floor(Number(amount) || 0);
    if (n <= 0) return;
    setBalance((b) => b + n);
    setAmount("");
    flash(`Deposited $${n.toLocaleString()}`);
  };

  const withdraw = () => {
    const n = Math.floor(Number(amount) || 0);
    if (n <= 0) return;
    if (n > balance) {
      flash("Insufficient funds");
      return;
    }
    setBalance((b) => b - n);
    setAmount("");
    flash(`Withdrew $${n.toLocaleString()}`);
  };

  const publishAnnounce = () => {
    if (!annTitle.trim() || !annBody.trim()) return;
    const author = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Boss";
    setAnnouncements((prev) => [
      {
        id: Date.now(),
        title: annTitle.trim(),
        body: annBody.trim(),
        author,
        time: "now",
      },
      ...prev,
    ]);
    setAnnTitle("");
    setAnnBody("");
    flash("Posted — synced to Police MDT");
  };

  return (
    <div
      className="absolute inset-0 flex flex-col select-none"
      style={{
        background:
          "radial-gradient(ellipse at 20% 0%, rgba(37,99,235,0.22), transparent 48%), linear-gradient(165deg, #070b14 0%, #0c1220 45%, #080a10 100%)",
      }}
    >
      <StatusBar />

      <div className="flex items-start justify-between gap-3 px-5 pb-2 pt-2">
        <div className="min-w-0">
          <div className="flex flex-wrap items-center gap-2">
            <Shield className="h-5 w-5 text-[#60a5fa]" strokeWidth={2.2} />
            <h1 className="text-[22px] font-bold tracking-wide text-white">Police Boss</h1>
            <span className="rounded-md bg-[#1d4ed8] px-2 py-0.5 text-[10px] font-bold uppercase tracking-wider text-white">
              Boss Only
            </span>
          </div>
          <p className="mt-1 text-[12px] text-white/45">
            LSPD management · Society funds · Roster · MDT announcements
          </p>
        </div>
      </div>

      {/* Tabs */}
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
                  ? "bg-[#2563eb] text-white shadow-[0_4px_16px_rgba(37,99,235,0.35)]"
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
        {tab === "funds" && (
          <div className="space-y-4">
            <div className="rounded-2xl border border-[#2563eb]/35 bg-[#0f172a] p-5 shadow-lg">
              <p className="text-[12px] font-semibold uppercase tracking-[0.14em] text-[#60a5fa]">
                Society account · society_police
              </p>
              <p className="mt-2 text-[36px] font-bold tracking-tight text-white">
                ${balance.toLocaleString()}
              </p>
              <p className="mt-1 text-[13px] text-white/40">Live balance via cfx-keydi-society</p>
            </div>

            <div className="rounded-2xl border border-white/8 bg-[#111827] p-4">
              <p className="mb-3 text-[14px] font-semibold text-white">Deposit / Withdraw</p>
              <div className="flex flex-wrap items-center gap-2">
                <div className="flex flex-1 items-center gap-2 rounded-xl border border-white/10 bg-black/35 px-3 py-2.5">
                  <DollarSign className="h-4 w-4 text-white/40" />
                  <input
                    type="number"
                    min={0}
                    value={amount}
                    onChange={(e) => setAmount(e.target.value)}
                    placeholder="Amount"
                    className="w-full min-w-[120px] bg-transparent text-[15px] font-semibold text-white outline-none"
                  />
                </div>
                <button
                  type="button"
                  className="rounded-full bg-[#16a34a] px-4 py-2.5 text-[12px] font-bold uppercase text-white"
                  onClick={deposit}
                >
                  Deposit
                </button>
                <button
                  type="button"
                  className="rounded-full bg-[#dc2626] px-4 py-2.5 text-[12px] font-bold uppercase text-white"
                  onClick={withdraw}
                >
                  Withdraw
                </button>
              </div>
            </div>

            <div className="rounded-2xl border border-white/8 bg-[#111827] p-4">
              <p className="mb-2 text-[13px] font-semibold text-white/70">Recent ledger (preview)</p>
              <div className="space-y-2 text-[13px]">
                <div className="flex justify-between text-white/70">
                  <span>Deposit · Fine pool</span>
                  <span className="font-semibold text-[#4ade80]">+$85,000</span>
                </div>
                <div className="flex justify-between text-white/70">
                  <span>Withdraw · Equipment</span>
                  <span className="font-semibold text-[#f87171]">-$12,500</span>
                </div>
              </div>
            </div>
          </div>
        )}

        {tab === "members" && (
          <div className="space-y-3">
            <div className="flex flex-wrap gap-2">
              <div className="flex flex-1 items-center gap-2 rounded-xl border border-white/10 bg-[#111827] px-3 py-2.5">
                <Search className="h-4 w-4 text-white/35" />
                <input
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  placeholder="Search members..."
                  className="w-full bg-transparent text-[14px] text-white outline-none placeholder:text-white/30"
                />
              </div>
              <div className="flex items-center gap-2 rounded-xl border border-white/10 bg-[#111827] px-3 py-2.5">
                <UserPlus className="h-4 w-4 text-[#60a5fa]" />
                <input
                  value={hireId}
                  onChange={(e) => setHireId(e.target.value)}
                  placeholder="Server ID"
                  className="w-20 bg-transparent text-[14px] text-white outline-none placeholder:text-white/30"
                />
                <button
                  type="button"
                  className="rounded-lg bg-[#2563eb] px-2.5 py-1 text-[11px] font-bold text-white"
                  onClick={() => {
                    if (!hireId.trim()) return;
                    flash(`Hire request · ID ${hireId} (preview)`);
                    setHireId("");
                  }}
                >
                  Hire
                </button>
              </div>
            </div>

            <div className="overflow-hidden rounded-2xl border border-white/8 bg-[#111827]">
              {members.map((m, i) => (
                <div
                  key={m.id}
                  className={cn(
                    "flex items-center gap-3 px-4 py-3",
                    i < members.length - 1 && "border-b border-white/6",
                  )}
                >
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-[#1e3a8a] text-[13px] font-bold text-white">
                    {m.badge}
                  </div>
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-[15px] font-semibold text-white">{m.name}</p>
                    <p className="text-[12px] text-white/40">
                      {m.grade} · grade {m.gradeNum}
                      {m.online ? " · Online" : " · Offline"}
                    </p>
                  </div>
                  <button
                    type="button"
                    className="rounded-lg bg-white/6 px-2.5 py-1.5 text-[11px] font-semibold text-white/70"
                    onClick={() => flash(`Edit ${m.name} (preview)`)}
                  >
                    Edit
                  </button>
                  <button
                    type="button"
                    className="rounded-lg bg-[#7f1d1d]/50 px-2 py-1.5 text-[#fca5a5]"
                    onClick={() => flash(`Remove ${m.name} (preview)`)}
                    title="Remove"
                  >
                    <UserMinus className="h-4 w-4" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}

        {tab === "online" && (
          <div className="space-y-3">
            <div className="rounded-2xl border border-[#2563eb]/30 bg-[#0f172a] px-4 py-3">
              <div className="flex items-center gap-2 text-[#60a5fa]">
                <Users className="h-4 w-4" />
                <p className="text-[13px] font-semibold">
                  {MOCK_ONLINE.length} police online right now
                </p>
              </div>
            </div>
            <div className="overflow-hidden rounded-2xl border border-white/8 bg-[#111827]">
              {MOCK_ONLINE.map((m, i) => (
                <div
                  key={m.id}
                  className={cn(
                    "flex items-center gap-3 px-4 py-3",
                    i < MOCK_ONLINE.length - 1 && "border-b border-white/6",
                  )}
                >
                  <span className="h-2.5 w-2.5 rounded-full bg-[#22c55e]" />
                  <div className="min-w-0 flex-1">
                    <p className="text-[15px] font-semibold text-white">{m.name}</p>
                    <p className="text-[12px] text-white/40">
                      Badge {m.badge} · {m.grade}
                    </p>
                  </div>
                  <span className="text-[11px] font-semibold uppercase text-[#4ade80]">On duty</span>
                </div>
              ))}
            </div>
          </div>
        )}

        {tab === "announce" && (
          <div className="space-y-4">
            <div className="rounded-2xl border border-white/8 bg-[#111827] p-4">
              <div className="mb-3 flex items-center gap-2 text-[#60a5fa]">
                <Megaphone className="h-4 w-4" />
                <p className="text-[14px] font-semibold">Post to Police MDT</p>
              </div>
              <input
                value={annTitle}
                onChange={(e) => setAnnTitle(e.target.value)}
                placeholder="Title"
                className="mb-2 w-full rounded-xl border border-white/10 bg-black/35 px-3 py-2.5 text-[14px] text-white outline-none placeholder:text-white/30"
              />
              <textarea
                value={annBody}
                onChange={(e) => setAnnBody(e.target.value)}
                placeholder="Announcement body..."
                rows={3}
                className="mb-3 w-full resize-none rounded-xl border border-white/10 bg-black/35 px-3 py-2.5 text-[14px] text-white outline-none placeholder:text-white/30"
              />
              <button
                type="button"
                className="flex items-center gap-2 rounded-full bg-[#2563eb] px-4 py-2.5 text-[12px] font-bold uppercase text-white"
                onClick={publishAnnounce}
              >
                <Bell className="h-3.5 w-3.5" />
                Publish to MDT
              </button>
            </div>

            <div className="space-y-2">
              {announcements.map((a) => (
                <div key={a.id} className="rounded-2xl border border-white/8 bg-[#111827] px-4 py-3">
                  <div className="flex items-baseline justify-between gap-2">
                    <p className="text-[15px] font-semibold text-white">{a.title}</p>
                    <span className="text-[11px] text-white/35">{a.time}</span>
                  </div>
                  <p className="mt-1 text-[13px] leading-snug text-white/60">{a.body}</p>
                  <p className="mt-2 text-[11px] text-[#60a5fa]">By {a.author}</p>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {toast ? (
        <div className="pointer-events-none absolute bottom-8 left-1/2 z-50 -translate-x-1/2 rounded-full bg-[#1d4ed8] px-4 py-2 text-[13px] font-semibold text-white shadow-lg">
          {toast}
        </div>
      ) : null}
    </div>
  );
}
