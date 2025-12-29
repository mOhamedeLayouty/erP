import React from 'react';

type InputProps = React.InputHTMLAttributes<HTMLInputElement>;

export default function Input({ className, ...props }: InputProps) {
  const classes = ['m365-input', className].filter(Boolean).join(' ');
  return <input className={classes} {...props} />;
}
