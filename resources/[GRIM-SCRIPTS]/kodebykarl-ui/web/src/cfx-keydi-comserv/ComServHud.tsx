import { useEffect, useState } from "react";
import { HardHat, CheckCircle2 } from "lucide-react";
import { cn } from "@/lib/utils";

interface ComServData {
  remaining: number;
  total: number;
  reason: string;
  brand?: string;
}

const DEFAULT_DATA: ComServData = {
  remaining: 0,
  total: 0,
  reason: "",
  brand: "PANDORA CITY",
};

export default function ComServHud() {
  const [visible, setVisible] = useState(false);
  const [data, setData] = useState<ComServData>(DEFAULT_DATA);
  const [completedFlash, setCompletedFlash] = useState(false);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const msg = event.data;
      if (!msg) return;

      if (msg.action === "cfx-keydi-comserv:show") {
        if (msg.data) setData({ ...DEFAULT_DATA, ...msg.data });
        setCompletedFlash(false);
        setVisible(true);
      } else if (msg.action === "cfx-keydi-comserv:update") {
        if (msg.data) {
          setData((prev) => ({ ...prev, ...msg.data }));
          if (typeof msg.data.remaining === "number" && msg.data.remaining <= 0) {
            setCompletedFlash(true);
          }
        }
      } else if (msg.action === "cfx-keydi-comserv:hide") {
        setVisible(false);
        setCompletedFlash(false);
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  if (!visible) return null;

  const total = Math.max(data.total, 1);
  const done = Math.max(0, total - data.remaining);
  const progress = Math.min(100, Math.round((done / total) * 100));

  return (
    <div className="pandora fixed right-6 top-[42%] -translate-y-1/2 z-[99990] w-[280px] select-none pointer-events-none font-sans">
      <div
        className={cn(
          "relative overflow-hidden rounded-2xl border shadow-[0_25px_60px_-15px_rgba(0,0,0,0.85)]",
          completedFlash ? "border-emerald-400/40" : "border-[rgba(143,228,255,0.22)]"
        )}
        style={{
          background: "linear-gradient(180deg, rgba(10, 40, 70, 0.96) 0%, rgba(5, 25, 47, 0.98) 100%)",
        }}
      >
        <div className="panel-grid pointer-events-none absolute inset-0 opacity-40" />

        <div
          className="relative flex items-center gap-2.5 px-3.5 py-2.5"
          style={{
            background:
              "linear-gradient(135deg, rgba(53,199,242,0.35) 0%, rgba(28,111,168,0.55) 55%, rgba(11,44,78,0.6) 100%)",
            borderBottom: "1px solid rgba(255, 210, 76, 0.35)",
          }}
        >
          <div className="flex h-7 w-7 items-center justify-center rounded-lg border border-white/25 bg-white/12">
            {completedFlash ? (
              <CheckCircle2 className="h-3.5 w-3.5 text-emerald-300" />
            ) : (
              <HardHat className="h-3.5 w-3.5 text-white" />
            )}
          </div>
          <div className="flex flex-col min-w-0">
            <span className="text-[10px] font-black uppercase tracking-[0.18em] text-white/90">
              Community Service
            </span>
            <span className="text-[9px] font-bold uppercase tracking-wider text-[#ffd24c]/80 truncate">
              {data.brand || "PANDORA CITY"}
            </span>
          </div>
        </div>

        <div className="relative px-3.5 py-3 space-y-3">
          <div className="flex items-end justify-between gap-2">
            <div>
              <p className="text-[9px] font-bold uppercase tracking-wider text-white/45">Remaining</p>
              <p className="text-2xl font-black tabular-nums text-white leading-none mt-0.5">
                {data.remaining}
                <span className="text-sm font-bold text-white/40"> / {data.total}</span>
              </p>
            </div>
            <div className="text-right">
              <p className="text-[9px] font-bold uppercase tracking-wider text-white/45">Progress</p>
              <p className="text-lg font-black tabular-nums text-[#8fe4ff] leading-none mt-0.5">{progress}%</p>
            </div>
          </div>

          <div className="h-1.5 w-full rounded-full bg-white/10 overflow-hidden">
            <div
              className="h-full rounded-full transition-all duration-500"
              style={{
                width: `${progress}%`,
                background: completedFlash
                  ? "linear-gradient(90deg, #34d399, #6ee7b7)"
                  : "linear-gradient(90deg, #35c7f2, #ffd24c)",
              }}
            />
          </div>

          {data.reason ? (
            <div className="rounded-lg border border-white/10 bg-white/5 px-2.5 py-2">
              <p className="text-[8px] font-black uppercase tracking-wider text-white/40 mb-0.5">Reason</p>
              <p className="text-[11px] font-semibold text-white/85 leading-snug line-clamp-2">{data.reason}</p>
            </div>
          ) : null}

          <p className="text-[9px] font-medium text-white/40 text-center">
            Complete marked tasks in the service zone
          </p>
        </div>
      </div>
    </div>
  );
}
