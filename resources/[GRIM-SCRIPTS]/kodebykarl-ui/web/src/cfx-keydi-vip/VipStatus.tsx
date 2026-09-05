import { useEffect, useState } from "react";
import { CalendarClock, Crown, Image, PersonStanding, RefreshCw, ShieldOff, Timer } from "lucide-react";
import { cn } from "@/lib/utils";
import ModulePageShell from "@/cfx-keydi-modules/ModulePageShell";
import { fetchNui } from "@/lib/nui";
import { EMPTY_VIP, type VipMembership } from "./types";
import VipStaffPanel from "./VipStaffPanel";

interface VipStatusProps {
  onClose: () => void;
}

function formatDate(iso: string | null) {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function remainingLabel(days: number, hours: number) {
  if (days <= 0 && hours <= 0) return "Expired";
  if (days <= 0) return `${hours}h left`;
  if (days === 1) return hours > 0 ? `1 day ${hours}h left` : "1 day left";
  return hours > 0 ? `${days} days ${hours}h left` : `${days} days left`;
}

export default function VipStatus({ onClose }: VipStatusProps) {
  const [vip, setVip] = useState<VipMembership>(EMPTY_VIP);
  const [canManage, setCanManage] = useState(false);
  const [loading, setLoading] = useState(true);

  const load = () => {
    setLoading(true);
    fetchNui<{ vip?: VipMembership; canManage?: boolean }>("cfx-keydi-vip:getStatus", {})
      .then((res) => {
        if (res?.vip) setVip(res.vip);
        else setVip(EMPTY_VIP);
        setCanManage(!!res?.canManage);
      })
      .catch(() => {
        setVip(EMPTY_VIP);
        setCanManage(false);
      })
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    load();
  }, []);

  const urgency =
    !vip.active ? "none" : vip.daysRemaining <= 3 ? "critical" : vip.daysRemaining <= 7 ? "warn" : "ok";

  return (
    <ModulePageShell
      title="VIP Status"
      eyebrow="VIP MEMBERSHIP"
      subtitle="Active plan, days left until renewal, and revoke date."
      sidebarHint={
        canManage
          ? "View your plan, or Set / Edit VIP for online players."
          : "Track your VIP tier and when access ends."
      }
      onClose={onClose}
    >
      <div className="flex flex-1 flex-col justify-between overflow-hidden">
        <div className="mb-2 flex-1 space-y-3 overflow-y-auto pr-2 custom-scrollbar">
          <div className="flex items-center justify-between rounded-xl border border-[#ff3a3a]/40 bg-[#ff3a3a]/10 p-3.5">
            <div className="flex items-center gap-3">
              <Crown className="h-5 w-5 shrink-0 text-[#ff4d4d]" />
              <div className="flex flex-col text-left">
                <span className="text-[11px] font-bold text-white">Your VIP Plan</span>
                <span className="mt-0.5 text-[9.5px] text-[#a08890]">
                  Linked to Multicharacter · Ped Menu · Welcome Banner
                </span>
              </div>
            </div>
            <button
              type="button"
              onClick={load}
              disabled={loading}
              className="flex cursor-pointer items-center gap-1.5 rounded-lg border border-white/10 bg-black/40 px-2.5 py-1 text-[9.5px] font-black uppercase tracking-wider text-white transition hover:border-white/30"
            >
              <RefreshCw className={cn("h-3 w-3", loading && "animate-spin")} />
              Refresh
            </button>
          </div>

          {loading ? (
            <div className="py-10 text-center text-xs text-[#a08890]">Loading VIP status...</div>
          ) : !vip.active ? (
            <div className="rounded-xl border border-white/10 bg-[#181216] p-6 text-center">
              <ShieldOff className="mx-auto mb-2 h-8 w-8 text-[#a08890]" />
              <p className="text-sm font-black uppercase tracking-wider text-white">No Active VIP</p>
              <p className="mt-1 text-[11px] text-[#a08890]">
                You are not on a VIP plan. Contact store / staff to purchase or renew.
              </p>
            </div>
          ) : (
            <>
              <div
                className={cn(
                  "rounded-xl border p-4 bg-[#181216]",
                  urgency === "critical"
                    ? "border-red-500/50"
                    : urgency === "warn"
                      ? "border-amber-500/40"
                      : "border-[#ff3a3a]/40"
                )}
              >
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="text-[9px] font-bold uppercase tracking-[0.18em] text-[#a08890]">
                      Active VIP
                    </p>
                    <p className="mt-1 text-2xl font-black uppercase tracking-wide text-white">
                      {vip.label}
                    </p>
                    <p className="mt-1 text-[10px] font-semibold uppercase tracking-wider text-[#ff8080]">
                      Tier · {vip.tier.toUpperCase()}
                      {vip.autoRenew ? " · Auto-renew ON" : " · Auto-renew OFF"}
                    </p>
                  </div>
                  <span
                    className={cn(
                      "rounded-lg border px-2.5 py-1 text-[10px] font-black uppercase tracking-wider",
                      urgency === "critical"
                        ? "border-red-500 bg-red-500/20 text-red-300"
                        : urgency === "warn"
                          ? "border-amber-500/50 bg-amber-500/15 text-amber-300"
                          : "border-emerald-500/40 bg-emerald-500/15 text-emerald-400"
                    )}
                  >
                    Active
                  </span>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <div className="rounded-xl border border-[#ff3a3a]/30 bg-[#181216] px-3 py-3">
                  <div className="mb-1.5 flex items-center gap-1.5">
                    <Timer className="h-3.5 w-3.5 text-[#ff4d4d]" />
                    <span className="text-[9px] font-bold uppercase tracking-wider text-[#a08890]">
                      Before Renewal
                    </span>
                  </div>
                  <p className="text-[18px] font-black text-white">
                    {remainingLabel(vip.daysRemaining, vip.hoursRemaining)}
                  </p>
                  <p className="mt-1 text-[9.5px] text-[#a08890]">
                    Renews {formatDate(vip.renewsAt)}
                  </p>
                </div>
                <div className="rounded-xl border border-[#ff3a3a]/30 bg-[#181216] px-3 py-3">
                  <div className="mb-1.5 flex items-center gap-1.5">
                    <CalendarClock className="h-3.5 w-3.5 text-[#ff4d4d]" />
                    <span className="text-[9px] font-bold uppercase tracking-wider text-[#a08890]">
                      Revoke Date
                    </span>
                  </div>
                  <p className="text-[15px] font-black leading-snug text-white">
                    {formatDate(vip.expiresAt)}
                  </p>
                  <p className="mt-1 text-[9.5px] text-[#a08890]">
                    VIP access ends if not renewed
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <button
                  type="button"
                  disabled={!vip.pedMenu}
                  onClick={() => fetchNui("cfx-keydi-vip:openPedMenu", {})}
                  className={cn(
                    "flex items-center gap-2 rounded-xl border px-3 py-3 text-left transition",
                    vip.pedMenu
                      ? "cursor-pointer border-[#ff3a3a]/40 bg-[#181216] hover:border-[#ff3a3a]"
                      : "cursor-not-allowed border-white/10 bg-[#121214] opacity-45"
                  )}
                >
                  <PersonStanding className="h-4 w-4 shrink-0 text-[#ff4d4d]" />
                  <div>
                    <p className="text-[11px] font-black uppercase text-white">Ped Menu</p>
                    <p className="text-[9px] text-[#a08890]">
                      {vip.pedMenu ? "VIP 2+ · /pedmenu" : "Requires VIP 2+"}
                    </p>
                  </div>
                </button>
                <button
                  type="button"
                  disabled={!vip.welcomeBanner}
                  onClick={() => fetchNui("cfx-keydi-vip:openWelcomeBanner", {})}
                  className={cn(
                    "flex items-center gap-2 rounded-xl border px-3 py-3 text-left transition",
                    vip.welcomeBanner
                      ? "cursor-pointer border-[#ff3a3a]/40 bg-[#181216] hover:border-[#ff3a3a]"
                      : "cursor-not-allowed border-white/10 bg-[#121214] opacity-45"
                  )}
                >
                  <Image className="h-4 w-4 shrink-0 text-[#ff4d4d]" />
                  <div>
                    <p className="text-[11px] font-black uppercase text-white">Welcome Banner</p>
                    <p className="text-[9px] text-[#a08890]">
                      {vip.welcomeBanner ? "Edit yours · /wcb" : "Not included"}
                    </p>
                  </div>
                </button>
              </div>

              {typeof vip.characterSlots === "number" && (
                <div className="rounded-xl border border-white/10 bg-[#181216] px-3 py-2.5 text-[11px] text-white/85">
                  <span className="font-black text-[#ff4d4d]">MultiVIP</span>
                  <span className="text-[#a08890]"> · </span>
                  Character slots: <span className="font-black">{vip.characterSlots}</span>
                  <span className="text-[#a08890]"> (synced with multicharacter)</span>
                </div>
              )}

              {vip.perks.length > 0 && (
                <div className="rounded-xl border border-white/10 bg-[#181216] p-3.5">
                  <p className="mb-2 text-[9px] font-black uppercase tracking-[0.18em] text-[#ff4d4d]">
                    Included Perks
                  </p>
                  <ul className="space-y-1.5">
                    {vip.perks.map((perk) => (
                      <li key={perk} className="flex items-center gap-2 text-[11px] text-[#a08890]">
                        <span className="h-1.5 w-1.5 shrink-0 rounded-full bg-[#ff3a3a]" />
                        {perk}
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </>
          )}

          {canManage && <VipStaffPanel onOwnStatusChanged={load} />}
        </div>

        <div className="mt-2 flex justify-end border-t border-[#ff3a3a]/25 pt-3.5">
          <button
            type="button"
            onClick={onClose}
            className="cursor-pointer rounded-xl border border-[#ff3a3a] bg-[#ff3a3a] px-4 py-2 text-xs font-black uppercase tracking-wider text-white transition hover:brightness-110"
          >
            Return to Modules
          </button>
        </div>
      </div>
    </ModulePageShell>
  );
}
