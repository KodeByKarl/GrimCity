import { useEffect, useMemo, useRef, useState } from "react";
import {
  Lock,
  Search,
  X,
  RefreshCw,
  Plus,
  Trash2,
  Users,
  User,
  Wifi,
  WifiOff,
  Shirt,
  Glasses,
  Sparkles,
  PenLine,
  ChevronRight,
  Share2,
  Download,
  Upload,
  Hand,
  AlertTriangle,
  Briefcase,
  Clock,
} from "lucide-react";
import { cn } from "@/lib/utils";

export interface LockCategory {
  id: string;
  label: string;
  type: string;
  componentId: string;
  group?: string;
}

export interface LockPlayer {
  source?: number;
  identifier: string;
  name: string;
  online?: boolean;
}

export interface AppearanceLock {
  id: number;
  category: string;
  componentId: string;
  drawable: number;
  texture: number;
  anyTexture?: boolean;
  gender: string;
  ownerIdentifier: string;
  ownerName: string;
  sharedIdentifiers: string[];
  sharedJobs?: string[];
  sharedCount: number;
  expiresAt?: string;
  createdAt?: string;
}

export interface LockPanelData {
  brand?: string;
  staffName?: string;
  staffId?: number;
  staffIdentifier?: string;
  categories?: LockCategory[];
  genders?: { id: string; label: string }[];
  online?: LockPlayer[];
  locks?: AppearanceLock[];
}

interface LockMenuProps {
  data?: LockPanelData | null;
  onClose: () => void;
}

interface GrabFromPedResult {
  drawable?: number;
  texture?: number;
  gender?: string;
  componentId?: string;
}

interface DuplicateCheckResult {
  duplicate?: boolean;
  lock?: AppearanceLock;
}

async function fetchNui<T = unknown>(event: string, payload?: unknown): Promise<T> {
  const resourceName = (window as Window & { GetParentResourceName?: () => string }).GetParentResourceName
    ? (window as Window & { GetParentResourceName: () => string }).GetParentResourceName()
    : "cfx-keydi-ui";
  try {
    const resp = await fetch(`https://${resourceName}/${event}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(payload ?? {}),
    });
    return await resp.json();
  } catch {
    return undefined as T;
  }
}

function formatDate(raw?: string) {
  if (!raw) return "—";
  try {
    return new Date(raw).toLocaleString();
  } catch {
    return String(raw);
  }
}

function formatExpires(raw?: string) {
  if (!raw) return "Never";
  try {
    const d = new Date(raw);
    if (Number.isNaN(d.getTime())) return String(raw);
    if (d.getTime() < Date.now()) return `Expired · ${d.toLocaleString()}`;
    return d.toLocaleString();
  } catch {
    return String(raw);
  }
}

function parseJobsInput(raw: string): string[] {
  return raw
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
}

function jobsToInput(jobs?: string[]): string {
  return (jobs || []).join(", ");
}

function lockMatchesSearch(lock: AppearanceLock, query: string): boolean {
  const q = query.trim().toLowerCase();
  if (!q) return true;
  const haystack = [
    lock.ownerName,
    lock.ownerIdentifier,
    String(lock.drawable),
    lock.componentId,
    String(lock.texture),
    lock.gender,
  ]
    .join(" ")
    .toLowerCase();
  return haystack.includes(q);
}

const GROUP_META: Record<string, { label: string; icon: typeof Shirt }> = {
  clothes: { label: "Clothes", icon: Shirt },
  props: { label: "Props", icon: Glasses },
  head: { label: "Head", icon: Sparkles },
  tattoos: { label: "Tattoos", icon: PenLine },
};

export default function LockMenu({ data, onClose }: LockMenuProps) {
  const categories = data?.categories || [];
  const genders = data?.genders || [
    { id: "male", label: "Male" },
    { id: "female", label: "Female" },
    { id: "any", label: "Any" },
  ];

  const importRef = useRef<HTMLInputElement>(null);

  const [online, setOnline] = useState<LockPlayer[]>(data?.online || []);
  const [locks, setLocks] = useState<AppearanceLock[]>(data?.locks || []);
  const [selectedGroup, setSelectedGroup] = useState<string>(categories[0]?.group || "clothes");
  const [selectedCategory, setSelectedCategory] = useState<string>(categories[0]?.id || "tops");
  const [busy, setBusy] = useState(false);
  const [lockSearch, setLockSearch] = useState("");

  const [showAdd, setShowAdd] = useState(false);
  const [showShared, setShowShared] = useState<AppearanceLock | null>(null);

  // Add-lock form
  const [drawable, setDrawable] = useState(0);
  const [texture, setTexture] = useState(0);
  const [anyTexture, setAnyTexture] = useState(false);
  const [gender, setGender] = useState("male");
  const [componentOverride, setComponentOverride] = useState("");
  const [expiresAt, setExpiresAt] = useState("");
  const [addSharedJobs, setAddSharedJobs] = useState("");
  const [ownerMode, setOwnerMode] = useState<"online" | "offline">("online");
  const [ownerSearch, setOwnerSearch] = useState("");
  const [owner, setOwner] = useState<LockPlayer | null>(null);
  const [offlineResults, setOfflineResults] = useState<LockPlayer[]>([]);
  const [sharedPick, setSharedPick] = useState<string[]>([]);
  const [searching, setSearching] = useState(false);
  const [duplicateWarning, setDuplicateWarning] = useState(false);
  const [grabbing, setGrabbing] = useState(false);

  // Shared manage
  const [sharedSearch, setSharedSearch] = useState("");
  const [sharedOffline, setSharedOffline] = useState<LockPlayer[]>([]);
  const [sharedDraft, setSharedDraft] = useState<string[]>([]);
  const [sharedJobsDraft, setSharedJobsDraft] = useState("");

  const brand = data?.brand || "PANDORA CITY";
  const staffIdentifier = data?.staffIdentifier;
  const staffSelf = useMemo(() => {
    if (staffIdentifier) {
      const found = online.find((p) => p.identifier === staffIdentifier);
      if (found) return found;
    }
    if (data?.staffId != null) {
      const found = online.find((p) => p.source === data.staffId);
      if (found) return found;
    }
    if (staffIdentifier) {
      return {
        identifier: staffIdentifier,
        name: data?.staffName || "Me",
        source: data?.staffId,
        online: true,
      } satisfies LockPlayer;
    }
    return null;
  }, [online, staffIdentifier, data?.staffId, data?.staffName]);

  useEffect(() => {
    setOnline(data?.online || []);
    setLocks(data?.locks || []);
    if (data?.categories?.length) {
      const stillExists = data.categories.find((c) => c.id === selectedCategory);
      if (!stillExists) {
        const first = data.categories[0];
        setSelectedGroup(first.group || "clothes");
        setSelectedCategory(first.id);
      } else if (stillExists.group && stillExists.group !== selectedGroup) {
        setSelectedGroup(stillExists.group);
      }
    }
  }, [data, selectedCategory, selectedGroup]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const msg = event.data;
      if (!msg) return;
      if (msg.action === "cfx-keydi-lockscript:panel:update" && msg.data) {
        if (msg.data.online) setOnline(msg.data.online);
        if (msg.data.locks) setLocks(msg.data.locks);
      }
    };
    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  // Offline search for owner
  useEffect(() => {
    if (!showAdd || ownerMode !== "offline") return;
    const q = ownerSearch.trim();
    if (q.length < 2) {
      setOfflineResults([]);
      return;
    }
    const timer = setTimeout(async () => {
      setSearching(true);
      const results = await fetchNui<LockPlayer[]>("cfx-keydi-lockscript:searchOffline", { query: q });
      setOfflineResults(Array.isArray(results) ? results : []);
      setSearching(false);
    }, 280);
    return () => clearTimeout(timer);
  }, [ownerSearch, ownerMode, showAdd]);

  // Offline search for shared manage
  useEffect(() => {
    if (!showShared) return;
    const q = sharedSearch.trim();
    if (q.length < 2) {
      setSharedOffline([]);
      return;
    }
    const timer = setTimeout(async () => {
      const results = await fetchNui<LockPlayer[]>("cfx-keydi-lockscript:searchOffline", { query: q });
      setSharedOffline(Array.isArray(results) ? results : []);
    }, 280);
    return () => clearTimeout(timer);
  }, [sharedSearch, showShared]);

  // Clear duplicate warning when form fields change
  useEffect(() => {
    if (duplicateWarning) setDuplicateWarning(false);
  }, [drawable, texture, anyTexture, gender, componentOverride, selectedCategory, owner?.identifier]);

  const grouped = useMemo(() => {
    const map: Record<string, LockCategory[]> = {};
    for (const cat of categories) {
      const g = cat.group || "other";
      if (!map[g]) map[g] = [];
      map[g].push(cat);
    }
    return map;
  }, [categories]);

  const groupKeys = useMemo(() => Object.keys(grouped), [grouped]);

  const categoriesInGroup = useMemo(
    () => grouped[selectedGroup] || [],
    [grouped, selectedGroup]
  );

  const searchActive = lockSearch.trim().length > 0;

  const displayedLocks = useMemo(() => {
    const base = searchActive
      ? locks
      : locks.filter((l) => l.category === selectedCategory);
    return base.filter((l) => lockMatchesSearch(l, lockSearch));
  }, [locks, selectedCategory, lockSearch, searchActive]);

  const activeCat = categories.find((c) => c.id === selectedCategory);

  const onGroupChange = (group: string) => {
    setSelectedGroup(group);
    const first = grouped[group]?.[0];
    if (first) setSelectedCategory(first.id);
  };

  const filteredOnline = useMemo(() => {
    const q = ownerSearch.trim().toLowerCase();
    const list = q
      ? online.filter((p) => `${p.name} ${p.source ?? ""} ${p.identifier}`.toLowerCase().includes(q))
      : [...online];
    const meId = staffIdentifier;
    if (!meId) return list;
    return list.sort((a, b) => {
      if (a.identifier === meId) return -1;
      if (b.identifier === meId) return 1;
      return 0;
    });
  }, [online, ownerSearch, staffIdentifier]);

  const ownerList = useMemo(() => {
    const base = ownerMode === "online" ? filteredOnline : offlineResults;
    if (ownerMode !== "online" || !staffSelf) return base;
    if (base.some((p) => p.identifier === staffSelf.identifier)) return base;
    return [staffSelf, ...base];
  }, [ownerMode, filteredOnline, offlineResults, staffSelf]);

  const refresh = async () => {
    setBusy(true);
    const res = await fetchNui<{ online?: LockPlayer[]; locks?: AppearanceLock[] }>(
      "cfx-keydi-lockscript:refresh"
    );
    if (res?.online) setOnline(res.online);
    if (res?.locks) setLocks(res.locks);
    setBusy(false);
  };

  const openAdd = () => {
    setDrawable(0);
    setTexture(0);
    setAnyTexture(false);
    setGender("male");
    setComponentOverride("");
    setExpiresAt("");
    setAddSharedJobs("");
    setOwner(staffSelf);
    setSharedPick([]);
    setOwnerSearch("");
    setOwnerMode("online");
    setDuplicateWarning(false);
    setShowAdd(true);
  };

  const buildAddPayload = () => ({
    category: selectedCategory,
    componentId: componentOverride.trim() || activeCat?.componentId,
    drawable: Math.floor(Number(drawable) || 0),
    texture: anyTexture ? 0 : Math.floor(Number(texture) || 0),
    anyTexture,
    gender,
    ownerIdentifier: owner?.identifier,
    ownerName: owner?.name,
    sharedIdentifiers: sharedPick,
    sharedJobs: parseJobsInput(addSharedJobs),
    expiresAt: expiresAt ? new Date(expiresAt).toISOString() : undefined,
  });

  const grabFromPed = async () => {
    setGrabbing(true);
    const res = await fetchNui<GrabFromPedResult>("cfx-keydi-lockscript:grabFromPed", {
      category: selectedCategory,
    });
    if (res) {
      if (res.drawable != null) setDrawable(res.drawable);
      if (res.texture != null) setTexture(res.texture);
      if (res.gender) setGender(res.gender);
      if (res.componentId) setComponentOverride(res.componentId);
    }
    setGrabbing(false);
  };

  const submitAdd = async () => {
    if (!owner || busy) return;

    setBusy(true);
    const payload = buildAddPayload();
    const dup = await fetchNui<DuplicateCheckResult>("cfx-keydi-lockscript:checkDuplicate", payload);

    if (dup?.duplicate) {
      setDuplicateWarning(true);
      setBusy(false);
      return;
    }

    await fetchNui("cfx-keydi-lockscript:addLock", payload);
    setShowAdd(false);
    setDuplicateWarning(false);
    setTimeout(refresh, 350);
    setBusy(false);
  };

  const removeLock = async (lock: AppearanceLock) => {
    if (busy) return;
    setBusy(true);
    await fetchNui("cfx-keydi-lockscript:removeLock", { lockId: lock.id });
    setTimeout(refresh, 350);
    setBusy(false);
  };

  const openShared = (lock: AppearanceLock) => {
    setShowShared(lock);
    setSharedDraft([...(lock.sharedIdentifiers || [])]);
    setSharedJobsDraft(jobsToInput(lock.sharedJobs));
    setSharedSearch("");
  };

  const saveShared = async () => {
    if (!showShared || busy) return;
    setBusy(true);
    await fetchNui("cfx-keydi-lockscript:setShared", {
      lockId: showShared.id,
      sharedIdentifiers: sharedDraft,
      sharedJobs: parseJobsInput(sharedJobsDraft),
    });
    setShowShared(null);
    setTimeout(refresh, 350);
    setBusy(false);
  };

  const exportLocks = async () => {
    setBusy(true);
    const res = await fetchNui<AppearanceLock[] | { locks?: AppearanceLock[] }>(
      "cfx-keydi-lockscript:exportLocks"
    );
    const exported = Array.isArray(res) ? res : res?.locks || locks;
    const blob = new Blob([JSON.stringify(exported, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "keydi-locks.json";
    a.click();
    URL.revokeObjectURL(url);
    setBusy(false);
  };

  const importLocks = async (file: File) => {
    try {
      const text = await file.text();
      const parsed = JSON.parse(text);
      const imported: AppearanceLock[] = Array.isArray(parsed) ? parsed : parsed?.locks;
      if (!Array.isArray(imported)) return;

      setBusy(true);
      await fetchNui("cfx-keydi-lockscript:importLocks", { locks: imported });
      setTimeout(refresh, 350);
      setBusy(false);
    } catch {
      /* invalid JSON */
    } finally {
      if (importRef.current) importRef.current.value = "";
    }
  };

  const toggleSharedId = (identifier: string, list: string[], setList: (v: string[]) => void) => {
    if (list.includes(identifier)) {
      setList(list.filter((id) => id !== identifier));
    } else {
      setList([...list, identifier]);
    }
  };

  const playerLabel = (identifier: string) => {
    const found = online.find((p) => p.identifier === identifier);
    return found ? `${found.name} (#${found.source})` : identifier;
  };

  const renderSharedCell = (lock: AppearanceLock) => {
    const jobCount = lock.sharedJobs?.length ?? 0;
    const idCount = lock.sharedCount ?? lock.sharedIdentifiers?.length ?? 0;
    if (idCount === 0 && jobCount === 0) return <span className="text-white/40">0</span>;
    return (
      <span className="text-white/70">
        {idCount}
        {jobCount > 0 && (
          <span className="ml-1 text-[9px] text-[#8fe4ff]/80">
            +{jobCount} job{jobCount === 1 ? "" : "s"}
          </span>
        )}
      </span>
    );
  };

  const GroupIcon = GROUP_META[selectedGroup]?.icon || Lock;
  const preferredGroupOrder = ["clothes", "props", "head"];
  const orderedGroups = [
    ...preferredGroupOrder.filter((g) => grouped[g]),
    ...groupKeys.filter((g) => !preferredGroupOrder.includes(g)),
  ];

  const categoryLockCount = locks.filter((l) => l.category === selectedCategory).length;

  return (
    <div className="pandora fixed inset-0 z-[99995] flex items-center justify-center bg-black/55 backdrop-blur-[2px]">
      <div
        className="relative flex h-[72vh] w-[700px] max-w-[94vw] flex-col overflow-hidden rounded-2xl border shadow-[0_30px_80px_-20px_rgba(0,0,0,0.9)]"
        style={{
          background: "linear-gradient(180deg, rgba(10, 40, 70, 0.97) 0%, rgba(5, 25, 47, 0.98) 100%)",
          borderColor: "rgba(143, 228, 255, 0.22)",
        }}
      >
        <div className="panel-grid pointer-events-none absolute inset-0 opacity-25" />

        {/* Header */}
        <div
          className="relative flex items-center justify-between gap-3 border-b px-4 py-3"
          style={{
            background:
              "linear-gradient(135deg, rgba(53,199,242,0.35) 0%, rgba(28,111,168,0.55) 55%, rgba(11,44,78,0.6) 100%)",
            borderBottomColor: "rgba(255, 210, 76, 0.35)",
          }}
        >
          <div className="flex min-w-0 items-center gap-3">
            <div className="flex h-9 w-9 items-center justify-center rounded-xl border border-white/25 bg-white/12">
              <Lock className="h-4 w-4 text-white" />
            </div>
            <div className="min-w-0">
              <p className="text-[10px] font-black uppercase tracking-[0.18em] text-white/90">
                VIP Appearance Locks
              </p>
              <p className="truncate text-[11px] font-bold uppercase tracking-wider text-[#ffd24c]/85">
                {brand} · {data?.staffName || "Staff"}
              </p>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={exportLocks}
              disabled={busy}
              className="flex h-8 items-center gap-1 rounded-lg border border-white/15 bg-black/25 px-2 text-[9px] font-bold uppercase tracking-wide text-white/80 transition hover:border-white/30 hover:text-white disabled:opacity-40"
              title="Export locks"
            >
              <Download className="h-3.5 w-3.5" />
              <span className="hidden sm:inline">Export</span>
            </button>
            <button
              type="button"
              onClick={() => importRef.current?.click()}
              disabled={busy}
              className="flex h-8 items-center gap-1 rounded-lg border border-white/15 bg-black/25 px-2 text-[9px] font-bold uppercase tracking-wide text-white/80 transition hover:border-white/30 hover:text-white disabled:opacity-40"
              title="Import locks"
            >
              <Upload className="h-3.5 w-3.5" />
              <span className="hidden sm:inline">Import</span>
            </button>
            <input
              ref={importRef}
              type="file"
              accept=".json,application/json"
              className="hidden"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) void importLocks(file);
              }}
            />
            <button
              type="button"
              onClick={refresh}
              disabled={busy}
              className="flex h-8 w-8 items-center justify-center rounded-lg border border-white/15 bg-black/25 text-white/80 transition hover:border-white/30 hover:text-white disabled:opacity-40"
              title="Refresh"
            >
              <RefreshCw className={cn("h-3.5 w-3.5", busy && "animate-spin")} />
            </button>
            <button
              type="button"
              onClick={onClose}
              className="flex items-center gap-1.5 rounded-lg border border-white/15 bg-black/25 px-2.5 py-1.5 text-[10px] font-semibold text-white/80 transition hover:border-white/30 hover:text-white"
            >
              <span>Esc</span>
              <X className="h-3.5 w-3.5" />
            </button>
          </div>
        </div>

        {/* Body: compact group sidebar + category dropdown */}
        <div className="relative grid min-h-0 flex-1 grid-cols-[148px_1fr]">
          {/* Group sidebar (Clothes / Props / Head / Tattoos only) */}
          <div className="flex min-h-0 flex-col gap-1.5 border-r border-white/10 p-2.5">
            {orderedGroups.map((g) => {
              const meta = GROUP_META[g] || { label: g, icon: Lock };
              const Icon = meta.icon;
              const active = selectedGroup === g;
              const groupLockCount = (grouped[g] || []).reduce(
                (sum, cat) => sum + locks.filter((l) => l.category === cat.id).length,
                0
              );
              return (
                <button
                  key={g}
                  type="button"
                  onClick={() => onGroupChange(g)}
                  className={cn(
                    "flex items-center gap-2 rounded-xl border px-2.5 py-2.5 text-left transition",
                    active
                      ? "border-[#35c7f2]/45 bg-[#35c7f2]/20 text-[#8fe4ff]"
                      : "border-transparent bg-black/15 text-white/55 hover:border-white/10 hover:bg-white/5 hover:text-white/85"
                  )}
                >
                  <Icon className="h-3.5 w-3.5 shrink-0" />
                  <span className="min-w-0 flex-1 truncate text-[11px] font-bold uppercase tracking-wide">
                    {meta.label}
                  </span>
                  {groupLockCount > 0 && (
                    <span
                      className={cn(
                        "rounded-md px-1.5 py-0.5 text-[9px] font-bold",
                        active ? "bg-black/25 text-[#8fe4ff]" : "bg-black/30 text-white/40"
                      )}
                    >
                      {groupLockCount}
                    </span>
                  )}
                </button>
              );
            })}
          </div>

          {/* Main: dropdown category + list */}
          <div className="flex min-h-0 flex-col">
            <div className="flex items-end gap-2 border-b border-white/10 px-3 py-2.5">
              <label className="min-w-0 flex-1">
                <span className="mb-1 flex items-center gap-1 text-[9px] font-bold uppercase tracking-wider text-white/40">
                  <GroupIcon className="h-3 w-3" /> Category
                </span>
                <select
                  value={selectedCategory}
                  onChange={(e) => setSelectedCategory(e.target.value)}
                  className="w-full rounded-lg border border-white/10 bg-black/35 px-2.5 py-2 text-[12px] font-semibold text-white outline-none focus:border-[#35c7f2]/40"
                >
                  {categoriesInGroup.map((cat) => {
                    const count = locks.filter((l) => l.category === cat.id).length;
                    return (
                      <option key={cat.id} value={cat.id} className="bg-[#0a2846]">
                        {cat.label}
                        {count > 0 ? ` (${count})` : ""}
                      </option>
                    );
                  })}
                </select>
              </label>

              <button
                type="button"
                onClick={openAdd}
                className="inline-flex h-[38px] shrink-0 items-center gap-1.5 rounded-lg border border-[#35c7f2]/40 bg-[#35c7f2]/20 px-3 text-[11px] font-bold uppercase tracking-wide text-[#8fe4ff] transition hover:bg-[#35c7f2]/30"
              >
                <Plus className="h-3.5 w-3.5" /> Add
              </button>
            </div>

            <div className="flex items-center justify-between gap-2 px-3 pt-2 pb-1">
              <p className="text-[10px] text-white/40">
                <span className="font-semibold text-white/70">{activeCat?.label || "—"}</span>
                {" · "}comp {activeCat?.componentId || "—"}
                {" · "}
                {searchActive ? (
                  <>
                    {displayedLocks.length} match{displayedLocks.length === 1 ? "" : "es"} (all categories)
                  </>
                ) : (
                  <>
                    {categoryLockCount} lock{categoryLockCount === 1 ? "" : "s"}
                  </>
                )}
              </p>
            </div>

            {/* Search locks */}
            <div className="px-3 pb-2">
              <div className="relative">
                <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-white/35" />
                <input
                  value={lockSearch}
                  onChange={(e) => setLockSearch(e.target.value)}
                  placeholder="Search owner, identifier, drawable, component..."
                  className="w-full rounded-lg border border-white/10 bg-black/30 py-2 pl-8 pr-3 text-[11px] text-white outline-none placeholder:text-white/30 focus:border-[#35c7f2]/40"
                />
                {lockSearch && (
                  <button
                    type="button"
                    onClick={() => setLockSearch("")}
                    className="absolute right-2 top-1/2 -translate-y-1/2 text-white/40 hover:text-white"
                  >
                    <X className="h-3.5 w-3.5" />
                  </button>
                )}
              </div>
            </div>

            <div className="no-scrollbar relative min-h-0 flex-1 overflow-y-auto px-3 pb-3 pt-1">
              {displayedLocks.length === 0 ? (
                <div className="flex h-full min-h-[180px] items-center justify-center rounded-xl border border-dashed border-white/10 bg-black/15">
                  <p className="text-[11px] text-white/40">
                    {searchActive ? "No locks match your search." : "No locks in this category yet."}
                  </p>
                </div>
              ) : (
                <div className="overflow-hidden rounded-xl border border-white/10">
                  <table className="w-full text-left text-[11px]">
                    <thead className="sticky top-0 z-[1]">
                      <tr className="border-b border-white/10 bg-[#082038] text-[9px] font-black uppercase tracking-wider text-white/40">
                        <th className="px-2.5 py-2">Draw / Tex</th>
                        <th className="px-2.5 py-2">Gender</th>
                        <th className="px-2.5 py-2">Owner</th>
                        <th className="px-2.5 py-2">Shared</th>
                        <th className="px-2.5 py-2">Expires</th>
                        <th className="px-2.5 py-2">Date</th>
                        <th className="px-2.5 py-2 text-right"> </th>
                      </tr>
                    </thead>
                    <tbody>
                      {displayedLocks.map((lock) => {
                        const lockCat = categories.find((c) => c.id === lock.category);
                        const isExpired =
                          lock.expiresAt && new Date(lock.expiresAt).getTime() < Date.now();
                        return (
                          <tr
                            key={lock.id}
                            className="border-b border-white/5 transition hover:bg-white/[0.03]"
                          >
                            <td className="px-2.5 py-2 font-mono text-white/90">
                              <span className="font-bold">{lock.drawable}</span>
                              <span className="text-white/35"> / </span>
                              {lock.anyTexture ? (
                                <span className="text-[#8fe4ff]/90">any</span>
                              ) : (
                                lock.texture
                              )}
                              {(lockCat?.type === "tattoo" || searchActive) && (
                                <p className="mt-0.5 max-w-[90px] truncate text-[9px] text-white/40">
                                  {lock.componentId}
                                  {searchActive && lockCat && (
                                    <span className="text-white/25"> · {lockCat.label}</span>
                                  )}
                                </p>
                              )}
                            </td>
                            <td className="px-2.5 py-2 capitalize text-white/70">{lock.gender}</td>
                            <td className="px-2.5 py-2">
                              <p className="max-w-[110px] truncate font-semibold text-white">{lock.ownerName}</p>
                              <p className="max-w-[110px] truncate font-mono text-[9px] text-white/35">
                                {lock.ownerIdentifier}
                              </p>
                            </td>
                            <td className="px-2.5 py-2">{renderSharedCell(lock)}</td>
                            <td
                              className={cn(
                                "px-2.5 py-2 text-[10px]",
                                isExpired ? "text-red-300/80" : "text-white/45"
                              )}
                            >
                              {formatExpires(lock.expiresAt)}
                            </td>
                            <td className="px-2.5 py-2 text-[10px] text-white/45">
                              {formatDate(lock.createdAt)}
                            </td>
                            <td className="px-2.5 py-2">
                              <div className="flex items-center justify-end gap-1">
                                <button
                                  type="button"
                                  onClick={() => openShared(lock)}
                                  className="rounded-md border border-white/10 bg-black/20 p-1.5 text-white/55 transition hover:border-[#35c7f2]/40 hover:text-[#8fe4ff]"
                                  title="Manage shared access"
                                >
                                  <Share2 className="h-3.5 w-3.5" />
                                </button>
                                <button
                                  type="button"
                                  onClick={() => removeLock(lock)}
                                  className="rounded-md border border-white/10 bg-black/20 p-1.5 text-white/55 transition hover:border-red-400/40 hover:text-red-300"
                                  title="Remove lock"
                                >
                                  <Trash2 className="h-3.5 w-3.5" />
                                </button>
                              </div>
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Add Lock modal */}
        {showAdd && (
          <div className="absolute inset-0 z-20 flex items-center justify-center bg-black/60 p-4">
            <div
              className="flex max-h-[90%] w-full max-w-[520px] flex-col overflow-hidden rounded-2xl border"
              style={{
                background: "linear-gradient(180deg, rgba(12, 48, 82, 0.98) 0%, rgba(6, 28, 52, 0.99) 100%)",
                borderColor: "rgba(143, 228, 255, 0.25)",
              }}
            >
              <div className="flex items-center justify-between border-b border-white/10 px-4 py-3">
                <p className="text-[12px] font-black uppercase tracking-wider text-white">
                  Add Lock · {activeCat?.label}
                </p>
                <button type="button" onClick={() => setShowAdd(false)} className="text-white/50 hover:text-white">
                  <X className="h-4 w-4" />
                </button>
              </div>

              {duplicateWarning && (
                <div className="mx-4 mt-3 flex items-center gap-2 rounded-lg border border-red-400/40 bg-red-500/15 px-3 py-2">
                  <AlertTriangle className="h-4 w-4 shrink-0 text-red-300" />
                  <p className="text-[11px] font-semibold text-red-200">Already locked — duplicate entry exists.</p>
                </div>
              )}

              <div className="no-scrollbar min-h-0 flex-1 space-y-3 overflow-y-auto p-4">
                <div className="flex items-center justify-between gap-2">
                  <span className="text-[9px] font-bold uppercase text-white/40">Appearance values</span>
                  <button
                    type="button"
                    onClick={grabFromPed}
                    disabled={grabbing || busy}
                    className="inline-flex items-center gap-1.5 rounded-lg border border-[#ffd24c]/35 bg-[#ffd24c]/10 px-2.5 py-1 text-[9px] font-bold uppercase tracking-wide text-[#ffd24c]/90 transition hover:bg-[#ffd24c]/20 disabled:opacity-40"
                  >
                    <Hand className={cn("h-3 w-3", grabbing && "animate-pulse")} />
                    Grab from me
                  </button>
                </div>

                <div className="grid grid-cols-3 gap-2">
                  <label className="block">
                    <span className="text-[9px] font-bold uppercase text-white/40">Drawable</span>
                    <input
                      type="number"
                      value={drawable}
                      onChange={(e) => setDrawable(Number(e.target.value))}
                      className="mt-1 w-full rounded-lg border border-white/10 bg-black/30 px-2.5 py-2 text-[12px] text-white outline-none focus:border-[#35c7f2]/40"
                    />
                  </label>
                  <label className="block">
                    <span className="text-[9px] font-bold uppercase text-white/40">Texture</span>
                    <input
                      type="number"
                      value={texture}
                      disabled={anyTexture}
                      onChange={(e) => setTexture(Number(e.target.value))}
                      className={cn(
                        "mt-1 w-full rounded-lg border border-white/10 bg-black/30 px-2.5 py-2 text-[12px] text-white outline-none focus:border-[#35c7f2]/40",
                        anyTexture && "cursor-not-allowed opacity-40"
                      )}
                    />
                  </label>
                  <label className="block">
                    <span className="text-[9px] font-bold uppercase text-white/40">Gender</span>
                    <select
                      value={gender}
                      onChange={(e) => setGender(e.target.value)}
                      className="mt-1 w-full rounded-lg border border-white/10 bg-black/30 px-2.5 py-2 text-[12px] text-white outline-none focus:border-[#35c7f2]/40"
                    >
                      {genders.map((g) => (
                        <option key={g.id} value={g.id} className="bg-[#0a2846]">
                          {g.label}
                        </option>
                      ))}
                    </select>
                  </label>
                </div>

                <label className="flex cursor-pointer items-center gap-2">
                  <input
                    type="checkbox"
                    checked={anyTexture}
                    onChange={(e) => setAnyTexture(e.target.checked)}
                    className="h-3.5 w-3.5 rounded border-white/20 bg-black/30 accent-[#35c7f2]"
                  />
                  <span className="text-[11px] font-semibold text-white/75">Any texture</span>
                </label>

                {(activeCat?.type === "tattoo" || activeCat?.type === "headOverlay") && (
                  <label className="block">
                    <span className="text-[9px] font-bold uppercase text-white/40">
                      {activeCat?.type === "tattoo" ? "Tattoo name (e.g. TAT_AR_000)" : "Component key override"}
                    </span>
                    <input
                      value={componentOverride}
                      onChange={(e) => setComponentOverride(e.target.value)}
                      placeholder={activeCat?.componentId}
                      className="mt-1 w-full rounded-lg border border-white/10 bg-black/30 px-2.5 py-2 text-[12px] text-white outline-none placeholder:text-white/25 focus:border-[#35c7f2]/40"
                    />
                  </label>
                )}

                <div className="grid grid-cols-2 gap-2">
                  <label className="block">
                    <span className="mb-1 flex items-center gap-1 text-[9px] font-bold uppercase text-white/40">
                      <Clock className="h-3 w-3" /> Expires (optional)
                    </span>
                    <input
                      type="datetime-local"
                      value={expiresAt}
                      onChange={(e) => setExpiresAt(e.target.value)}
                      className="w-full rounded-lg border border-white/10 bg-black/30 px-2.5 py-2 text-[11px] text-white outline-none focus:border-[#35c7f2]/40 [color-scheme:dark]"
                    />
                  </label>
                  <label className="block">
                    <span className="mb-1 flex items-center gap-1 text-[9px] font-bold uppercase text-white/40">
                      <Briefcase className="h-3 w-3" /> Shared jobs
                    </span>
                    <input
                      value={addSharedJobs}
                      onChange={(e) => setAddSharedJobs(e.target.value)}
                      placeholder="police, ambulance"
                      className="w-full rounded-lg border border-white/10 bg-black/30 px-2.5 py-2 text-[11px] text-white outline-none placeholder:text-white/25 focus:border-[#35c7f2]/40"
                    />
                  </label>
                </div>

                <div>
                  <div className="mb-1.5 flex items-center justify-between">
                    <span className="text-[9px] font-bold uppercase text-white/40">Owner</span>
                    <div className="flex items-center gap-1.5">
                      {staffSelf && (
                        <button
                          type="button"
                          onClick={() => {
                            setOwnerMode("online");
                            setOwner(staffSelf);
                            setOwnerSearch("");
                          }}
                          className={cn(
                            "inline-flex items-center gap-1 rounded-md border px-2 py-0.5 text-[9px] font-bold uppercase tracking-wide transition",
                            owner?.identifier === staffSelf.identifier
                              ? "border-[#ffd24c]/50 bg-[#ffd24c]/20 text-[#ffd24c]"
                              : "border-white/10 bg-black/20 text-white/55 hover:border-[#ffd24c]/35 hover:text-[#ffd24c]/90"
                          )}
                        >
                          <User className="h-3 w-3" /> Me
                        </button>
                      )}
                      <div className="flex rounded-lg border border-white/10 bg-black/20 p-0.5">
                      <button
                        type="button"
                        onClick={() => setOwnerMode("online")}
                        className={cn(
                          "inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-[9px] font-bold uppercase",
                          ownerMode === "online" ? "bg-[#35c7f2]/25 text-[#8fe4ff]" : "text-white/45"
                        )}
                      >
                        <Wifi className="h-3 w-3" /> Online
                      </button>
                      <button
                        type="button"
                        onClick={() => setOwnerMode("offline")}
                        className={cn(
                          "inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-[9px] font-bold uppercase",
                          ownerMode === "offline" ? "bg-[#35c7f2]/25 text-[#8fe4ff]" : "text-white/45"
                        )}
                      >
                        <WifiOff className="h-3 w-3" /> Offline
                      </button>
                      </div>
                    </div>
                  </div>
                  <div className="relative mb-2">
                    <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-white/35" />
                    <input
                      value={ownerSearch}
                      onChange={(e) => setOwnerSearch(e.target.value)}
                      placeholder={ownerMode === "online" ? "Search online..." : "Search by name / identifier..."}
                      className="w-full rounded-lg border border-white/10 bg-black/30 py-2 pl-8 pr-3 text-[12px] text-white outline-none placeholder:text-white/30 focus:border-[#35c7f2]/40"
                    />
                  </div>
                  <div className="max-h-[120px] space-y-1 overflow-y-auto rounded-lg border border-white/10 bg-black/20 p-1.5">
                    {ownerMode === "offline" && ownerSearch.trim().length < 2 && (
                      <p className="py-4 text-center text-[10px] text-white/35">Type at least 2 characters.</p>
                    )}
                    {searching && <p className="py-3 text-center text-[10px] text-white/35">Searching...</p>}
                    {ownerList.map((p) => {
                      const sel = owner?.identifier === p.identifier;
                      return (
                        <button
                          key={`${p.identifier}-${p.source ?? "off"}`}
                          type="button"
                          onClick={() => setOwner(p)}
                          className={cn(
                            "flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left transition",
                            sel ? "bg-[#35c7f2]/20 text-[#8fe4ff]" : "text-white/70 hover:bg-white/5"
                          )}
                        >
                          <User className="h-3.5 w-3.5 shrink-0 opacity-50" />
                          <span className="min-w-0 flex-1 truncate text-[11px] font-semibold">{p.name}</span>
                          {(p.identifier === staffIdentifier || p.source === data?.staffId) && (
                            <span className="rounded bg-[#ffd24c]/20 px-1.5 py-0.5 text-[8px] font-black uppercase tracking-wide text-[#ffd24c]">
                              You
                            </span>
                          )}
                          {p.source != null && (
                            <span className="text-[9px] text-white/40">#{p.source}</span>
                          )}
                        </button>
                      );
                    })}
                  </div>
                </div>

                <div>
                  <span className="text-[9px] font-bold uppercase text-white/40">Also allow (shared)</span>
                  <div className="mt-1.5 max-h-[90px] space-y-1 overflow-y-auto rounded-lg border border-white/10 bg-black/20 p-1.5">
                    {online
                      .filter((p) => p.identifier !== owner?.identifier)
                      .map((p) => {
                        const on = sharedPick.includes(p.identifier);
                        return (
                          <button
                            key={p.identifier}
                            type="button"
                            onClick={() => toggleSharedId(p.identifier, sharedPick, setSharedPick)}
                            className={cn(
                              "flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left text-[11px] transition",
                              on ? "bg-emerald-500/15 text-emerald-300" : "text-white/60 hover:bg-white/5"
                            )}
                          >
                            <Users className="h-3 w-3 shrink-0 opacity-50" />
                            <span className="truncate font-semibold">{p.name}</span>
                            <ChevronRight className="ml-auto h-3 w-3 opacity-30" />
                          </button>
                        );
                      })}
                    {online.length === 0 && (
                      <p className="py-3 text-center text-[10px] text-white/35">No online players.</p>
                    )}
                  </div>
                </div>
              </div>

              <div className="flex justify-end gap-2 border-t border-white/10 px-4 py-3">
                <button
                  type="button"
                  onClick={() => setShowAdd(false)}
                  className="rounded-lg border border-white/10 px-3 py-1.5 text-[11px] font-semibold text-white/60 hover:text-white"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  disabled={!owner || busy || duplicateWarning}
                  onClick={submitAdd}
                  className="rounded-lg border border-[#35c7f2]/40 bg-[#35c7f2]/25 px-4 py-1.5 text-[11px] font-bold uppercase text-[#8fe4ff] disabled:opacity-40"
                >
                  Create Lock
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Manage shared modal */}
        {showShared && (
          <div className="absolute inset-0 z-20 flex items-center justify-center bg-black/60 p-4">
            <div
              className="flex max-h-[90%] w-full max-w-[460px] flex-col overflow-hidden rounded-2xl border"
              style={{
                background: "linear-gradient(180deg, rgba(12, 48, 82, 0.98) 0%, rgba(6, 28, 52, 0.99) 100%)",
                borderColor: "rgba(143, 228, 255, 0.25)",
              }}
            >
              <div className="flex items-center justify-between border-b border-white/10 px-4 py-3">
                <div>
                  <p className="text-[12px] font-black uppercase tracking-wider text-white">Shared Access</p>
                  <p className="text-[10px] text-white/45">
                    Owner · {showShared.ownerName} · drawable {showShared.drawable}
                    {showShared.anyTexture ? " / any tex" : ` / ${showShared.texture}`}
                  </p>
                </div>
                <button type="button" onClick={() => setShowShared(null)} className="text-white/50 hover:text-white">
                  <X className="h-4 w-4" />
                </button>
              </div>

              <div className="no-scrollbar min-h-0 flex-1 space-y-3 overflow-y-auto p-4">
                <label className="block">
                  <span className="mb-1 flex items-center gap-1 text-[9px] font-bold uppercase text-white/40">
                    <Briefcase className="h-3 w-3" /> Shared jobs (comma-separated)
                  </span>
                  <input
                    value={sharedJobsDraft}
                    onChange={(e) => setSharedJobsDraft(e.target.value)}
                    placeholder="police, ambulance"
                    className="w-full rounded-lg border border-white/10 bg-black/30 px-2.5 py-2 text-[11px] text-white outline-none placeholder:text-white/25 focus:border-[#35c7f2]/40"
                  />
                </label>

                <div>
                  <span className="text-[9px] font-bold uppercase text-white/40">Currently shared</span>
                  <div className="mt-1.5 space-y-1">
                    {sharedDraft.length === 0 && (
                      <p className="py-2 text-[10px] text-white/35">Nobody else has access.</p>
                    )}
                    {sharedDraft.map((id) => (
                      <div
                        key={id}
                        className="flex items-center justify-between gap-2 rounded-lg border border-white/10 bg-black/20 px-2.5 py-1.5"
                      >
                        <span className="truncate text-[11px] text-white/80">{playerLabel(id)}</span>
                        <button
                          type="button"
                          onClick={() => setSharedDraft(sharedDraft.filter((x) => x !== id))}
                          className="text-red-300/80 hover:text-red-300"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>

                <div>
                  <span className="text-[9px] font-bold uppercase text-white/40">Add players</span>
                  <div className="relative mt-1.5 mb-2">
                    <Search className="pointer-events-none absolute left-2.5 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-white/35" />
                    <input
                      value={sharedSearch}
                      onChange={(e) => setSharedSearch(e.target.value)}
                      placeholder="Search offline to add..."
                      className="w-full rounded-lg border border-white/10 bg-black/30 py-2 pl-8 pr-3 text-[12px] text-white outline-none placeholder:text-white/30 focus:border-[#35c7f2]/40"
                    />
                  </div>
                  <div className="max-h-[140px] space-y-1 overflow-y-auto rounded-lg border border-white/10 bg-black/20 p-1.5">
                    {[...online, ...sharedOffline]
                      .filter(
                        (p, i, arr) =>
                          p.identifier !== showShared.ownerIdentifier &&
                          arr.findIndex((x) => x.identifier === p.identifier) === i
                      )
                      .map((p) => {
                        const on = sharedDraft.includes(p.identifier);
                        return (
                          <button
                            key={p.identifier}
                            type="button"
                            onClick={() => toggleSharedId(p.identifier, sharedDraft, setSharedDraft)}
                            className={cn(
                              "flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left text-[11px] transition",
                              on ? "bg-emerald-500/15 text-emerald-300" : "text-white/60 hover:bg-white/5"
                            )}
                          >
                            <span className="truncate font-semibold">{p.name}</span>
                            {p.online !== false && p.source != null && (
                              <span className="text-[9px] text-white/40">#{p.source}</span>
                            )}
                          </button>
                        );
                      })}
                  </div>
                </div>
              </div>

              <div className="flex justify-end gap-2 border-t border-white/10 px-4 py-3">
                <button
                  type="button"
                  onClick={() => setShowShared(null)}
                  className="rounded-lg border border-white/10 px-3 py-1.5 text-[11px] font-semibold text-white/60 hover:text-white"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  disabled={busy}
                  onClick={saveShared}
                  className="rounded-lg border border-[#35c7f2]/40 bg-[#35c7f2]/25 px-4 py-1.5 text-[11px] font-bold uppercase text-[#8fe4ff] disabled:opacity-40"
                >
                  Save Access
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
