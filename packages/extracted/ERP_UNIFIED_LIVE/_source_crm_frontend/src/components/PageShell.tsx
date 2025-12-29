import React from "react";
import { Link } from "react-router-dom";
import {
  Button, Dropdown, Option, Toolbar, ToolbarButton, ToolbarDivider,
  Title3, Caption1, makeStyles, tokens
} from "@fluentui/react-components";
import { ArrowClockwise24Regular } from "@fluentui/react-icons";
import { useServiceCenter } from "../state/serviceCenter";

const useStyles = makeStyles({
  wrap: { maxWidth: "1120px", margin: "0 auto", padding: "16px" },
  header: {
    position: "sticky",
    top: 0,
    zIndex: 20,
    backgroundColor: tokens.colorNeutralBackground1,
    borderBottom: `1px solid ${tokens.colorNeutralStroke2}`
  },
  headerInner: { maxWidth: "1120px", margin: "0 auto", padding: "10px 16px" },
  content: { maxWidth: "1120px", margin: "0 auto", padding: "16px" }
});

export default function PageShell({ children }: { children: React.ReactNode }) {
  const s = useStyles();
  const { serviceCenters, serviceCenter, setServiceCenter, refreshServiceCenters } = useServiceCenter();

  return (
    <div>
      <div className={s.header}>
        <div className={s.headerInner}>
          <Toolbar>
            <ToolbarButton as={Link as any} to="/customers">
              <Title3 style={{ margin: 0 }}>Proactive CRM</Title3>
            </ToolbarButton>
            <ToolbarDivider />
            <Caption1>UI: Microsoft 365 (Fluent UI)</Caption1>
            <div style={{ flex: 1 }} />
            <Dropdown
              value={serviceCenter ?? ""}
              onOptionSelect={(_, data) => setServiceCenter(Number(data.optionValue))}
              placeholder="Select service center"
              style={{ minWidth: 260 }}
            >
              {serviceCenters.map(sc => (
                <Option key={sc.service_center} value={String(sc.service_center)}>
                  {sc.service_center} — {sc.name}
                </Option>
              ))}
            </Dropdown>
            <Button appearance="secondary" icon={<ArrowClockwise24Regular />} onClick={refreshServiceCenters}>
              Refresh
            </Button>
          </Toolbar>
        </div>
      </div>

      <div className={s.content}>
        {children}
      </div>
    </div>
  );
}
