import React from 'react';
import { Box, createStyles, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import type { ProgressbarProps } from '../../typings';
import {
  clipChamferBR,
  grim,
  grimFont,
  grimMono,
  hazardStripe,
  panelGridBg,
} from '../../theme/grim';

const useStyles = createStyles(() => ({
  wrapper: {
    width: '100%',
    height: '22%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    bottom: 0,
    position: 'absolute',
    pointerEvents: 'none',
  },
  panel: {
    width: 420,
    maxWidth: '90vw',
    padding: '14px 16px 12px',
    background: panelGridBg,
    backgroundSize: 'auto, 28px 28px, 28px 28px',
    backgroundPosition: '0 0, 0 0, 0 0',
    border: `1px solid ${grim.primary}`,
    clipPath: clipChamferBR,
    position: 'relative',
    boxShadow: '0 20px 50px rgba(0, 0, 0, 0.85)',
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 0,
      width: 48,
      height: 2,
      background: `linear-gradient(90deg, ${grim.accent}, transparent)`,
    },
  },
  header: {
    display: 'flex',
    alignItems: 'baseline',
    justifyContent: 'space-between',
    gap: 12,
    marginBottom: 10,
  },
  label: {
    fontFamily: grimFont,
    fontSize: 15,
    fontWeight: 600,
    color: grim.foreground,
    letterSpacing: '0.02em',
    maxWidth: 300,
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap',
  },
  percent: {
    fontFamily: grimMono,
    fontSize: 14,
    fontWeight: 700,
    color: grim.accent,
    letterSpacing: '0.04em',
    flexShrink: 0,
  },
  track: {
    width: '100%',
    height: 10,
    backgroundColor: grim.track,
    border: `1px solid ${grim.borderMuted}`,
    clipPath: 'polygon(0 0, 100% 0, 100% calc(100% - 4px), calc(100% - 4px) 100%, 0 100%)',
    overflow: 'hidden',
    position: 'relative',
  },
  bar: {
    height: '100%',
    width: 0,
    backgroundImage: `linear-gradient(90deg, ${grim.deep} 0%, ${grim.primary} 55%, ${grim.accent} 100%), ${hazardStripe}`,
    backgroundBlendMode: 'overlay',
    backgroundSize: '100% 100%, auto',
    position: 'relative',
    '&::after': {
      content: '""',
      position: 'absolute',
      top: 0,
      right: 0,
      width: 2,
      height: '100%',
      background: grim.foreground,
      opacity: 0.85,
    },
  },
  footer: {
    marginTop: 10,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 6,
  },
  cancel: {
    fontFamily: grimFont,
    fontSize: 11,
    fontWeight: 500,
    color: grim.muted,
    letterSpacing: '0.06em',
    textTransform: 'uppercase',
  },
  cancelKey: {
    fontFamily: grimMono,
    fontSize: 10,
    fontWeight: 700,
    color: grim.soft,
    border: `1px solid ${grim.borderMuted}`,
    padding: '1px 6px',
    background: grim.secondary,
  },
  techTag: {
    position: 'absolute',
    top: 8,
    right: 20,
    fontFamily: grimMono,
    fontSize: 8,
    letterSpacing: '0.14em',
    color: grim.mutedDark,
    textTransform: 'uppercase',
  },
}));

const Progressbar: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState('');
  const [duration, setDuration] = React.useState(0);
  const [percent, setPercent] = React.useState(0);
  const rafRef = React.useRef<number | null>(null);
  const startRef = React.useRef<number | null>(null);

  const stopPercent = React.useCallback(() => {
    if (rafRef.current !== null) {
      cancelAnimationFrame(rafRef.current);
      rafRef.current = null;
    }
    startRef.current = null;
  }, []);

  const tickPercent = React.useCallback(
    (time: number) => {
      startRef.current ??= time;
      const elapsed = time - startRef.current;
      const next = Math.min(100, Math.floor((elapsed / duration) * 100));
      setPercent(next);
      if (next < 100) {
        rafRef.current = requestAnimationFrame(tickPercent);
      }
    },
    [duration]
  );

  useNuiEvent('progressCancel', () => {
    stopPercent();
    setVisible(false);
  });

  useNuiEvent<ProgressbarProps>('progress', (data) => {
    stopPercent();
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
    setPercent(0);
  });

  React.useEffect(() => {
    if (!visible || duration <= 0) return;
    rafRef.current = requestAnimationFrame(tickPercent);
    return () => stopPercent();
  }, [visible, duration, tickPercent, stopPercent]);

  return (
    <Box className={classes.wrapper}>
      <ScaleFade
        visible={visible}
        onExitComplete={() => {
          stopPercent();
          fetchNui('progressComplete');
        }}
      >
        <Box className={classes.panel}>
          <Text className={classes.techTag}>SYS // PROG</Text>
          <Box className={classes.header}>
            <Text className={classes.label}>{label}</Text>
            <Text className={classes.percent}>{percent}%</Text>
          </Box>
          <Box className={classes.track}>
            <Box
              className={classes.bar}
              onAnimationEnd={() => {
                setPercent(100);
                setVisible(false);
              }}
              sx={{
                animation: 'progress-bar linear forwards',
                animationDuration: `${duration}ms`,
              }}
            />
          </Box>
          <Box className={classes.footer}>
            <Text className={classes.cancel}>Press</Text>
            <Text component="span" className={classes.cancelKey}>
              X
            </Text>
            <Text className={classes.cancel}>to cancel</Text>
          </Box>
        </Box>
      </ScaleFade>
    </Box>
  );
};

export default Progressbar;
