import { Button, createStyles, Group, HoverCard, Image, Progress, Stack, Text } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import { ContextMenuProps, Option } from '../../../../typings';
import { fetchNui } from '../../../../utils/fetchNui';
import { isIconUrl } from '../../../../utils/isIconUrl';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import MarkdownComponents from '../../../../config/MarkdownComponents';
import LibIcon from '../../../../components/LibIcon';
import { grim, grimFont } from '../../../../theme/grim';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: false });
};

const clickContext = (id: string) => {
  fetchNui('clickContext', id);
};

const useStyles = createStyles((_theme, params: { disabled?: boolean; readOnly?: boolean }) => ({
  inner: {
    justifyContent: 'flex-start',
  },
  label: {
    width: '100%',
    color: params.disabled ? grim.mutedDark : grim.foreground,
    whiteSpace: 'pre-wrap',
    fontFamily: grimFont,
  },
  button: {
    height: 'fit-content',
    width: '100%',
    padding: '11px 14px',
    borderRadius: 0,
    backgroundColor: 'transparent',
    border: 'none',
    borderLeft: '3px solid transparent',
    borderBottom: `1px solid rgba(255, 58, 58, 0.12)`,
    clipPath: 'none',
    transition: 'background-color 120ms ease, border-color 120ms ease',
    '&:hover': {
      backgroundColor: params.readOnly ? 'transparent' : 'rgba(255, 58, 58, 0.12)',
      borderLeftColor: params.readOnly ? 'transparent' : grim.primary,
      cursor: params.readOnly ? 'unset' : 'pointer',
    },
    '&:active': {
      transform: params.readOnly ? 'unset' : undefined,
    },
  },
  iconImage: {
    maxWidth: '22px',
  },
  description: {
    color: params.disabled ? grim.mutedDark : grim.muted,
    fontSize: 11,
    fontFamily: grimFont,
    lineHeight: 1.35,
    marginTop: 2,
  },
  dropdown: {
    padding: 12,
    color: grim.foreground,
    fontSize: 13,
    maxWidth: 260,
    width: 'fit-content',
    border: `1px solid ${grim.primary}`,
    borderRadius: 0,
    background: `linear-gradient(180deg, #161014, ${grim.background})`,
    boxShadow: '0 16px 40px rgba(0,0,0,0.85)',
    fontFamily: grimFont,
  },
  buttonStack: {
    gap: 2,
    flex: '1',
    minWidth: 0,
  },
  buttonGroup: {
    gap: 10,
    flexWrap: 'nowrap',
    alignItems: 'center',
  },
  buttonIconContainer: {
    width: 22,
    height: 22,
    justifyContent: 'center',
    alignItems: 'center',
    color: grim.accent,
    flexShrink: 0,
  },
  buttonTitleText: {
    overflowWrap: 'break-word',
    fontWeight: 700,
    fontSize: 13,
    letterSpacing: '0.02em',
  },
  buttonArrowContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    width: 18,
    height: 18,
    color: grim.soft,
    opacity: 0.85,
    flexShrink: 0,
  },
  progress: {
    marginTop: 6,
  },
}));

const ContextButton: React.FC<{
  option: [string, Option];
}> = ({ option }) => {
  const button = option[1];
  const buttonKey = option[0];
  const { classes } = useStyles({ disabled: button.disabled, readOnly: button.readOnly });

  return (
    <>
      <HoverCard
        position="right-start"
        disabled={button.disabled || !(button.metadata || button.image)}
        openDelay={200}
      >
        <HoverCard.Target>
          <Button
            classNames={{ inner: classes.inner, label: classes.label, root: classes.button }}
            onClick={() =>
              !button.disabled && !button.readOnly
                ? button.menu
                  ? openMenu(button.menu)
                  : clickContext(buttonKey)
                : null
            }
            variant="default"
            disabled={button.disabled}
          >
            <Group position="apart" w="100%" noWrap>
              <Stack className={classes.buttonStack}>
                {(button.title || Number.isNaN(+buttonKey)) && (
                  <Group className={classes.buttonGroup}>
                    {button?.icon && (
                      <Stack className={classes.buttonIconContainer}>
                        {typeof button.icon === 'string' && isIconUrl(button.icon) ? (
                          <img src={button.icon} className={classes.iconImage} alt="Missing img" />
                        ) : (
                          <LibIcon
                            icon={button.icon as IconProp}
                            fixedWidth
                            size="sm"
                            style={{ color: button.iconColor || grim.accent }}
                            animation={button.iconAnimation}
                          />
                        )}
                      </Stack>
                    )}
                    <Text className={classes.buttonTitleText}>
                      <ReactMarkdown components={MarkdownComponents}>{button.title || buttonKey}</ReactMarkdown>
                    </Text>
                  </Group>
                )}
                {button.description && (
                  <Text className={classes.description}>
                    <ReactMarkdown components={MarkdownComponents}>{button.description}</ReactMarkdown>
                  </Text>
                )}
                {button.progress !== undefined && (
                  <Progress
                    className={classes.progress}
                    value={button.progress}
                    size={4}
                    radius={0}
                    color={button.colorScheme || 'red'}
                    styles={{ root: { backgroundColor: 'rgba(255,255,255,0.08)' } }}
                  />
                )}
              </Stack>
              {(button.menu || button.arrow) && button.arrow !== false && (
                <Stack className={classes.buttonArrowContainer}>
                  <LibIcon icon="chevron-right" fixedWidth size="sm" />
                </Stack>
              )}
            </Group>
          </Button>
        </HoverCard.Target>
        <HoverCard.Dropdown className={classes.dropdown}>
          {button.image && <Image src={button.image} />}
          {Array.isArray(button.metadata) ? (
            button.metadata.map(
              (
                metadata: string | { label: string; value?: any; progress?: number; colorScheme?: string },
                index: number
              ) => (
                <>
                  <Text key={`context-metadata-${index}`}>
                    {typeof metadata === 'string' ? `${metadata}` : `${metadata.label}: ${metadata?.value ?? ''}`}
                  </Text>

                  {typeof metadata === 'object' && metadata.progress !== undefined && (
                    <Progress
                      value={metadata.progress}
                      size={4}
                      radius={0}
                      color={metadata.colorScheme || button.colorScheme || 'red'}
                      styles={{ root: { backgroundColor: 'rgba(255,255,255,0.08)', marginTop: 4 } }}
                    />
                  )}
                </>
              )
            )
          ) : (
            <>
              {typeof button.metadata === 'object' &&
                Object.entries(button.metadata).map((metadata: { [key: string]: any }, index) => (
                  <Text key={`context-metadata-${index}`}>
                    {metadata[0]}: {metadata[1]}
                  </Text>
                ))}
            </>
          )}
        </HoverCard.Dropdown>
      </HoverCard>
    </>
  );
};

export default ContextButton;
