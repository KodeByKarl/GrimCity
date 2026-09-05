import { useEffect, useMemo, useState } from "react";
import { Ban, Pencil, RefreshCw, Search, UserPlus } from "lucide-react";
import { cn } from "@/lib/utils";
import { fetchNui } from "@/lib/nui";
import {
  EMPTY_VIP,
  type VipDurationUnit,
  type VipMembership,
  type VipPlayerRow,
  type VipTierOption,
} from "./types";

interface VipStaffPanelProps {
  onOwnStatusChanged: () => void;
}

const DURATION_PRESETS: { label: string; amount: number; unit: VipDurationUnit }[] = [
  { label: "1 mo", amount: 1, unit: "months" },
  { label: "3 mo", amount: 3, unit: "months" },
  { label: "6 mo", amount: 6, unit: "months" },
  { label: "12 mo", amount: 12, unit: "months" },
  { label: "30 d", amount: 30, unit: "days" },
];

function formatDate(iso: string | null) {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function previewRevokeAt(amount: number, unit: VipDurationUnit) {
  if (!Number.isFinite(amount) || amount < 1) return null;
  const d = new Date();
  if (unit === "months") d.setMonth(d.getMonth() + amount);
  else d.setDate(d.getDate() + amount);
  return d.toISOString();
}

export default function VipStaffPanel({ onOwnStatusChanged }: VipStaffPanelProps) {
  const [mode, setMode] = useState<"set" | "edit">("set");
  const [tiers, setTiers] = useState<VipTierOption[]>([]);
  const [players, setPlayers] = useState<VipPlayerRow[]>([]);
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const [selected, setSelected] = useState<VipPlayerRow | null>(null);
  const [tier, setTier] = useState("vip3");
  const [amount, setAmount] = useState(1);
  const [unit, setUnit] = useState<VipDurationUnit>("months");
  const [autoRenew, setAutoRenew] = useState(false);
  const [keepExpiry, setKeepExpiry] = useState(false);
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState<{ ok: boolean; text: string } | null>(null);

  const loadRoster = () => {
    setLoading(true);
    fetchNui<{
      ok?: boolean;
      tiers?: VipTierOption[];
      players?: VipPlayerRow[];
    }>("cfx-keydi-vip:staffRoster", {})
      .then((res) => {
        if (res?.tiers?.length) setTiers(res.tiers);
        if (res?.players) setPlayers(res.players);
      })
      .catch(() => undefined)
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    loadRoster();
  }, []);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return players;
    return players.filter(
      (p) => String(p.id).includes(q) || p.name.toLowerCase().includes(q)
    );
  }, [players, query]);

  const applyPlayer = (row: VipPlayerRow) => {
    setSelectedId(row.id);
    setSelected(row);
    setQuery(String(row.id));
    setMessage(null);
    if (row.vip?.active) {
      setMode("edit");
      setTier(row.vip.tier || "vip1");
      setAutoRenew(!!row.vip.autoRenew);
      setKeepExpiry(true);
    } else {
      setMode("set");
      setKeepExpiry(false);
    }
  };

  const lookupId = async () => {
    const id = Number.parseInt(query, 10);
    if (!Number.isFinite(id) || id < 1) {
      setMessage({ ok: false, text: "Enter a valid player ID." });
      return;
    }
    const fromList = players.find((p) => p.id === id);
    if (fromList) {
      applyPlayer(fromList);
      return;
    }
    setBusy(true);
    try {
      const res = await fetchNui<{ ok?: boolean; error?: string; player?: VipPlayerRow }>(
        "cfx-keydi-vip:staffLookup",
        { targetId: id }
      );
      if (res?.ok && res.player) applyPlayer(res.player);
      else setMessage({ ok: false, text: res?.error || "Player not found." });
    } catch {
      setMessage({ ok: false, text: "Lookup failed." });
    } finally {
      setBusy(false);
    }
  };

  const revokePreview = keepExpiry && mode === "edit" && selected?.vip?.active
    ? selected.vip.expiresAt
    : previewRevokeAt(amount, unit);

  const submit = async () => {
    if (!selectedId) {
      setMessage({ ok: false, text: "Select a player first." });
      return;
    }
    if (mode === "edit" && !selected?.vip?.active) {
      setMessage({ ok: false, text: "Player has no VIP. Use Set New." });
      return;
    }
    const useKeep = mode === "edit" && keepExpiry;
    if (!useKeep && (!Number.isFinite(amount) || amount < 1)) {
      setMessage({ ok: false, text: "Enter duration until revoke." });
      return;
    }

    setBusy(true);
    setMessage(null);
    try {
      const res = await fetchNui<{
        ok?: boolean;
        error?: string;
        vip?: VipMembership;
        players?: VipPlayerRow[];
      }>("cfx-keydi-vip:staffSet", {
        targetId: selectedId,
        tier,
        amount,
        unit,
        autoRenew,
        keepExpiry: useKeep,
      });
      if (!res?.ok) {
        setMessage({ ok: false, text: res?.error || "Could not save VIP." });
        return;
      }
      if (res.players) setPlayers(res.players);
      if (res.vip) {
        setSelected((prev) =>
          prev ? { ...prev, vip: res.vip as VipMembership } : prev
        );
      }
      setMessage({
        ok: true,
        text: mode === "edit" ? "VIP updated." : "VIP granted.",
      });
      onOwnStatusChanged();
    } catch {
      setMessage({ ok: false, text: "Could not save VIP." });
    } finally {
      setBusy(false);
    }
  };

  const revoke = async () => {
    if (!selectedId) {
      setMessage({ ok: false, text: "Select a player first." });
      return;
    }
    setBusy(true);
    setMessage(null);
    try {
      const res = await fetchNui<{
        ok?: boolean;
        error?: string;
        vip?: VipMembership;
        players?: VipPlayerRow[];
      }>("cfx-keydi-vip:staffRevoke", { targetId: selectedId });
      if (!res?.ok) {
        setMessage({ ok: false, text: res?.error || "Could not revoke VIP." });
        return;
      }
      if (res.players) setPlayers(res.players);
      setSelected((prev) =>
        prev ? { ...prev, vip: res.vip || EMPTY_VIP } : prev
      );
      setMode("set");
      setKeepExpiry(false);
      setMessage({ ok: true, text: "VIP revoked." });
      onOwnStatusChanged();
    } catch {
      setMessage({ ok: false, text: "Could not revoke VIP." });
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="rounded-xl border border-[#ff3a3a]/40 bg-[#181216] p-3.5">
      <div className="mb-3 flex items-center justify-between gap-2">
        <div>
          <p className="text-[9px] font-black uppercase tracking-[0.18em] text-[#ff4d4d]">
            Set VIP
          </p>
          <p className="mt-0.5 text-[10px] text-[#a08890]">
            Grant a new plan or edit an existing one. Duration is when VIP is revoked.
          </p>
        </div>
        <button
          type="button"
          onClick={loadRoster}
          disabled={loading}
          className="flex cursor-pointer items-center gap-1 rounded-lg border border-white/10 bg-black/40 px-2 py-1 text-[9px] font-black uppercase tracking-wider text-white transition hover:border-white/30"
        >
          <RefreshCw className={cn("h-3 w-3", loading && "animate-spin")} />
          Players
        </button>
      </div>

      <div className="mb-3 grid grid-cols-2 gap-1.5">
        <button
          type="button"
          onClick={() => {
            setMode("set");
            setKeepExpiry(false);
            setMessage(null);
          }}
          className={cn(
            "flex cursor-pointer items-center justify-center gap-1.5 rounded-lg border px-2 py-1.5 text-[10px] font-black uppercase tracking-wider transition",
            mode === "set"
              ? "border-[#ff3a3a] bg-[#ff3a3a]/20 text-white"
              : "border-white/10 bg-black/30 text-[#a08890] hover:border-white/25"
          )}
        >
          <UserPlus className="h-3.5 w-3.5" />
          Set New
        </button>
        <button
          type="button"
          onClick={() => {
            setMode("edit");
            setKeepExpiry(true);
            setMessage(null);
          }}
          className={cn(
            "flex cursor-pointer items-center justify-center gap-1.5 rounded-lg border px-2 py-1.5 text-[10px] font-black uppercase tracking-wider transition",
            mode === "edit"
              ? "border-[#ff3a3a] bg-[#ff3a3a]/20 text-white"
              : "border-white/10 bg-black/30 text-[#a08890] hover:border-white/25"
          )}
        >
          <Pencil className="h-3.5 w-3.5" />
          Edit
        </button>
      </div>

      <div className="mb-2 flex gap-1.5">
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              e.preventDefault();
              lookupId();
            }
          }}
          placeholder="Search name or ID"
          className="min-w-0 flex-1 rounded-lg border border-white/10 bg-black/40 px-2.5 py-1.5 text-[11px] text-white outline-none placeholder:text-[#6d5a62] focus:border-[#ff3a3a]/60"
        />
        <button
          type="button"
          onClick={lookupId}
          disabled={busy}
          className="flex cursor-pointer items-center gap-1 rounded-lg border border-[#ff3a3a]/40 bg-[#ff3a3a]/15 px-2.5 py-1.5 text-[10px] font-black uppercase tracking-wider text-white transition hover:border-[#ff3a3a]"
        >
          <Search className="h-3.5 w-3.5" />
          Load
        </button>
      </div>

      <div className="mb-3 max-h-[92px] overflow-y-auto rounded-lg border border-white/10 bg-black/30 custom-scrollbar">
        {loading ? (
          <p className="px-2.5 py-2 text-[10px] text-[#a08890]">Loading players...</p>
        ) : filtered.length === 0 ? (
          <p className="px-2.5 py-2 text-[10px] text-[#a08890]">No online players match.</p>
        ) : (
          filtered.map((p) => (
            <button
              key={p.id}
              type="button"
              onClick={() => applyPlayer(p)}
              className={cn(
                "flex w-full cursor-pointer items-center justify-between gap-2 border-b border-white/5 px-2.5 py-1.5 text-left last:border-b-0",
                selectedId === p.id ? "bg-[#ff3a3a]/15" : "hover:bg-white/5"
              )}
            >
              <span className="truncate text-[11px] font-semibold text-white">
                #{p.id} {p.name}
              </span>
              <span
                className={cn(
                  "shrink-0 text-[9px] font-black uppercase tracking-wider",
                  p.vip?.active ? "text-[#ff8080]" : "text-[#6d5a62]"
                )}
              >
                {p.vip?.active ? p.vip.label : "None"}
              </span>
            </button>
          ))
        )}
      </div>

      {selected && (
        <div className="mb-3 rounded-lg border border-white/10 bg-black/30 px-2.5 py-2">
          <p className="text-[11px] font-black text-white">
            #{selected.id} {selected.name}
          </p>
          <p className="mt-0.5 text-[10px] text-[#a08890]">
            {selected.vip?.active
              ? `${selected.vip.label} · revokes ${formatDate(selected.vip.expiresAt)}`
              : "No active VIP"}
          </p>
        </div>
      )}

      {mode === "edit" && selected && !selected.vip?.active && (
        <p className="mb-3 text-[10px] text-amber-300">
          This player has no VIP. Switch to Set New to grant one.
        </p>
      )}

      <label className="mb-2 block">
        <span className="mb-1 block text-[9px] font-bold uppercase tracking-wider text-[#a08890]">
          Tier
        </span>
        <select
          value={tier}
          onChange={(e) => setTier(e.target.value)}
          className="w-full cursor-pointer rounded-lg border border-white/10 bg-black/40 px-2.5 py-1.5 text-[11px] text-white outline-none focus:border-[#ff3a3a]/60"
        >
          {(tiers.length ? tiers : [
            { id: "vip1", label: "VIP 1", characterSlots: 1 },
            { id: "vip2", label: "VIP 2", characterSlots: 2 },
            { id: "vip3", label: "VIP 3", characterSlots: 3 },
            { id: "vip4", label: "VIP 4", characterSlots: 3 },
            { id: "vip5", label: "VIP 5", characterSlots: 3 },
          ]).map((t) => (
            <option key={t.id} value={t.id}>
              {t.label} · {t.characterSlots} slot{t.characterSlots === 1 ? "" : "s"}
            </option>
          ))}
        </select>
      </label>

      {mode === "edit" && selected?.vip?.active && (
        <label className="mb-2 flex cursor-pointer items-center gap-2 text-[11px] text-white/85">
          <input
            type="checkbox"
            checked={keepExpiry}
            onChange={(e) => setKeepExpiry(e.target.checked)}
            className="accent-[#ff3a3a]"
          />
          Keep current revoke date
        </label>
      )}

      {!(mode === "edit" && keepExpiry) && (
        <>
          <div className="mb-2 grid grid-cols-[1fr_auto] gap-1.5">
            <label>
              <span className="mb-1 block text-[9px] font-bold uppercase tracking-wider text-[#a08890]">
                Duration
              </span>
              <input
                type="number"
                min={1}
                max={unit === "months" ? 120 : 3650}
                value={amount}
                onChange={(e) => setAmount(Number(e.target.value))}
                className="w-full rounded-lg border border-white/10 bg-black/40 px-2.5 py-1.5 text-[11px] text-white outline-none focus:border-[#ff3a3a]/60"
              />
            </label>
            <div>
              <span className="mb-1 block text-[9px] font-bold uppercase tracking-wider text-[#a08890]">
                Unit
              </span>
              <div className="flex rounded-lg border border-white/10 bg-black/40 p-0.5">
                {(["days", "months"] as VipDurationUnit[]).map((u) => (
                  <button
                    key={u}
                    type="button"
                    onClick={() => setUnit(u)}
                    className={cn(
                      "cursor-pointer rounded-md px-2.5 py-1 text-[10px] font-black uppercase tracking-wider",
                      unit === u ? "bg-[#ff3a3a] text-white" : "text-[#a08890]"
                    )}
                  >
                    {u}
                  </button>
                ))}
              </div>
            </div>
          </div>

          <div className="mb-2 flex flex-wrap gap-1">
            {DURATION_PRESETS.map((p) => (
              <button
                key={p.label}
                type="button"
                onClick={() => {
                  setAmount(p.amount);
                  setUnit(p.unit);
                }}
                className={cn(
                  "cursor-pointer rounded-md border px-2 py-0.5 text-[9px] font-black uppercase tracking-wider",
                  amount === p.amount && unit === p.unit
                    ? "border-[#ff3a3a] bg-[#ff3a3a]/20 text-white"
                    : "border-white/10 text-[#a08890] hover:border-white/25"
                )}
              >
                {p.label}
              </button>
            ))}
          </div>
        </>
      )}

      <p className="mb-2 text-[10px] text-[#a08890]">
        Revokes{" "}
        <span className="font-semibold text-white">{formatDate(revokePreview)}</span>
      </p>

      <label className="mb-3 flex cursor-pointer items-center gap-2 text-[11px] text-white/85">
        <input
          type="checkbox"
          checked={autoRenew}
          onChange={(e) => setAutoRenew(e.target.checked)}
          className="accent-[#ff3a3a]"
        />
        Auto-renew
      </label>

      {message && (
        <p className={cn("mb-2 text-[10px]", message.ok ? "text-emerald-400" : "text-red-400")}>
          {message.text}
        </p>
      )}

      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          disabled={busy || !selectedId || (mode === "edit" && !selected?.vip?.active)}
          onClick={submit}
          className="cursor-pointer rounded-lg border border-[#ff3a3a] bg-[#ff3a3a] px-3 py-1.5 text-[10px] font-black uppercase tracking-wider text-white transition hover:brightness-110 disabled:cursor-not-allowed disabled:opacity-40"
        >
          {mode === "edit" ? "Save Edit" : "Grant VIP"}
        </button>
        {selected?.vip?.active && (
          <button
            type="button"
            disabled={busy}
            onClick={revoke}
            className="flex cursor-pointer items-center gap-1 rounded-lg border border-red-500/50 bg-red-500/15 px-3 py-1.5 text-[10px] font-black uppercase tracking-wider text-red-300 transition hover:border-red-400 disabled:opacity-40"
          >
            <Ban className="h-3 w-3" />
            Revoke
          </button>
        )}
      </div>
    </div>
  );
}
