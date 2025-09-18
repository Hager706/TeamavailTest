const request = require('supertest');
const app = require('../server');

describe('TeamAvail Application', () => {
  test('Health check endpoint', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);
    
    expect(response.body).toHaveProperty('status', 'OK');
  });
  
  test('Root endpoint returns HTML', async () => {
    const response = await request(app)
      .get('/')
      .expect(200);
    
    expect(response.headers['content-type']).toMatch(/html/);
  });
});