import assert from 'node:assert/strict';

const authHost = process.env.FIREBASE_AUTH_EMULATOR_HOST;
const firestoreHost = process.env.FIRESTORE_EMULATOR_HOST;
const projectId = 'demo-tidyday';

assert.ok(authHost && firestoreHost, 'Run this test with firebase emulators:exec.');
assert.equal(process.env.GCLOUD_PROJECT, projectId);

const database = `projects/${projectId}/databases/(default)`;
const firestore = `http://${firestoreHost}/v1/${database}/documents`;

async function request(url, { method = 'GET', token, body } = {}) {
  const headers = {};
  if (token) headers.Authorization = `Bearer ${token}`;
  if (body) headers['Content-Type'] = 'application/json';
  return fetch(url, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
    signal: AbortSignal.timeout(10000),
  });
}

async function expectStatus(response, status, scenario) {
  const result = await response;
  assert.equal(result.status, status, `${scenario} (HTTP ${result.status})`);
  console.log(`PASS ${scenario}`);
  return result;
}

async function newAccount() {
  const response = await request(
    `http://${authHost}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-key`,
    { method: 'POST', body: { returnSecureToken: true } },
  );
  assert.equal(response.status, 200);
  return response.json();
}

function createTask(path, token, fields) {
  return request(`${firestore}:commit`, {
    method: 'POST',
    token,
    body: {
      writes: [{
        update: { name: `${database}/documents/${path}`, fields },
        updateTransforms: [{ fieldPath: 'createdAt', setToServerValue: 'REQUEST_TIME' }],
      }],
    },
  });
}

function updateTask(path, token, field, value) {
  return request(`${firestore}/${path}?updateMask.fieldPaths=${field}`, {
    method: 'PATCH',
    token,
    body: { fields: { [field]: value } },
  });
}

const owner = await newAccount();
const other = await newAccount();
const collection = `users/${owner.localId}/tasks`;
const task = `${collection}/rule-check`;
const fields = {
  title: { stringValue: 'Review tasks' },
  notes: { stringValue: '' },
  dueDate: { nullValue: null },
  completed: { booleanValue: false },
};

await expectStatus(createTask(task, owner.idToken, fields), 200, 'owner creates task');
await expectStatus(request(`${firestore}/${task}`, { token: owner.idToken }), 200, 'owner reads task');
await expectStatus(request(`${firestore}/${collection}`, { token: owner.idToken }), 200, 'owner lists tasks');
await expectStatus(request(`${firestore}/${task}`), 403, 'signed-out read denied');
await expectStatus(createTask(`${collection}/signed-out`, null, fields), 403, 'signed-out write denied');
await expectStatus(request(`${firestore}/${task}`, { token: other.idToken }), 403, 'other account read denied');
await expectStatus(request(`${firestore}/${collection}`, { token: other.idToken }), 403, 'other account list denied');
await expectStatus(createTask(`${collection}/another`, other.idToken, fields), 403, 'other account create denied');
await expectStatus(updateTask(task, other.idToken, 'completed', { booleanValue: true }), 403, 'other account update denied');
await expectStatus(request(`${firestore}/${task}`, { method: 'DELETE', token: other.idToken }), 403, 'other account delete denied');
await expectStatus(updateTask(task, owner.idToken, 'completed', { booleanValue: true }), 200, 'owner completes task');
await expectStatus(updateTask(task, owner.idToken, 'dueDate', { stringValue: '2026-11-09' }), 200, 'owner sets due date');
await expectStatus(updateTask(task, owner.idToken, 'dueDate', { nullValue: null }), 200, 'owner clears due date');
await expectStatus(updateTask(task, owner.idToken, 'title', { stringValue: '   ' }), 403, 'blank title denied');
await expectStatus(updateTask(task, owner.idToken, 'title', { stringValue: ' Review tasks ' }), 403, 'untrimmed title denied');
await expectStatus(updateTask(task, owner.idToken, 'title', { stringValue: '✓'.repeat(120) }), 200, 'Unicode title accepts 120 characters');
await expectStatus(updateTask(task, owner.idToken, 'title', { stringValue: 'x'.repeat(121) }), 403, 'overlong title denied');
await expectStatus(updateTask(task, owner.idToken, 'dueDate', { stringValue: '09/11/26' }), 403, 'invalid date format denied');
await expectStatus(updateTask(task, owner.idToken, 'createdAt', { timestampValue: '2026-11-09T00:00:00Z' }), 403, 'creation timestamp immutable');
await expectStatus(updateTask(task, owner.idToken, 'extra', { stringValue: 'unexpected' }), 403, 'unknown field denied');
await expectStatus(request(`${firestore}/${task}`, { method: 'DELETE', token: owner.idToken }), 200, 'owner deletes task');
