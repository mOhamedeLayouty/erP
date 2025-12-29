import { Router } from 'express';
export function meRouter() {
    const r = Router();
    r.get('/me', (req, res) => {
        return res.json({ ok: true, data: req.user ?? null });
    });
    return r;
}
