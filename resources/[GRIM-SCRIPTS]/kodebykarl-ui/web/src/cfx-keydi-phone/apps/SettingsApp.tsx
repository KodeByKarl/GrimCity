import React, { useCallback, useEffect, useState } from "react";
import {
  Bell,
  ChevronRight,
  Info,
  Keyboard,
  Phone,
  Shield,
  Smartphone,
  User,
  Volume2,
} from "lucide-react";
import { AppChrome, formatMoney, type PhonePlayerData } from "./shared";

interface PhoneSettings {
  messageNotify: boolean;
  messageSound: boolean;
  useProp: boolean;
}

const DEFAULTS: PhoneSettings = {
  messageNotify: true,
  messageSound: true,
  useProp: true,
};

function isBrowser() {
  return (
    !(window as unknown as { invokeNative?: unknown }).invokeNative &&
    !navigator.userAgent.includes("FiveM")
  );
}

async function nui<T>(event: string, data: Record<string, unknown> = {}): Promise<T | null> {
  if (isBrowser()) {
    if (event.endsWith(":get")) {
      return { ok: true, settings: DEFAULTS } as T;
    }
    return { ok: true, settings: { ...DEFAULTS, ...data } } as T;
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

function Toggle({
  checked,
  onChange,
  disabled,
}: {
  checked: boolean;
  onChange: (next: boolean) => void;
  disabled?: boolean;
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      disabled={disabled}
      onPointerDown={(e) => {
        e.stopPropagation();
      }}
      onClick={(e) => {
        e.stopPropagation();
        if (disabled) return;
        onChange(!checked);
      }}
      className={`relative h-7 w-[51px] shrink-0 rounded-full border border-black/20 p-0.5 shadow-inner transition-colors duration-200 ease-out disabled:opacity-50 ${
        checked ? "bg-[#30d158]" : "bg-[#39393d]"
      }`}
    >
      <span
        className={`block h-6 w-6 rounded-full bg-white shadow-[0_1px_3px_rgba(0,0,0,0.35)] transition-transform duration-200 ease-out will-change-transform ${
          checked ? "translate-x-[23px]" : "translate-x-0"
        }`}
      />
    </button>
  );
}

function Row({
  icon: Icon,
  iconBg,
  label,
  value,
  detail,
  toggle,
  onToggle,
  onClick,
}: {
  icon: React.ComponentType<{ className?: string; strokeWidth?: number }>;
  iconBg: string;
  label: string;
  value?: string;
  detail?: string;
  toggle?: boolean;
  onToggle?: (v: boolean) => void;
  onClick?: () => void;
}) {
  const hasToggle = typeof toggle === "boolean" && !!onToggle;
  const clickable = !!onClick || hasToggle;

  return (
    <div
      role={clickable ? "button" : undefined}
      tabIndex={clickable ? 0 : undefined}
      onClick={() => {
        if (hasToggle && onToggle) onToggle(!toggle);
        else onClick?.();
      }}
      onKeyDown={(e) => {
        if (!clickable) return;
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          if (hasToggle && onToggle) onToggle(!toggle);
          else onClick?.();
        }
      }}
      className={`flex w-full items-center gap-3 px-3 py-3 text-left transition ${
        clickable ? "cursor-pointer active:bg-white/5" : ""
      }`}
    >
      <div
        className="flex h-8 w-8 shrink-0 items-center justify-center rounded-[8px] text-white"
        style={{ backgroundColor: iconBg }}
      >
        <Icon className="h-4 w-4" strokeWidth={2} />
      </div>
      <div className="min-w-0 flex-1">
        <p className="truncate text-[14px] font-semibold text-[#f8f3e8]">{label}</p>
        {detail ? <p className="truncate text-[11px] text-[#9a9386]">{detail}</p> : null}
      </div>
      {hasToggle ? (
        <Toggle checked={!!toggle} onChange={(v) => onToggle?.(v)} />
      ) : value ? (
        <span className="max-w-[42%] truncate text-right text-[12px] tabular-nums text-[#9a9386]">
          {value}
        </span>
      ) : onClick ? (
        <ChevronRight className="h-4 w-4 text-[#5c564c]" />
      ) : null}
    </div>
  );
}

function Section({ title, children }: { title?: string; children: React.ReactNode }) {
  return (
    <div>
      {title ? (
        <p className="mb-1.5 px-1 text-[10px] font-black uppercase tracking-[0.16em] text-[#9a9386]">
          {title}
        </p>
      ) : null}
      <div className="overflow-hidden rounded-2xl border border-white/8 bg-[#141720]">{children}</div>
    </div>
  );
}

export default function SettingsApp({ player }: { player?: PhonePlayerData | null }) {
  const [settings, setSettings] = useState<PhoneSettings>(DEFAULTS);
  const [aboutOpen, setAboutOpen] = useState(false);
  const [loading, setLoading] = useState(true);

  const name = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Citizen";
  const number = player?.number || "—";
  const job = player?.job || "Unemployed";

  const load = useCallback(async () => {
    setLoading(true);
    const res = await nui<{ ok?: boolean; settings?: PhoneSettings }>("cfx-keydi-phone:settings:get");
    if (res?.settings) setSettings({ ...DEFAULTS, ...res.settings });
    setLoading(false);
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const patch = async (partial: Partial<PhoneSettings>) => {
    setSettings((prev) => {
      const next = { ...prev, ...partial };
      void nui("cfx-keydi-phone:settings:set", {
        messageNotify: next.messageNotify,
        messageSound: next.messageSound,
        useProp: next.useProp,
      });
      return next;
    });
  };

  if (aboutOpen) {
    return (
      <AppChrome
        title="About"
        dark
        right={
          <button
            type="button"
            onClick={() => setAboutOpen(false)}
            className="px-1 text-[13px] font-semibold text-[#f5c542]"
          >
            Done
          </button>
        }
      >
        <div className="flex min-h-full flex-col gap-3 bg-[#0c0e14] px-3 pb-12 pt-3">
          <div className="rounded-2xl border border-[#f5c542]/20 bg-gradient-to-br from-[#1a160c] to-[#12141c] px-4 py-5 text-center">
            <Smartphone className="mx-auto h-10 w-10 text-[#f5c542]" />
            <p className="mt-3 text-[18px] font-black text-[#f8f3e8]">Grim Phone</p>
            <p className="mt-1 text-[12px] text-[#9a9386]">Companion · v1.0</p>
          </div>
          <Section title="Included">
            <div className="divide-y divide-white/6 px-3 py-1 text-[12px] leading-relaxed text-[#c9b896]">
              <p className="py-2.5">Wallet — bank & cash snapshot</p>
              <p className="py-2.5">Market — live sell prices</p>
              <p className="py-2.5">Contacts — saved to database</p>
              <p className="py-2.5">Messages — DMs + notifications</p>
            </div>
          </Section>
          <p className="px-1 text-center text-[11px] text-[#5c564c]">
            Calls & SMS still use lb-phone if installed.
          </p>
        </div>
      </AppChrome>
    );
  }

  return (
    <AppChrome title="Settings" dark>
      <div className="flex min-h-full flex-col gap-4 bg-gradient-to-b from-[#0c0e14] via-[#12141c] to-[#0a0c12] px-3 pb-12 pt-2">
        {/* Profile */}
        <div className="flex items-center gap-3 rounded-2xl border border-white/8 bg-[#141720] px-3.5 py-3.5">
          <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-[#3a4558] to-[#1a2030] text-[18px] font-black text-[#f5c542] ring-1 ring-white/10">
            {name
              .split(/\s+/)
              .filter(Boolean)
              .slice(0, 2)
              .map((p) => p[0])
              .join("")
              .toUpperCase() || "?"}
          </div>
          <div className="min-w-0 flex-1">
            <p className="truncate text-[17px] font-bold text-[#f8f3e8]">{name}</p>
            <p className="mt-0.5 text-[12px] text-[#9a9386]">{job}</p>
            <p className="mt-1 text-[11px] font-medium tabular-nums tracking-wide text-[#f5c542]/90">
              {number}
            </p>
          </div>
        </div>

        <Section title="Account">
          <Row icon={User} iconBg="#007aff" label="Citizen" value={name} />
          <div className="border-t border-white/6" />
          <Row icon={Phone} iconBg="#30d158" label="My Number" value={number} detail="SSN used for contacts & messages" />
          <div className="border-t border-white/6" />
          <Row
            icon={Shield}
            iconBg="#5856d6"
            label="Wallet"
            value={`${formatMoney(player?.bank ?? 0)} bank`}
            detail={`Cash ${formatMoney(player?.cash ?? 0)}`}
          />
        </Section>

        <Section title="Notifications">
          <Row
            icon={Bell}
            iconBg="#ff3b30"
            label="Message alerts"
            detail="Toast + ox_lib when someone DMs you"
            toggle={settings.messageNotify}
            onToggle={(v) => void patch({ messageNotify: v })}
          />
          <div className="border-t border-white/6" />
          <Row
            icon={Volume2}
            iconBg="#ff9500"
            label="Message sound"
            detail="Play SMS tone on new messages"
            toggle={settings.messageSound}
            onToggle={(v) => void patch({ messageSound: v })}
          />
        </Section>

        <Section title="Phone">
          <Row
            icon={Smartphone}
            iconBg="#8e8e93"
            label="Hold phone prop"
            detail="Show phone in hand while open"
            toggle={settings.useProp}
            onToggle={(v) => void patch({ useProp: v })}
          />
          <div className="border-t border-white/6" />
          <Row
            icon={Keyboard}
            iconBg="#64d2ff"
            label="Open shortcut"
            value="/phone · F6"
            detail="Esc / home bar to go back"
          />
        </Section>

        <Section title="General">
          <Row
            icon={Info}
            iconBg="#007aff"
            label="About Grim Phone"
            onClick={() => setAboutOpen(true)}
          />
        </Section>

        {loading ? (
          <p className="text-center text-[11px] text-[#5c564c]">Syncing preferences…</p>
        ) : (
          <p className="text-center text-[11px] text-[#5c564c]">Preferences saved on this client.</p>
        )}
      </div>
    </AppChrome>
  );
}
