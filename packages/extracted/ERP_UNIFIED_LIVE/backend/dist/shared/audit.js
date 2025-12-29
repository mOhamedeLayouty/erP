import fs from 'node:fs';
import path from 'node:path';
function ensureDir(p) {
    if (!fs.existsSync(p))
        fs.mkdirSync(p, { recursive: true });
}
export function fileAuditSink(filePath = './logs/audit.ndjson') {
    const abs = path.isAbsolute(filePath) ? filePath : path.join(process.cwd(), filePath);
    ensureDir(path.dirname(abs));
    return (ev) => {
        fs.appendFileSync(abs, JSON.stringify(ev) + '\n', 'utf8');
    };
}
export function auditMiddleware() {
    const sinkPath = process.env.AUDIT_FILE_PATH ?? './logs/audit.ndjson';
    const sink = fileAuditSink(sinkPath);
    return (req, res, next) => {
        // log only mutating requests
        const method = req.method.toUpperCase();
        if (['GET', 'HEAD', 'OPTIONS'].includes(method))
            return next();
        const started = new Date();
        res.on('finish', () => {
            const ev = {
                ts: started.toISOString(),
                user_id: req.user?.user_id,
                user_name: req.user?.user_name,
                method,
                path: req.path,
                ip: req.ip,
                status: res.statusCode,
                body: req.body
            };
            try {
                sink(ev);
            }
            catch { /* ignore */ }
        });
        return next();
    };
}
