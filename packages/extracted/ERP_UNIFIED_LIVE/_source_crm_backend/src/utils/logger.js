const pino = require("pino");

function createLogger() {
  return pino({
    level: process.env.NODE_ENV === "production" ? "info" : "debug",
    redact: {
      paths: ["req.headers.authorization", "req.headers.cookie"],
      remove: true
    }
  });
}

module.exports = { createLogger };
