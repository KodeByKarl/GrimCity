import { useEffect, useRef, useState } from "react";
import { Volume2, VolumeX, X } from "lucide-react";
import { cn } from "@/lib/utils";

export interface WelcomeBannerVolumeData {
  volume?: number;
}

interface WelcomeBannerVolumeProps {
  data?: WelcomeBannerVolumeData | null;
  onClose: () => void;
}

const PRESETS = [
  { label: "Mute", value: 0 },
  { label: "Quiet", value: 0.25 },
  { label: "Low", value: 0.5 },
  { label: "Normal", value: 0.75 },
  { label: "Full", value: 1 },
];

function getResourceName() {
  return (window as Window & { GetParentResourceName?: () => string }).GetParentResourceName
    ? (window as Window & { GetParentResourceName: () => string }).GetParentResourceName()
    : "cfx-keydi-ui";
}

function clamp01(value: number) {
  if (Number.isNaN(value)) return 1;
  return Math.min(1, Math.max(0, value));
}

async function fetchNui(event: string, payload?: unknown) {
  try {
    await fetch(`https://${getResourceName()}/${event}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(payload ?? {}),
    });
  } catch {
    // NUI fetch can fail in browser preview.
  }
}

export default function WelcomeBannerVolume({ data, onClose }: WelcomeBannerVolumeProps) {
  const [volume, setVolume] = useState(() => clamp01(data?.volume ?? 1));
  const lastAudibleRef = useRef(volume > 0 ? volume : 1);

  useEffect(() => {
    const next = clamp01(data?.volume ?? 1);
    setVolume(next);
    if (next > 0) lastAudibleRef.current = next;
  }, [data]);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose]);

  const commit = (next: number) => {
    const clamped = clamp01(next);
    setVolume(clamped);
    if (clamped > 0) lastAudibleRef.current = clamped;
    fetchNui("cfx-keydi-welcomebanner:volume:set", { volume: clamped });
  };

  const muted = volume <= 0;
  const percent = Math.round(volume * 100);

  return (
    <div className="pandora fixed inset-0 z-[99950] flex items-center justify-center bg-black/55 p-6 font-sans">
      <div className="pandora-panel relative flex w-full max-w-md flex-col overflow-hidden rounded-2xl border">
        <div className="flex items-center justify-between border-b border-border/40 px-5 py-4">
          <div>
            <p className="text-[10px] font-black uppercase tracking-[0.22em] text-[#8fe4ff]">Player Setting</p>
            <h2 className="text-lg font-black text-white">Banner Volume</h2>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="flex h-8 w-8 items-center justify-center rounded-lg border border-white/10 bg-white/5 text-white/70 hover:text-white"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="space-y-5 p-5">
          <p className="text-[12px] leading-relaxed text-white/55">
            Lower this if welcome banners are too loud or startling. This only changes what you hear — other players are not affected.
          </p>

          <div className="rounded-xl border border-white/10 bg-white/5 p-4">
            <div className="mb-3 flex items-center justify-between">
              <span className="flex items-center gap-2 text-sm font-bold text-white">
                {muted ? <VolumeX className="h-4 w-4 text-white/50" /> : <Volume2 className="h-4 w-4 text-[#8fe4ff]" />}
                Your volume
              </span>
              <span className="text-sm font-black text-[#8fe4ff]">{percent}%</span>
            </div>

            <input
              type="range"
              min={0}
              max={1}
              step={0.05}
              value={volume}
              onChange={(e) => commit(Number(e.target.value))}
              className="w-full"
            />

            <button
              type="button"
              onClick={() => commit(muted ? lastAudibleRef.current || 1 : 0)}
              className={cn(
                "mt-3 w-full rounded-lg border px-3 py-2 text-xs font-bold",
                muted
                  ? "border-[#35c7f2]/35 bg-[#35c7f2]/15 text-[#8fe4ff]"
                  : "border-white/10 bg-white/5 text-white/70 hover:text-white"
              )}
            >
              {muted ? "Unmute banners" : "Mute banners"}
            </button>
          </div>

          <div className="grid grid-cols-5 gap-1.5">
            {PRESETS.map((preset) => {
              const active = Math.abs(volume - preset.value) < 0.001;
              return (
                <button
                  key={preset.label}
                  type="button"
                  onClick={() => commit(preset.value)}
                  className={cn(
                    "rounded-lg border px-1 py-2 text-[10px] font-bold",
                    active
                      ? "border-[#35c7f2]/40 bg-[#35c7f2]/15 text-[#8fe4ff]"
                      : "border-white/10 bg-white/5 text-white/60 hover:text-white"
                  )}
                >
                  {preset.label}
                </button>
              );
            })}
          </div>
        </div>

        <div className="flex shrink-0 items-center justify-center border-t border-white/10 px-5 py-2.5">
          <p className="text-[11px] font-semibold tracking-[0.18em] text-white/45">karlbykode.dev</p>
        </div>
      </div>
    </div>
  );
}
