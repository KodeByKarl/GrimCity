import { UnstyledButton, createStyles } from '@mantine/core';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import LibIcon from '../../../../components/LibIcon';
import { grim } from '../../../../theme/grim';

interface Props {
  icon: IconProp;
  canClose?: boolean;
  iconSize: number;
  handleClick: () => void;
}

const useStyles = createStyles((_theme, params: { canClose?: boolean }) => ({
  button: {
    width: 44,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    background: 'transparent',
    border: 'none',
    borderLeft: `1px solid ${grim.borderMuted}`,
    color: params.canClose === false ? grim.mutedDark : grim.foreground,
    cursor: params.canClose === false ? 'not-allowed' : 'pointer',
    transition: 'background-color 120ms ease, color 120ms ease',
    '&:hover': {
      backgroundColor: params.canClose === false ? 'transparent' : 'rgba(255, 58, 58, 0.18)',
      color: params.canClose === false ? grim.mutedDark : grim.soft,
    },
  },
}));

const HeaderButton: React.FC<Props> = ({ icon, canClose, iconSize, handleClick }) => {
  const { classes } = useStyles({ canClose });

  return (
    <UnstyledButton className={classes.button} disabled={canClose === false} onClick={handleClick}>
      <LibIcon icon={icon} fontSize={iconSize} fixedWidth />
    </UnstyledButton>
  );
};

export default HeaderButton;
