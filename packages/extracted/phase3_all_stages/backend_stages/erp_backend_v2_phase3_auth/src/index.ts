import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import pinoHttp from 'pino-http';

import { logger } from './shared/logger.js';
import { buildRoutes } from './routes.js';
import { errorHandler } from './shared/error-handler.js';

const app = express();

app.use(pinoHttp({ logger }));
app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN ?? '*' }));
app.use(express.json({ limit: '2mb' }));

buildRoutes(app);

app.use(errorHandler);

const port = Number(process.env.PORT ?? 8080);
app.listen(port, () => {
  logger.info({ port }, 'ERP Backend v1 running');
});
