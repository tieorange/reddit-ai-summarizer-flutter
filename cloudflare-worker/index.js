const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default {
  async fetch(request) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    const url = new URL(request.url);

    if (url.pathname === '/reddit') {
      const path = url.searchParams.get('path');
      if (!path) return new Response('Missing path', { status: 400 });

      const res = await fetch(`https://www.reddit.com${path}`, {
        headers: { 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36' }
      });
      const body = await res.text();
      return new Response(body, { headers: { 'Content-Type': 'application/json', ...CORS_HEADERS } });
    }

    if (url.pathname === '/ai') {
      const res = await fetch('https://api.sambanova.ai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': request.headers.get('Authorization') ?? '',
        },
        body: request.body,
      });
      const body = await res.text();
      return new Response(body, { status: res.status, headers: { 'Content-Type': 'application/json', ...CORS_HEADERS } });
    }

    return new Response('Not found', { status: 404 });
  }
};
