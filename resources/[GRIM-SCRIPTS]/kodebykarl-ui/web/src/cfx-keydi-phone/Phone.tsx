import React, { Component, Suspense, lazy, useCallback, useEffect, useMemo, useRef, useState } from "react";
import { cn } from "@/lib/utils";
import {
  BatteryFull,
  Signal,
  Wifi,
  Flashlight,
  Camera,
  MessageCircle,
  Wallet,
  Store,
  Contact,
  MessageSquare,
  Settings,
  Phone as PhoneIcon,
  PhoneOff,
} from "lucide-react";
import PlaceholderApp from "./apps/PlaceholderApp";
import type { MessagePeer } from "./apps/MessagesApp";
import type { ContactAction } from "./apps/ContactsApp";

const WalletApp = lazy(() => import("./apps/WalletApp"));
const MarketApp = lazy(() => import("./apps/MarketApp"));
const ContactsApp = lazy(() => import("./apps/ContactsApp"));
const MessagesApp = lazy(() => import("./apps/MessagesApp"));
const SettingsApp = lazy(() => import("./apps/SettingsApp"));

type PhoneView = "lock" | "home" | "app";

export interface PhonePlayerData {
  firstName?: string;
  lastName?: string;
  cash?: number;
  bank?: number;
  job?: string;
  number?: string;
}

export type PhoneCallInfo = {
  name?: string;
  number?: string;
  peerIdentifier?: string;
  nonce?: number;
  reason?: string;
};

export type PhoneCallSeed = {
  action: "incoming" | "accepted" | "ended";
  data?: PhoneCallInfo | null;
  nonce?: number;
};

type LiveCall = {
  status: "outgoing" | "incoming" | "active";
  name: string;
  number?: string | null;
  peerIdentifier?: string | null;
  startedAt?: number;
};

interface PhoneProps {
  visible: boolean;
  data?: PhonePlayerData | null;
  onClose?: () => void;
  callSeed?: PhoneCallSeed | null;
}

type AppDef = {
  id: string;
  label: string;
  icon: React.ComponentType<{ className?: string; strokeWidth?: number }>;
  color: string;
};

const APPS: AppDef[] = [
  { id: "wallet", label: "Wallet", icon: Wallet, color: "#1c1c1e" },
  { id: "market", label: "Market", icon: Store, color: "#c99212" },
  { id: "contacts", label: "Contacts", icon: Contact, color: "#30d158" },
  { id: "messages", label: "Messages", icon: MessageSquare, color: "#007aff" },
  { id: "settings", label: "Settings", icon: Settings, color: "#8e8e93" },
];

const HOME_APPS = ["wallet", "market", "contacts", "messages", "settings"] as const;
const DOCK = ["wallet", "market", "messages", "settings"] as const;

async function fetchNui(event: string, data: Record<string, unknown> = {}) {
  const isBrowser =
    !(window as unknown as { invokeNative?: unknown }).invokeNative &&
    !navigator.userAgent.includes("FiveM");
  if (isBrowser) return;
  const resourceName = (window as unknown as { GetParentResourceName?: () => string })
    .GetParentResourceName
    ? (window as unknown as { GetParentResourceName: () => string }).GetParentResourceName()
    : "kodebykarl-ui";
  await fetch(`https://${resourceName}/${event}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(data),
  }).catch(() => {});
}

async function nuiJson<T>(event: string, data: Record<string, unknown> = {}): Promise<T | null> {
  const isBrowser =
    !(window as unknown as { invokeNative?: unknown }).invokeNative &&
    !navigator.userAgent.includes("FiveM");
  if (isBrowser) return { ok: true } as T;
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

class AppErrorBoundary extends Component<
  { children: React.ReactNode; onReset?: () => void },
  { error: string | null }
> {
  state = { error: null as string | null };

  static getDerivedStateFromError(err: Error) {
    return { error: err?.message || "Something went wrong" };
  }

  render() {
    if (this.state.error) {
      return (
        <div className="absolute inset-0 flex flex-col items-center justify-center bg-[#0c0e14] px-6 text-center">
          <p className="text-[14px] font-semibold text-[#f8f3e8]">App crashed</p>
          <p className="mt-2 text-[12px] leading-relaxed text-[#9a9386]">{this.state.error}</p>
          <button
            type="button"
            onClick={() => {
              this.setState({ error: null });
              this.props.onReset?.();
            }}
            className="mt-4 rounded-full bg-[#f5c542] px-4 py-2 text-[12px] font-black text-[#1a1408]"
          >
            Close app
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

function formatCallClock(startedAt?: number) {
  if (!startedAt) return "00:00";
  const sec = Math.max(0, Math.floor((Date.now() - startedAt) / 1000));
  const m = Math.floor(sec / 60);
  const s = sec % 60;
  return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
}

function CallOverlay({
  call,
  onAccept,
  onDecline,
  onHangup,
}: {
  call: LiveCall;
  onAccept: () => void;
  onDecline: () => void;
  onHangup: () => void;
}) {
  const [, tick] = useState(0);
  useEffect(() => {
    if (call.status !== "active") return;
    const id = window.setInterval(() => tick((n) => n + 1), 1000);
    return () => window.clearInterval(id);
  }, [call.status]);

  const label =
    call.status === "incoming" ? "Incoming call" : call.status === "outgoing" ? "Calling…" : "Connected";

  return (
    <div className="absolute inset-0 z-[80] flex flex-col bg-gradient-to-b from-[#1a2030] via-[#12141c] to-[#0a0c12] px-6 pb-10 pt-16 text-center">
      <p className="text-[11px] font-black uppercase tracking-[0.18em] text-[#9a9386]">{label}</p>
      <div className="mt-8 flex flex-1 flex-col items-center">
        <div className="flex h-20 w-20 items-center justify-center rounded-full bg-gradient-to-br from-[#2a3344] to-[#1a2030] text-[22px] font-black text-[#f5c542] ring-1 ring-white/10">
          {(call.name || "?").trim().slice(0, 1).toUpperCase()}
        </div>
        <p className="mt-4 text-[22px] font-semibold tracking-tight text-[#f8f3e8]">{call.name}</p>
        {call.number ? (
          <p className="mt-1 text-[12px] tabular-nums text-[#9a9386]">{call.number}</p>
        ) : null}
        {call.status === "active" ? (
          <p className="mt-3 text-[13px] tabular-nums text-[#30d158]">{formatCallClock(call.startedAt)}</p>
        ) : null}
      </div>

      {call.status === "incoming" ? (
        <div className="grid grid-cols-2 gap-4 px-2">
          <button
            type="button"
            onClick={onDecline}
            className="flex flex-col items-center gap-2"
          >
            <span className="flex h-14 w-14 items-center justify-center rounded-full bg-[#ff3b30] text-white shadow-lg">
              <PhoneOff className="h-6 w-6" />
            </span>
            <span className="text-[11px] font-semibold text-[#9a9386]">Decline</span>
          </button>
          <button type="button" onClick={onAccept} className="flex flex-col items-center gap-2">
            <span className="flex h-14 w-14 items-center justify-center rounded-full bg-[#30d158] text-[#05240d] shadow-lg">
              <PhoneIcon className="h-6 w-6" />
            </span>
            <span className="text-[11px] font-semibold text-[#9a9386]">Accept</span>
          </button>
        </div>
      ) : (
        <button type="button" onClick={onHangup} className="mx-auto flex flex-col items-center gap-2">
          <span className="flex h-14 w-14 items-center justify-center rounded-full bg-[#ff3b30] text-white shadow-lg">
            <PhoneOff className="h-6 w-6" />
          </span>
          <span className="text-[11px] font-semibold text-[#9a9386]">Hang up</span>
        </button>
      )}
    </div>
  );
}

function useClock(enabled = true) {
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    if (!enabled) return;
    const id = window.setInterval(() => setNow(new Date()), 1000);
    return () => window.clearInterval(id);
  }, [enabled]);
  return now;
}

const ISLAND_NOTIF_INTERVAL_MS = 30 * 60 * 1000;
const ISLAND_NOTIF_VISIBLE_MS = 7000;

function DynamicIsland({ active }: { active: boolean }) {
  const [showNotif, setShowNotif] = useState(false);

  useEffect(() => {
    if (!active) {
      setShowNotif(false);
      return;
    }

    let hideTimer: number | undefined;
    const show = () => {
      setShowNotif(true);
      window.clearTimeout(hideTimer);
      hideTimer = window.setTimeout(() => setShowNotif(false), ISLAND_NOTIF_VISIBLE_MS);
    };

    // First pulse shortly after open, then every 30 min
    const first = window.setTimeout(show, 2500);
    const repeat = window.setInterval(show, ISLAND_NOTIF_INTERVAL_MS);

    return () => {
      window.clearTimeout(first);
      window.clearInterval(repeat);
      window.clearTimeout(hideTimer);
    };
  }, [active]);

  return (
    <div className="pointer-events-none absolute left-1/2 top-[11px] z-50 -translate-x-1/2">
      <div
        className={cn(
          "relative flex items-center overflow-hidden bg-black shadow-[inset_0_0_0_1px_rgba(255,255,255,0.08)] transition-all duration-500 ease-[cubic-bezier(0.32,0.72,0,1)]",
          showNotif
            ? "h-[48px] w-[min(92%,280px)] gap-2 rounded-[24px] pl-2 pr-10"
            : "h-[32px] w-[118px] justify-center rounded-[20px]",
        )}
        style={showNotif ? { animation: "phoneIslandPulse 3.2s ease-in-out infinite" } : undefined}
      >
        {showNotif && (
          <>
            <div className="relative flex h-[32px] w-[32px] shrink-0 items-center justify-center rounded-full bg-gradient-to-b from-[#64d2ff] to-[#007aff] shadow-sm">
              <MessageCircle
                className="h-4 w-4 text-white"
                strokeWidth={2.4}
                fill="white"
                fillOpacity={0.15}
              />
              <span className="absolute -right-0.5 -top-0.5 h-2 w-2 rounded-full bg-[#ff3b30] ring-2 ring-black" />
            </div>
            <div className="min-w-0 flex-1 leading-tight">
              <div className="flex items-center justify-between gap-2">
                <p className="truncate text-[12px] font-semibold tracking-tight text-white">
                  Keydi.dev
                </p>
                <span className="shrink-0 text-[9px] font-medium text-white/45">now</span>
              </div>
              <p className="truncate text-[10px] font-medium text-white/55">
                Message · Built for Grim City
              </p>
            </div>
          </>
        )}

        <div
          className={cn(
            "absolute top-1/2 -translate-y-1/2 rounded-full bg-[#0a1a12] ring-1 ring-[#1a3d2a]",
            showNotif ? "right-[12px] h-[8px] w-[8px] opacity-40" : "right-[16px] h-[9px] w-[9px]",
          )}
        >
          <div className="absolute inset-[2px] rounded-full bg-[#0d2818]" />
          {!showNotif && (
            <div className="absolute left-[2px] top-[2px] h-[2px] w-[2px] rounded-full bg-[#2ee59d]/50" />
          )}
        </div>
      </div>
    </div>
  );
}

function StatusBar({ light }: { light?: boolean }) {
  const now = useClock();
  const time = now.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  return (
    <div
      className={cn(
        "relative z-40 flex items-center justify-between px-6 pt-[14px] text-[12px] font-semibold tracking-tight",
        light ? "text-white" : "text-black",
      )}
    >
      <span className="min-w-[48px]">{time}</span>
      <div className="w-[100px]" />
      <div className="flex items-center gap-1 opacity-90">
        <Signal className="h-3 w-3" strokeWidth={2.4} />
        <Wifi className="h-3 w-3" strokeWidth={2.4} />
        <BatteryFull className="h-3.5 w-3.5" strokeWidth={2.2} />
      </div>
    </div>
  );
}

function LockScreen({
  onUnlock,
  player,
}: {
  onUnlock: () => void;
  player?: PhonePlayerData | null;
}) {
  const now = useClock();
  const time = now.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  const date = now.toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" });
  const name = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Player";

  const dragY = useRef(0);
  const startY = useRef<number | null>(null);
  const [offset, setOffset] = useState(0);
  const [unlocking, setUnlocking] = useState(false);
  const [dragging, setDragging] = useState(false);

  const finishUnlock = useCallback(() => {
    setUnlocking(true);
    setDragging(false);
    setOffset(-120);
    window.setTimeout(() => onUnlock(), 220);
  }, [onUnlock]);

  const onPointerDown = (e: React.PointerEvent<HTMLDivElement>) => {
    e.currentTarget.setPointerCapture(e.pointerId);
    startY.current = e.clientY;
    dragY.current = 0;
    setDragging(true);
  };

  const onPointerMove = (e: React.PointerEvent<HTMLDivElement>) => {
    if (startY.current == null || unlocking) return;
    const dy = e.clientY - startY.current;
    const up = Math.min(0, dy);
    dragY.current = up;
    setOffset(up);
  };

  const onPointerUp = (e: React.PointerEvent<HTMLDivElement>) => {
    if (startY.current == null) return;
    try {
      e.currentTarget.releasePointerCapture(e.pointerId);
    } catch {
      /* already released */
    }
    const upDistance = Math.abs(dragY.current);
    startY.current = null;
    setDragging(false);
    if (upDistance >= 56) {
      finishUnlock();
    } else {
      setOffset(0);
    }
  };

  return (
    <div
      className="absolute inset-0 flex touch-none flex-col select-none"
      style={{
        background:
          "linear-gradient(180deg, #1a2744 0%, #3d2a5c 35%, #8f3d6a 68%, #e8a06a 100%)",
        transform: `translateY(${offset}px)`,
        opacity: unlocking ? 0 : Math.max(0.35, 1 + offset / 260),
        transition: dragging ? "none" : "transform 220ms ease, opacity 220ms ease",
      }}
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerUp}
      onPointerCancel={onPointerUp}
    >
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_50%_0%,rgba(255,255,255,0.2),transparent_48%)]" />
      <StatusBar light />

      <div className="relative z-10 flex flex-1 flex-col items-center px-6 pt-16">
        <p className="text-[16px] font-medium tracking-[0.01em] text-white drop-shadow-sm">{date}</p>
        <p className="mt-1 text-[72px] font-thin leading-none tracking-[-0.04em] text-white drop-shadow-[0_4px_20px_rgba(0,0,0,0.25)]">
          {time}
        </p>

        <div className="mt-8 flex w-full flex-col gap-2">
          <div className="flex items-start gap-3 rounded-[20px] bg-white/16 px-3.5 py-3 shadow-[0_8px_28px_rgba(0,0,0,0.12)] backdrop-blur-2xl">
            <div className="mt-0.5 flex h-9 w-9 shrink-0 items-center justify-center rounded-[10px] bg-gradient-to-b from-[#64d2ff] to-[#007aff]">
              <MessageCircle className="h-4 w-4 text-white" strokeWidth={2.2} />
            </div>
            <div className="min-w-0 flex-1">
              <div className="flex items-baseline justify-between gap-2">
                <p className="truncate text-[13px] font-semibold text-white">Keydi.dev</p>
                <span className="shrink-0 text-[11px] text-white/55">now</span>
              </div>
              <p className="mt-0.5 text-[12px] leading-snug text-white/80">
                Welcome back, {name}.
              </p>
            </div>
          </div>
        </div>
      </div>

      <div className="relative z-10 mb-8 flex items-end justify-between px-10">
        <button
          type="button"
          className="flex h-12 w-12 items-center justify-center rounded-full bg-black/28 text-white backdrop-blur-xl"
          onPointerDown={(e) => e.stopPropagation()}
        >
          <Flashlight className="h-5 w-5" strokeWidth={1.8} />
        </button>
        <p className="pb-2 text-[12px] font-medium tracking-wide text-white/80">Swipe up to unlock</p>
        <button
          type="button"
          className="flex h-12 w-12 items-center justify-center rounded-full bg-black/28 text-white backdrop-blur-xl"
          onPointerDown={(e) => e.stopPropagation()}
        >
          <Camera className="h-5 w-5" strokeWidth={1.8} />
        </button>
      </div>
    </div>
  );
}

function HomeScreen({
  player,
  onOpenApp,
}: {
  player?: PhonePlayerData | null;
  onOpenApp: (id: string) => void;
}) {
  const appMap = useMemo(() => Object.fromEntries(APPS.map((a) => [a.id, a])), []);
  const name = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Citizen";
  const [unread, setUnread] = useState(0);

  useEffect(() => {
    const load = async () => {
      try {
        const resourceName = (window as unknown as { GetParentResourceName?: () => string })
          .GetParentResourceName
          ? (window as unknown as { GetParentResourceName: () => string }).GetParentResourceName()
          : "kodebykarl-ui";
        const res = await fetch(`https://${resourceName}/cfx-keydi-phone:messages:unread`, {
          method: "POST",
          headers: { "Content-Type": "application/json; charset=UTF-8" },
          body: "{}",
        });
        const data = (await res.json()) as { count?: number };
        setUnread(Number(data?.count) || 0);
      } catch {
        /* browser preview */
      }
    };
    void load();

    const onMsg = (event: MessageEvent) => {
      if (event.data?.action === "cfx-keydi-phone:message") {
        setUnread((n) => n + 1);
      }
    };
    window.addEventListener("message", onMsg);
    return () => window.removeEventListener("message", onMsg);
  }, []);

  const renderAppButton = (id: string, size: "home" | "dock") => {
    const app = appMap[id];
    if (!app) return null;
    const isDock = size === "dock";
    return (
      <button
        key={id}
        type="button"
        className={
          isDock
            ? "relative flex h-[48px] w-[48px] shrink-0 items-center justify-center rounded-[13px] text-white shadow-md transition-transform active:scale-90"
            : "relative flex flex-col items-center gap-1.5 transition-transform active:scale-95"
        }
        style={isDock ? { backgroundColor: app.color } : undefined}
        onClick={() => onOpenApp(id)}
        title={app.label}
      >
        {isDock ? (
          <app.icon className="h-[22px] w-[22px]" strokeWidth={1.8} />
        ) : (
          <>
            <div
              className="relative flex h-[54px] w-[54px] items-center justify-center rounded-[14px] text-white shadow-[0_8px_18px_rgba(0,0,0,0.28)]"
              style={{ backgroundColor: app.color }}
            >
              <app.icon className="h-[26px] w-[26px]" strokeWidth={1.8} />
              {id === "messages" && unread > 0 ? (
                <span className="absolute -right-1 -top-1 flex h-4 min-w-4 items-center justify-center rounded-full bg-[#ff3b30] px-1 text-[9px] font-bold text-white">
                  {unread > 9 ? "9+" : unread}
                </span>
              ) : null}
            </div>
            <span className="w-full truncate text-center text-[10px] font-medium leading-tight text-white drop-shadow-sm">
              {app.label}
            </span>
          </>
        )}
        {isDock && id === "messages" && unread > 0 ? (
          <span className="absolute -right-0.5 -top-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-[#ff3b30] px-1 text-[9px] font-bold text-white">
            {unread > 9 ? "9+" : unread}
          </span>
        ) : null}
      </button>
    );
  };

  return (
    <div
      className="absolute inset-0 flex flex-col select-none"
      style={{
        background:
          "linear-gradient(180deg, #5b7cfa 0%, #8a9ff5 30%, #c8a8e8 65%, #f0c8b8 100%)",
      }}
    >
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_20%_15%,rgba(255,255,255,0.32),transparent_42%)]" />
      <StatusBar light />

      <div className="relative z-10 px-5 pt-4">
        <button
          type="button"
          className="flex w-full flex-col justify-between rounded-[22px] bg-black/50 px-4 py-3.5 text-left text-white shadow-[0_10px_28px_rgba(0,0,0,0.16)] backdrop-blur-xl transition-transform active:scale-[0.99]"
          onClick={() => onOpenApp("wallet")}
        >
          <div className="flex items-center justify-between">
            <p className="text-[11px] font-semibold text-white/65">Wallet · {name}</p>
            <Wallet className="h-3.5 w-3.5 text-white/75" />
          </div>
          <p className="mt-2 text-[24px] font-semibold tracking-tight leading-none">
            ${(player?.bank ?? 0).toLocaleString()}
          </p>
          <p className="mt-1.5 text-[11px] text-white/60">
            Cash ${(player?.cash ?? 0).toLocaleString()} · {player?.job || "Unemployed"}
          </p>
        </button>
      </div>

      <div className="relative z-10 px-5 pt-5">
        <div className="grid grid-cols-4 gap-x-3 gap-y-4">
          {HOME_APPS.map((id) => renderAppButton(id, "home"))}
        </div>
      </div>

      <div className="relative z-0 min-h-0 flex-1" />

      <div className="relative z-10 mx-4 mb-6">
        <div className="flex items-center justify-around rounded-[28px] border border-white/35 bg-white/28 px-3 py-2.5 shadow-[0_14px_36px_rgba(0,0,0,0.18)] backdrop-blur-2xl">
          {DOCK.map((id) => renderAppButton(id, "dock"))}
        </div>
      </div>
    </div>
  );
}

function AppScreen({
  appId,
  player,
  messagePeer,
  onOpenMessage,
  onStartCall,
  onCrashReset,
}: {
  appId: string;
  player?: PhonePlayerData | null;
  messagePeer?: MessagePeer | null;
  onOpenMessage: (opts: ContactAction) => void;
  onStartCall: (opts: ContactAction | MessagePeer) => void;
  onCrashReset: () => void;
}) {
  const fallback = (
    <div className="absolute inset-0 flex items-center justify-center bg-[#f2f2f7] text-[13px] text-[#8e8e93]">
      Loading…
    </div>
  );

  let screen: React.ReactNode = null;

  if (appId === "wallet") {
    screen = (
      <Suspense fallback={fallback}>
        <WalletApp player={player} />
      </Suspense>
    );
  } else if (appId === "market") {
    screen = (
      <Suspense fallback={fallback}>
        <MarketApp />
      </Suspense>
    );
  } else if (appId === "contacts") {
    screen = (
      <Suspense fallback={fallback}>
        <ContactsApp onOpenMessage={onOpenMessage} onStartCall={onStartCall} />
      </Suspense>
    );
  } else if (appId === "messages") {
    screen = (
      <Suspense fallback={fallback}>
        <MessagesApp startPeer={messagePeer} onStartCall={onStartCall} />
      </Suspense>
    );
  } else if (appId === "settings") {
    screen = (
      <Suspense fallback={fallback}>
        <SettingsApp player={player} />
      </Suspense>
    );
  } else {
    const app = APPS.find((a) => a.id === appId);
    if (!app) return null;
    screen = (
      <PlaceholderApp
        title={app.label}
        icon={app.icon}
        color={app.color}
        message="Coming soon."
        player={player}
      />
    );
  }

  return <AppErrorBoundary onReset={onCrashReset}>{screen}</AppErrorBoundary>;
}

export default function Phone({ visible, data, onClose, callSeed }: PhoneProps) {
  const [view, setView] = useState<PhoneView>("lock");
  const [activeApp, setActiveApp] = useState<string | null>(null);
  const [messagePeer, setMessagePeer] = useState<MessagePeer | null>(null);
  const [liveCall, setLiveCall] = useState<LiveCall | null>(null);
  const [callError, setCallError] = useState<string | null>(null);

  useEffect(() => {
    if (!visible) {
      setView("lock");
      setActiveApp(null);
      setMessagePeer(null);
    }
  }, [visible]);

  useEffect(() => {
    if (!callSeed) return;
    if (callSeed.action === "incoming") {
      setLiveCall({
        status: "incoming",
        name: callSeed.data?.name || "Unknown",
        number: callSeed.data?.number,
        peerIdentifier: callSeed.data?.peerIdentifier,
      });
      setView((v) => (v === "lock" ? "home" : v));
    } else if (callSeed.action === "accepted") {
      setLiveCall((prev) =>
        prev
          ? {
              ...prev,
              status: "active",
              name: callSeed.data?.name || prev.name,
              number: callSeed.data?.number ?? prev.number,
              startedAt: Date.now(),
            }
          : {
              status: "active",
              name: callSeed.data?.name || "Unknown",
              number: callSeed.data?.number,
              peerIdentifier: callSeed.data?.peerIdentifier,
              startedAt: Date.now(),
            },
      );
    } else if (callSeed.action === "ended") {
      setLiveCall(null);
    }
  }, [callSeed]);

  const close = useCallback(() => {
    void fetchNui("cfx-keydi-phone:close");
    onClose?.();
  }, [onClose]);

  const startCall = useCallback(async (opts: ContactAction | MessagePeer) => {
    setCallError(null);
    const res = await nuiJson<{
      ok?: boolean;
      error?: string;
      name?: string;
      number?: string;
      peerIdentifier?: string;
    }>("cfx-keydi-phone:call:start", {
      peerIdentifier: opts.peerIdentifier || undefined,
      contactId: "contactId" in opts ? opts.contactId : undefined,
    });
    if (!res?.ok) {
      setCallError(res?.error || "Could not start call");
      window.setTimeout(() => setCallError(null), 4000);
      return;
    }
    setLiveCall({
      status: "outgoing",
      name: res.name || opts.name || "Unknown",
      number: res.number,
      peerIdentifier: res.peerIdentifier || opts.peerIdentifier,
    });
  }, []);

  const openMessage = useCallback((opts: ContactAction) => {
    setMessagePeer({
      peerIdentifier: opts.peerIdentifier,
      contactId: opts.contactId,
      name: opts.name,
    });
    setActiveApp("messages");
    setView("app");
  }, []);

  const acceptCall = useCallback(async () => {
    const res = await nuiJson<{ ok?: boolean; error?: string }>("cfx-keydi-phone:call:accept");
    if (!res?.ok) {
      setCallError(res?.error || "Could not answer");
      return;
    }
    setLiveCall((prev) =>
      prev ? { ...prev, status: "active", startedAt: Date.now() } : prev,
    );
  }, []);

  const declineCall = useCallback(async () => {
    setLiveCall(null);
    await nuiJson("cfx-keydi-phone:call:decline");
  }, []);

  const hangupCall = useCallback(async () => {
    setLiveCall(null);
    await nuiJson("cfx-keydi-phone:call:hangup");
  }, []);

  useEffect(() => {
    if (!visible) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        if (liveCall) {
          if (liveCall.status === "incoming") void declineCall();
          else void hangupCall();
          return;
        }
        if (view === "app") {
          setView("home");
          setActiveApp(null);
        } else if (view === "home") {
          setView("lock");
        } else {
          close();
        }
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [visible, view, close, liveCall, declineCall, hangupCall]);

  if (!visible) return null;

  return (
    <div className="pointer-events-none fixed inset-0 z-[100000]">
      <div
        className="pointer-events-auto absolute bottom-6 right-6 animate-[phoneIn_420ms_cubic-bezier(0.32,0.72,0,1)]"
        style={{
          width: "min(300px, 34vw)",
          aspectRatio: "9 / 19.5",
          maxHeight: "62vh",
          height: "auto",
          fontFamily:
            '-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Segoe UI", sans-serif',
        }}
      >
        <div
          className="absolute inset-0 rounded-[48px]"
          style={{
            background:
              "linear-gradient(145deg, #5c5c60 0%, #2c2c2e 16%, #111113 48%, #1c1c1e 78%, #4a4a4c 100%)",
            boxShadow:
              "0 40px 90px rgba(0,0,0,0.55), inset 0 1px 1px rgba(255,255,255,0.28), inset 0 -1px 2px rgba(0,0,0,0.65)",
          }}
        />

        {/* Side buttons */}
        <div className="absolute -left-[3px] top-[100px] h-[28px] w-[3px] rounded-l-sm bg-[#3a3a3c]" />
        <div className="absolute -left-[3px] top-[145px] h-[52px] w-[3px] rounded-l-sm bg-[#3a3a3c]" />
        <div className="absolute -left-[3px] top-[210px] h-[52px] w-[3px] rounded-l-sm bg-[#3a3a3c]" />
        <div className="absolute -right-[3px] top-[180px] h-[88px] w-[3px] rounded-r-sm bg-[#3a3a3c]" />

        <div className="absolute inset-[9px] overflow-hidden rounded-[40px] bg-black shadow-[inset_0_0_0_1.5px_#0a0a0a]">
          <DynamicIsland active={visible} />

          {view === "lock" && <LockScreen player={data} onUnlock={() => setView("home")} />}
          {view === "home" && (
            <HomeScreen
              player={data}
              onOpenApp={(id) => {
                if (id === "messages") setMessagePeer(null);
                setActiveApp(id);
                setView("app");
              }}
            />
          )}
          {view === "app" && activeApp && (
            <AppScreen
              appId={activeApp}
              player={data}
              messagePeer={messagePeer}
              onOpenMessage={openMessage}
              onStartCall={startCall}
              onCrashReset={() => {
                setActiveApp(null);
                setView("home");
              }}
            />
          )}

          {callError ? (
            <div className="absolute bottom-12 left-3 right-3 z-[90] rounded-xl border border-red-500/30 bg-red-500/15 px-3 py-2 text-center text-[11px] text-red-200">
              {callError}
            </div>
          ) : null}

          {liveCall ? (
            <CallOverlay
              call={liveCall}
              onAccept={() => void acceptCall()}
              onDecline={() => void declineCall()}
              onHangup={() => void hangupCall()}
            />
          ) : null}

          <button
            type="button"
            aria-label="Back"
            className="absolute bottom-0 left-1/2 z-50 flex h-8 w-[150px] -translate-x-1/2 items-end justify-center pb-2.5"
            onClick={() => {
              if (liveCall) return;
              if (view === "app") {
                setActiveApp(null);
                setView("home");
              } else if (view === "home") {
                setView("lock");
              }
            }}
          >
            <span className="h-[5px] w-[120px] rounded-full bg-white shadow-[0_0_0_1px_rgba(0,0,0,0.35),0_2px_8px_rgba(0,0,0,0.45)]" />
          </button>
        </div>
      </div>

      <style>{`
        @keyframes phoneIn {
          from { opacity: 0; transform: translateY(18px) scale(0.94); }
          to { opacity: 1; transform: translateY(0) scale(1); }
        }
        @keyframes phoneIslandPulse {
          0%, 100% { transform: scale(1); box-shadow: inset 0 0 0 1px rgba(255,255,255,0.08), 0 8px 24px rgba(0,0,0,0.35); }
          50% { transform: scale(1.015); box-shadow: inset 0 0 0 1px rgba(255,255,255,0.14), 0 10px 28px rgba(0,122,255,0.22); }
        }
      `}</style>
    </div>
  );
}
