import React from "react";
import { Link, useParams } from "react-router-dom";
import {
  Button, Card, CardHeader, Spinner, Table, TableBody, TableCell, TableHeader, TableHeaderCell, TableRow,
  Text, makeStyles
} from "@fluentui/react-components";
import { Edit24Regular, Delete24Regular, Add24Regular } from "@fluentui/react-icons";
import { useServiceCenter } from "../state/serviceCenter";
import { apiDelete, apiGet, apiPost, apiPut } from "../utils/api";
import JsonEditor from "../components/JsonEditor";

const useStyles = makeStyles({
  grid: { display: "grid", gridTemplateColumns: "1.2fr 1fr", gap: 12 },
  @media (max-width: 900): { grid: { gridTemplateColumns: "1fr" } },
  pre: { margin: 0, whiteSpace: "pre-wrap", fontSize: 12, lineHeight: 1.35 }
});

function guessCallId(r: any, fallback: any) {
  return r.call_id ?? r.CallID ?? r.id ?? r.ID ?? r.callid ?? r.CallId ?? fallback;
}

export default function CustomerDetailsPage() {
  const styles = useStyles();
  const { customerId } = useParams();
  const { serviceCenter } = useServiceCenter();
  const sc = serviceCenter ?? 1;

  const [customer, setCustomer] = React.useState<any | null>(null);
  const [calls, setCalls] = React.useState<any[]>([]);
  const [loading, setLoading] = React.useState(false);
  const [err, setErr] = React.useState<string | null>(null);

  const [editPayload, setEditPayload] = React.useState<any>({});
  const [newCallPayload, setNewCallPayload] = React.useState<any>({});
  const [showEdit, setShowEdit] = React.useState(false);
  const [showNewCall, setShowNewCall] = React.useState(false);

  const load = async () => {
    if (!customerId) return;
    setLoading(true);
    setErr(null);
    try {
      const c = await apiGet<any>(`/crm/customers/${encodeURIComponent(customerId)}`, sc);
      setCustomer(c);
      setEditPayload(c);

      const callsResp = await apiGet<any>(`/crm/customers/${encodeURIComponent(customerId)}/calls?page=1&pageSize=50`, sc);
      setCalls(callsResp.rows || []);
    } catch (e: any) {
      setErr(e?.message || "Failed to load customer");
    } finally {
      setLoading(false);
    }
  };

  React.useEffect(() => { load().catch(() => {}); }, [customerId, sc]);

  const save = async () => {
    if (!customerId) return;
    setErr(null);
    try {
      await apiPut(`/crm/customers/${encodeURIComponent(customerId)}`, editPayload, sc);
      setShowEdit(false);
      await load();
    } catch (e: any) {
      setErr(e?.message || "Update failed");
    }
  };

  const del = async () => {
    if (!customerId) return;
    if (!confirm("Delete customer? This is HARD delete against legacy DB.")) return;
    setErr(null);
    try {
      await apiDelete(`/crm/customers/${encodeURIComponent(customerId)}`, sc);
      window.location.href = "/customers";
    } catch (e: any) {
      setErr(e?.message || "Delete failed");
    }
  };

  const createCall = async () => {
    if (!customerId) return;
    setErr(null);
    try {
      await apiPost(`/crm/customers/${encodeURIComponent(customerId)}/calls`, newCallPayload, sc);
      setShowNewCall(false);
      setNewCallPayload({});
      await load();
    } catch (e: any) {
      setErr(e?.message || "Create call failed");
    }
  };

  return (
    <div className={styles.grid}>
      <Card>
        <CardHeader
          header={<Text size={600} weight="semibold">Customer #{customerId}</Text>}
          description={<Link to="/customers">← Back to Customers</Link>}
          action={
            <div style={{ display: "flex", gap: 8 }}>
              <Button appearance="secondary" icon={<Edit24Regular />} onClick={() => setShowEdit(v => !v)}>
                {showEdit ? "Close" : "Edit JSON"}
              </Button>
              <Button icon={<Delete24Regular />} onClick={del}>Delete</Button>
            </div>
          }
        />
        <div style={{ padding: 12, display: "grid", gap: 10 }}>
          {err ? <Text style={{ color: "#b00020" }}>{err}</Text> : null}
          {loading ? <Spinner size="tiny" /> : null}
          {customer ? <pre className={styles.pre}>{JSON.stringify(customer, null, 2)}</pre> : <Text size={200} style={{ color: "#666" }}>No data</Text>}

          {showEdit ? (
            <>
              <Text size={500} weight="semibold">Edit Customer</Text>
              <JsonEditor value={editPayload} onChange={setEditPayload} />
              <Button onClick={save}>Save</Button>
            </>
          ) : null}
        </div>
      </Card>

      <Card>
        <CardHeader
          header={<Text size={500} weight="semibold">Calls</Text>}
          action={
            <Button appearance="secondary" icon={<Add24Regular />} onClick={() => setShowNewCall(v => !v)}>
              {showNewCall ? "Close" : "New Call"}
            </Button>
          }
        />
        <div style={{ padding: 12, display: "grid", gap: 10 }}>
          {showNewCall ? (
            <>
              <JsonEditor value={newCallPayload} onChange={setNewCallPayload} placeholder='{"call_date":"2025-12-26","notes":"..."}' />
              <Button onClick={createCall}>Create Call</Button>
            </>
          ) : null}

          <Table aria-label="Calls table">
            <TableHeader>
              <TableRow>
                <TableHeaderCell>Call</TableHeaderCell>
                <TableHeaderCell>Preview</TableHeaderCell>
              </TableRow>
            </TableHeader>
            <TableBody>
              {calls.map((r, idx) => {
                const id = guessCallId(r, idx);
                return (
                  <TableRow key={idx}>
                    <TableCell>
                      <Link to={`/calls/${encodeURIComponent(String(id))}`}>Open Call #{String(id)}</Link>
                    </TableCell>
                    <TableCell><pre className={styles.pre}>{JSON.stringify(r, null, 2)}</pre></TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>

          <Text size={200} style={{ color: "#666" }}>
            If calls are not filtered per customer, set <b>CRM_CALLS_CUSTOMER_FK</b> in backend .env.
          </Text>
        </div>
      </Card>
    </div>
  );
}
