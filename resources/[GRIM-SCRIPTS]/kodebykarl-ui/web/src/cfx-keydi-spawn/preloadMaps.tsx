import mapDay from "@/assets/map_day.jpg";
import mapNight from "@/assets/map_night.jpg";

export const SPAWN_MAP_DAY = mapDay;
export const SPAWN_MAP_NIGHT = mapNight;

let started = false;

export function preloadSpawnMaps() {
  if (started) return;
  started = true;
  for (const src of [mapDay, mapNight]) {
    const img = new Image();
    img.decoding = "async";
    img.src = src;
    if (typeof img.decode === "function") {
      img.decode().catch(() => {});
    }
  }
}

/** Keeps both map bitmaps decoded in CEF so the first spawn open is instant. */
export function SpawnMapWarmup() {
  return (
    <div
      aria-hidden
      className="pointer-events-none fixed left-0 top-0 h-px w-px overflow-hidden opacity-[0.01]"
    >
      <img src={mapDay} alt="" decoding="async" />
      <img src={mapNight} alt="" decoding="async" />
    </div>
  );
}
