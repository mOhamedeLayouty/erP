import React from 'react';

type ButtonVariant = 'primary' | 'secondary';

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
};

export default function Button({ variant = 'primary', className, ...props }: ButtonProps) {
  const classes = ['m365-button', variant, className].filter(Boolean).join(' ');
  return <button className={classes} {...props} />;
}
