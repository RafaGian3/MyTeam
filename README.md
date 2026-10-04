# MyTeam

### Aplikasi Mobile Pencarian dan Pembentukan Tim Mahasiswa UNAND

MyTeam adalah aplikasi mobile berbasis Android yang membantu mahasiswa Universitas Andalas menemukan, membentuk, dan bergabung dengan tim untuk berbagai kegiatan seperti lomba, penelitian, proyek, dan kegiatan kampus lainnya.

Aplikasi ini membantu mahasiswa menemukan rekan yang sesuai berdasarkan minat, keahlian, pengalaman, dan kebutuhan suatu kegiatan tanpa harus bergantung pada berbagai grup atau media komunikasi.

---

## 📌 Latar Belakang

Mahasiswa yang ingin mengikuti kegiatan yang membutuhkan pembentukan tim masih mengalami kesulitan dalam menemukan tim atau anggota yang sesuai. Informasi mengenai mahasiswa yang mencari tim maupun mahasiswa yang membutuhkan anggota juga masih tersebar di berbagai grup dan media komunikasi.

MyTeam hadir sebagai wadah untuk mempermudah proses pencarian dan pembentukan tim secara lebih terstruktur.

---

## 🎯 Tujuan

MyTeam bertujuan untuk:

- Mempermudah mahasiswa menemukan tim yang sesuai dengan minat, keahlian, dan pengalaman.
- Mempermudah pembuat tim menemukan calon anggota yang sesuai dengan kebutuhan.
- Memperluas jangkauan pencarian tim dan anggota.
- Memfasilitasi proses pengajuan bergabung dan pengajuan kepada calon anggota.
- Memberikan informasi status pengajuan secara jelas melalui notifikasi.

---

## 👥 Target Pengguna

MyTeam ditujukan untuk mahasiswa aktif Universitas Andalas.

Pengguna dapat memiliki dua peran:

- **Pencari Tim** — mencari dan bergabung dengan tim yang sesuai.
- **Pencari Anggota** — membuat tim dan mencari anggota sesuai kebutuhan.

Satu mahasiswa dapat memiliki kedua peran tersebut dan mengatur preferensi pencarian sesuai kebutuhannya.

---

## ✨ Fitur Utama

### 1. Akun & Data Riwayat Diri

Pengguna dapat mengelola informasi diri, pendidikan, media sosial, minat, keahlian, pengalaman beserta bukti pendukung, preferensi pencarian, serta informasi tim yang diikuti.

### 2. Pembentukan Tim

Pengguna dapat:

- Membuat tim.
- Mengisi informasi kegiatan.
- Menentukan kebutuhan anggota.
- Mengunggah dokumen pendukung seperti poster atau panduan.
- Melihat detail tim.
- Mengubah informasi tim.
- Menghapus tim.

### 3. Pencarian Tim & Pengajuan Bergabung

Pengguna sebagai pencari tim dapat:

- Melihat feed tim.
- Mencari tim.
- Memfilter tim berdasarkan kriteria tertentu.
- Melihat detail tim.
- Mengajukan permintaan bergabung.
- Melihat status pengajuan.

Pembuat tim dapat melihat, menerima, atau menolak pengajuan bergabung.

### 4. Pencarian Anggota & Pengajuan Anggota

Pembuat tim dapat mencari calon anggota berdasarkan:

- Nama pengguna.
- Keahlian.
- Pengalaman.
- Minat.

Pembuat tim juga dapat melihat informasi calon anggota dan mengirimkan permintaan untuk bergabung ke tim.

Calon anggota dapat menerima atau menolak permintaan tersebut.

### 5. Notifikasi

Sistem memberikan notifikasi terkait:

- Pembaruan data riwayat diri.
- Pengajuan bergabung ke tim.
- Pengajuan kepada calon anggota.
- Respons terhadap pengajuan.
- Perubahan status pengajuan.

---

## 🔄 Alur Utama

```text
                     ┌──────────────┐
                     │   Open App   │
                     └──────┬───────┘
                            │
                     ┌──────▼───────┐
                     │  Daftar/Login│
                     └──────┬───────┘
                            │
                     ┌──────▼───────┐
                     │    Beranda   │
                     └──────┬───────┘
                            │
             ┌──────────────┴──────────────┐
             │                             │
      ┌──────▼──────┐               ┌──────▼──────┐
      │  Pencari    │               │   Pencari   │
      │     Tim     │               │   Anggota   │
      └──────┬──────┘               └──────┬──────┘
             │                             │
      Cari & Filter                  Buat Tim /
             │                       Cari Anggota
             │                             │
      Lihat Detail                   Pengajuan
             │                             │
      Ajukan Bergabung               Terima/Tolak
             │                             │
             └──────────────┬──────────────┘
                            │
                     ┌──────▼───────┐
                     │  Notifikasi  │
                     └──────────────┘
```

---

## 🛠️ Teknologi

| Teknologi | Keterangan |
|---|---|
| Flutter | Framework pengembangan aplikasi |
| Dart | Bahasa pemrograman |
| Android | Platform aplikasi |
| Database | Penyimpanan dan pertukaran data aplikasi |
| Git & GitHub | Version control dan repository |
| Figma | Perancangan UI/UX |

Aplikasi dikembangkan menggunakan Flutter untuk perangkat Android dengan minimum versi Android 8.0 (Oreo).

---

## 📱 Platform

- Android
- Minimum Android 8.0 (Oreo)

---

## 📂 Struktur Project

Struktur project akan mengikuti arsitektur dan implementasi Flutter yang digunakan dalam pengembangan aplikasi.

Contoh struktur:

```text
MyTeam/
├── android/
├── assets/
├── lib/
│   ├── models/
│   ├── data/
│   ├── screens/
│   ├── widgets/
│   ├── routes/
│   └── utils/
├── test/
├── pubspec.yaml
└── README.md
```

Struktur dapat berkembang selama proses pengembangan sesuai kebutuhan masing-masing modul.

---

## 👨‍💻 Tim Pengembang

| Nama | NIM |
|---|---|
| Nayla Puspita Sari | 2411521007 |
| Diva Ramadhani | 2411521017 |
| Fuadi Dhiyaulhaq | 2411522001 |
| Rafa Gian Atthari | 2411522014 |

**Mata Kuliah:** Mobile Programming  
**Universitas:** Universitas Andalas  
**Versi PRD:** 1.2  
**Tanggal PRD:** 30 September 2026

---

## 📋 Requirements

Untuk menjalankan project, pastikan telah tersedia:

- Flutter SDK
- Dart SDK
- Android Studio atau IDE yang mendukung Flutter
- Android Emulator atau perangkat Android
- Git

---

## 🚀 Cara Menjalankan Project

Clone repository:

```bash
git clone https://github.com/RafaGian3/MyTeam.git
```

Masuk ke folder project:

```bash
cd MyTeam
```

Install dependencies:

```bash
flutter pub get
```

Jalankan aplikasi:

```bash
flutter run
```

Untuk memeriksa kode:

```bash
flutter analyze
```

---

## 📌 Scope

### In Scope

- Pengelolaan akun dan data riwayat diri.
- Pengelolaan media sosial, minat, keahlian, dan pengalaman.
- Pembuatan dan pengelolaan tim.
- Pengelolaan kebutuhan anggota dan dokumen pendukung.
- Pencarian dan penyaringan tim.
- Pencarian calon anggota.
- Pengajuan bergabung dua arah.
- Penerimaan atau penolakan pengajuan.
- Pemantauan status pengajuan.
- Notifikasi terkait aktivitas pengajuan dan perubahan status.

### Out of Scope

MyTeam tidak mencakup:

- Katalog atau daftar resmi kegiatan.
- Pendaftaran resmi ke kegiatan.
- Pengelolaan tim setelah pembentukan selesai.
- Chat atau komunikasi langsung antarmahasiswa.
- Pembayaran atau transaksi.
- Sistem rekomendasi berbasis AI/ML.
- Admin sebagai aktor utama.
- Firebase Storage.

---

## 🔐 Catatan

MyTeam dirancang sebagai aplikasi **user-to-user** tanpa admin sebagai aktor utama. Data yang ditampilkan dalam aplikasi berasal dari data yang dimasukkan oleh pengguna.

Aplikasi membutuhkan koneksi internet untuk fungsi yang memerlukan pertukaran dan pembaruan data antarpengguna.

---

## 📄 Dokumentasi

Dokumentasi lengkap mengenai kebutuhan produk, functional requirements, non-functional requirements, user flow, data requirements, scope, dan constraints tersedia pada **Product Requirements Document (PRD)**.

---

## 📚 Academic Project

Project ini dikembangkan sebagai bagian dari **Mata Kuliah Mobile Programming, Fakultas Teknologi Informasi, Universitas Andalas**.
