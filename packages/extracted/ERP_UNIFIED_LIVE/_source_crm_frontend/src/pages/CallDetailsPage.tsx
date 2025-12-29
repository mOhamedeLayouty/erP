import React from "react";
import { Link, useParams } from "react-router-dom";
import {
  Button, Card, CardHeader, Spinner, Table, TableBody, TableCell, TableHeader, TableHeaderCell, TableRow,
  Text, makeStyles
} from "@fluentui/react-components";
import { Add24Regular } from "@fluentui/react-icons";
import { useServiceCenter } from "../state/serviceCenter";
import { apiGet, apiPost } from "../utils/api";
import JsonEditor from "../components/JsonEditor";

const useStyles = makeStyles({
  pre: { margin: 0, whiteSpace: "pre-wrap", fontSize: 12, lineHeight: 1.35 }
});

export default function CallDetailsPage() {
  const styles = useStyles();
  const { callId } = useParams();
  const { serviceCenter } = useServiceCenter();
  const sc = serviceCenter ?? 1;

  const [history, setHistory] = React.useState<any[]>([]);
  const [err, setErr] = React.useState<string | null>(null);
  const [loading, setLoading] = React.useState(false);

  const [newHist, setNewHist] = React.useState<any>({});
  const [showNew, setShowNew] = React.useState(false);

  const load = async () => {
    if (!callId) return;
    setLoading(true);
    setErr(null);
    try {
      const resp = await apiGet<any>(`/crm/calls/${encodeURIComponent(callId)}/history`, sc);
      setHistory(resp.rows || []);
    } catch (e: any) {
      setErr(e?.message || "Failed to load history");
    } finally {
      setLoading(false);
    }
  };

  React.useEffect(() => { load().catch(() => {}); }, [callId, sc]);

  const createHistory = async () => {
    if (!callId) return;
    setErr(null);
    try {
      await apiPost(`/crm/calls/${encodeURIComponent(callId)}/history`, newHist, sc);
      setShowNew(false);
      setNewHist({});
      await load();
    } catch (e: any) {
      setErr(e?.message || "Create history failed");
    }
  };

  return (
    <Card>
      <CardHeader
        header={<Text size={600} weight="semibold">Call #{callId} — History</Text>}
        description={<Link to="/customers">← Customers</Link>}
        action={
          <Button appearance="secondary" icon={<Add24Regular />} onClick={() => setShowNew(v => !v)}>
            {showNew ? "Close" : "New History"}
          </Button>
        }
      />
      <div style={{ padding: 12, display: "grid", gap: 10 }}>
        {err ? <Text style={{ color: "#b00020" }}>{err}</Text> : null}
        {loading ? <Spinner size="tiny" /> : null}

        {showNew ? (
          <>
            <JsonEditor value={newHist} onChange={setNewHist} placeholder='{"action_date":"2025-12-26","action_notes":"..."}' />
            <Button onClick={createHistory}>Create History</Button>
          </>
        ) : null}

        <Table aria-label="History table">
          <TableHeader>
            <TableRow>
              <TableHeaderCell>Preview</TableHeaderCell>
            </TableRow>
          </TableHeader>
          <TableBody>
            {history.map((r, idx) => (
              <TableRow key={idx}>
                <TableCell><pre className={styles.pre}>{JSON.stringify(r, null, 2)}</pre></TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>

        <Text size={200} style={{ color: "#666" }}>
          If history is not filtered per call, set <b>CRM_CALL_HISTORY_CALL_FK</b> in backend .env.
        </Text>
      </div>
    </Card>
  );
}
