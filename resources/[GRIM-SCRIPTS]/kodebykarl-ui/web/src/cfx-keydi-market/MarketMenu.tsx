import React, { useEffect, useMemo, useState } from "react";
import {
  Search,
  X,
  Banknote,
  CreditCard,
  ShoppingCart,
  Minus,
  Plus,
  Trash2,
  DollarSign,
  Package,
} from "lucide-react";
import pandoraLogo from "@/assets/pandora-city-logo.png";

export interface MarketItem {
  item: string;
  label: string;
  category: string;
  price: number;
  count: number;
  image?: string;
}

export interface MarketData {
  items?: MarketItem[];
}

export interface MarketMenuProps {
  visible?: boolean;
  data?: MarketData;
  onClose?: () => void;
}

interface CartEntry {
  item: string;
  label: string;
  price: number;
  amount: number;
  max: number;
  image?: string;
}

const fetchNui = async (eventName: string, data?: any) => {
  try {
    const resourceName = (window as any).GetParentResourceName
      ? (window as any).GetParentResourceName()
      : "cfx-keydi-ui";
    const response = await fetch(`https://${resourceName}/${eventName}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(data || {}),
    });
    return await response.json();
  } catch {
    return null;
  }
};

const formatMoney = (n: number) =>
  `$${Math.max(0, Math.floor(n || 0)).toLocaleString()}`;

export const MarketMenu: React.FC<MarketMenuProps> = ({
  visible = true,
  data,
  onClose,
}) => {
  const [items, setItems] = useState<MarketItem[]>([]);
  const [selectedCategory, setSelectedCategory] = useState("all");
  const [searchQuery, setSearchQuery] = useState("");
  const [cart, setCart] = useState<CartEntry[]>([]);
  const [failedImages, setFailedImages] = useState<Record<string, boolean>>({});

  useEffect(() => {
    if (!visible) return;
    setItems(data?.items || []);
    setSelectedCategory("all");
    setSearchQuery("");
    setCart([]);
    setFailedImages({});
  }, [visible, data]);

  const categories = useMemo(() => {
    const set = new Set(items.map((i) => i.category || "general"));
    return ["all", ...Array.from(set)];
  }, [items]);

  const filtered = useMemo(() => {
    const q = searchQuery.trim().toLowerCase();
    return items.filter((i) => {
      const catOk =
        selectedCategory === "all" || i.category === selectedCategory;
      const searchOk =
        !q ||
        i.label.toLowerCase().includes(q) ||
        i.item.toLowerCase().includes(q);
      return catOk && searchOk;
    });
  }, [items, selectedCategory, searchQuery]);

  const cartTotal = useMemo(
    () => cart.reduce((sum, row) => sum + row.price * row.amount, 0),
    [cart]
  );

  const handleClose = () => {
    fetchNui("cfx-keydi-market:close");
    if (onClose) onClose();
  };

  const addToCart = (entry: MarketItem) => {
    if ((entry.count || 0) < 1) return;
    setCart((prev) => {
      const existing = prev.find((c) => c.item === entry.item);
      if (existing) {
        if (existing.amount >= entry.count) return prev;
        return prev.map((c) =>
          c.item === entry.item
            ? {
                ...c,
                amount: Math.min(entry.count, c.amount + 1),
                max: entry.count,
              }
            : c
        );
      }
      return [
        ...prev,
        {
          item: entry.item,
          label: entry.label,
          price: entry.price,
          amount: 1,
          max: entry.count,
          image: entry.image,
        },
      ];
    });
  };

  const setCartAmount = (item: string, amount: number) => {
    setCart((prev) =>
      prev
        .map((c) => {
          if (c.item !== item) return c;
          const next = Math.max(0, Math.min(c.max, Math.floor(amount)));
          return { ...c, amount: next };
        })
        .filter((c) => c.amount > 0)
    );
  };

  const removeFromCart = (item: string) => {
    setCart((prev) => prev.filter((c) => c.item !== item));
  };

  const sellAllOwned = (entry: MarketItem) => {
    if ((entry.count || 0) < 1) return;
    setCart((prev) => {
      const without = prev.filter((c) => c.item !== entry.item);
      return [
        ...without,
        {
          item: entry.item,
          label: entry.label,
          price: entry.price,
          amount: entry.count,
          max: entry.count,
          image: entry.image,
        },
      ];
    });
  };

  const handleCheckout = (payout: "cash" | "bank") => {
    if (cart.length < 1 || cartTotal < 1) return;
    fetchNui("cfx-keydi-market:sell", {
      cart: cart.map((c) => ({ item: c.item, amount: c.amount })),
      payout,
    });
    setCart([]);
  };

  if (!visible) return null;

  return (
    <div className="pandora fixed inset-0 z-50 flex items-center justify-center bg-[#030d1a]/85 backdrop-blur-md p-4 font-sans select-none text-white animate-in fade-in duration-300">
      <div className="w-full max-w-[1100px] h-[85vh] max-h-[720px] bg-[#05192f] border border-[rgba(255,122,181,0.35)] rounded-3xl overflow-hidden shadow-[0_20px_60px_rgba(0,0,0,0.9),0_0_50px_rgba(255,61,150,0.2)] relative flex flex-col">
        <div className="absolute top-0 right-0 w-96 h-96 rounded-full bg-[#ff3d96]/15 blur-3xl pointer-events-none" />
        <div className="absolute bottom-0 left-0 w-96 h-96 rounded-full bg-[#35c7f2]/15 blur-3xl pointer-events-none" />

        {/* HEADER */}
        <div className="p-6 pb-4 border-b border-[rgba(255,122,181,0.25)] relative z-10 flex items-center justify-between">
          <div className="flex items-center gap-3.5">
            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#ff3d96] via-[#d3106f] to-[#0a2743] p-0.5 shadow-lg shadow-[#ff3d96]/30 border border-[#ff7ab5]/50 flex items-center justify-center shrink-0">
              <img
                src={pandoraLogo}
                alt="Pandora Logo"
                className="w-8 h-8 object-contain drop-shadow"
              />
            </div>
            <div>
              <div className="text-[10px] font-black uppercase tracking-[0.2em] text-[#35c7f2]">
                PANDORA CITY • SELL MARKET
              </div>
              <h1 className="text-xl font-black tracking-tight bg-gradient-to-r from-[#ff3d96] via-[#8fe4ff] to-[#ffd24c] bg-clip-text text-transparent">
                Market Place
              </h1>
            </div>
          </div>

          <button
            onClick={handleClose}
            className="p-2.5 rounded-xl bg-[#0a2743] hover:bg-[#0f3a68] border border-[rgba(255,122,181,0.3)] text-[#cfe7ff] hover:text-white transition-all cursor-pointer shadow-md"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* FILTERS */}
        <div className="p-4 px-6 border-b border-[rgba(255,122,181,0.15)] bg-[#071d33]/60 relative z-10 flex flex-wrap items-center justify-between gap-3">
          <div className="flex items-center gap-1.5 overflow-x-auto custom-scrollbar pb-1 max-w-full">
            {categories.map((cat) => (
              <button
                key={cat}
                onClick={() => setSelectedCategory(cat)}
                className={`px-3.5 py-1.5 rounded-xl text-xs font-black uppercase tracking-wider transition-all cursor-pointer capitalize shrink-0 ${
                  selectedCategory === cat
                    ? "bg-gradient-to-r from-[#ff3d96] to-[#35c7f2] text-white shadow-[0_0_15px_rgba(255,61,150,0.4)]"
                    : "bg-[#0a2743]/80 hover:bg-[#0f3a68] text-[#9cc3e6] border border-[rgba(255,122,181,0.2)]"
                }`}
              >
                {cat}
              </button>
            ))}
          </div>

          <div className="relative flex items-center w-full sm:w-64">
            <Search className="w-4 h-4 text-[#35c7f2] absolute left-3 pointer-events-none" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search items..."
              className="w-full pl-9 pr-3 py-1.5 rounded-xl bg-[#0a2743]/90 border border-[rgba(255,122,181,0.25)] text-xs text-white placeholder-[#9cc3e6]/40 focus:outline-none focus:border-[#ff3d96]"
            />
          </div>
        </div>

        {/* BODY */}
        <div className="flex-1 min-h-0 flex relative z-10">
          <div className="flex-1 overflow-y-auto custom-scrollbar p-5">
            {filtered.length === 0 ? (
              <div className="h-full min-h-[280px] flex flex-col items-center justify-center text-center p-8">
                <Package className="w-12 h-12 text-[#35c7f2]/40 mb-2" />
                <div className="text-sm font-bold text-white">No items found</div>
                <div className="text-xs text-[#9cc3e6]/60">
                  Grind autofarm or raven — then sell here.
                </div>
              </div>
            ) : (
              <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                {filtered.map((entry) => {
                  const owned = entry.count || 0;
                  const disabled = owned < 1;
                  return (
                    <div
                      key={entry.item}
                      className={`bg-[#071d33] border border-[rgba(255,122,181,0.25)] rounded-2xl p-4 flex flex-col justify-between transition-all ${
                        disabled
                          ? "opacity-45"
                          : "hover:border-[#ff3d96]/60 hover:shadow-[0_10px_25px_rgba(0,0,0,0.5),0_0_20px_rgba(255,61,150,0.2)]"
                      }`}
                    >
                      <div className="flex items-start justify-between gap-2 mb-2">
                        <h3 className="text-sm font-black text-white leading-tight line-clamp-2">
                          {entry.label}
                        </h3>
                        <span className="text-xs font-mono font-bold text-[#9cc3e6] shrink-0">
                          {owned}x
                        </span>
                      </div>

                      <div className="h-28 flex items-center justify-center mb-2 relative">
                        {!failedImages[entry.item] && entry.image ? (
                          <img
                            src={entry.image}
                            alt={entry.label}
                            className="max-h-24 max-w-[85%] object-contain drop-shadow-lg"
                            onError={() =>
                              setFailedImages((prev) => ({
                                ...prev,
                                [entry.item]: true,
                              }))
                            }
                          />
                        ) : (
                          <Package className="w-10 h-10 text-[#35c7f2]/35" />
                        )}
                      </div>

                      <div>
                        <div className="flex items-center gap-1 text-xs mb-3">
                          <span className="font-mono font-black text-[#35c7f2]">
                            {formatMoney(entry.price)}
                          </span>
                          <span className="text-[10px] text-[#9cc3e6]/60 font-bold uppercase">
                            / each
                          </span>
                        </div>

                        <div className="flex items-center gap-2">
                          <button
                            type="button"
                            disabled={disabled}
                            onClick={() => sellAllOwned(entry)}
                            className="px-2.5 py-2 rounded-xl text-[10px] font-black uppercase tracking-wider bg-[#0a2743] border border-[rgba(255,122,181,0.25)] text-[#9cc3e6] hover:text-white disabled:cursor-not-allowed cursor-pointer"
                          >
                            All
                          </button>
                          <button
                            type="button"
                            disabled={disabled}
                            onClick={() => addToCart(entry)}
                            className="flex-1 py-2 rounded-xl bg-gradient-to-r from-[#ff3d96] to-[#35c7f2] hover:brightness-110 text-xs font-black uppercase tracking-wider text-white shadow-[0_0_15px_rgba(255,61,150,0.3)] transition-all cursor-pointer disabled:cursor-not-allowed disabled:opacity-50 flex items-center justify-center gap-1"
                          >
                            <DollarSign className="w-3.5 h-3.5" />
                            Sell
                          </button>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* CART */}
          <div className="w-[300px] shrink-0 border-l border-[rgba(255,122,181,0.2)] bg-[#041525]/80 flex flex-col">
            <div className="px-5 py-4 border-b border-[rgba(255,122,181,0.2)] flex items-center gap-2">
              <ShoppingCart className="w-4 h-4 text-[#35c7f2]" />
              <h2 className="text-sm font-black text-white">Your Shopping Cart</h2>
            </div>

            <div className="flex-1 overflow-y-auto custom-scrollbar px-4 py-3 space-y-2.5">
              {cart.length === 0 ? (
                <div className="h-full min-h-[160px] flex flex-col items-center justify-center text-center text-[#9cc3e6]/50 px-4">
                  <ShoppingCart className="w-8 h-8 mb-2 opacity-40" />
                  <div className="text-xs font-bold text-[#9cc3e6]/70">
                    Cart is empty
                  </div>
                  <div className="text-[11px] mt-1">
                    Click Sell on items you want to cash out.
                  </div>
                </div>
              ) : (
                cart.map((row) => (
                  <div
                    key={row.item}
                    className="bg-[#071d33] border border-[rgba(255,122,181,0.25)] rounded-2xl p-3"
                  >
                    <div className="flex items-start justify-between gap-2 mb-2">
                      <div className="min-w-0">
                        <div className="text-xs font-black text-white truncate">
                          {row.label}
                        </div>
                        <div className="text-[11px] font-mono text-[#35c7f2]">
                          {formatMoney(row.price)} each
                        </div>
                      </div>
                      <button
                        type="button"
                        onClick={() => removeFromCart(row.item)}
                        className="p-1 rounded-md text-[#9cc3e6] hover:text-[#ff3d96] cursor-pointer"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-1.5 bg-[#0a2743]/90 rounded-xl border border-[rgba(255,122,181,0.25)] p-0.5">
                        <button
                          type="button"
                          onClick={() => setCartAmount(row.item, row.amount - 1)}
                          className="w-7 h-7 rounded-lg hover:bg-[#0f3a68] flex items-center justify-center cursor-pointer"
                        >
                          <Minus className="w-3.5 h-3.5" />
                        </button>
                        <span className="w-8 text-center text-xs font-mono font-black">
                          {row.amount}
                        </span>
                        <button
                          type="button"
                          onClick={() => setCartAmount(row.item, row.amount + 1)}
                          className="w-7 h-7 rounded-lg hover:bg-[#0f3a68] flex items-center justify-center cursor-pointer"
                        >
                          <Plus className="w-3.5 h-3.5" />
                        </button>
                      </div>
                      <div className="text-sm font-mono font-black text-[#ffd24c]">
                        {formatMoney(row.price * row.amount)}
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>

            <div className="p-4 border-t border-[rgba(255,122,181,0.2)] space-y-3 shrink-0">
              <div className="flex items-center justify-between p-3.5 rounded-2xl bg-[#0a2743]/80 border border-[rgba(255,122,181,0.25)]">
                <span className="text-xs font-bold text-[#9cc3e6]">
                  Total Amount
                </span>
                <span className="text-xl font-mono font-black text-[#ffd24c]">
                  {formatMoney(cartTotal)}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  disabled={cart.length < 1}
                  onClick={() => handleCheckout("cash")}
                  className="py-2.5 rounded-2xl border text-xs font-black uppercase tracking-wider flex items-center justify-center gap-1.5 transition-all cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed bg-gradient-to-r from-[#ff3d96] to-[#d3106f] text-white border-[#ff7ab5]"
                >
                  <Banknote className="w-4 h-4" />
                  Cash
                </button>
                <button
                  type="button"
                  disabled={cart.length < 1}
                  onClick={() => handleCheckout("bank")}
                  className="py-2.5 rounded-2xl border text-xs font-black uppercase tracking-wider flex items-center justify-center gap-1.5 transition-all cursor-pointer disabled:opacity-40 disabled:cursor-not-allowed bg-gradient-to-r from-[#35c7f2] to-[#0f3a68] text-white border-[#8fe4ff]"
                >
                  <CreditCard className="w-4 h-4" />
                  Card
                </button>
              </div>
              <div className="text-[10px] text-center text-[#9cc3e6]/50">
                Cash = pocket · Card = bank deposit
              </div>
            </div>
          </div>
        </div>

        <div className="p-3 border-t border-[rgba(255,122,181,0.15)] bg-[#030d1a]/60 flex items-center justify-between text-[11px] text-[#9cc3e6]/50 font-mono relative z-10 px-6">
          <div>{filtered.length} Listings Available</div>
          <div className="flex items-center gap-1">
            <div className="w-3 h-3 rounded-full bg-[#ff3d96]/20 border border-[#ff7ab5]/40 flex items-center justify-center text-[9px] font-bold text-[#ff3d96]">
              p
            </div>
            <span>keydi,net</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default MarketMenu;
