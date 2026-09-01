import { useEffect, useMemo, useState, useRef } from "react";
import { 
  Image, 
  Plus, 
  Search, 
  Trash2, 
  UserPlus, 
  Users, 
  Volume2, 
  VolumeX, 
  X, 
  Edit3, 
  Play, 
  Square, 
  Clock, 
  Sparkles,
  Maximize2,
  CheckCircle2,
  AlertCircle
} from "lucide-react";
import { cn } from "@/lib/utils";

export interface WelcomeBannerPlayer {
  identifier: string;
  name?: string;
  gif?: string;
  sound?: string;
  volume?: number;
  width?: number;
  height?: number;
  duration?: number;
  addedBy?: string;
  addedAt?: string;
}

export interface WelcomeBannerOnlinePlayer {
  id: number;
  name: string;
  identifier: string;
}

export interface WelcomeBannerPanelData {
  staffName?: string;
  staffGroup?: string;
  players?: WelcomeBannerPlayer[];
  online?: WelcomeBannerOnlinePlayer[];
  duration?: number;
}

interface WelcomeBannerPanelProps {
  data?: WelcomeBannerPanelData | null;
  onClose: () => void;
}

function getResourceName() {
  return (window as Window & { GetParentResourceName?: () => string }).GetParentResourceName
    ? (window as Window & { GetParentResourceName: () => string }).GetParentResourceName()
    : "cfx-keydi-ui";
}

async function fetchNui<T = unknown>(event: string, payload?: unknown): Promise<T | undefined> {
  try {
    const resp = await fetch(`https://${getResourceName()}/${event}`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify(payload ?? {}),
    });
    return await resp.json();
  } catch {
    return undefined;
  }
}

export default function WelcomeBannerPanel({ data, onClose }: WelcomeBannerPanelProps) {
  const [players, setPlayers] = useState<WelcomeBannerPlayer[]>(data?.players ?? []);
  const [online, setOnline] = useState<WelcomeBannerOnlinePlayer[]>(data?.online ?? []);
  const [search, setSearch] = useState("");
  const [showDrawer, setShowDrawer] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [busy, setBusy] = useState(false);

  // Form Fields
  const [identifier, setIdentifier] = useState("");
  const [name, setName] = useState("");
  const [gif, setGif] = useState("");
  const [sound, setSound] = useState("");
  const [volume, setVolume] = useState(0.6);
  const [duration, setDuration] = useState<number>(8);
  const [width, setWidth] = useState<string>("");
  const [height, setHeight] = useState<string>("");

  // Audio Preview state
  const [isPlayingAudio, setIsPlayingAudio] = useState(false);
  const audioPreviewRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    setPlayers(data?.players ?? []);
    setOnline(data?.online ?? []);
  }, [data]);

  useEffect(() => {
    const onMessage = (event: MessageEvent) => {
      const msg = event.data;
      if (!msg) return;
      if (msg.action === "cfx-keydi-welcomebanner:panel:update" && msg.data) {
        if (msg.data.players) setPlayers(msg.data.players);
        if (msg.data.online) setOnline(msg.data.online);
      }
    };
    window.addEventListener("message", onMessage);
    return () => window.removeEventListener("message", onMessage);
  }, []);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        stopAudioPreview();
        if (showDrawer) {
          setShowDrawer(false);
          setIsEditing(false);
        } else {
          onClose();
        }
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [onClose, showDrawer]);

  const stopAudioPreview = () => {
    if (audioPreviewRef.current) {
      audioPreviewRef.current.pause();
      audioPreviewRef.current.currentTime = 0;
      audioPreviewRef.current = null;
    }
    setIsPlayingAudio(false);
  };

  const togglePlayAudio = (soundUrl: string, vol: number) => {
    if (isPlayingAudio) {
      stopAudioPreview();
      return;
    }

    if (!soundUrl || !soundUrl.trim()) return;

    try {
      const audio = new Audio(soundUrl.trim());
      audio.volume = Math.max(0, Math.min(1, vol));
      audioPreviewRef.current = audio;
      audio.play().then(() => {
        setIsPlayingAudio(true);
      }).catch(() => {
        setIsPlayingAudio(false);
      });
      audio.onended = () => {
        setIsPlayingAudio(false);
        audioPreviewRef.current = null;
      };
    } catch {
      setIsPlayingAudio(false);
    }
  };

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return players;
    return players.filter((player) =>
      [player.name, player.identifier, player.gif, player.sound]
        .filter(Boolean)
        .some((value) => String(value).toLowerCase().includes(q))
    );
  }, [players, search]);

  const resetForm = () => {
    setIdentifier("");
    setName("");
    setGif("");
    setSound("");
    setVolume(0.6);
    setDuration(8);
    setWidth("");
    setHeight("");
    setIsEditing(false);
    stopAudioPreview();
  };

  const openAddForm = () => {
    resetForm();
    setShowDrawer(true);
  };

  const openEditForm = (player: WelcomeBannerPlayer) => {
    stopAudioPreview();
    setIdentifier(player.identifier);
    setName(player.name || "");
    setGif(player.gif || "");
    setSound(player.sound || "");
    setVolume(player.volume ?? 0.6);
    setDuration(player.duration ?? 8);
    setWidth(player.width ? String(player.width) : "");
    setHeight(player.height ? String(player.height) : "");
    setIsEditing(true);
    setShowDrawer(true);
  };

  const pickOnline = (player: WelcomeBannerOnlinePlayer) => {
    setIdentifier(player.identifier);
    setName(player.name);
  };

  const savePlayerBanner = async () => {
    if (busy || !identifier.trim() || !gif.trim()) return;
    setBusy(true);
    stopAudioPreview();

    const payload: any = {
      identifier: identifier.trim(),
      name: name.trim(),
      gif: gif.trim(),
      sound: sound.trim(),
      volume: volume,
      duration: Number(duration) || 8,
    };

    if (width.trim() && !isNaN(Number(width))) {
      payload.width = Number(width);
    }
    if (height.trim() && !isNaN(Number(height))) {
      payload.height = Number(height);
    }

    await fetchNui("cfx-keydi-welcomebanner:add", payload);
    setBusy(false);
    setShowDrawer(false);
    resetForm();
  };

  const removePlayer = async (player: WelcomeBannerPlayer) => {
    if (busy) return;
    setBusy(true);
    stopAudioPreview();
    await fetchNui("cfx-keydi-welcomebanner:remove", { identifier: player.identifier });
    setBusy(false);
  };

  return (
    <div className="pandora fixed inset-0 z-[99950] flex items-center justify-center bg-black/75 backdrop-blur-md p-4 font-sans select-none">
      <div className="relative flex h-[620px] w-full max-w-5xl flex-col overflow-hidden rounded-3xl border border-slate-700/80 bg-[#090d18] shadow-2xl ring-1 ring-white/10">
        
        {/* Top Header */}
        <div className="flex items-center justify-between border-b border-slate-800 bg-[#0c1222] px-6 py-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-cyan-600/20 border border-cyan-500/40 text-cyan-400">
              <Sparkles className="h-5 w-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-[10px] font-black uppercase tracking-[0.2em] text-cyan-400 bg-cyan-950/60 px-2 py-0.5 rounded border border-cyan-500/30">
                  {data?.staffGroup || "Staff Management"}
                </span>
                <span className="text-xs text-slate-400">• {data?.staffName || "Admin"}</span>
              </div>
              <h2 className="text-base font-black text-white tracking-wide">
                Custom Welcome Banner System
              </h2>
            </div>
          </div>

          <div className="flex items-center gap-2.5">
            <button
              type="button"
              onClick={openAddForm}
              className="flex items-center gap-1.5 rounded-xl border border-cyan-500/40 bg-cyan-600/20 hover:bg-cyan-600 px-3.5 py-2 text-xs font-bold text-cyan-200 hover:text-white transition-all shadow-md active:scale-95"
            >
              <Plus className="h-4 w-4" />
              Add Player Banner
            </button>
            <button
              type="button"
              onClick={onClose}
              className="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-700 bg-slate-800/80 text-slate-400 hover:text-white hover:bg-slate-700 transition-colors"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        </div>

        {/* Search Bar */}
        <div className="border-b border-slate-800 bg-[#090d18] px-6 py-2.5">
          <div className="flex items-center gap-2.5 rounded-xl border border-slate-800 bg-slate-900/90 px-3.5 py-1.5 shadow-inner">
            <Search className="h-4 w-4 text-slate-400 shrink-0" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by Player Name, License Identifier, GIF/Image URL, or Sound..."
              className="w-full bg-transparent text-xs text-white outline-none placeholder:text-slate-500"
            />
            {search && (
              <button onClick={() => setSearch("")} className="text-slate-500 hover:text-white text-xs">
                Clear
              </button>
            )}
          </div>
        </div>

        {/* Main Content Area */}
        <div className="flex min-h-0 flex-1 overflow-hidden">
          {/* Left / Center: Player Cards List */}
          <div className="no-scrollbar flex-1 space-y-2.5 overflow-y-auto p-5">
            {filtered.length === 0 ? (
              <div className="flex h-full flex-col items-center justify-center gap-3 text-slate-500 py-12">
                <Users className="h-12 w-12 stroke-1 opacity-40 text-cyan-400" />
                <div className="text-center">
                  <p className="text-sm font-bold text-slate-300">No Custom Banner Players Found</p>
                  <p className="text-xs text-slate-500 mt-0.5">Click "Add Player Banner" to assign custom GIF & sound to any citizen or VIP.</p>
                </div>
              </div>
            ) : (
              filtered.map((player) => (
                <div
                  key={player.identifier}
                  className="flex items-center gap-4 rounded-2xl border border-slate-800 bg-[#0e1424] hover:border-slate-700/80 p-3.5 transition-all shadow-md group"
                >
                  {/* Banner Thumbnail Preview */}
                  <div className="relative h-16 w-28 shrink-0 overflow-hidden rounded-xl border border-slate-700 bg-black/60 shadow-md">
                    {player.gif ? (
                      <img src={player.gif} alt="" className="h-full w-full object-cover" />
                    ) : (
                      <div className="flex h-full items-center justify-center text-slate-600">
                        <Image className="h-5 w-5" />
                      </div>
                    )}
                  </div>

                  {/* Player Information & Details */}
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <h4 className="truncate text-sm font-bold text-white">
                        {player.name || "Unnamed Player"}
                      </h4>
                      <span className="px-2 py-0.5 rounded-full text-[9px] font-mono font-bold bg-cyan-950 text-cyan-300 border border-cyan-500/30">
                        Vol: {Math.round((player.volume ?? 0.6) * 100)}%
                      </span>
                      {player.duration && (
                        <span className="px-2 py-0.5 rounded-full text-[9px] font-mono font-bold bg-slate-800 text-slate-300 border border-slate-700">
                          {player.duration}s
                        </span>
                      )}
                    </div>

                    <p className="truncate font-mono text-[11px] text-slate-400 mt-0.5">
                      {player.identifier}
                    </p>

                    <div className="flex items-center gap-3 text-[11px] text-slate-400 mt-1">
                      {player.sound ? (
                        <span className="flex items-center gap-1 text-cyan-300/90 font-mono truncate max-w-xs">
                          <Volume2 className="h-3 w-3 shrink-0 text-cyan-400" />
                          <span className="truncate">{player.sound}</span>
                        </span>
                      ) : (
                        <span className="flex items-center gap-1 text-slate-500 italic">
                          <VolumeX className="h-3 w-3 shrink-0" /> No Sound
                        </span>
                      )}
                    </div>
                  </div>

                  {/* Action Buttons: Play/Test, Edit, Delete */}
                  <div className="flex items-center gap-1.5 shrink-0">
                    {player.sound && (
                      <button
                        type="button"
                        onClick={() => togglePlayAudio(player.sound || "", player.volume ?? 0.6)}
                        className="flex h-9 w-9 items-center justify-center rounded-xl border border-cyan-500/30 bg-cyan-600/10 text-cyan-300 hover:bg-cyan-600 hover:text-white transition-all"
                        title="Test Sound Audio"
                      >
                        {isPlayingAudio && audioPreviewRef.current?.src.includes(player.sound) ? (
                          <Square className="h-3.5 w-3.5 fill-current" />
                        ) : (
                          <Play className="h-3.5 w-3.5 fill-current" />
                        )}
                      </button>
                    )}

                    <button
                      type="button"
                      onClick={() => openEditForm(player)}
                      className="flex h-9 items-center gap-1.5 px-3 rounded-xl border border-indigo-500/40 bg-indigo-600/15 hover:bg-indigo-600 text-indigo-200 hover:text-white text-xs font-bold transition-all shadow-sm active:scale-95"
                      title="Edit Player Banner"
                    >
                      <Edit3 className="h-3.5 w-3.5" />
                      <span>Edit</span>
                    </button>

                    <button
                      type="button"
                      disabled={busy}
                      onClick={() => removePlayer(player)}
                      className="flex h-9 w-9 items-center justify-center rounded-xl border border-red-500/30 bg-red-600/15 text-red-300 hover:bg-red-600 hover:text-white transition-all shadow-sm active:scale-95"
                      title="Delete Player Banner"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Right Drawer: Add / Edit Form */}
          {showDrawer && (
            <div className="flex w-[380px] shrink-0 flex-col border-l border-slate-800 bg-[#0b101c] shadow-2xl animate-in slide-in-from-right-4 duration-200">
              {/* Form Title */}
              <div className="flex items-center justify-between border-b border-slate-800 px-5 py-4 bg-[#0d1322]">
                <div className="flex items-center gap-2 text-white">
                  {isEditing ? (
                    <Edit3 className="h-4 w-4 text-cyan-400" />
                  ) : (
                    <UserPlus className="h-4 w-4 text-emerald-400" />
                  )}
                  <div>
                    <h3 className="text-sm font-black">
                      {isEditing ? "Edit Player Banner" : "Add Player Banner"}
                    </h3>
                    <p className="text-[10px] text-slate-400">
                      {isEditing ? "Modify GIF, sound, volume & dimensions" : "Assign custom welcome banner & audio"}
                    </p>
                  </div>
                </div>
                <button
                  type="button"
                  onClick={() => {
                    stopAudioPreview();
                    setShowDrawer(false);
                  }}
                  className="text-slate-400 hover:text-white p-1 rounded-lg hover:bg-slate-800 transition-colors"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              {/* Form Body Inputs */}
              <div className="no-scrollbar flex-1 space-y-3.5 overflow-y-auto p-5">
                {/* Identifier / License */}
                <div>
                  <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1">
                    Player License Identifier
                  </label>
                  <input
                    value={identifier}
                    onChange={(e) => setIdentifier(e.target.value)}
                    placeholder="license:xxxxxxxx..."
                    className="w-full rounded-xl border border-slate-700 bg-slate-950 px-3 py-2 text-xs font-mono text-white outline-none focus:border-cyan-500"
                  />
                  <span className="text-[10px] text-slate-500 mt-1 block">
                    Use full license identifier or select an online player below.
                  </span>
                </div>

                {/* Player Name */}
                <div>
                  <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1">
                    Player Display Name
                  </label>
                  <input
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    placeholder="e.g. John Doe"
                    className="w-full rounded-xl border border-slate-700 bg-slate-950 px-3 py-2 text-xs text-white outline-none focus:border-cyan-500"
                  />
                </div>

                {/* GIF / Image URL with Live Thumbnail Preview */}
                <div>
                  <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300 mb-1">
                    GIF / Image URL
                  </label>
                  <input
                    value={gif}
                    onChange={(e) => setGif(e.target.value)}
                    placeholder="https://.../banner.gif"
                    className="w-full rounded-xl border border-slate-700 bg-slate-950 px-3 py-2 text-xs text-white outline-none focus:border-cyan-500"
                  />
                  <span className="text-[10px] text-slate-500 mt-1 block">
                    Direct image link (.gif, .png, .jpg, .webp)
                  </span>

                  {gif && (
                    <div className="mt-2 h-20 w-full overflow-hidden rounded-xl border border-slate-700 bg-black/50 flex items-center justify-center">
                      <img
                        src={gif}
                        alt="Preview"
                        className="h-full w-full object-contain"
                        onError={(e) => {
                          (e.target as HTMLImageElement).style.display = "none";
                        }}
                      />
                    </div>
                  )}
                </div>

                {/* Sound URL & Audio Test Button */}
                <div>
                  <div className="flex items-center justify-between mb-1">
                    <label className="block text-[11px] font-bold uppercase tracking-wider text-slate-300">
                      Sound URL (MP3 / OGG)
                    </label>
                    {sound && (
                      <button
                        type="button"
                        onClick={() => togglePlayAudio(sound, volume)}
                        className="flex items-center gap-1 text-[10px] font-bold text-cyan-400 hover:text-cyan-300"
                      >
                        {isPlayingAudio ? (
                          <>
                            <Square className="h-3 w-3 fill-current" /> Stop Audio
                          </>
                        ) : (
                          <>
                            <Play className="h-3 w-3 fill-current" /> Test Audio
                          </>
                        )}
                      </button>
                    )}
                  </div>
                  <input
                    value={sound}
                    onChange={(e) => setSound(e.target.value)}
                    placeholder="https://.../welcome.mp3"
                    className="w-full rounded-xl border border-slate-700 bg-slate-950 px-3 py-2 text-xs text-white outline-none focus:border-cyan-500"
                  />
                  <span className="text-[10px] text-slate-500 mt-1 block">
                    Direct MP3 or OGG link (Discord CDN, FiveManage, etc.)
                  </span>
                </div>

                {/* Volume Slider */}
                <div className="rounded-xl border border-slate-800 bg-slate-900/60 p-3">
                  <div className="flex items-center justify-between text-xs font-bold text-slate-300 mb-1.5">
                    <span className="flex items-center gap-1.5">
                      <Volume2 className="h-3.5 w-3.5 text-cyan-400" />
                      Sound Playback Volume
                    </span>
                    <span className="font-mono text-cyan-400">{Math.round(volume * 100)}%</span>
                  </div>
                  <input
                    type="range"
                    min={0}
                    max={1}
                    step={0.05}
                    value={volume}
                    onChange={(e) => setVolume(Number(e.target.value))}
                    className="w-full accent-cyan-500 cursor-pointer"
                  />
                </div>

                {/* Duration Slider */}
                <div className="rounded-xl border border-slate-800 bg-slate-900/60 p-3">
                  <div className="flex items-center justify-between text-xs font-bold text-slate-300 mb-1.5">
                    <span className="flex items-center gap-1.5">
                      <Clock className="h-3.5 w-3.5 text-amber-400" />
                      Display Duration
                    </span>
                    <span className="font-mono text-amber-400">{duration} seconds</span>
                  </div>
                  <input
                    type="range"
                    min={4}
                    max={20}
                    step={1}
                    value={duration}
                    onChange={(e) => setDuration(Number(e.target.value))}
                    className="w-full accent-amber-500 cursor-pointer"
                  />
                </div>

                {/* Custom Dimensions (Optional) */}
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-1">
                      Width (px, opt)
                    </label>
                    <input
                      type="number"
                      value={width}
                      onChange={(e) => setWidth(e.target.value)}
                      placeholder="e.g. 350"
                      className="w-full rounded-xl border border-slate-700 bg-slate-950 px-3 py-1.5 text-xs text-white outline-none focus:border-cyan-500"
                    />
                  </div>
                  <div>
                    <label className="block text-[10px] font-bold uppercase tracking-wider text-slate-400 mb-1">
                      Height (px, opt)
                    </label>
                    <input
                      type="number"
                      value={height}
                      onChange={(e) => setHeight(e.target.value)}
                      placeholder="e.g. 200"
                      className="w-full rounded-xl border border-slate-700 bg-slate-950 px-3 py-1.5 text-xs text-white outline-none focus:border-cyan-500"
                    />
                  </div>
                </div>

                {/* Quick Select from Online Players */}
                <div>
                  <p className="mb-1.5 text-[10px] font-bold uppercase tracking-wider text-slate-400">
                    Quick Pick Online Players ({online.length})
                  </p>
                  <div className="no-scrollbar max-h-28 space-y-1 overflow-y-auto rounded-xl border border-slate-800 bg-slate-950/60 p-1.5">
                    {online.length === 0 ? (
                      <p className="text-[11px] text-slate-500 p-2 text-center">No other players online.</p>
                    ) : (
                      online.map((player) => (
                        <button
                          key={`${player.id}-${player.identifier}`}
                          type="button"
                          onClick={() => pickOnline(player)}
                          className={cn(
                            "w-full rounded-lg border px-2.5 py-1.5 text-left text-xs transition-colors",
                            identifier === player.identifier
                              ? "border-cyan-500 bg-cyan-600/20 text-white font-bold"
                              : "border-slate-800 bg-slate-900/60 text-slate-300 hover:bg-slate-800 hover:text-white"
                          )}
                        >
                          <span className="block truncate">{player.name}</span>
                          <span className="block truncate font-mono text-[9px] opacity-60">{player.identifier}</span>
                        </button>
                      ))
                    )}
                  </div>
                </div>
              </div>

              {/* Form Action Buttons */}
              <div className="flex items-center gap-2 p-4 border-t border-slate-800 bg-[#0d1322]">
                <button
                  type="button"
                  onClick={() => {
                    stopAudioPreview();
                    setShowDrawer(false);
                  }}
                  className="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-bold transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  disabled={busy || !identifier.trim() || !gif.trim()}
                  onClick={savePlayerBanner}
                  className="flex-1 rounded-xl bg-cyan-600 hover:bg-cyan-500 disabled:opacity-40 text-white py-2 text-xs font-black transition-all shadow-md shadow-cyan-600/30"
                >
                  {isEditing ? "Update Player Banner" : "Save Player Banner"}
                </button>
              </div>
            </div>
          )}
        </div>

        {/* Bottom Footer */}
        <div className="flex shrink-0 items-center justify-between border-t border-slate-800 bg-[#0c1222] px-6 py-2.5 text-[11px] text-slate-400 font-mono">
          <span>Pandora City Welcome Banner System</span>
          <span className="text-cyan-400 font-bold">{players.length} Total Custom Banners</span>
        </div>
      </div>
    </div>
  );
}
