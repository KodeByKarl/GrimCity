import React from "react";
import { ArrowDownLeft, ArrowUpRight, Building2, Wallet } from "lucide-react";
import { AppChrome, formatMoney, type PhonePlayerData } from "./shared";

export default function WalletApp({ player }: { player?: PhonePlayerData | null }) {
  const bank = player?.bank ?? 0;
  const cash = player?.cash ?? 0;
  const total = bank + cash;
  const name = [player?.firstName, player?.lastName].filter(Boolean).join(" ") || "Citizen";

  return (
    <AppChrome title="Wallet" dark>
      <div className="flex min-h-full flex-col gap-3 bg-gradient-to-b from-[#0c0e14] via-[#12141c] to-[#0a0c12] px-4 pb-12 pt-1">
        {/* Hero total */}
        <div className="relative overflow-hidden rounded-[22px] border border-[#f5c542]/25 bg-gradient-to-br from-[#1a160c] via-[#141720] to-[#0c0e14] p-4 shadow-[0_12px_40px_rgba(0,0,0,0.45)]">
          <div className="pointer-events-none absolute -right-8 -top-10 h-28 w-28 rounded-full bg-[#f5c542]/15 blur-2xl" />
          <p className="text-[10px] font-black uppercase tracking-[0.2em] text-[#f5c542]">
            Total balance
          </p>
          <p className="mt-1.5 text-[30px] font-black tracking-tight tabular-nums text-[#f8f3e8]">
            {formatMoney(total)}
          </p>
          <p className="mt-1 truncate text-[11px] text-[#9a9386]">{name}</p>
        </div>

        {/* Bank + Cash split */}
        <div className="grid grid-cols-1 gap-2.5">
          <div className="rounded-[18px] border border-white/8 bg-[#141720] p-3.5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="flex h-8 w-8 items-center justify-center rounded-full bg-[#f5c542]/12 text-[#f5c542]">
                  <Building2 className="h-3.5 w-3.5" />
                </div>
                <div>
                  <p className="text-[10px] font-black uppercase tracking-[0.14em] text-[#9a9386]">
                    Bank
                  </p>
                  <p className="text-[18px] font-black tabular-nums text-white">
                    {formatMoney(bank)}
                  </p>
                </div>
              </div>
              <ArrowDownLeft className="h-4 w-4 text-[#30d158]" />
            </div>
          </div>

          <div className="rounded-[18px] border border-white/8 bg-[#141720] p-3.5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="flex h-8 w-8 items-center justify-center rounded-full bg-white/8 text-[#f8f3e8]">
                  <Wallet className="h-3.5 w-3.5" />
                </div>
                <div>
                  <p className="text-[10px] font-black uppercase tracking-[0.14em] text-[#9a9386]">
                    Cash
                  </p>
                  <p className="text-[18px] font-black tabular-nums text-white">
                    {formatMoney(cash)}
                  </p>
                </div>
              </div>
              <ArrowUpRight className="h-4 w-4 text-[#f5c542]" />
            </div>
          </div>
        </div>

        <div className="rounded-[16px] border border-[#f5c542]/15 bg-[#f5c542]/8 px-3.5 py-3">
          <p className="text-[11px] leading-relaxed text-[#c9b896]">
            Sell orange, wood, and raw meat at the Market NPC. Choose cash or bank payout.
          </p>
        </div>
      </div>
    </AppChrome>
  );
}
