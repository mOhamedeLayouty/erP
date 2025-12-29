import { Router } from 'express';
import { badRequest } from '../../shared/errors.js';
import { createPurchaseOrder, setPurchaseOrderApproved, createReceipt, postReceipt, createIssue, postIssue, createTransfer, postTransfer, getBalance, } from './stock-ops.repo.js';
/**
 * Stock Operations Workflows
 * - Purchase Orders (sc_buy_order_header/detail)
 * - Receipts / GRN (sc_credit_header/detail)
 * - Issues (sc_debit_header/detail)
 * - Transfers (sc_credit_* + sc_transfer_detail)
 * - Balance Inquiry (sc_balance)
 *
 * Note: Posting/balance effects are expected to be handled by DB rules/triggers.
 */
export function stockOpsRouter(_guard) {
    const r = Router();
    // Purchase Order
    r.post('/po', async (req, res, next) => {
        try {
            const { header, lines } = req.body ?? {};
            const result = await createPurchaseOrder(header ?? {}, lines ?? []);
            res.json(result);
        }
        catch (e) {
            next(e);
        }
    });
    r.put('/po/:id/approve', async (req, res, next) => {
        try {
            const id = Number(req.params.id);
            if (!id)
                throw badRequest('Invalid PO id');
            const { approved, approved_by } = req.body ?? {};
            const result = await setPurchaseOrderApproved(id, approved ? 1 : 0, approved_by ?? null);
            res.json(result);
        }
        catch (e) {
            next(e);
        }
    });
    // Receipt / GRN
    r.post('/receipt', async (req, res, next) => {
        try {
            const { header, lines } = req.body ?? {};
            const result = await createReceipt(header ?? {}, lines ?? []);
            res.json(result);
        }
        catch (e) {
            next(e);
        }
    });
    r.put('/receipt/:id/post', async (req, res, next) => {
        try {
            const id = Number(req.params.id);
            if (!id)
                throw badRequest('Invalid receipt id');
            const { user_name } = req.body ?? {};
            const result = await postReceipt(id, user_name ?? null);
            res.json(result);
        }
        catch (e) {
            next(e);
        }
    });
    // Issue
    r.post('/issue', async (req, res, next) => {
        try {
            const { header, lines } = req.body ?? {};
            const result = await createIssue(header ?? {}, lines ?? []);
            res.json(result);
        }
        catch (e) {
            next(e);
        }
    });
    r.put('/issue/:id/post', async (req, res, next) => {
        try {
            const id = Number(req.params.id);
            if (!id)
                throw badRequest('Invalid issue id');
            const { user_name } = req.body ?? {};
            const result = await postIssue(id, user_name ?? null);
            res.json(result);
        }
        catch (e) {
            next(e);
        }
    });
    // Transfer
    r.post('/transfer', async (req, res, next) => {
        try {
            const { header, lines } = req.body ?? {};
            const result = await createTransfer(header ?? {}, lines ?? []);
            res.json(result);
        }
        catch (e) {
            next(e);
        }
    });
    r.put('/transfer/:id/post', async (req, res, next) => {
        try {
            const id = Number(req.params.id);
            if (!id)
                throw badRequest('Invalid transfer id');
            const { user_name } = req.body ?? {};
            const result = await postTransfer(id, user_name ?? null);
            res.json(result);
        }
        catch (e) {
            next(e);
        }
    });
    // Balance inquiry
    r.get('/balance', async (req, res, next) => {
        try {
            const { store_id, item_id, location_id, service_center, limit } = req.query;
            const result = await getBalance(store_id ? String(store_id) : undefined, item_id ? String(item_id) : undefined, location_id ?? undefined, service_center ?? undefined, limit ? Number(limit) : 500);
            res.json(result);
        }
        catch (e) {
            next(e);
        }
    });
    return r;
}
