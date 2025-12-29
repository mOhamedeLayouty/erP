import React from "react";
import { Textarea, Button, MessageBar, MessageBarBody } from "@fluentui/react-components";

function pretty(obj: any) {
  try { return JSON.stringify(obj, null, 2); } catch { return String(obj); }
}

export default function JsonEditor({
  value,
  onChange,
  placeholder
}: {
  value: any;
  onChange: (v: any) => void;
  placeholder?: string;
}) {
  const [text, setText] = React.useState<string>(() => pretty(value ?? {}));
  const [error, setError] = React.useState<string | null>(null);

  React.useEffect(() => {
    setText(pretty(value ?? {}));
  }, [value]);

  const apply = () => {
    try {
      const v = JSON.parse(text);
      setError(null);
      onChange(v);
    } catch (e: any) {
      setError(e?.message || "Invalid JSON");
    }
  };

  return (
    <div style={{ display: "grid", gap: 10 }}>
      <Textarea value={text} onChange={(_, data) => setText(data.value)} placeholder={placeholder} resize="vertical" />
      <div style={{ display: "flex", gap: 10, alignItems: "center", justifyContent: "space-between" }}>
        <Button appearance="secondary" onClick={apply}>Apply JSON</Button>
        {error ? (
          <MessageBar intent="error">
            <MessageBarBody>{error}</MessageBarBody>
          </MessageBar>
        ) : (
          <div style={{ color: "#666", fontSize: 12 }}>JSON keys must match DB columns.</div>
        )}
      </div>
    </div>
  );
}
