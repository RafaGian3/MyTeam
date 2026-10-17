# MyTeam Backend API Server 🚀

Server Backend resmi untuk aplikasi mobile **MyTeam – Universitas Andalas**, dibangun menggunakan **Node.js + Express.js** dan terhubung ke database **MySQL (`myteam_db`)** di phpMyAdmin.

---

## 🛠️ Prasyarat
1. **Node.js** (v18 ke atas) sudah terpasang di laptop.
2. **XAMPP / Laragon** sudah menyala (modul Apache & MySQL aktif).

---

## ⚡ Panduan Cepat Menjalankan Backend & Setup Database Otomatis

Cukup jalankan 5 langkah simpel berikut lewat terminal:

1. Pastikan modul **Apache** dan **MySQL** di aplikasi XAMPP/Laragon sudah berstatus **Start**.
2. Buka terminal dan masuk ke folder `backend` dengan mengetik: `cd backend`.
3. Pasang dependensi package (cukup sekali di awal): `npm install`.
4. Jalankan perintah impor database otomatis: `npm run db:setup` (perintah ini otomatis membuat database `myteam_db`, 13 tabel, dan mengisi data dummy 4 anggota tim tanpa perlu membuka phpMyAdmin).
5. Jalankan server backend: `npm start` (server akan aktif di port 8000 dan siap melayani login aplikasi Flutter).

---

## 📱 Uji Coba Login dari Flutter

1. Pada kode proyek Flutter, pastikan URL API sudah mengarah ke `http://10.0.2.2:8000/api/v1` (untuk Android Emulator) atau `http://localhost:8000/api/v1` (untuk Chrome).
2. Jalankan aplikasi Flutter (`flutter run`).
3. Lakukan uji coba login menggunakan akun mahasiswa yang sudah terisi di database:
   - **NIM:** `2411522001` (Fuadi) / `2411522014` (Rafa) / `2411521017` (Diva) / `2411521007` (Nayla)
   - **Kata Sandi:** `SandiAman123!`

---

## 📡 Daftar Pemetaan Endpoint Lengkap (Sesuai Kontrak API v1.0.0)

Seluruh endpoint berikut diselaraskan 100% dengan dokumen [**`api_specification_contract.md`**](../api_specification_contract.md):

### 🔑 Modul 0: Autentikasi & Identitas Akun (Core / Shared Service)
| Method | Endpoint API | Deskripsi |
| :---: | :--- | :--- |
| `POST` | `/api/v1/auth/register` | Pendaftaran akun mahasiswa baru |
| `POST` | `/api/v1/auth/login` | Login mahasiswa menggunakan NIM & kata sandi |
| `POST` | `/api/v1/auth/foto-profil` | Unggah foto profil pengguna |

### 👤 Modul 1: Akun & Data Riwayat Diri (PIC: Fuadi Dhiyaulhaq)
| Method | Endpoint API | Kode FR | Deskripsi |
| :---: | :--- | :---: | :--- |
| `GET`, `PUT` | `/api/v1/profile/data-diri` | **FR-01** | Mengelola informasi biodata & kontak |
| `GET`, `POST`, `PUT`, `DELETE` | `/api/v1/profile/media-sosial` | **FR-02** | Mengelola tautan media sosial portofolio |
| `GET`, `POST`, `PUT`, `DELETE` | `/api/v1/profile/minat` | **FR-03** | Mengelola keminatan mahasiswa |
| `GET`, `POST`, `PUT`, `DELETE` | `/api/v1/profile/keahlian` | **FR-04** | Mengelola keahlian teknis & non-teknis |
| `GET`, `POST`, `PUT`, `DELETE` | `/api/v1/profile/pengalaman` | **FR-05** | Mengelola riwayat kegiatan (dengan deskripsi) |
| `GET` | `/api/v1/profile/detail/:id_pengguna` | **FR-06** | Profil lengkap, identitas, dan riwayat tim yang diikuti |
| *Auto-event* | `/api/v1/notifications` | **FR-07** | Notifikasi otomatis saat data riwayat diri diperbarui |

### 👥 Modul 2: Pembentukan & Manajemen Tim (PIC: Nayla Puspita Sari)
| Method | Endpoint API | Kode FR | Deskripsi |
| :---: | :--- | :---: | :--- |
| `POST` | `/api/v1/teams` | **FR-08** | Membuat tim baru beserta posisi dan upload poster/dokumen |
| `GET` | `/api/v1/teams/my-teams` | **FR-09** | Melihat daftar tim yang dibuat oleh pengguna |
| `GET` | `/api/v1/teams/:id_tim` | **FR-09** | Melihat rincian detail tim yang dibuat |
| `PUT` | `/api/v1/teams/:id_tim` | **FR-10** | Mengubah informasi tim dan kebutuhan anggota |
| `DELETE`| `/api/v1/teams/:id_tim` | **FR-11** | Menghapus tim (cascade aman ke berkas & relasi terkait) |
| *Auto-event* | `/api/v1/notifications` | **FR-12** | Notifikasi ke pembuat tim saat ada pelamar masuk |

### 🔍 Modul 3: Pencarian Tim & Pengajuan Bergabung (PIC: Rafa Gian Atthari)
| Method | Endpoint API | Kode FR | Deskripsi |
| :---: | :--- | :---: | :--- |
| `GET` | `/api/v1/teams/feed` | **FR-13, FR-14** | Feed tim terbaru & filter (kategori, search, keahlian) |
| `GET` | `/api/v1/teams/feed/:id_tim` | **FR-15** | Melihat detail tim dari feed pencarian |
| `POST` | `/api/v1/applications/join-team` | **FR-16** | Mengajukan bergabung ke tim (wajib menyertakan atribut `posisi`) |
| `GET` | `/api/v1/teams/:id_tim/applications` | **FR-17** | Pembuat tim melihat daftar pelamar yang masuk |
| `GET` | `/api/v1/applications/join-team/:id` | **FR-18** | Pembuat tim melihat detail profil & posisi pelamar |
| `PATCH`| `/api/v1/applications/join-team/:id/status` | **FR-19** | Pembuat tim menerima atau menolak lamaran |
| `GET` | `/api/v1/applications/my-applications` | **FR-20** | Pelamar memantau status lamaran yang diajukannya |

### 📢 Modul 4: Pencarian Anggota, Rekrutmen & Notifikasi (PIC: Diva Ramadhani)
| Method | Endpoint API | Kode FR | Deskripsi |
| :---: | :--- | :---: | :--- |
| `GET` | `/api/v1/members/search` | **FR-21** | Mencari calon anggota (nama, keahlian, minat, pengalaman) |
| `GET` | `/api/v1/profile/detail/:id_pengguna` | **FR-22** | Melihat detail profil calon anggota dari pencarian |
| `POST` | `/api/v1/applications/invite-member` | **FR-23** | Pembuat tim mengirim undangan ajakan ke calon anggota |
| `GET`, `PATCH` | `/api/v1/applications/received-invitations` | **FR-24** | Calon anggota melihat & merespons undangan tim |
| *Auto-event* | `/api/v1/notifications` | **FR-25** | Notifikasi ke pembuat tim saat undangan direspons |
| `GET` | `/api/v1/notifications` | **Universal** | Mengambil seluruh daftar notifikasi pengguna |
| `PATCH`| `/api/v1/notifications/:id/read` | **Universal** | Menandai notifikasi telah dibaca |
| `GET` | `/api/v1/notifications/unread-count` | **Universal** | Menghitung jumlah notifikasi yang belum dibaca |
