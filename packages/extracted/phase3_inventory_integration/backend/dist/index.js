import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import pinoHttp from 'pino-http';
import { logger } from './shared/logger.js';
import { buildRoutes } from './routes.js';
import { errorHandler } from './shared/error-handler.js';
import { auditMiddleware } from './shared/audit.js';
const app = express();
app.use(pinoHttp({ logger }));
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN ?? '*' }));
app.use(express.json({ limit: '4mb' }));
// Phase 3.2: audit writes (file sink by default)
app.use(auditMiddleware());
buildRoutes(app);
app.use(errorHandler);
const port = Number(process.env.PORT ?? 8080);
app.listen(port, () => {
    logger.info({ port }, 'ERP Backend v3 (Phase 3.2) running');
});
