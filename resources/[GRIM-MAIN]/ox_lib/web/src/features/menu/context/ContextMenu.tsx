import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { Box, createStyles, Stack, Text } from '@mantine/core';
import { useEffect, useState } from 'react';
import { ContextMenuProps } from '../../../typings';
import ContextButton from './components/ContextButton';
import { fetchNui } from '../../../utils/fetchNui';
import ReactMarkdown from 'react-markdown';
import HeaderButton from './components/HeaderButton';
import ScaleFade from '../../../transitions/ScaleFade';
import MarkdownComponents from '../../../config/MarkdownComponents';
import { grim, grimFont, grimMono } from '../../../theme/grim';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: true });
};

const useStyles = createStyles(() => ({
  container: {
    position: 'absolute',
    top: '12%',
    right: '22%',
    width: 340,
  },
  shell: {
    position: 'relative',
    background: `linear-gradient(165deg, #161014 0%, ${grim.background} 55%, #0a080c 100%)`,
    border: `1.5px solid ${grim.primary}`,
    clipPath: 'polygon(0 0, calc(100% - 18px) 0, 100% 18px, 100% 100%, 18px 100%, 0 calc(100% - 18px))',
    boxShadow: '0 28px 60px rgba(0, 0, 0, 0.92)',
    overflow: 'hidden',
    '&::before': {
      content: '""',
      position: 'absolute',
      inset: 0,
      backgroundImage: `
        linear-gradient(rgba(255, 58, 58, 0.035) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255, 58, 58, 0.035) 1px, transparent 1px)
      `,
      backgroundSize: '24px 24px',
      pointerEvents: 'none',
      opacity: 0.7,
    },
  },
  header: {
    position: 'relative',
    zIndex: 1,
    display: 'flex',
    alignItems: 'stretch',
    gap: 0,
    minHeight: 48,
    background: `linear-gradient(90deg, rgba(255, 58, 58, 0.22) 0%, rgba(179, 0, 0, 0.08) 42%, transparent 100%)`,
    borderBottom: `1px solid ${grim.borderMuted}`,
  },
  headerAccent: {
    width: 4,
    flexShrink: 0,
    background: `linear-gradient(180deg, ${grim.accent}, ${grim.deep})`,
  },
  titleWrap: {
    flex: 1,
    display: 'flex',
    alignItems: 'center',
    padding: '0 14px',
    minWidth: 0,
  },
  titleText: {
    color: grim.foreground,
    fontFamily: grimFont,
    fontWeight: 800,
    letterSpacing: '0.14em',
    textTransform: 'uppercase',
    fontSize: 13,
    lineHeight: 1.2,
    whiteSpace: 'nowrap',
    overflow: 'hidden',
    textOverflow: 'ellipsis',
  },
  headerActions: {
    display: 'flex',
    alignItems: 'stretch',
    flexShrink: 0,
  },
  buttonsContainer: {
    position: 'relative',
    zIndex: 1,
    maxHeight: 520,
    overflowY: 'auto',
    padding: '6px 0',
  },
  buttonsFlexWrapper: {
    gap: 0,
  },
  footer: {
    position: 'relative',
    zIndex: 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '8px 12px 10px',
    borderTop: `1px solid ${grim.borderMuted}`,
    background: 'linear-gradient(90deg, transparent, rgba(255, 58, 58, 0.06), transparent)',
  },
  footerText: {
    fontFamily: grimMono,
    fontSize: 10,
    letterSpacing: '0.12em',
    color: grim.mutedDark,
    textTransform: 'lowercase',
  },
}));

const ContextMenu: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<ContextMenuProps>({
    title: '',
    options: { '': { description: '', metadata: [] } },
  });

  const closeContext = () => {
    if (contextMenu.canClose === false) return;
    setVisible(false);
    fetchNui('closeContext');
  };

  useEffect(() => {
    if (!visible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (['Escape'].includes(e.code)) closeContext();
    };

    window.addEventListener('keydown', keyHandler);

    return () => window.removeEventListener('keydown', keyHandler);
  }, [visible]);

  useNuiEvent('hideContext', () => setVisible(false));

  useNuiEvent<ContextMenuProps>('showContext', async (data) => {
    if (visible) {
      setVisible(false);
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
    setContextMenu(data);
    setVisible(true);
  });

  return (
    <Box className={classes.container}>
      <ScaleFade visible={visible}>
        <Box className={classes.shell}>
          <Box className={classes.header}>
            <Box className={classes.headerAccent} />
            {contextMenu.menu && (
              <Box className={classes.headerActions}>
                <HeaderButton icon="chevron-left" iconSize={15} handleClick={() => openMenu(contextMenu.menu)} />
              </Box>
            )}
            <Box className={classes.titleWrap}>
              <Text className={classes.titleText}>
                <ReactMarkdown components={MarkdownComponents}>{contextMenu.title}</ReactMarkdown>
              </Text>
            </Box>
            <Box className={classes.headerActions}>
              <HeaderButton icon="xmark" canClose={contextMenu.canClose} iconSize={16} handleClick={closeContext} />
            </Box>
          </Box>

          <Box className={classes.buttonsContainer}>
            <Stack className={classes.buttonsFlexWrapper}>
              {Object.entries(contextMenu.options).map((option, index) => (
                <ContextButton option={option} key={`context-item-${index}`} />
              ))}
            </Stack>
          </Box>

          <Box className={classes.footer}>
            <Text className={classes.footerText}>kodebykarl.site</Text>
          </Box>
        </Box>
      </ScaleFade>
    </Box>
  );
};

export default ContextMenu;
