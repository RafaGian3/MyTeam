-- =============================================================================
-- BASIS DATA: myteam_db
-- DML (DATA MANIPULATION LANGUAGE) SEEDER / DUMMY DATA
-- APLIKASI: MyTeam – Pencarian dan Pembentukan Tim Mahasiswa Unand
-- ACUAN: schema_myteam.sql, PRD v1.0, & API Specification Contract v1.0.0
-- TARGET DBMS: MySQL 8.0 / MariaDB 10.4+ (phpMyAdmin Compatible)
-- =============================================================================

USE myteam_db;

-- Matikan pengecekan FK sementara agar aman saat replace/insert ulang
SET FOREIGN_KEY_CHECKS = 0;

-- Kosongkan tabel jika ada data lama (urutan anak ke induk)
DELETE FROM Notifikasi;
DELETE FROM Pengajuan_Anggota;
DELETE FROM Pengajuan_Bergabung_Tim;
DELETE FROM Anggota_Tim;
DELETE FROM Dokumen_Pendukung;
DELETE FROM Kebutuhan_Anggota_Tim;
DELETE FROM Data_Tim;
DELETE FROM Data_Pengalaman;
DELETE FROM Data_Keahlian;
DELETE FROM Data_Minat;
DELETE FROM Media_Sosial;
DELETE FROM Data_Diri;
DELETE FROM Pengguna;

SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================================
-- 1. TABEL PENGGUNA (4 Mahasiswa Asli Pengembang MyTeam)
-- Catatan: Password default untuk semua akun adalah "SandiAman123!" (hash bcrypt)
-- =============================================================================
INSERT INTO Pengguna (id_pengguna, nim, kata_sandi, nama_pengguna, foto_profil, created_at) VALUES
('usr_fuadi_01', '2411522001', '$2y$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77EFr6', 'Fuadi Dhiyaulhaq', 'profiles/usr_fuadi_01.jpg', '2026-10-01 08:30:00'),
('usr_rafa_02',  '2411522014', '$2y$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77EFr6', 'Rafa Gian Atthari', 'profiles/usr_rafa_02.jpg',  '2026-10-01 08:35:00'),
('usr_diva_03',  '2411521017', '$2y$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77EFr6', 'Diva Ramadhani',   'profiles/usr_diva_03.jpg',  '2026-10-01 08:40:00'),
('usr_nayla_04', '2411521007', '$2y$10$TKh8H1.PfQx37YgCzwiKb.KjNyWgaHb9cbcoQgdIVFlYg7B77EFr6', 'Nayla Puspita Sari','profiles/usr_nayla_04.jpg', '2026-10-01 08:45:00');


-- =============================================================================
-- 2. TABEL DATA_DIRI (Biodata & Rekam Akademik Mahasiswa)
-- =============================================================================
INSERT INTO Data_Diri (id_pengguna, deskripsi_singkat, kontak, program_studi, fakultas, ipk, updated_at) VALUES
('usr_fuadi_01', 
 'Mahasiswa Sistem Informasi yang berfokus pada Mobile App Development dengan Flutter. Berpengalaman dalam arsitektur MVVM, Clean Architecture, serta integrasi RESTful API.', 
 '081267891011', 'Sistem Informasi', 'Teknologi Informasi', 3.85, '2026-10-10 09:00:00'),

('usr_rafa_02', 
 'Ketua tim dengan ketertarikan tinggi pada Software Engineering, Intelligent Systems, dan Internet of Things. Terbiasa memimpin perancangan produk dari ideation hingga deployment.', 
 '081267891012', 'Sistem Informasi', 'Teknologi Informasi', 3.80, '2026-10-10 09:15:00'),

('usr_diva_03', 
 'UI/UX Designer yang berorientasi pada Human-Centered Design. Gemar melakukan user research, prototyping interaktif di Figma, dan menyusun design system konsisten.', 
 '081267891013', 'Sistem Informasi', 'Teknologi Informasi', 3.82, '2026-10-10 09:30:00'),

('usr_nayla_04', 
 'Peneliti muda di bidang Data Science dan Analisis Sistem. Memiliki minat kuat dalam penulisan proposal hibah kompetitif (PKM) dan pengolahan data analitik.', 
 '081267891014', 'Sistem Informasi', 'Teknologi Informasi', 3.88, '2026-10-10 09:45:00');


-- =============================================================================
-- 3. TABEL MEDIA_SOSIAL (Kontak Portofolio Mahasiswa)
-- =============================================================================
INSERT INTO Media_Sosial (id_media_sosial, id_pengguna, nama_media_sosial, link_media_sosial, created_at) VALUES
-- Fuadi
('soc_01', 'usr_fuadi_01', 'GitHub',    'https://github.com/fuadidhy',                '2026-10-02 10:00:00'),
('soc_02', 'usr_fuadi_01', 'LinkedIn',  'https://linkedin.com/in/fuadi-dhiyaulhaq',  '2026-10-02 10:02:00'),
('soc_03', 'usr_fuadi_01', 'Instagram', 'https://instagram.com/fuadidhy',             '2026-10-02 10:05:00'),
-- Rafa
('soc_04', 'usr_rafa_02',  'GitHub',    'https://github.com/rafagian',                '2026-10-02 10:10:00'),
('soc_05', 'usr_rafa_02',  'LinkedIn',  'https://linkedin.com/in/rafa-gian-atthari',  '2026-10-02 10:12:00'),
('soc_06', 'usr_rafa_02',  'Instagram', 'https://instagram.com/rafagian',              '2026-10-02 10:15:00'),
-- Diva
('soc_07', 'usr_diva_03',  'LinkedIn',  'https://linkedin.com/in/diva-ramadhani',     '2026-10-02 10:20:00'),
('soc_08', 'usr_diva_03',  'Behance',   'https://behance.net/divaramadhani',          '2026-10-02 10:22:00'),
('soc_09', 'usr_diva_03',  'Instagram', 'https://instagram.com/divaramadhani_',       '2026-10-02 10:25:00'),
-- Nayla
('soc_10', 'usr_nayla_04', 'LinkedIn',  'https://linkedin.com/in/nayla-puspita-sari', '2026-10-02 10:30:00'),
('soc_11', 'usr_nayla_04', 'GitHub',    'https://github.com/naylapuspita',            '2026-10-02 10:32:00'),
('soc_12', 'usr_nayla_04', 'Instagram', 'https://instagram.com/naylapuspita',         '2026-10-02 10:35:00');


-- =============================================================================
-- 4. TABEL DATA_MINAT (Keminatan Tiap Mahasiswa)
-- =============================================================================
INSERT INTO Data_Minat (id_minat, id_pengguna, minat, deskripsi_minat, created_at) VALUES
('mnt_01', 'usr_fuadi_01', 'Mobile App Development',  'Pengembangan aplikasi Android dan iOS lintas platform dengan performa tinggi.', '2026-10-02 11:00:00'),
('mnt_02', 'usr_fuadi_01', 'Kompetisi Software Dev',  'Tertarik aktif berpartisipasi dalam ajang GEMASTIK dan perlombaan IT nasional.', '2026-10-02 11:02:00'),
('mnt_03', 'usr_rafa_02',  'Artificial Intelligence', 'Penerapan computer vision dan deep learning pada aplikasi dunia nyata.',        '2026-10-02 11:10:00'),
('mnt_04', 'usr_rafa_02',  'Product Management',     'Perencanaan roadmap produk dan koordinasi tim teknis multidisiplin.',             '2026-10-02 11:12:00'),
('mnt_05', 'usr_diva_03',  'UI/UX Design',           'Perancangan visual interface yang rapi, ergonomis, dan berpusat pada empati pengguna.', '2026-10-02 11:20:00'),
('mnt_06', 'usr_diva_03',  'Design Sprint',          'Metodologi validasi ide cepat melalui prototyping dan usability testing.',        '2026-10-02 11:22:00'),
('mnt_07', 'usr_nayla_04', 'Data Science & Analytics', 'Eksplorasi data, pemodelan statistik, dan pembuatan dashboard insight.',        '2026-10-02 11:30:00'),
('mnt_08', 'usr_nayla_04', 'Riset Ilmiah & PKM',      'Penulisan proposal Program Kreativitas Mahasiswa bidang Riset Eksakta (PKM-RE).',  '2026-10-02 11:32:00');


-- =============================================================================
-- 5. TABEL DATA_KEAHLIAN (Keahlian Teknis & Non-Teknis)
-- =============================================================================
INSERT INTO Data_Keahlian (id_keahlian, id_pengguna, keahlian, deskripsi_keahlian, created_at) VALUES
('khl_01', 'usr_fuadi_01', 'Flutter & Dart',    'Mahir widget lifecycle, state management (Provider/Bloc), dan integrasi API RESTful.', '2026-10-02 11:40:00'),
('khl_02', 'usr_fuadi_01', 'RESTful API Client', 'Penanganan otentikasi JWT, parsing respons JSON kompleks, dan penanganan status offline.', '2026-10-02 11:42:00'),
('khl_03', 'usr_rafa_02',  'Backend Go / Node.js', 'Perancangan mikroarsitektur service, indexing MySQL, dan komunikasi endpoint.',      '2026-10-02 11:50:00'),
('khl_04', 'usr_rafa_02',  'System Architecture', 'Penyusunan usecase diagram, ERD terstandar, dan arsitektur database relasional.',    '2026-10-02 11:52:00'),
('khl_05', 'usr_diva_03',  'Figma & Prototyping', 'Membuat komponen interaktif, design token, layout auto-layout, dan wireframing mikro.', '2026-10-02 12:00:00'),
('khl_06', 'usr_diva_03',  'Usability Testing',   'Penyusunan task scenario, SUS scoring, dan evaluasi heuristik antarmuka aplikasi.',  '2026-10-02 12:02:00'),
('khl_07', 'usr_nayla_04', 'Python & Pandas',     'Analisis data tabular, visualisasi Matplotlib/Seaborn, dan pemodelan prediktif.',    '2026-10-02 12:10:00'),
('khl_08', 'usr_nayla_04', 'Scientific Writing',  'Penyusunan metodologi penelitian kuantitatif dan kepatuhan format pedoman Dikti.',    '2026-10-02 12:12:00');


-- =============================================================================
-- 6. TABEL DATA_PENGALAMAN (FR-05: Bukti media ditiadakan, deskripsi wajib ada)
-- =============================================================================
INSERT INTO Data_Pengalaman (id_pengalaman, id_pengguna, nama_kegiatan, peran, tahun, deskripsi_pengalaman, created_at) VALUES
('exp_01', 'usr_fuadi_01', 'Lomba Aplikasi Mobile Edukasi Nasional 2025', 'Frontend Lead Developer', 2025, 
 'Mengembangkan aplikasi belajar mandiri berbasis Flutter hingga babak final 10 besar, bertanggung jawab atas seluruh konsumsi API dan transisi UI interaktif.', '2026-10-03 14:00:00'),
('exp_02', 'usr_fuadi_01', 'Proyek Mini Studio PAM 2026', 'Mobile Developer', 2026, 
 'Membangun purwarupa aplikasi kampus pintar Universitas Andalas dengan integrasi sistem autentikasi lokal dan penyimpanan SQLite/shared preferences.', '2026-10-03 14:05:00'),

('exp_03', 'usr_rafa_02', 'GEMASTIK XVI Divisi Software Development', 'Ketua Tim / Backend Developer', 2023, 
 'Merancang ide sistem monitoring bencana dan memimpin koordinasi pembuatan backend REST API dengan arsitektur terdistribusi.', '2026-10-03 14:15:00'),

('exp_04', 'usr_diva_03', 'Sayembara Redesain UI Portal Mahasiswa Unand 2025', 'UI/UX Designer', 2025, 
 'Juara 2 dalam kompetisi desain antarmuka portal akademik, menyajikan riset komprehensif terkait pain point mahasiswa dalam pengisian KRS online.', '2026-10-03 14:25:00'),

('exp_05', 'usr_nayla_04', 'Program Kreativitas Mahasiswa (PKM-AI) Lolos Pendanaan 2025', 'Peneliti Utama', 2025, 
 'Menganalisis sentimen media sosial terhadap kebijakan transportasi publik dan mempublikasikan artikel ilmiah di jurnal terakreditasi SINTA.', '2026-10-03 14:35:00');


-- =============================================================================
-- 7. TABEL DATA_TIM
-- Distribusi tim per pemilik: Fuadi 1, Rafa 2, Diva 3, Nayla 1.
-- =============================================================================
INSERT INTO Data_Tim (id_tim, id_pengguna, nama_tim, nama_kegiatan, kategori_kegiatan, deskripsi, status_tim, created_at) VALUES
('tim_gemastik_01', 'usr_rafa_02', 
 'Tim Robotik Cerdas Unand', 
 'GEMASTIK XVII Divisi Software Development', 
 'Lomba', 
 'Tim dibentuk untuk merancang aplikasi mobile pemantau dan kendali telemetri robot penjelajah otonom kampus. Kami mencari mahasiswa berkomitmen tinggi untuk membawa karya Unand ke kancah nasional.', 
 'terbuka', '2026-10-05 09:00:00'),

('tim_pkm_02', 'usr_nayla_04', 
 'Inovator Pangan Unand', 
 'Program Kreativitas Mahasiswa Riset Eksakta (PKM-RE) 2026', 
 'Penelitian', 
 'Proyek riset interdisipliner untuk membangun model kecerdasan buatan dan aplikasi mobile pemantau kestabilan pasokan komoditas pangan lokal Sumatera Barat.', 
 'terbuka', '2026-10-06 10:00:00'),

('tim_fuadi_03', 'usr_fuadi_01',
 'Aplikasi Jelajah Kampus',
 'Unand Digital Innovation Challenge 2026',
 'Proyek',
 'Mengembangkan aplikasi Flutter untuk membantu mahasiswa menemukan fasilitas dan layanan kampus.',
 'terbuka', '2026-10-07 09:00:00'),

('tim_rafa_04', 'usr_rafa_02',
 'Sistem Irigasi Cerdas',
 'Kompetisi Inovasi Teknologi Pertanian 2026',
 'Lomba',
 'Merancang sistem IoT dan backend untuk pemantauan irigasi lahan pertanian.',
 'terbuka', '2026-10-07 10:00:00'),

('tim_diva_05', 'usr_diva_03',
 'Ruang Belajar Inklusif',
 'Program Kreativitas Mahasiswa Pengabdian 2026',
 'Penelitian',
 'Mendesain pengalaman belajar digital yang mudah diakses oleh mahasiswa dengan beragam kebutuhan.',
 'terbuka', '2026-10-07 11:00:00'),

('tim_diva_06', 'usr_diva_03',
 'Dashboard Data Kampus',
 'Unand Data Visualization Project 2026',
 'Proyek',
 'Membuat dashboard interaktif untuk menyajikan data layanan dan aktivitas kampus.',
 'terbuka', '2026-10-07 12:00:00'),

('tim_diva_07', 'usr_diva_03',
 'Kampanye Literasi Digital',
 'Kompetisi Konten Edukasi Digital 2026',
 'Lomba',
 'Menyusun kampanye konten edukasi keamanan dan literasi digital bagi mahasiswa.',
 'terbuka', '2026-10-07 13:00:00');


-- =============================================================================
-- 8. TABEL KEBUTUHAN_ANGGOTA_TIM (Kriteria Posisi Terbuka pada Tim)
-- =============================================================================
INSERT INTO Kebutuhan_Anggota_Tim (id_kebutuhan, id_tim, posisi_dibutuhkan, keahlian_dibutuhkan, jumlah_anggota_dibutuhkan, created_at) VALUES
-- Kebutuhan Tim Rafa (GEMASTIK)
('keb_01', 'tim_gemastik_01', 'Frontend Flutter', 'Flutter, Dart, REST API Integration, Responsive UI', 1, '2026-10-05 09:10:00'),
('keb_02', 'tim_gemastik_01', 'UI/UX Designer',   'Figma, Wireframing, User Testing, Design System',   1, '2026-10-05 09:12:00'),

-- Kebutuhan Tim Nayla (PKM-RE)
('keb_03', 'tim_pkm_02',      'Mobile App Developer', 'Flutter / Android Native, SQLite / Local Cache',  1, '2026-10-06 10:15:00'),
('keb_04', 'tim_pkm_02',      'Data Analyst',         'Python, Data Modeling, Descriptive Statistics',   1, '2026-10-06 10:18:00'),
('keb_05', 'tim_fuadi_03',    'Flutter Developer',    'Flutter, Dart, REST API',                           1, '2026-10-07 09:10:00'),
('keb_06', 'tim_rafa_04',     'IoT Engineer',         'ESP32, sensor, MQTT',                               1, '2026-10-07 10:10:00'),
('keb_07', 'tim_diva_05',     'UI/UX Designer',       'Figma, accessibility, user research',               1, '2026-10-07 11:10:00'),
('keb_08', 'tim_diva_06',     'Data Visualization Designer', 'Figma, dashboard design, data storytelling', 1, '2026-10-07 12:10:00'),
('keb_09', 'tim_diva_07',     'Content Designer',     'Copywriting, visual design, social media',          1, '2026-10-07 13:10:00');


-- =============================================================================
-- 9. TABEL DOKUMEN_PENDUKUNG (Poster & Panduan Kegiatan Tim)
-- =============================================================================
INSERT INTO Dokumen_Pendukung (id_dokumen, id_tim, jenis_dokumen, nama_file, path_file, urutan, uploaded_at) VALUES
('dok_01', 'tim_gemastik_01', 'poster',  'Poster_Gemastik_XVII_Unand.jpg',    'uploads/teams/tim_gemastik_01/poster_gemastik.jpg', 1, '2026-10-05 09:20:00'),
('dok_02', 'tim_gemastik_01', 'panduan', 'Pedoman_Teknis_Lomba_Gemastik.pdf', 'uploads/teams/tim_gemastik_01/pedoman_teknis.pdf',  2, '2026-10-05 09:22:00'),
('dok_03', 'tim_pkm_02',      'poster',  'Leaflet_PKM_RE_2026.png',           'uploads/teams/tim_pkm_02/leaflet_pkm.png',          1, '2026-10-06 10:25:00');


-- =============================================================================
-- 10. TABEL PENGAJUAN_BERGABUNG_TIM (Pencari Tim Melamar ke Tim Tertentu)
-- Skenario:
-- 1. Diva melamar ke tim Rafa posisi "UI/UX Designer" -> status: diterima
-- 2. Fuadi melamar ke tim Rafa posisi "Frontend Flutter" -> status: menunggu
-- =============================================================================
INSERT INTO Pengajuan_Bergabung_Tim (id_pengajuan_bergabung_tim, id_tim, id_pengguna, posisi, pesan_pengajuan, waktu_pengajuan, status_pengajuan) VALUES
('pbg_01', 'tim_gemastik_01', 'usr_diva_03', 'UI/UX Designer', 
 'Halo Rafa! Saya sangat tertarik bergabung dengan Tim Robotik Cerdas. Portofolio saya di Figma berfokus pada dashboard interaktif yang cocok untuk telemetri robot tim Anda.', 
 '2026-10-07 13:00:00', 'diterima'),

('pbg_02', 'tim_gemastik_01', 'usr_fuadi_01', 'Frontend Flutter', 
 'Halo Rafa, perkenalkan saya Fuadi. Saya memiliki keahlian mendalam di Flutter dan konsumsi REST API. Saya siap mendedikasikan waktu untuk membangun aplikasi telemetri tim GEMASTIK ini.', 
 '2026-10-08 14:30:00', 'menunggu');


-- =============================================================================
-- 11. TABEL ANGGOTA_TIM (Diva Resmi Bergabung ke Tim Rafa setelah Diterima)
-- =============================================================================
INSERT INTO Anggota_Tim (id_anggota_tim, id_tim, id_pengguna, posisi, joined_at) VALUES
('ang_01', 'tim_gemastik_01', 'usr_diva_03', 'UI/UX Designer', '2026-10-07 16:00:00');


-- =============================================================================
-- 13. TABEL NOTIFIKASI (Sinkron Penuh dengan Seluruh Aktivitas di Atas)
-- Distribusi Notifikasi Modul 1 s/d Modul 4:
-- - Fuadi (M1): Notifikasi update profil (FR-07)
-- - Nayla (M2): Notifikasi lamaran baru yang masuk ke tim buatan pengguna (FR-12)
-- - Rafa (M3): Notifikasi status lamaran yang diajukan pelamar (FR-20)
-- - Diva (M4): Notifikasi konfirmasi respon ajakan calon anggota (FR-25)
-- =============================================================================
INSERT INTO Notifikasi (id_notifikasi, id_pengguna, id_pengajuan_bergabung_tim, id_pengajuan_anggota, jenis_notifikasi, pesan_notifikasi, waktu_notifikasi, status_dibaca) VALUES
-- 1. Notifikasi Fuadi: Pembaruan data riwayat diri berhasil (FR-07 - Modul 1 Fuadi)
('notif_01', 'usr_fuadi_01', NULL, NULL, 
 'aktivitas_profil', 
 'Data riwayat diri dan portofolio Anda berhasil diperbarui di sistem MyTeam.', 
 '2026-10-03 14:06:00', TRUE),

-- 2. Notifikasi Rafa: Ada lamaran masuk dari Diva (FR-12 - Modul 2 Notifikasi Lamaran Tim)
('notif_02', 'usr_rafa_02', 'pbg_01', NULL, 
 'pengajuan_masuk', 
 'Diva Ramadhani mengajukan diri untuk bergabung pada posisi UI/UX Designer di tim Anda (Tim Robotik Cerdas Unand).', 
 '2026-10-07 13:01:00', TRUE),

-- 3. Notifikasi Diva: Lamaran ke tim Rafa diterima (FR-20 - Modul 3 Notifikasi Status Pelamar)
('notif_03', 'usr_diva_03', 'pbg_01', NULL, 
 'pengajuan_diterima', 
 'Selamat! Pengajuan bergabung Anda untuk posisi UI/UX Designer pada "Tim Robotik Cerdas Unand" telah diterima oleh Rafa Gian Atthari.', 
 '2026-10-07 16:01:00', TRUE),

-- 4. Notifikasi Rafa: Ada lamaran masuk dari Fuadi (FR-12 - Modul 2 Rafa)
('notif_04', 'usr_rafa_02', 'pbg_02', NULL, 
 'pengajuan_masuk', 
 'Fuadi Dhiyaulhaq mengajukan diri untuk bergabung pada posisi Frontend Flutter di tim Anda (Tim Robotik Cerdas Unand).', 
 '2026-10-08 14:31:00', FALSE);

-- =============================================================================
-- SELESAI: Seluruh Data Dummy Berhasil Di-generate
-- =============================================================================
