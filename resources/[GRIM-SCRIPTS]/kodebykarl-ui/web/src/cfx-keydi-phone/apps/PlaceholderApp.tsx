import React from "react";
import type { LucideIcon } from "lucide-react";
import { AppChrome, type PhonePlayerData } from "./shared";

export default function PlaceholderApp({
  title,
  icon: Icon,
  color,
  message,
  player,
}: {
  title: string;
  icon: LucideIcon;
  color: string;
  message: string;
  player?: PhonePlayerData | null;
}) {
  const name = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Citizen";

  return (
    <AppChrome title={title}>
      <div className="flex h-full flex-col items-center justify-center gap-4 px-8 pb-8 text-center">
        <div
          className="flex h-20 w-20 items-center justify-center rounded-[22px] text-white shadow-lg"
          style={{ backgroundColor: color }}
        >
          <Icon className="h-10 w-10" strokeWidth={1.6} />
        </div>
        <div>
          <h2 className="text-[22px] font-semibold text-[#1c1c1e]">{title}</h2>
          <p className="mt-2 max-w-[260px] text-[14px] leading-relaxed text-[#8e8e93]">{message}</p>
        </div>
        {title === "Settings" && (
          <div className="mt-2 w-full max-w-[280px] rounded-2xl bg-white p-4 text-left shadow-sm">
            <p className="text-[12px] text-[#8e8e93]">Signed in</p>
            <p className="text-[16px] font-semibold text-[#1c1c1e]">{name}</p>
            <p className="mt-2 text-[13px] text-[#8e8e93]">Job · {player?.job || "Unemployed"}</p>
            <p className="mt-3 text-[12px] leading-relaxed text-[#8e8e93]">
              Esc / home bar: app → home → lock → close
            </p>
          </div>
        )}
      </div>
    </AppChrome>
  );
}
