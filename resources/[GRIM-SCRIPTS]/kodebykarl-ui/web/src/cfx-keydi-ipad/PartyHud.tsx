import { useEffect, useState } from "react";
import { Heart, Shield } from "lucide-react";
import { isBrowserEnv } from "@/lib/nui";

type PartyMemberHud = {
  slot: number;
  name: string;
  leader?: boolean;
  online?: boolean;
  health?: number;
  armor?: number;
};

type PartyHudData = {
  visible?: boolean;
  name?: string;
  count?: number;
  max?: number;
  members?: PartyMemberHud[];
};

const PREVIEW: PartyHudData = {
  visible: true,
  name: "Night Crew",
  count: 2,
  max: 4,
  members: [
    { slot: 1, name: "Kosel Carpio", leader: true, online: true, health: 92, armor: 0 },
    { slot: 2, name: "Mia Storm", leader: false, online: true, health: 64, armor: 40 },
  ],
};

function Ring({ value, color, size = 28, stroke = 3 }: { value: number; color: string; size?: number; stroke?: number }) {
  const pct = Math.max(0, Math.min(100, value));
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const dash = (pct / 100) * c;
  return (
    <svg width={size} height={size} className="-rotate-90">
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth={stroke} />
      <circle
        cx={size / 2}
        cy={size / 2}
        r={r}
        fill="none"
        stroke={color}
        strokeWidth={stroke}
        strokeLinecap="round"
        strokeDasharray={`${dash} ${c}`}
      />
    </svg>
  );
}

function initials(name: string) {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "?";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

export default function PartyHud() {
  const [data, setData] = useState<PartyHudData | null>(() => {
    if (isBrowserEnv() && new URLSearchParams(window.location.search).get("preview") === "party") {
      return PREVIEW;
    }
    return null;
  });

  useEffect(() => {
    const onMsg = (event: MessageEvent) => {
      const msg = event.data;
      if (!msg || msg.action !== "cfx-keydi-ipad:party:hud") return;
      const payload = (msg.data || {}) as PartyHudData;
      if (!payload.visible) {
        setData(null);
        return;
      }
      setData(payload);
    };
    window.addEventListener("message", onMsg);
    return () => window.removeEventListener("message", onMsg);
  }, []);

  if (!data?.visible || !data.members?.length) return null;

  const max = data.max || 4;
  const count = data.count || data.members.length;

  return (
    <div
      className="pointer-events-none fixed right-4 top-1/2 z-[99980] w-[240px] -translate-y-1/2 select-none"
      style={{ fontFamily: "'Outfit', sans-serif" }}
    >
      <div
        className="overflow-hidden"
        style={{
          background: "linear-gradient(180deg, rgba(22,12,14,0.94) 0%, rgba(10,8,10,0.96) 100%)",
          clipPath: "polygon(10px 0, 100% 0, 100% calc(100% - 10px), calc(100% - 10px) 100%, 0 100%, 0 10px)",
          borderLeft: "3px solid #ff3a3a",
        }}
      >
        <div className="flex items-end justify-between px-3 pb-1.5 pt-2.5">
          <div>
            <p className="text-[9px] font-semibold uppercase tracking-[0.22em] text-white/35">Grim Squad</p>
            <p className="truncate text-[13px] font-bold leading-tight text-white">{data.name || "Squad"}</p>
          </div>
          <p className="text-[10px] font-semibold tabular-nums text-[#ff8080]">
            {count}
            <span className="text-white/30"> · {max}</span>
          </p>
        </div>

        <div className="space-y-px">
          {data.members.slice(0, max).map((m) => {
            const hp = m.online ? m.health || 0 : 0;
            const ar = m.online ? m.armor || 0 : 0;
            return (
              <div key={`${m.slot}-${m.name}`} className="flex items-center gap-2.5 px-3 py-2">
                <div
                  className="relative flex h-8 w-8 shrink-0 items-center justify-center text-[10px] font-bold"
                  style={{
                    background: m.online ? "rgba(255,58,58,0.18)" : "rgba(255,255,255,0.04)",
                    color: m.online ? "#ffb4b4" : "rgba(255,255,255,0.28)",
                    clipPath: "polygon(6px 0, 100% 0, 100% calc(100% - 6px), calc(100% - 6px) 100%, 0 100%, 0 6px)",
                  }}
                >
                  {initials(m.name)}
                </div>
                <div className="min-w-0 flex-1">
                  <p className={`truncate text-[12px] font-semibold leading-tight ${m.online ? "text-white" : "text-white/30"}`}>
                    {m.name}
                  </p>
                  <p className="text-[9px] font-medium uppercase tracking-wider text-white/30">
                    {m.leader ? "Host" : "Member"}
                    {m.online ? "" : " · Away"}
                  </p>
                </div>
                <div className="flex items-center gap-1.5">
                  <div className="relative">
                    <Ring value={hp} color="#ff3a3a" />
                    <Heart className="absolute left-1/2 top-1/2 h-2.5 w-2.5 -translate-x-1/2 -translate-y-1/2 text-[#ff3a3a]" />
                  </div>
                  <div className="relative">
                    <Ring value={ar} color="#8ea4c8" />
                    <Shield className="absolute left-1/2 top-1/2 h-2.5 w-2.5 -translate-x-1/2 -translate-y-1/2 text-[#8ea4c8]" />
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
