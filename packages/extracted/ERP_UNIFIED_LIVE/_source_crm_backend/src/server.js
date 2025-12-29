const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const dotenv = require("dotenv");
const pinoHttp = require("pino-http");
const { requestContextMiddleware } = require("./middleware/requestContext");
const { errorHandler } = require("./middleware/errorHandler");
const { createLogger } = require("./utils/logger");

dotenv.config();

const app = express();
const logger = createLogger();

app.use(pinoHttp({ logger }));
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: process.env.REQUEST_BODY_LIMIT || "2mb" }));

// Context: picks DB connection based on X-Service-Center
app.use(requestContextMiddleware);

// Routes
app.get("/health", (req, res) => res.json({ ok: true, time: new Date().toISOString() }));
app.use("/meta", require("./routes/meta"));
app.use("/crm", require("./routes/crm"));

app.use(errorHandler);

const port = Number(process.env.PORT || 8080);
app.listen(port, () => {
  logger.info({ port }, "CRM backend started");
});
