import React, { useCallback, useEffect, useMemo, useState } from "react";
import {
  ChevronLeft,
  Contact,
  MessageSquare,
  Phone,
  Plus,
  Search,
  Trash2,
  UserPlus,
  Users,
  X,
} from "lucide-react";
import { AppChrome } from "./shared";

interface PhoneContact {
  id: number;
  name: string;
  number: string;
  note?: string | null;
  contactIdentifier?: string | null;
}

interface PlayerHit {
  serverId?: number;
  identifier?: string;
  name: string;
  number: string;
  online?: boolean;
}

type View = "list" | "add" | "detail";

export type ContactAction = {
  peerIdentifier?: string | null;
  contactId: number;
  name: string;
};

function asText(value: unknown, fallback = "") {
  if (value == null) return fallback;
  return String(value);
}

function isBrowser() {
  return (
    !(window as unknown as { invokeNative?: unknown }).invokeNative &&
    !navigator.userAgent.includes("FiveM")
  );
}

async function nui<T>(event: string, data: Record<string, unknown> = {}): Promise<T | null> {
  if (isBrowser()) {
    if (event.endsWith(":list")) {
      return {
        ok: true,
        contacts: [
          { id: 1, name: "Maya Cruz", number: "482-91-3371", note: "Mechanic" },
          { id: 2, name: "Rico Santos", number: "119-44-2088" },
        ],
      } as T;
    }
    if (event.endsWith(":online")) {
      return {
        ok: true,
        players: [
          { serverId: 12, identifier: "char1:demo", name: "Lana Reyes", number: "331-20-9910" },
          { serverId: 18, identifier: "char2:demo", name: "Jon Dela Cruz", number: "554-18-1022" },
        ],
      } as T;
    }
    if (event.endsWith(":search")) {
      return {
        ok: true,
        players: [
          {
            identifier: "char3:demo",
            name: "Ana Villanueva",
            number: "220-11-4455",
            online: false,
          },
        ],
      } as T;
    }
    if (event.endsWith(":add")) {
      return {
        ok: true,
        contact: {
          id: Date.now(),
          name: String(data.name || "New Contact"),
          number: String(data.number || "000-00-0000"),
          contactIdentifier: data.contactIdentifier,
        },
      } as T;
    }
    return { ok: true } as T;
  }

  const resourceName = (window as unknown as { GetParentResourceName?: () => string })
    .GetParentResourceName
    ? (window as unknown as { GetParentResourceName: () => string }).GetParentResourceName()
    : "kodebykarl-ui";

  try {
    const res = await fetch(`https://${resourceName}/${event}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(data),
    });
    return (await res.json()) as T;
  } catch {
    return null;
  }
}

function initials(name: string) {
  const parts = asText(name).trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "?";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return `${parts[0][0] || ""}${parts[1][0] || ""}`.toUpperCase();
}

function Avatar({ name, size = "md" }: { name: string; size?: "sm" | "md" | "lg" }) {
  const dim = size === "lg" ? "h-16 w-16 text-[22px]" : size === "sm" ? "h-9 w-9 text-[11px]" : "h-11 w-11 text-[13px]";
  return (
    <div
      className={`flex shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-[#2a3344] to-[#1a2030] font-black text-[#f5c542] ring-1 ring-white/10 ${dim}`}
    >
      {initials(name)}
    </div>
  );
}

export default function ContactsApp({
  onOpenMessage,
  onStartCall,
}: {
  onOpenMessage?: (opts: ContactAction) => void;
  onStartCall?: (opts: ContactAction) => void;
}) {
  const [view, setView] = useState<View>("list");
  const [contacts, setContacts] = useState<PhoneContact[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("");
  const [selected, setSelected] = useState<PhoneContact | null>(null);
  const [editName, setEditName] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Add flow
  const [addTab, setAddTab] = useState<"online" | "search" | "manual">("online");
  const [online, setOnline] = useState<PlayerHit[]>([]);
  const [searchQ, setSearchQ] = useState("");
  const [searchHits, setSearchHits] = useState<PlayerHit[]>([]);
  const [manualName, setManualName] = useState("");
  const [manualNumber, setManualNumber] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    const res = await nui<{ ok?: boolean; contacts?: PhoneContact[] }>("cfx-keydi-phone:contacts:list");
    setContacts(res?.contacts || []);
    setLoading(false);
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const filtered = useMemo(() => {
    const q = filter.trim().toLowerCase();
    if (!q) return contacts;
    return contacts.filter((c) => {
      const name = asText(c.name).toLowerCase();
      const number = asText(c.number).toLowerCase();
      return name.includes(q) || number.includes(q);
    });
  }, [contacts, filter]);

  const grouped = useMemo(() => {
    const map = new Map<string, PhoneContact[]>();
    for (const c of filtered) {
      const letter = (asText(c.name).trim()[0] || "#").toUpperCase();
      const key = /[A-Z]/.test(letter) ? letter : "#";
      if (!map.has(key)) map.set(key, []);
      map.get(key)!.push(c);
    }
    return [...map.entries()].sort(([a], [b]) => a.localeCompare(b));
  }, [filtered]);

  const openAdd = async () => {
    setError(null);
    setAddTab("online");
    setSearchQ("");
    setSearchHits([]);
    setManualName("");
    setManualNumber("");
    setView("add");
    const res = await nui<{ ok?: boolean; players?: PlayerHit[] }>("cfx-keydi-phone:contacts:online");
    setOnline(res?.players || []);
  };

  const openDetail = (c: PhoneContact) => {
    setSelected(c);
    setEditName(c.name);
    setError(null);
    setView("detail");
  };

  const savePlayer = async (p: PlayerHit) => {
    setBusy(true);
    setError(null);
    const payload: Record<string, unknown> = {
      name: p.name,
      number: p.number,
    };
    if (p.serverId) payload.serverId = p.serverId;
    if (p.identifier) payload.contactIdentifier = p.identifier;

    const res = await nui<{ ok?: boolean; error?: string; contact?: PhoneContact }>(
      "cfx-keydi-phone:contacts:add",
      payload,
    );
    setBusy(false);
    if (!res?.ok) {
      setError(res?.error || "Could not save contact");
      return;
    }
    await load();
    setView("list");
  };

  const saveManual = async () => {
    setBusy(true);
    setError(null);
    const res = await nui<{ ok?: boolean; error?: string }>("cfx-keydi-phone:contacts:add", {
      name: manualName,
      number: manualNumber,
    });
    setBusy(false);
    if (!res?.ok) {
      setError(res?.error || "Could not save contact");
      return;
    }
    await load();
    setView("list");
  };

  const runSearch = async (q: string) => {
    setSearchQ(q);
    if (q.trim().length < 2) {
      setSearchHits([]);
      return;
    }
    const res = await nui<{ ok?: boolean; players?: PlayerHit[] }>("cfx-keydi-phone:contacts:search", {
      query: q,
    });
    setSearchHits(res?.players || []);
  };

  const saveRename = async () => {
    if (!selected) return;
    setBusy(true);
    setError(null);
    const res = await nui<{ ok?: boolean; error?: string }>("cfx-keydi-phone:contacts:update", {
      id: selected.id,
      name: editName,
    });
    setBusy(false);
    if (!res?.ok) {
      setError(res?.error || "Update failed");
      return;
    }
    await load();
    setView("list");
  };

  const removeContact = async () => {
    if (!selected) return;
    setBusy(true);
    setError(null);
    const res = await nui<{ ok?: boolean; error?: string }>("cfx-keydi-phone:contacts:remove", {
      id: selected.id,
    });
    setBusy(false);
    if (!res?.ok) {
      setError(res?.error || "Delete failed");
      return;
    }
    await load();
    setView("list");
  };

  if (view === "add") {
    return (
      <AppChrome
        title="New Contact"
        dark
        right={
          <button
            type="button"
            onClick={() => setView("list")}
            className="rounded-full p-1.5 text-[#9a9386] active:bg-white/10"
            aria-label="Close"
          >
            <X className="h-4 w-4" />
          </button>
        }
      >
        <div className="flex min-h-full flex-col gap-3 bg-[#0c0e14] px-3 pb-12 pt-2">
          <div className="flex rounded-full bg-[#141720] p-1">
            {(
              [
                ["online", "Online"],
                ["search", "Search"],
                ["manual", "Manual"],
              ] as const
            ).map(([id, label]) => (
              <button
                key={id}
                type="button"
                onClick={() => setAddTab(id)}
                className={`flex-1 rounded-full py-1.5 text-[11px] font-bold tracking-wide ${
                  addTab === id ? "bg-[#f5c542] text-[#1a1408]" : "text-[#9a9386]"
                }`}
              >
                {label}
              </button>
            ))}
          </div>

          {error ? (
            <p className="rounded-xl border border-red-500/30 bg-red-500/10 px-3 py-2 text-[12px] text-red-300">
              {error}
            </p>
          ) : null}

          {addTab === "online" ? (
            <div className="space-y-2">
              <p className="px-1 text-[10px] font-black uppercase tracking-[0.16em] text-[#9a9386]">
                Players online
              </p>
              {online.length === 0 ? (
                <div className="rounded-2xl border border-white/8 bg-[#141720] px-4 py-10 text-center">
                  <Users className="mx-auto mb-2 h-7 w-7 text-[#5c564c]" />
                  <p className="text-[13px] text-[#9a9386]">No other players online to add.</p>
                </div>
              ) : (
                online.map((p) => (
                  <button
                    key={p.identifier || p.serverId}
                    type="button"
                    disabled={busy}
                    onClick={() => void savePlayer(p)}
                    className="flex w-full items-center gap-3 rounded-2xl border border-white/8 bg-[#141720] px-3 py-2.5 text-left transition active:scale-[0.98] disabled:opacity-50"
                  >
                    <Avatar name={p.name} size="sm" />
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-[14px] font-semibold text-[#f8f3e8]">{p.name}</p>
                      <p className="text-[11px] tabular-nums text-[#9a9386]">{p.number}</p>
                    </div>
                    <UserPlus className="h-4 w-4 text-[#f5c542]" />
                  </button>
                ))
              )}
            </div>
          ) : null}

          {addTab === "search" ? (
            <div className="space-y-2">
              <div className="flex items-center gap-2 rounded-2xl border border-white/8 bg-[#141720] px-3 py-2">
                <Search className="h-4 w-4 text-[#9a9386]" />
                <input
                  value={searchQ}
                  onChange={(e) => void runSearch(e.target.value)}
                  placeholder="Name or SSN…"
                  className="w-full bg-transparent text-[14px] text-[#f8f3e8] outline-none placeholder:text-[#5c564c]"
                />
              </div>
              {searchHits.length === 0 ? (
                <p className="py-8 text-center text-[12px] text-[#9a9386]">
                  {searchQ.trim().length < 2 ? "Type at least 2 characters." : "No players found."}
                </p>
              ) : (
                searchHits.map((p) => (
                  <button
                    key={p.identifier}
                    type="button"
                    disabled={busy}
                    onClick={() => void savePlayer(p)}
                    className="flex w-full items-center gap-3 rounded-2xl border border-white/8 bg-[#141720] px-3 py-2.5 text-left transition active:scale-[0.98] disabled:opacity-50"
                  >
                    <Avatar name={p.name} size="sm" />
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-[14px] font-semibold text-[#f8f3e8]">{p.name}</p>
                      <p className="text-[11px] tabular-nums text-[#9a9386]">
                        {p.number}
                        {p.online ? " · Online" : ""}
                      </p>
                    </div>
                    <UserPlus className="h-4 w-4 text-[#f5c542]" />
                  </button>
                ))
              )}
            </div>
          ) : null}

          {addTab === "manual" ? (
            <div className="space-y-3">
              <div className="space-y-1.5">
                <label className="px-1 text-[10px] font-black uppercase tracking-[0.16em] text-[#9a9386]">
                  Name
                </label>
                <input
                  value={manualName}
                  onChange={(e) => setManualName(e.target.value)}
                  placeholder="Contact name"
                  className="w-full rounded-2xl border border-white/8 bg-[#141720] px-3.5 py-3 text-[14px] text-[#f8f3e8] outline-none placeholder:text-[#5c564c] focus:border-[#f5c542]/40"
                />
              </div>
              <div className="space-y-1.5">
                <label className="px-1 text-[10px] font-black uppercase tracking-[0.16em] text-[#9a9386]">
                  Number / SSN
                </label>
                <input
                  value={manualNumber}
                  onChange={(e) => setManualNumber(e.target.value)}
                  placeholder="XXX-XX-XXXX"
                  className="w-full rounded-2xl border border-white/8 bg-[#141720] px-3.5 py-3 text-[14px] tabular-nums text-[#f8f3e8] outline-none placeholder:text-[#5c564c] focus:border-[#f5c542]/40"
                />
              </div>
              <button
                type="button"
                disabled={busy || !manualName.trim() || !manualNumber.trim()}
                onClick={() => void saveManual()}
                className="w-full rounded-2xl bg-[#f5c542] py-3 text-[14px] font-black text-[#1a1408] transition active:scale-[0.98] disabled:opacity-40"
              >
                Save contact
              </button>
            </div>
          ) : null}
        </div>
      </AppChrome>
    );
  }

  if (view === "detail" && selected) {
    return (
      <AppChrome
        title="Contact"
        dark
        right={
          <button
            type="button"
            onClick={() => setView("list")}
            className="rounded-full p-1.5 text-[#9a9386] active:bg-white/10"
            aria-label="Back"
          >
            <ChevronLeft className="h-4 w-4" />
          </button>
        }
      >
        <div className="flex min-h-full flex-col gap-4 bg-[#0c0e14] px-4 pb-12 pt-3">
          <div className="flex flex-col items-center gap-2 pt-2">
            <Avatar name={editName || selected.name} size="lg" />
            <p className="text-[11px] tabular-nums text-[#9a9386]">{selected.number}</p>
          </div>

          {error ? (
            <p className="rounded-xl border border-red-500/30 bg-red-500/10 px-3 py-2 text-[12px] text-red-300">
              {error}
            </p>
          ) : null}

          <div className="space-y-1.5">
            <label className="px-1 text-[10px] font-black uppercase tracking-[0.16em] text-[#9a9386]">
              Display name
            </label>
            <input
              value={editName}
              onChange={(e) => setEditName(e.target.value)}
              className="w-full rounded-2xl border border-white/8 bg-[#141720] px-3.5 py-3 text-[15px] font-semibold text-[#f8f3e8] outline-none focus:border-[#f5c542]/40"
            />
          </div>

          <button
            type="button"
            disabled={busy || !editName.trim()}
            onClick={() => void saveRename()}
            className="w-full rounded-2xl bg-[#f5c542] py-3 text-[14px] font-black text-[#1a1408] disabled:opacity-40"
          >
            Save changes
          </button>

          <div className="grid grid-cols-2 gap-2">
            <button
              type="button"
              disabled={busy}
              onClick={() =>
                onStartCall?.({
                  peerIdentifier: selected.contactIdentifier,
                  contactId: selected.id,
                  name: selected.name,
                })
              }
              className="flex items-center justify-center gap-2 rounded-2xl bg-[#30d158] py-3 text-[13px] font-black text-[#05240d] disabled:opacity-40"
            >
              <Phone className="h-4 w-4" />
              Call
            </button>
            <button
              type="button"
              disabled={busy}
              onClick={() =>
                onOpenMessage?.({
                  peerIdentifier: selected.contactIdentifier,
                  contactId: selected.id,
                  name: selected.name,
                })
              }
              className="flex items-center justify-center gap-2 rounded-2xl bg-[#007aff] py-3 text-[13px] font-black text-white disabled:opacity-40"
            >
              <MessageSquare className="h-4 w-4" />
              Message
            </button>
          </div>

          <button
            type="button"
            disabled={busy}
            onClick={() => void removeContact()}
            className="flex w-full items-center justify-center gap-2 rounded-2xl border border-red-500/25 bg-red-500/10 py-3 text-[13px] font-bold text-red-300"
          >
            <Trash2 className="h-4 w-4" />
            Delete contact
          </button>
        </div>
      </AppChrome>
    );
  }

  return (
    <AppChrome
      title="Contacts"
      dark
      right={
        <button
          type="button"
          onClick={() => void openAdd()}
          className="rounded-full bg-[#f5c542]/15 p-1.5 text-[#f5c542] active:scale-95"
          aria-label="Add contact"
        >
          <Plus className="h-4 w-4" strokeWidth={2.5} />
        </button>
      }
    >
      <div className="flex min-h-full flex-col gap-3 bg-gradient-to-b from-[#0c0e14] via-[#12141c] to-[#0a0c12] px-3 pb-12 pt-2">
        <div className="flex items-center gap-2 rounded-2xl border border-white/8 bg-[#141720] px-3 py-2">
          <Search className="h-4 w-4 text-[#9a9386]" />
          <input
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            placeholder="Search contacts"
            className="w-full bg-transparent text-[14px] text-[#f8f3e8] outline-none placeholder:text-[#5c564c]"
          />
        </div>

        <p className="px-1 text-[11px] text-[#9a9386]">
          {contacts.length} contact{contacts.length === 1 ? "" : "s"} · saved to your account
        </p>

        {loading && contacts.length === 0 ? (
          <p className="py-12 text-center text-[13px] text-[#9a9386]">Loading…</p>
        ) : filtered.length === 0 ? (
          <div className="rounded-2xl border border-white/8 bg-[#141720] px-4 py-12 text-center">
            <Contact className="mx-auto mb-3 h-8 w-8 text-[#5c564c]" />
            <p className="text-[14px] font-semibold text-[#f8f3e8]">No contacts yet</p>
            <p className="mt-1 text-[12px] text-[#9a9386]">
              Tap + to save another player. Contacts stay in the database.
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            {grouped.map(([letter, rows]) => (
              <div key={letter}>
                <p className="mb-1.5 px-1 text-[10px] font-black uppercase tracking-[0.18em] text-[#f5c542]/80">
                  {letter}
                </p>
                <div className="overflow-hidden rounded-2xl border border-white/8 bg-[#141720]">
                  {rows.map((c, i) => (
                    <button
                      key={c.id}
                      type="button"
                      onClick={() => openDetail(c)}
                      className={`flex w-full items-center gap-3 px-3 py-2.5 text-left transition active:bg-white/5 ${
                        i > 0 ? "border-t border-white/6" : ""
                      }`}
                    >
                      <Avatar name={c.name} size="sm" />
                      <div className="min-w-0 flex-1">
                        <p className="truncate text-[14px] font-semibold text-[#f8f3e8]">{c.name}</p>
                        <p className="text-[11px] tabular-nums text-[#9a9386]">{c.number}</p>
                      </div>
                    </button>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </AppChrome>
  );
}
