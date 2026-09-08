import React from "react";
import { BatteryFull, Signal, Wifi } from "lucide-react";
import { cn } from "@/lib/utils";
import type { PhonePlayerData } from "../Phone";

function useClock(enabled = true) {
  const [now, setNow] = React.useState(() => new Date());
  React.useEffect(() => {
    if (!enabled) return;
    const id = window.setInterval(() => setNow(new Date()), 1000);
    return () => window.clearInterval(id);
  }, [enabled]);
  return now;
}

export function PhoneStatusBar({ light }: { light?: boolean }) {
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

export function AppChrome({
  title,
  light,
  dark,
  right,
  children,
}: {
  title: string;
  light?: boolean;
  /** Dark / modern shell (preferred for phone apps) */
  dark?: boolean;
  right?: React.ReactNode;
  children: React.ReactNode;
}) {
  const isDark = dark || light;
  return (
    <div
      className={cn(
        "absolute inset-0 flex flex-col select-none",
        isDark ? "bg-[#0c0e14]" : "bg-[#f2f2f7]",
      )}
    >
      <PhoneStatusBar light={isDark} />
      <div
        className={cn(
          "relative border-b px-3 pb-2 pt-2",
          isDark ? "border-white/8 bg-[#0c0e14]" : "border-black/5",
        )}
      >
        <p
          className={cn(
            "text-center text-[15px] font-semibold tracking-tight",
            isDark ? "text-[#f8f3e8]" : "text-black",
          )}
        >
          {title}
        </p>
        {right ? (
          <div className="absolute right-2 top-1/2 flex -translate-y-1/2 items-center gap-1">
            {right}
          </div>
        ) : null}
      </div>
      <div className="no-scrollbar min-h-0 flex-1 overflow-y-auto overflow-x-hidden pb-11">
        {children}
      </div>
    </div>
  );
}

export function formatMoney(n: number) {
  return `$${Math.max(0, Math.floor(n || 0)).toLocaleString()}`;
}

export type { PhonePlayerData };
