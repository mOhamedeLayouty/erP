-- Phase 3.14 - Audit Trail Table
-- SQL Anywhere syntax (should work on SA 17)
CREATE TABLE IF NOT EXISTS inv_request_audit (
  audit_id    INTEGER NOT NULL DEFAULT AUTOINCREMENT,
  entity      VARCHAR(10) NOT NULL,      -- 'ISSUE' | 'RETURN'
  header_id   INTEGER NOT NULL,
  line_id     INTEGER NULL,
  action      VARCHAR(30) NOT NULL,
  reason      VARCHAR(50) NULL,
  note        VARCHAR(255) NULL,
  actor       VARCHAR(100) NULL,
  at_time     TIMESTAMP NOT NULL DEFAULT CURRENT TIMESTAMP,
  PRIMARY KEY (audit_id)
);

CREATE INDEX IF NOT EXISTS idx_inv_audit_hdr ON inv_request_audit(entity, header_id, audit_id);
