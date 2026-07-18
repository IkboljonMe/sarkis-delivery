import { io } from 'socket.io-client';

async function testWebSocket() {
  console.log('Fetching JWT token...');
  const res = await fetch('http://localhost:3000/v1/auth/otp/verify', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-client-platform': 'ios' },
    body: JSON.stringify({ phone: '+491701234567', code: '123456' })
  });
  
  if (!res.ok) {
    console.error('Failed to login:', await res.text());
    process.exit(1);
  }
  
  const data = await res.json();
  const token = data.accessToken;
  console.log('Login successful. Access token:', token ? 'OK' : 'MISSING');

  console.log('Connecting to WebSocket Gateway...');
  const socket = io('http://localhost:3000', {
    auth: { token },
    transports: ['websocket', 'polling']
  });

  socket.on('connect', () => {
    console.log('✅ WebSocket connected successfully!');
    console.log('Socket ID:', socket.id);
    
    // Test receiving some event or wait a sec before exiting
    setTimeout(() => {
      console.log('Test complete. Disconnecting...');
      socket.disconnect();
      process.exit(0);
    }, 1000);
  });

  socket.on('connect_error', (err) => {
    console.error('❌ WebSocket connection error:', err.message);
    process.exit(1);
  });
}

testWebSocket();
