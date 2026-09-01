import React, { useEffect, useMemo, useRef, useState } from "react";
import { Gift, X, Car, Sparkles, ChevronDown } from "lucide-react";
import grimLogo from "@/assets/grim-city-logo.png";

export interface FreeCarOption {
  model: string;
  label: string;
  category?: string;
  image?: string;
  chance?: number;
  rarity?: "common" | "rare" | "legendary" | string;
}

export interface FreeCarData {
  vehicles?: FreeCarOption[];
  title?: string;
  spinDurationMs?: number;
  bonusVehicle?: {
    model: string;
    label: string;
  };
}

export interface FreeCarMenuProps {
  visible?: boolean;
  data?: FreeCarData;
  onClose?: () => void;
}

type SpinPhase = "idle" | "spinning" | "landed";

const ITEM_WIDTH = 168;
const ITEM_GAP = 12;
const STRIDE = ITEM_WIDTH + ITEM_GAP;
const STRIP_LENGTH = 55;
const WINNER_INDEX = 48;

const DEFAULT_VEHICLES: FreeCarOption[] = [
  { model: "sultan", label: "Karin Sultan", chance: 32.333, rarity: "common" },
  { model: "kuruma", label: "Karin Kuruma", chance: 32.333, rarity: "common" },
  { model: "sugoi", label: "Dinka Sugoi", chance: 32.334, rarity: "common" },
  { model: "jugular", label: "Ocelot Jugular", chance: 2, rarity: "rare" },
  { model: "neon", label: "Pfister Neon", chance: 1, rarity: "legendary" },
];

const RARITY_STYLES: Record<
  string,
  { border: string; glow: string; badge: string; label: string }
> = {
  common: {
    border: "border-[#ff3a3a]/40",
    glow: "",
    badge: "bg-[#181216] text-[#ff8080] border border-[#ff3a3a]/30",
    label: "COMMON",
  },
  rare: {
    border: "border-[#ff3a3a]",
    glow: "",
    badge: "bg-[#ff3a3a]/20 text-[#ff4d4d] border border-[#ff3a3a]",
    label: "RARE",
  },
  legendary: {
    border: "border-[#ffd24c]",
    glow: "",
    badge: "bg-[#4a3a10] text-[#ffd24c] border border-[#ffd24c]",
    label: "LEGENDARY",
  },
};

const isBrowserPreview = () =>
  !(window as any).invokeNative && !navigator.userAgent.includes("FiveM");

const pickRandomVehicle = (pool: FreeCarOption[]) =>
  pool[Math.floor(Math.random() * pool.length)] || pool[0];

const rollWeighted = (pool: FreeCarOption[]) => {
  const total = pool.reduce((sum, v) => sum + (Number(v.chance) || 0), 0);
  if (total <= 0) return pickRandomVehicle(pool);
  let roll = Math.random() * total;
  for (const v of pool) {
    roll -= Number(v.chance) || 0;
    if (roll <= 0) return v;
  }
  return pool[pool.length - 1];
};

const fetchNui = async (eventName: string, data?: any, vehicles?: FreeCarOption[]) => {
  if (isBrowserPreview() && eventName === "cfx-keydi-freecar:spin") {
    const pool = vehicles && vehicles.length > 0 ? vehicles : DEFAULT_VEHICLES;
    const win = rollWeighted(pool);
    await new Promise((r) => setTimeout(r, 200));
    return {
      success: true,
      model: win.model,
      label: win.label,
      rarity: win.rarity || "common",
      chance: win.chance,
      plate: `DEV${Math.floor(Math.random() * 9000 + 1000)}`,
    };
  }

  const resourceName = (window as any).GetParentResourceName
    ? (window as any).GetParentResourceName()
    : "cfx-keydi-ui";

  const resp = await fetch(`https://${resourceName}/${eventName}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify(data || {}),
  });
  return await resp.json();
};

function formatChance(chance?: number) {
  if (chance === undefined || chance === null) return "";
  const num = Number(chance);
  if (Number.isNaN(num)) return "";
  if (num >= 10) return `${Math.round(num)}%`;
  if (num >= 1) return `${num.toFixed(1)}%`;
  return `${num.toFixed(2)}%`;
}

function VehicleImage({
  src,
  alt,
  model,
}: {
  src?: string;
  alt: string;
  model: string;
  category?: string;
}) {
  const [imgError, setImgError] = useState(false);

  const directUrl = useMemo(() => {
    if (src && src.trim().length > 0) return src;
    return `https://docs.fivem.net/vehicles/${model}.png`;
  }, [src, model]);

  if (imgError) {
    return (
      <div className="w-full h-full flex flex-col items-center justify-center bg-[#181216] rounded-xl border border-[#ff3a3a]/30 text-[#a08890] p-2">
        <Car className="w-10 h-10 text-[#ff4d4d] opacity-70 mb-1" />
        <span className="text-[10px] font-bold tracking-wider uppercase text-[#ff8080]">
          {model}
        </span>
      </div>
    );
  }

  return (
    <img
      src={directUrl}
      alt={alt}
      onError={() => setImgError(true)}
      className="w-full h-full object-contain filter drop-shadow-[0_4px_8px_rgba(0,0,0,0.8)]"
      loading="lazy"
    />
  );
}

export const FreeCarMenu: React.FC<FreeCarMenuProps> = ({
  visible = true,
  data,
  onClose,
}) => {
  const vehiclesList = useMemo(() => {
    if (data?.vehicles && data.vehicles.length > 0) return data.vehicles;
    return DEFAULT_VEHICLES;
  }, [data]);

  const bonusVehicle = useMemo(() => {
    if (data?.bonusVehicle) return data.bonusVehicle;
    return { model: "panto", label: "Benefactor Panto" };
  }, [data]);

  const totalChance = useMemo(() => {
    return vehiclesList.reduce((sum, v) => sum + (Number(v.chance) || 0), 0);
  }, [vehiclesList]);

  const spinDuration = data?.spinDurationMs || 6000;

  const [phase, setPhase] = useState<SpinPhase>("idle");
  const [strip, setStrip] = useState<FreeCarOption[]>([]);
  const [winner, setWinner] = useState<FreeCarOption | null>(null);
  const [offsetX, setOffsetX] = useState<number>(0);
  const [spinning, setSpinning] = useState(false);

  const trackRef = useRef<HTMLDivElement>(null);

  const handleClose = () => {
    if (spinning) return;
    if (onClose) onClose();
    else {
      const resourceName = (window as any).GetParentResourceName
        ? (window as any).GetParentResourceName()
        : "cfx-keydi-ui";
      fetch(`https://${resourceName}/cfx-keydi-freecar:close`, {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify({}),
      }).catch(() => {});
    }
  };

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && visible) {
        handleClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [visible, spinning]);

  const buildStripWithWinner = (winningVeh: FreeCarOption) => {
    const arr: FreeCarOption[] = [];
    for (let i = 0; i < STRIP_LENGTH; i++) {
      if (i === WINNER_INDEX) {
        arr.push(winningVeh);
      } else {
        arr.push(pickRandomVehicle(vehiclesList));
      }
    }
    return arr;
  };

  const handleSpin = async () => {
    if (spinning || phase !== "idle") return;
    setSpinning(true);

    try {
      const res = await fetchNui("cfx-keydi-freecar:spin", {}, vehiclesList);
      if (!res || !res.success) {
        setSpinning(false);
        return;
      }

      const winningModel = res.model;
      const matched =
        vehiclesList.find((v) => v.model === winningModel) || {
          model: winningModel,
          label: res.label || winningModel,
          rarity: res.rarity || "common",
          chance: res.chance || 1,
        };

      setWinner(matched);
      const newStrip = buildStripWithWinner(matched);
      setStrip(newStrip);

      const trackWidth = trackRef.current ? trackRef.current.clientWidth : 900;
      const centerViewport = trackWidth / 2;

      const winnerCenterOffset = WINNER_INDEX * STRIDE + ITEM_WIDTH / 2;
      const jitter = (Math.random() - 0.5) * (ITEM_WIDTH * 0.5);
      const targetOffset = -(winnerCenterOffset - centerViewport + jitter);

      setPhase("spinning");
      requestAnimationFrame(() => {
        setOffsetX(targetOffset);
      });

      setTimeout(() => {
        setPhase("landed");
        setSpinning(false);
      }, spinDuration + 300);
    } catch {
      setSpinning(false);
    }
  };

  if (!visible) return null;

  return (
    <div className="pandora fixed inset-0 z-50 flex items-center justify-center bg-black/75 backdrop-blur-[6px] p-4 font-sans select-none text-white animate-in fade-in duration-300">
      <div className="w-full max-w-[980px] bg-[#0d0d12] border-2 border-[#ff3a3a] rounded-2xl overflow-hidden shadow-2xl relative flex flex-col">

        <div className="p-6 pb-4 border-b border-[#ff3a3a]/30 relative z-10 flex items-center justify-between">
          <div className="flex items-center gap-3.5">
            <div className="w-12 h-12 rounded-xl bg-[#181216] border border-[#ff3a3a] flex items-center justify-center shrink-0">
              <img
                src={grimLogo}
                alt="Grim City Logo"
                className="w-8 h-8 object-contain"
              />
            </div>
            <div>
              <div className="text-[10px] font-black uppercase tracking-[0.2em] text-[#ff4d4d]">
                GRIM CITY ROLEPLAY • STARTER ROULETTE
              </div>
              <h1 className="text-xl font-black tracking-tight text-white flex items-center gap-2 mt-0.5">
                <Gift className="w-5 h-5 text-[#ff4d4d]" />
                {data?.title || "Claim Free Car"}
              </h1>
            </div>
          </div>

          <button
            onClick={handleClose}
            disabled={spinning}
            className="p-2.5 rounded-xl bg-[#181216] hover:bg-[#ff3a3a]/20 border border-[#ff3a3a]/40 text-white/80 hover:text-white transition-all cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        <div className="px-6 pt-5 relative z-10">
          <div className="flex flex-wrap gap-2 mb-4">
            {vehiclesList.map((veh) => {
              const style = RARITY_STYLES[veh.rarity || "common"] || RARITY_STYLES.common;
              const pct =
                totalChance > 0
                  ? formatChance(((Number(veh.chance) || 0) / totalChance) * 100)
                  : formatChance(veh.chance);
              return (
                <div
                  key={veh.model}
                  className={`flex items-center gap-2 px-3 py-1.5 rounded-xl bg-[#181216] border ${style.border}`}
                >
                  <span className={`text-[9px] font-black px-1.5 py-0.5 rounded ${style.badge}`}>
                    {style.label}
                  </span>
                  <span className="text-xs font-bold">{veh.label}</span>
                  <span className="text-[10px] text-[#a08890] font-semibold">{pct}</span>
                </div>
              );
            })}
          </div>
        </div>

        <div className="px-6 pb-2 relative z-10">
          <div
            ref={trackRef}
            className="relative h-[250px] rounded-2xl bg-[#140d11] border border-[#ff3a3a]/40 overflow-hidden"
          >
            <div className="pointer-events-none absolute inset-y-0 left-0 w-24 z-20 bg-gradient-to-r from-[#140d11] to-transparent" />
            <div className="pointer-events-none absolute inset-y-0 right-0 w-24 z-20 bg-gradient-to-l from-[#140d11] to-transparent" />

            {/* Center arrow (fixed) */}
            <div className="pointer-events-none absolute top-2 left-1/2 -translate-x-1/2 z-30 flex flex-col items-center">
              <div className="px-2.5 py-1 rounded-lg bg-[#ff3a3a] text-white text-[10px] font-black tracking-widest border border-[#ff3a3a]">
                WIN
              </div>
              <ChevronDown className="w-8 h-8 text-[#ff3a3a] -mt-1" />
            </div>
            <div className="pointer-events-none absolute inset-y-0 left-1/2 -translate-x-1/2 w-0.5 bg-[#ff3a3a] z-20" />

            <div
              className="absolute top-[52px] left-0 flex items-stretch will-change-transform"
              style={{
                gap: ITEM_GAP,
                transform: `translate3d(${offsetX}px, 0, 0)`,
                transition:
                  phase === "spinning"
                    ? `transform ${spinDuration}ms cubic-bezier(0.12, 0.75, 0.08, 1)`
                    : "none",
              }}
            >
              {(strip.length > 0 ? strip : vehiclesList.concat(vehiclesList).concat(vehiclesList)).map(
                (veh, idx) => {
                  const style = RARITY_STYLES[veh.rarity || "common"] || RARITY_STYLES.common;
                  const isWinCard = phase === "landed" && winner?.model === veh.model && idx === WINNER_INDEX;
                  return (
                    <div
                      key={`${veh.model}-${idx}`}
                      className={`shrink-0 rounded-2xl border bg-[#181216] p-3 flex flex-col items-center justify-between transition-all ${style.border} ${
                        isWinCard ? `scale-[1.04] border-[#ff3a3a] bg-[#ff3a3a]/20` : ""
                      }`}
                      style={{ width: ITEM_WIDTH, height: 180 }}
                    >
                      <div className={`text-[9px] font-black px-2 py-0.5 rounded ${style.badge}`}>
                        {style.label}
                      </div>
                      <div className="h-[100px] w-full flex items-center justify-center">
                        <VehicleImage
                          src={veh.image}
                          alt={veh.label}
                          model={veh.model}
                          category={veh.category}
                        />
                      </div>
                      <p className="text-[11px] font-black text-center leading-tight truncate w-full">
                        {veh.label}
                      </p>
                    </div>
                  );
                }
              )}
            </div>
          </div>
        </div>

        <div className="p-5 border-t border-[#ff3a3a]/30 relative z-10 flex items-center justify-between gap-3 bg-[#140d11]">
          <div className="min-w-0">
            <p className="text-[10px] font-black uppercase tracking-[0.2em] text-[#ff4d4d]">
              One-time claim • Roulette + {bonusVehicle.label}
            </p>
            <p className="text-sm font-bold truncate flex items-center gap-2 text-white">
              {phase === "landed" && winner ? (
                <>
                  <Sparkles className="w-4 h-4 text-[#ff4d4d] shrink-0" />
                  Won {winner.label} + {bonusVehicle.label} → garage
                </>
              ) : phase === "spinning" ? (
                "Spinning… good luck!"
              ) : (
                `Spin for a random car — you also get a free ${bonusVehicle.label}`
              )}
            </p>
          </div>
          <button
            onClick={handleSpin}
            disabled={spinning || phase !== "idle"}
            className="px-5 py-2.5 rounded-xl font-black text-xs uppercase tracking-wider transition-all cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed bg-gradient-to-r from-[#ff4d4d] via-[#e61e1e] to-[#b30000] border border-[#ff3a3a] text-white hover:brightness-110 flex items-center gap-2"
          >
            {spinning || phase === "spinning" ? (
              <>
                <Car className="w-4 h-4 animate-pulse" />
                Spinning...
              </>
            ) : phase === "landed" ? (
              "Claimed!"
            ) : (
              <>
                <Gift className="w-4 h-4" />
                Spin Free Car
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
};

export default FreeCarMenu;
