const express = require('express');
const router = express.Router();
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const jwt = require('jsonwebtoken');
const db = require('../config/db');

// Konfigurasi Multer untuk Upload Dokumen Pendukung (Poster / Panduan)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, '../../storage/teams');
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const unique = `${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;
    cb(null, `doc_${unique}${ext}`);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // Max 10MB
  fileFilter: (req, file, cb) => {
    const allowed = /jpeg|jpg|png|pdf|webp/;
    const extname = allowed.test(path.extname(file.originalname).toLowerCase());
    const mimetype = /image\/(jpeg|jpg|png|webp)|application\/pdf/.test(file.mimetype);
    if (extname || mimetype) {
      return cb(null, true);
    }
    cb(new Error('Format file tidak didukung. Harap upload berkas JPG, PNG, atau PDF.'));
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
  } catch (err) { }
  return req.body?.id_pengguna || req.query?.id_pengguna || req.headers['x-user-id'] || 'usr_rafa_02';
};

// GET /api/v1/teams/feed (FR-13, FR-14: Feed & Filter Tim)
router.get('/feed', async (req, res) => {
  try {
    const { search, kategori, keahlian } = req.query;
    let query = `
      SELECT dt.*, p.nama_pengguna, p.foto_profil 
      FROM Data_Tim dt
      JOIN Pengguna p ON dt.id_pengguna = p.id_pengguna
      WHERE dt.status_tim = 'terbuka'
    `;
    const params = [];

    if (search && search.trim() !== '') {
      const term = `%${search.trim()}%`;
      query += ` AND (
        dt.nama_tim LIKE ? 
        OR dt.nama_kegiatan LIKE ? 
        OR dt.deskripsi LIKE ?
        OR EXISTS (
          SELECT 1 FROM Kebutuhan_Anggota_Tim kat 
          WHERE kat.id_tim = dt.id_tim 
            AND (kat.keahlian_dibutuhkan LIKE ? OR kat.posisi_dibutuhkan LIKE ?)
        )
      )`;
      params.push(term, term, term, term, term);
    }
    if (kategori && kategori !== 'Semua' && kategori.trim() !== '') {
      query += ` AND dt.kategori_kegiatan = ?`;
      params.push(kategori.trim());
    }
    if (keahlian && keahlian.trim() !== '') {
      const skillTerm = `%${keahlian.trim()}%`;
      query += ` AND EXISTS (
        SELECT 1 FROM Kebutuhan_Anggota_Tim kat 
        WHERE kat.id_tim = dt.id_tim 
          AND (kat.keahlian_dibutuhkan LIKE ? OR kat.posisi_dibutuhkan LIKE ?)
      )`;
      params.push(skillTerm, skillTerm);
    }

    query += ` ORDER BY dt.created_at DESC`;

    const [teams] = await db.query(query, params);

    for (const team of teams) {
      const [kebutuhan] = await db.query(
        'SELECT * FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?',
        [team.id_tim]
      );
      const [dokumen] = await db.query(
        'SELECT * FROM Dokumen_Pendukung WHERE id_tim = ? ORDER BY urutan ASC',
        [team.id_tim]
      );
      const [[anggotaCount]] = await db.query(
        'SELECT COUNT(*) AS total FROM Anggota_Tim WHERE id_tim = ?',
        [team.id_tim]
      );

      team.pembuat_tim = {
        id_pengguna: team.id_pengguna,
        nama_pengguna: team.nama_pengguna,
        foto_profil: team.foto_profil
      };
      team.kebutuhan_tim = kebutuhan;
      team.dokumen_pendukung = dokumen;
      team.total_anggota_saat_ini = Number(anggotaCount?.total) || 0;
    }

    return res.json({
      success: true,
      message: 'Feed tim berhasil diambil',
      data: teams
    });
  } catch (error) {
    console.error('Error feed teams:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/teams/feed/:id_tim (FR-15: Detail Tim dari Feed)
router.get('/feed/:id_tim', async (req, res) => {
  try {
    const { id_tim } = req.params;
    const currentUserId = getAuthUserId(req);

    const [teams] = await db.query(`
      SELECT dt.*, 
             p.nama_pengguna, p.foto_profil, p.nim,
             dd.program_studi, dd.fakultas, dd.kontak
      FROM Data_Tim dt
      JOIN Pengguna p ON dt.id_pengguna = p.id_pengguna
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      WHERE dt.id_tim = ?
    `, [id_tim]);

    if (teams.length === 0) {
      return res.status(404).json({ success: false, message: 'Tim tidak ditemukan.' });
    }

    const team = teams[0];
    const [kebutuhan] = await db.query('SELECT * FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?', [id_tim]);
    const [dokumen] = await db.query('SELECT * FROM Dokumen_Pendukung WHERE id_tim = ? ORDER BY urutan ASC', [id_tim]);
    const [anggota] = await db.query(`
      SELECT at.*, 
             p.nama_pengguna, p.foto_profil, p.nim,
             dd.program_studi, dd.fakultas
      FROM Anggota_Tim at
      JOIN Pengguna p ON at.id_pengguna = p.id_pengguna
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      WHERE at.id_tim = ?
      ORDER BY at.joined_at ASC
    `, [id_tim]);

    team.kebutuhan_tim = kebutuhan;
    team.dokumen_pendukung = dokumen;
    team.anggota_tim = anggota;
    team.total_anggota_saat_ini = anggota.length;

    team.pembuat_tim = {
      id_pengguna: team.id_pengguna,
      nama_pengguna: team.nama_pengguna,
      foto_profil: team.foto_profil,
      nim: team.nim,
      program_studi: team.program_studi,
      fakultas: team.fakultas,
      kontak: team.kontak
    };

    let hasPending = false;
    if (currentUserId) {
      const [pendingApps] = await db.query(`
        SELECT id_pengajuan_bergabung_tim 
        FROM Pengajuan_Bergabung_Tim 
        WHERE id_tim = ? AND id_pengguna = ? AND status_pengajuan = 'menunggu'
        LIMIT 1
      `, [id_tim, currentUserId]);
      hasPending = pendingApps.length > 0;
    }

    const isPembuat = currentUserId ? (team.id_pengguna === currentUserId) : false;
    const isAnggota = currentUserId ? anggota.some(a => a.id_pengguna === currentUserId) : false;

    team.user_status = {
      is_pembuat: isPembuat,
      is_anggota: isAnggota,
      has_pending_application: hasPending
    };

    return res.json({
      success: true,
      message: 'Detail tim berhasil dimuat',
      data: team
    });
  } catch (error) {
    console.error('Error detail team:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/teams/my-teams (FR-09: Daftar Tim Saya)
router.get('/my-teams', async (req, res) => {
  try {
    const id_pengguna = getAuthUserId(req);
    const [rows] = await db.query(`
      SELECT dt.*,
        CASE WHEN dt.id_pengguna = ? THEN 'pemilik' ELSE 'anggota' END AS peran
      FROM Data_Tim dt
      WHERE dt.id_pengguna = ?
        OR EXISTS (
          SELECT 1
          FROM Anggota_Tim at
          WHERE at.id_tim = dt.id_tim AND at.id_pengguna = ?
        )
      ORDER BY dt.created_at DESC
    `, [id_pengguna, id_pengguna, id_pengguna]);

    for (const team of rows) {
      const [kebutuhan] = await db.query('SELECT * FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?', [team.id_tim]);
      const [dokumen] = await db.query('SELECT * FROM Dokumen_Pendukung WHERE id_tim = ? ORDER BY urutan ASC', [team.id_tim]);
      const [anggota] = await db.query(`
        SELECT at.*, p.nama_pengguna, p.foto_profil, dd.program_studi
        FROM Anggota_Tim at
        JOIN Pengguna p ON at.id_pengguna = p.id_pengguna
        LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
        WHERE at.id_tim = ?
      `, [team.id_tim]);

      team.kebutuhan_tim = kebutuhan;
      team.dokumen_pendukung = dokumen;
      team.anggota_tim = anggota;
    }

    return res.json({ success: true, data: rows });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// POST /api/v1/teams (FR-08: Buat Tim Baru)
router.post('/', upload.any(), async (req, res) => {
  try {
    const id_pengguna = getAuthUserId(req);
    const { nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi } = req.body;
    let kebutuhan = req.body.kebutuhan;
    if (typeof kebutuhan === 'string') {
      try {
        kebutuhan = JSON.parse(kebutuhan);
      } catch (_) { }
    }

    const id_tim = `tim_${Date.now()}`;

    await db.query(
      'INSERT INTO Data_Tim (id_tim, id_pengguna, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, status_tim) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id_tim, id_pengguna, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, 'terbuka']
    );

    // Kebutuhan posisi tim
    if (Array.isArray(kebutuhan)) {
      for (const item of kebutuhan) {
        await db.query(
          'INSERT INTO Kebutuhan_Anggota_Tim (id_kebutuhan, id_tim, posisi_dibutuhkan, keahlian_dibutuhkan, jumlah_anggota_dibutuhkan) VALUES (?, ?, ?, ?, ?)',
          [`keb_${Date.now()}_${Math.random().toString(36).substr(2, 4)}`, id_tim, item.posisi_dibutuhkan, item.keahlian_dibutuhkan, item.jumlah_anggota_dibutuhkan || 1]
        );
      }
    }

    // Dokumen pendukung yang diunggah
    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const file = req.files[i];
        const jenis = req.body[`jenis_dokumen[${i}]`] || (path.extname(file.originalname).toLowerCase() === '.pdf' ? 'panduan' : 'poster');
        const id_dok = `dok_${Date.now()}_${i}`;
        const relativePath = `teams/${file.filename}`;

        await db.query(
          'INSERT INTO Dokumen_Pendukung (id_dokumen, id_tim, jenis_dokumen, nama_file, path_file, urutan) VALUES (?, ?, ?, ?, ?, ?)',
          [id_dok, id_tim, jenis, file.originalname, relativePath, i + 1]
        );
      }
    }

    // Ambil data tim lengkap sesuai API specification contract v1.0.0
    const [createdRows] = await db.query('SELECT * FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    const createdTeam = createdRows[0];
    const [kebutuhanList] = await db.query('SELECT * FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?', [id_tim]);
    const [dokumenList] = await db.query('SELECT * FROM Dokumen_Pendukung WHERE id_tim = ? ORDER BY urutan ASC', [id_tim]);
    createdTeam.kebutuhan_tim = kebutuhanList;
    createdTeam.dokumen_pendukung = dokumenList;
    createdTeam.anggota_tim = [];
    createdTeam.peran = 'pemilik';

    return res.status(201).json({
      success: true,
      message: 'Tim berhasil dibuat',
      data: createdTeam
    });
  } catch (error) {
    console.error('Error create team:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/teams/:id_tim/applications (FR-17: Pelamar Masuk ke Tim - Pembuat Tim)
router.get('/:id_tim/applications', async (req, res) => {
  try {
    const { id_tim } = req.params;
    const { status } = req.query;
    const id_pengguna = getAuthUserId(req);

    // 1. Validasi keberadaan tim dan otorisasi pembuat tim
    const [teamRows] = await db.query(
      'SELECT id_tim, id_pengguna, nama_tim, nama_kegiatan FROM Data_Tim WHERE id_tim = ?',
      [id_tim]
    );

    if (teamRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Tim tidak ditemukan.'
      });
    }

    const team = teamRows[0];
    if (team.id_pengguna !== id_pengguna) {
      return res.status(403).json({
        success: false,
        message: 'Akses ditolak. Hanya pembuat tim yang dapat melihat daftar pengajuan ini.'
      });
    }

    // 2. Query data pelamar dengan join Pengguna dan Data_Diri
    let query = `
      SELECT 
        pbt.id_pengajuan_bergabung_tim,
        pbt.id_tim,
        pbt.id_pengguna,
        pbt.posisi,
        pbt.pesan_pengajuan,
        pbt.waktu_pengajuan,
        pbt.status_pengajuan,
        p.nama_pengguna,
        p.nim,
        p.foto_profil,
        dd.program_studi,
        dd.fakultas,
        dd.ipk,
        dd.kontak,
        dt.nama_tim,
        dt.nama_kegiatan
      FROM Pengajuan_Bergabung_Tim pbt
      JOIN Data_Tim dt ON pbt.id_tim = dt.id_tim
      JOIN Pengguna p ON pbt.id_pengguna = p.id_pengguna
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      WHERE pbt.id_tim = ?
    `;
    const params = [id_tim];

    if (status && status !== 'Semua' && ['menunggu', 'diterima', 'ditolak'].includes(status.toString().toLowerCase().trim())) {
      query += ` AND LOWER(pbt.status_pengajuan) = ?`;
      params.push(status.toString().toLowerCase().trim());
    }

    query += ` ORDER BY pbt.waktu_pengajuan DESC`;

    const [rows] = await db.query(query, params);

    // 3. Hitung rekap counter status lamaran (FR-17)
    const [counts] = await db.query(`
      SELECT 
        COUNT(*) AS total,
        SUM(CASE WHEN status_pengajuan = 'menunggu' THEN 1 ELSE 0 END) AS menunggu,
        SUM(CASE WHEN status_pengajuan = 'diterima' THEN 1 ELSE 0 END) AS diterima,
        SUM(CASE WHEN status_pengajuan = 'ditolak' THEN 1 ELSE 0 END) AS ditolak
      FROM Pengajuan_Bergabung_Tim
      WHERE id_tim = ?
    `, [id_tim]);

    const summary = {
      total: Number(counts[0]?.total || 0),
      menunggu: Number(counts[0]?.menunggu || 0),
      diterima: Number(counts[0]?.diterima || 0),
      ditolak: Number(counts[0]?.ditolak || 0)
    };

    return res.json({
      success: true,
      message: 'Daftar pengajuan tim berhasil dimuat.',
      team: {
        id_tim: team.id_tim,
        nama_tim: team.nama_tim,
        nama_kegiatan: team.nama_kegiatan
      },
      summary,
      data: rows
    });
  } catch (error) {
    console.error('Error get team applications:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

// GET /api/v1/teams/:id_tim (FR-09: Detail Tim)
router.get('/:id_tim', async (req, res) => {
  try {
    const { id_tim } = req.params;
    const id_pengguna = getAuthUserId(req);
    const [teams] = await db.query(`
      SELECT dt.*, p.nama_pengguna, p.foto_profil,
        CASE WHEN dt.id_pengguna = ? THEN 'pemilik' ELSE 'anggota' END AS peran
      FROM Data_Tim dt
      JOIN Pengguna p ON dt.id_pengguna = p.id_pengguna
      WHERE dt.id_tim = ?
    `, [id_pengguna, id_tim]);

    if (teams.length === 0) return res.status(404).json({ success: false, message: 'Tim tidak ditemukan' });

    const team = teams[0];
    if (team.id_pengguna !== id_pengguna) {
      const [membership] = await db.query(
        'SELECT id_anggota_tim FROM Anggota_Tim WHERE id_tim = ? AND id_pengguna = ?',
        [id_tim, id_pengguna]
      );
      if (membership.length === 0) {
        return res.status(403).json({ success: false, message: 'Hanya pemilik atau anggota tim yang dapat melihat detail ini.' });
      }
    }

    const [kebutuhan] = await db.query('SELECT * FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?', [id_tim]);
    const [dokumen] = await db.query('SELECT * FROM Dokumen_Pendukung WHERE id_tim = ? ORDER BY urutan ASC', [id_tim]);
    const [anggota] = await db.query(`
      SELECT at.*, p.nama_pengguna, p.foto_profil, dd.program_studi
      FROM Anggota_Tim at
      JOIN Pengguna p ON at.id_pengguna = p.id_pengguna
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      WHERE at.id_tim = ?
    `, [id_tim]);

    team.kebutuhan_tim = kebutuhan;
    team.dokumen_pendukung = dokumen;
    team.anggota_tim = anggota;

    return res.json({ success: true, data: team });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// POST /api/v1/teams/:id_tim/update (Alternatif multipart update FR-10)
router.post('/:id_tim/update', upload.any(), async (req, res) => {
  try {
    const { id_tim } = req.params;
    const { nama_tim, nama_kegiatan, deskripsi, status_tim } = req.body;
    let kebutuhan = req.body.kebutuhan;
    if (typeof kebutuhan === 'string') {
      try {
        kebutuhan = JSON.parse(kebutuhan);
      } catch (_) { }
    }

    const [existing] = await db.query('SELECT * FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Tim tidak ditemukan' });
    }
    if (existing[0].id_pengguna !== getAuthUserId(req)) {
      return res.status(403).json({ success: false, message: 'Hanya pemilik tim yang dapat mengubah tim ini.' });
    }

    // Aturan Bisnis FR-10: kategori_kegiatan dikunci / tidak boleh diubah
    if (req.body.kategori_kegiatan && req.body.kategori_kegiatan !== existing[0].kategori_kegiatan) {
      return res.status(422).json({
        success: false,
        message: 'Kategori kegiatan dikunci dan tidak dapat diubah setelah tim dibuat.'
      });
    }

    await db.query(
      'UPDATE Data_Tim SET nama_tim = ?, nama_kegiatan = ?, deskripsi = ?, status_tim = ? WHERE id_tim = ?',
      [nama_tim, nama_kegiatan, deskripsi, status_tim || existing[0].status_tim, id_tim]
    );

    if (Array.isArray(kebutuhan)) {
      await db.query('DELETE FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?', [id_tim]);
      for (const item of kebutuhan) {
        await db.query(
          'INSERT INTO Kebutuhan_Anggota_Tim (id_kebutuhan, id_tim, posisi_dibutuhkan, keahlian_dibutuhkan, jumlah_anggota_dibutuhkan) VALUES (?, ?, ?, ?, ?)',
          [`keb_${Date.now()}_${Math.random().toString(36).substr(2, 4)}`, id_tim, item.posisi_dibutuhkan, item.keahlian_dibutuhkan, item.jumlah_anggota_dibutuhkan || 1]
        );
      }
    }

    if (req.files && req.files.length > 0) {
      for (let i = 0; i < req.files.length; i++) {
        const file = req.files[i];
        const jenis = req.body[`jenis_dokumen[${i}]`] || (path.extname(file.originalname).toLowerCase() === '.pdf' ? 'panduan' : 'poster');
        const id_dok = `dok_${Date.now()}_${i}`;
        const relativePath = `teams/${file.filename}`;

        await db.query(
          'INSERT INTO Dokumen_Pendukung (id_dokumen, id_tim, jenis_dokumen, nama_file, path_file, urutan) VALUES (?, ?, ?, ?, ?, ?)',
          [id_dok, id_tim, jenis, file.originalname, relativePath, i + 1]
        );
      }
    }

    // Ambil data tim terbaru
    const [teams] = await db.query('SELECT * FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    const team = teams[0] || {};
    team.peran = 'pemilik';
    const [kebutuhanList] = await db.query('SELECT * FROM Kebutuhan_Anggota_Tim WHERE id_tim = ?', [id_tim]);
    const [dokumenList] = await db.query('SELECT * FROM Dokumen_Pendukung WHERE id_tim = ? ORDER BY urutan ASC', [id_tim]);
    const [anggotaList] = await db.query(`
      SELECT at.*, p.nama_pengguna, p.foto_profil, dd.program_studi
      FROM Anggota_Tim at
      JOIN Pengguna p ON at.id_pengguna = p.id_pengguna
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      WHERE at.id_tim = ?
    `, [id_tim]);

    team.kebutuhan_tim = kebutuhanList;
    team.dokumen_pendukung = dokumenList;
    team.anggota_tim = anggotaList;

    return res.json({ success: true, message: 'Data tim berhasil diperbarui', data: team });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// PUT /api/v1/teams/:id_tim (FR-10: Ubah Tim JSON)
router.put('/:id_tim', async (req, res) => {
  try {
    const { id_tim } = req.params;
    const { nama_tim, nama_kegiatan, deskripsi, status_tim } = req.body;

    const [existing] = await db.query('SELECT * FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Tim tidak ditemukan' });
    }
    if (existing[0].id_pengguna !== getAuthUserId(req)) {
      return res.status(403).json({ success: false, message: 'Hanya pemilik tim yang dapat mengubah tim ini.' });
    }

    // Aturan Bisnis FR-10: kategori_kegiatan dikunci / tidak boleh diubah
    if (req.body.kategori_kegiatan && req.body.kategori_kegiatan !== existing[0].kategori_kegiatan) {
      return res.status(422).json({
        success: false,
        message: 'Kategori kegiatan dikunci dan tidak dapat diubah setelah tim dibuat.'
      });
    }

    await db.query(
      'UPDATE Data_Tim SET nama_tim = ?, nama_kegiatan = ?, deskripsi = ?, status_tim = ? WHERE id_tim = ?',
      [nama_tim, nama_kegiatan, deskripsi, status_tim || existing[0].status_tim, id_tim]
    );
    return res.json({ success: true, message: 'Data tim berhasil diperbarui' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// DELETE /api/v1/teams/:id_tim (FR-11: Hapus Tim)
router.delete('/:id_tim', async (req, res) => {
  try {
    const { id_tim } = req.params;
    const [existing] = await db.query('SELECT id_tim, id_pengguna FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Tim tidak ditemukan' });
    }
    if (existing[0].id_pengguna !== getAuthUserId(req)) {
      return res.status(403).json({ success: false, message: 'Hanya pemilik tim yang dapat menghapus tim ini.' });
    }

    await db.query('DELETE FROM Data_Tim WHERE id_tim = ?', [id_tim]);
    return res.json({ success: true, message: 'Tim berhasil dihapus dari sistem.' });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
