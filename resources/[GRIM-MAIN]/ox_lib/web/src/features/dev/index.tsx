import { ActionIcon, Button, createStyles, Divider, Drawer, Stack, Text, Tooltip } from '@mantine/core';
import { debugAlert } from './debug/alert';
import { debugContext } from './debug/context';
import { debugInput } from './debug/input';
import { debugMenu } from './debug/menu';
import { debugCustomNotification } from './debug/notification';
import { debugCircleProgressbar, debugProgressbar } from './debug/progress';
import { debugTextUI } from './debug/textui';
import { debugSkillCheck } from './debug/skillcheck';
import { useState } from 'react';
import { debugRadial } from './debug/radial';
import LibIcon from '../../components/LibIcon';
import { clipChamferKey, grim, grimFont, grimMono } from '../../theme/grim';

const useStyles = createStyles(() => ({
  fab: {
    position: 'absolute',
    bottom: 50,
    right: 50,
    width: 52,
    height: 52,
    borderRadius: 0,
    clipPath: clipChamferKey,
    background: `linear-gradient(135deg, ${grim.accent}, ${grim.deep})`,
    border: `1px solid ${grim.primary}`,
    color: grim.foreground,
    '&:hover': {
      filter: 'brightness(1.1)',
      background: `linear-gradient(135deg, ${grim.accent}, ${grim.deep})`,
    },
  },
  section: {
    fontFamily: grimMono,
    fontSize: 9,
    letterSpacing: '0.16em',
    color: grim.mutedDark,
    textTransform: 'uppercase',
    marginTop: 4,
  },
  btn: {
    backgroundColor: grim.card,
    border: `1px solid ${grim.borderMuted}`,
    color: grim.foreground,
    fontFamily: grimFont,
    fontWeight: 700,
    letterSpacing: '0.04em',
    '&:hover': {
      backgroundColor: 'rgba(255, 58, 58, 0.2)',
      borderColor: grim.primary,
    },
  },
  divider: {
    borderColor: grim.borderMuted,
  },
}));

const Dev: React.FC = () => {
  const [opened, setOpened] = useState(false);
  const { classes } = useStyles();

  return (
    <>
      <Tooltip label="Developer drawer" position="bottom">
        <ActionIcon onClick={() => setOpened(true)} className={classes.fab} size="xl" variant="filled">
          <LibIcon icon="wrench" fontSize={22} />
        </ActionIcon>
      </Tooltip>

      <Drawer position="left" onClose={() => setOpened(false)} opened={opened} title="GRIM // DEV MATRIX" padding="xl">
        <Stack spacing="sm">
          <Text className={classes.section}>Dialogs</Text>
          <Divider className={classes.divider} />
          <Button fullWidth className={classes.btn} onClick={() => debugInput()}>
            Open input dialog
          </Button>
          <Button fullWidth className={classes.btn} onClick={() => debugAlert()}>
            Open alert dialog
          </Button>

          <Text className={classes.section}>Menus</Text>
          <Divider className={classes.divider} />
          <Button fullWidth className={classes.btn} onClick={() => debugContext()}>
            Open context menu
          </Button>
          <Button fullWidth className={classes.btn} onClick={() => debugMenu()}>
            Open list menu
          </Button>
          <Button fullWidth className={classes.btn} onClick={() => debugRadial()}>
            Open radial menu
          </Button>

          <Text className={classes.section}>Alerts</Text>
          <Divider className={classes.divider} />
          <Button fullWidth className={classes.btn} onClick={() => debugCustomNotification()}>
            Send notification
          </Button>

          <Text className={classes.section}>Progress</Text>
          <Divider className={classes.divider} />
          <Button fullWidth className={classes.btn} onClick={() => debugProgressbar()}>
            Activate progress bar
          </Button>
          <Button fullWidth className={classes.btn} onClick={() => debugCircleProgressbar()}>
            Activate progress circle
          </Button>

          <Text className={classes.section}>HUD</Text>
          <Divider className={classes.divider} />
          <Button fullWidth className={classes.btn} onClick={() => debugTextUI()}>
            Show TextUI
          </Button>

          <Text className={classes.section}>Mechanics</Text>
          <Divider className={classes.divider} />
          <Button fullWidth className={classes.btn} onClick={() => debugSkillCheck()}>
            Run skill check
          </Button>
        </Stack>
      </Drawer>
    </>
  );
};

export default Dev;
