export const INVOICING_TABLES = {
  "header": {
    "table": "DBA.ws_InvoiceHeader",
    "columns": [
      "InvoiceID",
      "InvoiceType",
      "InvoiceDate",
      "CustomerID",
      "EqptID",
      "Status",
      "Receptionist",
      "user_id",
      "service_center",
      "location_id"
    ]
  },
  "detail": {
    "table": "DBA.ws_InvoiceDetail",
    "columns": [
      "InvoiceID",
      "ItemID",
      "Notes"
    ]
  }
} as const;
