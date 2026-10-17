# KONTRAK SPESIFIKASI API (API SPECIFICATION CONTRACT)
## APLIKASI MOBILE "MyTeam" — UNIVERSITAS ANDALAS

---

### Informasi Dokumen & Tim Pengembang
| Metadata | Keterangan |
| :--- | :--- |
| **Nama Proyek** | MyTeam – Aplikasi Mobile Pencarian dan Pembentukan Tim Mahasiswa Unand |
| **Mata Kuliah** | Pemrograman Aplikasi Mobile (PAM) |
| **Program Studi / Fakultas** | Sistem Informasi / Teknologi Informasi, Universitas Andalas |
| **Versi Dokumen** | **1.0.0 (Final Academic Contract)** |
| **Tanggal Terbit** | 11 Oktober 2026 |
| **Acuan Dokumen** | Product Requirements Document (PRD MyTeam Versi 1.0) |
| **Base URL Development** | `http://10.0.2.2:8000/api/v1` (Android Emulator) / `http://localhost:8000/api/v1` |
| **Protokol Komunikasi** | RESTful JSON & Multipart Form-Data over HTTP/HTTPS |
| **Anggota Tim (4 Mahasiswa)** | 1. **Fuadi Dhiyaulhaq** (2411522001) — *PIC Modul 1*<br>2. **Nayla Puspita Sari** (2411521007) — *PIC Modul 2*<br>3. **Rafa Gian Atthari** (2411522014) — *PIC Modul 3*<br>4. **Diva Ramadhani** (2411521017) — *PIC Modul 4* |

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

Matriks berikut memetakan 25 Kebutuhan Fungsional (*Functional Requirements*) dari PRD v1.0 ke endpoint API yang bersesuaian, beserta penanggung jawab (*PIC*) modul:

| Kode FR | Deskripsi Kebutuhan Fungsional PRD v1.0 | HTTP Method | Endpoint API | PIC Modul |
| :---: | :--- | :---: | :--- | :---: |
| **FR-01** | Mengelola data diri (deskripsi singkat, kontak, prodi, fakultas, IPK) | `GET`, `PUT` | `/profile/data-diri` | Fuadi (M1) |
| **FR-02** | Mengelola media sosial (nama & tautan) | `GET`, `POST`, `PUT`, `DELETE` | `/profile/media-sosial` | Fuadi (M1) |
| **FR-03** | Mengelola minat (nama minat & deskripsi) | `GET`, `POST`, `PUT`, `DELETE` | `/profile/minat` | Fuadi (M1) |
| **FR-04** | Mengelola keahlian (nama keahlian & deskripsi) | `GET`, `POST`, `PUT`, `DELETE` | `/profile/keahlian` | Fuadi (M1) |
| **FR-05** | Mengelola pengalaman (nama kegiatan, peran, tahun, deskripsi) | `GET`, `POST`, `PUT`, `DELETE` | `/profile/pengalaman` | Fuadi (M1) |
| **FR-06** | Melihat informasi tim yang diikuti (nama tim, kegiatan, kategori, posisi) | `GET` | `/profile/detail/{id_pengguna}` | Fuadi (M1) |
| **FR-07** | Sistem mengirim notifikasi aktivitas data riwayat diri | *Auto-event* | `/notifications` | Fuadi (M1) |
| **FR-08** | Membuat tim baru & mengunggah dokumen pendukung (poster/panduan) | `POST` | `/teams` | Nayla (M2) |
| **FR-09** | Melihat daftar tim yang dibuat atau diikuti sebagai anggota dan detailnya | `GET` | `/teams/my-teams`, `/teams/{id}` | Nayla (M2) |
| **FR-10** | Mengubah informasi & dokumen tim (kategori kegiatan dikunci) | `PUT` | `/teams/{id}` | Nayla (M2) |
| **FR-11** | Menghapus tim yang telah dibuat | `DELETE` | `/teams/{id}` | Nayla (M2) |
| **FR-12** | Menerima notifikasi saat ada pengajuan bergabung ke tim | *Auto-event* | `/notifications` | Nayla (M2) |
| **FR-13** | Melihat feed tim atau kegiatan terbaru | `GET` | `/teams/feed` | Rafa (M3) |
| **FR-14** | Pencarian dan penyaringan tim berdasarkan kriteria | `GET` | `/teams/feed?search=&kategori=&keahlian=` | Rafa (M3) |
| **FR-15** | Melihat detail tim dari hasil pencarian | `GET` | `/teams/feed/{id_tim}` | Rafa (M3) |
| **FR-16** | Mengajukan bergabung ke tim dengan **posisi yang dilamar** & pesan | `POST` | `/applications/join-team` | Rafa (M3) |
| **FR-17** | Pembuat tim melihat daftar pengajuan bergabung | `GET` | `/teams/{id_tim}/applications` | Rafa (M3) |
| **FR-18** | Pembuat tim melihat detail pengajuan (posisi dilamar & profil pelamar) | `GET` | `/applications/join-team/{id}` | Rafa (M3) |
| **FR-19** | Pembuat tim menerima atau menolak pengajuan bergabung | `PATCH` | `/applications/join-team/{id}/status` | Rafa (M3) |
| **FR-20** | Melihat status pengajuan & notifikasi pembaruan status | `GET`, *Event* | `/applications/my-applications` | Rafa (M3) |
| **FR-21** | Mencari calon anggota dengan kata kunci nama/NIM/program studi, memfilter berdasarkan keahlian dan minat (termasuk reset filter)| `GET` | `/members/search` | Diva (M4) |
| **FR-22** | Melihat detail profil calon anggota yang dipilih dari hasil pencarian | `GET` | `/profile/detail/{id_pengguna}` | Diva (M4) |
| **FR-23** | Pembuat tim mengisi form pengajuan bergabung (tombol *Ajak Bergabung ke Tim*): pilih tim, posisi yang ditawarkan, dan pesan undangan, lalu mengirim atau membatalkan | `GET`, `POST` | `/teams/my-teams` (pilihan tim & posisi), `/applications/invite-member` | Diva (M4) |
| **FR-24** | Calon anggota mengelola undangan masuk: melihat detail tim pengundang dan menerima/menolak undangan | `GET`, `PATCH` | `/applications/received-invitations`, `/applications/received-invitations/{id}/status` | Diva (M4) |
| **FR-24b** | Pembuat tim mengelola undangan terkirim dan memantau statusnya (menunggu/diterima/ditolak) | `GET` | `/applications/sent-invitations` | Diva (M4) |
| **FR-25** | Notifikasi otomatis: calon anggota menerima notifikasi saat diundang, pembuat tim menerima notifikasi saat undangan diterima/ditolak | *Auto-event* | Dibuat pada alur FR-23 dan FR-24 (tabel `Notifikasi`); dibaca lewat `GET /notifications`, `GET /notifications/unread-count`, `PATCH /notifications/read-all` | Diva (M4) |

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
* **Jenis Dokumen Pendukung:** `'poster'`, `'panduan'`
* **Status Pengajuan / Undangan:** `'menunggu'`, `'diterima'`, `'ditolak'`
* **Jenis Notifikasi:** `'riwayat_diri_diperbarui'`, `'pengajuan_masuk'`, `'pengajuan_diterima'`, `'pengajuan_ditolak'`, `'undangan_masuk'`, `'respon_undangan'`

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

### MODUL 0: AUTENTIKASI & IDENTITAS AKUN (Core / Shared Service)

#### 4.0.1 Registrasi Akun Mahasiswa
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

#### 4.0.2 Login Akun Mahasiswa
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

#### 4.0.3 Unggah Foto Profil Pengguna
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

---

### MODUL 1: AKUN & DATA RIWAYAT DIRI (PIC: Fuadi Dhiyaulhaq)

#### 4.1.1 Kelola Data Diri (FR-01)
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

#### 4.1.2 Kelola Media Sosial (FR-02)
* **List Media Sosial:** `GET /profile/media-sosial`
* **Tambah Media Sosial:** `POST /profile/media-sosial`
  * Body: `{"nama_media_sosial": "LinkedIn", "link_media_sosial": "https://linkedin.com/in/fuadidhy"}`
* **Ubah Media Sosial:** `PUT /profile/media-sosial/{id_media_sosial}`
* **Hapus Media Sosial:** `DELETE /profile/media-sosial/{id_media_sosial}`

#### 4.1.3 Kelola Minat (FR-03)
* **List Minat:** `GET /profile/minat`
* **Tambah Minat:** `POST /profile/minat`
  * Body: `{"minat": "Mobile App Development", "deskripsi_minat": "Fokus pada Flutter dan Android Native"}`
* **Ubah Minat:** `PUT /profile/minat/{id_minat}`
* **Hapus Minat:** `DELETE /profile/minat/{id_minat}`

#### 4.1.4 Kelola Keahlian (FR-04)
* **List Keahlian:** `GET /profile/keahlian`
* **Tambah Keahlian:** `POST /profile/keahlian`
  * Body: `{"keahlian": "Flutter & Dart", "deskripsi_keahlian": "State management Provider, REST API integration"}`
* **Ubah Keahlian:** `PUT /profile/keahlian/{id_keahlian}`
* **Hapus Keahlian:** `DELETE /profile/keahlian/{id_keahlian}`

#### 4.1.5 Kelola Riwayat Pengalaman (FR-05 — PRD v1.0 Refinement)
> **Catatan Penting PRD v1.0:** Fitur media/bukti pendukung dihapus, digantikan dengan penambahan atribut `deskripsi_pengalaman`.

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

#### 4.1.6 Detail Profil Lengkap & Tim yang Diikuti (FR-06)
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

#### 4.1.7 Notifikasi Aktivitas Data Riwayat Diri (FR-07)
* **Trigger:** *Auto-event* sistem saat pengguna berhasil memperbarui data diri, keahlian, minat, atau pengalaman.
* **Aksi Sistem:** Menyimpan riwayat aktivitas ke tabel `Notifikasi` untuk akun pengguna bersangkutan dengan jenis `aktivitas_profil`.
* **Payload Event:**
```json
{
  "id_pengguna": "usr_2411522001",
  "jenis_notifikasi": "aktivitas_profil",
  "pesan_notifikasi": "Data riwayat diri Anda berhasil diperbarui.",
  "status_dibaca": false
}
```

---

### MODUL 2: PEMBENTUKAN & MANAJEMEN TIM (PIC: Nayla Puspita Sari)

#### 4.2.1 Pembuatan Tim Baru (FR-08)
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

#### 4.2.2 Daftar Tim Saya (FR-09)
* **Endpoint:** `GET /teams/my-teams`
* **Akses:** Terautentikasi
* **Respon Sukses (200 OK):** Mengembalikan tim yang dibuat pengguna dan tim yang diikuti sebagai anggota aktif pada `Anggota_Tim`. Setiap tim memuat `peran` bernilai `"pemilik"` atau `"anggota"`. Aksi ubah dan hapus hanya dapat dilakukan oleh pemilik.
```json
{
  "success": true,
  "data": [
    {
      "id_tim": "tim_gemastik_01",
      "id_pengguna": "usr_rafa_02",
      "nama_tim": "Tim Robotik Cerdas Unand",
      "nama_kegiatan": "GEMASTIK XVII Divisi Software Development",
      "kategori_kegiatan": "Lomba",
      "status_tim": "terbuka",
      "peran": "anggota",
      "anggota_tim": [
        {
          "id_pengguna": "usr_diva_03",
          "nama_pengguna": "Diva Ramadhani",
          "posisi": "UI/UX Designer"
        },
        {
          "id_pengguna": "usr_fuadi_01",
          "nama_pengguna": "Fuadi Dhiyaulhaq",
          "posisi": "Frontend Flutter"
        }
      ]
    }
  ]
}
```

#### 4.2.3 Detail Tim (FR-09)
* **Endpoint:** `GET /teams/{id_tim}`
* **Akses:** Terautentikasi (pemilik tim atau anggota aktif)
* **Respon Sukses (200 OK):** Mengembalikan informasi tim, dokumen pendukung, kebutuhan tim, dan daftar anggota aktif saat ini.

#### 4.2.4 Pembaruan Informasi Tim (FR-10)
* **Endpoint:** `PUT /teams/{id_tim}` (atau `POST /teams/{id_tim}/update` untuk form-data)
* **Akses:** Terautentikasi (khusus pemilik tim)
* **Aturan Bisnis FR-10:** Nilai `kategori_kegiatan` **dikunci / tidak boleh diubah**. Upaya mengubah field ini akan ditolak backend dengan status HTTP 422.
* **Request Body:**
```json
{
  "nama_tim": "Tim Robotik Cerdas Unand",
  "nama_kegiatan": "Kontes Robot Indonesia 2026",
  "deskripsi": "Deskripsi terbaharui mengenai kebutuhan mekanik dan elektronika robot.",
  "status_tim": "terbuka"
}
```

#### 4.2.5 Penghapusan Tim (FR-11)
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

#### 4.2.6 Notifikasi Pengajuan Masuk ke Tim (FR-12)
* **Trigger:** *Auto-event* sistem saat ada pencari tim yang mengajukan lamaran bergabung ke tim milik pembuat tim (`POST /applications/join-team`).
* **Aksi Sistem:** Mengirimkan dan mencatat record notifikasi ke tabel `Notifikasi` untuk akun pemilik tim dengan jenis `pengajuan_masuk`.
* **Payload Event:**
```json
{
  "id_pengguna": "usr_2411522014",
  "jenis_notifikasi": "pengajuan_masuk",
  "pesan_notifikasi": "Pengajuan bergabung baru diterima dari Fuadi Dhiyaulhaq untuk posisi Computer Vision Specialist pada tim 'Tim Robotik Cerdas Unand'.",
  "id_pengajuan_bergabung_tim": "pbg_9901b",
  "status_dibaca": false
}
```

---

### MODUL 3: PENCARIAN TIM & PENGAJUAN BERGABUNG (PIC: Rafa Gian Atthari)

#### 4.3.1 Feed Tim & Filter Pencarian (FR-13, FR-14)
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

#### 4.3.2 Detail Tim untuk Calon Pelamar (FR-15)
* **Endpoint:** `GET /teams/feed/{id_tim}`
* **Akses:** Terautentikasi
* **Respon Sukses (200 OK):** Mengembalikan profil lengkap tim, detail posisi terbuka, dan profil singkat pembuat tim.

#### 4.3.3 Pengajuan Bergabung ke Tim (FR-16 — PRD v1.0 Refinement)
> **Catatan Penting PRD v1.0:** Pelamar **wajib menyertakan atribut `posisi`** (posisi yang dilamar) sesuai opsi yang dibuka oleh pembuat tim.

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

#### 4.3.4 Daftar Pengajuan Masuk Tim (FR-17 — Pembuat Tim)
* **Endpoint:** `GET /teams/{id_tim}/applications`
* **Akses:** Terautentikasi (khusus pemilik tim)
* **Respon Sukses (200 OK):** Menampilkan daftar pelamar, posisi yang mereka lamar, waktu pengajuan, dan status.

#### 4.3.5 Detail Pengajuan Bergabung (FR-18)
* **Endpoint:** `GET /applications/join-team/{id_pengajuan_bergabung_tim}`
* **Akses:** Terautentikasi (pemilik tim)
* **Respon Sukses (200 OK):** Menampilkan detail lengkap surat pengajuan, posisi yang dilamar, serta profil akademik pelamar.

#### 4.3.6 Keputusan Pengajuan: Terima / Tolak (FR-19)
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

#### 4.3.7 Riwayat Pengajuan Saya (FR-20 — Pelamar)
* **Endpoint:** `GET /applications/my-applications`
* **Akses:** Terautentikasi
* **Respon Sukses (200 OK):** Menampilkan seluruh status pengajuan yang pernah dikirimkan oleh pengguna (`menunggu`, `diterima`, `ditolak`).

---

### MODUL 4: PENCARIAN ANGGOTA, PENGAJUAN ANGGOTA & NOTIFIKASI UNDANGAN (PIC: Diva Ramadhani)

**Ruang lingkup:** pembuat tim mencari calon anggota (nama, NIM, program studi, keahlian, minat), meninjau profilnya, mengirim undangan lewat form *Ajak Bergabung ke Tim*, dan memantau undangan terkirim. Calon anggota mengelola undangan masuk (terima/tolak). Notifikasi dibuat otomatis oleh server pada setiap pengiriman dan respons undangan.

| Layar Flutter | Fitur | Endpoint yang dipakai |
| :--- | :--- | :--- |
| `TalentSearchScreen` | Pencarian + filter keahlian/minat + reset filter (FR-21) | `GET /members/search` |
| `MemberDetailScreen` | Detail calon anggota (FR-22) | `GET /profile/detail/{id_pengguna}` |
| `_InviteBottomSheet` (dibuka dari tombol *Ajak Bergabung ke Tim*) | Form pilih tim, posisi, pesan; Kirim/Batal (FR-23) | `GET /teams/my-teams`, `POST /applications/invite-member` |
| `ReceivedInvitationsScreen` tab **Undangan Masuk** | Lihat undangan, detail tim, terima/tolak (FR-24) | `GET /applications/received-invitations`, `PATCH /applications/received-invitations/{id}/status`, `GET /teams/feed/{id_tim}` |
| `ReceivedInvitationsScreen` tab **Undangan Terkirim** | Pantau status undangan terkirim (FR-24b) | `GET /applications/sent-invitations` |
| *(otomatis di server)* | Notifikasi undangan & respons (FR-25) | Dibuat pada `POST /applications/invite-member` dan `PATCH .../status` |
| Ikon **Notifikasi** di navigasi bawah (`HomeScreen`) | Badge jumlah notifikasi belum dibaca (FR-25) | `GET /notifications/unread-count`, `PATCH /notifications/read-all` |

#### 4.4.1 Pencarian Calon Anggota (FR-21)
* **Endpoint:** `GET /members/search`
* **Akses:** Terautentikasi
* **Query Parameters:**

| Parameter | Tipe | Wajib | Keterangan |
| :--- | :--- | :---: | :--- |
| `q` | string | Tidak | Kata kunci yang dicocokkan (`LIKE %q%`) dengan **nama**, **program studi**, atau **NIM**. |
| `keahlian` | string | Tidak | Filter keahlian (tidak peka huruf besar/kecil, cocok sebagian). Pada aplikasi dipilih lewat chip *Filter Keahlian*. |
| `minat` | string | Tidak | Filter minat (aturan sama dengan `keahlian`). Pada aplikasi dipilih lewat chip *Filter Minat*. |
| `page`, `limit` | integer | Tidak | Paginasi. Default `page=1`, `limit=20`. |

* **Aturan:** semua parameter yang diisi digabung dengan logika **AND**. Filter `keahlian`/`minat` diterapkan setelah data diambil, sehingga paginasi dihitung dari hasil yang sudah terfilter. **Reset filter** dilakukan di sisi aplikasi (tombol hapus filter / reset pada kondisi hasil kosong) dengan memanggil ulang endpoint tanpa `keahlian`/`minat`. Opsi chip filter dibentuk dari daftar keahlian dan minat pada hasil pencarian tanpa filter. Pengguna yang sedang login tidak dikecualikan dari hasil; upaya mengundang diri sendiri ditolak di sisi aplikasi.
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Pencarian calon anggota berhasil",
  "data": [
    {
      "id_pengguna": "usr_nayla_04",
      "nim": "2411521007",
      "nama_pengguna": "Nayla Puspita Sari",
      "foto_profil": "profiles/usr_nayla_04.jpg",
      "program_studi": "Sistem Informasi",
      "fakultas": "Teknologi Informasi",
      "ipk": 3.88,
      "deskripsi_singkat": "Peneliti muda di bidang Data Science dan Analisis Sistem.",
      "keahlian": ["Python & Pandas", "Scientific Writing"],
      "minat": ["Data Science & Analytics", "Riset Ilmiah & PKM"],
      "total_pengalaman": 1
    }
  ],
  "pagination": { "current_page": 1, "per_page": 20, "total_records": 1, "total_pages": 1 }
}
```
* `program_studi`, `fakultas`, `ipk`, dan `deskripsi_singkat` bernilai `null` jika pengguna belum mengisi data diri. `total_pengalaman` menampilkan jumlah pengalaman sebagai informasi profil (bukan kriteria filter). **Respon Gagal:** `500` untuk kesalahan server.

#### 4.4.2 Detail Profil Calon Anggota (FR-22)
* **Endpoint:** `GET /profile/detail/{id_pengguna}` (endpoint yang sama dengan FR-06)
* **Akses:** Terautentikasi
* **Penggunaan di aplikasi:** dibuka dari kartu hasil pencarian (`MemberDetailScreen`). Layar menampilkan ringkasan jumlah keahlian/minat/pengalaman, deskripsi singkat, prodi dan IPK, media sosial & portofolio, minat, keahlian, riwayat pengalaman, serta tim yang diikuti. Tombol **Ajak Bergabung ke Tim** pada layar ini membuka form FR-23.
* **Respon Sukses (200 OK):** data dikembalikan di dalam objek `data`, dengan `pengguna`, `data_diri`, `media_sosial`, `minat`, `keahlian`, `pengalaman`, dan `tim_yang_diikuti`. Nilai `data_diri` dapat `null` jika belum tersedia.
```json
{
  "success": true,
  "message": "Detail profil pengguna berhasil diambil",
  "data": {
    "pengguna": {
      "id_pengguna": "usr_nayla_04",
      "nim": "2411521007",
      "nama_pengguna": "Nayla Puspita Sari",
      "foto_profil": "profiles/usr_nayla_04.jpg"
    },
    "data_diri": {
      "id_pengguna": "usr_nayla_04",
      "deskripsi_singkat": "Peneliti muda di bidang Data Science dan Analisis Sistem. Memiliki minat kuat dalam penulisan proposal hibah kompetitif (PKM) dan pengolahan data analitik.",
      "kontak": "081267891014",
      "program_studi": "Sistem Informasi",
      "fakultas": "Teknologi Informasi",
      "ipk": 3.88
    },
    "media_sosial": [
      {"id_media_sosial": "soc_10", "nama_media_sosial": "LinkedIn", "link_media_sosial": "https://linkedin.com/in/nayla-puspita-sari"},
      {"id_media_sosial": "soc_11", "nama_media_sosial": "GitHub", "link_media_sosial": "https://github.com/naylapuspita"},
      {"id_media_sosial": "soc_12", "nama_media_sosial": "Instagram", "link_media_sosial": "https://instagram.com/naylapuspita"}
    ],
    "minat": [
      {"id_minat": "mnt_07", "minat": "Data Science & Analytics", "deskripsi_minat": "Eksplorasi data, pemodelan statistik, dan pembuatan dashboard insight."},
      {"id_minat": "mnt_08", "minat": "Riset Ilmiah & PKM", "deskripsi_minat": "Penulisan proposal Program Kreativitas Mahasiswa bidang Riset Eksakta (PKM-RE)."}
    ],
    "keahlian": [
      {"id_keahlian": "khl_07", "keahlian": "Python & Pandas", "deskripsi_keahlian": "Analisis data tabular, visualisasi Matplotlib/Seaborn, dan pemodelan prediktif."},
      {"id_keahlian": "khl_08", "keahlian": "Scientific Writing", "deskripsi_keahlian": "Penyusunan metodologi penelitian kuantitatif dan kepatuhan format pedoman Dikti."}
    ],
    "pengalaman": [
      {"id_pengalaman": "exp_05", "nama_kegiatan": "Program Kreativitas Mahasiswa (PKM-AI) Lolos Pendanaan 2025", "peran": "Peneliti Utama", "tahun": 2025, "deskripsi_pengalaman": "Menganalisis sentimen media sosial terhadap kebijakan transportasi publik dan mempublikasikan artikel ilmiah di jurnal terakreditasi SINTA."}
    ],
    "tim_yang_diikuti": []
  }
}
```


#### 4.4.3 Pengajuan Bergabung: Kirim Undangan ke Calon Anggota (FR-23)
**Alur form (`_InviteBottomSheet`):** pembuat tim menekan tombol **Ajak Bergabung ke Tim** pada detail calon anggota, lalu mengisi:
1. **Pilih Tim:** dari `GET /teams/my-teams`, hanya tim dengan `peran = "pemilik"` (tim yang dibuat pengguna). Jika hanya ada satu tim, tim terpilih otomatis.
2. **Posisi yang Ditawarkan:** dropdown berisi hanya posisi yang masih memiliki kuota (`jumlah_anggota_dibutuhkan` dikurangi jumlah `anggota_tim` pada posisi tersebut). Posisi yang sudah penuh tidak ditampilkan.
3. **Pesan Undangan:** teks bebas.
4. Tombol **Kirim Undangan** atau **Batal** (menutup form tanpa memanggil API).

Validasi di aplikasi: tim, posisi, dan pesan wajib diisi; pengguna tidak dapat mengundang dirinya sendiri.

* **Endpoint:** `POST /applications/invite-member`
* **Akses:** Terautentikasi
* **Validasi server:** pengirim diambil dari token JWT dan **harus pembuat (pemilik) tim**. `id_tim`, `id_pengguna`, `posisi`, dan `pesan_pengajuan` wajib diisi. Calon anggota harus terdaftar dan bukan pengirim sendiri. Posisi harus ada pada `Kebutuhan_Anggota_Tim` tim tersebut (tidak peka huruf besar/kecil) dan kuotanya belum terpenuhi. Calon anggota yang sudah menjadi anggota tim, atau masih memiliki undangan `menunggu` dari tim yang sama, tidak dapat diundang lagi.
* **Request Body:**
```json
{
  "id_tim": "tim_pkm_02",
  "id_pengguna": "usr_fuadi_01",
  "posisi": "Mobile App Developer",
  "pesan_pengajuan": "Halo Fuadi, kami melihat keahlian Anda sesuai dengan kebutuhan tim."
}
```
* **Respon Sukses (201 Created):**
```json
{
  "success": true,
  "message": "Undangan berhasil dikirim ke calon anggota",
  "data": {
    "id_pengajuan_anggota": "pga_1728800001",
    "id_tim": "tim_pkm_02",
    "id_pengguna": "usr_fuadi_01",
    "posisi": "Mobile App Developer",
    "status_pengajuan": "menunggu"
  }
}
```
* **Aksi sistem (satu transaksi):** menyimpan undangan ke `Pengajuan_Anggota` dengan status `menunggu` dan membuat notifikasi `undangan_masuk` untuk calon anggota dengan isi: Anda menerima undangan untuk bergabung ke "{nama_tim}" sebagai {posisi}.
* **Respon Gagal:**

| Kode | Kondisi |
| :---: | :--- |
| `401` | Token tidak ada/tidak valid. |
| `403` | Pengirim bukan pembuat tim. |
| `404` | Tim atau calon anggota tidak ditemukan. |
| `422` | Field wajib tidak lengkap, atau mengundang diri sendiri. |
| `409` | Calon sudah anggota tim, masih ada undangan `menunggu` dari tim yang sama, atau posisi tidak tersedia/kuota penuh (undangan tidak dibuat). |
| `500` | Kesalahan server. |

Kondisi `409` kuota ini berbeda dari kuota yang baru penuh setelah undangan terkirim (lihat FR-24).

#### 4.4.4 Kelola Undangan Masuk: Terima / Tolak (FR-24)
Calon anggota membuka menu **Notifikasi** lalu tab **Undangan Masuk** (`ReceivedInvitationsScreen`). Undangan dikelompokkan menjadi **Menunggu Keputusan** dan **Riwayat Undangan**. Menekan kartu undangan membuka detail tim pengundang (`TeamDetailViewScreen`: tentang tim, posisi yang dibutuhkan, anggota tim, dokumen pendukung) lewat `GET /teams/feed/{id_tim}`. Tombol **Terima**/**Tolak** menampilkan dialog konfirmasi sebelum memanggil API.

* **Daftar Undangan Masuk:** `GET /applications/received-invitations`
* **Akses:** Terautentikasi (calon anggota). Identitas diambil dari token JWT. Parameter `id_pengguna` bersifat opsional dan, bila dikirim, harus sama dengan pemilik token (jika berbeda: `403`). Daftar memuat semua status, diurutkan dari yang terbaru. Tanpa token: `401`.
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id_pengajuan_anggota": "pga_01",
      "id_tim": "tim_pkm_02",
      "id_pengguna": "usr_fuadi_01",
      "posisi": "Mobile App Developer",
      "pesan_pengajuan": "Halo Fuadi, kami melihat portofolio dan riwayat pengalaman mobile development Anda di MyTeam. Apakah Anda bersedia bergabung?",
      "status_pengajuan": "menunggu",
      "waktu_pengajuan": "2026-10-09T11:00:00.000Z",
      "nama_tim": "Inovator Pangan Unand",
      "nama_kegiatan": "Program Kreativitas Mahasiswa Riset Eksakta (PKM-RE) 2026",
      "kategori_kegiatan": "Penelitian",
      "deskripsi_tim": "Proyek riset interdisipliner untuk membangun model kecerdasan buatan dan aplikasi mobile pemantau pasokan komoditas pangan lokal Sumatera Barat."
    }
  ]
}
```

* **Aksi Keputusan:** `PATCH /applications/received-invitations/{id_pengajuan_anggota}/status` (hanya calon anggota yang diundang; tanpa token `401`, bukan penerima undangan `403`)
* **Request Body:** `{ "status_pengajuan": "diterima" }` (nilai valid: `"diterima"` atau `"ditolak"`)
* **Aturan (satu transaksi):**
  * `diterima` dan kuota posisi masih tersedia: calon anggota ditambahkan ke `Anggota_Tim` pada posisi yang ditawarkan, status menjadi `diterima`.
  * `diterima` tetapi kuota posisi sudah penuh: tetap `200 OK`, status otomatis menjadi `ditolak`, pesan menyebut posisi tersebut, dan calon anggota tidak dimasukkan ke tim.
  * `ditolak`: status menjadi `ditolak`.
  * Pada kedua keputusan, server membuat notifikasi `respon_undangan` untuk pemilik tim (lihat FR-25).
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "message": "Undangan berhasil di-diterima.",
  "data": { "id_pengajuan_anggota": "pga_01", "status_pengajuan": "diterima" }
}
```
* **Respon ketika kuota penuh (200 OK):**
```json
{
  "success": true,
  "message": "Kuota untuk posisi \"Mobile App Developer\" sudah penuh. Undangan otomatis ditolak.",
  "data": { "id_pengajuan_anggota": "pga_01", "status_pengajuan": "ditolak" }
}
```
* **Respon Gagal:** `401` token tidak valid; `403` bukan penerima undangan; `400` status selain `diterima`/`ditolak`; `404` undangan tidak ditemukan; `409` undangan sudah pernah direspons, calon anggota sudah menjadi anggota tim, atau undangan lama belum memiliki posisi; `500` kesalahan server. Aplikasi menampilkan pesan dari server lalu memuat ulang daftar.

#### 4.4.5 Kelola Undangan Terkirim (FR-24b)
Pembuat tim membuka tab **Undangan Terkirim** pada layar yang sama. Layar menampilkan ringkasan jumlah **Menunggu / Diterima / Ditolak** dan daftar undangan yang dikelompokkan menurut status.

* **Endpoint:** `GET /applications/sent-invitations`
* **Akses:** Pembuat tim. Identitas diambil dari token JWT; `id_pengguna` opsional dan harus sama dengan pemilik token (jika berbeda: `403`; tanpa token: `401`). Mengambil undangan dari semua tim yang dimiliki pengguna tersebut.
* **Respon Sukses (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id_pengajuan_anggota": "pga_01",
      "id_tim": "tim_pkm_02",
      "id_calon": "usr_fuadi_01",
      "posisi": "Mobile App Developer",
      "pesan_pengajuan": "Halo Fuadi, kami mengajak Anda bergabung ke tim riset PKM Pangan.",
      "status_pengajuan": "menunggu",
      "waktu_pengajuan": "2026-10-09T11:00:00.000Z",
      "nama_tim": "Inovator Pangan Unand",
      "nama_kegiatan": "Program Kreativitas Mahasiswa Riset Eksakta (PKM-RE) 2026",
      "kategori_kegiatan": "Penelitian",
      "nama_calon": "Fuadi Dhiyaulhaq",
      "foto_calon": "profiles/usr_fuadi_01.jpg",
      "nim_calon": "2411522001",
      "prodi_calon": "Sistem Informasi"
    }
  ]
}
```

#### 4.4.6 Notifikasi Undangan (FR-25)
Notifikasi dibuat otomatis oleh server (tanpa endpoint pembuatan) dan disimpan di tabel `Notifikasi`:

| Pemicu | Penerima | `jenis_notifikasi` | Contoh isi (`pesan_notifikasi`) |
| :--- | :--- | :--- | :--- |
| `POST /applications/invite-member` | Calon anggota | `undangan_masuk` | Anda menerima undangan untuk bergabung ke "Inovator Pangan Unand" sebagai Mobile App Developer. |
| `PATCH .../received-invitations/{id}/status` | Pemilik tim | `respon_undangan` | Fuadi Dhiyaulhaq telah diterima undangan bergabung ke tim "Inovator Pangan Unand" sebagai Mobile App Developer. |

Setiap notifikasi menyimpan `id_pengajuan_anggota` dan `status_dibaca` (default `false`). Notifikasi dibaca lewat endpoint bersama berikut. Identitas pengguna diambil dari token JWT (tanpa token: `401`); `id_pengguna` pada query hanya dipakai sebagai cadangan jika token tidak dikirim.

| Endpoint | Fungsi | Respon |
| :--- | :--- | :--- |
| `GET /notifications` | Daftar notifikasi milik pengguna, terbaru dahulu | `200` + array notifikasi |
| `GET /notifications/unread-count` | Jumlah notifikasi belum dibaca (badge ikon Notifikasi) | `200` `{ "data": { "unread_count": 2 } }` |
| `PATCH /notifications/read-all` | Menandai semua notifikasi milik pengguna sudah dibaca | `200` `{ "data": { "updated": 2 } }` |
| `PATCH /notifications/{id}/read` | Menandai satu notifikasi sudah dibaca (hanya milik sendiri) | `200`; `404` jika bukan milik pengguna |

**Badge pada aplikasi:** ikon **Notifikasi** di navigasi bawah menampilkan jumlah `unread_count`. Angka disegarkan saat aplikasi dibuka, saat berpindah tab, dan tiap 30 detik. Membuka (atau meninggalkan) tab Notifikasi memanggil `PATCH /notifications/read-all` sehingga badge kembali ke 0. Status undangan juga ditampilkan langsung pada tab **Undangan Masuk** dan **Undangan Terkirim**; jika kuota penuh saat undangan diterima, isi notifikasi mengikuti status akhir `ditolak`.

---

## 5. Kamus Basis Data Fisik (Physical Data Dictionary)

Berdasarkan Bagian 2.5 PRD v1.0, berikut adalah skema database relasional yang disepakati:

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

-- 6. Data_Pengalaman (PRD v1.0: Deskripsi ditambahkan, Media ditiadakan)
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

-- 8. Kebutuhan_Anggota_Tim
CREATE TABLE Kebutuhan_Anggota_Tim (
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
    UNIQUE KEY uq_tim_anggota (id_tim, id_pengguna),
    FOREIGN KEY (id_tim) REFERENCES Data_Tim(id_tim) ON DELETE CASCADE,
    FOREIGN KEY (id_pengguna) REFERENCES Pengguna(id_pengguna) ON DELETE CASCADE
);

-- 11. Pengajuan_Bergabung_Tim (PRD v1.0: Atribut posisi ditambahkan)
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
    posisi VARCHAR(100) NOT NULL, -- Posisi yang ditawarkan oleh pembuat tim
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
  /// Mengirim pengajuan bergabung ke tim dengan posisi yang dilamar (FR-16)
  Future<ApplicationResult> applyToTeam({
    required String teamId,
    required String position,
    required String message,
  });

  /// Mengambil daftar riwayat pengajuan milik pengguna (FR-20)
  Future<List<ApplicationHistory>> getMyApplications();
}
```

Dengan adanya pemisahan interface ini:
1. Setiap mahasiswa dapat mengimplementasikan `MockTeamApplicationRepository` menggunakan data statis/lokal untuk kebutuhan demo UI dan pengujian widget.
2. Ketika backend server lokal siap, cukup ganti ke `HttpTeamApplicationRepository` tanpa perlu merombak layar UI (*Screen*) maupun *State Management*.

---

*Dokumen ini sah dan disetujui sebagai acuan baku pengembangan aplikasi MyTeam pada Mata Kuliah Pemrograman Aplikasi Mobile (PAM), Universitas Andalas.*
