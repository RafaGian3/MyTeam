# API Specification Contract — MyTeam Mobile App

**Version:** 1.0.0  
**Base URL:** `http://localhost:8000/api/v1` (atau server database/backend lokal yang ditentukan)  
**Protocol:** RESTful JSON API / Multipart Form-Data (dokumen & foto profil)  
**Referensi:** Product Requirements Document (PRD MyTeam v1.3)

---

## 1. Konvensi & Standar API

### 1.1 Headers Standar
| Header | Value | Keterangan |
| :--- | :--- | :--- |
| `Accept` | `application/json` | Format respons yang diharapkan |
| `Content-Type` | `application/json` atau `multipart/form-data` | Format data request |
| `Authorization` | `Bearer <access_token>` | Diperlukan pada semua endpoint terproteksi |

### 1.2 Format Respons Standar

#### Respons Sukses (200 OK / 201 Created)
```json
{
  "success": true,
  "message": "Operasi berhasil dilakukan",
  "data": {}
}
```

#### Respons Sukses dengan Pagination
```json
{
  "success": true,
  "message": "Data berhasil diambil",
  "data": [],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_records": 45,
    "total_pages": 5
  }
}
```

#### Respons Gagal / Error (400, 401, 403, 404, 422, 500)
```json
{
  "success": false,
  "message": "Pesan deskripsi kesalahan",
  "errors": {
    "field_name": [
      "Detail validasi error"
    ]
  }
}
```

---

## 2. Modul Autentikasi & Akun

### 2.1 Registrasi Pengguna
* **Endpoint:** `POST /auth/register`
* **Deskripsi:** Mendaftarkan akun mahasiswa baru ke sistem MyTeam.
* **Request Body:**
```json
{
  "nim": "2411522001",
  "nama_pengguna": "Fuadi Dhiyaulhaq",
  "kata_sandi": "passwordRahasia123",
  "kata_sandi_konfirmasi": "passwordRahasia123"
}
```
* **Response (201 Created):**
```json
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "id_pengguna": "usr_01h7abc...",
    "nim": "2411522001",
    "nama_pengguna": "Fuadi Dhiyaulhaq",
    "foto_profil": null,
    "token": "eyJhbGciOi..."
  }
}
```

### 2.2 Login Pengguna
* **Endpoint:** `POST /auth/login`
* **Deskripsi:** Masuk ke dalam aplikasi menggunakan NIM dan kata sandi.
* **Request Body:**
```json
{
  "nim": "2411522001",
  "kata_sandi": "passwordRahasia123"
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "token": "eyJhbGciOi...",
    "pengguna": {
      "id_pengguna": "usr_01h7abc...",
      "nim": "2411522001",
      "nama_pengguna": "Fuadi Dhiyaulhaq",
      "foto_profil": "https://storage.local/profiles/usr_01h7abc.jpg"
    }
  }
}
```

### 2.3 Ambil Data Akun Saya (Current User)
* **Endpoint:** `GET /auth/me`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Data akun berhasil diambil",
  "data": {
    "id_pengguna": "usr_01h7abc...",
    "nim": "2411522001",
    "nama_pengguna": "Fuadi Dhiyaulhaq",
    "foto_profil": "https://storage.local/profiles/usr_01h7abc.jpg"
  }
}
```

### 2.4 Update Foto Profil
* **Endpoint:** `POST /auth/foto-profil`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Body:**
  * `foto_profil`: File image (jpg/jpeg/png, max 2MB)
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Foto profil berhasil diperbarui",
  "data": {
    "foto_profil": "https://storage.local/profiles/usr_01h7abc.jpg"
  }
}
```

---

## 3. Modul Data Riwayat Diri (Profil Pengguna)

### 3.1 Data Diri (FR-01)
* **Get Data Diri Saya:** `GET /profile/data-diri`
* **Update Data Diri Saya:** `PUT /profile/data-diri`
* **Request Body (PUT):**
```json
{
  "deskripsi_singkat": "Mahasiswa Sistem Informasi yang tertarik pada mobile application development.",
  "kontak": "081234567890",
  "program_studi": "Sistem Informasi",
  "fakultas": "Teknologi Informasi",
  "ipk": 3.85
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Data diri berhasil diperbarui",
  "data": {
    "id_pengguna": "usr_01h7abc...",
    "deskripsi_singkat": "Mahasiswa Sistem Informasi yang tertarik pada mobile application development.",
    "kontak": "081234567890",
    "program_studi": "Sistem Informasi",
    "fakultas": "Teknologi Informasi",
    "ipk": 3.85
  }
}
```

### 3.2 Media Sosial (FR-02)
* **List Media Sosial Saya:** `GET /profile/media-sosial`
* **Tambah Media Sosial:** `POST /profile/media-sosial`
  * Body: `{"nama_media_sosial": "LinkedIn", "link_media_sosial": "https://linkedin.com/in/fuadidhy"}`
* **Update Media Sosial:** `PUT /profile/media-sosial/{id_media_sosial}`
  * Body: `{"nama_media_sosial": "LinkedIn", "link_media_sosial": "https://linkedin.com/in/fuadidhy-new"}`
* **Hapus Media Sosial:** `DELETE /profile/media-sosial/{id_media_sosial}`

### 3.3 Data Minat (FR-03)
* **List Minat Saya:** `GET /profile/minat`
* **Tambah Minat:** `POST /profile/minat`
  * Body: `{"minat": "UI/UX Design", "deskripsi_minat": "Mendesain antarmuka aplikasi yang intuitif"}`
* **Update Minat:** `PUT /profile/minat/{id_minat}`
* **Hapus Minat:** `DELETE /profile/minat/{id_minat}`

### 3.4 Data Keahlian (FR-04)
* **List Keahlian Saya:** `GET /profile/keahlian`
* **Tambah Keahlian:** `POST /profile/keahlian`
  * Body: `{"keahlian": "Flutter", "deskripsi_keahlian": "State management Provider & Riverpod"}`
* **Update Keahlian:** `PUT /profile/keahlian/{id_keahlian}`
* **Hapus Keahlian:** `DELETE /profile/keahlian/{id_keahlian}`

### 3.5 Data Pengalaman (FR-05 — Updated PRD v1.3)
> **Catatan PRD v1.3:** Bukti pendukung/media dihapus. Menyimpan riwayat kegiatan dan deskripsi pengalaman.

* **List Pengalaman Saya:** `GET /profile/pengalaman`
* **Tambah Pengalaman:** `POST /profile/pengalaman`
  * **Request Body:**
```json
{
  "nama_kegiatan": "GEMASTIK XVII 2024",
  "peran": "Frontend Mobile Developer",
  "tahun": 2024,
  "deskripsi_pengalaman": "Mengembangkan prototype aplikasi mobile untuk kategori pengembangan perangkat lunak hingga babak finalis."
}
```
* **Update Pengalaman:** `PUT /profile/pengalaman/{id_pengalaman}`
  * **Request Body:**
```json
{
  "nama_kegiatan": "GEMASTIK XVII 2024",
  "peran": "Lead Mobile Developer",
  "tahun": 2024,
  "deskripsi_pengalaman": "Memimpin arsitektur antarmuka Flutter dan integrasi REST API."
}
```
* **Hapus Pengalaman:** `DELETE /profile/pengalaman/{id_pengalaman}`

### 3.6 Preferensi Pencarian (FR-07)
* **Get Preferensi:** `GET /profile/preferensi`
* **Update Preferensi:** `PUT /profile/preferensi`
  * **Request Body:**
```json
{
  "preferensi_pencarian": "keduanya" 
}
```
*(Nilai valid: `"pencari_tim"`, `"pencari_anggota"`, `"keduanya"`)*

### 3.7 Profil Lengkap & Tim yang Diikuti (FR-06)
* **Endpoint:** `GET /profile/detail/{id_pengguna}`
* **Deskripsi:** Mengambil detail lengkap profil seorang mahasiswa beserta tim yang diikutinya (digunakan untuk melihat profil sendiri atau profil calon anggota).
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Detail profil berhasil diambil",
  "data": {
    "pengguna": {
      "id_pengguna": "usr_01h7abc...",
      "nim": "2411522001",
      "nama_pengguna": "Fuadi Dhiyaulhaq",
      "foto_profil": "https://storage.local/profiles/usr_01h7abc.jpg"
    },
    "data_diri": {
      "deskripsi_singkat": "Mobile Developer",
      "kontak": "081234567890",
      "program_studi": "Sistem Informasi",
      "fakultas": "Teknologi Informasi",
      "ipk": 3.85
    },
    "preferensi_pencarian": "keduanya",
    "media_sosial": [
      {
        "id_media_sosial": "soc_1",
        "nama_media_sosial": "LinkedIn",
        "link_media_sosial": "https://linkedin.com/in/fuadidhy"
      }
    ],
    "minat": [
      {
        "id_minat": "mnt_1",
        "minat": "Mobile Dev",
        "deskripsi_minat": "Flutter & Android"
      }
    ],
    "keahlian": [
      {
        "id_keahlian": "khl_1",
        "keahlian": "Flutter",
        "deskripsi_keahlian": "State Management & UI"
      }
    ],
    "pengalaman": [
      {
        "id_pengalaman": "exp_1",
        "nama_kegiatan": "GEMASTIK XVII",
        "peran": "Frontend Dev",
        "tahun": 2024,
        "deskripsi_pengalaman": "Membuat antarmuka aplikasi."
      }
    ],
    "tim_yang_diikuti": [
      {
        "id_anggota_tim": "ang_1",
        "id_tim": "tim_123",
        "nama_tim": "Garuda Tech",
        "nama_kegiatan": "LIDM 2025",
        "kategori_kegiatan": "Lomba",
        "posisi": "Mobile Developer"
      }
    ]
  }
}
```

---

## 4. Modul Manajemen Tim (Pembuat Tim)

### 4.1 Buat Tim Baru (FR-09)
* **Endpoint:** `POST /teams`
* **Headers:** `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`
* **Form Fields:**
  * `nama_tim` (string, required): "Inovasi Unand"
  * `nama_kegiatan` (string, required): "PIMNAS 2026"
  * `kategori_kegiatan` (string, required): "PKM-KC" *(misal: Lomba, Penelitian, Proyek)*
  * `deskripsi` (string, required): "Pengembangan prototipe sistem IoT kampus cerdas."
  * `kebutuhan` (string JSON):
    ```json
    [
      {
        "posisi_dibutuhkan": "Mobile Developer",
        "keahlian_dibutuhkan": "Flutter, Dart",
        "jumlah_anggota_dibutuhkan": 1
      },
      {
        "posisi_dibutuhkan": "Hardware Engineer",
        "keahlian_dibutuhkan": "ESP32, C++",
        "jumlah_anggota_dibutuhkan": 1
      }
    ]
    ```
  * `dokumen_pendukung[]` (file, optional): File poster/panduan PDF/PNG/JPG
  * `jenis_dokumen[]` (string, optional): `"poster"` atau `"panduan"`
* **Response (201 Created):**
```json
{
  "success": true,
  "message": "Tim berhasil dibuat",
  "data": {
    "id_tim": "tim_99182a",
    "nama_tim": "Inovasi Unand",
    "nama_kegiatan": "PIMNAS 2026",
    "kategori_kegiatan": "PKM-KC",
    "deskripsi": "Pengembangan prototipe sistem IoT kampus cerdas.",
    "status_tim": "terbuka",
    "dokumen_pendukung": [
      {
        "id_dokumen": "dok_1",
        "jenis_dokumen": "poster",
        "nama_file": "poster_kegiatan.png",
        "path_file": "https://storage.local/documents/poster_kegiatan.png",
        "urutan": 1
      }
    ]
  }
}
```

### 4.2 Daftar Tim yang Dibuat Saya (FR-10)
* **Endpoint:** `GET /teams/my-teams`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):** Menampilkan daftar tim yang dibuat oleh pembuat tim (user yang sedang login).

### 4.3 Detail Tim yang Dibuat Saya (FR-10)
* **Endpoint:** `GET /teams/{id_tim}`
* **Response (200 OK):** Menampilkan detail tim, kebutuhan tim, dokumen pendukung, dan daftar anggota tim saat ini.

### 4.4 Perbarui Tim (FR-11)
* **Endpoint:** `PUT /teams/{id_tim}` (atau `POST /teams/{id_tim}/update` untuk form multipart)
* **Deskripsi:** Mengubah informasi tim dan dokumen pendukung, **kecuali kategori kegiatan** (sesuai FR-11).
* **Form Fields:** `nama_tim`, `nama_kegiatan`, `deskripsi`, `status_tim`, `kebutuhan`, dll.

### 4.5 Hapus Tim (FR-12)
* **Endpoint:** `DELETE /teams/{id_tim}`
* **Deskripsi:** Menghapus tim yang dibuat beserta kebutuhan, dokumen pendukung, dan anggota secara konsisten (NFR-07).

---

## 5. Modul Feed & Eksplorasi Tim (Pencari Tim)

### 5.1 Feed Tim & Pencarian/Penyaringan (FR-14, FR-15)
* **Endpoint:** `GET /teams/feed`
* **Query Parameters:**
  * `search`: kata kunci pencarian (nama kegiatan, nama tim)
  * `kategori`: filter kategori kegiatan (misal: "Lomba", "Penelitian", "Proyek")
  * `keahlian`: filter keahlian yang dibutuhkan (misal: "Flutter")
  * `page`: nomor halaman (default: 1)
  * `limit`: jumlah data per halaman (default: 10)
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Feed tim berhasil diambil",
  "data": [
    {
      "id_tim": "tim_99182a",
      "nama_tim": "Inovasi Unand",
      "nama_kegiatan": "PIMNAS 2026",
      "kategori_kegiatan": "PKM-KC",
      "deskripsi": "Pengembangan prototipe sistem IoT kampus cerdas.",
      "status_tim": "terbuka",
      "pembuat_tim": {
        "id_pengguna": "usr_pembuat1",
        "nama_pengguna": "Rafa Gian Atthari",
        "foto_profil": "https://storage.local/profiles/rafa.jpg"
      },
      "kebutuhan_tim": [
        {
          "id_kebutuhan": "keb_1",
          "posisi_dibutuhkan": "Mobile Developer",
          "keahlian_dibutuhkan": "Flutter, Dart",
          "jumlah_anggota_dibutuhkan": 1
        }
      ],
      "dokumen_pendukung": [
        {
          "id_dokumen": "dok_1",
          "jenis_dokumen": "poster",
          "path_file": "https://storage.local/documents/poster_kegiatan.png"
        }
      ],
      "total_anggota_saat_ini": 2
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 10,
    "total_records": 12,
    "total_pages": 2
  }
}
```

### 5.2 Detail Tim untuk Pencari Tim (FR-16)
* **Endpoint:** `GET /teams/feed/{id_tim}`
* **Deskripsi:** Melihat detail lengkap tim, poster kegiatan, kebutuhan posisi, dan profil ringkas pembuat tim.

---

## 6. Modul Pengajuan Bergabung ke Tim (Pencari Tim → Pembuat Tim)

### 6.1 Kirim Pengajuan Bergabung ke Tim (FR-17 — Updated PRD v1.3)
> **Catatan PRD v1.3:** Wajib menyertakan posisi yang dilamar (`posisi`) dan pesan pengajuan.

* **Endpoint:** `POST /applications/join-team`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
```json
{
  "id_tim": "tim_99182a",
  "posisi": "Mobile Developer",
  "pesan_pengajuan": "Saya memiliki pengalaman membangun aplikasi Flutter dan siap berkontribusi pada posisi Mobile Developer di PIMNAS 2026."
}
```
* **Response (201 Created):**
```json
{
  "success": true,
  "message": "Pengajuan bergabung berhasil dikirim",
  "data": {
    "id_pengajuan_bergabung_tim": "app_join_883a",
    "id_tim": "tim_99182a",
    "id_pengguna": "usr_01h7abc...",
    "posisi": "Mobile Developer",
    "pesan_pengajuan": "Saya memiliki pengalaman membangun aplikasi Flutter...",
    "waktu_pengajuan": "2026-10-11T14:50:00Z",
    "status_pengajuan": "menunggu"
  }
}
```

### 6.2 Daftar Pengajuan Masuk ke Tim Saya (FR-18 — Untuk Pembuat Tim)
* **Endpoint:** `GET /teams/{id_tim}/applications`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Daftar pengajuan berhasil diambil",
  "data": [
    {
      "id_pengajuan_bergabung_tim": "app_join_883a",
      "posisi": "Mobile Developer",
      "pesan_pengajuan": "Saya memiliki pengalaman membangun aplikasi Flutter...",
      "waktu_pengajuan": "2026-10-11T14:50:00Z",
      "status_pengajuan": "menunggu",
      "pelamar": {
        "id_pengguna": "usr_01h7abc...",
        "nim": "2411522001",
        "nama_pengguna": "Fuadi Dhiyaulhaq",
        "program_studi": "Sistem Informasi",
        "foto_profil": "https://storage.local/profiles/fuad.jpg"
      }
    }
  ]
}
```

### 6.3 Detail Pengajuan Bergabung (FR-19 — Untuk Pembuat Tim)
* **Endpoint:** `GET /applications/join-team/{id_pengajuan_bergabung_tim}`
* **Headers:** `Authorization: Bearer <token>`
* **Deskripsi:** Melihat detail pengajuan, termasuk posisi yang dilamar, pesan pengajuan, dan riwayat profil pelamar.

### 6.4 Menerima atau Menolak Pengajuan Bergabung (FR-20)
* **Endpoint:** `PATCH /applications/join-team/{id_pengajuan_bergabung_tim}/status`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
```json
{
  "status_pengajuan": "diterima"
}
```
*(Nilai valid: `"diterima"`, `"ditolak"`)*
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Status pengajuan berhasil diperbarui menjadi diterima",
  "data": {
    "id_pengajuan_bergabung_tim": "app_join_883a",
    "status_pengajuan": "diterima",
    "waktu_diproses": "2026-10-11T15:00:00Z"
  }
}
```
*(Jika diterima, sistem secara otomatis memasukkan pelamar ke dalam tabel `Anggota_Tim` dengan atribut `posisi` sesuai yang dilamar).*

### 6.5 Riwayat Status Pengajuan Saya (FR-21 — Untuk Pencari Tim)
* **Endpoint:** `GET /applications/my-applications`
* **Headers:** `Authorization: Bearer <token>`
* **Response (200 OK):** Menampilkan daftar tim yang pernah diajukan oleh pengguna beserta statusnya (`menunggu`, `diterima`, `ditolak`).

---

## 7. Modul Pencarian Anggota & Undangan Rekrutmen (Pembuat Tim → Calon Anggota)

### 7.1 Pencarian Calon Anggota (FR-22)
* **Endpoint:** `GET /members/search`
* **Query Parameters:**
  * `q`: kata kunci (nama mahasiswa)
  * `keahlian`: keahlian yang dicari (misal: "Figma", "Machine Learning")
  * `minat`: minat yang dicari (misal: "UI/UX", "Data Science")
  * `page`: halaman (default: 1)
  * `limit`: batasan data (default: 10)
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Pencarian calon anggota berhasil",
  "data": [
    {
      "id_pengguna": "usr_kandidat1",
      "nama_pengguna": "Nayla Puspita Sari",
      "program_studi": "Sistem Informasi",
      "fakultas": "Teknologi Informasi",
      "foto_profil": "https://storage.local/profiles/nayla.jpg",
      "keahlian": ["UI Design", "Figma"],
      "minat": ["UI/UX Design"],
      "total_pengalaman": 3
    }
  ]
}
```

### 7.2 Lihat Profil Detail Calon Anggota (FR-23)
* Menggunakan `GET /profile/detail/{id_pengguna}` (Seksi 3.7).

### 7.3 Kirim Undangan/Tawaran Bergabung kepada Calon Anggota (FR-24)
* **Endpoint:** `POST /applications/invite-member`
* **Headers:** `Authorization: Bearer <token>`
* **Request Body:**
```json
{
  "id_tim": "tim_99182a",
  "id_pengguna": "usr_kandidat1",
  "pesan_pengajuan": "Halo Nayla, kami membutuhkan keahlian UI/UX Design Anda untuk tim PIMNAS kami."
}
```
* **Response (201 Created):**
```json
{
  "success": true,
  "message": "Permintaan bergabung kepada calon anggota berhasil dikirim",
  "data": {
    "id_pengajuan_anggota": "inv_mem_772c",
    "id_tim": "tim_99182a",
    "id_pengguna": "usr_kandidat1",
    "pesan_pengajuan": "Halo Nayla...",
    "waktu_pengajuan": "2026-10-11T14:52:00Z",
    "status_pengajuan": "menunggu"
  }
}
```

### 7.4 Calon Anggota Menerima / Menolak Undangan (FR-25)
* **Daftar Undangan yang Diterima Calon Anggota:** `GET /applications/received-invitations`
* **Respons Undangan:** `PATCH /applications/invite-member/{id_pengajuan_anggota}/status`
* **Request Body:**
```json
{
  "status_pengajuan": "diterima"
}
```
*(Nilai valid: `"diterima"`, `"ditolak"`)*

---

## 8. Modul Notifikasi (FR-08, FR-13, FR-21, FR-26)

### 8.1 Daftar Notifikasi Pengguna
* **Endpoint:** `GET /notifications`
* **Headers:** `Authorization: Bearer <token>`
* **Query Parameters:** `page`, `limit`, `status_dibaca` (true/false)
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Daftar notifikasi berhasil diambil",
  "data": [
    {
      "id_notifikasi": "notif_001",
      "id_pengguna": "usr_01h7abc...",
      "jenis_notifikasi": "pengajuan_bergabung_diterima",
      "pesan_notifikasi": "Selamat! Pengajuan Anda untuk posisi Mobile Developer di tim 'Inovasi Unand' telah diterima.",
      "id_pengajuan_bergabung_tim": "app_join_883a",
      "id_pengajuan_anggota": null,
      "status_dibaca": false,
      "waktu_notifikasi": "2026-10-11T15:00:00Z"
    }
  ]
}
```

### 8.2 Tandai Notifikasi Telah Dibaca
* **Endpoint:** `PATCH /notifications/{id_notifikasi}/read`
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Notifikasi ditandai telah dibaca",
  "data": {
    "id_notifikasi": "notif_001",
    "status_dibaca": true
  }
}
```

### 8.3 Jumlah Notifikasi Belum Dibaca
* **Endpoint:** `GET /notifications/unread-count`
* **Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "unread_count": 3
  }
}
```

---

## 9. Pemetaan Entitas ERD & Field Summary

| Nama Entitas | Kolom / Fields | Tipe Data | Keterangan |
| :--- | :--- | :--- | :--- |
| **Pengguna** | `id_pengguna`<br>`nim`<br>`kata_sandi`<br>`nama_pengguna`<br>`foto_profil` | PK (UUID/String)<br>String (10)<br>String (Hash)<br>String (100)<br>String (Nullable) | Data akun mahasiswa |
| **Data_Diri** | `id_pengguna`<br>`deskripsi_singkat`<br>`kontak`<br>`program_studi`<br>`fakultas`<br>`ipk` | FK Pengguna (PK)<br>Text<br>String (20)<br>String (50)<br>String (50)<br>Decimal (3,2) | Informasi diri & akademik (1-to-1) |
| **Media_Sosial** | `id_media_sosial`<br>`id_pengguna`<br>`nama_media_sosial`<br>`link_media_sosial` | PK<br>FK Pengguna<br>String (50)<br>String (255) | Akun medsos mahasiswa |
| **Data_Minat** | `id_minat`<br>`id_pengguna`<br>`minat`<br>`deskripsi_minat` | PK<br>FK Pengguna<br>String (100)<br>Text | Minat kegiatan / topik |
| **Data_Keahlian** | `id_keahlian`<br>`id_pengguna`<br>`keahlian`<br>`deskripsi_keahlian` | PK<br>FK Pengguna<br>String (100)<br>Text | Skill teknis / non-teknis |
| **Data_Pengalaman** | `id_pengalaman`<br>`id_pengguna`<br>`nama_kegiatan`<br>`peran`<br>`tahun`<br>`deskripsi_pengalaman` | PK<br>FK Pengguna<br>String (150)<br>String (100)<br>Integer<br>Text | Riwayat pengalaman (tanpa upload media) |
| **Data_Tim** | `id_tim`<br>`id_pengguna`<br>`nama_tim`<br>`nama_kegiatan`<br>`kategori_kegiatan`<br>`deskripsi`<br>`status_tim` | PK<br>FK Pengguna (Pembuat Tim)<br>String (100)<br>String (150)<br>String (50)<br>Text<br>Enum('terbuka','ditutup') | Data tim kegiatan |
| **Kebutuhan_Tim** | `id_kebutuhan`<br>`id_tim`<br>`posisi_dibutuhkan`<br>`keahlian_dibutuhkan`<br>`jumlah_anggota_dibutuhkan` | PK<br>FK Data_Tim<br>String (100)<br>String (255)<br>Integer | Kebutuhan role & slot |
| **Dokumen_Pendukung** | `id_dokumen`<br>`id_tim`<br>`jenis_dokumen`<br>`nama_file`<br>`path_file`<br>`urutan` | PK<br>FK Data_Tim<br>Enum('poster','panduan')<br>String (255)<br>String (255)<br>Integer | File poster/panduan tim |
| **Anggota_Tim** | `id_anggota_tim`<br>`id_tim`<br>`id_pengguna`<br>`posisi` | PK<br>FK Data_Tim<br>FK Pengguna<br>String (100) | Anggota tim yang telah diterima |
| **Pengajuan_Bergabung_Tim** | `id_pengajuan_bergabung_tim`<br>`id_tim`<br>`id_pengguna`<br>`posisi`<br>`pesan_pengajuan`<br>`waktu_pengajuan`<br>`status_pengajuan` | PK<br>FK Data_Tim<br>FK Pengguna (Pelamar)<br>String (100)<br>Text<br>DateTime<br>Enum('menunggu','diterima','ditolak') | Pengajuan pelamar ke tim dengan posisi yang dilamar |
| **Pengajuan_Anggota** | `id_pengajuan_anggota`<br>`id_tim`<br>`id_pengguna`<br>`pesan_pengajuan`<br>`waktu_pengajuan`<br>`status_pengajuan` | PK<br>FK Data_Tim<br>FK Pengguna (Kandidat)<br>Text<br>DateTime<br>Enum('menunggu','diterima','ditolak') | Undangan rekrutmen dari pembuat tim |
| **Notifikasi** | `id_notifikasi`<br>`id_pengguna`<br>`id_pengajuan_bergabung_tim`<br>`id_pengajuan_anggota`<br>`jenis_notifikasi`<br>`pesan_notifikasi`<br>`waktu_notifikasi`<br>`status_dibaca` | PK<br>FK Pengguna<br>FK (Nullable)<br>FK (Nullable)<br>String (50)<br>Text<br>DateTime<br>Boolean | Notifikasi aktivitas pengguna |
