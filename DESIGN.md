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
| **Dokumen Acuan** | PRD MyTeam Versi 1.3 & API Specification Contract Versi 1.3.0 |
| **Tipografi Utama** | Google Font: **Inter** |
| **Warna Utama Brand** | **Unand Emerald Green** (`#008000` / `#006400`) |
| **Anggota Tim (4 Mahasiswa)** | 1. **Nayla Puspita Sari** (2411521007) — *PIC Modul 4*<br>2. **Diva Ramadhani** (2411521017) — *PIC Modul 3*<br>3. **Fuadi Dhiyaulhaq** (2411522001) — *PIC Modul 1*<br>4. **Rafa Gian Atthari** (2411522014) — *PIC Modul 2* |

---

## 1. Filosofi & Karakter Visual (*Brand & Style*)

Sistem desain **Academic Emerald Synergy** merefleksikan atmosfer kampus digital Universitas Andalas yang terpelajar, berintegritas, dinamis, dan kolaboratif. Sistem ini memadukan kedisiplinan dan prestise dunia akademik dengan semangat kompetitif mahasiswa dalam berkarya—mulai dari riset ilmiah, Program Kreativitas Mahasiswa (PKM), perlombaan nasional/internasional, hingga proyek capstone.

Gaya visual yang diusung adalah **_Modern Academic Minimal_**:
* **Terstruktur & Berdensitas Tinggi:** Tata letak rapi dengan legibilitas teks yang tinggi untuk membaca abstrak kegiatan dan profil akademik.
* **Pendekatan Tactile & Ergonomis:** Menggunakan sudut membulat (*rounded corners*) yang lembut dan bersahabat bagi interaksi sentuhan layar sentuh mobile.
* **Identitas Hijau Unand (Emerald Green):** Menghindari kesan birokratis yang kaku dengan kombinasi putih bersih (*pure white canvas*), aksen hijau zamrud yang melambangkan pertumbuhan dan kebanggaan almamater, serta aksen semantik yang kaya.

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

### 3.6 Navigasi Bawah (*Bottom Navigation Bar*)
* 4 Tab Utama:
  1. **Beranda / Feed Tim** (Ikon: `Icons.explore_outlined` / `explore`)
  2. **Tim Saya** (Ikon: `Icons.groups_outlined` / `groups`)
  3. **Cari Rekan** (Ikon: `Icons.person_search_outlined` / `person_search`)
  4. **Profil & Notifikasi** (Ikon: `Icons.account_circle_outlined` / `account_circle`)
* Tab aktif: Berwarna `#008000` dengan titik indikator 4px di bawah ikon. Tab non-aktif: `#6B7280`.

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

| Aspek Desain | Keselarasan dengan PRD v1.3 | Keselarasan dengan API Contract |
| :--- | :--- | :--- |
| **Formulir Pengalaman** | Tidak ada field upload gambar/media; input hanya Nama Kegiatan, Peran, Tahun, dan Deskripsi. | Sesuai `POST /profile/pengalaman` (`deskripsi_pengalaman`). |
| **Pengajuan Bergabung** | Modal pemilihan posisi yang dibuka sebelum mengirim pesan pengajuan. | Sesuai `POST /applications/join-team` (wajib parameter `posisi`). |
| **Badge Status** | Tiga warna standar: Kuning (menunggu), Hijau (diterima), Merah (ditolak). | Sesuai enum field `status_pengajuan` pada database. |
| **Dokumen Tim** | Tampilan lampiran PDF/Gambar untuk poster kegiatan dan pedoman teknis tim. | Sesuai entitas `Dokumen_Pendukung` (`poster` / `panduan`). |

---

*Panduan desain ini resmi digunakan sebagai acuan visual seluruh anggota kelompok dalam pembuatan antarmuka aplikasi MyTeam.*
