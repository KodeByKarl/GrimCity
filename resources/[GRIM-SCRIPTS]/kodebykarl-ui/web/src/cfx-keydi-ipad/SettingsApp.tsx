import React, { useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import {
  AppWindow,
  BatteryFull,
  Bell,
  Bluetooth,
  ChevronRight,
  Globe,
  Info,
  Moon,
  Plane,
  Search,
  Settings,
  Shield,
  Signal,
  Sun,
  User,
  Volume2,
  Wallet,
  Wifi,
  type LucideIcon,
} from "lucide-react";
import type { IpadPlayerData } from "./Ipad";

type SectionId =
  | "profile"
  | "wifi"
  | "bluetooth"
  | "cellular"
  | "notifications"
  | "sounds"
  | "focus"
  | "display"
  | "general"
  | "privacy"
  | "wallet"
  | "grim"
  | "about";

interface NavItem {
  id: SectionId;
  label: string;
  icon: LucideIcon;
  tint: string;
  value?: string;
}

function Toggle({
  on,
  onChange,
}: {
  on: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      className={cn(
        "relative h-[31px] w-[51px] shrink-0 rounded-full transition-colors duration-200",
        on ? "bg-[#34c759]" : "bg-[#e9e9eb]",
      )}
      onClick={() => onChange(!on)}
    >
      <span
        className={cn(
          "absolute top-[2px] h-[27px] w-[27px] rounded-full bg-white shadow-[0_1px_3px_rgba(0,0,0,0.25)] transition-transform duration-200",
          on ? "translate-x-[22px]" : "translate-x-[2px]",
        )}
      />
    </button>
  );
}

function Group({ children, footer }: { children: React.ReactNode; footer?: string }) {
  return (
    <div className="mb-6">
      <div className="overflow-hidden rounded-[12px] bg-white">{children}</div>
      {footer ? <p className="mt-2 px-4 text-[13px] leading-snug text-[#8e8e93]">{footer}</p> : null}
    </div>
  );
}

function Row({
  label,
  value,
  detail,
  onClick,
  chevron,
  right,
  destructive,
  last,
}: {
  label: string;
  value?: string;
  detail?: string;
  onClick?: () => void;
  chevron?: boolean;
  right?: React.ReactNode;
  destructive?: boolean;
  last?: boolean;
}) {
  const Comp = onClick ? "button" : "div";
  return (
    <Comp
      type={onClick ? "button" : undefined}
      className={cn(
        "flex w-full items-center gap-3 bg-white px-4 py-[11px] text-left",
        onClick && "active:bg-[#d1d1d6]/40",
        !last && "border-b border-[#c6c6c8]/55",
      )}
      onClick={onClick}
    >
      <div className="min-w-0 flex-1">
        <p className={cn("text-[17px]", destructive ? "text-[#ff3b30]" : "text-black")}>{label}</p>
        {detail ? <p className="mt-0.5 text-[13px] text-[#8e8e93]">{detail}</p> : null}
      </div>
      {value ? <span className="shrink-0 text-[17px] text-[#8e8e93]">{value}</span> : null}
      {right}
      {chevron ? <ChevronRight className="h-[18px] w-[18px] shrink-0 text-[#c7c7cc]" strokeWidth={2.4} /> : null}
    </Comp>
  );
}

function IconBadge({ icon: Icon, tint }: { icon: LucideIcon; tint: string }) {
  return (
    <div className={cn("flex h-[29px] w-[29px] shrink-0 items-center justify-center rounded-[7px] text-white", tint)}>
      <Icon className="h-[16px] w-[16px]" strokeWidth={2.2} />
    </div>
  );
}

function SettingsStatusBar() {
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

export default function SettingsApp({
  player,
}: {
  player?: IpadPlayerData | null;
}) {
  const [section, setSection] = useState<SectionId>("profile");
  const [query, setQuery] = useState("");

  const [airplane, setAirplane] = useState(false);
  const [wifi, setWifi] = useState(true);
  const [bluetooth, setBluetooth] = useState(true);
  const [cellular, setCellular] = useState(true);
  const [notifLock, setNotifLock] = useState(true);
  const [notifBanners, setNotifBanners] = useState(true);
  const [notifSounds, setNotifSounds] = useState(true);
  const [ringtone, setRingtone] = useState(true);
  const [haptics, setHaptics] = useState(true);
  const [focus, setFocus] = useState(false);
  const [darkMode, setDarkMode] = useState(false);
  const [trueTone, setTrueTone] = useState(true);
  const [nightShift, setNightShift] = useState(false);
  const [autoLock, setAutoLock] = useState(true);
  const [raiseToWake, setRaiseToWake] = useState(true);
  const [location, setLocation] = useState(true);
  const [tracking, setTracking] = useState(false);
  const [analytics, setAnalytics] = useState(true);
  const [brightness, setBrightness] = useState(72);
  const [volume, setVolume] = useState(55);

  const name = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Citizen";

  const nav: NavItem[] = useMemo(
    () => [
      { id: "profile", label: name, icon: User, tint: "bg-[#8e8e93]" },
      { id: "wifi", label: "Wi‑Fi", icon: Wifi, tint: "bg-[#007aff]", value: wifi ? "Grim_City_5G" : "Off" },
      { id: "bluetooth", label: "Bluetooth", icon: Bluetooth, tint: "bg-[#007aff]", value: bluetooth ? "On" : "Off" },
      { id: "cellular", label: "Cellular", icon: Signal, tint: "bg-[#30d158]", value: cellular ? "On" : "Off" },
      { id: "notifications", label: "Notifications", icon: Bell, tint: "bg-[#ff3b30]" },
      { id: "sounds", label: "Sounds & Haptics", icon: Volume2, tint: "bg-[#ff2d55]" },
      { id: "focus", label: "Focus", icon: Moon, tint: "bg-[#5856d6]" },
      { id: "display", label: "Display & Brightness", icon: Sun, tint: "bg-[#007aff]" },
      { id: "general", label: "General", icon: Settings, tint: "bg-[#8e8e93]" },
      { id: "privacy", label: "Privacy & Security", icon: Shield, tint: "bg-[#30d158]" },
      { id: "wallet", label: "Wallet & Balance", icon: Wallet, tint: "bg-black" },
      { id: "grim", label: "Grim City", icon: AppWindow, tint: "bg-[#ff3b30]" },
      { id: "about", label: "About Keydi.dev", icon: Info, tint: "bg-[#007aff]" },
    ],
    [name, wifi, bluetooth, cellular],
  );

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return nav;
    return nav.filter((n) => n.label.toLowerCase().includes(q) || n.id.includes(q));
  }, [nav, query]);

  const title = nav.find((n) => n.id === section)?.label ?? "Settings";

  return (
    <div className="absolute inset-0 flex flex-col bg-[#f2f2f7] select-none">
      <SettingsStatusBar />

      <div className="flex min-h-0 flex-1 overflow-hidden">
        {/* Sidebar */}
        <aside className="flex w-[340px] shrink-0 flex-col border-r border-black/10 bg-[#f2f2f7]">
          <div className="flex items-center justify-center px-2 pb-2 pt-2">
            <p className="text-[17px] font-semibold text-black">Settings</p>
          </div>

          <div className="px-3 pb-3">
            <div className="flex items-center gap-2 rounded-[10px] bg-[#e3e3e8] px-3 py-2">
              <Search className="h-4 w-4 text-[#8e8e93]" strokeWidth={2.4} />
              <input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Search"
                className="w-full bg-transparent text-[16px] text-black outline-none placeholder:text-[#8e8e93]"
              />
            </div>
          </div>

          <div className="min-h-0 flex-1 overflow-y-auto px-3 pb-6">
            {/* Airplane quick row */}
            <div className="mb-4 overflow-hidden rounded-[12px] bg-white">
              <div className="flex items-center gap-3 px-3 py-[10px]">
                <IconBadge icon={Plane} tint="bg-[#ff9500]" />
                <p className="flex-1 text-[17px] text-black">Airplane Mode</p>
                <Toggle on={airplane} onChange={setAirplane} />
              </div>
            </div>

            <div className="overflow-hidden rounded-[12px] bg-white">
              {filtered.map((item, i) => (
                <button
                  key={item.id}
                  type="button"
                  className={cn(
                    "flex w-full items-center gap-3 px-3 py-[10px] text-left transition-colors",
                    section === item.id ? "bg-[#d1d1d6]/55" : "active:bg-[#d1d1d6]/35",
                    i < filtered.length - 1 && "border-b border-[#c6c6c8]/55",
                  )}
                  onClick={() => setSection(item.id)}
                >
                  <IconBadge icon={item.icon} tint={item.tint} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-[17px] text-black">{item.label}</p>
                    {item.id === "profile" ? (
                      <p className="truncate text-[13px] text-[#8e8e93]">Apple ID, Character, Job</p>
                    ) : null}
                  </div>
                  {item.value ? <span className="text-[15px] text-[#8e8e93]">{item.value}</span> : null}
                  <ChevronRight className="h-[18px] w-[18px] shrink-0 text-[#c7c7cc]" strokeWidth={2.4} />
                </button>
              ))}
            </div>
          </div>
        </aside>

        {/* Detail */}
        <main className="min-w-0 flex-1 overflow-y-auto px-8 pb-10 pt-4">
          <h1 className="mb-5 text-[28px] font-bold tracking-tight text-black">{title}</h1>

          {section === "profile" && (
            <>
              <div className="mb-6 flex items-center gap-4 rounded-[12px] bg-white px-4 py-4">
                <div className="flex h-[64px] w-[64px] items-center justify-center rounded-full bg-gradient-to-br from-[#a1a1a6] to-[#636366] text-[24px] font-semibold text-white">
                  {name.slice(0, 1).toUpperCase()}
                </div>
                <div>
                  <p className="text-[22px] font-semibold text-black">{name}</p>
                  <p className="text-[15px] text-[#8e8e93]">Grim City Character · Keydi ID</p>
                </div>
              </div>
              <Group footer="Character info syncs from your active session in Los Santos.">
                <Row label="First Name" value={player?.firstName || "—"} last={false} />
                <Row label="Last Name" value={player?.lastName || "—"} last={false} />
                <Row label="Job" value={player?.job || "Unemployed"} last={false} />
                <Row label="Gang" value={player?.gang || "None"} last={false} />
                <Row label="Playtime" value={player?.playtime || "—"} last />
              </Group>
              <Group>
                <Row label="Name, Phone Numbers, Email" chevron last={false} />
                <Row label="Password & Security" chevron last={false} />
                <Row label="Payment & Shipping" chevron last />
              </Group>
            </>
          )}

          {section === "wifi" && (
            <>
              <Group footer="Choose a network to join Grim City Wi‑Fi while roleplaying online.">
                <Row
                  label="Wi‑Fi"
                  right={<Toggle on={wifi && !airplane} onChange={(v) => { setWifi(v); if (v) setAirplane(false); }} />}
                  last
                />
              </Group>
              {wifi && !airplane ? (
                <Group>
                  <Row label="Grim_City_5G" value="Connected" chevron last={false} />
                  <Row label="LS_Public" chevron last={false} />
                  <Row label="Sandy_Shores_Guest" chevron last={false} />
                  <Row label="Other…" chevron last />
                </Group>
              ) : (
                <p className="px-1 text-[15px] text-[#8e8e93]">
                  {airplane ? "Turn off Airplane Mode to use Wi‑Fi." : "Wi‑Fi is turned off."}
                </p>
              )}
            </>
          )}

          {section === "bluetooth" && (
            <>
              <Group footer="Bluetooth devices can connect for audio and accessories in-game.">
                <Row
                  label="Bluetooth"
                  right={<Toggle on={bluetooth && !airplane} onChange={setBluetooth} />}
                  last
                />
              </Group>
              {bluetooth && !airplane ? (
                <Group>
                  <Row label="AirPods Pro" value="Not Connected" chevron last={false} />
                  <Row label="Keydi Gamepad" value="Not Connected" chevron last />
                </Group>
              ) : null}
            </>
          )}

          {section === "cellular" && (
            <>
              <Group footer="Cellular data powers live server status, messages, and region sync.">
                <Row label="Cellular Data" right={<Toggle on={cellular && !airplane} onChange={setCellular} />} last />
              </Group>
              <Group>
                <Row label="Network Selection" value="Automatic" chevron last={false} />
                <Row label="Data Mode" value="Standard" chevron last={false} />
                <Row label="Wi‑Fi Calling" value="Off" chevron last />
              </Group>
            </>
          )}

          {section === "notifications" && (
            <>
              <Group footer="Controls banners, lock screen alerts, and Keydi.dev island messages.">
                <Row label="Allow Notifications" right={<Toggle on={notifBanners} onChange={setNotifBanners} />} last={false} />
                <Row label="Lock Screen" right={<Toggle on={notifLock} onChange={setNotifLock} />} last={false} />
                <Row label="Notification Sounds" right={<Toggle on={notifSounds} onChange={setNotifSounds} />} last />
              </Group>
              <Group>
                <Row label="Scheduled Summary" value="Off" chevron last={false} />
                <Row label="Show Previews" value="Always" chevron last={false} />
                <Row label="Keydi.dev Messages" value="Priority" chevron last />
              </Group>
            </>
          )}

          {section === "sounds" && (
            <>
              <Group>
                <div className="flex items-center gap-3 px-4 py-3">
                  <Volume2 className="h-5 w-5 text-[#8e8e93]" />
                  <input
                    type="range"
                    min={0}
                    max={100}
                    value={volume}
                    onChange={(e) => setVolume(Number(e.target.value))}
                    className="h-1.5 w-full accent-[#007aff]"
                  />
                </div>
              </Group>
              <Group>
                <Row label="Ringtone" right={<Toggle on={ringtone} onChange={setRingtone} />} last={false} />
                <Row label="System Haptics" right={<Toggle on={haptics} onChange={setHaptics} />} last={false} />
                <Row label="Keyboard Clicks" value="On" chevron last />
              </Group>
            </>
          )}

          {section === "focus" && (
            <>
              <Group footer="Focus silences non-priority alerts while you grind or run turfs.">
                <Row label="Do Not Disturb" right={<Toggle on={focus} onChange={setFocus} />} last />
              </Group>
              <Group>
                <Row label="Driving" chevron last={false} />
                <Row label="Sleep" chevron last={false} />
                <Row label="Work" chevron last />
              </Group>
            </>
          )}

          {section === "display" && (
            <>
              <Group>
                <div className="flex items-center gap-3 px-4 py-3">
                  <Sun className="h-4 w-4 text-[#8e8e93]" />
                  <input
                    type="range"
                    min={10}
                    max={100}
                    value={brightness}
                    onChange={(e) => setBrightness(Number(e.target.value))}
                    className="h-1.5 w-full accent-[#007aff]"
                  />
                  <Sun className="h-5 w-5 text-black" />
                </div>
              </Group>
              <Group>
                <Row label="Dark Mode" right={<Toggle on={darkMode} onChange={setDarkMode} />} last={false} />
                <Row label="True Tone" right={<Toggle on={trueTone} onChange={setTrueTone} />} last={false} />
                <Row label="Night Shift" right={<Toggle on={nightShift} onChange={setNightShift} />} last />
              </Group>
              <Group>
                <Row label="Text Size" chevron last={false} />
                <Row label="Bold Text" value="Off" chevron last />
              </Group>
            </>
          )}

          {section === "general" && (
            <>
              <Group>
                <Row label="About" value="iPad Pro · Grim City" chevron last={false} />
                <Row label="Software Update" value="Up to Date" chevron last={false} />
                <Row label="AirDrop" value="Contacts Only" chevron last />
              </Group>
              <Group>
                <Row label="Auto-Lock" right={<Toggle on={autoLock} onChange={setAutoLock} />} last={false} />
                <Row label="Raise to Wake" right={<Toggle on={raiseToWake} onChange={setRaiseToWake} />} last={false} />
                <Row label="Date & Time" value="Automatic" chevron last={false} />
                <Row label="Language & Region" value="English (US)" chevron last />
              </Group>
              <Group>
                <Row label="Transfer or Reset iPad" destructive chevron last />
              </Group>
            </>
          )}

          {section === "privacy" && (
            <>
              <Group footer="Manage what Grim City apps can access from this iPad.">
                <Row label="Location Services" right={<Toggle on={location} onChange={setLocation} />} last={false} />
                <Row label="Tracking" right={<Toggle on={tracking} onChange={setTracking} />} last={false} />
                <Row label="Analytics & Improvements" right={<Toggle on={analytics} onChange={setAnalytics} />} last />
              </Group>
              <Group>
                <Row label="Contacts" chevron last={false} />
                <Row label="Photos" chevron last={false} />
                <Row label="Microphone" chevron last={false} />
                <Row label="Camera" chevron last />
              </Group>
              <Group>
                <Row
                  label="Lock Down Mode"
                  detail="Extra protection for high-risk situations."
                  chevron
                  last
                />
              </Group>
            </>
          )}

          {section === "wallet" && (
            <>
              <div className="mb-6 overflow-hidden rounded-[16px] bg-gradient-to-br from-[#1c1c1e] to-black p-5 text-white shadow-md">
                <p className="text-[13px] text-white/55">Bank Balance</p>
                <p className="mt-1 text-[36px] font-semibold tracking-tight">
                  ${(player?.bank ?? 0).toLocaleString()}
                </p>
                <p className="mt-3 text-[14px] text-white/70">
                  Cash on hand · ${(player?.cash ?? 0).toLocaleString()}
                </p>
              </div>
              <Group footer="Balances update from your live character economy.">
                <Row label="Default Card" value="Fleeca Debit" chevron last={false} />
                <Row label="Transaction History" chevron last={false} />
                <Row label="Express Mode" value="On" chevron last />
              </Group>
            </>
          )}

          {section === "grim" && (
            <>
              <Group footer="Server-facing options for your Grim City iPad.">
                <Row label="Server Status" value="Online" last={false} />
                <Row label="Region Sync" value="Enabled" chevron last={false} />
                <Row label="Gang System" value={player?.gang || "None"} chevron last={false} />
                <Row label="Turf Alerts" value="On" chevron last />
              </Group>
              <Group>
                <Row label="Open Grim Hub" chevron last={false} />
                <Row label="Refresh Character Data" chevron last />
              </Group>
            </>
          )}

          {section === "about" && (
            <>
              <div className="mb-6 rounded-[12px] bg-white px-4 py-5 text-center">
                <div className="mx-auto mb-3 flex h-16 w-16 items-center justify-center rounded-[18px] bg-gradient-to-br from-[#64d2ff] to-[#007aff] text-white shadow-md">
                  <Globe className="h-8 w-8" strokeWidth={1.8} />
                </div>
                <p className="text-[22px] font-semibold text-black">Keydi.dev</p>
                <p className="mt-1 text-[15px] text-[#8e8e93]">Developer · Grim City Systems</p>
              </div>
              <Group footer="This iPad UI was built by Keydi.dev for Grim City roleplay.">
                <Row label="Developer" value="Keydi.dev" last={false} />
                <Row label="Product" value="kodebykarl-ui iPad" last={false} />
                <Row label="Version" value="1.0.0" last={false} />
                <Row label="Build" value="2026.09.05" last />
              </Group>
              <Group>
                <Row label="Acknowledgements" chevron last={false} />
                <Row label="Visit Keydi.dev" chevron last />
              </Group>
            </>
          )}
        </main>
      </div>
    </div>
  );
}
