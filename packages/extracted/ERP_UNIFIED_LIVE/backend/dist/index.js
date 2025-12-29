import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import pinoHttp from 'pino-http';
import { logger } from './shared/logger.js';
import { buildRoutes } from './routes.js';
import { errorHandler } from './shared/error-handler.js';
import { auditMiddleware } from './shared/audit.js';
import path from 'node:path';
import fs from 'node:fs';
const app = express();
app.use(pinoHttp({ logger }));
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN ?? '*' }));
app.use(express.json({ limit: '4mb' }));
// Phase 3.2: audit writes (file sink by default)
app.use(auditMiddleware());
buildRoutes(app);
// Optional: serve unified UI (built frontend) from the same port for demo.
// - Set SERVE_FRONTEND=true
// - Build frontend to ../frontend/dist (default) or set FRONTEND_DIST
{
    const serve = (process.env.SERVE_FRONTEND ?? 'false').toLowerCase() === 'true';
    if (serve) {
        const distRel = process.env.FRONTEND_DIST ?? '../frontend/dist';
        const dist = path.isAbsolute(distRel) ? distRel : path.join(process.cwd(), distRel);
        if (fs.existsSync(dist)) {
            app.use(express.static(dist));
            app.get('*', (_req, res) => res.sendFile(path.join(dist, 'index.html')));
        }
    }
}
app.use(errorHandler);
const port = Number(process.env.PORT ?? 8080);
app.listen(port, () => {
    logger.info({ port }, 'ERP Backend (Unified Phase 3.16) running');
});
