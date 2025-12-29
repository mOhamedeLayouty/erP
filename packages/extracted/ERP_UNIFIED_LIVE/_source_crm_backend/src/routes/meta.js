const express = require("express");
const { listServiceCenters } = require("../services/branchDb");

const router = express.Router();

router.get("/service-centers", (req, res) => {
  res.json({ service_centers: listServiceCenters() });
});

module.exports = router;
