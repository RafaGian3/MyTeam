-- =============================================================================
-- BASIS DATA: myteam_db
-- DDL (DATA DEFINITION LANGUAGE) SCHEMA SPECIFICATION
-- APLIKASI: MyTeam – Pencarian dan Pembentukan Tim Mahasiswa Unand
-- ACUAN: PRD v1.0 & API Specification Contract v1.0.0
-- TARGET DBMS: MySQL 8.0 / MariaDB 10.4+ (Kompatibel Penuh phpMyAdmin)
-- =============================================================================

-- Nonaktifkan pengecekan foreign key sementara agar urutan DROP aman
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- 0. INISIALISASI BASIS DATA
-- -----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS myteam_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE myteam_db;

-- Hapus tabel jika sudah ada sebelumnya (urutan terbalik relasi)
DROP TABLE IF EXISTS Notifikasi;
DROP TABLE IF EXISTS Pengajuan_Anggota;
DROP TABLE IF EXISTS Pengajuan_Bergabung_Tim;
DROP TABLE IF EXISTS Anggota_Tim;
DROP TABLE IF EXISTS Dokumen_Pendukung;
DROP TABLE IF EXISTS Kebutuhan_Anggota_Tim;
DROP TABLE IF EXISTS Data_Tim;
DROP TABLE IF EXISTS Data_Pengalaman;
DROP TABLE IF EXISTS Data_Keahlian;
DROP TABLE IF EXISTS Data_Minat;
DROP TABLE IF EXISTS Media_Sosial;
DROP TABLE IF EXISTS Data_Diri;
DROP TABLE IF EXISTS Pengguna;

-- Aktifkan kembali pengecekan foreign key
SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================================
-- BLOK 1: MODUL 1 — PENGGUNA, PROFIL, DAN DATA RIWAYAT DIRI
-- =============================================================================

-- 1. Tabel Pengguna (Entitas Induk Akun Mahasiswa)
CREATE TABLE Pengguna (
    id_pengguna VARCHAR(36) NOT NULL,
    nim VARCHAR(10) NOT NULL,
    kata_sandi VARCHAR(255) NOT NULL,
    nama_pengguna VARCHAR(100) NOT NULL,
    foto_profil VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_pengguna),
    UNIQUE KEY uq_pengguna_nim (nim)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 2. Tabel Data_Diri (Informasi Biodata & Akademik Mahasiswa - 1:1 Pengguna)
CREATE TABLE Data_Diri (
    id_pengguna VARCHAR(36) NOT NULL,
    deskripsi_singkat TEXT NULL,
    kontak VARCHAR(20) NOT NULL,
    program_studi VARCHAR(50) NOT NULL,
    fakultas VARCHAR(50) NOT NULL,
    ipk DECIMAL(3,2) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_pengguna),
    CONSTRAINT fk_datadiri_pengguna FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 3. Tabel Media_Sosial (Tautan Media Sosial Pengguna - 1:N Pengguna)
CREATE TABLE Media_Sosial (
    id_media_sosial VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL,
    nama_media_sosial VARCHAR(50) NOT NULL,
    link_media_sosial VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_media_sosial),
    CONSTRAINT fk_medsos_pengguna FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 4. Tabel Data_Minat (Minat Bidang Mahasiswa - 1:N Pengguna)
CREATE TABLE Data_Minat (
    id_minat VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL,
    minat VARCHAR(100) NOT NULL,
    deskripsi_minat TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_minat),
    CONSTRAINT fk_minat_pengguna FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 5. Tabel Data_Keahlian (Keahlian Teknis / Soft-skill - 1:N Pengguna)
CREATE TABLE Data_Keahlian (
    id_keahlian VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL,
    keahlian VARCHAR(100) NOT NULL,
    deskripsi_keahlian TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_keahlian),
    CONSTRAINT fk_keahlian_pengguna FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 6. Tabel Data_Pengalaman (Riwayat Kegiatan/Lomba - FR-05 Refinement PRD v1.0)
-- Catatan PRD v1.0: Bukti/media ditiadakan, atribut deskripsi_pengalaman disertakan
CREATE TABLE Data_Pengalaman (
    id_pengalaman VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL,
    nama_kegiatan VARCHAR(150) NOT NULL,
    peran VARCHAR(100) NOT NULL,
    tahun INT NOT NULL,
    deskripsi_pengalaman TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_pengalaman),
    CONSTRAINT fk_pengalaman_pengguna FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- BLOK 2: MODUL 2 — DATA TIM, KEBUTUHAN, DAN DOKUMEN PENDUKUNG
-- =============================================================================

-- 7. Tabel Data_Tim (Informasi Tim yang Dibentuk oleh Mahasiswa - FR-08..11)
CREATE TABLE Data_Tim (
    id_tim VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL, -- Relasi ke Pembuat Tim
    nama_tim VARCHAR(100) NOT NULL,
    nama_kegiatan VARCHAR(150) NOT NULL,
    kategori_kegiatan ENUM('Lomba', 'Penelitian', 'Proyek', 'Lainnya') NOT NULL,
    deskripsi TEXT NOT NULL,
    status_tim ENUM('terbuka', 'ditutup') NOT NULL DEFAULT 'terbuka',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id_tim),
    CONSTRAINT fk_tim_pembuat FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 8. Tabel Kebutuhan_Anggota_Tim (Posisi & Kriteria Anggota yang Dibutuhkan Tim)
CREATE TABLE Kebutuhan_Anggota_Tim (
    id_kebutuhan VARCHAR(36) NOT NULL,
    id_tim VARCHAR(36) NOT NULL,
    posisi_dibutuhkan VARCHAR(100) NOT NULL,
    keahlian_dibutuhkan VARCHAR(255) NOT NULL,
    jumlah_anggota_dibutuhkan INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_kebutuhan),
    CONSTRAINT fk_kebutuhan_tim FOREIGN KEY (id_tim) 
        REFERENCES Data_Tim (id_tim) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 9. Tabel Dokumen_Pendukung (Poster dan Pedoman Panduan Tim)
CREATE TABLE Dokumen_Pendukung (
    id_dokumen VARCHAR(36) NOT NULL,
    id_tim VARCHAR(36) NOT NULL,
    jenis_dokumen ENUM('poster', 'panduan') NOT NULL,
    nama_file VARCHAR(255) NOT NULL,
    path_file VARCHAR(255) NOT NULL,
    urutan INT NOT NULL DEFAULT 1,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_dokumen),
    CONSTRAINT fk_dokumen_tim FOREIGN KEY (id_tim) 
        REFERENCES Data_Tim (id_tim) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 10. Tabel Anggota_Tim (Daftar Mahasiswa yang Resmi Bergabung dalam Tim)
CREATE TABLE Anggota_Tim (
    id_anggota_tim VARCHAR(36) NOT NULL,
    id_tim VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL,
    posisi VARCHAR(100) NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_anggota_tim),
    UNIQUE KEY uq_tim_anggota (id_tim, id_pengguna),
    CONSTRAINT fk_anggotatim_tim FOREIGN KEY (id_tim) 
        REFERENCES Data_Tim (id_tim) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_anggotatim_pengguna FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- BLOK 3: MODUL 3 & 4 — PENGAJUAN BERGABUNG, PENGAJUAN ANGGOTA & NOTIFIKASI
-- =============================================================================

-- 11. Tabel Pengajuan_Bergabung_Tim (Lamaran Pencari Tim ke Tim Tertentu - FR-16 Refinement)
-- Catatan PRD v1.0: Atribut posisi wajib disertakan saat melamar
CREATE TABLE Pengajuan_Bergabung_Tim (
    id_pengajuan_bergabung_tim VARCHAR(36) NOT NULL,
    id_tim VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL, -- Pelamar
    posisi VARCHAR(100) NOT NULL,     -- Posisi yang dilamar (Wajib)
    pesan_pengajuan TEXT NOT NULL,
    waktu_pengajuan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_pengajuan ENUM('menunggu', 'diterima', 'ditolak') NOT NULL DEFAULT 'menunggu',
    PRIMARY KEY (id_pengajuan_bergabung_tim),
    CONSTRAINT fk_pengajuan_bergabung_tim FOREIGN KEY (id_tim) 
        REFERENCES Data_Tim (id_tim) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pengajuan_bergabung_pelamar FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 12. Tabel Pengajuan_Anggota (Undangan Rekrutmen Pembuat Tim ke Calon Anggota - FR-23)
CREATE TABLE Pengajuan_Anggota (
    id_pengajuan_anggota VARCHAR(36) NOT NULL,
    id_tim VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL, -- Calon Anggota yang diundang
    posisi VARCHAR(100) NOT NULL,     -- Posisi yang ditawarkan pembuat tim
    pesan_pengajuan TEXT NOT NULL,
    waktu_pengajuan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_pengajuan ENUM('menunggu', 'diterima', 'ditolak') NOT NULL DEFAULT 'menunggu',
    PRIMARY KEY (id_pengajuan_anggota),
    CONSTRAINT fk_pengajuan_anggota_tim FOREIGN KEY (id_tim) 
        REFERENCES Data_Tim (id_tim) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pengajuan_anggota_calon FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 13. Tabel Notifikasi (Pemberitahuan Sistem untuk Semua Modul)
CREATE TABLE Notifikasi (
    id_notifikasi VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL, -- Penerima Notifikasi
    id_pengajuan_bergabung_tim VARCHAR(36) NULL,
    id_pengajuan_anggota VARCHAR(36) NULL,
    jenis_notifikasi VARCHAR(50) NOT NULL, -- 'aktivitas_profil', 'pengajuan_masuk', 'pengajuan_diterima', 'undangan_masuk', dll.
    pesan_notifikasi TEXT NOT NULL,
    waktu_notifikasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_dibaca BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (id_notifikasi),
    CONSTRAINT fk_notifikasi_pengguna FOREIGN KEY (id_pengguna) 
        REFERENCES Pengguna (id_pengguna) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_notifikasi_pengajuan_bergabung FOREIGN KEY (id_pengajuan_bergabung_tim) 
        REFERENCES Pengajuan_Bergabung_Tim (id_pengajuan_bergabung_tim) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_notifikasi_pengajuan_anggota FOREIGN KEY (id_pengajuan_anggota) 
        REFERENCES Pengajuan_Anggota (id_pengajuan_anggota) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SELESAI: Skema DDL Berhasil Dibuat
-- =============================================================================
