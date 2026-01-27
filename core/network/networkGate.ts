import dns from "dns/promises";
import fs from "fs";
import path from "path";

/* ---------- allowlist loading ---------- */

const ALLOWLIST_PATHS = [
  "/etc/continue/allowlist.json",
  path.join(__dirname, "../../allowlist.json"),
];

function loadAllowlist(): { cidrs: string[] } {
  for (const p of ALLOWLIST_PATHS) {
    try {
      return JSON.parse(fs.readFileSync(p, "utf8"));
    } catch {}
  }

  // PoC default: only local + private ranges
  return {
    cidrs: ["127.0.0.0/8", "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"],
  };
}

const allowlist = loadAllowlist();

/* ---------- CIDR helpers ---------- */

function ipToNum(ip: string) {
  return ip.split(".").reduce((acc, p) => acc * 256 + Number(p), 0) >>> 0;
}

function maskToNum(len: number) {
  return len === 0 ? 0 : (~0 << (32 - len)) >>> 0;
}

function ipInCidrs(ip: string, cidrs: string[]) {
  const ipNum = ipToNum(ip);
  return cidrs.some((c) => {
    const [net, len] = c.split("/");
    return (ipNum & maskToNum(Number(len))) === ipToNum(net);
  });
}

/* ---------- public API ---------- */

export async function validateHostOrThrow(host: string) {
  // raw IP
  if (/^\d+\.\d+\.\d+\.\d+$/.test(host)) {
    if (!ipInCidrs(host, allowlist.cidrs)) {
      throw new Error("NETWORK_GATE: IP not in allowlist");
    }
    return;
  }

  // DNS name
  const ips = await dns.resolve4(host).catch(() => {
    throw new Error("NETWORK_GATE: DNS resolution blocked");
  });

  if (!ips.some((ip) => ipInCidrs(ip, allowlist.cidrs))) {
    throw new Error("NETWORK_GATE: host resolves outside allowlist");
  }
}

/* ---------- global hardening (used by plugins) ---------- */

export function hardenGlobals() {
  const g: any = global as any;

  if (g.__networkGatePatched) return;
  g.__networkGatePatched = true;

  const originalFetch = g.fetch;

  g.fetch = async (url: string, opts?: any) => {
    const host = new URL(url).hostname;
    await validateHostOrThrow(host);
    if (typeof originalFetch === "function") {
      return originalFetch(url, opts);
    }
    throw new Error("NETWORK_GATE: fetch disabled");
  };

  try {
    const http = require("http");
    const https = require("https");
    http.request = () => {
      throw new Error("NETWORK_GATE: http blocked");
    };
    https.request = () => {
      throw new Error("NETWORK_GATE: https blocked");
    };
  } catch {}
}
