import { Box, createStyles, Text } from '@mantine/core';
import React from 'react';
import { clipChamferDual, grim, grimFont, grimMono, panelGridBg } from '../../../theme/grim';

const useStyles = createStyles(() => ({
  container: {
    textAlign: 'center',
    clipPath: clipChamferDual,
    background: panelGridBg,
    backgroundSize: 'auto, 28px 28px, 28px 28px',
    border: `1px solid ${grim.primary}`,
    height: 56,
    width: 384,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  heading: {
    fontSize: 16,
    textTransform: 'uppercase',
    fontWeight: 800,
    letterSpacing: '0.14em',
    fontFamily: grimFont,
    color: grim.foreground,
  },
  tag: {
    position: 'absolute',
    top: 6,
    left: 12,
    fontFamily: grimMono,
    fontSize: 7,
    letterSpacing: '0.14em',
    color: grim.mutedDark,
  },
}));

const Header: React.FC<{ title: string }> = ({ title }) => {
  const { classes } = useStyles();

  return (
    <Box className={classes.container}>
      <Text className={classes.tag}>LIST // MENU</Text>
      <Text className={classes.heading}>{title}</Text>
    </Box>
  );
};

export default React.memo(Header);
