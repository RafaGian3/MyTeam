const express = require('express');
const router = express.Router();
const db = require('../config/db');
const jwt = require('jsonwebtoken');

// Ambil id pengguna hanya dari token JWT agar identitas tidak bisa dipalsukan lewat query.
const getUserId = (req) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const decoded = jwt.verify(authHeader.split(' ')[1], process.env.JWT_SECRET || 'myteam_secret');
      if (decoded?.id_pengguna) return decoded.id_pengguna;
    }
  } catch (err) {
    // token tidak valid / kedaluwarsa
  }
  return null;
};

const unauthorized = (res) =>
  res.status(401).json({ success: false, message: 'Sesi tidak valid. Silakan login kembali.' });

// GET /api/v1/notifications (Inbox Notifikasi Universal)
router.get('/', async (req, res) => {
  try {
    const id_pengguna = getUserId(req);
    if (!id_pengguna) return unauthorized(res);
    const [rows] = await db.query(
      'SELECT * FROM Notifikasi WHERE id_pengguna = ? ORDER BY waktu_notifikasi DESC',
      [id_pengguna]
    );

    return res.json({
      success: true,
      message: 'Daftar notifikasi berhasil diambil',
      data: rows
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/notifications/unread-count (Hitung Belum Dibaca - badge ikon Notifikasi)
router.get('/unread-count', async (req, res) => {
  try {
    const id_pengguna = getUserId(req);
    if (!id_pengguna) return unauthorized(res);
    const [rows] = await db.query(
      'SELECT COUNT(*) AS unread_count FROM Notifikasi WHERE id_pengguna = ? AND status_dibaca = FALSE',
      [id_pengguna]
    );
    return res.json({
      success: true,
      data: { unread_count: Number(rows[0].unread_count) }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PATCH /api/v1/notifications/read-all (Tandai Semua Dibaca - saat tab Notifikasi dibuka)
router.patch('/read-all', async (req, res) => {
  try {
    const id_pengguna = getUserId(req);
    if (!id_pengguna) return unauthorized(res);
    const [result] = await db.query(
      'UPDATE Notifikasi SET status_dibaca = TRUE WHERE id_pengguna = ? AND status_dibaca = FALSE',
      [id_pengguna]
    );
    return res.json({
      success: true,
      message: 'Semua notifikasi ditandai telah dibaca.',
      data: { updated: result.affectedRows }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PATCH /api/v1/notifications/:id/read (Tandai Dibaca) - hanya milik sendiri
router.patch('/:id/read', async (req, res) => {
  try {
    const id_pengguna = getUserId(req);
    if (!id_pengguna) return unauthorized(res);
    const { id } = req.params;
    const [result] = await db.query(
      'UPDATE Notifikasi SET status_dibaca = TRUE WHERE id_notifikasi = ? AND id_pengguna = ?',
      [id, id_pengguna]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Notifikasi tidak ditemukan.' });
    }
    return res.json({ success: true, message: 'Notifikasi ditandai telah dibaca.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
