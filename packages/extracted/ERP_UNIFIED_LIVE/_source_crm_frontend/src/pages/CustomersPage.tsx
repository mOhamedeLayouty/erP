import React from "react";
import { Link } from "react-router-dom";
import {
  Button, Card, CardHeader, CardPreview, Input, Spinner, Table, TableBody, TableCell,
  TableHeader, TableHeaderCell, TableRow, Text, makeStyles
} from "@fluentui/react-components";
import { Search24Regular, Add24Regular } from "@fluentui/react-icons";
import { useServiceCenter } from "../state/serviceCenter";
import { apiGet, apiPost } from "../utils/api";
import JsonEditor from "../components/JsonEditor";

type CustomersResp = { page: number; pageSize: number; rows: any[] };

const useStyles = makeStyles({
  grid: { display: "grid", gridTemplateColumns: "1.2fr 1fr", gap: 12 },
  @media (max-width: 900): { grid: { gridTemplateColumns: "1fr" } },
  row: { display: "flex", gap: 10, alignItems: "center", flexWrap: "wrap" },
  pre: { margin: 0, whiteSpace: "pre-wrap", fontSize: 12, lineHeight: 1.35 }
});

function guessId(r: any, fallback: any) {
  return r.customer_id ?? r.CustomerID ?? r.id ?? r.ID ?? r.customerid ?? r.CustomerId ?? r.code ?? r.Code ?? fallback;
}

export default function CustomersPage() {
  const styles = useStyles();
  const { serviceCenter } = useServiceCenter();
  const sc = serviceCenter ?? 1;

  const [page, setPage] = React.useState(1);
  const [pageSize, setPageSize] = React.useState(50);
  const [rows, setRows] = React.useState<any[]>([]);
  const [loading, setLoading] = React.useState(false);
  const [err, setErr] = React.useState<string | null>(null);

  const [search, setSearch] = React.useState("");
  const searchNorm = search.trim().toLowerCase();

  const [createOpen, setCreateOpen] = React.useState(false);
  const [createPayload, setCreatePayload] = React.useState<any>({});

  const load = async () => {
    setLoading(true);
    setErr(null);
    try {
      const q = encodeURIComponent(search.trim());
      // Backend may or may not apply q. UI also filters locally.
      const data = await apiGet<CustomersResp>(`/crm/customers?page=${page}&pageSize=${pageSize}&q=${q}`, sc);
      setRows(data.rows || []);
    } catch (e: any) {
      setErr(e?.message || "Failed to load customers");
    } finally {
      setLoading(false);
    }
  };

  React.useEffect(() => { load().catch(() => {}); }, [page, pageSize, sc]);

  const filtered = React.useMemo(() => {
    if (!searchNorm) return rows;
    return rows.filter(r => JSON.stringify(r).toLowerCase().includes(searchNorm));
  }, [rows, searchNorm]);

  const create = async () => {
    setErr(null);
    try {
      await apiPost(`/crm/customers`, createPayload, sc);
      setCreateOpen(false);
      setCreatePayload({});
      await load();
    } catch (e: any) {
      setErr(e?.message || "Create failed");
    }
  };

  return (
    <div className={styles.grid}>
      <Card>
        <CardHeader
          header={<Text size={600} weight="semibold">Customers</Text>}
          action={
            <Button appearance="secondary" icon={<Add24Regular />} onClick={() => setCreateOpen(v => !v)}>
              {createOpen ? "Close" : "New Customer"}
            </Button>
          }
        />
        <div style={{ padding: 12, display: "grid", gap: 10 }}>
          <div className={styles.row}>
            <Input
              value={search}
              onChange={(_, d) => setSearch(d.value)}
              placeholder="Search (name / phone / any text)…"
              contentBefore={<Search24Regular />}
              style={{ minWidth: 320 }}
            />
            <Input value={String(page)} onChange={(_, d) => setPage(Number(d.value || 1))} placeholder="Page" style={{ width: 110 }} />
            <Input value={String(pageSize)} onChange={(_, d) => setPageSize(Number(d.value || 50))} placeholder="Page size" style={{ width: 120 }} />
            <Button appearance="secondary" onClick={load} disabled={loading}>
              {loading ? "Loading…" : "Reload"}
            </Button>
          </div>

          {err ? <Text style={{ color: "#b00020" }}>{err}</Text> : null}
          {loading ? <Spinner size="tiny" /> : null}

          <Table aria-label="Customers table">
            <TableHeader>
              <TableRow>
                <TableHeaderCell>Customer</TableHeaderCell>
                <TableHeaderCell>Preview</TableHeaderCell>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filtered.map((r, idx) => {
                const id = guessId(r, idx);
                return (
                  <TableRow key={idx}>
                    <TableCell>
                      <Link to={`/customers/${encodeURIComponent(String(id))}`}>
                        Open #{String(id)}
                      </Link>
                    </TableCell>
                    <TableCell>
                      <pre className={styles.pre}>{JSON.stringify(r, null, 2)}</pre>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>

          <Text size={200} style={{ color: "#666" }}>
            Search filters the currently loaded rows instantly. For full DB search across columns, enable backend-side filtering.
          </Text>
        </div>
      </Card>

      <Card>
        <CardHeader
          header={<Text size={500} weight="semibold">Create Customer (JSON)</Text>}
          description={<Text size={200} style={{ color: "#666" }}>JSON keys must match legacy DB columns.</Text>}
        />
        <div style={{ padding: 12, display: "grid", gap: 10 }}>
          {createOpen ? (
            <>
              <JsonEditor value={createPayload} onChange={setCreatePayload} placeholder='{"customer_id":123,"name":"..."}' />
              <div className={styles.row}>
                <Button onClick={create}>Create</Button>
                <Button appearance="secondary" onClick={() => setCreatePayload({})}>Clear</Button>
              </div>
            </>
          ) : (
            <Text size={200} style={{ color: "#666" }}>Click “New Customer” to open the editor.</Text>
          )}
        </div>
      </Card>
    </div>
  );
}
