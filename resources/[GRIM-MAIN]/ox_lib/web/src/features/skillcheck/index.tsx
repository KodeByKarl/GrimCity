import { useRef, useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import Indicator from './indicator';
import { fetchNui } from '../../utils/fetchNui';
import { Box, createStyles, Text } from '@mantine/core';
import type { GameDifficulty, SkillCheckProps } from '../../typings';
import { grim, grimFont, grimMono } from '../../theme/grim';
import ScaleFade from '../../transitions/ScaleFade';

export const circleCircumference = 2 * 50 * Math.PI;

const getRandomAngle = (min: number, max: number) => Math.floor(Math.random() * (max - min)) + min;

const difficultyOffsets = {
  easy: 50,
  medium: 40,
  hard: 25,
};

const getSpeedMultiplier = (difficulty: GameDifficulty) => {
  if (difficulty === 'easy') return 1;
  if (difficulty === 'medium') return 1.5;
  if (difficulty === 'hard') return 1.75;
  return difficulty.speedMultiplier;
};

const difficultyLabel = (difficulty: GameDifficulty) => {
  if (typeof difficulty === 'object') return 'Custom';
  return difficulty.charAt(0).toUpperCase() + difficulty.slice(1);
};

const useStyles = createStyles((_theme, params: { difficultyOffset: number }) => ({
  overlay: {
    width: '100%',
    height: '22%',
    bottom: 0,
    position: 'absolute',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    pointerEvents: 'none',
  },
  frame: {
    display: 'flex',
    flexDirection: 'column',
    width: 340,
    maxWidth: '88vw',
    background: 'rgba(11, 11, 16, 0.94)',
    border: `1px solid rgba(255, 58, 58, 0.45)`,
    borderRadius: 10,
    boxShadow: '0 16px 40px rgba(0, 0, 0, 0.85)',
    pointerEvents: 'auto',
    overflow: 'hidden',
  },
  header: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '8px 12px 6px',
  },
  title: {
    fontFamily: grimFont,
    fontSize: 12,
    fontWeight: 700,
    color: grim.foreground,
  },
  meta: {
    fontFamily: grimFont,
    fontSize: 11,
    fontWeight: 600,
    color: grim.muted,
  },
  metaAccent: {
    color: grim.accent,
    fontWeight: 700,
  },
  body: {
    display: 'flex',
    alignItems: 'center',
    gap: 4,
    padding: '0 10px 12px',
  },
  ringWrap: {
    position: 'relative',
    width: 84,
    height: 84,
    flexShrink: 0,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  svg: {
    width: 84,
    height: 84,
    overflow: 'visible',
  },
  track: {
    fill: 'transparent',
    stroke: 'rgba(255, 255, 255, 0.12)',
    strokeWidth: 8,
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
  },
  skillArea: {
    fill: 'transparent',
    stroke: grim.primary,
    strokeWidth: 8,
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    strokeDashoffset: circleCircumference - (Math.PI * 50 * params.difficultyOffset) / 180,
  },
  indicator: {
    stroke: '#ff4d4d',
    strokeWidth: 16,
    fill: 'transparent',
    r: 50,
    cx: 250,
    cy: 250,
    strokeDasharray: circleCircumference,
    strokeDashoffset: circleCircumference - 3,
  },
  button: {
    position: 'absolute',
    left: '50%',
    top: '50%',
    transform: 'translate(-50%, -50%)',
    backgroundColor: 'rgba(26, 18, 22, 0.95)',
    width: 22,
    height: 22,
    borderRadius: 5,
    border: `1px solid ${grim.borderMuted}`,
    fontFamily: grimMono,
    fontSize: 11,
    fontWeight: 700,
    color: grim.foreground,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
  },
  info: {
    flex: 1,
    minWidth: 0,
    display: 'flex',
    flexDirection: 'column',
    gap: 6,
    paddingRight: 4,
  },
  infoTitle: {
    fontFamily: grimFont,
    fontSize: 11,
    fontWeight: 700,
    color: grim.foreground,
  },
  instructions: {
    fontFamily: grimFont,
    fontSize: 11,
    fontWeight: 500,
    color: grim.muted,
    lineHeight: 1.4,
  },
  keyHl: {
    fontFamily: grimMono,
    fontWeight: 700,
    color: grim.foreground,
    background: grim.secondary,
    border: `1px solid ${grim.borderMuted}`,
    borderRadius: 3,
    padding: '0 4px',
    fontSize: 10,
  },
  needleHl: {
    fontWeight: 700,
    color: '#ff4d4d',
  },
  zoneHl: {
    fontWeight: 700,
    color: grim.primary,
  },
  tip: {
    display: 'flex',
    alignItems: 'center',
    gap: 6,
    marginTop: 0,
  },
  tipDot: {
    width: 5,
    height: 5,
    borderRadius: 999,
    background: grim.accent,
    flexShrink: 0,
  },
  tipText: {
    fontFamily: grimFont,
    fontSize: 10,
    color: grim.mutedDark,
  },
}));

const SkillCheck: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const dataRef = useRef<{ difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] } | null>(null);
  const dataIndexRef = useRef<number>(0);
  const [step, setStep] = useState({ current: 1, total: 1 });
  const [skillCheck, setSkillCheck] = useState<SkillCheckProps>({
    angle: 0,
    difficultyOffset: 50,
    difficulty: 'easy',
    key: 'e',
  });
  const { classes } = useStyles({ difficultyOffset: skillCheck.difficultyOffset });

  useNuiEvent('startSkillCheck', (data: { difficulty: GameDifficulty | GameDifficulty[]; inputs?: string[] }) => {
    dataRef.current = data;
    dataIndexRef.current = 0;
    const total = Array.isArray(data.difficulty) ? data.difficulty.length : 1;
    setStep({ current: 1, total });
    const gameData = Array.isArray(data.difficulty) ? data.difficulty[0] : data.difficulty;
    const offset = typeof gameData === 'object' ? gameData.areaSize : difficultyOffsets[gameData];
    const randomKey = data.inputs ? data.inputs[Math.floor(Math.random() * data.inputs.length)] : 'e';
    setSkillCheck({
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: gameData,
      keys: data.inputs?.map((input) => input.toLowerCase()),
      key: randomKey.toLowerCase(),
    });
    setVisible(true);
  });

  useNuiEvent('skillCheckCancel', () => {
    setVisible(false);
    fetchNui('skillCheckOver', false);
  });

  const handleComplete = (success: boolean) => {
    if (!dataRef.current) return;
    if (!success || !Array.isArray(dataRef.current.difficulty)) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    if (dataIndexRef.current >= dataRef.current.difficulty.length - 1) {
      setVisible(false);
      return fetchNui('skillCheckOver', success);
    }

    dataIndexRef.current++;
    setStep({ current: dataIndexRef.current + 1, total: dataRef.current.difficulty.length });
    const data = dataRef.current.difficulty[dataIndexRef.current];
    const key = dataRef.current.inputs
      ? dataRef.current.inputs[Math.floor(Math.random() * dataRef.current.inputs.length)]
      : 'e';
    const offset = typeof data === 'object' ? data.areaSize : difficultyOffsets[data];
    setSkillCheck((prev) => ({
      ...prev,
      angle: -90 + getRandomAngle(120, 360 - offset),
      difficultyOffset: offset,
      difficulty: data,
      key: key.toLowerCase(),
    }));
  };

  return (
    <Box className={classes.overlay}>
      <ScaleFade visible={visible}>
        <Box className={classes.frame}>
          <Box className={classes.header}>
            <Text className={classes.title}>Skill Check</Text>
            <Text className={classes.meta}>
              {step.current}/{step.total} •{' '}
              <Text component="span" className={classes.metaAccent}>
                {difficultyLabel(skillCheck.difficulty)}
              </Text>
            </Text>
          </Box>

          <Box className={classes.body}>
            <Box className={classes.ringWrap}>
              <svg className={classes.svg} viewBox="190 190 120 120">
                <circle className={classes.track} />
                <circle transform={`rotate(${skillCheck.angle}, 250, 250)`} className={classes.skillArea} />
                <Indicator
                  angle={skillCheck.angle}
                  offset={skillCheck.difficultyOffset}
                  multiplier={getSpeedMultiplier(skillCheck.difficulty)}
                  handleComplete={handleComplete}
                  className={classes.indicator}
                  skillCheck={skillCheck}
                />
              </svg>
              <Box className={classes.button}>{skillCheck.key.toUpperCase()}</Box>
            </Box>

            <Box className={classes.info}>
              <Text className={classes.infoTitle}>Instructions</Text>
              <Text className={classes.instructions}>
                Hit <Text component="span" className={classes.keyHl}>{skillCheck.key.toUpperCase()}</Text> when the{' '}
                <Text component="span" className={classes.needleHl}>red line</Text> hits the{' '}
                <Text component="span" className={classes.zoneHl}>red zone</Text>.
              </Text>
              <Box className={classes.tip}>
                <Box className={classes.tipDot} />
                <Text className={classes.tipText}>Timing is everything...</Text>
              </Box>
            </Box>
          </Box>
        </Box>
      </ScaleFade>
    </Box>
  );
};

export default SkillCheck;
