#!/usr/bin/env node

const path = require("path");
const { execFileSync } = require("child_process");
const { CREDENTIALS_ENV, loadEnv, readEnv, setEnv, writeEnv } = require("./env-utils");

loadEnv(CREDENTIALS_ENV);

if (process.env.USER_ID && (process.env.SUB_ACCOUNT_NORMAL || process.env.SUB_ACCOUNT_MARGIN)) {
  console.log("✅ Credentials already set"); process.exit(0);
}

const { FINHAY_API_KEY, FINHAY_API_SECRET } = process.env;
if (!FINHAY_API_KEY || !FINHAY_API_SECRET) { console.error("ERROR: FINHAY_API_KEY and FINHAY_API_SECRET required"); process.exit(1); }

const request = (method, endpoint) =>
  JSON.parse(execFileSync("node", [path.join(__dirname, "request.js"), method, endpoint], { encoding: "utf8" }));

try {
  let env = readEnv(CREDENTIALS_ENV);

  const uid = request("GET", "/users/v1/users/me").result?.user_id;
  if (!uid) { console.error("ERROR: user_id missing in response"); process.exit(1); }
  env = setEnv(env, "USER_ID", uid);

  for (const sba of request("GET", `/users/v1/users/${uid}/sub-accounts`).result ?? []) {
    const t = (sba.type || "unknown").toUpperCase();
    env = setEnv(env, `SUB_ACCOUNT_${t}`, sba.id);
    env = setEnv(env, `SUB_ACCOUNT_EXT_${t}`, sba.sub_account_ext);
  }

  writeEnv(CREDENTIALS_ENV, env);
  console.log("✅ Credentials updated successfully");
} catch (e) {
  console.error("ERROR:", e.message);
  process.exit(1);
}
