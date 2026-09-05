import React, { useState, useEffect } from "react";
import {
  Skull, HeartCrack, Ghost, AlertTriangle, X, Ban,
  Smile
} from "lucide-react";

interface IndicatorSettings {
  deadText: string;
  deadIcon: string;
  fontFamily: string;
  fontSize: number;
  duration: number;
  healthColor: string;
  armorColor: string;
}

interface DamageItem {
  id: string;
  type: "health" | "armor" | "dead";
  amount: string | number;
  x: number;
  y: number;
  zone?: string;
  zoneLabel?: string;
  zoneColor?: string;
  settings: IndicatorSettings;
}

interface DamageOverlayProps {
  currentSettings: IndicatorSettings;
}

const getDeadIconElement = (iconName: string) => {
  switch(iconName) {
    case "skull": return <Skull className="h-4 w-4 text-white fill-white/10" />;
    case "crossbones": return <Skull className="h-4 w-4 rotate-12 text-white fill-white/10" />;
    case "heart-crack": return <HeartCrack className="h-4 w-4 text-white" />;
    case "ghost": return <Ghost className="h-4 w-4 text-white" />;
    case "danger": return <AlertTriangle className="h-4 w-4 text-white" />;
    case "sick": return <Smile className="h-4 w-4 rotate-180 text-white" />;
    case "x-mark": return <X className="h-4 w-4 text-white" />;
    case "skull-io": return <Skull className="h-4 w-4 text-[#ffa6ce] fill-[#ffa6ce]/10" />;
    case "ban": return <Ban className="h-4 w-4 text-white" />;
    default: return <Skull className="h-4 w-4 text-white" />;
  }
};

function resolveHitColor(item: DamageItem) {
  // Zone colors always win so you can see where the bone registered
  if (item.zoneColor) return item.zoneColor;
  if (item.type === "health") return item.settings.healthColor;
  if (item.type === "armor") return item.settings.armorColor;
  return "#ffffff";
}

export default function DamageOverlay({ currentSettings }: DamageOverlayProps) {
  const [indicators, setIndicators] = useState<DamageItem[]>([]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const data = event.data;

      if (data.action === "indicator:triggerDamage" && data.data) {
        const item: DamageItem = {
          id: data.data.id,
          type: data.data.type,
          amount: data.data.amount,
          x: data.data.x,
          y: data.data.y,
          zone: data.data.zone,
          zoneLabel: data.data.zoneLabel,
          zoneColor: data.data.zoneColor,
          settings: { ...currentSettings }
        };

        setIndicators((prev) => [...prev, item]);

        const dur = (item.settings.duration || 3.0) * 1000;
        setTimeout(() => {
          setIndicators((prev) => prev.filter((i) => i.id !== item.id));
        }, dur + 100);
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, [currentSettings]);

  return (
    <div className="fixed inset-0 pointer-events-none select-none z-50 w-full h-full overflow-hidden">
      {indicators.map((item) => {
        const color = resolveHitColor(item);

        return (
          <div
            key={item.id}
            className="absolute animate-damage-float font-extrabold flex items-center justify-center gap-1"
            style={{
              left: `${item.x * 100}%`,
              top: `${item.y * 100}%`,
              fontFamily: item.settings.fontFamily,
              fontSize: `${item.settings.fontSize}px`,
              color: color,
              textShadow: "0 2px 5px rgba(0, 0, 0, 0.95), 0 0 2px rgba(0, 0, 0, 0.95)",
              ["--duration" as any]: `${item.settings.duration}s`
            }}
          >
            {item.type === "dead" && (
              <span className="flex items-center gap-1.5">
                {getDeadIconElement(item.settings.deadIcon)}
                {item.zoneLabel && (
                  <span className="text-[0.7em] font-black opacity-90">{item.zoneLabel}</span>
                )}
                <span className="uppercase">{item.amount}</span>
              </span>
            )}

            {item.type !== "dead" && (
              <>
                {item.zoneLabel && (
                  <span className="text-[0.72em] font-black tracking-wide opacity-95">
                    {item.zoneLabel}
                  </span>
                )}
                <span>
                  {item.type === "health" ? "-" : ""}
                  {item.amount}
                </span>
              </>
            )}
          </div>
        );
      })}
    </div>
  );
}
