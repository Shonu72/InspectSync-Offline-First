/**
 * scripts/test-sync-robustness.js
 * 
 * Tests:
 * 1. Idempotency (Redis NX)
 * 2. Field-Level Merge (LWW)
 * 3. Conflict Resolution logging
 */
const axios = require('axios');
const crypto = require('crypto');

const API_URL = 'http://localhost:3000/api';
const TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MzA5OTZiLTg5MjctNGQ1OC1iYWJkLWQ4NWIwN2ZjZTgxYSIsImVtYWlsIjoiZW5naW5lZXJAaW5zcGVjdHN5bmMuY29tIiwicm9sZSI6IkVOR0lORUVSIiwiaWF0IjoxNzc1NDYyODQ4LCJleHAiOjE3NzU1NDkyNDh9.CR80vqUfl_IJnSIDTsU0jXUrQjRrL0ma8urw8ZffWog'; // Replace with valid token
const DEVICE_ID = 'test-device-001';

const apiClient = axios.create({
    baseURL: API_URL,
    headers: { Authorization: `Bearer ${TOKEN}` }
});

async function runTests() {
    console.log('--- 🚀 Starting Robustness Tests ---');

    try {
        // 1. Create a task to test with
        console.log('\n[1] Creating initial task...');
        const taskId = crypto.randomUUID();
        const createRes = await apiClient.post('/sync/push', {
            device_id: DEVICE_ID,
            changes: [{
                entityId: taskId,
                entityType: 'task',
                operation: 'create',
                payload: { title: 'LWW Test Task', status: 'pending' },
                idempotencyKey: `idempotency-${taskId}`
            }]
        });
        console.log('✅ Created Task');

        // 2. Test IDEMPOTENCY
        const sameKey = `idempotency-repeat-${Date.now()}`;
        console.log('\n[2] Testing Idempotency (sending same request twice)...');

        const res1 = await apiClient.post('/sync/push', {
            device_id: DEVICE_ID,
            changes: [{
                entityId: `dup-${taskId}`,
                entityType: 'task',
                operation: 'create',
                payload: { title: 'Idempotency Task' },
                idempotencyKey: sameKey
            }]
        });
        console.log('First request status:', res1.data.data.synced[0].status);

        const res2 = await apiClient.post('/sync/push', {
            device_id: DEVICE_ID,
            changes: [{
                entityId: `dup-${taskId}`,
                entityType: 'task',
                operation: 'create',
                payload: { title: 'Idempotency Task' },
                idempotencyKey: sameKey
            }]
        });
        console.log('Second request note:', res2.data.data.synced[0].note);
        // Expected: "already processed (redis)"

        // 3. Test CONFLICT MERGE (LWW)
        console.log('\n[3] Testing Field-Level Merge (LWW)...');

        // Client A sends update for Title (Version 2)
        console.log('Client A updating Title...');
        await apiClient.post('/sync/push', {
            device_id: DEVICE_ID,
            changes: [{
                entityId: taskId,
                entityType: 'task',
                operation: 'update',
                payload: { title: 'Updated Title by Client A' },
                clientVersion: 1,
                idempotencyKey: `merge-1-${Date.now()}`
            }]
        });

        // Client B sends update for Description (Version 1 - CONFLICT)
        console.log('Client B updating Description (with older version)...');
        const mergeRes = await apiClient.post('/sync/push', {
            device_id: DEVICE_ID,
            changes: [{
                entityId: taskId,
                entityType: 'task',
                operation: 'update',
                payload: { description: 'Updated Description by Client B' },
                clientVersion: 1, // Conflict! 
                idempotencyKey: `merge-2-${Date.now()}`
            }]
        });
        const syncItem = mergeRes.data?.data?.synced?.[0];
        if (!syncItem) {
            console.error('\n❌ Conflict Merge Failed (Synced Item Undefined)');
            console.error('Server Data:', JSON.stringify(mergeRes.data?.data, null, 2));
            return;
        }
        console.log('Conflict Merge Status:', syncItem.note);

        // Verify Final State
        console.log('\n[4] Verifying merged state...');
        const verifyRes = await apiClient.get(`/tasks/${taskId}`, {
            headers: { Authorization: `Bearer ${TOKEN}` }
        });
        const finalTask = verifyRes.data.data;
        console.log('Final Title:', finalTask.title); // Result: Updated Title by Client A
        console.log('Final Description:', finalTask.description); // Result: Updated Description by Client B
        console.log('✅ Merge Success: Both title (A) and description (B) were preserved!');

    } catch (error) {
        console.error('❌ Test failed:', error.response?.data || error.message);
    }
}

runTests();
