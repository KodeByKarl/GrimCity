import React, { useCallback, useEffect, useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import { ChevronLeft, ChevronRight, Clock3, Trophy, User, X } from "lucide-react";

export interface PlaytimeProduct {
  id: string;
  label: string;
  amount?: number;
  price: number;
  image?: string;
  model?: string;
}

export interface PlaytimeShopData {
  playerName?: string;
  coins?: number;
  totalEarned?: number;
  nextRewardSeconds?: number;
  rewardCoins?: number;
  rewardMinutes?: number;
  items?: PlaytimeProduct[];
  cars?: PlaytimeProduct[];
  pageSize?: number;
}

interface TopEarner {
  rank: number;
  name: string;
  coins: number;
}

type Category = "items" | "cars";

const MOCK: PlaytimeShopData = {
  playerName: "Karl Dev",
  coins: 0,
  nextRewardSeconds: 25 * 60,
  rewardCoins: 5,
  rewardMinutes: 25,
  pageSize: 6,
  items: [
    { id: "bandage", label: "BANDAGE", amount: 5, price: 15, image: "bandage" },
    { id: "lockpick", label: "LOCKPICK", amount: 1, price: 35, image: "lockpick" },
    { id: "armor", label: "ARMOR", amount: 1, price: 80, image: "armour" },
    { id: "repairkit", label: "REPAIR KIT", amount: 1, price: 45, image: "repairkit" },
    { id: "phone", label: "PHONE", amount: 1, price: 60, image: "phone" },
    { id: "radio", label: "RADIO", amount: 1, price: 50, image: "radio" },
    { id: "water", label: "WATER", amount: 5, price: 10, image: "water" },
    { id: "burger", label: "BURGER", amount: 5, price: 12, image: "burger" },
  ],
  cars: [
    { id: "panto", label: "PANTO", price: 250, image: "car" },
    { id: "blista", label: "BLISTA", price: 400, image: "car" },
    { id: "futo", label: "FUTO", price: 550, image: "car" },
    { id: "sultan", label: "SULTAN", price: 900, image: "car" },
    { id: "elegy", label: "ELEGY", price: 1200, image: "car" },
    { id: "buffalo", label: "BUFFALO", price: 1000, image: "car" },
  ],
};

function isBrowser() {
  return (
    !(window as unknown as { invokeNative?: unknown }).invokeNative &&
    !navigator.userAgent.includes("FiveM")
  );
}

async function nui<T>(event: string, data: Record<string, unknown> = {}): Promise<T | null> {
  if (isBrowser()) return null;
  const resourceName = (window as unknown as { GetParentResourceName?: () => string })
    .GetParentResourceName
    ? (window as unknown as { GetParentResourceName: () => string }).GetParentResourceName()
    : "kodebykarl-ui";
  try {
    const res = await fetch(`https://${resourceName}/${event}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(data),
    });
    return (await res.json()) as T;
  } catch {
    return null;
  }
}

function formatTime(totalSeconds: number) {
  const s = Math.max(0, Math.floor(totalSeconds));
  const m = Math.floor(s / 60);
  const r = s % 60;
  return `${m}m ${r.toString().padStart(2, "0")}s`;
}

function CoinIcon({ className }: { className?: string }) {
  return (
    <span
      className={cn(
        "inline-flex h-5 w-5 items-center justify-center rounded-full bg-gradient-to-br from-[#fbbf24] to-[#d97706] text-[11px] font-black text-[#1c1917] shadow-sm",
        className,
      )}
    >
      G
    </span>
  );
}

function itemImageSrc(image?: string) {
  if (!image || image === "car") return null;
  return `nui://ox_inventory/web/images/${image}.png`;
}

export default function PlaytimeShop({
  visible,
  data,
  onClose,
}: {
  visible: boolean;
  data?: PlaytimeShopData | null;
  onClose?: () => void;
}) {
  const [category, setCategory] = useState<Category>("items");
  const [page, setPage] = useState(0);
  const [coins, setCoins] = useState(0);
  const [nextSec, setNextSec] = useState(0);
  const [buying, setBuying] = useState<string | null>(null);
  const [showTop, setShowTop] = useState(false);
  const [top, setTop] = useState<TopEarner[]>([]);
  const [toast, setToast] = useState<string | null>(null);

  const shop = data || (isBrowser() ? MOCK : null);
  const pageSize = shop?.pageSize || 6;
  const rewardCoins = shop?.rewardCoins ?? 5;
  const rewardMinutes = shop?.rewardMinutes ?? 25;

  useEffect(() => {
    if (!visible || !shop) return;
    setCoins(shop.coins ?? 0);
    setNextSec(shop.nextRewardSeconds ?? rewardMinutes * 60);
    setPage(0);
    setCategory("items");
  }, [visible, shop, rewardMinutes]);

  useEffect(() => {
    if (!visible || !data) return;
    if (typeof data.coins === "number") setCoins(data.coins);
    if (typeof data.nextRewardSeconds === "number") setNextSec(data.nextRewardSeconds);
  }, [visible, data?.coins, data?.nextRewardSeconds]);

  useEffect(() => {
    if (!visible) return;
    const id = window.setInterval(() => {
      setNextSec((s) => Math.max(0, s - 1));
    }, 1000);
    return () => window.clearInterval(id);
  }, [visible]);

  useEffect(() => {
    if (!visible) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        void nui("cfx-keydi-playtimeshop:close");
        onClose?.();
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [visible, onClose]);

  const products = useMemo(() => {
    if (!shop) return [];
    return category === "cars" ? shop.cars || [] : shop.items || [];
  }, [shop, category]);

  const totalPages = Math.max(1, Math.ceil(products.length / pageSize));
  const pageSafe = Math.min(page, totalPages - 1);
  const pageItems = products.slice(pageSafe * pageSize, pageSafe * pageSize + pageSize);

  const flash = (msg: string) => {
    setToast(msg);
    window.setTimeout(() => setToast(null), 2200);
  };

  const close = () => {
    void nui("cfx-keydi-playtimeshop:close");
    onClose?.();
  };

  const loadTop = useCallback(async () => {
    if (isBrowser()) {
      setTop([
        { rank: 1, name: "Ace Walker", coins: 420 },
        { rank: 2, name: "Nova Cruz", coins: 310 },
        { rank: 3, name: "Karl Dev", coins: 0 },
      ]);
      return;
    }
    const rows = await nui<TopEarner[]>("cfx-keydi-playtimeshop:top");
    setTop(rows || []);
  }, []);

  const toggleTop = async () => {
    const next = !showTop;
    setShowTop(next);
    if (next) await loadTop();
  };

  const buy = async (product: PlaytimeProduct) => {
    if (buying) return;
    if (coins < product.price) {
      flash("Not enough Grim Coins");
      return;
    }
    setBuying(product.id);

    if (isBrowser()) {
      setCoins((c) => c - product.price);
      flash(`Bought ${product.label} (preview)`);
      setBuying(null);
      return;
    }

    const result = await nui<{ ok: boolean; coins?: number; error?: string; nextRewardSeconds?: number }>(
      "cfx-keydi-playtimeshop:buy",
      { category, id: product.id },
    );
    if (result?.ok) {
      if (typeof result.coins === "number") setCoins(result.coins);
      if (typeof result.nextRewardSeconds === "number") setNextSec(result.nextRewardSeconds);
      flash(`Purchased ${product.label}`);
    } else {
      flash(
        result?.error === "insufficient"
          ? "Not enough Grim Coins"
          : result?.error === "inventory_full"
            ? "Inventory full"
            : "Purchase failed",
      );
    }
    setBuying(null);
  };

  if (!visible || !shop) return null;

  return (
    <div className="fixed inset-0 z-[100050] flex items-center justify-center bg-black/55 p-4 select-none">
      <div
        className="flex h-[min(720px,90vh)] w-[min(1100px,96vw)] overflow-hidden rounded-2xl border border-[#e10600]/70 bg-[#0a0a0a] shadow-[0_30px_80px_rgba(0,0,0,0.65)]"
        style={{ fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif' }}
      >
        {/* Sidebar */}
        <aside className="flex w-[300px] shrink-0 flex-col border-r border-[#e10600]/45 bg-[#0d0d0d] p-5">
          <div className="mb-4 flex flex-col items-center text-center">
            <div className="mb-3 flex h-20 w-20 items-center justify-center rounded-full border-2 border-[#e10600] bg-gradient-to-b from-[#1a0505] to-black shadow-[0_0_24px_rgba(225,6,0,0.35)]">
              <span className="text-[28px] font-black text-[#e10600]">★</span>
            </div>
            <span className="rounded-full bg-[#e10600]/15 px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em] text-[#e10600]">
              Grim City Roleplay
            </span>
            <h1 className="mt-2 text-[26px] font-black tracking-tight text-white">PLAYTIME SHOP</h1>
            <p className="mt-1 text-[12px] leading-snug text-white/45">
              Earn Grim Coins while online and redeem them for items or vehicles.
            </p>
          </div>

          <div className="space-y-2.5">
            <div className="rounded-xl border border-[#e10600]/40 bg-black/40 px-3 py-3">
              <p className="text-[10px] font-bold uppercase tracking-[0.14em] text-white/40">Balance</p>
              <div className="mt-1 flex items-center gap-2">
                <CoinIcon className="h-6 w-6 text-[12px]" />
                <p className="text-[20px] font-black text-white">{coins.toLocaleString()} COIN</p>
              </div>
            </div>

            <div className="rounded-xl border border-[#e10600]/40 bg-black/40 px-3 py-3">
              <p className="text-[10px] font-bold uppercase tracking-[0.14em] text-white/40">Next Reward</p>
              <div className="mt-1 flex items-center justify-between gap-2">
                <div className="flex items-center gap-2 text-white">
                  <Clock3 className="h-4 w-4 text-[#e10600]" />
                  <span className="text-[16px] font-bold tabular-nums">{formatTime(nextSec)}</span>
                </div>
                <span className="text-[13px] font-bold text-[#fbbf24]">+{rewardCoins} COIN</span>
              </div>
              <p className="mt-1 text-[11px] text-white/35">Every {rewardMinutes} minutes online</p>
            </div>

            <div className="rounded-xl border border-[#e10600]/40 bg-black/40 px-3 py-3">
              <p className="text-[10px] font-bold uppercase tracking-[0.14em] text-white/40">Player</p>
              <div className="mt-1 flex items-center gap-2 text-white">
                <User className="h-4 w-4 text-[#e10600]" />
                <span className="truncate text-[15px] font-semibold">{shop.playerName || "Citizen"}</span>
              </div>
            </div>

            <div className="rounded-xl border border-[#e10600]/40 bg-black/40 px-3 py-3">
              <button
                type="button"
                className="flex w-full items-center justify-between gap-2 text-left"
                onClick={() => void toggleTop()}
              >
                <div className="flex items-center gap-2">
                  <Trophy className="h-4 w-4 text-[#fbbf24]" />
                  <span className="text-[13px] font-bold uppercase tracking-wide text-white">
                    Top 10 Earners
                  </span>
                </div>
                <span className="text-[11px] font-semibold text-[#e10600]">
                  {showTop ? "Hide" : "Show"}
                </span>
              </button>
              {showTop ? (
                <div className="mt-2 max-h-[140px] space-y-1.5 overflow-y-auto">
                  {top.length === 0 ? (
                    <p className="py-3 text-center text-[12px] text-white/35">No earners yet</p>
                  ) : (
                    top.map((t) => (
                      <div
                        key={`${t.rank}-${t.name}`}
                        className="flex items-center justify-between gap-2 rounded-lg bg-white/5 px-2 py-1.5 text-[12px]"
                      >
                        <span className="font-semibold text-white/80">
                          #{t.rank} {t.name}
                        </span>
                        <span className="flex items-center gap-1 font-bold text-[#fbbf24]">
                          <CoinIcon className="h-3.5 w-3.5 text-[9px]" />
                          {t.coins}
                        </span>
                      </div>
                    ))
                  )}
                </div>
              ) : (
                <div className="mt-2 h-2 overflow-hidden rounded-full bg-white/10">
                  <div className="h-full w-1/3 rounded-full bg-[#e10600]/70" />
                </div>
              )}
            </div>
          </div>

          <p className="mt-auto pt-4 text-center text-[10px] text-white/25">Powered by KodeByKarl.Net</p>
        </aside>

        {/* Catalog */}
        <main className="flex min-w-0 flex-1 flex-col bg-[#0a0a0a] p-5">
          <div className="mb-4 flex flex-wrap items-start justify-between gap-3">
            <div>
              <h2 className="text-[22px] font-black uppercase tracking-wide text-[#e10600]">
                {category === "cars" ? "Car Catalog" : "Item Catalog"}
              </h2>
              <p className="text-[12px] text-white/40">
                Spend Grim Coins earned every {rewardMinutes} minutes online.
              </p>
            </div>
            <div className="flex items-center gap-2">
              <button
                type="button"
                className={cn(
                  "rounded-full px-4 py-1.5 text-[12px] font-bold uppercase tracking-wide",
                  category === "items"
                    ? "bg-[#e10600] text-white"
                    : "border border-[#e10600]/60 bg-transparent text-white/70",
                )}
                onClick={() => {
                  setCategory("items");
                  setPage(0);
                }}
              >
                Items
              </button>
              <button
                type="button"
                className={cn(
                  "rounded-full px-4 py-1.5 text-[12px] font-bold uppercase tracking-wide",
                  category === "cars"
                    ? "bg-[#e10600] text-white"
                    : "border border-[#e10600]/60 bg-transparent text-white/70",
                )}
                onClick={() => {
                  setCategory("cars");
                  setPage(0);
                }}
              >
                Cars
              </button>
              <button
                type="button"
                className="ml-1 flex items-center gap-1 rounded-lg border border-[#e10600]/50 px-2.5 py-1.5 text-[12px] font-bold text-white/80"
                onClick={close}
              >
                Esc
                <X className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>

          <div className="grid min-h-0 flex-1 grid-cols-3 gap-3 content-start">
            {pageItems.map((p) => {
              const src = itemImageSrc(p.image);
              return (
                <div
                  key={p.id}
                  className="flex flex-col rounded-xl border border-[#e10600]/45 bg-[#121212] p-3 shadow-md"
                >
                  <div className="mb-2 flex items-start justify-between gap-2">
                    <p className="text-[13px] font-bold uppercase tracking-wide text-white">{p.label}</p>
                    <span className="rounded-md bg-[#e10600]/20 px-1.5 py-0.5 text-[10px] font-bold text-[#e10600]">
                      {category === "cars" ? "1x" : `${p.amount || 1}x`}
                    </span>
                  </div>
                  <div className="mb-3 flex h-[100px] items-center justify-center rounded-lg bg-black/40">
                    {src ? (
                      <img
                        src={src}
                        alt=""
                        className="max-h-[88px] max-w-[88px] object-contain"
                        onError={(e) => {
                          (e.currentTarget as HTMLImageElement).style.display = "none";
                        }}
                      />
                    ) : (
                      <span className="text-[13px] font-bold tracking-widest text-white/25">VEHICLE</span>
                    )}
                  </div>
                  <div className="mt-auto flex items-center justify-between gap-2 border-t border-white/8 pt-2.5">
                    <div className="flex items-center gap-1.5 font-bold text-white">
                      <CoinIcon />
                      <span className="text-[14px]">{p.price}</span>
                    </div>
                    <button
                      type="button"
                      disabled={buying === p.id}
                      className="rounded-md bg-[#e10600] px-3 py-1.5 text-[11px] font-black uppercase tracking-wide text-white transition-colors hover:bg-[#ff1a1a] disabled:opacity-50"
                      onClick={() => void buy(p)}
                    >
                      {buying === p.id ? "…" : "Buy"}
                    </button>
                  </div>
                </div>
              );
            })}
          </div>

          <div className="mt-4 flex items-center justify-between gap-3">
            <button
              type="button"
              disabled={pageSafe <= 0}
              className="flex items-center gap-1 rounded-lg border border-[#e10600]/50 px-3 py-1.5 text-[12px] font-bold uppercase text-white/80 disabled:opacity-30"
              onClick={() => setPage((p) => Math.max(0, p - 1))}
            >
              <ChevronLeft className="h-4 w-4" />
              Prev
            </button>
            <p className="text-[13px] font-bold text-white/70">
              <span className="text-[#e10600]">{pageSafe + 1}</span> / {totalPages}
            </p>
            <button
              type="button"
              disabled={pageSafe >= totalPages - 1}
              className="flex items-center gap-1 rounded-lg border border-[#e10600]/50 px-3 py-1.5 text-[12px] font-bold uppercase text-white/80 disabled:opacity-30"
              onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
            >
              Next
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        </main>
      </div>

      {toast ? (
        <div className="pointer-events-none absolute bottom-8 left-1/2 z-[100060] -translate-x-1/2 rounded-full bg-[#e10600] px-4 py-2 text-[13px] font-semibold text-white shadow-lg">
          {toast}
        </div>
      ) : null}
    </div>
  );
}
