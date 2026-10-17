-- Migrasi untuk database LAMA (database baru dari schema_myteam.sql sudah benar).
-- Kolom posisi pada undangan wajib diisi (NOT NULL).
ALTER TABLE Pengajuan_Anggota
    ADD COLUMN IF NOT EXISTS posisi VARCHAR(100) NULL AFTER id_pengguna;

-- Undangan lama tanpa posisi dihapus (notifikasi terkait ikut terhapus karena ON DELETE CASCADE)
DELETE FROM Pengajuan_Anggota WHERE posisi IS NULL OR TRIM(posisi) = '';

ALTER TABLE Pengajuan_Anggota
    MODIFY COLUMN posisi VARCHAR(100) NOT NULL;
