const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

// POST /api/v1/auth/register
router.post('/register', async (req, res) => {
  try {
    const { nim, nama_pengguna, kata_sandi, kata_sandi_konfirmasi } = req.body;

    if (!nim || !nama_pengguna || !kata_sandi) {
      return res.status(422).json({
        success: false,
        message: 'NIM, nama pengguna, dan kata sandi wajib diisi.'
      });
    }

    if (kata_sandi !== kata_sandi_konfirmasi) {
      return res.status(422).json({
        success: false,
        message: 'Konfirmasi kata sandi tidak cocok.'
      });
    }

    // Cek apakah NIM sudah terdaftar
    const [existing] = await db.query('SELECT nim FROM Pengguna WHERE nim = ?', [nim]);
    if (existing.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'NIM sudah terdaftar dalam sistem MyTeam.'
      });
    }

    const id_pengguna = `usr_${Date.now()}`;
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(kata_sandi, salt);

    await db.query(
      'INSERT INTO Pengguna (id_pengguna, nim, kata_sandi, nama_pengguna) VALUES (?, ?, ?, ?)',
      [id_pengguna, nim, hash, nama_pengguna]
    );

    // Inisialisasi Data_Diri default
    await db.query(
      'INSERT INTO Data_Diri (id_pengguna, deskripsi_singkat, kontak, program_studi, fakultas, ipk) VALUES (?, ?, ?, ?, ?, ?)',
      [id_pengguna, '', '', 'Sistem Informasi', 'Teknologi Informasi', 0.00]
    );

    const token = jwt.sign(
      { id_pengguna, nim, nama_pengguna },
      process.env.JWT_SECRET || 'myteam_secret',
      { expiresIn: '7d' }
    );

    return res.status(201).json({
      success: true,
      message: 'Registrasi akun berhasil',
      data: {
        id_pengguna,
        nim,
        nama_pengguna,
        foto_profil: null,
        token
      }
    });
  } catch (error) {
    console.error('Error register:', error);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server.' });
  }
});

// POST /api/v1/auth/login
router.post('/login', async (req, res) => {
  try {
    const { nim, kata_sandi } = req.body;

    if (!nim || !kata_sandi) {
      return res.status(400).json({
        success: false,
        message: 'NIM dan kata sandi wajib diisi.'
      });
    }

    const [rows] = await db.query(
      'SELECT id_pengguna, nim, kata_sandi, nama_pengguna, foto_profil FROM Pengguna WHERE nim = ?',
      [nim]
    );

    if (rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'NIM atau kata sandi tidak valid.'
      });
    }

    const user = rows[0];
    // Fix kompatibilitas: hash dummy seed pakai prefix $2y$ (PHP),
    // bcryptjs Node.js pakai $2b$ — keduanya algoritmanya sama, beda prefix saja.
    const hashCompat = user.kata_sandi.replace(/^\$2y\$/, '$2b$');
    const isMatch = await bcrypt.compare(kata_sandi, hashCompat);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'NIM atau kata sandi tidak valid.'
      });
    }

    const token = jwt.sign(
      { id_pengguna: user.id_pengguna, nim: user.nim, nama_pengguna: user.nama_pengguna },
      process.env.JWT_SECRET || 'myteam_secret',
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      success: true,
      message: 'Autentikasi berhasil',
      data: {
        id_pengguna: user.id_pengguna,
        nim: user.nim,
        nama_pengguna: user.nama_pengguna,
        foto_profil: user.foto_profil,
        token
      }
    });
  } catch (error) {
    console.error('Error login:', error);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server.' });
  }
});

module.exports = router;
