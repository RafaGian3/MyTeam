# KONTRAK SPESIFIKASI API (API SPECIFICATION CONTRACT)
## APLIKASI MOBILE "MyTeam" — UNIVERSITAS ANDALAS

---

### Informasi Dokumen & Tim Pengembang
| Metadata | Keterangan |
| :--- | :--- |
| **Nama Proyek** | MyTeam – Aplikasi Mobile Pencarian dan Pembentukan Tim Mahasiswa Unand |
| **Mata Kuliah** | Pemrograman Aplikasi Mobile (PAM) |
| **Program Studi / Fakultas** | Sistem Informasi / Teknologi Informasi, Universitas Andalas |
| **Versi Dokumen** | **1.3.0 (Final Academic Contract)** |
| **Tanggal Terbit** | 11 Oktober 2026 |
| **Acuan Dokumen** | Product Requirements Document (PRD MyTeam Versi 1.3) |
| **Base URL Development** | `http://10.0.2.2:8000/api/v1` (Android Emulator) / `http://localhost:8000/api/v1` |
| **Protokol Komunikasi** | RESTful JSON & Multipart Form-Data over HTTP/HTTPS |
| **Anggota Tim (4 Mahasiswa)** | 1. **Nayla Puspita Sari** (2411521007) — *PIC Modul 4*<br>2. **Diva Ramadhani** (2411521017) — *PIC Modul 3*<br>3. **Fuadi Dhiyaulhaq** (2411522001) — *PIC Modul 1*<br>4. **Rafa Gian Atthari** (2411522014) — *PIC Modul 2* |

---

## 1. Pendahuluan & Prinsip Desain

Dokumen ini merupakan kontrak resmi antarmuka pemrograman aplikasi (*API Specification Contract*) untuk sistem aplikasi mobile **MyTeam**. Dokumen ini dirancang menggunakan pendekatan **_Contract-First Development_**, yang memungkinkan ke-4 anggota tim pengembang bekerja secara paralel dan independen pada modulnya masing-masing tanpa terjadi *blocking* dependensi antar-fitur.

### 1.1 Aturan & Prinsip Arsitektur
1. **Stateless Authentication:** Seluruh endpoint privat diwajibkan menyertakan *JSON Web Token (JWT)* pada HTTP header `Authorization: Bearer <token>`.
2. **Kesesuaian NFR-06 (Tanpa Firebase):** Penyimpanan file (foto profil dan dokumen tim seperti poster/panduan) ditangani langsung oleh file server backend lokal, bukan Firebase Storage.
3. **Kesesuaian NFR-07 (Integritas & Konsistensi Data):** Operasi penghapusan tim (`DELETE /teams/{id}`) secara otomatis menghapus atau menonaktifkan relasi kebutuhan tim, dokumen pendukung, anggota tim, serta pengajuan terkait.
4. **Respon Seragam:** Seluruh respon API menggunakan pembungkus (*envelope*) standar dengan status HTTP semantik (RFC 7231).

---

## 2. Matriks Keterlacakan Kebutuhan (FR Traceability Matrix)

Matriks berikut memetakan 26 Kebutuhan Fungsional (*Functional Requirements*) dari PRD v1.3 ke endpoint API yang bersesuaian, beserta penanggung jawab (*PIC*) modul:

| Kode FR | Deskripsi Kebutuhan Fungsional PRD v1.3 | HTTP Method | Endpoint API | PIC Modul |
| :---: | :--- | :---: | :--- | :---: |
| **FR-01** | Mengelola data diri (deskripsi singkat, kontak, prodi, fakultas, IPK) | `GET`, `PUT` | `/profile/data-diri` | Fuadi (M1) |
| **FR-02** | Mengelola media sosial (nama & tautan) | `GET`, `POST`, `PUT`, `DELETE` | `/profile/media-sosial` | Fuadi (M1) |
| **FR-03** | Mengelola minat (nama minat & deskripsi) | `GET`, `POST`, `PUT`, `DELETE` | `/profile/minat` | Fuadi (M1) |
| **FR-04** | Mengelola keahlian (nama keahlian & deskripsi) | `GET`, `POST`, `PUT`, `DELETE` | `/profile/keahlian` | Fuadi (M1) |
| **FR-05** | Mengelola pengalaman (nama kegiatan, peran, tahun, deskripsi) | `GET`, `POST`, `PUT`, `DELETE` | `/profile/pengalaman` | Fuadi (M1) |
| **FR-06** | Melihat informasi tim yang diikuti (nama tim, kegiatan, kategori, posisi) | `GET` | `/profile/detail/{id_pengguna}` | Fuadi (M1) |
| **FR-07** | Mengelola preferensi pencarian (pencari tim/anggota/keduanya) | `GET`, `PUT` | `/profile/preferensi` | Fuadi (M1) |
| **FR-08** | Sistem mengirim notifikasi aktivitas data riwayat diri | *Auto-event* | `/notifications` | Nayla (M4) |
| **FR-09** | Membuat tim baru & mengunggah dokumen pendukung (poster/panduan) | `POST` | `/teams` | Rafa (M2) |
| **FR-10** | Melihat daftar dan detail tim yang dibuat | `GET` | `/teams/my-teams`, `/teams/{id}` | Rafa (M2) |
| **FR-11** | Mengubah informasi & dokumen tim (kategori kegiatan dikunci) | `PUT` | `/teams/{id}` | Rafa (M2) |
| **FR-12** | Menghapus tim yang telah dibuat | `DELETE` | `/teams/{id}` | Rafa (M2) |
| **FR-13** | Menerima notifikasi saat ada pengajuan bergabung ke tim | *Auto-event* | `/notifications` | Nayla (M4) |
| **FR-14** | Melihat feed tim atau kegiatan terbaru | `GET` | `/teams/feed` | Diva (M3) |
| **FR-15** | Pencarian dan penyaringan tim berdasarkan kriteria | `GET` | `/teams/feed?search=&kategori=&keahlian=` | Diva (M3) |
| **FR-16** | Melihat detail tim dari hasil pencarian | `GET` | `/teams/feed/{id_tim}` | Diva (M3) |
| **FR-17** | Mengajukan bergabung ke tim dengan **posisi yang dilamar** & pesan | `POST` | `/applications/join-team` | Diva (M3) |
| **FR-18** | Pembuat tim melihat daftar pengajuan bergabung | `GET` | `/teams/{id_tim}/applications` | Diva (M3) |
| **FR-19** | Pembuat tim melihat detail pengajuan (posisi dilamar & profil pelamar) | `GET` | `/applications/join-team/{id}` | Diva (M3) |
| **FR-20** | Pembuat tim menerima atau menolak pengajuan bergabung | `PATCH` | `/applications/join-team/{id}/status` | Diva (M3) |
| **FR-21** | Melihat status pengajuan & notifikasi pembaruan status | `GET`, *Event* | `/applications/my-applications` | Diva (M3) |
| **FR-22** | Mencari calon anggota berdasarkan nama, keahlian, pengalaman, minat | `GET` | `/members/search` | Nayla (M4) |
| **FR-23** | Melihat detail profil calon anggota dari hasil pencarian | `GET` | `/profile/detail/{id_pengguna}` | Nayla (M4) |
| **FR-24** | Pembuat tim mengajukan permintaan (undangan) ke calon anggota | `POST` | `/applications/invite-member` | Nayla (M4) |
| **FR-25** | Calon anggota melihat detail tim & menerima/menolak undangan | `GET`, `PATCH` | `/applications/received-invitations`, status | Nayla (M4) |
| **FR-26** | Notifikasi respon undangan tim (calon anggota terima/tolak) | *Auto-event* | `/notifications` | Nayla (M4) |

---

## 3. Konvensi Protokol & Standar Respon

### 3.1 HTTP Headers
```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer <jwt_access_token>
```
*(Gunakan `Content-Type: multipart/form-data` untuk upload foto profil atau dokumen pendukung tim).*

### 3.2 Kamus Nilai Terbatas (Enumerasi / Domain Values)
* **Kategori Kegiatan Tim:** `'Lomba'`, `'Penelitian'`, `'Proyek'`, `'Lainnya'`
* **Status Tim:** `'terbuka'`, `'ditutup'`
* **Preferensi Pencarian:** `'pencari_tim'`, `'pencari_anggota'`, `'keduanya'`
* **Jenis Dokumen Pendukung:** `'poster'`, `'panduan'`
* **Status Pengajuan / Undangan:** `'menunggu'`, `'diterima'`, `'ditolak'`
* **Jenis Notifikasi:** `'riwayat_diri_diperbarui'`, `'pengajuan_masuk'`, `'pengajuan_diterima'`, `'pengajuan_ditolak'`, `'undangan_masuk'`, `'undangan_diterima'`, `'undangan_ditolak'`

### 3.3 Struktur Respon Standar

#### Respon Sukses Tunggal (200 OK / 201 Created)
```json
{
  "success": true,
  "message": "Deskripsi aksi berhasil dieksekusi",
  "data": {}
}
```

#### Respon Sukses Daftar Terpaginasi (200 OK)
```json
{
  "success": true,
  "message": "Daftar data berhasil diambil",
  "data": [],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_records": 34,
    "total_pages": 4
  }
}
```

#### Respon Validasi Gagal (422 Unprocessable Entity)
```json
{
  "success": false,
  "message": "Validasi input gagal",
  "errors": {
    "posisi": [
      "Field posisi yang dilamar wajib diisi."
    ],
    "ipk": [
      "Nilai IPK harus berada pada rentang 0.00 hingga 4.00."
    ]
  }
}
```

#### Respon Autentikasi / Otorisasi Gagal (401 Unauthorized / 403 Forbidden)
```json
{
  "success": false,
  "message": "Sesi tidak valid atau hak akses tidak diizinkan."
}
```

---

## 4. Rincian Endpoint Spesifikasi per Modul

---

### MODUL 1: AUTENTIKASI, AKUN & DATA RIWAYAT DIRI (PIC: Fuadi Dhiyaulhaq)

#### 4.1.1 Registrasi Akun Mahasiswa
* **Endpoint:** `POST /auth/register`
* **Akses:** Publik
* **Request Body:**
```json
{
  "nim": "2411522001",
  "nama_pengguna": "Fuadi Dhiyaulhaq",
  "kata_sandi": "SandiAman123!",
  "kata_sandi_konfirmasi": "SandiAman123!"
}
```
* **Respon Sukses (201 Created):**
```json
{
  "success": true,
  "message": "Registrasi akun berhasil",
  "data": {
    "id_pengguna": "usr_2411522001",
    "nim": "2411522001",
    "nama_pengguna": "Fuadi Dhiyaulhaq",
    "foto_profil": null,
    "token": "eyJhbGciOiJIUzI1Ni..."
  }
}
```

#### 4.1.2 Login Akun Mahasiswa
* **Endpoint:** `POST /auth/login`
* **Akses:** Publik
* **Request Body:**
```json
{
  "nim": "2411522001",
  "kata_sandi": "SandiAman123!"
}
```
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGciOiJIUzI1Ni...",
    "pengguna": {
      "id_pengguna": "usr_2411522001",
      "nim": "2411522001",
      "nama_pengguna": "Fuadi Dhiyaulhaq",
      "foto_profil": "http://10.0.2.2:8000/storage/profiles/usr_2411522001.jpg"
    }
  }
}
```

#### 4.1.3 Unggah Foto Profil Pengguna
* **Endpoint:** `POST /auth/foto-profil`
* **Akses:** Terautentikasi (`Bearer Token`)
* **Content-Type:** `multipart/form-data`
* **Form-Data:** `foto_profil` (File image: jpg, jpeg, png; max 2MB)
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Foto profil berhasil diperbarui",
  "data": {
    "foto_profil": "http://10.0.2.2:8000/storage/profiles/usr_2411522001.jpg"
  }
}
```

#### 4.1.4 Kelola Data Diri (FR-01)
* **Ambil Data Diri:** `GET /profile/data-diri`
* **Simpan / Perbarui Data Diri:** `PUT /profile/data-diri`
* **Request Body (PUT):**
```json
{
  "deskripsi_singkat": "Mahasiswa Sistem Informasi peminatan rekayasa perangkat lunak mobile.",
  "kontak": "081267891011",
  "program_studi": "Sistem Informasi",
  "fakultas": "Teknologi Informasi",
  "ipk": 3.88
}
```
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Data diri berhasil disimpan",
  "data": {
    "id_pengguna": "usr_2411522001",
    "deskripsi_singkat": "Mahasiswa Sistem Informasi peminatan rekayasa perangkat lunak mobile.",
    "kontak": "081267891011",
    "program_studi": "Sistem Informasi",
    "fakultas": "Teknologi Informasi",
    "ipk": 3.88
  }
}
```

#### 4.1.5 Kelola Media Sosial (FR-02)
* **List Media Sosial:** `GET /profile/media-sosial`
* **Tambah Media Sosial:** `POST /profile/media-sosial`
  * Body: `{"nama_media_sosial": "LinkedIn", "link_media_sosial": "https://linkedin.com/in/fuadidhy"}`
* **Ubah Media Sosial:** `PUT /profile/media-sosial/{id_media_sosial}`
* **Hapus Media Sosial:** `DELETE /profile/media-sosial/{id_media_sosial}`

#### 4.1.6 Kelola Minat & Keahlian (FR-03, FR-04)
* **Kelola Minat:** `GET`, `POST`, `PUT`, `DELETE` pada `/profile/minat` (dan `/profile/minat/{id_minat}`)
  * Body POST: `{"minat": "Mobile App Development", "deskripsi_minat": "Fokus pada Flutter dan Android Native"}`
* **Kelola Keahlian:** `GET`, `POST`, `PUT`, `DELETE` pada `/profile/keahlian` (dan `/profile/keahlian/{id_keahlian}`)
  * Body POST: `{"keahlian": "Flutter & Dart", "deskripsi_keahlian": "State management Provider, REST API integration"}`

#### 4.1.7 Kelola Riwayat Pengalaman (FR-05 — PRD v1.3 Refinement)
> **Catatan Penting PRD v1.3:** Fitur media/bukti pendukung dihapus, digantikan dengan penambahan atribut `deskripsi_pengalaman`.

* **Ambil Daftar Pengalaman:** `GET /profile/pengalaman`
* **Tambah Pengalaman:** `POST /profile/pengalaman`
  * **Request Body:**
```json
{
  "nama_kegiatan": "GEMASTIK XVII Divisi Software Development",
  "peran": "Mobile Frontend Developer",
  "tahun": 2024,
  "deskripsi_pengalaman": "Merancang dan membangun antarmuka interaktif aplikasi mobile serta melakukan pengujian fungsional modul pengguna."
}
```
* **Ubah Pengalaman:** `PUT /profile/pengalaman/{id_pengalaman}`
* **Hapus Pengalaman:** `DELETE /profile/pengalaman/{id_pengalaman}`

#### 4.1.8 Kelola Preferensi Pencarian (FR-07)
* **Ambil Preferensi:** `GET /profile/preferensi`
* **Simpan Preferensi:** `PUT /profile/preferensi`
  * **Request Body:**
```json
{
  "preferensi_pencarian": "keduanya"
}
```

#### 4.1.9 Detail Profil Lengkap & Tim yang Diikuti (FR-06)
* **Endpoint:** `GET /profile/detail/{id_pengguna}`
* **Akses:** Terautentikasi
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Detail profil pengguna berhasil diambil",
  "data": {
    "pengguna": {
      "id_pengguna": "usr_2411522001",
      "nim": "2411522001",
      "nama_pengguna": "Fuadi Dhiyaulhaq",
      "foto_profil": "http://10.0.2.2:8000/storage/profiles/usr_2411522001.jpg"
    },
    "data_diri": {
      "deskripsi_singkat": "Mahasiswa Sistem Informasi.",
      "kontak": "081267891011",
      "program_studi": "Sistem Informasi",
      "fakultas": "Teknologi Informasi",
      "ipk": 3.88
    },
    "preferensi_pencarian": "keduanya",
    "media_sosial": [
      {
        "id_media_sosial": "soc_01",
        "nama_media_sosial": "GitHub",
        "link_media_sosial": "https://github.com/fuadidhy"
      }
    ],
    "minat": [
      {
        "id_minat": "mnt_01",
        "minat": "Mobile App",
        "deskripsi_minat": "Pengembangan aplikasi lintas platform"
      }
    ],
    "keahlian": [
      {
        "id_keahlian": "khl_01",
        "keahlian": "Flutter",
        "deskripsi_keahlian": "Arsitektur MVC/Clean Code"
      }
    ],
    "pengalaman": [
      {
        "id_pengalaman": "exp_01",
        "nama_kegiatan": "GEMASTIK XVII",
        "peran": "Mobile Frontend Developer",
        "tahun": 2024,
        "deskripsi_pengalaman": "Merancang dan membangun antarmuka aplikasi."
      }
    ],
    "tim_yang_diikuti": [
      {
        "id_anggota_tim": "ang_01",
        "id_tim": "tim_101",
        "nama_tim": "Inovator Unand",
        "nama_kegiatan": "PIMNAS 37",
        "kategori_kegiatan": "Lomba",
        "posisi": "Mobile Developer"
      }
    ]
  }
}
```

---

### MODUL 2: PEMBENTUKAN & MANAJEMEN TIM (PIC: Rafa Gian Atthari)

#### 4.2.1 Pembuatan Tim Baru (FR-09)
* **Endpoint:** `POST /teams`
* **Akses:** Terautentikasi
* **Content-Type:** `multipart/form-data`
* **Form-Data Fields:**
  * `nama_tim` (string, required): "Tim Robotik Cerdas"
  * `nama_kegiatan` (string, required): "Kontes Robot Indonesia 2026"
  * `kategori_kegiatan` (string, required, enum: `'Lomba' | 'Penelitian' | 'Proyek' | 'Lainnya'`): "Lomba"
  * `deskripsi` (string, required): "Pengembangan robot penjelajah otonom berbasis computer vision."
  * `kebutuhan` (JSON string, required):
    ```json
    [
      {
        "posisi_dibutuhkan": "Computer Vision Specialist",
        "keahlian_dibutuhkan": "Python, OpenCV",
        "jumlah_anggota_dibutuhkan": 1
      },
      {
        "posisi_dibutuhkan": "Hardware Engineer",
        "keahlian_dibutuhkan": "STM32, PCB Design",
        "jumlah_anggota_dibutuhkan": 2
      }
    ]
    ```
  * `dokumen_pendukung` (array file, optional): Berkas gambar poster (jpg/png) atau pedoman teknis (pdf).
  * `jenis_dokumen` (array string, optional): `["poster", "panduan"]`
* **Respon Sukses (201 Created):**
```json
{
  "success": true,
  "message": "Tim berhasil dibentuk",
  "data": {
    "id_tim": "tim_77189a",
    "nama_tim": "Tim Robotik Cerdas",
    "nama_kegiatan": "Kontes Robot Indonesia 2026",
    "kategori_kegiatan": "Lomba",
    "deskripsi": "Pengembangan robot penjelajah otonom...",
    "status_tim": "terbuka",
    "dokumen_pendukung": [
      {
        "id_dokumen": "dok_01",
        "jenis_dokumen": "poster",
        "nama_file": "poster_kri_2026.png",
        "path_file": "http://10.0.2.2:8000/storage/documents/poster_kri_2026.png",
        "urutan": 1
      }
    ],
    "kebutuhan_tim": [
      {
        "id_kebutuhan": "keb_01",
        "posisi_dibutuhkan": "Computer Vision Specialist",
        "keahlian_dibutuhkan": "Python, OpenCV",
        "jumlah_anggota_dibutuhkan": 1
      }
    ]
  }
}
```

#### 4.2.2 Daftar Tim yang Dibuat Pengguna (FR-10)
* **Endpoint:** `GET /teams/my-teams`
* **Akses:** Terautentikasi
* **Respon Sukses (200 OK):** Mengembalikan daftar seluruh tim yang diinisiasi oleh pengguna yang sedang login.

#### 4.2.3 Detail Tim Pembuat (FR-10)
* **Endpoint:** `GET /teams/{id_tim}`
* **Akses:** Terautentikasi (khusus pemilik tim)
* **Respon Sukses (200 OK):** Mengembalikan informasi tim, dokumen pendukung, kebutuhan tim, dan daftar anggota aktif saat ini.

#### 4.2.4 Pembaruan Informasi Tim (FR-11)
* **Endpoint:** `PUT /teams/{id_tim}` (atau `POST /teams/{id_tim}/update` untuk form-data)
* **Akses:** Terautentikasi (khusus pemilik tim)
* **Aturan Bisnis FR-11:** Nilai `kategori_kegiatan` **dikunci / tidak boleh diubah**. Upaya mengubah field ini akan ditolak backend dengan status HTTP 422.
* **Request Body:**
```json
{
  "nama_tim": "Tim Robotik Cerdas Unand",
  "nama_kegiatan": "Kontes Robot Indonesia 2026",
  "deskripsi": "Deskripsi terbaharui mengenai kebutuhan mekanik dan elektronika robot.",
  "status_tim": "terbuka"
}
```

#### 4.2.5 Penghapusan Tim (FR-12)
* **Endpoint:** `DELETE /teams/{id_tim}`
* **Akses:** Terautentikasi (khusus pemilik tim)
* **Aturan Bisnis NFR-07:** Sistem menjamin penghapusan secara konsisten (*cascade* aman) terhadap relasi kebutuhan, dokumen fisik, dan membatalkan pengajuan terkait.
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Tim berhasil dihapus dari sistem beserta seluruh berkas terkait."
}
```

---

### MODUL 3: PENCARIAN TIM & PENGAJUAN BERGABUNG (PIC: Diva Ramadhani)

#### 4.3.1 Feed Tim & Filter Pencarian (FR-14, FR-15)
* **Endpoint:** `GET /teams/feed`
* **Akses:** Terautentikasi
* **Query Parameters:**
  * `search` (string, optional): Kata kunci nama kegiatan atau nama tim.
  * `kategori` (string, optional): Filter kategori (`Lomba`, `Penelitian`, `Proyek`).
  * `keahlian` (string, optional): Filter keahlian yang dibutuhkan (misal: `Flutter`, `Python`).
  * `page` (integer, optional): Halaman (default: 1).
  * `limit` (integer, optional): Jumlah item per halaman (default: 10).
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Feed tim berhasil diambil",
  "data": [
    {
      "id_tim": "tim_77189a",
      "nama_tim": "Tim Robotik Cerdas Unand",
      "nama_kegiatan": "Kontes Robot Indonesia 2026",
      "kategori_kegiatan": "Lomba",
      "deskripsi": "Pengembangan robot penjelajah otonom...",
      "status_tim": "terbuka",
      "pembuat_tim": {
        "id_pengguna": "usr_2411522014",
        "nama_pengguna": "Rafa Gian Atthari",
        "foto_profil": "http://10.0.2.2:8000/storage/profiles/rafa.jpg"
      },
      "kebutuhan_tim": [
        {
          "id_kebutuhan": "keb_01",
          "posisi_dibutuhkan": "Computer Vision Specialist",
          "keahlian_dibutuhkan": "Python, OpenCV",
          "jumlah_anggota_dibutuhkan": 1
        }
      ],
      "dokumen_pendukung": [
        {
          "id_dokumen": "dok_01",
          "jenis_dokumen": "poster",
          "path_file": "http://10.0.2.2:8000/storage/documents/poster_kri_2026.png"
        }
      ],
      "total_anggota_saat_ini": 1
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_records": 18,
    "total_pages": 2
  }
}
```

#### 4.3.2 Detail Tim untuk Calon Pelamar (FR-16)
* **Endpoint:** `GET /teams/feed/{id_tim}`
* **Akses:** Terautentikasi
* **Respon Sukses (200 OK):** Mengembalikan profil lengkap tim, detail posisi terbuka, dan profil singkat pembuat tim.

#### 4.3.3 Pengajuan Bergabung ke Tim (FR-17 — PRD v1.3 Refinement)
> **Catatan Penting PRD v1.3:** Pelamar **wajib menyertakan atribut `posisi`** (posisi yang dilamar) sesuai opsi yang dibuka oleh pembuat tim.

* **Endpoint:** `POST /applications/join-team`
* **Akses:** Terautentikasi (Pencari Tim)
* **Request Body:**
```json
{
  "id_tim": "tim_77189a",
  "posisi": "Computer Vision Specialist",
  "pesan_pengajuan": "Saya memiliki pengalaman implementasi modul YOLOv8 dan berminat mengisi posisi Computer Vision Specialist pada tim ini."
}
```
* **Respon Sukses (201 Created):**
```json
{
  "success": true,
  "message": "Pengajuan bergabung berhasil dikirim ke pembuat tim",
  "data": {
    "id_pengajuan_bergabung_tim": "pbg_9901b",
    "id_tim": "tim_77189a",
    "id_pengguna": "usr_2411522001",
    "posisi": "Computer Vision Specialist",
    "pesan_pengajuan": "Saya memiliki pengalaman implementasi modul YOLOv8...",
    "waktu_pengajuan": "2026-10-11T15:00:00Z",
    "status_pengajuan": "menunggu"
  }
}
```

#### 4.3.4 Daftar Pengajuan Masuk Tim (FR-18 — Pembuat Tim)
* **Endpoint:** `GET /teams/{id_tim}/applications`
* **Akses:** Terautentikasi (khusus pemilik tim)
* **Respon Sukses (200 OK):** Menampilkan daftar pelamar, posisi yang mereka lamar, waktu pengajuan, dan status.

#### 4.3.5 Detail Pengajuan Bergabung (FR-19)
* **Endpoint:** `GET /applications/join-team/{id_pengajuan_bergabung_tim}`
* **Akses:** Terautentikasi (pemilik tim)
* **Respon Sukses (200 OK):** Menampilkan detail lengkap surat pengajuan, posisi yang dilamar, serta profil akademik pelamar.

#### 4.3.6 Keputusan Pengajuan: Terima / Tolak (FR-20)
* **Endpoint:** `PATCH /applications/join-team/{id_pengajuan_bergabung_tim}/status`
* **Akses:** Terautentikasi (pemilik tim)
* **Request Body:**
```json
{
  "status_pengajuan": "diterima"
}
```
*(Nilai valid: `"diterima"` atau `"ditolak"`)*
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Pengajuan berhasil diterima. Pelamar telah ditambahkan ke dalam anggota tim.",
  "data": {
    "id_pengajuan_bergabung_tim": "pbg_9901b",
    "status_pengajuan": "diterima",
    "posisi_terdaftar": "Computer Vision Specialist"
  }
}
```

#### 4.3.7 Riwayat Pengajuan Saya (FR-21 — Pelamar)
* **Endpoint:** `GET /applications/my-applications`
* **Akses:** Terautentikasi
* **Respon Sukses (200 OK):** Menampilkan seluruh status pengajuan yang pernah dikirimkan oleh pengguna (`menunggu`, `diterima`, `ditolak`).

---

### MODUL 4: PENCARIAN ANGGOTA, REKRUTMEN & NOTIFIKASI (PIC: Nayla Puspita Sari)

#### 4.4.1 Pencarian Calon Anggota (FR-22)
* **Endpoint:** `GET /members/search`
* **Akses:** Terautentikasi
* **Query Parameters:**
  * `q` (string, optional): Nama mahasiswa atau program studi.
  * `keahlian` (string, optional): Filter keahlian spesifik (misal: `UI Design`).
  * `minat` (string, optional): Filter minat spesifik.
  * `page`, `limit` (pagination).
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Pencarian calon anggota berhasil",
  "data": [
    {
      "id_pengguna": "usr_2411521007",
      "nama_pengguna": "Nayla Puspita Sari",
      "program_studi": "Sistem Informasi",
      "fakultas": "Teknologi Informasi",
      "foto_profil": "http://10.0.2.2:8000/storage/profiles/nayla.jpg",
      "keahlian": [
        "UI Design",
        "Figma Prototyping"
      ],
      "minat": [
        "UI/UX Design",
        "Product Management"
      ],
      "total_pengalaman": 3
    }
  ]
}
```

#### 4.4.2 Undangan Rekrutmen ke Calon Anggota (FR-24)
* **Endpoint:** `POST /applications/invite-member`
* **Akses:** Terautentikasi (Pembuat Tim)
* **Request Body:**
```json
{
  "id_tim": "tim_77189a",
  "id_pengguna": "usr_2411521007",
  "pesan_pengajuan": "Halo Nayla, kami melihat keahlian UI/UX Anda sangat cocok untuk kebutuhan tim Kontes Robotik kami."
}
```
* **Respon Sukses (201 Created):**
```json
{
  "success": true,
  "message": "Undangan bergabung berhasil dikirimkan ke calon anggota",
  "data": {
    "id_pengajuan_anggota": "und_3310a",
    "id_tim": "tim_77189a",
    "id_pengguna": "usr_2411521007",
    "pesan_pengajuan": "Halo Nayla...",
    "waktu_pengajuan": "2026-10-11T15:05:00Z",
    "status_pengajuan": "menunggu"
  }
}
```

#### 4.4.3 Respon Calon Anggota terhadap Undangan (FR-25)
* **Daftar Undangan Masuk ke Saya:** `GET /applications/received-invitations`
* **Keputusan Calon Anggota:** `PATCH /applications/invite-member/{id_pengajuan_anggota}/status`
* **Request Body:**
```json
{
  "status_pengajuan": "diterima"
}
```
*(Nilai valid: `"diterima"` atau `"ditolak"`)*

#### 4.4.4 Modul Notifikasi Sistem (FR-08, FR-13, FR-21, FR-26)
* **Ambil Daftar Notifikasi:** `GET /notifications?page=1&limit=15`
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Daftar notifikasi berhasil diambil",
  "data": [
    {
      "id_notifikasi": "notif_501",
      "id_pengguna": "usr_2411522001",
      "jenis_notifikasi": "pengajuan_diterima",
      "pesan_notifikasi": "Selamat! Pengajuan bergabung Anda untuk posisi Computer Vision Specialist pada 'Tim Robotik Cerdas Unand' telah diterima.",
      "id_pengajuan_bergabung_tim": "pbg_9901b",
      "id_pengajuan_anggota": null,
      "status_dibaca": false,
      "waktu_notifikasi": "2026-10-11T15:10:00Z"
    }
  ]
}
```
* **Tandai Telah Dibaca:** `PATCH /notifications/{id_notifikasi}/read`
* **Hitung Notifikasi Belum Dibaca:** `GET /notifications/unread-count`

---

## 5. Kamus Basis Data Fisik (Physical Data Dictionary)

Berdasarkan Bagian 2.5 PRD v1.3, berikut adalah skema database relasional yang disepakati:

```sql
-- 1. Pengguna
CREATE TABLE Pengguna (
    id_pengguna VARCHAR(36) PRIMARY KEY,
    nim VARCHAR(10) UNIQUE NOT NULL,
    kata_sandi VARCHAR(255) NOT NULL,
    nama_pengguna VARCHAR(100) NOT NULL,
    foto_profil VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Data_Diri
CREATE TABLE Data_Diri (
    id_pengguna VARCHAR(36) PRIMARY KEY,
    deskripsi_singkat TEXT NULL,
    kontak VARCHAR(20) NOT NULL,
    program_studi VARCHAR(50) NOT NULL,
    fakultas VARCHAR(50) NOT NULL,
    ipk DECIMAL(3,2) NOT NULL,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE
);

-- 3. Media_Sosial
CREATE TABLE Media_Sosial (
    id_media_sosial VARCHAR(36) PRIMARY KEY,
    id_pengguna VARCHAR(36) NOT NULL,
    nama_media_sosial VARCHAR(50) NOT NULL,
    link_media_sosial VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE
);

-- 4. Data_Minat & 5. Data_Keahlian
CREATE TABLE Data_Minat (
    id_minat VARCHAR(36) PRIMARY KEY,
    id_pengguna VARCHAR(36) NOT NULL,
    minat VARCHAR(100) NOT NULL,
    deskripsi_minat TEXT NULL,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE
);

CREATE TABLE Data_Keahlian (
    id_keahlian VARCHAR(36) PRIMARY KEY,
    id_pengguna VARCHAR(36) NOT NULL,
    keahlian VARCHAR(100) NOT NULL,
    deskripsi_keahlian TEXT NULL,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE
);

-- 6. Data_Pengalaman (PRD v1.3: Deskripsi ditambahkan, Media ditiadakan)
CREATE TABLE Data_Pengalaman (
    id_pengalaman VARCHAR(36) PRIMARY KEY,
    id_pengguna VARCHAR(36) NOT NULL,
    nama_kegiatan VARCHAR(150) NOT NULL,
    peran VARCHAR(100) NOT NULL,
    tahun INT NOT NULL,
    deskripsi_pengalaman TEXT NOT NULL,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE
);

-- 7. Data_Tim
CREATE TABLE Data_Tim (
    id_tim VARCHAR(36) PRIMARY KEY,
    id_pengguna VARCHAR(36) NOT NULL, -- Pembuat Tim
    nama_tim VARCHAR(100) NOT NULL,
    nama_kegiatan VARCHAR(150) NOT NULL,
    kategori_kegiatan VARCHAR(50) NOT NULL,
    deskripsi TEXT NOT NULL,
    status_tim ENUM('terbuka', 'ditutup') DEFAULT 'terbuka',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE RESTRICT
);

-- 8. Kebutuhan_Tim
CREATE TABLE Kebutuhan_Tim (
    id_kebutuhan VARCHAR(36) PRIMARY KEY,
    id_tim VARCHAR(36) NOT NULL,
    posisi_dibutuhkan VARCHAR(100) NOT NULL,
    keahlian_dibutuhkan VARCHAR(255) NOT NULL,
    jumlah_anggota_dibutuhkan INT NOT NULL DEFAULT 1,
    FOREIGN KEY (id_tim) REFERENCES Data_Tim(id_tim) ON DELETE CASCADE
);

-- 9. Dokumen_Pendukung
CREATE TABLE Dokumen_Pendukung (
    id_dokumen VARCHAR(36) PRIMARY KEY,
    id_tim VARCHAR(36) NOT NULL,
    jenis_dokumen ENUM('poster', 'panduan') NOT NULL,
    nama_file VARCHAR(255) NOT NULL,
    path_file VARCHAR(255) NOT NULL,
    urutan INT DEFAULT 1,
    FOREIGN KEY (id_tim) REFERENCES Data_Tim(id_tim) ON DELETE CASCADE
);

-- 10. Anggota_Tim
CREATE TABLE Anggota_Tim (
    id_anggota_tim VARCHAR(36) PRIMARY KEY,
    id_tim VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL,
    posisi VARCHAR(100) NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_tim) REFERENCES Data_Tim(id_tim) ON DELETE CASCADE,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE
);

-- 11. Pengajuan_Bergabung_Tim (PRD v1.3: Atribut posisi ditambahkan)
CREATE TABLE Pengajuan_Bergabung_Tim (
    id_pengajuan_bergabung_tim VARCHAR(36) PRIMARY KEY,
    id_tim VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL, -- Pelamar
    posisi VARCHAR(100) NOT NULL,     -- Posisi yang dilamar
    pesan_pengajuan TEXT NOT NULL,
    waktu_pengajuan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_pengajuan ENUM('menunggu', 'diterima', 'ditolak') DEFAULT 'menunggu',
    FOREIGN KEY (id_tim) REFERENCES Data_Tim(id_tim) ON DELETE CASCADE,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE
);

-- 12. Pengajuan_Anggota (Undangan Rekrutmen dari Pembuat Tim)
CREATE TABLE Pengajuan_Anggota (
    id_pengajuan_anggota VARCHAR(36) PRIMARY KEY,
    id_tim VARCHAR(36) NOT NULL,
    id_pengguna VARCHAR(36) NOT NULL, -- Calon Anggota yang diundang
    pesan_pengajuan TEXT NOT NULL,
    waktu_pengajuan TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_pengajuan ENUM('menunggu', 'diterima', 'ditolak') DEFAULT 'menunggu',
    FOREIGN KEY (id_tim) REFERENCES Data_Tim(id_tim) ON DELETE CASCADE,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE
);

-- 13. Notifikasi
CREATE TABLE Notifikasi (
    id_notifikasi VARCHAR(36) PRIMARY KEY,
    id_pengguna VARCHAR(36) NOT NULL,
    id_pengajuan_bergabung_tim VARCHAR(36) NULL,
    id_pengajuan_anggota VARCHAR(36) NULL,
    jenis_notifikasi VARCHAR(50) NOT NULL,
    pesan_notifikasi TEXT NOT NULL,
    waktu_notifikasi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_dibaca BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE,
    FOREIGN KEY (id_pengajuan_bergabung_tim) REFERENCES Pengajuan_Bergabung_Tim(id_pengajuan_bergabung_tim) ON DELETE CASCADE,
    FOREIGN KEY (id_pengajuan_anggota) REFERENCES Pengajuan_Anggota(id_pengajuan_anggota) ON DELETE CASCADE
);
```

---

## 6. Pedoman Implementasi Flutter (Dummy / Mock Repository)

Untuk memastikan pekerjaan tiap modul berjalan paralel tanpa terhalang server backend, implementasi repository Flutter wajib menggunakan kontrak model berikut:

```dart
// Contoh Implementasi Abstraksi Repository Flutter (Contract First)
abstract class TeamApplicationRepository {
  /// Mengirim pengajuan bergabung ke tim dengan posisi yang dilamar (FR-17)
  Future<ApplicationResult> applyToTeam({
    required String teamId,
    required String position,
    required String message,
  });

  /// Mengambil daftar riwayat pengajuan milik pengguna (FR-21)
  Future<List<ApplicationHistory>> getMyApplications();
}
```

Dengan adanya pemisahan interface ini:
1. Setiap mahasiswa dapat mengimplementasikan `MockTeamApplicationRepository` menggunakan data statis/lokal untuk kebutuhan demo UI dan pengujian widget.
2. Ketika backend server lokal siap, cukup ganti ke `HttpTeamApplicationRepository` tanpa perlu merombak layar UI (*Screen*) maupun *State Management*.

---

*Dokumen ini sah dan disetujui sebagai acuan baku pengembangan aplikasi MyTeam pada Mata Kuliah Pemrograman Aplikasi Mobile (PAM), Universitas Andalas.*
