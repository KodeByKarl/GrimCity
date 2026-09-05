import { useCallback, useEffect, useState } from "react";
import {
  Briefcase,
  CheckCircle2,
  HelpCircle,
  Info,
  Lock,
  LogOut,
  RefreshCw,
  Server,
  ShieldCheck,
  Users,
} from "lucide-react";
import { cn } from "@/lib/utils";
import ModulePageShell from "@/cfx-keydi-modules/ModulePageShell";
import { fetchNui, isBrowserEnv } from "@/lib/nui";

type ServerTab = "public" | "jobs" | "faq";

export interface ServerRealm {
  id: string;
  name: string;
  tag: string;
  description: string;
  onlinePlayers: number;
  maxPlayers: number;
  ping: string;
  cfxUrl?: string;
  ip?: string;
  status: "ONLINE" | "FULL" | "WHITELIST" | string;
  isCurrent?: boolean;
  functions?: string[];
  type?: string;
}

export interface SideJobServer {
  id: string;
  name: string;
  tag: string;
  description: string;
  onlinePlayers: number;
  maxPlayers: number;
  isCurrent?: boolean;
  functions?: string[];
}

const DEFAULT_PUBLIC_SERVERS: ServerRealm[] = [
  {
    id: "region1",
    name: "Region 1 · All Farm",
    tag: "FARM REALM",
    description: "All farms available here — autofarm, hunting, weed, and orange picking.",
    onlinePlayers: 0,
    maxPlayers: 0,
    ping: "16 ms",
    status: "ONLINE",
    functions: ["grind", "autofarm", "raven", "weedfarm", "job_orange"],
  },
  {
    id: "region2",
    name: "Region 2 · School",
    tag: "SCHOOL REALM",
    description: "School / city RP. Jobs, housing, and social roleplay.",
    onlinePlayers: 0,
    maxPlayers: 0,
    ping: "16 ms",
    status: "ONLINE",
    isCurrent: true,
    functions: ["main", "jobs", "housing", "school"],
  },
  {
    id: "region3",
    name: "Region 3 · Turf War",
    tag: "TURF REALM",
    description: "Turf War instance. Gang wars only work here and on Region 4.",
    onlinePlayers: 0,
    maxPlayers: 0,
    ping: "18 ms",
    status: "ONLINE",
    functions: ["turfwar"],
  },
  {
    id: "region4",
    name: "Region 4 · Turf War",
    tag: "TURF REALM",
    description: "Second Turf War instance. Isolated from Region 3 players.",
    onlinePlayers: 0,
    maxPlayers: 0,
    ping: "18 ms",
    status: "ONLINE",
    functions: ["turfwar"],
  },
];

const DEFAULT_JOB_SERVERS: SideJobServer[] = [
  {
    id: "job_orange",
    name: "Orange Picking Instance",
    tag: "ORANGE JOB",
    maxPlayers: 30,
    onlinePlayers: 0,
    description: "Pick oranges in a dedicated orchard instance.",
  },
];

interface RegionsProps {
  onClose: () => void;
}

export default function Regions({ onClose }: RegionsProps) {
  const [serverSubTab, setServerSubTab] = useState<ServerTab>("public");
  const [publicServers, setPublicServers] = useState<ServerRealm[]>(DEFAULT_PUBLIC_SERVERS);
  const [jobServers, setJobServers] = useState<SideJobServer[]>(DEFAULT_JOB_SERVERS);
  const [inSafezone, setInSafezone] = useState(true);
  const [isLocked, setIsLocked] = useState(false);
  const [lockReason, setLockReason] = useState<string | null>(null);
  const [loadingServers, setLoadingServers] = useState(false);
  const [switchingServer, setSwitchingServer] = useState<string | null>(null);

  const loadServerRealms = useCallback(() => {
    setLoadingServers(true);
    fetchNui<{
      publicServers?: ServerRealm[];
      sideJobServers?: SideJobServer[];
      inSafezone?: boolean;
      isLocked?: boolean;
      lockReason?: string;
    }>("cfx-keydi-modules:getServers", {})
      .then((res) => {
        if (res) {
          if (res.publicServers && res.publicServers.length > 0) setPublicServers(res.publicServers);
          if (res.sideJobServers && res.sideJobServers.length > 0) setJobServers(res.sideJobServers);
          if (typeof res.inSafezone === "boolean") setInSafezone(res.inSafezone);
          if (typeof res.isLocked === "boolean") setIsLocked(res.isLocked);
          setLockReason(res.lockReason || null);
        }
      })
      .catch(() => {})
      .finally(() => setLoadingServers(false));
  }, []);

  useEffect(() => {
    loadServerRealms();
  }, [loadServerRealms]);

  const handleSwitchServer = (realm: { id: string; name: string; isCurrent?: boolean }) => {
    if (realm.isCurrent || switchingServer || !inSafezone || isLocked) return;
    setSwitchingServer(realm.id);
    if (isBrowserEnv()) {
      setPublicServers((prev) => prev.map((s) => ({ ...s, isCurrent: s.id === realm.id })));
      setJobServers((prev) => prev.map((s) => ({ ...s, isCurrent: s.id === realm.id })));
      setTimeout(() => setSwitchingServer(null), 600);
      return;
    }
    fetchNui("cfx-keydi-modules:connectServer", { id: realm.id, name: realm.name })
      .catch(() => {})
      .finally(() => {
        setTimeout(() => setSwitchingServer(null), 2500);
      });
  };

  return (
    <ModulePageShell
      title="Regions"
      eyebrow="REGIONS"
      subtitle="Switch regions in-game. Region 1 Farm · Region 2 School · Region 3–4 Turf."
      sidebarHint="Each region is isolated. Switch only from a safezone."
      onClose={onClose}
    >
      <div className="flex flex-1 flex-col justify-between overflow-hidden">
        <div className="mb-3 shrink-0 space-y-3">
          <div
            className={cn(
              "flex items-center justify-between rounded-xl border px-4 py-2.5 transition",
              inSafezone && !isLocked
                ? "border-emerald-500/40 bg-emerald-500/10 text-emerald-400"
                : "border-red-500/40 bg-red-500/10 text-red-400"
            )}
          >
            <div className="flex items-center gap-2.5 text-xs font-bold">
              {inSafezone && !isLocked ? (
                <>
                  <ShieldCheck className="h-4 w-4 shrink-0 text-emerald-400" />
                  <span>Safezone Verified — Server switching unlocked</span>
                </>
              ) : (
                <>
                  <Lock className="h-4 w-4 shrink-0 text-red-400" />
                  <span>
                    Server switching locked — {lockReason || "Outside Safezone / In Jail / In Job"}
                  </span>
                </>
              )}
            </div>
            <button
              type="button"
              onClick={loadServerRealms}
              disabled={loadingServers}
              className="flex cursor-pointer items-center gap-1.5 rounded-lg border border-white/10 bg-black/40 px-2.5 py-1 text-[9.5px] font-black uppercase tracking-wider text-white transition hover:border-white/30"
            >
              <RefreshCw className={cn("h-3 w-3", loadingServers && "animate-spin")} />
              Refresh
            </button>
          </div>

          <div className="flex items-center gap-2 border-b border-[#ff3a3a]/25 pb-2">
            {(
              [
                { id: "public" as const, label: `Public Servers (${publicServers.length})`, icon: Server },
                { id: "jobs" as const, label: `Side Job Servers (${jobServers.length})`, icon: Briefcase },
                { id: "faq" as const, label: "Why Instances Exist?", icon: HelpCircle },
              ] as const
            ).map((tab) => (
              <button
                key={tab.id}
                type="button"
                onClick={() => setServerSubTab(tab.id)}
                className={cn(
                  "flex cursor-pointer items-center gap-2 rounded-lg border px-3.5 py-1.5 text-xs font-black uppercase tracking-wider transition",
                  serverSubTab === tab.id
                    ? "border-[#ff3a3a] bg-[#ff3a3a] text-white"
                    : "border-white/10 bg-[#181216] text-[#a08890] hover:text-white"
                )}
              >
                <tab.icon className="h-3.5 w-3.5" />
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
        </div>

        {serverSubTab === "public" && (
          <div className="mb-2 flex-1 space-y-3 overflow-y-auto pr-2 custom-scrollbar">
            {publicServers.map((realm) => {
              const isBusy = switchingServer === realm.id;
              const cap = realm.maxPlayers > 0 ? realm.maxPlayers : 1;
              const playerPct = Math.min(100, Math.round((realm.onlinePlayers / cap) * 100));
              const canSwitch = inSafezone && !isLocked && !realm.isCurrent;

              return (
                <div
                  key={realm.id}
                  className={cn(
                    "flex flex-col gap-2.5 rounded-xl border p-3.5 transition bg-[#181216]",
                    realm.isCurrent ? "border-[#ff3a3a] bg-[#ff3a3a]/15" : "border-white/10 hover:border-[#ff3a3a]/50"
                  )}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3.5">
                      <div
                        className={cn(
                          "flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border",
                          realm.isCurrent
                            ? "border-[#ff3a3a] bg-[#ff3a3a] text-white"
                            : "border-white/10 bg-[#0d0d12] text-[#a08890]"
                        )}
                      >
                        <Server className="h-5 w-5" />
                      </div>
                      <div className="flex flex-col text-left">
                        <div className="flex items-center gap-2">
                          <span className="text-xs font-black text-white">{realm.name}</span>
                          <span className="rounded border border-[#ff3a3a]/40 bg-[#ff3a3a]/20 px-1.5 py-0.5 text-[8px] font-black uppercase tracking-wider text-[#ff8080]">
                            {realm.tag}
                          </span>
                          {realm.isCurrent && (
                            <span className="flex items-center gap-1 rounded-md border border-emerald-500/30 bg-emerald-500/15 px-2 py-0.5 text-[8.5px] font-black uppercase text-emerald-400">
                              <CheckCircle2 className="h-3 w-3" /> CONNECTED (CURRENT)
                            </span>
                          )}
                        </div>
                        <span className="mt-0.5 text-[10px] text-[#a08890]">{realm.description}</span>
                        {realm.functions && realm.functions.length > 0 && (
                          <div className="mt-1 flex flex-wrap gap-1">
                            {realm.functions.map((fn) => (
                              <span
                                key={fn}
                                className="rounded border border-[#ff3a3a]/30 bg-black/40 px-1.5 py-0.5 text-[8px] font-black uppercase tracking-wider text-[#ffc2c2]"
                              >
                                {fn}
                              </span>
                            ))}
                          </div>
                        )}
                      </div>
                    </div>

                    {realm.isCurrent ? (
                      <span className="rounded-lg border border-emerald-500/20 bg-emerald-500/10 px-3 py-1.5 text-[10px] font-black uppercase tracking-wider text-emerald-400">
                        Active Server
                      </span>
                    ) : (
                      <button
                        type="button"
                        onClick={() => handleSwitchServer(realm)}
                        disabled={!canSwitch || isBusy}
                        className={cn(
                          "flex shrink-0 cursor-pointer items-center gap-1.5 rounded-xl border px-4 py-2 text-xs font-black uppercase tracking-wider transition",
                          canSwitch
                            ? "border-[#ff3a3a] bg-gradient-to-r from-[#ff4d4d] via-[#e61e1e] to-[#b30000] text-white hover:brightness-110"
                            : "cursor-not-allowed border-white/10 bg-[#181216] text-[#a08890] opacity-50"
                        )}
                      >
                        {isBusy ? (
                          <>
                            <RefreshCw className="h-3.5 w-3.5 animate-spin" />
                            Connecting...
                          </>
                        ) : !canSwitch ? (
                          <>
                            <Lock className="h-3.5 w-3.5 text-red-400" />
                            Locked (Outside Safezone)
                          </>
                        ) : (
                          <>
                            <LogOut className="h-3.5 w-3.5" />
                            Switch Server
                          </>
                        )}
                      </button>
                    )}
                  </div>

                  <div className="flex items-center gap-3 border-t border-white/5 pt-1">
                    <div className="flex shrink-0 items-center gap-1.5 text-[10px] font-bold text-white">
                      <Users className="h-3.5 w-3.5 text-[#ff4d4d]" />
                      <span>
                        {realm.onlinePlayers} / {realm.maxPlayers} Players
                      </span>
                    </div>
                    <div className="h-2 flex-1 overflow-hidden rounded-full border border-white/10 bg-[#0d0d12]">
                      <div
                        className={cn(
                          "h-full rounded-full transition-all duration-500",
                          playerPct >= 90 ? "bg-amber-500" : "bg-[#ff3a3a]"
                        )}
                        style={{ width: `${playerPct}%` }}
                      />
                    </div>
                    <span className="shrink-0 text-[9.5px] font-bold text-[#a08890]">
                      {playerPct}% Capacity
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {serverSubTab === "jobs" && (
          <div className="mb-2 flex-1 space-y-3 overflow-y-auto pr-2 custom-scrollbar">
            <div className="space-y-2 rounded-xl border border-[#ff3a3a]/40 bg-[#ff3a3a]/10 p-3.5">
              <div className="flex items-center gap-2 text-xs font-bold text-white">
                <Briefcase className="h-4 w-4 text-[#ff4d4d]" />
                <span>Side Job Instance Protocol & How to Join</span>
              </div>
              <ul className="grid grid-cols-2 gap-2 text-[10px] leading-relaxed text-[#a08890]">
                <li className="flex items-center gap-1.5 rounded-lg border border-white/5 bg-[#0d0d12]/60 p-2">
                  <span className="font-black text-[#ff4d4d]">1.</span> Open Regions in Control Center (F5).
                </li>
                <li className="flex items-center gap-1.5 rounded-lg border border-white/5 bg-[#0d0d12]/60 p-2">
                  <span className="font-black text-[#ff4d4d]">2.</span> Join the Orange instance from this tab.
                </li>
                <li className="flex items-center gap-1.5 rounded-lg border border-white/5 bg-[#0d0d12]/60 p-2">
                  <span className="font-black text-[#ff4d4d]">3.</span> Grind oranges without Farm-region lag.
                </li>
                <li className="flex items-center gap-1.5 rounded-lg border border-white/5 bg-[#0d0d12]/60 p-2">
                  <span className="font-black text-[#ff4d4d]">4.</span> Switch back to Region 1 · All Farm when finished.
                </li>
              </ul>
            </div>

            <div className="grid grid-cols-2 gap-3">
              {jobServers.map((jobSrv) => {
                const isBusy = switchingServer === jobSrv.id;
                const canSwitch = inSafezone && !isLocked && !jobSrv.isCurrent;
                return (
                  <div
                    key={jobSrv.id}
                    className={cn(
                      "flex flex-col justify-between gap-2.5 rounded-xl border p-3.5",
                      jobSrv.isCurrent ? "border-[#ff3a3a] bg-[#ff3a3a]/15" : "border-[#ff3a3a]/30 bg-[#181216]"
                    )}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2.5">
                        <div className="flex h-8 w-8 items-center justify-center rounded-lg border border-[#ff3a3a] bg-[#ff3a3a]/20 text-white">
                          <Briefcase className="h-4 w-4" />
                        </div>
                        <div className="flex flex-col text-left">
                          <span className="text-xs font-bold text-white">{jobSrv.name}</span>
                          <span className="text-[9px] text-[#a08890]">{jobSrv.description}</span>
                        </div>
                      </div>
                      <span className="rounded border border-[#ff3a3a]/40 bg-[#ff3a3a]/20 px-2 py-0.5 text-[8px] font-black uppercase tracking-wider text-[#ff8080]">
                        {jobSrv.tag}
                      </span>
                    </div>

                    <div className="flex items-center justify-between border-t border-white/5 pt-2 text-[10px]">
                      <span className="text-[#a08890]">
                        {jobSrv.onlinePlayers} / {jobSrv.maxPlayers} Players
                      </span>
                      {jobSrv.isCurrent ? (
                        <span className="text-[9px] font-black uppercase text-emerald-400">
                          Active Instance
                        </span>
                      ) : (
                        <button
                          type="button"
                          onClick={() => handleSwitchServer(jobSrv)}
                          disabled={!canSwitch || isBusy}
                          className={cn(
                            "flex cursor-pointer items-center gap-1 rounded-lg border px-2.5 py-1 text-[9px] font-black uppercase tracking-wider transition",
                            canSwitch
                              ? "border-[#ff3a3a] bg-[#ff3a3a] text-white hover:brightness-110"
                              : "cursor-not-allowed border-white/10 bg-[#181216] text-[#a08890] opacity-50"
                          )}
                        >
                          {isBusy ? "Joining..." : "Join Instance"}
                        </button>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {serverSubTab === "faq" && (
          <div className="mb-2 flex-1 space-y-3 overflow-y-auto pr-2 custom-scrollbar">
            <div className="space-y-3 rounded-xl border border-[#ff3a3a]/30 bg-[#181216] p-4">
              <div className="flex items-center gap-2 border-b border-[#ff3a3a]/20 pb-2 text-[#ff4d4d]">
                <Info className="h-4.5 w-4.5" />
                <span className="text-xs font-black uppercase tracking-wider">
                  Why Instance Splitting Exists?
                </span>
              </div>
              <p className="text-[11px] leading-relaxed text-[#a08890]">
                Regions split the city in-game (same character, same inventory). Region 1 = All Farm.
                Region 2 = School. Region 3 & 4 = Turf War. Players only see others in the same region.
                Your last region is saved and restored when you reconnect.
              </p>
              <div className="grid grid-cols-3 gap-3 pt-1">
                <div className="rounded-xl border border-[#ff3a3a]/20 bg-[#0d0d12] p-3">
                  <span className="mb-1 block text-[10px] font-black uppercase text-[#ff4d4d]">
                    Zero Wipe
                  </span>
                  <span className="text-[9.5px] text-[#a08890]">
                    Your character, inventory, weapons, and money are 100% shared across all instances.
                  </span>
                </div>
                <div className="rounded-xl border border-[#ff3a3a]/20 bg-[#0d0d12] p-3">
                  <span className="mb-1 block text-[10px] font-black uppercase text-[#ff4d4d]">
                    Smooth Performance
                  </span>
                  <span className="text-[9.5px] text-[#a08890]">
                    Eliminates frame drops in high-density areas like Legion Square and police department.
                  </span>
                </div>
                <div className="rounded-xl border border-[#ff3a3a]/20 bg-[#0d0d12] p-3">
                  <span className="mb-1 block text-[10px] font-black uppercase text-[#ff4d4d]">
                    Safezone Protection
                  </span>
                  <span className="text-[9.5px] text-[#a08890]">
                    Server switching is locked outside safezones or during jail/combat to prevent combat
                    logging.
                  </span>
                </div>
              </div>
            </div>
          </div>
        )}

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
