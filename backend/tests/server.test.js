const { test } = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const { createApp } = require('../server');

function startServer(db) {
  return new Promise((resolve, reject) => {
    const server = createApp(db).listen(0, () => resolve(server));
    server.on('error', reject);
  });
}

function get(server, path) {
  return new Promise((resolve, reject) => {
    const { port } = server.address();
    http.get(`http://127.0.0.1:${port}${path}`, (res) => {
      let body = '';
      res.on('data', (chunk) => { body += chunk; });
      res.on('end', () => resolve({ status: res.statusCode, body }));
    }).on('error', reject);
  });
}

test('GET / returns running message', async (t) => {
  const server = await startServer({ query: async () => [[]] });
  t.after(() => server.close());
  const { status, body } = await get(server, '/');
  assert.strictEqual(status, 200);
  assert.ok(body.includes('running'));
});

test('GET /api/health returns ok', async (t) => {
  const server = await startServer({ query: async () => [[{ now: new Date() }]] });
  t.after(() => server.close());
  const { status, body } = await get(server, '/api/health');
  assert.strictEqual(status, 200);
  assert.strictEqual(JSON.parse(body).status, 'ok');
});

test('GET /api/health returns 500 on db error', async (t) => {
  const server = await startServer({ query: async () => { throw new Error('db fail'); } });
  t.after(() => server.close());
  const { status, body } = await get(server, '/api/health');
  assert.strictEqual(status, 500);
  assert.strictEqual(JSON.parse(body).status, 'error');
});

test('GET /api/visitors returns visitor list', async (t) => {
  const visitors = [{ id: 1, visited_at: new Date() }];
  let calls = 0;
  const db = { query: async () => (calls++ === 0 ? [[]] : [visitors]) };
  const server = await startServer(db);
  t.after(() => server.close());
  const { status, body } = await get(server, '/api/visitors');
  assert.strictEqual(status, 200);
  const data = JSON.parse(body);
  assert.ok(Array.isArray(data.visitors));
  assert.strictEqual(data.visitors.length, 1);
});

test('GET /api/visitors returns 500 on db error', async (t) => {
  const server = await startServer({ query: async () => { throw new Error('db fail'); } });
  t.after(() => server.close());
  const { status, body } = await get(server, '/api/visitors');
  assert.strictEqual(status, 500);
  assert.strictEqual(JSON.parse(body).status, 'error');
});
