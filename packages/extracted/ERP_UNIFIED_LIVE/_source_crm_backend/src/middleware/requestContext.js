const { getDbForServiceCenter } = require("../services/branchDb");

function requestContextMiddleware(req, res, next) {
  const serviceCenterRaw = req.header("X-Service-Center");
  if (!serviceCenterRaw) {
    return res.status(400).json({ error: { message: "Missing header: X-Service-Center" } });
  }

  const serviceCenter = Number(serviceCenterRaw);
  if (!Number.isFinite(serviceCenter)) {
    return res.status(400).json({ error: { message: "Invalid X-Service-Center" } });
  }

  const locationIdRaw = req.header("X-Location-Id");
  const locationId = locationIdRaw ? Number(locationIdRaw) : null;
  if (locationIdRaw && !Number.isFinite(locationId)) {
    return res.status(400).json({ error: { message: "Invalid X-Location-Id" } });
  }

  req.context = { serviceCenter, locationId };

  // Lazy DB getter (connect per request). You can replace with pooling later.
  req.getDb = () => getDbForServiceCenter(serviceCenter);

  next();
}

module.exports = { requestContextMiddleware };
