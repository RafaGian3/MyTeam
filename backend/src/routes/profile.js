const express = require('express');
const router = express.Router();
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

// Konfigurasi Multer untuk Upload Foto Profil
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, '../../storage/profiles');
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const userId = req.userId || 'user';
    cb(null, `${userId}_${Date.now()}${ext}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 }, // Max 2MB
  fileFilter: (req, file, cb) => {
    const allowed = /jpeg|jpg|png|webp/;
    const extname = allowed.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowed.test(file.mimetype);
    if (extname && mimetype) {
      return cb(null, true);
    }
    cb(new Error('Format file tidak didukung. Harap upload gambar (JPG, PNG, atau WebP).'));
  }
});

// Helper: Ekstraksi ID Pengguna dari Header Authorization JWT / Query / Body
const getAuthUserId = (req) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'myteam_secret');
      if (decoded && decoded.id_pengguna) {
        return decoded.id_pengguna;
      }
    }
  } catch (err) {
    // Token mungkin expired atau tidak valid, lanjut fallback
  }

  return req.body?.id_pengguna || req.query?.id_pengguna || req.headers['x-user-id'] || null;
};

// Middleware opsional untuk inject req.userId sebelum Multer dipanggil
const injectUserId = (req, res, next) => {
  req.userId = getAuthUserId(req) || 'usr_unknown';
  next();
};

// Helper: FR-07 — Otomasi Notifikasi Aktivitas Data Riwayat Diri
const createProfileNotification = async (id_pengguna, pesan) => {
  if (!id_pengguna) return;
  try {
    const id_notifikasi = `notif_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
    await db.query(
      `INSERT INTO Notifikasi 
        (id_notifikasi, id_pengguna, jenis_notifikasi, pesan_notifikasi, status_dibaca) 
       VALUES (?, ?, 'riwayat_diri_diperbarui', ?, FALSE)`,
      [id_notifikasi, id_pengguna, pesan]
    );
  } catch (err) {
    console.error('Gagal membuat auto-notifikasi FR-07:', err.message);
  }
};

// =============================================================================
// FR-06: Detail Profil Lengkap Pengguna & Tim yang Diikuti
// =============================================================================
router.get('/detail/:id_pengguna', async (req, res) => {
  try {
    const { id_pengguna } = req.params;

    const [user] = await db.query(
      'SELECT id_pengguna, nim, nama_pengguna, foto_profil FROM Pengguna WHERE id_pengguna = ?',
      [id_pengguna]
    );

    if (user.length === 0) {
      return res.status(404).json({ success: false, message: 'Pengguna tidak ditemukan.' });
    }

    const [dataDiri] = await db.query('SELECT * FROM Data_Diri WHERE id_pengguna = ?', [id_pengguna]);
    const [medsos] = await db.query(
      'SELECT id_media_sosial, nama_media_sosial, link_media_sosial FROM Media_Sosial WHERE id_pengguna = ? ORDER BY created_at ASC',
      [id_pengguna]
    );
    const [minat] = await db.query(
      'SELECT id_minat, minat, deskripsi_minat FROM Data_Minat WHERE id_pengguna = ? ORDER BY created_at ASC',
      [id_pengguna]
    );
    const [keahlian] = await db.query(
      'SELECT id_keahlian, keahlian, deskripsi_keahlian FROM Data_Keahlian WHERE id_pengguna = ? ORDER BY created_at ASC',
      [id_pengguna]
    );
    const [pengalaman] = await db.query(
      'SELECT id_pengalaman, nama_kegiatan, peran, tahun, deskripsi_pengalaman FROM Data_Pengalaman WHERE id_pengguna = ? ORDER BY tahun DESC, created_at DESC',
      [id_pengguna]
    );

    // Tim yang diikuti (FR-06)
    const [tim] = await db.query(`
      SELECT at.id_anggota_tim, dt.id_tim, dt.nama_tim, dt.nama_kegiatan, dt.kategori_kegiatan, at.posisi
      FROM Anggota_Tim at
      JOIN Data_Tim dt ON at.id_tim = dt.id_tim
      WHERE at.id_pengguna = ?
      ORDER BY at.joined_at DESC
    `, [id_pengguna]);

    return res.status(200).json({
      success: true,
      message: 'Detail profil pengguna berhasil diambil',
      data: {
        pengguna: user[0],
        data_diri: dataDiri[0] || null,
        media_sosial: medsos,
        minat,
        keahlian,
        pengalaman,
        tim_yang_diikuti: tim
      }
    });
  } catch (error) {
    console.error('Error profile detail:', error);
    return res.status(500).json({ success: false, message: 'Terjadi kesalahan pada server: ' + error.message });
  }
});

// =============================================================================
// FR-01: Kelola Data Diri & Akademik
// =============================================================================
router.get('/data-diri', async (req, res) => {
  try {
    const id_pengguna = getAuthUserId(req) || 'usr_fuadi_01';
    const [rows] = await db.query('SELECT * FROM Data_Diri WHERE id_pengguna = ?', [id_pengguna]);
    return res.json({
      success: true,
      message: 'Data diri berhasil diambil',
      data: rows[0] || null
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/data-diri', async (req, res) => {
  try {
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    if (!id_pengguna) {
      return res.status(401).json({ success: false, message: 'Pengguna tidak terautentikasi.' });
    }

    const { deskripsi_singkat, kontak, program_studi, fakultas, ipk } = req.body;

    // Validasi IPK (0.00 s/d 4.00)
    const numericIpk = parseFloat(ipk);
    if (isNaN(numericIpk) || numericIpk < 0.0 || numericIpk > 4.0) {
      return res.status(422).json({
        success: false,
        message: 'Validasi gagal',
        errors: { ipk: ['Nilai IPK harus berada pada rentang 0.00 hingga 4.00.'] }
      });
    }

    await db.query(`
      INSERT INTO Data_Diri (id_pengguna, deskripsi_singkat, kontak, program_studi, fakultas, ipk)
      VALUES (?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        deskripsi_singkat = VALUES(deskripsi_singkat),
        kontak = VALUES(kontak),
        program_studi = VALUES(program_studi),
        fakultas = VALUES(fakultas),
        ipk = VALUES(ipk)
    `, [id_pengguna, deskripsi_singkat || '', kontak || '', program_studi || '', fakultas || '', numericIpk]);

    // FR-07: Trigger Notifikasi
    await createProfileNotification(id_pengguna, 'Data diri dan riwayat akademik Anda berhasil diperbarui.');

    return res.status(200).json({
      success: true,
      message: 'Data diri berhasil disimpan',
      data: {
        id_pengguna,
        deskripsi_singkat,
        kontak,
        program_studi,
        fakultas,
        ipk: numericIpk
      }
    });
  } catch (error) {
    console.error('Error PUT data-diri:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// =============================================================================
// Upload / Update Foto Profil Pengguna
// =============================================================================
router.post('/foto-profil', injectUserId, upload.single('foto_profil'), async (req, res) => {
  try {
    const id_pengguna = req.userId;
    if (!id_pengguna || id_pengguna === 'usr_unknown') {
      return res.status(401).json({ success: false, message: 'Pengguna tidak teridentifikasi.' });
    }

    let fotoUrl = '';
    if (req.file) {
      // Simpan URL relatif atau host-based
      const host = req.get('host');
      const protocol = req.protocol;
      fotoUrl = `${protocol}://${host}/storage/profiles/${req.file.filename}`;
    } else if (req.body.foto_url) {
      fotoUrl = req.body.foto_url;
    } else {
      return res.status(422).json({ success: false, message: 'Berkas foto profil wajib diunggah.' });
    }

    await db.query('UPDATE Pengguna SET foto_profil = ? WHERE id_pengguna = ?', [fotoUrl, id_pengguna]);
    await createProfileNotification(id_pengguna, 'Foto profil Anda berhasil diperbarui.');

    return res.status(200).json({
      success: true,
      message: 'Foto profil berhasil diperbarui',
      data: { foto_profil: fotoUrl }
    });
  } catch (error) {
    console.error('Error upload foto profil:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/foto-profil', async (req, res) => {
  try {
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    const { foto_url } = req.body;
    if (!id_pengguna || !foto_url) {
      return res.status(400).json({ success: false, message: 'id_pengguna dan foto_url wajib disertakan.' });
    }

    await db.query('UPDATE Pengguna SET foto_profil = ? WHERE id_pengguna = ?', [foto_url, id_pengguna]);
    await createProfileNotification(id_pengguna, 'Foto profil Anda berhasil diperbarui.');

    return res.status(200).json({
      success: true,
      message: 'Foto profil berhasil diperbarui',
      data: { foto_profil: foto_url }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// =============================================================================
// FR-02: Kelola Media Sosial
// =============================================================================
router.get('/media-sosial', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || getAuthUserId(req) || 'usr_fuadi_01';
    const [rows] = await db.query(
      'SELECT id_media_sosial, nama_media_sosial, link_media_sosial FROM Media_Sosial WHERE id_pengguna = ? ORDER BY created_at ASC',
      [id_pengguna]
    );
    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/media-sosial', async (req, res) => {
  try {
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    const { nama_media_sosial, link_media_sosial } = req.body;

    if (!nama_media_sosial || !link_media_sosial) {
      return res.status(422).json({ success: false, message: 'Nama media sosial dan link wajib diisi.' });
    }

    const id_media_sosial = `soc_${Date.now()}`;
    await db.query(
      'INSERT INTO Media_Sosial (id_media_sosial, id_pengguna, nama_media_sosial, link_media_sosial) VALUES (?, ?, ?, ?)',
      [id_media_sosial, id_pengguna, nama_media_sosial, link_media_sosial]
    );

    await createProfileNotification(id_pengguna, `Media sosial "${nama_media_sosial}" berhasil ditambahkan ke profil Anda.`);

    return res.status(201).json({
      success: true,
      message: 'Media sosial berhasil ditambahkan',
      data: { id_media_sosial, nama_media_sosial, link_media_sosial }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/media-sosial/:id_media_sosial', async (req, res) => {
  try {
    const { id_media_sosial } = req.params;
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    const { nama_media_sosial, link_media_sosial } = req.body;

    await db.query(
      'UPDATE Media_Sosial SET nama_media_sosial = ?, link_media_sosial = ? WHERE id_media_sosial = ?',
      [nama_media_sosial, link_media_sosial, id_media_sosial]
    );

    await createProfileNotification(id_pengguna, `Media sosial "${nama_media_sosial}" berhasil diperbarui.`);

    return res.json({
      success: true,
      message: 'Media sosial berhasil diperbarui',
      data: { id_media_sosial, nama_media_sosial, link_media_sosial }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/media-sosial/:id_media_sosial', async (req, res) => {
  try {
    const { id_media_sosial } = req.params;
    const id_pengguna = req.query.id_pengguna || getAuthUserId(req);

    await db.query('DELETE FROM Media_Sosial WHERE id_media_sosial = ?', [id_media_sosial]);
    await createProfileNotification(id_pengguna, 'Satu tautan media sosial berhasil dihapus.');

    return res.json({ success: true, message: 'Media sosial berhasil dihapus.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// =============================================================================
// FR-03: Kelola Minat
// =============================================================================
router.get('/minat', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || getAuthUserId(req) || 'usr_fuadi_01';
    const [rows] = await db.query(
      'SELECT id_minat, minat, deskripsi_minat FROM Data_Minat WHERE id_pengguna = ? ORDER BY created_at ASC',
      [id_pengguna]
    );
    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/minat', async (req, res) => {
  try {
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    const { minat, deskripsi_minat } = req.body;

    if (!minat) {
      return res.status(422).json({ success: false, message: 'Nama minat wajib diisi.' });
    }

    const id_minat = `mnt_${Date.now()}`;
    await db.query(
      'INSERT INTO Data_Minat (id_minat, id_pengguna, minat, deskripsi_minat) VALUES (?, ?, ?, ?)',
      [id_minat, id_pengguna, minat, deskripsi_minat || '']
    );

    await createProfileNotification(id_pengguna, `Minat "${minat}" berhasil ditambahkan.`);

    return res.status(201).json({
      success: true,
      message: 'Minat berhasil ditambahkan',
      data: { id_minat, minat, deskripsi_minat }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/minat/:id_minat', async (req, res) => {
  try {
    const { id_minat } = req.params;
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    const { minat, deskripsi_minat } = req.body;

    await db.query(
      'UPDATE Data_Minat SET minat = ?, deskripsi_minat = ? WHERE id_minat = ?',
      [minat, deskripsi_minat || '', id_minat]
    );

    await createProfileNotification(id_pengguna, `Minat "${minat}" berhasil diperbarui.`);

    return res.json({
      success: true,
      message: 'Minat berhasil diperbarui',
      data: { id_minat, minat, deskripsi_minat }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/minat/:id_minat', async (req, res) => {
  try {
    const { id_minat } = req.params;
    const id_pengguna = req.query.id_pengguna || getAuthUserId(req);

    await db.query('DELETE FROM Data_Minat WHERE id_minat = ?', [id_minat]);
    await createProfileNotification(id_pengguna, 'Satu data minat berhasil dihapus.');

    return res.json({ success: true, message: 'Minat berhasil dihapus.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// =============================================================================
// FR-04: Kelola Keahlian
// =============================================================================
router.get('/keahlian', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || getAuthUserId(req) || 'usr_fuadi_01';
    const [rows] = await db.query(
      'SELECT id_keahlian, keahlian, deskripsi_keahlian FROM Data_Keahlian WHERE id_pengguna = ? ORDER BY created_at ASC',
      [id_pengguna]
    );
    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/keahlian', async (req, res) => {
  try {
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    const { keahlian, deskripsi_keahlian } = req.body;

    if (!keahlian) {
      return res.status(422).json({ success: false, message: 'Nama keahlian wajib diisi.' });
    }

    const id_keahlian = `khl_${Date.now()}`;
    await db.query(
      'INSERT INTO Data_Keahlian (id_keahlian, id_pengguna, keahlian, deskripsi_keahlian) VALUES (?, ?, ?, ?)',
      [id_keahlian, id_pengguna, keahlian, deskripsi_keahlian || '']
    );

    await createProfileNotification(id_pengguna, `Keahlian "${keahlian}" berhasil ditambahkan.`);

    return res.status(201).json({
      success: true,
      message: 'Keahlian berhasil ditambahkan',
      data: { id_keahlian, keahlian, deskripsi_keahlian }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/keahlian/:id_keahlian', async (req, res) => {
  try {
    const { id_keahlian } = req.params;
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    const { keahlian, deskripsi_keahlian } = req.body;

    await db.query(
      'UPDATE Data_Keahlian SET keahlian = ?, deskripsi_keahlian = ? WHERE id_keahlian = ?',
      [keahlian, deskripsi_keahlian || '', id_keahlian]
    );

    await createProfileNotification(id_pengguna, `Keahlian "${keahlian}" berhasil diperbarui.`);

    return res.json({
      success: true,
      message: 'Keahlian berhasil diperbarui',
      data: { id_keahlian, keahlian, deskripsi_keahlian }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/keahlian/:id_keahlian', async (req, res) => {
  try {
    const { id_keahlian } = req.params;
    const id_pengguna = req.query.id_pengguna || getAuthUserId(req);

    await db.query('DELETE FROM Data_Keahlian WHERE id_keahlian = ?', [id_keahlian]);
    await createProfileNotification(id_pengguna, 'Satu data keahlian berhasil dihapus.');

    return res.json({ success: true, message: 'Keahlian berhasil dihapus.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// =============================================================================
// FR-05: Kelola Pengalaman (PRD v1.0 Refinement: Tanpa Bukti Media, dengan Deskripsi)
// =============================================================================
router.get('/pengalaman', async (req, res) => {
  try {
    const id_pengguna = req.query.id_pengguna || getAuthUserId(req) || 'usr_fuadi_01';
    const [rows] = await db.query(
      'SELECT id_pengalaman, nama_kegiatan, peran, tahun, deskripsi_pengalaman FROM Data_Pengalaman WHERE id_pengguna = ? ORDER BY tahun DESC, created_at DESC',
      [id_pengguna]
    );
    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.post('/pengalaman', async (req, res) => {
  try {
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    const { nama_kegiatan, peran, tahun, deskripsi_pengalaman } = req.body;

    if (!nama_kegiatan || !peran || !tahun || !deskripsi_pengalaman) {
      return res.status(422).json({
        success: false,
        message: 'Nama kegiatan, peran, tahun, dan deskripsi pengalaman wajib diisi.'
      });
    }

    const id_pengalaman = `exp_${Date.now()}`;
    await db.query(
      'INSERT INTO Data_Pengalaman (id_pengalaman, id_pengguna, nama_kegiatan, peran, tahun, deskripsi_pengalaman) VALUES (?, ?, ?, ?, ?, ?)',
      [id_pengalaman, id_pengguna, nama_kegiatan, peran, parseInt(tahun, 10), deskripsi_pengalaman]
    );

    await createProfileNotification(id_pengguna, `Riwayat pengalaman "${nama_kegiatan}" berhasil ditambahkan.`);

    return res.status(201).json({
      success: true,
      message: 'Riwayat pengalaman berhasil ditambahkan',
      data: {
        id_pengalaman,
        nama_kegiatan,
        peran,
        tahun: parseInt(tahun, 10),
        deskripsi_pengalaman
      }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/pengalaman/:id_pengalaman', async (req, res) => {
  try {
    const { id_pengalaman } = req.params;
    const id_pengguna = req.body.id_pengguna || getAuthUserId(req);
    const { nama_kegiatan, peran, tahun, deskripsi_pengalaman } = req.body;

    await db.query(`
      UPDATE Data_Pengalaman 
      SET nama_kegiatan = ?, peran = ?, tahun = ?, deskripsi_pengalaman = ? 
      WHERE id_pengalaman = ?
    `, [nama_kegiatan, peran, parseInt(tahun, 10), deskripsi_pengalaman, id_pengalaman]);

    await createProfileNotification(id_pengguna, `Riwayat pengalaman "${nama_kegiatan}" berhasil diperbarui.`);

    return res.json({
      success: true,
      message: 'Riwayat pengalaman berhasil diperbarui',
      data: { id_pengalaman, nama_kegiatan, peran, tahun: parseInt(tahun, 10), deskripsi_pengalaman }
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/pengalaman/:id_pengalaman', async (req, res) => {
  try {
    const { id_pengalaman } = req.params;
    const id_pengguna = req.query.id_pengguna || getAuthUserId(req);

    await db.query('DELETE FROM Data_Pengalaman WHERE id_pengalaman = ?', [id_pengalaman]);
    await createProfileNotification(id_pengguna, 'Satu riwayat pengalaman berhasil dihapus.');

    return res.json({ success: true, message: 'Riwayat pengalaman berhasil dihapus.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
