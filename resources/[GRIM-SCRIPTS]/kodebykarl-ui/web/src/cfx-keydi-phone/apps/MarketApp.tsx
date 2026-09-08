import React, { useEffect, useState } from "react";
import { Package, RefreshCw } from "lucide-react";
import { AppChrome, formatMoney } from "./shared";

interface MarketRow {
  item: string;
  label: string;
  category: string;
  price: number;
  image?: string;
}

interface Catalog {
  items?: MarketRow[];
  nextUpdateAt?: number;
}

function isBrowser() {
  return (
    !(window as unknown as { invokeNative?: unknown }).invokeNative &&
    !navigator.userAgent.includes("FiveM")
  );
}

async function nui<T>(event: string, data: Record<string, unknown> = {}): Promise<T | null> {
  if (isBrowser()) {
    return {
      items: [
        { item: "orange", label: "Orange", category: "Farming", price: 55 },
        { item: "wood", label: "Wood", category: "Lumber", price: 60 },
        { item: "raw_meat", label: "Raw Meat", category: "Hunting", price: 75 },
      ],
      nextUpdateAt: Math.floor(Date.now() / 1000) + 3600,
    } as T;
  }
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

function ItemThumb({ item, label, image }: { item: string; label: string; image?: string }) {
  const [failed, setFailed] = useState(false);
  const src = image || `nui://ox_inventory/web/images/${item}.png`;
  if (failed) {
    return <Package className="h-7 w-7 text-[#c99212]" />;
  }
  return (
    <img
      src={src}
      alt={label}
      className="h-9 w-9 object-contain"
      onError={() => setFailed(true)}
      draggable={false}
    />
  );
}

export default function MarketApp() {
  const [rows, setRows] = useState<MarketRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [nextUpdateAt, setNextUpdateAt] = useState(0);

  const load = async () => {
    setLoading(true);
    const catalog = await nui<Catalog>("cfx-keydi-phone:market:catalog");
    setRows(catalog?.items || []);
    setNextUpdateAt(Number(catalog?.nextUpdateAt) || 0);
    setLoading(false);
  };

  useEffect(() => {
    void load();
  }, []);

  const countdown = (() => {
    if (!nextUpdateAt) return "Live";
    const remaining = Math.max(0, Math.floor(nextUpdateAt - Date.now() / 1000));
    const h = Math.floor(remaining / 3600);
    const m = Math.floor((remaining % 3600) / 60);
    if (h > 0) return `${h}h ${m}m`;
    if (m > 0) return `${m}m`;
    return `${remaining}s`;
  })();

  return (
    <AppChrome title="Market">
      <div className="space-y-3 p-4">
        <div className="flex items-center justify-between rounded-[16px] bg-white px-3.5 py-2.5 shadow-sm">
          <div>
            <p className="text-[11px] font-semibold uppercase tracking-wider text-[#8e8e93]">
              Next price roll
            </p>
            <p className="text-[15px] font-semibold text-[#1c1c1e]">{countdown}</p>
          </div>
          <button
            type="button"
            onClick={() => void load()}
            className="flex h-9 w-9 items-center justify-center rounded-full bg-[#f2f2f7] text-[#1c1c1e] transition active:scale-95"
            title="Refresh"
          >
            <RefreshCw className={`h-4 w-4 ${loading ? "animate-spin" : ""}`} />
          </button>
        </div>

        {loading && rows.length === 0 ? (
          <p className="py-10 text-center text-[13px] text-[#8e8e93]">Loading prices…</p>
        ) : rows.length === 0 ? (
          <p className="py-10 text-center text-[13px] text-[#8e8e93]">No listings.</p>
        ) : (
          <div className="space-y-2">
            {rows.map((row) => (
              <div
                key={row.item}
                className="flex items-center gap-3 rounded-[18px] bg-white px-3 py-3 shadow-sm"
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-[14px] bg-[#f2f2f7]">
                  <ItemThumb item={row.item} label={row.label} image={row.image} />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-[15px] font-semibold text-[#1c1c1e]">{row.label}</p>
                  <p className="text-[11px] font-medium uppercase tracking-wider text-[#8e8e93]">
                    {row.category}
                  </p>
                </div>
                <p className="text-[16px] font-semibold tabular-nums text-[#c99212]">
                  {formatMoney(row.price)}
                </p>
              </div>
            ))}
          </div>
        )}

        <p className="px-1 text-center text-[11px] leading-relaxed text-[#8e8e93]">
          View only. Sell orange, wood, and raw meat at the Sell Market NPC.
        </p>
      </div>
    </AppChrome>
  );
}
