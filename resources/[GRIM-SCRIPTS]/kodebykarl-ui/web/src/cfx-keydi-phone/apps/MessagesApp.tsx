import React, { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { ChevronLeft, MessageSquare, Phone, Plus, Search, Send, X } from "lucide-react";
import { AppChrome } from "./shared";

interface Conversation {
  peerIdentifier: string;
  name: string;
  number?: string | null;
  lastBody: string;
  lastAt?: string;
  lastFromMe?: boolean;
  unread?: number;
}

interface ChatMessage {
  id: number;
  body: string;
  fromMe: boolean;
  createdAt?: string;
}

interface ContactRow {
  id: number;
  name: string;
  number: string;
  contactIdentifier?: string | null;
}

type View = "inbox" | "chat" | "compose";

export type MessagePeer = {
  peerIdentifier?: string | null;
  contactId?: number;
  name?: string;
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
    if (event.endsWith(":conversations")) {
      return {
        ok: true,
        unreadTotal: 1,
        conversations: [
          {
            peerIdentifier: "char1:demo",
            name: "Maya Cruz",
            number: "482-91-3371",
            lastBody: "Saan ka?",
            lastAt: "2026-09-06 23:10:00",
            lastFromMe: false,
            unread: 1,
          },
          {
            peerIdentifier: "char2:demo",
            name: "Rico Santos",
            number: "119-44-2088",
            lastBody: "Ok sige",
            lastAt: "2026-09-06 21:02:00",
            lastFromMe: true,
            unread: 0,
          },
        ],
      } as T;
    }
    if (event.endsWith(":thread")) {
      return {
        ok: true,
        peerIdentifier: data.peerIdentifier || "char1:demo",
        name: "Maya Cruz",
        number: "482-91-3371",
        messages: [
          { id: 1, body: "Hoy", fromMe: true, createdAt: "2026-09-06 23:00:00" },
          { id: 2, body: "Saan ka?", fromMe: false, createdAt: "2026-09-06 23:10:00" },
        ],
      } as T;
    }
    if (event.endsWith(":send")) {
      return {
        ok: true,
        message: {
          id: Date.now(),
          body: String(data.body || ""),
          fromMe: true,
          createdAt: new Date().toISOString(),
          peerIdentifier: data.peerIdentifier,
        },
      } as T;
    }
    if (event.includes("contacts:list")) {
      return {
        ok: true,
        contacts: [
          { id: 1, name: "Maya Cruz", number: "482-91-3371", contactIdentifier: "char1:demo" },
          { id: 2, name: "Rico Santos", number: "119-44-2088", contactIdentifier: "char2:demo" },
        ],
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

function Avatar({ name }: { name: string }) {
  return (
    <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-[#2a3344] to-[#1a2030] text-[12px] font-black text-[#f5c542] ring-1 ring-white/10">
      {initials(name)}
    </div>
  );
}

function formatTime(value?: string | number | null) {
  if (value == null || value === "") return "";
  try {
    let d: Date;
    if (typeof value === "number" && Number.isFinite(value)) {
      d = new Date(value < 1e12 ? value * 1000 : value);
    } else {
      const s = asText(value);
      if (!s) return "";
      if (/^\d+(\.\d+)?$/.test(s)) {
        const n = Number(s);
        d = new Date(n < 1e12 ? n * 1000 : n);
      } else {
        d = new Date(s.includes("T") ? s : s.replace(" ", "T"));
      }
    }
    if (Number.isNaN(d.getTime())) return "";
    return d.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  } catch {
    return "";
  }
}

export default function MessagesApp({
  startPeer,
  onStartCall,
}: {
  startPeer?: MessagePeer | null;
  onStartCall?: (opts: { peerIdentifier?: string | null; contactId?: number; name: string }) => void;
}) {
  const [view, setView] = useState<View>("inbox");
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("");
  const [error, setError] = useState<string | null>(null);

  const [peerId, setPeerId] = useState<string | null>(null);
  const [peerName, setPeerName] = useState("");
  const [peerNumber, setPeerNumber] = useState<string | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [draft, setDraft] = useState("");
  const [busy, setBusy] = useState(false);

  const [contacts, setContacts] = useState<ContactRow[]>([]);
  const [composeFilter, setComposeFilter] = useState("");

  const bottomRef = useRef<HTMLDivElement | null>(null);
  const peerIdRef = useRef<string | null>(null);

  useEffect(() => {
    peerIdRef.current = peerId;
  }, [peerId]);

  const loadInbox = useCallback(async () => {
    setLoading(true);
    const res = await nui<{ ok?: boolean; conversations?: Conversation[] }>(
      "cfx-keydi-phone:messages:conversations",
    );
    setConversations(res?.conversations || []);
    setLoading(false);
  }, []);

  useEffect(() => {
    void loadInbox();
  }, [loadInbox]);

  useEffect(() => {
    const onMsg = (event: MessageEvent) => {
      const data = event.data;
      if (!data || data.action !== "cfx-keydi-phone:message") return;
      const payload = data.data || {};
      const fromId = payload.fromIdentifier as string | undefined;
      if (!fromId) return;

      if (peerIdRef.current === fromId && view === "chat") {
        setMessages((prev) => {
          if (prev.some((m) => m.id === payload.id)) return prev;
          return [
            ...prev,
            {
              id: Number(payload.id) || Date.now(),
              body: String(payload.body || ""),
              fromMe: false,
              createdAt: payload.createdAt,
            },
          ];
        });
        void nui("cfx-keydi-phone:messages:thread", { peerIdentifier: fromId });
      } else {
        void loadInbox();
      }
    };
    window.addEventListener("message", onMsg);
    return () => window.removeEventListener("message", onMsg);
  }, [loadInbox, view]);

  useEffect(() => {
    if (view === "chat") {
      bottomRef.current?.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages, view]);

  const filteredInbox = useMemo(() => {
    const q = filter.trim().toLowerCase();
    if (!q) return conversations;
    return conversations.filter((c) => {
      const name = asText(c.name).toLowerCase();
      const number = asText(c.number).toLowerCase();
      const body = asText(c.lastBody).toLowerCase();
      return name.includes(q) || number.includes(q) || body.includes(q);
    });
  }, [conversations, filter]);

  const openThread = async (
    peer?: string | null,
    fallbackName?: string,
    extra?: { contactId?: number },
  ) => {
    setError(null);
    setBusy(true);
    setPeerId(peer || null);
    setPeerName(fallbackName || "Chat");
    setView("chat");
    const res = await nui<{
      ok?: boolean;
      error?: string;
      name?: string;
      number?: string;
      peerIdentifier?: string;
      messages?: ChatMessage[];
    }>("cfx-keydi-phone:messages:thread", {
      peerIdentifier: peer || undefined,
      contactId: extra?.contactId,
    });
    setBusy(false);
    if (!res?.ok) {
      setError(res?.error || "Could not open chat");
      return;
    }
    setPeerId(res.peerIdentifier || peer);
    setPeerName(res.name || fallbackName || "Chat");
    setPeerNumber(res.number || null);
    setMessages(res.messages || []);
    void loadInbox();
  };

  const openCompose = async () => {
    setError(null);
    setComposeFilter("");
    setView("compose");
    const res = await nui<{ ok?: boolean; contacts?: ContactRow[] }>("cfx-keydi-phone:contacts:list");
    setContacts((res?.contacts || []).filter((c) => !!c.contactIdentifier || !!c.id));
  };

  useEffect(() => {
    if (!startPeer) return;
    if (startPeer.peerIdentifier) {
      void openThread(startPeer.peerIdentifier, startPeer.name, { contactId: startPeer.contactId });
    } else if (startPeer.contactId) {
      void openThread(null, startPeer.name, { contactId: startPeer.contactId });
    }
    // openThread is recreated each render; only react to the incoming peer payload
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [startPeer]);

  const send = async () => {
    if (!peerId || !draft.trim() || busy) return;
    const body = draft.trim();
    setBusy(true);
    setError(null);
    const res = await nui<{
      ok?: boolean;
      error?: string;
      message?: ChatMessage & { peerIdentifier?: string };
    }>("cfx-keydi-phone:messages:send", {
      peerIdentifier: peerId,
      body,
    });
    setBusy(false);
    if (!res?.ok || !res.message) {
      setError(res?.error || "Failed to send");
      return;
    }
    setDraft("");
    setMessages((prev) => [...prev, res.message!]);
    void loadInbox();
  };

  const composeFiltered = useMemo(() => {
    const q = composeFilter.trim().toLowerCase();
    if (!q) return contacts;
    return contacts.filter((c) => {
      const name = asText(c.name).toLowerCase();
      const number = asText(c.number).toLowerCase();
      return name.includes(q) || number.includes(q);
    });
  }, [contacts, composeFilter]);

  if (view === "compose") {
    return (
      <AppChrome
        title="New Message"
        dark
        right={
          <button
            type="button"
            onClick={() => setView("inbox")}
            className="rounded-full p-1.5 text-[#9a9386] active:bg-white/10"
          >
            <X className="h-4 w-4" />
          </button>
        }
      >
        <div className="flex min-h-full flex-col gap-3 bg-[#0c0e14] px-3 pb-12 pt-2">
          <div className="flex items-center gap-2 rounded-2xl border border-white/8 bg-[#141720] px-3 py-2">
            <Search className="h-4 w-4 text-[#9a9386]" />
            <input
              value={composeFilter}
              onChange={(e) => setComposeFilter(e.target.value)}
              placeholder="Search contacts"
              className="w-full bg-transparent text-[14px] text-[#f8f3e8] outline-none placeholder:text-[#5c564c]"
            />
          </div>

          {composeFiltered.length === 0 ? (
            <div className="rounded-2xl border border-white/8 bg-[#141720] px-4 py-10 text-center">
              <p className="text-[13px] text-[#9a9386]">
                Save a player in Contacts first, then message them here.
              </p>
            </div>
          ) : (
            <div className="space-y-2">
              {composeFiltered.map((c) => (
                <button
                  key={c.id}
                  type="button"
                  onClick={() => void openThread(c.contactIdentifier, c.name, { contactId: c.id })}
                  className="flex w-full items-center gap-3 rounded-2xl border border-white/8 bg-[#141720] px-3 py-2.5 text-left active:scale-[0.98]"
                >
                  <Avatar name={c.name} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-[14px] font-semibold text-[#f8f3e8]">{c.name}</p>
                    <p className="text-[11px] tabular-nums text-[#9a9386]">{c.number}</p>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      </AppChrome>
    );
  }

  if (view === "chat") {
    return (
      <AppChrome
        title={peerName}
        dark
        right={
          <div className="flex items-center gap-0.5">
            {onStartCall && peerId ? (
              <button
                type="button"
                onClick={() => onStartCall({ peerIdentifier: peerId, name: peerName })}
                className="rounded-full p-1.5 text-[#30d158] active:bg-white/10"
                aria-label="Call"
              >
                <Phone className="h-4 w-4" />
              </button>
            ) : null}
            <button
              type="button"
              onClick={() => {
                setView("inbox");
                setPeerId(null);
                void loadInbox();
              }}
              className="rounded-full p-1.5 text-[#9a9386] active:bg-white/10"
            >
              <ChevronLeft className="h-4 w-4" />
            </button>
          </div>
        }
      >
        <div className="flex h-full min-h-0 flex-col bg-[#0c0e14]">
          {peerNumber ? (
            <p className="-mt-1 mb-1 px-3 text-center text-[10px] tabular-nums text-[#9a9386]">
              {peerNumber}
            </p>
          ) : null}

          {error ? (
            <p className="mx-3 mb-2 rounded-xl border border-red-500/30 bg-red-500/10 px-3 py-2 text-[12px] text-red-300">
              {error}
            </p>
          ) : null}

          <div className="no-scrollbar min-h-0 flex-1 space-y-2 overflow-y-auto px-3 pb-2 pt-1">
            {messages.length === 0 ? (
              <p className="py-10 text-center text-[12px] text-[#9a9386]">Say hello — messages are saved.</p>
            ) : (
              messages.map((m) => (
                <div key={m.id} className={`flex ${m.fromMe ? "justify-end" : "justify-start"}`}>
                  <div
                    className={`max-w-[82%] rounded-2xl px-3 py-2 text-[13px] leading-snug ${
                      m.fromMe
                        ? "rounded-br-md bg-[#f5c542] text-[#1a1408]"
                        : "rounded-bl-md border border-white/8 bg-[#1a2030] text-[#f8f3e8]"
                    }`}
                  >
                    <p className="whitespace-pre-wrap break-words">{asText(m.body)}</p>
                    <p
                      className={`mt-1 text-[9px] ${
                        m.fromMe ? "text-[#1a1408]/55" : "text-[#9a9386]"
                      }`}
                    >
                      {formatTime(m.createdAt)}
                    </p>
                  </div>
                </div>
              ))
            )}
            <div ref={bottomRef} />
          </div>

          <div className="border-t border-white/8 bg-[#0c0e14] px-3 pb-10 pt-2">
            <div className="flex items-end gap-2">
              <textarea
                value={draft}
                onChange={(e) => setDraft(e.target.value.slice(0, 500))}
                onKeyDown={(e) => {
                  if (e.key === "Enter" && !e.shiftKey) {
                    e.preventDefault();
                    void send();
                  }
                }}
                rows={1}
                placeholder="iMessage"
                className="max-h-24 min-h-[38px] flex-1 resize-none rounded-2xl border border-white/8 bg-[#141720] px-3 py-2.5 text-[13px] text-[#f8f3e8] outline-none placeholder:text-[#5c564c] focus:border-[#f5c542]/35"
              />
              <button
                type="button"
                disabled={busy || !draft.trim()}
                onClick={() => void send()}
                className="flex h-[38px] w-[38px] shrink-0 items-center justify-center rounded-full bg-[#f5c542] text-[#1a1408] disabled:opacity-40"
              >
                <Send className="h-4 w-4" />
              </button>
            </div>
          </div>
        </div>
      </AppChrome>
    );
  }

  return (
    <AppChrome
      title="Messages"
      dark
      right={
        <button
          type="button"
          onClick={() => void openCompose()}
          className="rounded-full bg-[#f5c542]/15 p-1.5 text-[#f5c542] active:scale-95"
          aria-label="New message"
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
            placeholder="Search"
            className="w-full bg-transparent text-[14px] text-[#f8f3e8] outline-none placeholder:text-[#5c564c]"
          />
        </div>

        {loading && conversations.length === 0 ? (
          <p className="py-12 text-center text-[13px] text-[#9a9386]">Loading…</p>
        ) : filteredInbox.length === 0 ? (
          <div className="rounded-2xl border border-white/8 bg-[#141720] px-4 py-12 text-center">
            <MessageSquare className="mx-auto mb-3 h-8 w-8 text-[#5c564c]" />
            <p className="text-[14px] font-semibold text-[#f8f3e8]">No messages yet</p>
            <p className="mt-1 text-[12px] text-[#9a9386]">
              Tap + and pick a contact. Conversations save to the database.
            </p>
          </div>
        ) : (
          <div className="overflow-hidden rounded-2xl border border-white/8 bg-[#141720]">
            {filteredInbox.map((c, i) => (
              <button
                key={c.peerIdentifier}
                type="button"
                onClick={() => void openThread(c.peerIdentifier, c.name)}
                className={`flex w-full items-center gap-3 px-3 py-2.5 text-left transition active:bg-white/5 ${
                  i > 0 ? "border-t border-white/6" : ""
                }`}
              >
                <Avatar name={c.name} />
                <div className="min-w-0 flex-1">
                  <div className="flex items-center justify-between gap-2">
                    <p className="truncate text-[14px] font-semibold text-[#f8f3e8]">{c.name}</p>
                    <span className="shrink-0 text-[10px] text-[#9a9386]">{formatTime(c.lastAt)}</span>
                  </div>
                  <div className="mt-0.5 flex items-center gap-2">
                    <p className="min-w-0 flex-1 truncate text-[12px] text-[#9a9386]">
                      {asText(c.lastFromMe ? "You: " : "")}
                      {asText(c.lastBody)}
                    </p>
                    {(c.unread || 0) > 0 ? (
                      <span className="flex h-5 min-w-5 shrink-0 items-center justify-center rounded-full bg-[#f5c542] px-1.5 text-[10px] font-black text-[#1a1408]">
                        {c.unread}
                      </span>
                    ) : null}
                  </div>
                </div>
              </button>
            ))}
          </div>
        )}
      </div>
    </AppChrome>
  );
}
