import { useEffect, useState } from "react";
import { Pickaxe, Package, Weight, Zap, Gem } from "lucide-react";
import { cn } from "@/lib/utils";

type FarmStatus = "idle" | "farming" | "full";

interface AutofarmData {
  status: FarmStatus;
  label: string;
  image?: string;
  itemWeight: number;
  collected: number;
  weight: number;
  maxWeight: number;
  progress: number;
}

const DEFAULT_DATA: AutofarmData = {
  status: "idle",
  label: "Bandage",
  image: "",
  itemWeight: 0,
  collected: 0,
  weight: 0,
  maxWeight: 30000,
  progress: 0,
};

const STATUS_META: Record<FarmStatus, { label: string; dot: string; color: string }> = {
  idle: { label: "Standby", dot: "#ffd24c", color: "#ffd24c" },
  farming: { label: "Farming", dot: "#35c7f2", color: "#8fe4ff" },
  full: { label: "Full", dot: "#ff3d96", color: "#ffa6ce" },
};

const RING_RADIUS = 46;
const RING_CIRCUMFERENCE = 2 * Math.PI * RING_RADIUS;

function formatWeight(grams: number) {
  if (grams >= 1000) {
    return `${(grams / 1000).toLocaleString(undefined, { maximumFractionDigits: 2 })}kg`;
  }

  return `${grams.toLocaleString()}g`;
}

export default function AutofarmHud() {
  const [visible, setVisible] = useState(false);
  const [data, setData] = useState<AutofarmData>(DEFAULT_DATA);
  const [imageFailed, setImageFailed] = useState(false);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const msg = event.data;
      if (!msg) return;

      if (msg.action === "cfx-keydi-autofarm:show") {
        if (msg.data) setData({ ...DEFAULT_DATA, ...msg.data });
        setImageFailed(false);
        setVisible(true);
      } else if (msg.action === "cfx-keydi-autofarm:update") {
        if (msg.data) setData((prev) => ({ ...prev, ...msg.data }));
      } else if (msg.action === "cfx-keydi-autofarm:hide") {
        setVisible(false);
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  useEffect(() => {
    setImageFailed(false);
  }, [data.image]);

  if (!visible) return null;

  const status = STATUS_META[data.status] ?? STATUS_META.idle;
  const weightPercent = data.maxWeight > 0 ? Math.min((data.weight / data.maxWeight) * 100, 100) : 0;
  const cycleOffset = RING_CIRCUMFERENCE * (1 - Math.min(Math.max(data.progress, 0), 1));

  return (
    <div className="pandora fixed left-6 top-[58%] -translate-y-1/2 z-[99990] w-[272px] select-none pointer-events-none animate-autofarm-in font-sans">
      <div
        className="pandora-hero relative overflow-hidden rounded-2xl border shadow-[0_25px_60px_-15px_rgba(0,0,0,0.85)]"
        style={{ borderColor: "rgba(143, 228, 255, 0.22)" }}
      >
        <div className="panel-grid pointer-events-none absolute inset-0 opacity-50" />
        <div className="pandora-waves pointer-events-none absolute inset-x-0 bottom-0 h-24" />

        {/* Header */}
        <div
          className="relative flex items-center gap-2.5 px-3.5 py-2.5"
          style={{
            background: "linear-gradient(135deg, rgba(53,199,242,0.35) 0%, rgba(28,111,168,0.55) 55%, rgba(11,44,78,0.6) 100%)",
            borderBottom: "1px solid rgba(255, 210, 76, 0.35)",
          }}
        >
          <div className="flex h-7 w-7 items-center justify-center rounded-lg border border-white/25 bg-white/12">
            <Pickaxe className="h-3.5 w-3.5 text-white" />
          </div>
          <div className="leading-none">
            <p className="pandora-display text-[13px] font-black tracking-[0.14em] text-white">AUTO FARM</p>
            <p
              className="mt-1 text-[8px] font-bold uppercase tracking-[0.22em]"
              style={{ color: "var(--pandora-sun)" }}
            >
              Pandora City
            </p>
          </div>
          <div className="ml-auto flex items-center gap-1.5 rounded-full border border-white/20 bg-black/30 px-2 py-1">
            <span
              className={cn("h-1.5 w-1.5 rounded-full", data.status === "farming" && "animate-pulse")}
              style={{ background: status.dot }}
            />
            <span className="text-[8px] font-black uppercase tracking-wider" style={{ color: status.color }}>
              {status.label}
            </span>
          </div>
        </div>

        <div className="relative px-3.5 pb-3.5 pt-3">
          {/* Resource chip */}
          <div
            className="mb-3 flex flex-col items-center rounded-lg border py-1.5"
            style={{ background: "rgba(11, 44, 78, 0.45)", borderColor: "rgba(53, 199, 242, 0.22)" }}
          >
            <span className="pandora-title text-[13px] font-black uppercase tracking-[0.18em]">{data.label}</span>
            <span className="mt-0.5 text-[7px] font-bold uppercase tracking-[0.2em] text-white/50">
              {formatWeight(data.itemWeight)} per item
            </span>
          </div>

          {/* Item preview with cycle progress ring */}
          <div
            className="relative mb-3 flex items-center justify-center rounded-xl border py-3.5"
            style={{ background: "rgba(11, 44, 78, 0.4)", borderColor: "rgba(53, 199, 242, 0.2)" }}
          >
            <div className="relative h-[112px] w-[112px]">
              <svg className="absolute inset-0 -rotate-90" viewBox="0 0 116 116">
                <circle cx="58" cy="58" r={RING_RADIUS} fill="none" stroke="rgba(143, 228, 255, 0.18)" strokeWidth="4" />
                <circle
                  cx="58"
                  cy="58"
                  r={RING_RADIUS}
                  fill="none"
                  stroke="var(--pandora-pink)"
                  strokeWidth="4"
                  strokeLinecap="round"
                  strokeDasharray={RING_CIRCUMFERENCE}
                  strokeDashoffset={cycleOffset}
                  style={{ transition: "stroke-dashoffset 120ms linear" }}
                />
              </svg>

              <div
                className="absolute inset-[14px] flex items-center justify-center rounded-full border"
                style={{
                  background: "radial-gradient(circle at 50% 32%, rgba(53,199,242,0.25), rgba(11,44,78,0.9))",
                  borderColor:
                    data.status === "farming" ? "rgba(255, 61, 150, 0.5)" : "rgba(53, 199, 242, 0.28)",
                }}
              >
                {data.image && !imageFailed ? (
                  <img
                    src={data.image}
                    alt={data.label}
                    onError={() => setImageFailed(true)}
                    className="h-14 w-14 object-contain drop-shadow-[0_6px_14px_rgba(0,0,0,0.6)]"
                  />
                ) : (
                  <Gem
                    className="h-11 w-11 drop-shadow-[0_6px_14px_rgba(0,0,0,0.6)]"
                    style={{ color: "#8fe4ff" }}
                  />
                )}
              </div>
            </div>
          </div>

          {/* Stats */}
          <div className="mb-2.5 grid grid-cols-2 gap-2">
            <div
              className="flex items-center gap-2 rounded-lg border px-2.5 py-2"
              style={{ background: "rgba(11, 44, 78, 0.4)", borderColor: "rgba(53, 199, 242, 0.2)" }}
            >
              <Package className="h-3.5 w-3.5 shrink-0" style={{ color: "#8fe4ff" }} />
              <div className="min-w-0 leading-none">
                <p className="text-[7.5px] font-black uppercase tracking-wider text-white/50">Collected</p>
                <p className="mt-1 text-[12px] font-black text-white">{data.collected}</p>
              </div>
            </div>
            <div
              className="flex items-center gap-2 rounded-lg border px-2.5 py-2"
              style={{ background: "rgba(11, 44, 78, 0.4)", borderColor: "rgba(53, 199, 242, 0.2)" }}
            >
              <Weight className="h-3.5 w-3.5 shrink-0" style={{ color: "#ffa6ce" }} />
              <div className="min-w-0 leading-none">
                <p className="text-[7.5px] font-black uppercase tracking-wider text-white/50">Load</p>
                <p className="mt-1 text-[12px] font-black text-white">{Math.round(weightPercent)}%</p>
              </div>
            </div>
          </div>

          {/* Weight bar */}
          <div
            className="rounded-lg border px-2.5 py-2"
            style={{ background: "rgba(11, 44, 78, 0.4)", borderColor: "rgba(53, 199, 242, 0.2)" }}
          >
            <div className="flex items-center justify-between text-[8.5px] font-bold uppercase tracking-wider">
              <span className="text-white/50">Capacity</span>
              <span className="text-white/85">
                {formatWeight(data.weight)} / {formatWeight(data.maxWeight)}
              </span>
            </div>
            <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-black/30">
              <div
                className="h-full rounded-full transition-[width] duration-200"
                style={{
                  width: `${weightPercent}%`,
                  background:
                    weightPercent >= 100
                      ? "linear-gradient(90deg, #ff3d96, #d3106f)"
                      : "linear-gradient(90deg, #35c7f2, #ff5fa8)",
                }}
              />
            </div>
          </div>

          {/* Key hints */}
          <div className="mt-3 flex items-center gap-2">
            <div
              className={cn(
                "flex flex-1 items-center justify-center gap-1.5 rounded-lg border px-2 py-1.5",
                data.status === "full" && "opacity-45"
              )}
              style={{
                background:
                  data.status === "full"
                    ? "rgba(11, 44, 78, 0.55)"
                    : "linear-gradient(135deg, #ff5fa8 0%, #ff3d96 45%, #d3106f 100%)",
                borderColor: data.status === "full" ? "rgba(255, 255, 255, 0.12)" : "rgba(255, 210, 76, 0.5)",
              }}
            >
              <kbd className="rounded bg-black/35 px-1.5 py-0.5 text-[9px] font-black text-white">E</kbd>
              <span className="text-[9px] font-black uppercase tracking-wider text-white">
                {data.status === "farming" ? "Pause" : "Start"}
              </span>
            </div>
            <div
              className="flex flex-1 items-center justify-center gap-1.5 rounded-lg border px-2 py-1.5"
              style={{
                background: "rgba(53, 199, 242, 0.14)",
                borderColor: "rgba(53, 199, 242, 0.4)",
              }}
            >
              <kbd className="rounded bg-black/35 px-1.5 py-0.5 text-[9px] font-black text-white">X</kbd>
              <span
                className="text-[9px] font-black uppercase tracking-wider"
                style={{ color: "#8fe4ff" }}
              >
                Cancel
              </span>
            </div>
          </div>

          {data.status === "farming" && (
            <div className="mt-2.5 space-y-1.5">
              <div className="flex items-center justify-between text-[8.5px] font-bold uppercase tracking-wider">
                <span className="flex items-center gap-1.5" style={{ color: "#ffd24c" }}>
                  <Zap className="h-3 w-3" />
                  Gathering
                </span>
                <span className="font-mono" style={{ color: "#8fe4ff" }}>
                  {Math.round(Math.min(Math.max(data.progress, 0), 1) * 100)}%
                </span>
              </div>
              <div className="h-2 w-full overflow-hidden rounded-full bg-black/35 border border-white/10">
                <div
                  className="h-full rounded-full transition-[width] duration-100 ease-linear"
                  style={{
                    width: `${Math.min(Math.max(data.progress, 0), 1) * 100}%`,
                    background: "linear-gradient(90deg, #10b981, #ff3d96, #35c7f2)",
                    boxShadow: "0 0 12px rgba(16,185,129,0.55)",
                  }}
                />
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
