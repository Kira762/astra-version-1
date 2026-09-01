
















interface Env {}

const OWNER_REPO = "Kira762/astra-version-1";
const EDGE_TTL = 300;
const CACHE_EPOCH = 2;

type Channel = {
  asset: string;
  source: string;
};

const CHANNELS: Record<string, Channel> = {
  "/gen2": {
    asset: `https:
    source: "releases/latest",
  },
  "/gen2-preview": {
    asset: `https:
    source: "releases/preview",
  },
};

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("-- Method not allowed\n", {
        status: 405,
        headers: { "content-type": "text/plain; charset=utf-8" },
      });
    }




    const path = url.pathname.replace(/\/+$/, "") || "/";
    const channel = CHANNELS[path];

    if (!channel) {
      return new Response("-- Not found\n", {
        status: 404,
        headers: { "content-type": "text/plain; charset=utf-8" },
      });
    }









    const cacheKey = new Request(`${url.origin}${path}?e=${CACHE_EPOCH}`, { method: "GET" });
    const cache = caches.default;



    const bypass = url.searchParams.get("__fresh") === "1";

    const cached = bypass ? undefined : await cache.match(cacheKey);
    if (cached) return cached;




    const upstream = await fetch(channel.asset, { redirect: "follow" });

    if (!upstream.ok) {



      const what = path === "/gen2-preview" ? "No Astra Gen2 preview build is published" : "Astra Gen2 is unavailable right now";
      return new Response(`-- ${what}, try again shortly\n`, {
        status: 502,
        headers: {
          "content-type": "text/plain; charset=utf-8",
          "cache-control": "no-store",

          "x-astra-upstream": String(upstream.status),
        },
      });
    }

    const response = new Response(await upstream.text(), {
      headers: {
        "content-type": "text/plain; charset=utf-8",
        "cache-control": `public, max-age=${EDGE_TTL}`,
        "x-astra-source": channel.source,
      },
    });

    ctx.waitUntil(cache.put(cacheKey, response.clone()));
    return response;
  },
};
