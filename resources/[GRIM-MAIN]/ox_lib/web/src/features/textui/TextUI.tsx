import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { Box, createStyles, Group, Text } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import ScaleFade from '../../transitions/ScaleFade';
import remarkGfm from 'remark-gfm';
import type { TextUiPosition, TextUiProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import LibIcon from '../../components/LibIcon';
import { clipChamferBR, grim, grimFont, grimMono, panelGridBg } from '../../theme/grim';

const useStyles = createStyles((_theme, params: { position?: TextUiPosition }) => ({
  wrapper: {
    height: '100%',
    width: '100%',
    position: 'absolute',
    display: 'flex',
    alignItems:
      params.position === 'top-center' ? 'baseline' : params.position === 'bottom-center' ? 'flex-end' : 'center',
    justifyContent:
      params.position === 'right-center' ? 'flex-end' : params.position === 'left-center' ? 'flex-start' : 'center',
  },
  container: {
    fontSize: 15,
    padding: '12px 14px',
    margin: 8,
    background: panelGridBg,
    backgroundSize: 'auto, 28px 28px, 28px 28px',
    color: grim.foreground,
    fontFamily: grimFont,
    borderRadius: 0,
    clipPath: clipChamferBR,
    border: `1px solid ${grim.primary}`,
    boxShadow: '0 16px 40px rgba(0, 0, 0, 0.85)',
    position: 'relative',
    maxWidth: 360,
  },
  tag: {
    position: 'absolute',
    top: 4,
    right: 12,
    fontFamily: grimMono,
    fontSize: 7,
    letterSpacing: '0.12em',
    color: grim.mutedDark,
    textTransform: 'uppercase',
  },
  icon: {
    color: grim.accent,
  },
}));

const TextUI: React.FC = () => {
  const [data, setData] = React.useState<TextUiProps>({
    text: '',
    position: 'right-center',
  });
  const [visible, setVisible] = React.useState(false);
  const { classes } = useStyles({ position: data.position });

  useNuiEvent<TextUiProps>('textUi', (data) => {
    if (!data.position) data.position = 'right-center';
    setData(data);
    setVisible(true);
  });

  useNuiEvent('textUiHide', () => setVisible(false));

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible}>
          <Box style={data.style} className={classes.container}>
            <Text className={classes.tag}>PROMPT // UI</Text>
            <Group spacing={12}>
              {data.icon && (
                <LibIcon
                  icon={data.icon}
                  fixedWidth
                  size="lg"
                  animation={data.iconAnimation}
                  className={classes.icon}
                  style={{
                    color: data.iconColor || grim.accent,
                    alignSelf: !data.alignIcon || data.alignIcon === 'center' ? 'center' : 'start',
                  }}
                />
              )}
              <ReactMarkdown components={MarkdownComponents} remarkPlugins={[remarkGfm]}>
                {data.text}
              </ReactMarkdown>
            </Group>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default TextUI;
