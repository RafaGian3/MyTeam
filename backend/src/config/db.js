const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'myteam_db',
  port: process.env.DB_PORT || 3306,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4'
});

// Tes koneksi ke basis data
pool.getConnection()
  .then(conn => {
    console.log(' Terhubung ke database MySQL (myteam_db)');
    conn.release();
  })
  .catch(err => {
    console.error(' Gagal terhubung ke database MySQL:', err.message);
    console.error('👉 Pastikan XAMPP/MySQL sudah dinyalakan dan database myteam_db sudah diimport.');
  });

module.exports = pool;
