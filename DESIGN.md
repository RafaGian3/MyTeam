# PANDUAN SISTEM DESAIN (DESIGN SYSTEM SPECIFICATION)
## APLIKASI MOBILE "MyTeam" — UNIVERSITAS ANDALAS

---

### Informasi Dokumen & Tim Pengembang
| Metadata | Keterangan |
| :--- | :--- |
| **Nama Sistem Desain** | **Academic Emerald Synergy** |
| **Aplikasi Target** | MyTeam – Platform Kolaborasi dan Pembentukan Tim Mahasiswa Unand |
| **Mata Kuliah** | Pemrograman Aplikasi Mobile (PAM) |
| **Fakultas / Kampus** | Teknologi Informasi, Universitas Andalas |
| **Versi Dokumen** | **1.0.0 (Official Design Guide)** |
| **Tanggal Terbit** | 11 Oktober 2026 |
| **Dokumen Acuan** | PRD MyTeam Versi 1.0 & API Specification Contract Versi 1.0.0 |
| **Tipografi Utama** | Google Font: **Inter** |
| **Warna Utama Brand** | **Unand Emerald Green** (`#008000` / `#006400`) |
| **Aset Logo Utama** | `assets/images/logo-MyTeam.png` (Dimensi: 1254 × 1254 px) |
| **Anggota Tim (4 Mahasiswa)** | 1. **Fuadi Dhiyaulhaq** (2411522001) — *PIC Modul 1*<br>2. **Nayla Puspita Sari** (2411521007) — *PIC Modul 2*<br>3. **Rafa Gian Atthari** (2411522014) — *PIC Modul 3*<br>4. **Diva Ramadhani** (2411521017) — *PIC Modul 4* |

---

## 1. Filosofi & Karakter Visual (*Brand & Style*)

Sistem desain **Academic Emerald Synergy** merefleksikan atmosfer kampus digital Universitas Andalas yang terpelajar, berintegritas, dinamis, dan kolaboratif. Sistem ini memadukan kedisiplinan dan prestise dunia akademik dengan semangat kompetitif mahasiswa dalam berkarya—mulai dari riset ilmiah, Program Kreativitas Mahasiswa (PKM), perlombaan nasional/internasional, hingga proyek capstone.

Gaya visual yang diusung adalah **_Modern Academic Minimal_**:
* **Terstruktur & Berdensitas Tinggi:** Tata letak rapi dengan legibilitas teks yang tinggi untuk membaca abstrak kegiatan dan profil akademik.
* **Pendekatan Tactile & Ergonomis:** Menggunakan sudut membulat (*rounded corners*) yang lembut dan bersahabat bagi interaksi sentuhan layar sentuh mobile.
* **Identitas Hijau Unand (Emerald Green):** Menghindari kesan birokratis yang kaku dengan kombinasi putih bersih (*pure white canvas*), aksen hijau zamrud yang melambangkan pertumbuhan dan kebanggaan almamater, serta aksen semantik yang kaya.

### 1.1 Identitas Brand & Aset Logo Aplikasi (`logo-MyTeam.png`)

Logo resmi aplikasi **MyTeam** merupakan representasi grafis sinergi tim mahasiswa Unand:

| Atribut Aset | Spesifikasi Teknis | Keterangan & Penggunaan |
| :--- | :--- | :--- |
| **Nama Berkas** | `logo-MyTeam.png` | Aset master logo berformat PNG transparan. |
| **Dimensi Master** | **1254 × 1254 px** | Rasio 1:1 (*Square High-Resolution*), tajam untuk semua kerapatan layar mobile (*xxxhdpi*). |
| **Lokasi Aset Flutter** | `assets/images/logo-MyTeam.png` | Struktur standar aset Flutter (didaftarkan di `pubspec.yaml`). |
| **Palet Warna Dominan** | Emerald Green (`#008000` / `#006400`) | Selaras dengan warna identitas almamater Universitas Andalas. |

#### Panduan Penggunaan Logo pada Antarmuka (UI Guidelines):
1. **Layar Pembuka (*Splash Screen*):** 
   - Tampilkan logo di tengah layar (*center aligned*) dengan ukuran render `128 × 128 dp` atau `140 × 140 dp`.
   - Diiringi tipografi nama aplikasi **"MyTeam"** menggunakan font Inter Bold (24sp).
2. **Bilah Aplikasi (*AppBar / Top Navigation*):** 
   - Gunakan versi *logo mark* kompak dengan ukuran render `36 × 36 dp` atau `40 × 40 dp` di samping judul halaman utama / beranda.
3. **Status Kosong & Dialog (*Empty State / About Dialog*):**
   - Dapat digunakan sebagai ilustrasi dengan opasitas redup (50% - 70%) dan ukuran render `96 × 96 dp`.
4. **Ikon Peluncur Aplikasi (*App Launcher Icon*):**
   - Master aset `1254 × 1254 px` ini digunakan sebagai acuan *source icon* untuk di-*generate* menjadi berbagai ukuran launcher icon Android (`android/app/src/main/res/mipmap-*`).

---

## 2. Token Desain (Design Tokens)

### 2.1 Palet Warna (*Color Palette*)

#### A. Brand & Emerald Accents (Identitas Universitas Andalas)
| Nama Token | Nilai Hex | Peran & Penggunaan UI |
| :--- | :--- | :--- |
| `primary` | `#006400` | State aktif tombol utama, ikon navigasi terpilih |
| `primary-container` | `#008000` | Tombol CTA primer (*Unand Emerald*), header aksen |
| `primary-dark` | `#004D00` | Teks dengan kontras tinggi di atas kontainer hijau |
| `primary-soft` | `#E8F5E9` | Latar belakang chip terpilih, container badge sukses |
| `primary-outline` | `#C8E6C9` | Garis tepi chip aktif, highlight border kartu fokus |
| `on-primary` | `#FFFFFF` | Teks/ikon di atas warna primer |
| `on-primary-container` | `#CCFFBA` | Teks kontras pada container hijau gelap |

#### B. Fondasi Netral (*Neutral Foundation & Surfaces*)
| Nama Token | Nilai Hex | Peran & Penggunaan UI |
| :--- | :--- | :--- |
| `background` / `surface` | `#F9F9FF` / `#F8F9FA` | Latar belakang halaman (*scaffold background*) |
| `surface-container-lowest`| `#FFFFFF` | Permukaan kartu (*card surface*), modal dialog, bottom sheet |
| `surface-container-low` | `#F0F3FF` | Latar selang-seling tabel / section |
| `surface-container` | `#E7EEFE` | Latar belakang input pencarian pasif |
| `outline` | `#E5E7EB` | Garis pemisah hairline kartu dan divider standar (1px) |
| `on-surface` (Text Utama) | `#111827` | Judul layar, teks utama, nama kandidat, nama tim |
| `on-surface-variant` (Muted) | `#6B7280` | NIM, nama program studi/fakultas, tanggal, caption |

#### C. Aksen Semantik & Status (Sinkron dengan PRD & API Contract)
| Kategori Status | Background Pill | Warna Label | Penggunaan Komponen |
| :--- | :---: | :---: | :--- |
| **Kompetisi / Prestasi** | `#FEF3C7` | `#D97706` (Amber) | Kategori Lomba, badge keahlian khusus |
| **Riset / Kolaborasi Lab** | `#DBEAFE` | `#2563EB` (Blue) | Kategori Penelitian, link dokumen panduan |
| **Status "Diterima" / Sukses**| `#DCFCE7` | `#15803D` (Green) | Status pengajuan diterima, verifikasi mahasiswa |
| **Status "Menunggu" / Pending** | `#FEF9C3` | `#A16207` (Yellow)| Status pengajuan menunggu konfirmasi |
| **Status "Ditolak" / Urgensi** | `#FEE2E2` | `#DC2626` (Red) | Status pengajuan ditolak, deadline mepet, tombol hapus |

---

### 2.2 Sistem Tipografi (*Typography — Inter*)

Menggunakan font keluarga **Inter** dengan skala hierarki yang dioptimalkan untuk keterbacaan layar smartphone:

| Skala Tipografi | Ukuran (px) | Weight | Line Height | Letter Spacing | Peruntukan UI |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `headline-xl` | 36px / 28px (Mobile) | 700 (Bold) | 34px | -0.01em | Judul onboarding, hero screen |
| `headline-lg` | 30px / 22px (Mobile) | 600 (SemiBold)| 28px | -0.01em | Judul halaman utama (Beranda, Detail Tim) |
| `headline-md` | 18px | 600 (SemiBold)| 24px | 0 | Judul bagian (*section header*), modal title |
| `title-md` | 16px | 600 (SemiBold)| 22px | 0 | Nama kandidat pada kartu, nama tim pada card |
| `body-lg` | 16px | 400 (Regular) | 24px | 0 | Paragraf deskripsi tim & riwayat pengalaman |
| `body-md` | 14px | 400 (Regular) | 20px | 0 | Teks isi standar, input form text |
| `body-sm` | 12px | 400 (Regular) | 16px | 0 | Metadata subtitle (NIM, prodi, fakultas, tanggal) |
| `label-lg` | 14px | 600 (SemiBold)| 20px | +0.01em | Label tombol aksi utama (Button CTA) |
| `label-md` | 12px | 600 (SemiBold)| 16px | +0.02em | Label input form, segment controller |
| `label-sm` | 10px | 700 (Bold) | 14px | +0.04em | Teks badge pill status (`menunggu`, `diterima`) |

---

### 2.3 Tata Letak & Spasi (*Spacing & Layout Grid*)

Sistem menggunakan grid 4-kolom responsif untuk mobile viewport (<600px) berbasis kelipatan **4px**:

```text
Kelipatan Spasi:
├── space-xs  : 4px   (Jarak icon dan teks dalam badge)
├── space-sm  : 8px   (Gap horizontal antar chip/tags)
├── space-md  : 16px  (Padding kartu standar, margin layar mobile)
├── space-lg  : 24px  (Jarak antar seksi/kelompok formulir)
├── space-xl  : 32px  (Jarak heading dari konten utama)
└── space-xxl : 40px  (Bottom clearance untuk floating action button)
```

* **Margin Layar Standar:** `16px` pada perangkat smartphone, `24px` pada tablet.
* **Safe-Area Inset:** Bagian bawah selalu menyisakan safe-margin minimal `16px` di atas Bottom Navigation Bar.

---

### 2.4 Elevasi & Bayangan (*Elevation & Ambient Shadows*)

Kedalaman antarmuka dibangun dengan perpaduan garis tepi hairline (`1px solid #E5E7EB`) dan bayangan lembut beraksen hijau redup:

* **Level 0 (Flat Surface):** Nilai elevasi `0dp`. Diterapkan pada scaffold background (`#F8F9FA`).
* **Level 1 (Card & Top App Bar):** 
  * Surface `#FFFFFF` dengan border `1px solid #E5E7EB`.
  * Shadow: `box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05), 0 1px 2px -1px rgba(0, 0, 0, 0.05)`.
* **Level 2 (Active Focus Card, Modal Sheet, Segment Controller):**
  * Border aktif berubah menjadi `#C8E6C9`.
  * Shadow: `box-shadow: 0 4px 6px -1px rgba(0, 77, 0, 0.07), 0 2px 4px -2px rgba(0, 77, 0, 0.05)`.
* **Level 3 (Floating Action Button & Bottom Navigation Overlay):**
  * Shadow beraksen hijau: `box-shadow: 0 10px 15px -3px rgba(0, 128, 0, 0.18), 0 4px 6px -4px rgba(0, 128, 0, 0.10)`.

---

### 2.5 Bentuk & Radius Sudut (*Corner Radius*)

* **`rounded-sm` (4px):** Indikator badge kecil, check box, progress bar.
* **`rounded-md` (8px - 12px):** Kotak input teks form, drop-down menu, tombol sekunder.
* **`rounded-lg` (14px - 16px):** Kartu tim (*Team Card*), kartu profil kandidat, kontainer bottom sheet.
* **`rounded-full` (9999px):** Pill status badge, chip keahlian, ring avatar mahasiswa, Floating Action Button (FAB).

---

## 3. Spesifikasi Komponen UI (Spesifik Domain MyTeam)

### 3.1 Tombol & Elemen Aksi
1. **Primary Action Button (CTA):**
   * Tinggi standar: `48px` (ergonomis untuk jangkauan jempol).
   * Latar: `#008000` (hover/pressed: `#006400`).
   * Teks: `#FFFFFF` dengan gaya `label-lg`, radius `12px`.
2. **Secondary Outlined Button:**
   * Latar transparan / `#FFFFFF`, border `1.5px solid #008000`, teks `#008000`.
3. **Floating Action Button (FAB — Tambah Tim):**
   * Tombol bulat/kapsul dengan latar `#008000`, ikon putih, elevasi Level 3, posisi pojok kanan bawah (+16px margin).

---

### 3.2 Kartu Profil Kandidat (*Candidate Card — Modul 1 & 4*)
Diterapkan pada fitur pencarian calon anggota (FR-22) dan detail profil (FR-23):
* **Struktur Kartu:**
  * **Baris Atas:** Lingkaran foto profil berdiameter `44px` (dengan inisial fallback), nama mahasiswa (`title-md`), dan subtitle program studi/fakultas (`body-sm`, warna `#6B7280`).
  * **Baris Tengah:** Deskripsi diri singkat / minat, diikuti deretan chip pil horizontal (misal: `Flutter`, `UI/UX`, `Python`).
  * **Baris Bawah:** Indikator total pengalaman (misal: "3 Kegiatan") dan tombol aksi ("Ajak Bergabung" / "Lihat Profil").

---

### 3.3 Kartu Lowongan Tim (*Project Vacancy Card — Modul 2 & 3*)
Diterapkan pada Feed Tim (FR-14) dan Hasil Pencarian Tim (FR-15):
* **Aksen Visual Khas:** Terdapat garis penanda vertikal tebal `3.5px` di sisi kiri kartu dengan warna `#008000`.
* **Struktur Kartu:**
  * **Badge Kategori:** Pill di kanan atas (misal: `Lomba` latar `#FEF3C7`, atau `Penelitian` latar `#DBEAFE`).
  * **Header:** Nama tim (`title-md`) dan nama kegiatan lomba/PKM (`body-sm` `#6B7280`).
  * **Status Kuota Anggota:** Stack lingkaran avatar yang sudah terisi dan pill kapasitas (misal: "Sisa 1 Posisi" merah jika mendesak, atau "2 Posisi Terbuka" hijau).
  * **Tags Posisi:** Chip berisi nama role yang dicari (misal: `Mobile Developer`, `Hardware Specialist`).
  * **Aksi:** Tombol "Ajukan Bergabung" yang membuka bottom sheet pemilihan posisi yang dilamar (FR-17).

---

### 3.4 Grup Avatar Bertumpuk (*Stacked Avatar Group*)
* Lingkaran foto berukuran `28px` yang bertumpuk horizontal dengan margin negatif `-8px`.
* Setiap foto memiliki border lingkaran `2px solid #FFFFFF` untuk memisahkan antar foto.
* Lingkaran penutup bertuliskan `+N` (misal: `+2`) dengan latar `#E8F5E9` dan teks hijau gelap `#004D00`.

---

### 3.5 Kolom Pencarian & Filter (*Search & Filter Bar*)
* Tinggi: `48px`.
* Latar: `#FFFFFF` dengan border `1px solid #E5E7EB` (saat fokus berubah menjadi `1.5px solid #008000`).
* Prefix ikon: Kaca pembesar (`#6B7280`).
* Suffix ikon: Tombol filter corong dengan badge jika filter aktif.

---

### 3.6 Navigasi Bawah (*Bottom Navigation Bar — Flat Instagram Style*)
* Format: Rata lurus (*flat surface*), tinggi `58dp`, border atas `1px solid #E5E7EB`, latar `#FFFFFF`.
* 5 Tab Utama (Tepat 1 Kata per Tab):
  1. **Beranda** (Ikon: `Icons.home_outlined` / `home_rounded`) — Feed kegiatan & rekomendasi tim
  2. **Cari** (Ikon: `Icons.search_rounded`) — Pencarian tim & talenta mahasiswa
  3. **MyTeam** (Ikon: `Icons.groups_outlined` / `groups_rounded`) — Pembentukan & manajemen tim
  4. **Notifikasi** (Ikon: `Icons.notifications_none_rounded` / `notifications_rounded`) — Pusat pembaruan status & lamaran
  5. **Profil** (Ikon: `Icons.person_outline_rounded` / `person_rounded`) — Rekam jejak & portofolio akademik
* Tab aktif: Berwarna `#006400` (Emerald Unand) dengan label tebal `FontWeight.w700`. Tab non-aktif: `#6B7280`.

### 3.6.1 Header Universal Berlogo & Tombol Refresh (*Consistent Branded AppBar*)
* Seluruh 5 halaman utama (*Beranda*, *Cari*, *MyTeam*, *Notifikasi*, dan *Profil*) memiliki struktur AppBar yang 100% konsisten:
  * **Sisi Kiri:** Logo resmi MyTeam (`assets/images/logo-MyTeam.png`, `36x36px`) berbingkai radius `10px` dengan bayangan halus, disandingkan dengan teks tebal `"MyTeam"` (`#006400`, 20sp) dan subtitle dinamis sesuai konteks modul.
  * **Sisi Kanan:** Tombol **Segarkan / Refresh** (`Icons.refresh_rounded`, `#006400`) di dalam kontainer berukuran `38x38px` dengan border `1px solid #E5E7EB` dan radius `10px`.
* Memastikan keseragaman identitas visual dan kemudahan pengguna memperbarui data di seluruh sudut aplikasi.

---

### 3.7 Sub-Tab Segmented Pill Control (*Basecoat UI / Shadcn Style*)
Sub-navigasi internal pada halaman profil (Modul 1) menggunakan komponen Segmented Pill Control modern terinspirasi dari **Basecoat UI / Shadcn UI**:
* **Track Kontainer:**
  * Latar: `#F3F4F6` (Abu-abu netral lembut), tinggi `40dp`, padding `3dp`, radius sudut `12dp`.
  * Border luar: `0.8px solid #E5E7EB`.
* **Perilaku Dinamis (*Dynamic Expanding Pill*):**
  * **Tab Aktif (Selected):** Mengembang secara proporsional (`flex: 4`), latar putih `#FFFFFF` dengan bayangan halus (*elevation 1*, blur `4px`), menampilkan **Ikon + Teks Label** tebal berwarna `#006400`.
  * **Tab Tidak Aktif (Unselected):** Kompak dan ramping (`flex: 2`), **hanya menampilkan Ikon Simbol** berwarna `#6B7280` tanpa teks label.
* **Tujuan Ergonomis & UX:**
  * Menghilangkan masalah *text truncation / clipping* (teks "Pengalaman" yang sebelumnya terpotong menjadi "Pengalam...").
  * Memaksimalkan kenyamanan sentuhan jempol pada layar mobile berlebar sempit (≤ 360dp).
* **Pemetaan Simbol Ikon (Sesuai Struktur PRD):**
  1. **Tentang:** `Icons.person_rounded` (Biodata akademik, bio, kontak, media sosial, serta kartu riwayat *Tim yang Diikuti* sebelum tombol keluar sesi)
  2. **Minat:** `Icons.interests_rounded` (Daftar minat bidang / topik pengembangan mahasiswa — FR-04)
  3. **Keahlian:** `Icons.auto_awesome_rounded` (Daftar keahlian teknis/soft skills mahasiswa — FR-03)
  4. **Pengalaman:** `Icons.workspace_premium_rounded` (Rekam jejak kegiatan, peran kepanitiaan, dan lomba — FR-05)

* **Penempatan Kartu Tim yang Diikuti (FR-06):**
  * Demi simplifikasi navigasi dan fokus modul, kartu *Tim yang Diikuti* dipindahkan ke bagian bawah tab **Tentang**, tepat di atas tombol keluar sesi (*Logout*). Sub-navbar menjadi murni berfokus pada 4 domain utama: *Tentang*, *Minat*, *Keahlian*, dan *Pengalaman*.

### 3.8 Kartu Identitas Horizontal (*Hero Profile Card*) & Pusat Kendali Profil (*Settings Hub*)
* **Tata Letak Horizontal (*Left-to-Right Hero*):**
  * **Sisi Kiri:** Foto profil (`CircleAvatar` radius `36dp`) dilengkapi tombol ganti foto kamera.
  * **Sisi Tengah:** Nama lengkap mahasiswa (Inter Bold 16sp), teks NIM (`#6B7280`), dan badge status hijau muda `"Mahasiswa Aktif"`.
  * **Sisi Kanan:** Tombol **Pengaturan & Kelola Profil** (`Icons.settings_outlined`) yang membuka bottom sheet modal lengkap sebagai pusat kendali seluruh Modul 1.
* **Pusat Kendali Profil Komprehensif (*Management Hub Bottom Sheet*):**
  * Modal bottom sheet pengaturan menyediakan menu pengelolaan lengkap yang terbagi rapi ke dalam 3 kelompok:
    1. **DATA DIRI & PROFIL:**
       * **Perbarui Foto Profil** (`Icons.camera_alt_outlined`) — Membuka bottom sheet pemilih foto berkas atau avatar mahasiswa default.
       * **Edit Biodata & Kontak** (`Icons.badge_outlined`) — Membuka dialog formulir data akademik, bio, dan nomor WhatsApp.
       * **Kelola Media Sosial** (`Icons.share_outlined`) — Menavigasikan ke tab Tentang dan membuka dialog penambahan tautan medsos/portofolio.
    2. **KOMPETENSI & REKAM JEJAK:**
       * **Kelola Minat Bidang** (`Icons.interests_rounded`, badge *Tab Minat*) — Membuka tab Minat untuk melihat, menambah, atau menghapus topik ketertarikan.
       * **Kelola Keahlian Teknis** (`Icons.psychology_outlined`, badge *Tab Keahlian*) — Membuka tab Keahlian untuk mengelola skill teknis dan level kemahiran.
       * **Kelola Riwayat Pengalaman** (`Icons.workspace_premium_outlined`, badge *Tab Pengalaman*) — Membuka tab Pengalaman untuk mengelola rekam jejak organisasi, lomba, dan proyek.
    3. **APLIKASI & AKUN:**
       * **Tentang Aplikasi MyTeam** (`Icons.info_outline_rounded`) — Menampilkan dialog modal identitas aplikasi (v1.0.1 • Universitas Andalas).
       * **Keluar dari Akun** (`Icons.logout_rounded`, destruktif merah) — Membuka bottom sheet konfirmasi keluar sesi akun dengan aman.
* **Hierarki Kartu Tab Tentang & Aksi Edit Ringkas:**
  * **Urutan Kartu:** Kartu **Tentang Saya** diletakkan di posisi paling atas tab, diikuti oleh kartu **Akademik** (pengganti ringkas dari *Biodata & Data Akademik*), **Kontak**, **Media Sosial**, dan **Tim yang Diikuti**.
  * **Aksi Edit Ringkas:** Kartu *Tentang Saya* memuat tombol `[Edit]` ringkas (ikon pensil + label "Edit") untuk memperbarui data diri, bio, prodi, fakultas, IPK, dan nomor kontak secara terpadu.
* **Validasi Konfirmasi Hapus (*Destructive Confirmation Dialog*):**
  * Seluruh aksi hapus pada item portofolio (*Media Sosial*, *Minat*, *Keahlian*, dan *Pengalaman*) dilengkapi dialog konfirmasi modal (`AlertDialog`) dengan peringatan nama item, serta **dua tombol berukuran simetris (50:50)**: tombol *Batal* (`OutlinedButton` abu-abu netral) dan tombol *Hapus* (`ElevatedButton` merah destruktif) dengan tinggi dan radius membulat yang persis sama.

### 3.9 Layar Rangka Anatomi & Pemuatan Mulus (*Skeleton Screen & Seamless Loading*)
* **Pola Pemuatan Mulus (*Stale-While-Revalidate*):**
  * Menghilangkan *spinner loading* lingkaran yang menghalangi layar (*blocking full-screen spinner*).
  * Jika data profil sudah pernah dimuat di memori, aplikasi menampilkan data profil secara **instan dan tanpa kedip**, sementara penyegaran data berlangsung hening di latar belakang (*silent background sync*).
* **Skeleton Screen Mengikuti Anatomi Asli Halaman:**
  * Hanya saat data belum pernah dimuat sama sekali (inisialisasi awal), aplikasi menampilkan **Skeleton Screen** dengan animasi *pulse/shimmer* lembut (`Curves.easeInOut`, interval 850ms).
  * Struktur rangka skeleton 100% meniru tata letak visual halaman profil:
    1. **Hero Card:** Placeholder avatar lingkaran 72px, baris nama, NIM, badge status, dan tombol pengaturan.
    2. **Segmented Tab Bar:** Track pill abu-abu dengan 4 tab placeholder.
    3. **Kartu Tentang Saya:** Ikon kotak, judul, dan 3 baris teks bio.
    4. **Kartu Akademik:** 3 baris item data akademik (Prodi, Fakultas, IPK).
    5. **Kartu Kontak:** Placeholder kontak WhatsApp dan badge hijau.
    6. **Kartu Media Sosial:** 2 kontainer item media sosial.

---

## 4. Implementasi Siap Pakai di Flutter (`lib/theme/`)

Agar ke-4 anggota pengembang dapat langsung menggunakannya di kode program Flutter tanpa perbedaan variabel, berikut adalah kode sumber standarnya:

### 4.1 `lib/theme/app_colors.dart`
```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Emerald Unand
  static const primary = Color(0xFF006400);
  static const primaryContainer = Color(0xFF008000);
  static const primaryDark = Color(0xFF004D00);
  static const primarySoft = Color(0xFFE8F5E9);
  static const primaryOutline = Color(0xFFC8E6C9);

  // Canvas & Surfaces
  static const background = Color(0xFFF8F9FA);
  static const surface = Colors.white;
  static const border = Color(0xFFE5E7EB);
  static const borderFocused = Color(0xFF008000);

  // Typography
  static const text = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);

  // Semantics & Status (API Mapped)
  static const statusSuccessBg = Color(0xFFDCFCE7);
  static const statusSuccessText = Color(0xFF15803D);
  
  static const statusPendingBg = Color(0xFFFEF9C3);
  static const statusPendingText = Color(0xFFA16207);
  
  static const statusDangerBg = Color(0xFFFEE2E2);
  static const statusDangerText = Color(0xFFDC2626);

  static const categoryCompetitionBg = Color(0xFFFEF3C7);
  static const categoryCompetitionText = Color(0xFFD97706);

  static const categoryResearchBg = Color(0xFFDBEAFE);
  static const categoryResearchText = Color(0xFF2563EB);
}
```

### 4.2 `lib/theme/app_text_styles.dart`
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const headlineLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    letterSpacing: -0.2,
  );

  static const headlineMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const titleMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const bodyLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.45,
  );

  static const bodyMd = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.4,
  );

  static const bodySm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.35,
  );

  static const labelLg = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const labelSm = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );
}
```

---

## 5. Ringkasan Sinkronisasi Desain Antarmuka

| Aspek Desain | Keselarasan dengan PRD v1.0 | Keselarasan dengan API Contract |
| :--- | :--- | :--- |
| **Formulir Pengalaman** | Tidak ada field upload gambar/media; input hanya Nama Kegiatan, Peran, Tahun, dan Deskripsi. | Sesuai `POST /profile/pengalaman` (`deskripsi_pengalaman`). |
| **Pengajuan Bergabung** | Modal pemilihan posisi yang dibuka sebelum mengirim pesan pengajuan. | Sesuai `POST /applications/join-team` (wajib parameter `posisi`). |
| **Badge Status** | Tiga warna standar: Kuning (menunggu), Hijau (diterima), Merah (ditolak). | Sesuai enum field `status_pengajuan` pada database. |
| **Dokumen Tim** | Tampilan lampiran PDF/Gambar untuk poster kegiatan dan pedoman teknis tim. | Sesuai entitas `Dokumen_Pendukung` (`poster` / `panduan`). |

---

*Panduan desain ini resmi digunakan sebagai acuan visual seluruh anggota kelompok dalam pembuatan antarmuka aplikasi MyTeam.*
