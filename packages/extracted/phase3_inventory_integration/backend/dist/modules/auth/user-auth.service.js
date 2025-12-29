import fs from 'node:fs';
import path from 'node:path';
import jwt from 'jsonwebtoken';
import { getUserByLogin } from './user-auth.repo.js';
import { sha256Hex } from '../../shared/crypto.js';
import { badRequest, unauthorized } from '../../shared/errors.js';
function loadJsonIfExists(p) {
    const abs = path.isAbsolute(p) ? p : path.join(process.cwd(), p);
    if (!fs.existsSync(abs))
        return null;
    return JSON.parse(fs.readFileSync(abs, 'utf-8'));
}
function loadUserRoles() {
    return loadJsonIfExists(process.env.USER_ROLES_JSON_PATH ?? './config/user_roles.json') ?? {};
}
function loadUserSecrets() {
    return loadJsonIfExists(process.env.USER_SECRETS_JSON_PATH ?? './config/user_secrets.json') ?? {};
}
function resolveRoles(user) {
    const dbRoleCol = process.env.USER_COL_ROLE;
    const idCol = process.env.USER_COL_ID;
    const nameCol = process.env.USER_COL_NAME;
    if (dbRoleCol && user[dbRoleCol] != null) {
        const v = String(user[dbRoleCol]).trim();
        if (v)
            return v.split(/[;,]/).map(s => s.trim()).filter(Boolean);
    }
    const cfg = loadUserRoles();
    const uid = idCol ? user[idCol] : undefined;
    const uname = nameCol ? user[nameCol] : undefined;
    const rolesById = (uid && cfg.by_user_id?.[String(uid)]) ?? null;
    if (rolesById?.length)
        return rolesById;
    const rolesByName = (uname && cfg.by_user_name?.[String(uname).toLowerCase()]) ?? null;
    if (rolesByName?.length)
        return rolesByName;
    return [];
}
function isInactiveFlag(v) {
    if (v == null)
        return false;
    const s = String(v).toLowerCase().trim();
    return ['false', '0', 'n', 'no', 'disabled', 'inactive', 'deleted', 'del'].includes(s);
}
export function signAccessToken(payload) {
    const ttl = process.env.ACCESS_TOKEN_TTL ?? '2h';
    const opts = {
        issuer: process.env.JWT_ISSUER,
        audience: process.env.JWT_AUDIENCE,
        expiresIn: ttl
    };
    return jwt.sign(payload, (process.env.JWT_SECRET ?? 'change_me'), opts);
}
export function signRefreshToken(payload) {
    const ttl = process.env.REFRESH_TOKEN_TTL ?? '7d';
    const opts = {
        issuer: process.env.JWT_ISSUER,
        audience: process.env.JWT_AUDIENCE,
        expiresIn: ttl
    };
    return jwt.sign({ ...payload, token_type: 'refresh' }, (process.env.JWT_SECRET ?? 'change_me'), opts);
}
function verifyPassword(stored, password, strategy) {
    const s = (strategy ?? 'plain').toLowerCase();
    if (s === 'plain')
        return stored === password;
    if (s === 'sha256')
        return stored.toLowerCase() === sha256Hex(password).toLowerCase();
    throw new Error('Unsupported PASSWORD_STRATEGY: ' + s);
}
export async function login(user_name, password) {
    if (!user_name)
        throw badRequest('user_name is required');
    if (!password)
        throw badRequest('password is required');
    const user = await getUserByLogin(user_name);
    if (!user)
        throw unauthorized('Invalid credentials');
    const activeCol = process.env.USER_COL_ACTIVE;
    if (activeCol && isInactiveFlag(user[activeCol])) {
        throw unauthorized('User is inactive');
    }
    const idCol = process.env.USER_COL_ID;
    const nameCol = process.env.USER_COL_NAME;
    const uid = idCol ? String(user[idCol]) : user_name;
    const uname = nameCol ? String(user[nameCol]) : user_name;
    const passCol = process.env.USER_COL_PASSWORD;
    // Path A: Password column exists in DB
    if (passCol) {
        const stored = user[passCol];
        if (stored == null)
            throw unauthorized('Invalid credentials');
        const strategy = process.env.PASSWORD_STRATEGY ?? 'plain';
        if (!verifyPassword(String(stored), password, strategy))
            throw unauthorized('Invalid credentials');
    }
    else {
        // Path B: No password column in locked schema -> use external secrets config (file-based)
        const secrets = loadUserSecrets();
        const strategy = secrets.strategy ?? 'sha256';
        const byId = secrets.by_user_id?.[uid] ?? null;
        const byName = secrets.by_user_name?.[uname.toLowerCase()] ?? null;
        const stored = byId ?? byName;
        if (!stored)
            throw unauthorized('Auth not configured (no password column; missing user_secrets)');
        if (!verifyPassword(String(stored), password, strategy))
            throw unauthorized('Invalid credentials');
    }
    const payload = { user_id: uid, user_name: uname, roles: resolveRoles(user) };
    const access_token = signAccessToken(payload);
    const refresh_token = signRefreshToken(payload);
    return { access_token, refresh_token, user: payload };
}
export function refresh(refresh_token) {
    if (!refresh_token)
        throw badRequest('refresh_token is required');
    const decoded = jwt.verify(refresh_token, process.env.JWT_SECRET ?? 'change_me', {
        issuer: process.env.JWT_ISSUER,
        audience: process.env.JWT_AUDIENCE
    });
    if (decoded?.token_type !== 'refresh')
        throw unauthorized('Invalid refresh token');
    const payload = { user_id: decoded.user_id, user_name: decoded.user_name, roles: decoded.roles ?? [] };
    const access_token = signAccessToken(payload);
    return { access_token, user: payload };
}
