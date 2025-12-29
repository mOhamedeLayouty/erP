/**
 * Stock Control System (Inventory proper) – derived from unified_sql_map.csv
 *
 * IMPORTANT:
 * - Keep tables unqualified here; repo will qualify with DBA. by default.
 */
export const STOCK_CONTROL_TABLES = {
  items: 'sc_item',
  itemGroups: 'sc_item_grp',
  stores: 'sc_store',
  vendors: 'vendors',
  buyOrderHeader: 'sc_buy_order_header',
  buyOrderDetail: 'sc_buy_order_detail',
  creditHeader: 'sc_credit_header',
  creditDetail: 'sc_credit_detail',
  debitHeader: 'sc_debit_header',
  debitDetail: 'sc_debit_detail',
  transferDetail: 'sc_transfer_detail',
  balance: 'sc_balance',
  transaction: 'sc_transaction'
} as const;

export type StockControlTableKey = keyof typeof STOCK_CONTROL_TABLES;
