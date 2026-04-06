#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const os = require("os");
const { REF_ENV, loadEnv, normToken, readEnv, writeEnv } = require("./env-utils");
const { download, json, text } = require("./http-utils");

const REPO = "finhay-pro/finhay-skills-hub";
const BRANCH = "main";
const RAW = `https://raw.githubusercontent.com/${REPO}/${BRANCH}`;
const API = `https://api.github.com/repos/${REPO}`;
const TTL = 12 * 60 * 60 * 1000;

const nSkill = process.argv[2];
if (!nSkill) { console.error("Usage: sync.sh <skill>"); process.exit(1); }

let ROOT = __dirname;
while (path.basename(ROOT) !== "skills") {
  const parent = path.dirname(ROOT);
  if (parent === ROOT) { console.error("ERROR: skills directory not found"); process.exit(1); }
  ROOT = parent;
}

const SKILL_DIR = path.join(ROOT, nSkill);
const SHARED_DIR = path.join(ROOT, "_shared");

if (!fs.existsSync(path.join(SKILL_DIR, "SKILL.md"))) {
  console.error(`ERROR: skill not found: ${nSkill}`); process.exit(1);
}

loadEnv(REF_ENV);

const replaceDir = (src, dest) => {
  if (!fs.existsSync(src)) return;
  fs.rmSync(dest, { recursive: true, force: true });
  fs.cpSync(src, dest, { recursive: true });
};

const syncComponent = async ({ name, destDir, prefix, blobs, env, key }) => {
  const ver = await text(`${RAW}/skills/${prefix}/.version`);
  const files = blobs.filter(f => f.path.startsWith(`skills/${prefix}/`)).map(f => f.path);
  const tmp = fs.mkdtempSync(path.join(os.tmpdir(), `sync-${name}-`));
  try {
    await download({ files, baseUrl: RAW, outDir: tmp });
    replaceDir(path.join(tmp, name), destDir);
  } finally {
    fs.rmSync(tmp, { recursive: true, force: true });
  }
  env[key] = Date.now();
  console.log(`${name}: synced (${ver})`);
};

(async () => {
  const now = Date.now();
  const env = readEnv(REF_ENV);

  const sharedKey = "SHARED_SYNC_AT";
  const skillKey = `SKILL_${normToken(nSkill)}_SYNC_AT`;

  const sharedStale = !env[sharedKey] || now - Number(env[sharedKey]) > TTL;
  const skillStale  = !env[skillKey]  || now - Number(env[skillKey])  > TTL;

  if (!sharedStale && !skillStale) { console.log(`${nSkill}: up-to-date`); return; }

  const blobs = (await json(`${API}/git/trees/${BRANCH}?recursive=1`)).tree.filter(f => f.type === "blob");

  if (sharedStale) await syncComponent({ name: "_shared", destDir: SHARED_DIR, prefix: "_shared", blobs, env, key: sharedKey });
  if (skillStale)  await syncComponent({ name: nSkill,    destDir: SKILL_DIR,  prefix: nSkill,    blobs, env, key: skillKey });

  writeEnv(REF_ENV, env);
})().catch(e => { console.error("ERROR:", e.message); process.exit(1); });
