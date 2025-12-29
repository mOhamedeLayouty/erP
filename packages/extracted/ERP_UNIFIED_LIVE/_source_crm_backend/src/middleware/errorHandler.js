function errorHandler(err, req, res, next) {
  req.log.error({ err }, "Unhandled error");
  const status = err.statusCode || err.status || 500;
  res.status(status).json({
    error: {
      message: err.publicMessage || err.message || "Internal Server Error",
      code: err.code || "ERR_INTERNAL"
    }
  });
}

module.exports = { errorHandler };
