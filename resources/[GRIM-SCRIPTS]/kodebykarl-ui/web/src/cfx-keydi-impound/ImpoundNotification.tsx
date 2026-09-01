import React, { useEffect, useState } from "react";
import { Car } from "lucide-react";
import { cn } from "@/lib/utils";

export default function ImpoundNotification() {
  const [visible, setVisible] = useState(false);
  const [secondsLeft, setSecondsLeft] = useState(120);
  const [status, setStatus] = useState<"countdown" | "completed">("countdown");

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const msg = event.data;
      if (!msg) return;

      if (msg.action === "cfx-keydi-impound:show") {
        setSecondsLeft(msg.duration || 120);
        setStatus("countdown");
        setVisible(true);
      } else if (msg.action === "cfx-keydi-impound:completed") {
        setStatus("completed");
        setTimeout(() => {
          setVisible(false);
        }, 5000); // Hide after 5 seconds
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  // Countdown timer thread
  useEffect(() => {
    if (!visible || status !== "countdown" || secondsLeft <= 0) return;

    const timer = setInterval(() => {
      setSecondsLeft((prev) => prev - 1);
    }, 1000);

    return () => clearInterval(timer);
  }, [visible, status, secondsLeft]);

  const formatTime = (totalSeconds: number) => {
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    const padMin = String(minutes).padStart(2, "0");
    const padSec = String(seconds).padStart(2, "0");
    return `${padMin}:${padSec}`;
  };

  if (!visible) return null;

  return (
    <div
      className={cn(
        "pandora fixed bottom-5 left-1/2 -translate-x-1/2 w-[350px] h-[60px] border rounded-xl shadow-[0_6px_24px_rgba(0,0,0,0.85)] flex items-center justify-between px-4 py-2 select-none pointer-events-none z-50 animate-scale-up",
        status === "completed" ? "border-emerald-500/20 shadow-[0_0_15px_rgba(16,185,129,0.12)]" : "border-[#ff7ab5]/25"
      )}
      style={{
        background: "linear-gradient(180deg, rgba(10, 40, 70, 0.96) 0%, rgba(5, 25, 47, 0.98) 100%)",
      }}
    >
      <div className="flex items-center gap-3">
        {/* Icon Circle */}
        <div
          className={cn(
            "w-9 h-9 rounded-lg flex items-center justify-center border transition-colors duration-300",
            status === "completed"
              ? "bg-emerald-500/10 border-emerald-500/30 text-emerald-400"
              : "bg-white/5 border-white/10 text-white/90"
          )}
        >
          <Car className="h-4.5 w-4.5" />
        </div>

        {/* Text Area */}
        <div className="flex flex-col text-left">
          <span
            className={cn(
              "text-[7.5px] font-black uppercase tracking-wider transition-colors duration-300",
              status === "completed" ? "text-emerald-400" : "text-[#ff5fa8]"
            )}
          >
            MASS IMPOUND
          </span>
          <span className="text-[12px] font-extrabold text-white mt-0.5 leading-tight">
            {status === "countdown" ? "Global Mass Impound" : "Impound Completed"}
          </span>
          <span className="text-[9px] text-muted-foreground/60 mt-0.5 leading-none">
            {status === "countdown" ? "Vehicles will be impounded" : "All unoccupied cars cleaned"}
          </span>
        </div>
      </div>

      {/* Countdown Timer Display */}
      <div className="flex items-center">
        {status === "countdown" ? (
          <span className="text-xl font-black text-white/85 tracking-tight font-mono">
            {formatTime(secondsLeft)}
          </span>
        ) : (
          <span className="text-[10px] font-black uppercase tracking-wider text-emerald-400 bg-emerald-500/15 border border-emerald-500/35 px-2 py-0.5 rounded animate-pulse">
            Success
          </span>
        )}
      </div>
    </div>
  );
}
