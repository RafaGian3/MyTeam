/**
 * seed_teams_dummy.js
 * Script untuk menambahkan data dummy Tim ke database myteam_db
 * Jalankan: node seed_teams_dummy.js
 * 
 * Tim akan dibuat atas nama user yang sedang login di app:
 * - usr_fuadi_01 (default fallback di members.js / applications.js)
 * - usr_rafa_02  (default fallback di teams.js)
 */

const mysql = require('mysql2/promise');
require('dotenv').config();

const db = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'myteam_db',
  port: process.env.DB_PORT || 3306,
});

const teams = [
  {
    id_tim: 'tim_diva_001',
    id_pengguna: 'usr_fuadi_01',   // user login default di members/applications
    nama_tim: 'Tim Riset AI Unand',
    nama_kegiatan: 'Penelitian NLP & Sentiment Analysis',
    kategori_kegiatan: 'Penelitian',
    deskripsi: 'Tim riset yang berfokus pada pengembangan model NLP untuk Bahasa Indonesia, khususnya analisis sentimen di media sosial.',
    status_tim: 'terbuka',
    kebutuhan: [
      { posisi: 'Machine Learning Engineer', keahlian: 'Python, TensorFlow/PyTorch', jumlah: 2 },
      { posisi: 'Backend Developer', keahlian: 'Node.js atau FastAPI', jumlah: 1 },
    ]
  },
  {
    id_tim: 'tim_diva_002',
    id_pengguna: 'usr_fuadi_01',
    nama_tim: 'Gemastik UI/UX Team',
    nama_kegiatan: 'Gemastik XVII - Desain UX',
    kategori_kegiatan: 'Lomba',
    deskripsi: 'Tim yang mempersiapkan kompetisi Gemastik XVII kategori UI/UX Design, membuat prototype aplikasi mobile untuk UMKM Sumatera Barat.',
    status_tim: 'terbuka',
    kebutuhan: [
      { posisi: 'UI/UX Designer', keahlian: 'Figma, user research', jumlah: 1 },
      { posisi: 'Flutter Developer', keahlian: 'Flutter, Dart, prototype interaktif', jumlah: 1 },
    ]
  },
  {
    id_tim: 'tim_diva_003',
    id_pengguna: 'usr_rafa_02',    // user login default di teams.js
    nama_tim: 'PKM-KC Inovasi Pertanian',
    nama_kegiatan: 'PKM Karsa Cipta - Smart Farming IoT',
    kategori_kegiatan: 'Penelitian',
    deskripsi: 'Tim PKM Karsa Cipta yang mengembangkan sistem monitoring kebun cerdas berbasis IoT dan dashboard real-time untuk petani Sumatera Barat.',
    status_tim: 'terbuka',
    kebutuhan: [
      { posisi: 'IoT Engineer', keahlian: 'Arduino, ESP32', jumlah: 1 },
      { posisi: 'Frontend Developer', keahlian: 'React.js atau Vue.js', jumlah: 1 },
      { posisi: 'Data Analyst', keahlian: 'Python, pandas, visualisasi data', jumlah: 1 },
    ]
  },
];

async function seed() {
  const conn = await db.getConnection();
  try {
    console.log('🌱 Memulai seeding data dummy tim...\n');

    for (const team of teams) {
      // 1. Cek apakah id_tim sudah ada
      const [existing] = await conn.query(
        'SELECT id_tim FROM Data_Tim WHERE id_tim = ?', [team.id_tim]
      );

      if (existing.length > 0) {
        console.log(`⏭️  Tim "${team.nama_tim}" sudah ada — skip.`);
        continue;
      }

      // 2. Cek apakah id_pengguna ada di tabel Pengguna
      const [user] = await conn.query(
        'SELECT id_pengguna FROM Pengguna WHERE id_pengguna = ?', [team.id_pengguna]
      );
      if (user.length === 0) {
        console.log(`⚠️  User "${team.id_pengguna}" tidak ditemukan — skip tim "${team.nama_tim}".`);
        console.log(`   → Pastikan user ini ada di tabel Pengguna.\n`);
        continue;
      }

      // 3. Insert Data_Tim
      await conn.query(
        `INSERT INTO Data_Tim 
          (id_tim, id_pengguna, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, status_tim)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [team.id_tim, team.id_pengguna, team.nama_tim, team.nama_kegiatan,
         team.kategori_kegiatan, team.deskripsi, team.status_tim]
      );
      console.log(`✅ Tim "${team.nama_tim}" berhasil dibuat (${team.id_tim})`);

      // 4. Insert Kebutuhan_Anggota_Tim
      for (const keb of team.kebutuhan) {
        const id_keb = `keb_${Date.now()}_${Math.random().toString(36).substr(2, 4)}`;
        await conn.query(
          `INSERT INTO Kebutuhan_Anggota_Tim 
            (id_kebutuhan, id_tim, posisi_dibutuhkan, keahlian_dibutuhkan, jumlah_anggota_dibutuhkan)
           VALUES (?, ?, ?, ?, ?)`,
          [id_keb, team.id_tim, keb.posisi, keb.keahlian, keb.jumlah]
        );
        console.log(`   ➕ Kebutuhan: ${keb.posisi} (${keb.jumlah} orang)`);
      }
      console.log('');
    }

    console.log('✅ Seeding selesai!\n');
    console.log('👤 Tim untuk usr_fuadi_01:');
    console.log('   - tim_diva_001: Tim Riset AI Unand');
    console.log('   - tim_diva_002: Gemastik UI/UX Team');
    console.log('\n👤 Tim untuk usr_rafa_02:');
    console.log('   - tim_diva_003: PKM-KC Inovasi Pertanian');
    console.log('\n📱 Sekarang buka app → Cari Talenta → klik calon anggota → "Ajak Bergabung ke Tim"');
    console.log('   Dropdown tim akan muncul secara otomatis!');

  } catch (err) {
    console.error('❌ Error saat seeding:', err.message);
    console.error(err);
  } finally {
    conn.release();
    process.exit(0);
  }
}

seed();
