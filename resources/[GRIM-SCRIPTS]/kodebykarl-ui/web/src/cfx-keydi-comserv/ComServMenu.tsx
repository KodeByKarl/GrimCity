import { useEffect, useMemo, useState } from "react";
import {
  HardHat,
  Search,
  X,
  RefreshCw,
  User,
  Users,
  Wifi,
  WifiOff,
  Gavel,
  Trash2,
  Clock3,
  Copy,
  Check,
} from "lucide-react";
import { cn } from "@/lib/utils";

export interface ComServPlayer {
  source?: number;
  identifier: string;
  name: string;
  group?: string;
  online?: boolean;
  serving?: boolean;
  discord?: string;
  steam?: string;
  license?: string;
  license2?: string;
  fivem?: string;
  ip?: string;
  ping?: number | null;
}

export interface ComServActive {
  identifier: string;
  name: string;
  remaining: number;
  total: number;
  reason: string;
  adminName: string;
  adminIdentifier?: string;
  createdAt?: number;
  online: boolean;
  source?: number | null;
  discord?: string;
  steam?: string;
  license?: string;
  license2?: string;
  fivem?: string;
  ip?: string;
  ping?: number | null;
}

export interface ComServPanelData {
  brand?: string;
  defaultActions?: number;
  maxActions?: number;
  staffName?: string;
  staffId?: number;
  online?: ComServPlayer[];
  active?: ComServActive[];
}

interface ComServMenuProps {
  data?: ComServPanelData | null;
  onClose: () => void;
}

async function fetchNui<T = any>(event: string, payload?: unknown): Promise<T> {
  const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : "cfx-keydi-ui";
  try {
    const resp = await fetch(`https://${resourceName}/${event}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(payload ?? {}),
    });
    return await resp.json();
  } catch {
    return undefined as T;
  }
}

function formatTime(ts?: number) {
  if (!ts) return "—";
  try {
    return new Date(ts * 1000).toLocaleString();
  } catch {
    return "—";
  }
}

function DetailRow({ label, value }: { label: string; value?: string | number | null }) {
  const [copied, setCopied] = useState(false);
  const display = value == null || value === "" ? "N/A" : String(value);
  const canCopy = display !== "N/A";

  const copy = async () => {
    if (!canCopy) return;
    try {
      await navigator.clipboard.writeText(display);
      setCopied(true);
      setTimeout(() => setCopied(false), 1200);
    } catch {
      /* ignore */
    }
  };

  return (
    <div className="flex items-start justify-between gap-2 rounded-lg border border-white/5 bg-white/[0.03] px-2.5 py-1.5">
      <div className="min-w-0 flex-1">
        <p className="text-[8px] font-black uppercase tracking-wider text-white/35">{label}</p>
        <p className="mt-0.5 break-all font-mono text-[10px] font-semibold text-white/85">{display}</p>
      </div>
      {canCopy && (
        <button
          type="button"
          onClick={copy}
          className="mt-0.5 shrink-0 rounded-md border border-white/10 bg-black/20 p-1 text-white/45 transition hover:border-white/25 hover:text-white"
          title={`Copy ${label}`}
        >
          {copied ? <Check className="h-3 w-3 text-emerald-300" /> : <Copy className="h-3 w-3" />}
        </button>
      )}
    </div>
  );
}

function PlayerDetailsCard({
  player,
}: {
  player: Pick<
    ComServPlayer,
    | "name"
    | "source"
    | "identifier"
    | "online"
    | "group"
    | "discord"
    | "steam"
    | "license"
    | "license2"
    | "fivem"
    | "ip"
    | "ping"
  >;
}) {
  const isOnline = player.online !== false && player.source != null;

  return (
    <div className="space-y-2">
      <div className="flex items-start justify-between gap-2">
        <div className="min-w-0">
          <p className="truncate text-[13px] font-bold text-white">{player.name}</p>
          {player.group ? (
            <p className="mt-0.5 text-[10px] font-semibold uppercase tracking-wide text-white/40">
              Group · {player.group}
            </p>
          ) : null}
        </div>
        <span
          className={cn(
            "shrink-0 rounded-md px-2 py-0.5 text-[9px] font-bold uppercase",
            isOnline ? "bg-emerald-500/15 text-emerald-300" : "bg-white/10 text-white/55"
          )}
        >
          {isOnline ? `Online #${player.source}` : "Offline"}
        </span>
      </div>

      <div className="grid gap-1.5">
        {isOnline && <DetailRow label="Server ID" value={player.source} />}
        <DetailRow label="IP" value={player.ip} />
        <DetailRow label="Discord" value={player.discord} />
        <DetailRow label="Steam" value={player.steam} />
        <DetailRow label="License" value={player.license} />
        {player.license2 && player.license2 !== "N/A" ? (
          <DetailRow label="License2" value={player.license2} />
        ) : null}
        {player.fivem && player.fivem !== "N/A" ? (
          <DetailRow label="FiveM" value={player.fivem} />
        ) : null}
        <DetailRow label="Identifier" value={player.identifier} />
        {isOnline && player.ping != null ? <DetailRow label="Ping" value={`${player.ping} ms`} /> : null}
      </div>
    </div>
  );
}

export default function ComServMenu({ data, onClose }: ComServMenuProps) {
  const [online, setOnline] = useState<ComServPlayer[]>(data?.online || []);
  const [active, setActive] = useState<ComServActive[]>(data?.active || []);
  const [offlineResults, setOfflineResults] = useState<ComServPlayer[]>([]);
  const [tab, setTab] = useState<"sentence" | "active">("sentence");
  const [mode, setMode] = useState<"online" | "offline">("online");
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState<ComServPlayer | null>(null);
  const [actions, setActions] = useState(data?.defaultActions || 10);
  const [reason, setReason] = useState("");
  const [busy, setBusy] = useState(false);
  const [searching, setSearching] = useState(false);

  const maxActions = data?.maxActions || 100;
  const brand = data?.brand || "PANDORA CITY";

  useEffect(() => {
    setOnline(data?.online || []);
    setActive(data?.active || []);
    if (typeof data?.defaultActions === "number") {
      setActions(data.defaultActions);
    }
  }, [data]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const msg = event.data;
      if (!msg) return;
      if (msg.action === "cfx-keydi-comserv:panel:update" && msg.data) {
        if (msg.data.online) setOnline(msg.data.online);
        if (msg.data.active) setActive(msg.data.active);
      }
    };
    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  useEffect(() => {
    if (mode !== "offline") return;
    const q = search.trim();
    if (q.length < 2) {
      setOfflineResults([]);
      return;
    }
    const timer = setTimeout(async () => {
      setSearching(true);
      const results = await fetchNui<ComServPlayer[]>("cfx-keydi-comserv:searchOffline", { query: q });
      setOfflineResults(Array.isArray(results) ? results : []);
      setSearching(false);
    }, 280);
    return () => clearTimeout(timer);
  }, [search, mode]);

  const filteredOnline = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return online;
    return online.filter((p) => {
      const hay = `${p.name} ${p.source ?? ""} ${p.identifier}`.toLowerCase();
      return hay.includes(q);
    });
  }, [online, search]);

  const list = mode === "online" ? filteredOnline : offlineResults;

  const refresh = async () => {
    setBusy(true);
    const res = await fetchNui<{ online?: ComServPlayer[]; active?: ComServActive[] }>(
      "cfx-keydi-comserv:refresh"
    );
    if (res?.online) setOnline(res.online);
    if (res?.active) setActive(res.active);
    setBusy(false);
  };

  const sendSentence = async () => {
    if (!selected || busy) return;
    if (selected.serving) return;
    const amount = Math.max(1, Math.min(maxActions, Math.floor(Number(actions) || 1)));
    setBusy(true);
    await fetchNui("cfx-keydi-comserv:sentence", {
      source: selected.source,
      identifier: selected.identifier,
      name: selected.name,
      actions: amount,
      reason: reason.trim() || "Community Service",
    });
    setReason("");
    setSelected(null);
    setTimeout(refresh, 350);
    setBusy(false);
  };

  const endSentence = async (entry: ComServActive) => {
    if (busy) return;
    setBusy(true);
    await fetchNui("cfx-keydi-comserv:end", {
      identifier: entry.identifier,
      source: entry.source,
    });
    setTimeout(refresh, 350);
    setBusy(false);
  };

  return (
    <div className="pandora fixed inset-0 z-[99995] flex items-center justify-center bg-black/55 backdrop-blur-[2px]">
      <div
        className="relative flex h-[78vh] w-[920px] max-w-[94vw] flex-col overflow-hidden rounded-2xl border shadow-[0_30px_80px_-20px_rgba(0,0,0,0.9)]"
        style={{
          background: "linear-gradient(180deg, rgba(10, 40, 70, 0.97) 0%, rgba(5, 25, 47, 0.98) 100%)",
          borderColor: "rgba(143, 228, 255, 0.22)",
        }}
      >
        <div className="panel-grid pointer-events-none absolute inset-0 opacity-30" />

        <div
          className="relative flex items-center justify-between gap-3 border-b px-4 py-3"
          style={{
            background:
              "linear-gradient(135deg, rgba(53,199,242,0.35) 0%, rgba(28,111,168,0.55) 55%, rgba(11,44,78,0.6) 100%)",
            borderBottomColor: "rgba(255, 210, 76, 0.35)",
          }}
        >
          <div className="flex min-w-0 items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl border border-white/25 bg-white/12">
              <HardHat className="h-4 w-4 text-white" />
            </div>
            <div className="min-w-0">
              <p className="text-[10px] font-black uppercase tracking-[0.18em] text-white/90">
                Community Service
              </p>
              <p className="truncate text-[11px] font-bold uppercase tracking-wider text-[#ffd24c]/85">
                {brand} · {data?.staffName || "Staff"}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={refresh}
              disabled={busy}
              className="flex h-8 w-8 items-center justify-center rounded-lg border border-white/15 bg-black/25 text-white/80 transition hover:border-white/30 hover:text-white disabled:opacity-40"
              title="Refresh"
            >
              <RefreshCw className={cn("h-3.5 w-3.5", busy && "animate-spin")} />
            </button>
            <button
              type="button"
              onClick={onClose}
              className="flex items-center gap-1.5 rounded-lg border border-white/15 bg-black/25 px-2.5 py-1.5 text-[10px] font-semibold text-white/80 transition hover:border-white/30 hover:text-white"
            >
              <span>Esc</span>
              <X className="h-3.5 w-3.5" />
            </button>
          </div>
        </div>

        <div className="relative flex gap-2 border-b border-white/10 px-4 py-2">
          <button
            type="button"
            onClick={() => setTab("sentence")}
            className={cn(
              "rounded-lg px-3 py-1.5 text-[11px] font-bold uppercase tracking-wide transition",
              tab === "sentence"
                ? "bg-[#35c7f2]/25 text-[#8fe4ff] border border-[#35c7f2]/35"
                : "text-white/50 hover:text-white/80 border border-transparent"
            )}
          >
            <span className="inline-flex items-center gap-1.5">
              <Gavel className="h-3.5 w-3.5" /> Sentence
            </span>
          </button>
          <button
            type="button"
            onClick={() => setTab("active")}
            className={cn(
              "rounded-lg px-3 py-1.5 text-[11px] font-bold uppercase tracking-wide transition",
              tab === "active"
                ? "bg-[#35c7f2]/25 text-[#8fe4ff] border border-[#35c7f2]/35"
                : "text-white/50 hover:text-white/80 border border-transparent"
            )}
          >
            <span className="inline-flex items-center gap-1.5">
              <Users className="h-3.5 w-3.5" /> Active ({active.length})
            </span>
          </button>
        </div>

        {tab === "sentence" ? (
          <div className="relative grid min-h-0 flex-1 grid-cols-[1.15fr_0.85fr] gap-0">
            <div className="flex min-h-0 flex-col border-r border-white/10">
              <div className="flex items-center gap-2 border-b border-white/10 px-3 py-2.5">
                <div className="flex rounded-lg border border-white/10 bg-black/20 p-0.5">
                  <button
                    type="button"
                    onClick={() => {
                      setMode("online");
                      setSelected(null);
                      setOfflineResults([]);
                    }}
                    className={cn(
                      "inline-flex items-center gap-1 rounded-md px-2.5 py-1 text-[10px] font-bold uppercase transition",
                      mode === "online" ? "bg-[#35c7f2]/25 text-[#8fe4ff]" : "text-white/45 hover:text-white/75"
                    )}
                  >
                    <Wifi className="h-3 w-3" /> Online
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setMode("offline");
                      setSelected(null);
                    }}
                    className={cn(
                      "inline-flex items-center gap-1 rounded-md px-2.5 py-1 text-[10px] font-bold uppercase transition",
                      mode === "offline" ? "bg-[#35c7f2]/25 text-[#8fe4ff]" : "text-white/45 hover:text-white/75"
                    )}
                  >
                    <WifiOff className="h-3 w-3" /> Offline
                  </button>
                </div>

                <div className="relative flex-1">
                  <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-white/35" />
                  <input
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    placeholder={mode === "online" ? "Search online players..." : "Search offline by name..."}
                    className="w-full rounded-lg border border-white/10 bg-black/30 py-2 pl-8 pr-3 text-[12px] text-white outline-none placeholder:text-white/30 focus:border-[#35c7f2]/40"
                  />
                </div>
              </div>

              <div className="no-scrollbar min-h-0 flex-1 space-y-1.5 overflow-y-auto p-3">
                {mode === "offline" && search.trim().length < 2 && (
                  <p className="px-2 py-6 text-center text-[11px] text-white/40">
                    Type at least 2 characters to search offline players.
                  </p>
                )}
                {mode === "offline" && searching && (
                  <p className="px-2 py-4 text-center text-[11px] text-white/40">Searching...</p>
                )}
                {list.length === 0 && !(mode === "offline" && search.trim().length < 2) && !searching && (
                  <p className="px-2 py-6 text-center text-[11px] text-white/40">No players found.</p>
                )}
                {list.map((player) => {
                  const isSelected =
                    selected?.identifier === player.identifier &&
                    (selected?.source ?? null) === (player.source ?? null);
                  return (
                    <button
                      key={`${player.identifier}-${player.source ?? "off"}`}
                      type="button"
                      disabled={!!player.serving}
                      onClick={() => setSelected(player)}
                      className={cn(
                        "flex w-full items-center justify-between gap-3 rounded-xl border px-3 py-2.5 text-left transition",
                        isSelected
                          ? "border-[#35c7f2]/45 bg-[#35c7f2]/15"
                          : "border-white/10 bg-white/[0.03] hover:border-white/20 hover:bg-white/[0.06]",
                        player.serving && "opacity-45 pointer-events-none"
                      )}
                    >
                      <div className="flex min-w-0 items-center gap-2.5">
                        <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border border-white/10 bg-black/25">
                          <User className="h-3.5 w-3.5 text-[#8fe4ff]" />
                        </div>
                        <div className="min-w-0">
                          <p className="truncate text-[12px] font-bold text-white">{player.name}</p>
                          <p className="truncate text-[10px] text-white/40">
                            {player.online !== false && player.source != null
                              ? `ID ${player.source}`
                              : "Offline"}
                            {player.serving ? " · Already serving" : ""}
                          </p>
                        </div>
                      </div>
                      {mode === "online" ? (
                        <Wifi className="h-3.5 w-3.5 shrink-0 text-emerald-400/80" />
                      ) : (
                        <WifiOff className="h-3.5 w-3.5 shrink-0 text-white/35" />
                      )}
                    </button>
                  );
                })}
              </div>
            </div>

            <div className="flex min-h-0 flex-col overflow-hidden p-4">
              <p className="text-[10px] font-black uppercase tracking-[0.16em] text-white/45">Sentence details</p>

              <div className="no-scrollbar mt-3 min-h-0 flex-1 overflow-y-auto rounded-xl border border-white/10 bg-black/25 p-3">
                {selected ? (
                  <PlayerDetailsCard player={selected} />
                ) : (
                  <p className="py-4 text-center text-[11px] text-white/40">Select a player from the list</p>
                )}
              </div>

              <label className="mt-3 block text-[10px] font-bold uppercase tracking-wider text-white/45">
                Actions
              </label>
              <input
                type="number"
                min={1}
                max={maxActions}
                value={actions}
                onChange={(e) => setActions(Number(e.target.value))}
                className="mt-1.5 w-full rounded-lg border border-white/10 bg-black/30 px-3 py-2 text-[13px] font-semibold text-white outline-none focus:border-[#35c7f2]/40"
              />
              <p className="mt-1 text-[10px] text-white/30">Max {maxActions}</p>

              <label className="mt-3 block text-[10px] font-bold uppercase tracking-wider text-white/45">
                Reason
              </label>
              <textarea
                value={reason}
                onChange={(e) => setReason(e.target.value)}
                rows={2}
                maxLength={180}
                placeholder="Why are they on community service?"
                className="mt-1.5 w-full resize-none rounded-lg border border-white/10 bg-black/30 px-3 py-2 text-[12px] text-white outline-none placeholder:text-white/30 focus:border-[#35c7f2]/40"
              />

              <button
                type="button"
                disabled={!selected || busy || !!selected?.serving}
                onClick={sendSentence}
                className="mt-3 inline-flex items-center justify-center gap-2 rounded-xl border border-[#35c7f2]/40 bg-gradient-to-r from-[#1c6fa8] to-[#35c7f2] px-4 py-3 text-[12px] font-black uppercase tracking-wide text-white shadow-[0_10px_30px_rgba(53,199,242,0.25)] transition hover:brightness-110 disabled:pointer-events-none disabled:opacity-40"
              >
                <Gavel className="h-4 w-4" />
                Send to Comserv
              </button>
            </div>
          </div>
        ) : (
          <div className="no-scrollbar relative min-h-0 flex-1 overflow-y-auto p-4">
            {active.length === 0 ? (
              <div className="flex h-full flex-col items-center justify-center gap-2 text-white/40">
                <Users className="h-8 w-8 opacity-50" />
                <p className="text-[12px]">No active community service sentences.</p>
              </div>
            ) : (
              <div className="space-y-2">
                {active.map((entry) => {
                  const done = Math.max(0, entry.total - entry.remaining);
                  const pct = Math.min(100, Math.round((done / Math.max(entry.total, 1)) * 100));
                  return (
                    <div
                      key={entry.identifier}
                      className="rounded-xl border border-white/10 bg-white/[0.03] p-3"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div className="min-w-0">
                          <div className="flex flex-wrap items-center gap-2">
                            <p className="truncate text-[13px] font-bold text-white">{entry.name}</p>
                            <span
                              className={cn(
                                "rounded-md px-1.5 py-0.5 text-[9px] font-bold uppercase",
                                entry.online
                                  ? "bg-emerald-500/15 text-emerald-300"
                                  : "bg-white/10 text-white/50"
                              )}
                            >
                              {entry.online ? `Online${entry.source ? ` #${entry.source}` : ""}` : "Offline"}
                            </span>
                          </div>
                          <p className="mt-1 text-[11px] text-white/55 line-clamp-2">{entry.reason}</p>
                          <div className="mt-2 grid gap-1 sm:grid-cols-2">
                            <DetailRow label="IP" value={entry.ip} />
                            <DetailRow label="Discord" value={entry.discord} />
                            <DetailRow label="Steam" value={entry.steam} />
                            <DetailRow label="License" value={entry.license} />
                          </div>
                          <p className="mt-1.5 flex flex-wrap items-center gap-x-3 gap-y-1 text-[10px] text-white/35">
                            <span>
                              By <span className="text-white/60">{entry.adminName}</span>
                            </span>
                            <span className="inline-flex items-center gap-1">
                              <Clock3 className="h-3 w-3" /> {formatTime(entry.createdAt)}
                            </span>
                          </p>
                        </div>

                        <button
                          type="button"
                          disabled={busy}
                          onClick={() => endSentence(entry)}
                          className="inline-flex shrink-0 items-center gap-1.5 rounded-lg border border-rose-400/30 bg-rose-500/15 px-2.5 py-1.5 text-[10px] font-bold uppercase text-rose-200 transition hover:bg-rose-500/25 disabled:opacity-40"
                        >
                          <Trash2 className="h-3 w-3" /> End
                        </button>
                      </div>

                      <div className="mt-3 flex items-end justify-between gap-2">
                        <p className="text-[11px] font-bold text-white">
                          {entry.remaining}
                          <span className="text-white/40"> / {entry.total} remaining</span>
                        </p>
                        <p className="text-[11px] font-bold text-[#8fe4ff]">{pct}%</p>
                      </div>
                      <div className="mt-1.5 h-1.5 overflow-hidden rounded-full bg-white/10">
                        <div
                          className="h-full rounded-full transition-all"
                          style={{
                            width: `${pct}%`,
                            background: "linear-gradient(90deg, #35c7f2, #ffd24c)",
                          }}
                        />
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
