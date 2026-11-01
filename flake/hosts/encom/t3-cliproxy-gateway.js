// Thin pass-through in front of cliproxyapi. T3 Code only learns when a Claude
// usage limit resets from a gateway-style error, and Claude Code emits no
// rate_limit_event for third-party endpoints, so cliproxyapi's 429 (with a
// Retry-After header) is rewritten into the 503 shape T3 parses:
//   [x] [429]: {"type":"error","error":{"type":"rate_limit_error",...}} (reset after 1h2m3s)
// x-should-retry stops Claude Code from retrying the rewritten error.
const http = require("http");

const upstream = new URL(process.env.UPSTREAM);
const port = Number(process.env.PORT);

function duration(seconds) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  return `${h ? `${h}h` : ""}${m ? `${m}m` : ""}${s || !(h || m) ? `${s}s` : ""}`;
}

http
  .createServer((req, res) => {
    const proxied = http.request(
      {
        hostname: upstream.hostname,
        port: upstream.port || 80,
        path: req.url,
        method: req.method,
        headers: { ...req.headers, host: upstream.host },
      },
      (up) => {
        const retryAfter = Number(up.headers["retry-after"]);
        if (up.statusCode !== 429 || !(retryAfter > 0)) {
          res.writeHead(up.statusCode, up.headers);
          up.pipe(res);
          return;
        }
        const chunks = [];
        up.on("data", (c) => chunks.push(c));
        up.on("end", () => {
          const body = Buffer.concat(chunks).toString().replace(/[\r\n]+/g, " ").trim();
          if (!body.startsWith('{"type":"error","error":{"type":"rate_limit_error",')) {
            res.writeHead(429, up.headers);
            res.end(Buffer.concat(chunks));
            return;
          }
          res.writeHead(503, { "content-type": "text/plain", "x-should-retry": "false" });
          res.end(`[cliproxyapi] [429]: ${body} (reset after ${duration(Math.ceil(retryAfter))})`);
        });
      },
    );
    proxied.on("error", (err) => {
      res.writeHead(502, { "content-type": "text/plain" });
      res.end(`cliproxyapi unreachable: ${err.message}`);
    });
    req.pipe(proxied);
  })
  .listen(port, "127.0.0.1");
