import { MantineThemeOverride, Tuple } from '@mantine/core';
import { clipChamferBR, clipChamferDual, grim, grimFont, grimRedScale } from './grim';

export const theme: MantineThemeOverride = {
  colorScheme: 'dark',
  fontFamily: grimFont,
  primaryColor: 'red',
  primaryShade: 6,
  colors: {
    red: [...grimRedScale] as unknown as Tuple<string, 10>,
  },
  defaultRadius: 0,
  shadows: {
    sm: '0 12px 32px rgba(0, 0, 0, 0.75)',
    md: '0 20px 50px rgba(0, 0, 0, 0.85)',
  },
  components: {
    Button: {
      styles: {
        root: {
          borderRadius: 0,
          clipPath: clipChamferBR,
          fontFamily: grimFont,
          fontWeight: 700,
          letterSpacing: '0.06em',
          textTransform: 'uppercase',
          border: `1px solid ${grim.borderMuted}`,
          backgroundColor: grim.card,
          color: grim.foreground,
          transition: 'background-color 120ms ease, border-color 120ms ease, filter 120ms ease',
          '&:hover': {
            backgroundColor: 'rgba(255, 58, 58, 0.18)',
            borderColor: grim.primary,
          },
        },
      },
    },
    Modal: {
      styles: {
        modal: {
          background: `
            linear-gradient(180deg, rgba(24, 16, 20, 0.98) 0%, rgba(13, 10, 14, 0.98) 100%),
            linear-gradient(${grim.grid} 1px, transparent 1px),
            linear-gradient(90deg, ${grim.grid} 1px, transparent 1px)
          `,
          backgroundSize: 'auto, 28px 28px, 28px 28px',
          border: `1px solid ${grim.primary}`,
          borderRadius: 0,
          clipPath: clipChamferDual,
          boxShadow: '0 25px 60px rgba(0, 0, 0, 0.9)',
          fontFamily: grimFont,
        },
        header: {
          marginBottom: 12,
          borderBottom: `1px solid ${grim.borderMuted}`,
          paddingBottom: 10,
        },
        title: {
          fontFamily: grimFont,
          fontWeight: 800,
          letterSpacing: '0.12em',
          textTransform: 'uppercase',
          color: grim.foreground,
          fontSize: 14,
          width: '100%',
        },
        body: {
          color: grim.muted,
        },
        overlay: {
          backgroundColor: 'rgba(0, 0, 0, 0.72)',
        },
      },
    },
    Drawer: {
      styles: {
        drawer: {
          background: grim.panel,
          borderRight: `1px solid ${grim.primary}`,
          fontFamily: grimFont,
        },
        header: {
          borderBottom: `1px solid ${grim.borderMuted}`,
          marginBottom: 8,
        },
        title: {
          fontFamily: grimFont,
          fontWeight: 800,
          letterSpacing: '0.14em',
          textTransform: 'uppercase',
          color: grim.foreground,
          fontSize: 13,
        },
        closeButton: {
          color: grim.soft,
          '&:hover': {
            backgroundColor: 'rgba(255, 58, 58, 0.18)',
          },
        },
      },
    },
    TextInput: {
      styles: {
        input: {
          backgroundColor: grim.secondary,
          border: `1px solid ${grim.borderMuted}`,
          borderRadius: 0,
          color: grim.foreground,
          fontFamily: grimFont,
          '&:focus': {
            borderColor: grim.primary,
          },
        },
        label: {
          color: grim.muted,
          fontFamily: grimFont,
          fontWeight: 600,
          letterSpacing: '0.04em',
        },
      },
    },
    NumberInput: {
      styles: {
        input: {
          backgroundColor: grim.secondary,
          border: `1px solid ${grim.borderMuted}`,
          borderRadius: 0,
          color: grim.foreground,
          '&:focus': {
            borderColor: grim.primary,
          },
        },
        label: {
          color: grim.muted,
          fontWeight: 600,
        },
      },
    },
    Textarea: {
      styles: {
        input: {
          backgroundColor: grim.secondary,
          border: `1px solid ${grim.borderMuted}`,
          borderRadius: 0,
          color: grim.foreground,
          '&:focus': {
            borderColor: grim.primary,
          },
        },
        label: {
          color: grim.muted,
          fontWeight: 600,
        },
      },
    },
    Select: {
      styles: {
        input: {
          backgroundColor: grim.secondary,
          border: `1px solid ${grim.borderMuted}`,
          borderRadius: 0,
          color: grim.foreground,
          '&:focus': {
            borderColor: grim.primary,
          },
        },
        label: {
          color: grim.muted,
          fontWeight: 600,
        },
        dropdown: {
          backgroundColor: grim.card,
          border: `1px solid ${grim.borderMuted}`,
          borderRadius: 0,
        },
        item: {
          '&[data-selected]': {
            backgroundColor: 'rgba(255, 58, 58, 0.25)',
            color: grim.foreground,
          },
          '&[data-hovered]': {
            backgroundColor: 'rgba(255, 58, 58, 0.14)',
          },
        },
      },
    },
    Checkbox: {
      styles: {
        label: {
          color: grim.muted,
        },
        input: {
          backgroundColor: grim.secondary,
          borderColor: grim.borderMuted,
          borderRadius: 0,
          '&:checked': {
            backgroundColor: grim.primary,
            borderColor: grim.primary,
          },
        },
      },
    },
    Slider: {
      styles: {
        track: {
          backgroundColor: grim.track,
        },
        bar: {
          backgroundColor: grim.primary,
        },
        thumb: {
          borderColor: grim.primary,
          backgroundColor: grim.foreground,
        },
        label: {
          backgroundColor: grim.primary,
          borderRadius: 0,
        },
      },
    },
    Progress: {
      styles: {
        root: {
          backgroundColor: grim.track,
          borderRadius: 0,
        },
        bar: {
          borderRadius: 0,
        },
      },
    },
  },
};
