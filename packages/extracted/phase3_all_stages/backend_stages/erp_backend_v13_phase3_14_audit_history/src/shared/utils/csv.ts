export function toCsv(rows: any[]): string {
  if (!rows || !rows.length) return '';
  const cols = Array.from(new Set(rows.flatMap(r => Object.keys(r ?? {}))));
  const esc = (v: any) => {
    if (v === null || typeof v === 'undefined') return '';
    const s = String(v);
    if (/[",\n\r]/.test(s)) return '"' + s.replaceAll('"', '""') + '"';
    return s;
  };
  const head = cols.join(',');
  const body = rows.map(r => cols.map(c => esc((r as any)[c])).join(',')).join('\n');
  return head + '\n' + body + '\n';
}
