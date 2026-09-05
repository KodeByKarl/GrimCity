import { useCallback, useEffect, useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import {
  BatteryFull,
  Signal,
  Wifi,
  Flashlight,
  Camera,
  Settings,
  Map,
  Image,
  NotebookPen,
  Music2,
  MessageCircle,
  Compass,
  Clock3,
  CloudSun,
  Wallet,
  Users,
  Phone,
  CalendarDays,
  Mail,
  AppWindow,
  ChevronLeft,
} from "lucide-react";

type IpadView = "lock" | "home" | "app";

export interface IpadPlayerData {
  firstName?: string;
  lastName?: string;
  cash?: number;
  bank?: number;
  job?: string;
  gang?: string;
  playtime?: string;
}

interface IpadProps {
  visible: boolean;
  data?: IpadPlayerData | null;
  onClose?: () => void;
}

const APPS = [
  { id: "messages", label: "Messages", icon: MessageCircle, tint: "from-[#34c759] to-[#248a3d]" },
  { id: "safari", label: "Safari", icon: Compass, tint: "from-[#64d2ff] to-[#007aff]" },
  { id: "music", label: "Music", icon: Music2, tint: "from-[#ff2d55] to-[#c2185b]" },
  { id: "mail", label: "Mail", icon: Mail, tint: "from-[#5ac8fa] to-[#007aff]" },
  { id: "maps", label: "Maps", icon: Map, tint: "from-[#64d2ff] to-[#34c759]" },
  { id: "photos", label: "Photos", icon: Image, tint: "from-[#ff9f0a] to-[#ff375f]" },
  { id: "notes", label: "Notes", icon: NotebookPen, tint: "from-[#ffd60a] to-[#ff9f0a]" },
  { id: "calendar", label: "Calendar", icon: CalendarDays, tint: "from-[#ff3b30] to-[#ff453a]" },
  { id: "clock", label: "Clock", icon: Clock3, tint: "from-[#1c1c1e] to-[#3a3a3c]" },
  { id: "weather", label: "Weather", icon: CloudSun, tint: "from-[#5ac8fa] to-[#007aff]" },
  { id: "wallet", label: "Wallet", icon: Wallet, tint: "from-[#1c1c1e] to-[#000000]" },
  { id: "contacts", label: "Contacts", icon: Users, tint: "from-[#ff9f0a] to-[#ff6937]" },
  { id: "phone", label: "Phone", icon: Phone, tint: "from-[#34c759] to-[#30d158]" },
  { id: "camera", label: "Camera", icon: Camera, tint: "from-[#636366] to-[#1c1c1e]" },
  { id: "settings", label: "Settings", icon: Settings, tint: "from-[#8e8e93] to-[#636366]" },
  { id: "grim", label: "Grim City", icon: AppWindow, tint: "from-[#ff3b30] to-[#8b0000]" },
] as const;

const DOCK = ["phone", "safari", "messages", "music"] as const;

async function fetchNui(event: string, data: Record<string, unknown> = {}) {
  const isBrowser = !(window as unknown as { invokeNative?: unknown }).invokeNative
    && !navigator.userAgent.includes("FiveM");
  if (isBrowser) return;
  const resourceName = (window as unknown as { GetParentResourceName?: () => string }).GetParentResourceName
    ? (window as unknown as { GetParentResourceName: () => string }).GetParentResourceName()
    : "kodebykarl-ui";
  await fetch(`https://${resourceName}/${event}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(data),
  }).catch(() => {});
}

function useClock() {
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    const id = window.setInterval(() => setNow(new Date()), 1000);
    return () => window.clearInterval(id);
  }, []);
  return now;
}

function DynamicIsland({ expanded }: { expanded?: boolean }) {
  return (
    <div className="pointer-events-none absolute left-1/2 top-[14px] z-50 -translate-x-1/2">
      <div
        className={cn(
          "relative flex items-center justify-center overflow-hidden bg-black shadow-[inset_0_0_0_1px_rgba(255,255,255,0.06)] transition-all duration-500 ease-[cubic-bezier(0.32,0.72,0,1)]",
          expanded ? "h-[36px] w-[168px] rounded-[22px]" : "h-[28px] w-[112px] rounded-[18px]",
        )}
      >
        <div className="absolute right-[18px] top-1/2 h-[9px] w-[9px] -translate-y-1/2 rounded-full bg-[#0a1a12] ring-1 ring-[#1a3d2a]">
          <div className="absolute inset-[2px] rounded-full bg-[#0d2818]" />
          <div className="absolute left-[2px] top-[2px] h-[2px] w-[2px] rounded-full bg-[#2ee59d]/50" />
        </div>
        {expanded && (
          <div className="flex items-center gap-2 px-4 text-[11px] font-semibold tracking-wide text-white/90">
            <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-[#30d158]" />
            Connected
          </div>
        )}
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
        "relative z-40 flex items-center justify-between px-7 pt-[18px] text-[12px] font-semibold tracking-tight",
        light ? "text-white" : "text-black",
      )}
    >
      <span className="min-w-[54px]">{time}</span>
      <div className="flex items-center gap-1.5 opacity-90">
        <Signal className="h-3.5 w-3.5" strokeWidth={2.4} />
        <Wifi className="h-3.5 w-3.5" strokeWidth={2.4} />
        <BatteryFull className="h-4 w-4" strokeWidth={2.2} />
      </div>
    </div>
  );
}

function LockScreen({ onUnlock, player }: { onUnlock: () => void; player?: IpadPlayerData | null }) {
  const now = useClock();
  const time = now.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  const date = now.toLocaleDateString([], { weekday: "long", month: "long", day: "numeric" });
  const name = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Player";

  return (
    <div
      className="absolute inset-0 flex flex-col select-none"
      style={{
        background:
          "linear-gradient(165deg, #1a2744 0%, #3d2a5c 38%, #8b4578 68%, #c97b5a 100%)",
      }}
      onClick={onUnlock}
    >
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_top,rgba(255,255,255,0.18),transparent_55%)]" />
      <StatusBar light />
      <div className="relative z-10 mt-16 flex flex-1 flex-col items-center px-8 text-white">
        <p className="text-[17px] font-medium tracking-wide text-white/90 drop-shadow-sm">{date}</p>
        <p className="mt-1 text-[92px] font-thin leading-none tracking-[-0.04em] drop-shadow-md">{time}</p>
        <div className="mt-8 w-full max-w-[280px] rounded-2xl border border-white/20 bg-white/15 p-3.5 backdrop-blur-xl">
          <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-white/70">Notification</p>
          <p className="mt-1 text-[14px] font-semibold">Welcome back, {name}</p>
          <p className="mt-0.5 text-[12px] text-white/75">Swipe up or tap to unlock your iPad.</p>
        </div>
      </div>
      <div className="relative z-10 mb-10 flex items-end justify-between px-10">
        <button
          type="button"
          className="flex h-12 w-12 items-center justify-center rounded-full border border-white/25 bg-black/25 text-white backdrop-blur-md"
          onClick={(e) => e.stopPropagation()}
        >
          <Flashlight className="h-5 w-5" />
        </button>
        <div className="flex flex-col items-center gap-2 pb-1">
          <div className="h-1 w-10 rounded-full bg-white/55" />
          <p className="text-[12px] font-medium text-white/80">Swipe up to unlock</p>
        </div>
        <button
          type="button"
          className="flex h-12 w-12 items-center justify-center rounded-full border border-white/25 bg-black/25 text-white backdrop-blur-md"
          onClick={(e) => e.stopPropagation()}
        >
          <Camera className="h-5 w-5" />
        </button>
      </div>
    </div>
  );
}

function AppIcon({
  label,
  icon: Icon,
  tint,
  onClick,
}: {
  label: string;
  icon: typeof Settings;
  tint: string;
  onClick: () => void;
}) {
  return (
    <button type="button" className="group flex flex-col items-center gap-1.5" onClick={onClick}>
      <div
        className={cn(
          "flex h-[54px] w-[54px] items-center justify-center rounded-[14px] bg-gradient-to-br text-white shadow-[0_8px_16px_rgba(0,0,0,0.18)] transition-transform duration-200 group-active:scale-90",
          tint,
        )}
      >
        <Icon className="h-[26px] w-[26px]" strokeWidth={1.8} />
      </div>
      <span className="max-w-[64px] truncate text-[11px] font-medium text-white drop-shadow">{label}</span>
    </button>
  );
}

function HomeScreen({
  player,
  onOpenApp,
}: {
  player?: IpadPlayerData | null;
  onOpenApp: (id: string) => void;
}) {
  const now = useClock();
  const appMap = useMemo(() => Object.fromEntries(APPS.map((a) => [a.id, a])), []);

  return (
    <div
      className="absolute inset-0 flex flex-col select-none"
      style={{
        background:
          "linear-gradient(180deg, #5b7cfa 0%, #7a8ff5 28%, #c4a0e8 62%, #f0c4b8 100%)",
      }}
    >
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_20%_20%,rgba(255,255,255,0.35),transparent_40%)]" />
      <StatusBar light />

      {/* Widgets */}
      <div className="relative z-10 mt-6 grid grid-cols-2 gap-3 px-6">
        <div className="col-span-1 row-span-2 rounded-[22px] bg-gradient-to-br from-[#5ac8fa]/95 to-[#007aff] p-4 text-white shadow-lg">
          <p className="text-[13px] font-semibold opacity-90">Los Santos</p>
          <p className="mt-1 text-[52px] font-thin leading-none tracking-tight">72°</p>
          <div className="mt-3 flex items-center gap-2 text-[13px]">
            <CloudSun className="h-4 w-4" />
            <span>Partly Cloudy</span>
          </div>
          <p className="mt-6 text-[12px] opacity-80">H:78° · L:64°</p>
        </div>

        <div className="rounded-[22px] bg-white/85 p-3.5 text-[#1c1c1e] shadow-lg backdrop-blur-xl">
          <p className="text-[11px] font-semibold uppercase tracking-wider text-[#ff3b30]">
            {now.toLocaleDateString([], { weekday: "short" }).toUpperCase()}
          </p>
          <p className="text-[34px] font-light leading-none">{now.getDate()}</p>
          <p className="mt-2 text-[12px] text-[#8e8e93]">No more events</p>
        </div>

        <div className="rounded-[22px] bg-black/55 p-3.5 text-white shadow-lg backdrop-blur-xl">
          <p className="text-[11px] font-semibold text-white/70">Wallet</p>
          <p className="mt-1 text-[18px] font-semibold tracking-tight">
            ${(player?.bank ?? 0).toLocaleString()}
          </p>
          <p className="text-[11px] text-white/60">Cash ${(player?.cash ?? 0).toLocaleString()}</p>
        </div>
      </div>

      {/* App grid */}
      <div className="relative z-10 mt-5 grid flex-1 grid-cols-4 content-start gap-x-3 gap-y-4 px-6 pb-2">
        {APPS.filter((a) => !(DOCK as readonly string[]).includes(a.id)).map((app) => (
          <AppIcon
            key={app.id}
            label={app.label}
            icon={app.icon}
            tint={app.tint}
            onClick={() => onOpenApp(app.id)}
          />
        ))}
      </div>

      {/* Dock */}
      <div className="relative z-10 mx-5 mb-7 flex items-center justify-around rounded-[28px] border border-white/30 bg-white/25 px-3 py-3.5 shadow-xl backdrop-blur-2xl">
        {DOCK.map((id) => {
          const app = appMap[id];
          if (!app) return null;
          return (
            <button
              key={id}
              type="button"
              className={cn(
                "flex h-[54px] w-[54px] items-center justify-center rounded-[14px] bg-gradient-to-br text-white shadow-md active:scale-90",
                app.tint,
              )}
              onClick={() => onOpenApp(id)}
            >
              <app.icon className="h-[26px] w-[26px]" strokeWidth={1.8} />
            </button>
          );
        })}
      </div>
    </div>
  );
}

function AppScreen({
  appId,
  player,
  onBack,
}: {
  appId: string;
  player?: IpadPlayerData | null;
  onBack: () => void;
}) {
  const app = APPS.find((a) => a.id === appId) || APPS[APPS.length - 1];
  const Icon = app.icon;

  return (
    <div className="absolute inset-0 flex flex-col bg-[#f2f2f7] select-none">
      <StatusBar />
      <div className="flex items-center gap-1 border-b border-black/5 bg-[#f2f2f7]/95 px-3 pb-2 pt-3">
        <button
          type="button"
          className="flex items-center gap-0.5 rounded-lg px-2 py-1 text-[16px] font-medium text-[#007aff]"
          onClick={onBack}
        >
          <ChevronLeft className="h-5 w-5" />
          Home
        </button>
        <p className="flex-1 text-center text-[16px] font-semibold text-black">{app.label}</p>
        <span className="w-[72px]" />
      </div>

      <div className="flex flex-1 flex-col items-center justify-center gap-4 px-8 text-center">
        <div className={cn("flex h-20 w-20 items-center justify-center rounded-[22px] bg-gradient-to-br text-white shadow-lg", app.tint)}>
          <Icon className="h-10 w-10" strokeWidth={1.6} />
        </div>
        <div>
          <h2 className="text-[22px] font-semibold text-[#1c1c1e]">{app.label}</h2>
          <p className="mt-2 max-w-[280px] text-[14px] leading-relaxed text-[#8e8e93]">
            App shell ready. Wire gameplay features here later.
          </p>
        </div>
        {app.id === "grim" && (
          <div className="mt-2 w-full max-w-[300px] rounded-2xl bg-white p-4 text-left shadow-sm">
            <p className="text-[13px] text-[#8e8e93]">Signed in</p>
            <p className="text-[16px] font-semibold text-[#1c1c1e]">
              {[player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Citizen"}
            </p>
            <p className="mt-2 text-[13px] text-[#8e8e93]">
              Job: {player?.job || "Unemployed"} · Gang: {player?.gang || "None"}
            </p>
          </div>
        )}
        {app.id === "wallet" && (
          <div className="w-full max-w-[300px] space-y-2">
            <div className="rounded-2xl bg-gradient-to-br from-[#1c1c1e] to-black p-4 text-left text-white shadow-md">
              <p className="text-[12px] text-white/60">Bank</p>
              <p className="text-[28px] font-semibold">${(player?.bank ?? 0).toLocaleString()}</p>
            </div>
            <div className="rounded-2xl bg-white p-4 text-left shadow-sm">
              <p className="text-[12px] text-[#8e8e93]">Cash</p>
              <p className="text-[22px] font-semibold text-[#1c1c1e]">${(player?.cash ?? 0).toLocaleString()}</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default function Ipad({ visible, data, onClose }: IpadProps) {
  const [view, setView] = useState<IpadView>("lock");
  const [activeApp, setActiveApp] = useState<string | null>(null);
  const [islandExpanded, setIslandExpanded] = useState(false);

  useEffect(() => {
    if (!visible) {
      setView("lock");
      setActiveApp(null);
      setIslandExpanded(false);
      return;
    }
    setIslandExpanded(true);
    const t = window.setTimeout(() => setIslandExpanded(false), 1800);
    return () => window.clearTimeout(t);
  }, [visible]);

  const close = useCallback(() => {
    fetchNui("cfx-keydi-ipad:close");
    onClose?.();
  }, [onClose]);

  useEffect(() => {
    if (!visible) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
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
  }, [visible, view, close]);

  if (!visible) return null;

  return (
    <div className="fixed inset-0 z-[100000] flex items-center justify-center bg-black/45 backdrop-blur-[2px]">
      {/* iPad aluminum chassis */}
      <div
        className="relative animate-[ipadIn_420ms_cubic-bezier(0.32,0.72,0,1)]"
        style={{
          width: "min(430px, 92vw)",
          height: "min(620px, 92vh)",
          fontFamily:
            '-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Segoe UI", sans-serif',
        }}
      >
        {/* Outer graphite shell */}
        <div
          className="absolute inset-0 rounded-[42px]"
          style={{
            background:
              "linear-gradient(145deg, #6e6e73 0%, #3a3a3c 18%, #1c1c1e 50%, #2c2c2e 82%, #636366 100%)",
            boxShadow:
              "0 40px 80px rgba(0,0,0,0.55), inset 0 1px 1px rgba(255,255,255,0.35), inset 0 -1px 1px rgba(0,0,0,0.5)",
          }}
        />
        {/* Side buttons hint */}
        <div className="absolute -left-[3px] top-[96px] h-[28px] w-[3px] rounded-l-sm bg-[#4a4a4c]" />
        <div className="absolute -left-[3px] top-[140px] h-[52px] w-[3px] rounded-l-sm bg-[#4a4a4c]" />
        <div className="absolute -left-[3px] top-[200px] h-[52px] w-[3px] rounded-l-sm bg-[#4a4a4c]" />
        <div className="absolute -right-[3px] top-[150px] h-[80px] w-[3px] rounded-r-sm bg-[#4a4a4c]" />

        {/* Screen bezel */}
        <div className="absolute inset-[10px] overflow-hidden rounded-[34px] bg-black shadow-[inset_0_0_0_2px_#0a0a0a]">
          <DynamicIsland expanded={islandExpanded} />

          {view === "lock" && <LockScreen player={data} onUnlock={() => setView("home")} />}
          {view === "home" && (
            <HomeScreen
              player={data}
              onOpenApp={(id) => {
                setActiveApp(id);
                setView("app");
              }}
            />
          )}
          {view === "app" && activeApp && (
            <AppScreen
              appId={activeApp}
              player={data}
              onBack={() => {
                setActiveApp(null);
                setView("home");
              }}
            />
          )}

          {/* Home indicator */}
          <div className="pointer-events-none absolute bottom-2 left-1/2 z-50 h-[5px] w-[120px] -translate-x-1/2 rounded-full bg-white/80 mix-blend-difference" />
        </div>
      </div>

      <button
        type="button"
        className="absolute bottom-6 rounded-full border border-white/20 bg-black/50 px-5 py-2 text-[12px] font-semibold tracking-wide text-white/90 backdrop-blur-md"
        onClick={close}
      >
        Put Away · ESC
      </button>

      <style>{`
        @keyframes ipadIn {
          from { opacity: 0; transform: translateY(18px) scale(0.96); }
          to { opacity: 1; transform: translateY(0) scale(1); }
        }
      `}</style>
    </div>
  );
}
