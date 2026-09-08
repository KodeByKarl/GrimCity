import { Checkbox, createStyles } from '@mantine/core';
import { grim } from '../../../theme/grim';

const useStyles = createStyles(() => ({
  root: {
    display: 'flex',
    alignItems: 'center',
  },
  input: {
    backgroundColor: grim.secondary,
    borderColor: grim.borderMuted,
    borderRadius: 0,
    '&:checked': { backgroundColor: grim.primary, borderColor: grim.primary },
  },
  inner: {
    '> svg > path': {
      fill: grim.foreground,
    },
  },
}));

const CustomCheckbox: React.FC<{ checked: boolean }> = ({ checked }) => {
  const { classes } = useStyles();
  return (
    <Checkbox
      checked={checked}
      size="md"
      classNames={{ root: classes.root, input: classes.input, inner: classes.inner }}
    />
  );
};

export default CustomCheckbox;
