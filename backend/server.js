const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8000;

const path = require('path');

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/storage', express.static(path.join(__dirname, 'storage')));

// Rute Pengujian Status Server (Health Check)
app.get('/', (req, res) => {
  res.json({
    status: 'online',
    project: 'MyTeam API Backend',
    version: '1.0.0',
    university: 'Universitas Andalas',
    message: 'Server Backend MyTeam berjalan lancar!'
  });
});

app.get('/api/v1', (req, res) => {
  res.json({
    status: 'ready',
    contract_version: '1.0.0',
    base_url: `http://localhost:${PORT}/api/v1`,
    endpoints: [
      '/auth/login',
      '/auth/register',
      '/profile/detail/:id',
      '/teams/feed',
      '/teams/my-teams',
      '/applications/join-team',
      '/notifications'
    ]
  });
});

// Registrasi Modul Endpoint Resmi
app.use('/api/v1/auth', require('./src/routes/auth'));
app.use('/api/v1/profile', require('./src/routes/profile'));
app.use('/api/v1/teams', require('./src/routes/teams'));
app.use('/api/v1/applications', require('./src/routes/applications'));
app.use('/api/v1/members', require('./src/routes/members'));
app.use('/api/v1/notifications', require('./src/routes/notifications'));

// Error 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `Endpoint ${req.method} ${req.originalUrl} tidak ditemukan pada server MyTeam.`
  });
});

// Menjalankan Server
app.listen(PORT, () => {
  console.log(`=================================================`);
  console.log(`🚀 Server Backend MyTeam aktif di Port ${PORT}`);
  console.log(`🌐 Localhost URL : http://localhost:${PORT}`);
  console.log(`📱 Emulator URL  : http://10.0.2.2:${PORT}/api/v1`);
  console.log(`=================================================`);
});
