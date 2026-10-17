const express = require('express');
const router = express.Router();
const db = require('../config/db');

// GET /api/v1/members/search (FR-21: Pencarian Calon Anggota)
router.get('/search', async (req, res) => {
  try {
    const { q, keahlian, minat, page = 1, limit = 20 } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);

    let query = `
      SELECT p.id_pengguna, p.nim, p.nama_pengguna, p.foto_profil,
             dd.program_studi, dd.fakultas, dd.ipk, dd.deskripsi_singkat
      FROM Pengguna p
      LEFT JOIN Data_Diri dd ON p.id_pengguna = dd.id_pengguna
      WHERE 1=1
    `;
    const params = [];

    if (q) {
      query += ` AND (p.nama_pengguna LIKE ? OR dd.program_studi LIKE ? OR p.nim LIKE ?)`;
      params.push(`%${q}%`, `%${q}%`, `%${q}%`);
    }

    const [members] = await db.query(query, params);

    // Ambil keahlian, minat & total_pengalaman per anggota (filter di app level)
    const filtered = [];
    for (const member of members) {
      const [khl] = await db.query('SELECT keahlian FROM Data_Keahlian WHERE id_pengguna = ?', [member.id_pengguna]);
      const [mnt] = await db.query('SELECT minat FROM Data_Minat WHERE id_pengguna = ?', [member.id_pengguna]);
      const [expCount] = await db.query('SELECT COUNT(*) AS total FROM Data_Pengalaman WHERE id_pengguna = ?', [member.id_pengguna]);

      const memberKeahlian = khl.map(k => k.keahlian);
      const memberMinat = mnt.map(m => m.minat);

      // Filter keahlian jika ada parameter
      if (keahlian && !memberKeahlian.some(k => k.toLowerCase().includes(keahlian.toLowerCase()))) {
        continue;
      }
      // Filter minat jika ada parameter
      if (minat && !memberMinat.some(m => m.toLowerCase().includes(minat.toLowerCase()))) {
        continue;
      }

      member.keahlian = memberKeahlian;
      member.minat = memberMinat;
      member.total_pengalaman = expCount[0]?.total ?? 0;
      filtered.push(member);
    }

    // Pagination manual setelah filter keahlian/minat (karena filter di app-level)
    const totalRecords = filtered.length;
    const totalPages = Math.ceil(totalRecords / parseInt(limit));
    const results = filtered.slice(offset, offset + parseInt(limit));

    return res.json({
      success: true,
      message: 'Pencarian calon anggota berhasil',
      data: results,
      pagination: {
        current_page: parseInt(page),
        per_page: parseInt(limit),
        total_records: totalRecords,
        total_pages: totalPages
      }
    });
  } catch (error) {
    console.error('Error search members:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
