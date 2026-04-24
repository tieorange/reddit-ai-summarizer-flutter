export default async (request) => {
  const url = new URL(request.url);
  const redditPath = url.searchParams.get('path');

  if (!redditPath) {
    return new Response('Missing path', { status: 400 });
  }

  const redditUrl = `https://www.reddit.com${redditPath}`;
  const jinaUrl = `https://r.jina.ai/${redditUrl}`;

  const response = await fetch(jinaUrl, {
    headers: {
      'Accept': 'application/json',
      'X-Return-Format': 'json',
    },
  });

  if (!response.ok) {
    return new Response(JSON.stringify({ error: `Jina fetch failed: ${response.status}` }), {
      status: response.status,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  }

  const body = await response.text();
  return new Response(body, {
    status: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  });
};

export const config = { path: '/reddit-proxy' };
