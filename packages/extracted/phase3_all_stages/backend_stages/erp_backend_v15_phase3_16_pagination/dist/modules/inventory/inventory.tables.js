export const INVENTORY_TABLES = {
    "stores": {
        "table": "CRM.stores",
        "columns": [
            "store",
            "store_id",
            "client_code"
        ]
    },
    "items": {
        "table": "DBA.fx_item",
        "columns": [
            "asset_code",
            "branch_id",
            "desc_a",
            "desc_e",
            "category",
            "location",
            "department",
            "bar_code",
            "invoic_po",
            "date_purchased",
            "vendor_code",
            "cost",
            "sold_date",
            "sold_to",
            "selling_price",
            "warr_expire",
            "color",
            "made_of",
            "size",
            "shape",
            "year_made",
            "rcl",
            "rcsa",
            "insured",
            "taxable"
        ]
    },
    "transfer_header": {
        "table": "DBA.car_transfer_header",
        "columns": [
            "credit_header",
            "trans_id",
            "manual_number",
            "notes",
            "store_id",
            "vend_code",
            "credit_date",
            "debit_header",
            "store_id_to",
            "trans_time",
            "log_stock",
            "brand",
            "edit_user",
            "post_flag"
        ]
    },
    "transfer_detail": {
        "table": "DBA.car_transfer_detail",
        "columns": [
            "credit_detail",
            "credit_header",
            "vin",
            "log_stock",
            "arrived",
            "km_out",
            "km_in",
            "brand",
            "cert_no",
            "arrival_date",
            "arrival_time",
            "vehicle_id",
            "cost"
        ]
    }
};
