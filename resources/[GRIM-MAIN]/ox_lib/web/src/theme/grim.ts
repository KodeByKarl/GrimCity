/** Grim City / kodebykarl-ui palette + cyberpunk geometry tokens for ox_lib UI. */

export const grim = {
  background: '#0b0b10',
  card: '#13131a',
  panel: '#0d0d12',
  surface: '#181014',
  foreground: '#ffffff',
  muted: '#a08890',
  mutedDark: '#6e555c',
  primary: '#ff3a3a',
  accent: '#ff4d4d',
  deep: '#b30000',
  soft: '#ff8080',
  secondary: '#1a1215',
  track: '#1a1518',
  borderMuted: 'rgba(255, 58, 58, 0.35)',
  grid: 'rgba(255, 58, 58, 0.05)',
  overlay: 'rgba(11, 11, 16, 0.92)',
} as const;

/** Bottom-right chamfer — cyberpunk banner cut */
export const clipChamferBR = 'polygon(0 0, 100% 0, 100% calc(100% - 14px), calc(100% - 14px) 100%, 0 100%)';

/** Dual chamfer (top-left + bottom-right) */
export const clipChamferDual =
  'polygon(14px 0, 100% 0, 100% calc(100% - 14px), calc(100% - 14px) 100%, 0 100%, 0 14px)';

/** Small key chip chamfer */
export const clipChamferKey =
  'polygon(5px 0, 100% 0, 100% calc(100% - 5px), calc(100% - 5px) 100%, 0 100%, 0 5px)';

/** Red scale for Mantine primaryColor: 'red' — shade 6 ≈ #ff3a3a */
export const grimRedScale = [
  '#fff1f1',
  '#ffd6d6',
  '#ffb3b3',
  '#ff8080',
  '#ff5c5c',
  '#ff4d4d',
  '#ff3a3a',
  '#e61e1e',
  '#b30000',
  '#7a0000',
] as const;

export const grimFont =
  "'Outfit', 'Inter', system-ui, -apple-system, BlinkMacSystemFont, sans-serif";

export const grimMono = "'Roboto Mono', ui-monospace, monospace";

export const hazardStripe = `repeating-linear-gradient(
  -45deg,
  ${grim.deep} 0px,
  ${grim.deep} 6px,
  ${grim.primary} 6px,
  ${grim.primary} 12px
)`;

export const panelGridBg = `
  linear-gradient(180deg, rgba(24, 16, 20, 0.95) 0%, rgba(13, 10, 14, 0.95) 100%),
  linear-gradient(${grim.grid} 1px, transparent 1px),
  linear-gradient(90deg, ${grim.grid} 1px, transparent 1px)
`;
